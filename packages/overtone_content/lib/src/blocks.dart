import 'package:yaml/yaml.dart';

/// Language tags that are rendered as musical widgets.
const musicalBlockLanguages = {'notation', 'chord', 'fretboard', 'keyboard'};

/// A fenced musical block with a parsed YAML body.
class MusicalBlock {
  const MusicalBlock({
    required this.language,
    required this.data,
    required this.line,
  });

  final String language;
  final Map<String, Object?> data;

  /// 1-based source line of the opening fence.
  final int line;
}

class BlockException implements Exception {
  const BlockException(this.message, this.line);

  final String message;
  final int line;

  @override
  String toString() => 'line $line: $message';
}

final _open = RegExp(r'^\s{0,3}(`{3,})\s*([A-Za-z0-9_-]*)\s*$');

/// Extracts fenced blocks whose language is in [musicalBlockLanguages].
///
/// Other fenced code is skipped. [firstLine] is the source-file line number of
/// the first line of [body].
List<MusicalBlock> extractBlocks(String body, {int firstLine = 1}) {
  final blocks = <MusicalBlock>[];
  final lines = body.split('\n').map((l) => l.replaceAll('\r', '')).toList();

  var i = 0;
  while (i < lines.length) {
    final open = _open.firstMatch(lines[i]);
    if (open == null) {
      i++;
      continue;
    }

    final fence = open.group(1)!;
    final language = open.group(2)!;
    final startLine = firstLine + i;
    final content = <String>[];
    i++;
    var closed = false;
    while (i < lines.length) {
      final close = RegExp(r'^\s{0,3}(`{3,})\s*$').firstMatch(lines[i]);
      if (close != null && close.group(1)!.length >= fence.length) {
        closed = true;
        i++;
        break;
      }
      content.add(lines[i]);
      i++;
    }

    if (!musicalBlockLanguages.contains(language)) continue;
    if (!closed) {
      throw BlockException('Unclosed "$language" block.', startLine);
    }

    blocks.add(
      MusicalBlock(
        language: language,
        data: parseBlockData(language, content.join('\n'), startLine),
        line: startLine,
      ),
    );
  }
  return blocks;
}

/// Parses the YAML body of a musical block into a plain map.
///
/// [line] is the 1-based source line of the opening fence, used in errors.
Map<String, Object?> parseBlockData(String language, String yaml, int line) {
  final Object? doc;
  try {
    doc = loadYaml(yaml);
  } on YamlException catch (e) {
    throw BlockException(e.message, line + 1 + (e.span?.start.line ?? 0));
  }
  if (doc != null && doc is! YamlMap) {
    throw BlockException('"$language" block must be a YAML map.', line);
  }
  return {
    if (doc is YamlMap)
      for (final e in doc.entries) e.key.toString(): _plain(e.value),
  };
}

Object? _plain(Object? node) {
  if (node is YamlMap) {
    return {for (final e in node.entries) e.key.toString(): _plain(e.value)};
  }
  if (node is YamlList) return [for (final e in node) _plain(e)];
  return node;
}
