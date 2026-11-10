// Spike S3: OpenSheetMusicDisplay inside a Flutter HtmlElementView.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 's4_audio.dart';
import 'spike_util.dart';

const _viewType = 'overtone-notation';
var _registered = false;

void _registerViewFactory() {
  if (_registered) return;
  _registered = true;
  ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
    final div = web.HTMLDivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'auto'
      ..style.background = 'white';
    return div;
  });
}

/// A note in the rendered score.
class NoteRef {
  NoteRef(Map<Object?, Object?> m)
    : measure = m['measure']! as int,
      staff = m['staff']! as int,
      entry = m['entry']! as int,
      voice = m['voice']! as int,
      note = m['note']! as int,
      name = m['name']! as String,
      midi = m['midi']! as int;

  final int measure, staff, entry, voice, note, midi;
  final String name;

  Map<String, Object?> toRef() => {
    'measure': measure,
    'staff': staff,
    'entry': entry,
    'voice': voice,
    'note': note,
  };
}

/// Dart API over the JS wrapper; this is the surface PLAN.md 6.2 describes.
class NotationController {
  NotationController._(this._js);

  final JSObject _js;

  static NotationController attach(Object element) {
    final api = globalContext['OvertoneNotation']! as JSObject;
    final js = api.callMethod<JSObject>('attach'.toJS, element as JSAny);
    return NotationController._(js);
  }

  Future<int> loadUrl(String url) async {
    final r = await _js
        .callMethod<JSPromise<JSAny?>>('loadUrl'.toJS, url.toJS)
        .toDart;
    return (r.dartify()! as Map<Object?, Object?>)['notes']! as int;
  }

  List<NoteRef> notes() {
    final list =
        _js.callMethod<JSAny?>('notes'.toJS).dartify()! as List<Object?>;
    return [for (final m in list) NoteRef(m! as Map<Object?, Object?>)];
  }

  void highlight(List<NoteRef> notes) => _js.callMethod<JSAny?>(
    'highlight'.toJS,
    [for (final n in notes) n.toRef()].jsify(),
    '#d81b60'.toJS,
  );

  void clear() => _js.callMethod<JSAny?>('clear'.toJS);

  void onNoteTapped(void Function(NoteRef) cb) {
    _js.callMethod<JSAny?>(
      'onNoteClick'.toJS,
      ((JSAny? d) {
        cb(NoteRef(d.dartify()! as Map<Object?, Object?>));
      }).toJS,
    );
  }

  void dispose() => _js.callMethod<JSAny?>('dispose'.toJS);
}

const _scores = [
  'triad-treble',
  'bass-clef',
  'key-time-ties',
  'grand-staff-voices',
  'intervals-triplets',
];

class S3NotationPage extends StatefulWidget {
  const S3NotationPage({super.key});

  @override
  State<S3NotationPage> createState() => _S3NotationPageState();
}

class _S3NotationPageState extends State<S3NotationPage> {
  NotationController? _ctl;
  final _audio = WebAudioEngine();
  var _score = _scores.first;
  var _status = 'Loading...';
  NoteRef? _tapped;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  @override
  void dispose() {
    _ctl?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ctl = _ctl;
    if (ctl == null) return;
    try {
      final n = await ctl.loadUrl('scores/$_score.musicxml');
      setState(() => _status = '$_score: $n notes');
      publishResult('spikeS3', {'score': _score, 'notes': n});
    } catch (e) {
      setState(() => _status = 'Error: $e');
      publishResult('spikeS3', {'score': _score, 'error': '$e'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: _score,
                items: [
                  for (final s in _scores)
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) {
                  setState(() => _score = v!);
                  _load();
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _ctl?.highlight(
                  _ctl!.notes().where((n) => n.measure == 1).toList(),
                ),
                child: const Text('Highlight measure 1'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _ctl?.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          Text(_status),
          Text(
            _tapped == null
                ? 'Tap a note'
                : 'Tapped: ${_tapped!.name} (MIDI ${_tapped!.midi}), measure ${_tapped!.measure}',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: HtmlElementView(
              viewType: _viewType,
              onPlatformViewCreated: (id) {
                final el = ui_web.platformViewRegistry.getViewById(id);
                final ctl = NotationController.attach(el);
                ctl.onNoteTapped((n) async {
                  setState(() => _tapped = n);
                  ctl.highlight([n]);
                  await _audio.unlock();
                  _audio.play([ScheduledNote(0, 0.8, n.midi)]);
                });
                _ctl = ctl;
                _load();
              },
            ),
          ),
        ],
      ),
    );
  }
}
