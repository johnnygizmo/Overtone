// Spike S2: Markdown AST rendering with wikilinks, callouts, embeds, and
// musical blocks. Raw HTML is never interpreted; it renders as plain text.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:overtone_content/overtone_content.dart';

class WikilinkSyntax extends md.InlineSyntax {
  WikilinkSyntax() : super(r'\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final target = match[1]!.trim();
    final label = (match[2] ?? target).trim();
    parser.addNode(
      md.Element.text('wikilink', label)..attributes['target'] = target,
    );
    return true;
  }
}

class EmbedSyntax extends md.InlineSyntax {
  EmbedSyntax() : super(r'!\[\[([^\]|]+)(?:\|([^\]]*))?\]\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final target = match[1]!.trim();
    parser.addNode(
      md.Element.text('embed', match[2]?.trim() ?? target)
        ..attributes['target'] = target,
    );
    return true;
  }
}

List<md.Node> parseMarkdown(String body) {
  final doc = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [EmbedSyntax(), WikilinkSyntax()],
    encodeHtml: false,
  );
  return doc.parseLines(body.split('\n'));
}

class MarkdownView extends StatelessWidget {
  const MarkdownView({
    super.key,
    required this.body,
    required this.knownNotes,
    this.mediaRoot = 'assets/media/',
    this.showAuthoringWarnings = true,
  });

  final String body;

  /// id -> title for wikilink resolution.
  final Map<String, String> knownNotes;
  final String mediaRoot;
  final bool showAuthoringWarnings;

  @override
  Widget build(BuildContext context) {
    final nodes = parseMarkdown(body);
    final r = _Renderer(
      context: context,
      knownNotes: knownNotes,
      mediaRoot: mediaRoot,
      showWarnings: showAuthoringWarnings,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: r.blocks(nodes),
    );
  }
}

class _Renderer {
  _Renderer({
    required this.context,
    required this.knownNotes,
    required this.mediaRoot,
    required this.showWarnings,
  });

  final BuildContext context;
  final Map<String, String> knownNotes;
  final String mediaRoot;
  final bool showWarnings;

  TextTheme get _text => Theme.of(context).textTheme;

  List<Widget> blocks(List<md.Node> nodes) => [
    for (final n in nodes)
      if (n is md.Element)
        _block(n)
      else if (n is md.Text)
        // Raw HTML blocks arrive as text; show them literally.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(n.text),
        ),
  ];

  Widget _block(md.Element e) {
    switch (e.tag) {
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        final style = switch (e.tag) {
          'h1' => _text.headlineMedium,
          'h2' => _text.headlineSmall,
          'h3' => _text.titleLarge,
          _ => _text.titleMedium,
        };
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Semantics(
            header: true,
            child: Text.rich(_inline(e.children ?? [], style)),
          ),
        );
      case 'p':
        final kids = e.children ?? [];
        if (kids.length == 1 && kids.first is md.Element) {
          final only = kids.first as md.Element;
          if (only.tag == 'embed') return _embed(only);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text.rich(_inline(kids, _text.bodyLarge)),
        );
      case 'blockquote':
        return _blockquote(e);
      case 'ul' || 'ol':
        return _list(e);
      case 'table':
        return _table(e);
      case 'pre':
        return _pre(e);
      case 'hr':
        return const Divider();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: blocks(e.children ?? []),
        );
    }
  }

  InlineSpan _inline(List<md.Node> nodes, TextStyle? style) => TextSpan(
    style: style,
    children: [for (final n in nodes) _inlineNode(n, style)],
  );

  InlineSpan _inlineNode(md.Node n, TextStyle? style) {
    if (n is md.Text) return TextSpan(text: n.text);
    final e = n as md.Element;
    switch (e.tag) {
      case 'strong':
        return TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            for (final c in e.children ?? <md.Node>[]) _inlineNode(c, style),
          ],
        );
      case 'em':
        return TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: [
            for (final c in e.children ?? <md.Node>[]) _inlineNode(c, style),
          ],
        );
      case 'code':
        return TextSpan(
          text: e.textContent,
          style: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Color(0x14000000),
          ),
        );
      case 'a':
        return TextSpan(
          text: e.textContent,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        );
      case 'wikilink':
        final target = e.attributes['target']!;
        final ok = knownNotes.containsKey(target);
        return TextSpan(
          text: e.textContent,
          style: TextStyle(
            color: ok
                ? Theme.of(context).colorScheme.primary
                : Colors.red.shade700,
            decoration: ok
                ? TextDecoration.underline
                : TextDecoration.lineThrough,
          ),
        );
      case 'embed':
        return WidgetSpan(child: _embed(e));
      case 'br':
        return const TextSpan(text: '\n');
      default:
        return TextSpan(
          children: [
            for (final c in e.children ?? <md.Node>[]) _inlineNode(c, style),
          ],
        );
    }
  }

  Widget _blockquote(md.Element e) {
    final first = e.children?.firstOrNull;
    if (first is md.Element && first.tag == 'p') {
      final firstText = first.children?.firstOrNull;
      final m = firstText is md.Text
          ? RegExp(r'^\[!(\w+)\][ \t]*([^\n]*)\n?([\s\S]*)$')
                .firstMatch(firstText.text)
          : null;
      if (m != null) return _callout(e, first, m);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(width: 3, color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks(e.children ?? []),
      ),
    );
  }

  Widget _callout(md.Element quote, md.Element firstPara, RegExpMatch m) {
    final type = m.group(1)!;
    final title = m.group(2)!.isEmpty
        ? type[0].toUpperCase() + type.substring(1)
        : m.group(2)!;
    final rest = m.group(3)!;
    final remaining = <md.Node>[
      if (rest.isNotEmpty || (firstPara.children?.length ?? 0) > 1)
        md.Element('p', [
          if (rest.isNotEmpty) md.Text(rest),
          ...?firstPara.children?.skip(1),
        ]),
      ...?quote.children?.skip(1),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        border: Border(left: BorderSide(width: 4, color: scheme.primary)),
      ),
      child: Semantics(
        container: true,
        label: '$type callout: $title',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ...blocks(remaining),
          ],
        ),
      ),
    );
  }

  Widget _list(md.Element e) {
    final ordered = e.tag == 'ol';
    var i = 0;
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final li in e.children ?? <md.Node>[])
            if (li is md.Element)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(ordered ? '${++i}.' : '\u2022'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _liChildren(li),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  List<Widget> _liChildren(md.Element li) {
    final kids = li.children ?? <md.Node>[];
    // Tight lists put inline nodes directly in the item.
    if (kids.isNotEmpty &&
        kids.every(
          (k) => k is md.Text || (k is md.Element && !_isBlock(k.tag)),
        )) {
      return [Text.rich(_inline(kids, _text.bodyLarge))];
    }
    return blocks(kids);
  }

  bool _isBlock(String tag) => const {
    'p',
    'ul',
    'ol',
    'pre',
    'blockquote',
    'table',
    'h1',
    'h2',
    'h3',
    'hr',
  }.contains(tag);

  Widget _table(md.Element e) {
    final rows = <TableRow>[];
    void collect(md.Element section, {required bool head}) {
      for (final tr
          in section.children?.whereType<md.Element>() ?? <md.Element>[]) {
        rows.add(
          TableRow(
            decoration: head ? BoxDecoration(color: Colors.black12) : null,
            children: [
              for (final cell
                  in tr.children?.whereType<md.Element>() ?? <md.Element>[])
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text.rich(
                    _inline(
                      cell.children ?? [],
                      head
                          ? _text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                          : _text.bodyLarge,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    }

    for (final section
        in e.children?.whereType<md.Element>() ?? <md.Element>[]) {
      collect(section, head: section.tag == 'thead');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Table(
        border: TableBorder.all(color: Colors.black26),
        children: rows,
      ),
    );
  }

  Widget _pre(md.Element e) {
    final code = e.children?.firstOrNull;
    if (code is! md.Element) return const SizedBox.shrink();
    final cls = code.attributes['class'] ?? '';
    final language = cls.startsWith('language-') ? cls.substring(9) : '';
    final text = code.textContent.trimRight();

    if (musicalBlockLanguages.contains(language)) {
      try {
        return _MusicalBlockCard(
          language: language,
          data: parseBlockData(language, text, 0),
        );
      } on BlockException catch (ex) {
        return _warning('Invalid "$language" block: ${ex.message}');
      }
    }
    // A tag we do not know. Only odd single-word tags are treated as authoring
    // mistakes; ordinary code languages render as code.
    const codeLanguages = {
      '',
      'dart',
      'json',
      'yaml',
      'text',
      'markdown',
      'sh',
      'js',
    };
    if (!codeLanguages.contains(language)) {
      return _warning('Unknown block type "$language"');
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      color: Colors.black12,
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }

  Widget _warning(String message) {
    if (!showWarnings) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          const Icon(Icons.warning_amber),
          const SizedBox(width: 8),
          Expanded(child: Text('Authoring warning: $message')),
        ],
      ),
    );
  }

  Widget _embed(md.Element e) {
    final target = e.attributes['target']!;
    final caption = e.textContent == target ? null : e.textContent;
    final ext = target.contains('.')
        ? target.split('.').last.toLowerCase()
        : '';
    final path = '$mediaRoot$target';

    Widget body;
    switch (ext) {
      case 'svg':
        body = SvgPicture.asset(
          path,
          semanticsLabel: caption ?? target,
          placeholderBuilder: (_) => const CircularProgressIndicator(),
        );
      case 'png' || 'jpg' || 'jpeg' || 'webp':
        body = Image.asset(
          path,
          semanticLabel: caption ?? target,
          errorBuilder: (_, _, _) => _warning('Missing image "$target"'),
        );
      case 'mp3':
        body = _AudioPlaceholder(name: target, caption: caption);
      default:
        return _warning('Unsupported embed "$target"');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: body,
    );
  }
}

class _MusicalBlockCard extends StatelessWidget {
  const _MusicalBlockCard({required this.language, required this.data});

  final String language;
  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Semantics(
        container: true,
        label:
            '$language block: ${data.entries.map((e) => '${e.key} ${e.value}').join(', ')}',
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$language block (stub)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final e in data.entries) Text('${e.key}: ${e.value}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioPlaceholder extends StatelessWidget {
  const _AudioPlaceholder({required this.name, this.caption});

  final String name;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle),
        title: Text(caption ?? 'Audio: $name'),
        subtitle: const Text('Audio player (placeholder for the S4 engine)'),
        onTap: () => SystemSound.play(SystemSoundType.click),
      ),
    );
  }
}

/// Convenience for the spike page: loads and renders the sample note.
Future<ParsedNote> loadSample() async {
  final text = await rootBundle.loadString('assets/sample_lesson.md');
  return parseNote(text);
}

bool get kShowAuthoringWarningsDefault => !kReleaseMode;
