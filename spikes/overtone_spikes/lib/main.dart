import 'package:flutter/material.dart';

import 's2_markdown_page.dart';
import 's3_notation.dart';
import 's4_audio.dart';
import 's5_caching.dart';
import 's6_storage.dart';

void main() {
  runApp(const SpikesApp());
}

class SpikesApp extends StatelessWidget {
  const SpikesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overtone spikes',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SpikeHome(),
    );
  }
}

class _Spike {
  const _Spike(this.id, this.title, this.builder);

  final String id;
  final String title;
  final WidgetBuilder builder;
}

final _spikes = <_Spike>[
  _Spike('S2', 'Markdown renderer', (_) => const S2MarkdownPage()),
  _Spike('S3', 'Notation', (_) => const S3NotationPage()),
  _Spike('S4', 'Audio', (_) => const S4AudioPage()),
  _Spike('S5', 'Caching', (_) => const S5CachingPage()),
  _Spike('S6', 'Storage', (_) => const S6StoragePage()),
];

class SpikeHome extends StatefulWidget {
  const SpikeHome({super.key});

  @override
  State<SpikeHome> createState() => _SpikeHomeState();
}

class _SpikeHomeState extends State<SpikeHome> {
  var _index = _spikes
      .indexWhere((s) => s.id == Uri.base.queryParameters['spike'])
      .clamp(0, _spikes.length - 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_spikes[_index].id}: ${_spikes[_index].title}'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final s in _spikes)
                NavigationRailDestination(
                  icon: Text(s.id),
                  label: Text(s.title),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _spikes[_index].builder(context)),
        ],
      ),
    );
  }
}
