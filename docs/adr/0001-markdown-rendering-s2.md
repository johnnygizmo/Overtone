# ADR 0001: Markdown rendering (spike S2)

Status: accepted

## Decision

Parse with `package:markdown` and render the AST with an in-repo renderer.
Do not use a Flutter markdown widget package.

- Custom inline syntaxes: `[[target|label]]` (wikilink) and `![[file|caption]]` (embed).
  The embed syntax is registered first so it wins over the wikilink at the same position.
- Callouts: a block quote whose first line matches `[!type] Title`.
- Musical blocks: fenced code whose language is in `musicalBlockLanguages`;
  the YAML body is parsed by `parseBlockData` from `overtone_content`, so the
  CLI and the app use the same parser.
- Unknown fence languages render an authoring warning (hidden in release).
  Ordinary code languages render as code.
- Raw HTML is never interpreted: HTML blocks and inline HTML arrive as text
  nodes and are shown literally.
- SVG embeds use `flutter_svg` (not injected into the DOM). Audio embeds are
  a placeholder until the audio engine is wired in.

## Evidence

`spikes/overtone_spikes/lib/s2_markdown.dart` rendered the sample note
(`assets/sample_lesson.md`) in Chrome: headings, emphasis, resolved and
unresolved wikilinks, a callout, a table, an ordered list, four musical
blocks, an unknown block (warning), an SVG embed, an MP3 embed, and
`<script>`/`<b>` as literal text.

## Follow-ups

- Obsidian sizing syntax `![[image.png|300]]` conflicts with the caption alias.
  Rule to adopt: a purely numeric alias is a width in pixels.
- Not yet covered: nested lists, task lists, foldable callouts (`[!note]-`),
  footnotes, heading anchors, long-table scrolling.
- Accessibility: tables and callouts have basic semantics only; review in M3.
