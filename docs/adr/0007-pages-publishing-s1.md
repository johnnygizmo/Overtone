# ADR 0007: GitHub Pages hosting and publishing (spike S1)

Status: pending verification on GitHub Pages

## Plan being tested

- Site at `https://johnnygizmo.github.io/Overtone/`, built with
  `--base-href /Overtone/ --no-web-resources-cdn`.
- App and `content/` published to the `gh-pages` branch by separate
  workflows, each limited to its own path.
- Hash routing (`/#/...`) so refresh and deep links need no server support.
  Path URLs (`/Overtone/lesson/x`) would return 404 on Pages.

## To verify

1. The spike loads at the Pages URL: app, fonts, scores, OSMD, and audio JS
   resolve under `/Overtone/`.
2. Deep links work and survive refresh: `?spike=S3`, `?spike=S5&auto=1`.
3. A commit that changes only `content/` leaves the app files untouched and
   is visible to the S5 page.
4. A commit that replaces the app files but keeps `content/` leaves the
   content intact.

Record the results here when done.
