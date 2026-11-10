import 'dart:convert';

import 'package:yaml/yaml.dart';

/// A note split into its YAML frontmatter and Markdown body.
class ParsedNote {
  const ParsedNote({
    required this.frontmatter,
    required this.body,
    required this.bodyStartLine,
  });

  final Map<String, Object?> frontmatter;
  final String body;

  /// 1-based line number in the source file of the first body line.
  final int bodyStartLine;
}

class FrontmatterException implements Exception {
  const FrontmatterException(this.message, this.line);

  final String message;

  /// 1-based line number in the source file.
  final int line;

  @override
  String toString() => 'line $line: $message';
}

/// Splits [source] into frontmatter and body.
///
/// Handles CRLF and a leading byte-order mark so results are identical for
/// files authored on Windows.
ParsedNote parseNote(String source) {
  final text = source.startsWith('\uFEFF') ? source.substring(1) : source;
  final lines = const LineSplitter().convert(text);

  if (lines.isEmpty || lines.first.trim() != '---') {
    throw const FrontmatterException(
      'Note must start with a "---" frontmatter fence.',
      1,
    );
  }

  final end = lines.indexWhere((l) => l.trim() == '---', 1);
  if (end == -1) {
    throw const FrontmatterException(
      'Frontmatter is not closed with a "---" fence.',
      1,
    );
  }

  final Object? doc;
  try {
    doc = loadYaml(lines.sublist(1, end).join('\n'));
  } on YamlException catch (e) {
    throw FrontmatterException(e.message, 2 + (e.span?.start.line ?? 0));
  }

  if (doc != null && doc is! YamlMap) {
    throw const FrontmatterException('Frontmatter must be a YAML map.', 2);
  }

  return ParsedNote(
    frontmatter: doc == null ? const {} : _plain(doc) as Map<String, Object?>,
    body: lines.sublist(end + 1).join('\n'),
    bodyStartLine: end + 2,
  );
}

/// Converts YAML collections to plain Dart maps and lists.
Object? _plain(Object? node) {
  if (node is YamlMap) {
    return {for (final e in node.entries) e.key.toString(): _plain(e.value)};
  }
  if (node is YamlList) {
    return [for (final e in node) _plain(e)];
  }
  return node;
}
