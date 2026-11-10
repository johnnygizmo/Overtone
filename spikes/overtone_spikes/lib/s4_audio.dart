// Spike S4: Dart wrapper and test page for the Web Audio engine.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';

import 'spike_util.dart';

class ScheduledNote {
  const ScheduledNote(this.t, this.dur, this.midi, [this.vel = 0.8]);

  /// Seconds after the start of the playback.
  final double t;
  final double dur;
  final int midi;
  final double vel;

  JSAny toJs() => {'t': t, 'dur': dur, 'midi': midi, 'vel': vel}.jsify()!;
}

/// Dart side of the SoundSource interface described in PLAN.md section 8.1.
class WebAudioEngine {
  JSObject get _e => globalContext['overtoneAudio']! as JSObject;

  Future<String> unlock() async {
    final p = _e.callMethod<JSPromise<JSString>>('unlock'.toJS);
    return (await p.toDart).toDart;
  }

  String get state => _e.callMethod<JSString>('state'.toJS).toDart;

  Map<Object?, Object?> info() =>
      _e.callMethod<JSAny?>('info'.toJS).dartify()! as Map<Object?, Object?>;

  void setVolume(double v) => _e.callMethod<JSAny?>('setVolume'.toJS, v.toJS);

  int play(List<ScheduledNote> notes, {double delay = 0.05}) {
    final jsNotes = [for (final n in notes) n.toJs()].toJS;
    final opts = {'delay': delay}.jsify();
    return _e.callMethod<JSNumber>('play'.toJS, jsNotes, opts).toDartInt;
  }

  void stop(int id, {int fadeMs = 15}) =>
      _e.callMethod<JSAny?>('stop'.toJS, id.toJS, {'fadeMs': fadeMs}.jsify());

  void stopAll() => _e.callMethod<JSAny?>('stopAll'.toJS);

  Future<Map<Object?, Object?>> selfTest() async {
    final api = globalContext['OvertoneAudio']! as JSObject;
    final p = api.callMethod<JSPromise<JSAny?>>('selfTest'.toJS);
    return (await p.toDart).dartify()! as Map<Object?, Object?>;
  }
}

class S4AudioPage extends StatefulWidget {
  const S4AudioPage({super.key});

  @override
  State<S4AudioPage> createState() => _S4AudioPageState();
}

class _S4AudioPageState extends State<S4AudioPage> {
  final _audio = WebAudioEngine();
  var _status = '';
  var _volume = 0.8;
  int? _last;

  @override
  void initState() {
    super.initState();
    if (autoRun('S4')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selfTest());
    }
  }

  Future<void> _selfTest() async {
    final r = await _audio.selfTest();
    publishResult('spikeS4', r);
    setState(
      () => _status = r.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
    );
  }

  Future<void> _play(List<ScheduledNote> notes) async {
    final state = await _audio.unlock();
    _last = _audio.play(notes);
    setState(() => _status = 'context: $state\n${_audio.info()}');
  }

  List<ScheduledNote> _chord(List<int> midis, {double dur = 1.5}) => [
    for (final m in midis) ScheduledNote(0, dur, m),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _play([const ScheduledNote(0, 1.0, 69)]),
                  child: const Text('A4'),
                ),
                FilledButton(
                  onPressed: () => _play(const [
                    ScheduledNote(0, 0.7, 60),
                    ScheduledNote(0.8, 0.9, 67),
                  ]),
                  child: const Text('Melodic fifth'),
                ),
                FilledButton(
                  onPressed: () => _play(_chord([60, 67])),
                  child: const Text('Harmonic fifth'),
                ),
                FilledButton(
                  onPressed: () => _play(_chord([60, 64, 67])),
                  child: const Text('C major'),
                ),
                FilledButton(
                  onPressed: () => _play(_chord([60, 63, 67])),
                  child: const Text('C minor'),
                ),
                FilledButton(
                  onPressed: () => _play(_chord([60, 63, 66])),
                  child: const Text('C diminished'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _play(_chord([48, 60, 64, 67], dur: 6));
                    await Future<void>.delayed(
                      const Duration(milliseconds: 800),
                    );
                    if (_last != null) _audio.stop(_last!);
                    _last = _audio.play(_chord([62, 65, 69], dur: 2));
                  },
                  child: const Text('Replace after 0.8 s'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _audio.unlock();
                    for (var i = 0; i < 20; i++) {
                      if (_last != null) _audio.stop(_last!);
                      _last = _audio.play(_chord([60 + i % 12], dur: 2));
                      await Future<void>.delayed(
                        const Duration(milliseconds: 60),
                      );
                    }
                  },
                  child: const Text('Rapid replace x20'),
                ),
                OutlinedButton(
                  onPressed: _audio.stopAll,
                  child: const Text('Stop'),
                ),
                OutlinedButton(
                  onPressed: _selfTest,
                  child: const Text('Run offline self-test'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Volume'),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: (v) {
                      setState(() => _volume = v);
                      _audio.setVolume(v);
                    },
                  ),
                ),
              ],
            ),
            SelectableText(_status),
          ],
        ),
      ),
    );
  }
}
