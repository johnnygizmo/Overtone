# ADR 0006: Content parsing is platform-independent (spike S7)

Status: accepted

## Decision

`overtone_content` parses notes with `package:yaml` and `package:crypto`, both
pure Dart. The CLI (Dart VM) and the app (dart2js or Wasm) share one
implementation.

## Evidence

`packages/overtone_content/test/overtone_content_test.dart` (15 tests) passes
on the VM, in Chrome with dart2js (`dart test -p chrome`), and in Chrome with
dart2wasm (`dart test -p chrome -c dart2wasm`). Covered:

- Frontmatter to plain Dart maps and lists; fence errors; YAML error line
  numbers; empty frontmatter.
- CRLF line endings and a byte-order mark give identical results.
- Wikilinks and embeds with labels, ignoring inline code and fenced code;
  line numbers map back to the source file.
- Musical blocks parsed from YAML; unclosed and non-map bodies rejected.
- `contentHash` matches a known SHA-256 prefix on all three platforms.

## Consequences

- The M2 build pipeline can be written once and tested on the VM.
- Add a CI job that runs `dart test -p chrome` for this package.
