# ADR 0005: Self-hosting, CSP, and caching (spike S5, partial)

Status: local findings accepted; GitHub Pages verification pending

## Findings (local release build)

1. A default `flutter build web` loads CanvasKit from `www.gstatic.com` and
   Roboto from `fonts.gstatic.com` at runtime. That sends visitors' requests
   to a third party, conflicts with the "private" principle, and breaks a
   strict CSP.
2. `flutter build web --no-web-resources-cdn` self-hosts CanvasKit, and
   bundling Roboto as an asset (declared in `pubspec.yaml`, set as the theme
   font) removes the font request. With both, every request in S2, S3, S4,
   and S6 went to the app's own origin.
3. A `<meta http-equiv="Content-Security-Policy">` tag works with Flutter
   web, the OSMD bundle, and the audio engine (no console errors):

   ```text
   default-src 'self'; script-src 'self' 'wasm-unsafe-eval';
   style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:;
   font-src 'self' data:; connect-src 'self' data: blob:;
   worker-src 'self' blob:; object-src 'none'; base-uri 'self'
   ```

   Header-only directives (`frame-ancestors`, `report-uri`) cannot be set on
   GitHub Pages.
4. Flutter 3.47 registers no service worker (`flutter_service_worker.js` is a
   stub and there were 0 registrations). App staleness is therefore limited
   to normal HTTP caching.

## Decision

- Release builds use `--no-web-resources-cdn` and the bundled font.
- Keep the meta CSP above in the app's `index.html`.
- Content cache-busting stays as planned: fetch `manifest.json` with a
  timestamp, then every other file with `?v=<hash from the manifest>`.
- Record every bundled font and library in `docs/third-party.md`
  (Roboto: Apache-2.0; OSMD: BSD-3-Clause).

## Still to verify on GitHub Pages

See the checklist in MILESTONES.md M1 (S1/S5): response headers
(`cache-control`, `age`), how soon a content-only publish is visible to a
returning browser, and that an app publish is picked up. The spike's S5 page
(`?spike=S5&auto=1`) reports these.
