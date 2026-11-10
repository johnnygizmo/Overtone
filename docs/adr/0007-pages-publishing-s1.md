# ADR 0007: GitHub Pages hosting and publishing (spike S1)

Status: accepted

## Plan being tested

- Site at `https://johnnygizmo.github.io/Overtone/`, built with
  `--base-href /Overtone/ --no-web-resources-cdn`.
- App and `content/` published to the `gh-pages` branch by separate
  workflows, each limited to its own path.
- Hash routing (`/#/...`) so refresh and deep links need no server support.
  Path URLs (`/Overtone/lesson/x`) would return 404 on Pages.

## Results

1. Passed. The spike loads at the Pages URL and the app, bundled Roboto,
   scores, OSMD, and audio JS all resolve under `/Overtone/`. S2, S3, S4, S5,
   and S6 pages ran there with no external hosts.
2. Passed. `?spike=...` deep links load and survive refresh. Path URLs such
   as `/Overtone/lesson/x` would 404, so the app uses hash routing.
3. Passed. The content-only commit (`S5 content v2`) changed only
   `content/manifest.json` and `content/probe.txt`.
4. Passed. The app-only commit (`S5 app build 2`) changed only
   `.last_build_id`, `flutter_bootstrap.js`, `js/overtone_notation.js`, and
   `main.dart.js`; `content/` stayed at v2 and the live site served both.

Other findings:

- Pages must be set to deploy from the `gh-pages` branch (root), not `main`
  and not GitHub Actions. A `.nojekyll` file belongs in `gh-pages`.
- A push made while a Pages deploy is running cancels that run; the later run
  deploys the whole branch state, so nothing is lost.
- Updates take up to about ten minutes to reach returning visitors (ADR
  0005), and content must be published as immutable snapshots.
- Each Pages deploy takes about 30 seconds.
