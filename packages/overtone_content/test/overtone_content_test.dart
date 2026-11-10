// Runs on both the Dart VM and in Chrome (spike S7):
//   dart test
//   dart test -p chrome
import 'dart:convert';

import 'package:overtone_content/overtone_content.dart';
import 'package:test/test.dart';

const _lesson = '''
---
type: lesson
id: major-triads-introduction
title: Introduction to Major Triads
difficulty: beginner
estimatedMinutes: 6
prerequisites:
  - understanding-pitch
  - understanding-intervals
skills: [chord-quality-recognition]
---

# Major triads

See [[understanding-pitch]] and [[understanding-intervals|intervals]].
Not a link: `[[in-inline-code]]`.

```notation
source: c-major-triad.musicxml
display: score
playback: true
```

![[triad-construction.svg]]

```dart
// Not a link: [[in-code-fence]]
```

```chord
root: C
quality: major
```

![[c-major-triad.mp3]]
''';

void main() {
  group('parseNote', () {
    test('reads frontmatter as plain Dart values', () {
      final note = parseNote(_lesson);
      expect(note.frontmatter['id'], 'major-triads-introduction');
      expect(note.frontmatter['estimatedMinutes'], 6);
      expect(note.frontmatter['prerequisites'], [
        'understanding-pitch',
        'understanding-intervals',
      ]);
      expect(note.frontmatter['skills'], ['chord-quality-recognition']);
      expect(note.body.trimLeft(), startsWith('# Major triads'));
    });

    test('reports where the body starts in the source file', () {
      final note = parseNote(_lesson);
      final sourceLine = _lesson.split('\n')[note.bodyStartLine - 1];
      expect(sourceLine, '');
      expect(_lesson.split('\n')[note.bodyStartLine], '# Major triads');
    });

    test('CRLF and BOM give identical results', () {
      final crlf = '\uFEFF${_lesson.replaceAll('\n', '\r\n')}';
      final a = parseNote(_lesson);
      final b = parseNote(crlf);
      expect(b.frontmatter, a.frontmatter);
      expect(b.body, a.body);
      expect(b.bodyStartLine, a.bodyStartLine);
    });

    test('rejects a missing opening fence', () {
      expect(
        () => parseNote('# No frontmatter'),
        throwsA(isA<FrontmatterException>()),
      );
    });

    test('rejects an unclosed fence', () {
      expect(
        () => parseNote('---\nid: x\n# body'),
        throwsA(isA<FrontmatterException>()),
      );
    });

    test('reports the line of a YAML error', () {
      expect(
        () => parseNote('---\nid: x\ntitle: [unclosed\n---\nbody'),
        throwsA(
          isA<FrontmatterException>().having(
            (e) => e.line,
            'line',
            greaterThan(1),
          ),
        ),
      );
    });

    test('empty frontmatter is an empty map', () {
      expect(parseNote('---\n---\nbody').frontmatter, isEmpty);
    });
  });

  group('extractLinks', () {
    final note = parseNote(_lesson);
    final links = extractLinks(note.body, firstLine: note.bodyStartLine);

    test('finds wikilinks and embeds, ignoring code', () {
      expect(links.map((l) => '${l.kind.name}:${l.target}'), [
        'wikilink:understanding-pitch',
        'wikilink:understanding-intervals',
        'embed:triad-construction.svg',
        'embed:c-major-triad.mp3',
      ]);
    });

    test('parses labels', () {
      expect(links[1].label, 'intervals');
      expect(links[0].label, isNull);
    });

    test('line numbers point into the source file', () {
      final sourceLines = _lesson.split('\n');
      for (final l in links) {
        expect(sourceLines[l.line - 1], contains('[[${l.target}'));
      }
    });
  });

  group('extractBlocks', () {
    final note = parseNote(_lesson);
    final blocks = extractBlocks(note.body, firstLine: note.bodyStartLine);

    test('returns only musical blocks, parsed from YAML', () {
      expect(blocks.map((b) => b.language), ['notation', 'chord']);
      expect(blocks[0].data, {
        'source': 'c-major-triad.musicxml',
        'display': 'score',
        'playback': true,
      });
      expect(blocks[1].data, {'root': 'C', 'quality': 'major'});
    });

    test('line numbers point at the opening fence in the source', () {
      final sourceLines = _lesson.split('\n');
      for (final b in blocks) {
        expect(sourceLines[b.line - 1], '```${b.language}');
      }
    });

    test('reports an unclosed block', () {
      expect(
        () => extractBlocks('```chord\nroot: C\n'),
        throwsA(isA<BlockException>()),
      );
    });

    test('reports a non-map body', () {
      expect(
        () => extractBlocks('```chord\n- a\n- b\n```'),
        throwsA(isA<BlockException>()),
      );
    });
  });

  group('contentHash', () {
    test('matches a known SHA-256 prefix', () {
      expect(contentHash(utf8.encode('hello')), '2cf24dba5fb0a30e');
    });
  });
}
