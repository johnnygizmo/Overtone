# ADR 0002: Notation renderer (spike S3)

Status: accepted for the MVP, subject to real MuseScore exports (see follow-ups)

## Decision

Use OpenSheetMusicDisplay (OSMD) 2.3.0, bundled locally, hosted in an
`HtmlElementView`, behind the `NotationController` API in
`spikes/overtone_spikes/lib/s3_notation.dart` (load, highlight, clear,
onNoteTapped, notes, dispose). Verovio stays as the documented fallback; it
was not evaluated because OSMD met the criteria.

- License: BSD-3-Clause (compatible with the project's GPL-3.0). Keep its
  LICENSE file next to the bundle and list it in `docs/third-party.md`.
- Size: 1.46 MB minified. Load it lazily, only on pages that contain a
  `notation` block.
- Integration: a thin JS module (`overtone_notation.js`) owns OSMD; Dart only
  calls that API. A `ResizeObserver` re-renders after layout changes and
  re-applies highlights.

## Evidence

Five hand-written MusicXML scores (`web/scores/`) all loaded and rendered:
a chord and arpeggio, bass clef with key signature, 3/4 with ties and a
natural accidental and rests, a grand staff with two voices and chord symbols
(C, G7), and dyads with triplets. Results:

- Note identification: every note got the correct name and MIDI number.
- Click: tapping the middle notehead of a three-note chord reported E4
  (MIDI 64) and the right measure/entry; chord noteheads are individually
  addressable.
- Highlight: coloured one notehead of a chord; the colour survived a resize
  that reflowed the score onto two lines.
- Flutter: inside `HtmlElementView` the tap updated Flutter state, highlighted
  the note, and played it through the S4 audio engine.
- No console errors under the meta CSP (ADR 0005).

## Risks and follow-ups

- The wrapper depends on OSMD internals (`GraphicSheet`, `getSVGGElement`,
  `AccidentalEnum` values). Pin the OSMD version and keep a regression test
  that loads the sample scores and checks note names.
- The scores were written by hand. Export real scores from MuseScore Studio
  and re-run the check before M3 (lyrics, tablature, multi-part scores,
  ornaments, and playback cursor sync are untested).
- Chord note ordering relies on VexFlow drawing noteheads bottom to top.
