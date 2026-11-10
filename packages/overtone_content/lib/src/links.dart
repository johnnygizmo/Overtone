enum LinkKind { wikilink, embed }

/// A `[[target]]` link or `![[target]]` embed found in a note body.
class NoteLink {
  const NoteLink({
    required this.kind,
    required this.target,
    required this.label,
    required this.line,
    required this.column,
  });

  final LinkKind kind;
  final String target;
  final String? label;

  /// 1-based line number in the source file.
  final int line;

  /// 1-based column.
  final int column;

  @override
  bool operator ==(Object other) =>
      other is NoteLink &&
      other.kind == kind &&
      other.target == target &&
      other.label == label &&
      other.line == line &&
      other.column == column;

  @override
  int get hashCode => Object.hash(kind, target, label, line, column);

  @override
  String toString() => '${kind.name}($target, $label) @$line:$column';
}

final _link = RegExp(r'(!?)\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]');
final _inlineCode = RegExp(r'`[^`]*`');

/// Finds wikilinks and embeds, ignoring fenced code blocks and inline code.
///
/// [firstLine] is the source-file line number of the first line of [body].
List<NoteLink> extractLinks(String body, {int firstLine = 1}) {
  final links = <NoteLink>[];
  final lines = body.split('\n');
  String? fence;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].replaceAll('\r', '');
    final fenceMatch = _fenceOpen.firstMatch(line);
    if (fence == null && fenceMatch != null) {
      fence = fenceMatch.group(1)!;
      continue;
    }
    if (fence != null) {
      if (_closesFence(line, fence)) fence = null;
      continue;
    }

    final masked = line.replaceAllMapped(
      _inlineCode,
      (m) => ' ' * m.group(0)!.length,
    );
    for (final m in _link.allMatches(masked)) {
      links.add(
        NoteLink(
          kind: m.group(1) == '!' ? LinkKind.embed : LinkKind.wikilink,
          target: m.group(2)!.trim(),
          label: m.group(3)?.trim(),
          line: firstLine + i,
          column: m.start + 1,
        ),
      );
    }
  }
  return links;
}

final _fenceOpen = RegExp(r'^\s{0,3}(`{3,})');

bool _closesFence(String line, String fence) {
  final m = RegExp(r'^\s{0,3}(`{3,})\s*$').firstMatch(line);
  return m != null && m.group(1)!.length >= fence.length;
}
