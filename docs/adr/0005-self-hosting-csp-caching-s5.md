# ADR 0005: Self-hosting, CSP, and caching (spike S5, partial)

Status: accepted (local findings and GitHub Pages verification both done)

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
- Content is published as immutable `<buildId>/` snapshots plus one small
  mutable `manifest.json` that points at the current snapshot (PLAN.md 4.5).
  Do not use `?v=<hash>` for cache-busting; the Pages CDN ignores it.
- Record every bundled font and library in `docs/third-party.md`
  (Roboto: Apache-2.0; OSMD: BSD-3-Clause).

## GitHub Pages findings (live, `johnnygizmo.github.io/Overtone/`)

- Every response carries `cache-control: max-age=600`, an `etag`, and CDN
  headers (`x-cache: HIT`/`MISS`, `age`).
- The CDN ignores query strings. Fetching `manifest.json?t=<new>` returned
  the same cached object (`age: 64`, then `569`).
- A deploy did not purge the CDN. Timeline (UTC): content-only commit 17:46:14,
  app-only commit 17:46:34, successful Pages deploy finished 17:47:13 (the
  earlier deploy run was cancelled by the later push; the later run contained
  both changes). At 17:48:35 a returning browser still received the old
  manifest (`age: 569`) and the old app. At 17:51:05 every file was fresh
  (`x-cache: MISS`). So an update becomes visible after the old CDN entry
  expires, up to ten minutes after the deploy.
- After the CDN refreshed, the S5 page reported content `v2` (new manifest
  hash, new probe file) and `appBuild: 2`, so both kinds of update arrived.
- Risk: the manifest and a content file can expire at different times, so a
  fresh manifest could be paired with a stale file. Immutable snapshots avoid
  this because every URL under a snapshot is unique.
- No third-party hosts were contacted; no service worker was registered.
