import 'package:flutter/material.dart';
import 'package:overtone_content/overtone_content.dart';

import 's2_markdown.dart';

class S2MarkdownPage extends StatelessWidget {
  const S2MarkdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParsedNote>(
      future: loadSample(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        final note = snap.data;
        if (note == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: MarkdownView(
              body: note.body,
              knownNotes: const {
                'understanding-pitch': 'Understanding Pitch',
                'understanding-intervals': 'Understanding Intervals',
              },
            ),
          ),
        );
      },
    );
  }
}
