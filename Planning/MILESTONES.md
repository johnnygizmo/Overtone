# MILESTONES.md

Ordered work for **Overtone**. Architecture and decisions are in
[PLAN.md](PLAN.md); product scope is in [PROJECT.md](PROJECT.md).

Each milestone has a goal, tasks, and acceptance criteria. A milestone is done
only when every acceptance criterion is demonstrably true. Milestones
correspond to the phases in PROJECT.md section 16 (noted in each heading).

Conventions:

- `[ ]` open, `[x]` done.
- Spike IDs (S1 to S7) are defined in PLAN.md section 14.
- Each spike ends with a short decision record in `docs/adr/`.

------------------------------------------------------------------------

## M0. Repository and toolchain

**Goal:** an empty but correctly structured repository that builds, tests,
and runs in CI.

Tasks:

- [x] Confirm the GitHub repository (`johnnygizmo/Overtone`) and keep the
      GPL-3.0 code license already in `LICENSE`.
- [x] Create the Dart workspace root `pubspec.yaml` with members
      `apps/overtone_web`, `packages/*`, `tools/overtone_cli`.
- [x] Scaffold `music_domain`, `overtone_content`, `exercise_engine`,
      `learner_model` as pure Dart packages with a placeholder test each.
- [x] Scaffold `overtone_web` with `flutter create` (web only) and add
      Riverpod and `go_router`.
- [x] Scaffold `overtone_cli` with a `content` command group and `--help`.
- [x] Add `analysis_options.yaml` shared by all members.
- [x] Add `README.md`, `LICENSE`, `CONTRIBUTING.md` (content under CC BY-SA),
      `docs/adr/`.
- [x] Add `ci.yaml`: pub get, format check, analyze, tests, web build.

Acceptance:

- [x] A fresh clone runs `dart pub get`, `dart analyze`, and the tests with no
  manual steps. (Verified locally; CI not yet run.)
- [ ] CI is green on a pull request.
- [x] Package dependency directions match PLAN.md section 2.1 (checked by
  `tools/check_deps.dart`, run in CI).

------------------------------------------------------------------------

## M1. Technical spikes (Phase 0)

**Goal:** answer the highest-risk questions before building on them.

Tasks:

- [ ] **S1** Publish a minimal Flutter web build to `gh-pages` under
      `/Overtone/`; test deep link and refresh with hash routing.
      (Build ready in `spikes/overtone_spikes/build/pages`; waiting for the
      push. Checklist in ADR 0007.)
- [ ] **S1** Prove two path-scoped publishes (`app` and `content/`) coexist
      without overwriting each other.
- [x] **S2** Prototype markdown rendering with wikilinks, callouts, embeds,
      and the four musical block types. (ADR 0001)
- [x] **S3** Render representative scores with OSMD (bundled,
      `HtmlElementView`); test note click and resize. Done with five
      hand-written MusicXML scores (ADR 0002).
- [ ] **S3** Re-test with real MuseScore Studio exports (5 to 8 scores).
- [x] **S4** Build the Web Audio engine prototype: unlock, play a note,
      interval, triad; replace playback cleanly; measure timing. Offline
      checks pass (ADR 0003).
- [ ] **S4** Listen on desktop Chrome, Firefox, Edge and Android Chrome;
      confirm the autoplay gesture behaviour and timbre.
- [x] **S5** (local) Meta CSP and self-hosting verified; no service worker
      (ADR 0005).
- [ ] **S5** Verify content-only and app-only updates reach a returning
      browser on GitHub Pages.
- [x] **S6** Benchmark `sembast_web` including export and import
      (ADR 0004).
- [x] **S7** Confirm `overtone_content` parsing behaves the same on the VM,
      dart2js, and dart2wasm (ADR 0006).
- [x] Write one ADR per spike with the decision (S1 and S5 hold pending
      items).

Acceptance:

- Each spike has a written decision and its prototype code or notes are kept
  under `docs/adr/` or `spikes/`.
- Notation renderer, audio engine approach, storage library, and renderer
  for Markdown are each confirmed or replaced, with PLAN.md updated to match.

------------------------------------------------------------------------

## M2. Content engine (Phase 1)

**Goal:** add and publish a text-based lesson without recompiling the app.

Tasks:

`overtone_content` and CLI:

- [ ] Frontmatter parser and typed models for each note type (PLAN.md 4.3).
- [ ] Vault scanner with allowlist and ignore rules.
- [ ] Filename/ID, uniqueness, folder-note, and hierarchy-mismatch checks.
- [ ] Wikilink, embed, and block extraction; `BlockSpec` registry.
- [ ] Reference checks: prerequisites, exercises, flashcards, skills,
      related topics.
- [ ] Asset checks and path-traversal protection.
- [ ] Diagnostics with stable codes, suggestions, and `docs/diagnostics.md`.
- [ ] `build` command: manifest, `nodes.json`, `graph.json`, `search.json`,
      `media.json`, per-file content hashes.
- [ ] `new` command and Obsidian templates in `content/_templates/`.
- [ ] Fixture vaults: one valid, plus one invalid vault per diagnostic code.

App:

- [ ] App shell, navigation, and responsive layout (phone, tablet, desktop).
- [ ] `ContentSource` over HTTP with cache-busting.
- [ ] Manifest, nodes, and graph providers; schema version check.
- [ ] Subject browser and lesson page; markdown renderer with wikilinks,
      callouts, and image/SVG/MP3 embeds.
- [ ] Graceful per-item error display for bad or unsupported content.

Deployment:

- [ ] `deploy-app.yaml` and `deploy-content.yaml` (PLAN.md 11.2).
- [ ] `ci.yaml` runs `overtone content validate --strict`.

Acceptance:

- Adding a new `lesson` note and running the content workflow makes it
  appear on the live site, with no Flutter build.
- A deliberately invalid note fails CI with a message that names the file,
  line, and a suggested fix.
- A note with an unsupported schema version or a broken embed shows an error
  for that item while the rest of the site works.
- Unit tests cover every diagnostic code.

------------------------------------------------------------------------

## M3. Music domain and rendering (Phase 2)

**Goal:** a lesson with prose, notation, diagrams, and playable examples.

Tasks:

`music_domain`:

- [ ] `Letter`, `Accidental`, `PitchClass`, `Pitch` with enharmonic handling.
- [ ] `Interval`: number, quality, semitones, direction, compound, inversion.
- [ ] Pitch plus interval and interval between two pitches.
- [ ] `ChordType` and `Chord` for triads, inversions, and voicings.
- [ ] `ChordTypeRegistry` and `IntervalTypeRegistry` loaded from `reference`
      notes.
- [ ] `Key` for major and natural minor.
- [ ] `Duration`, `Tempo`, and `PlaybackEvent` generation.
- [ ] Extensive unit tests (spelling, enharmonics, all interval qualities).

Rendering:

- [ ] `NotationView` and `NotationController` with the chosen renderer.
- [ ] `chord`, `keyboard`, `fretboard`, `notation` block widgets.
- [ ] `KeyboardWidget` and `FretboardWidget` driven by `instrument` notes.
- [ ] Accessible text alternatives for every block.

Audio:

- [ ] `SoundSource` interface and Web Audio implementation from S4.
- [ ] `Scheduler`: events to scheduled notes.
- [ ] Audio player embed for MP3 files.
- [ ] Volume and mute controls; unlock-on-gesture state.

Acceptance:

- A sample lesson in the vault shows a rendered score from MusicXML, a
  keyboard diagram, a fretboard diagram, an MP3 embed, and a "play this
  chord" control that sounds correct pitches.
- Playing a second example stops the first without clicks.
- Screen reader labels and keyboard navigation work on the sample lesson.
- Domain test suite passes and covers the cases listed in PROJECT.md
  section 15.

------------------------------------------------------------------------

## M4. Exercise runtime (Phase 3)

**Goal:** complete practice sessions driven by exercise-set notes.

Tasks:

- [ ] `ExerciseType` interface, `ExerciseRegistry`, `ExerciseSession` state
      machine.
- [ ] `exercise-presets` reference note and preset resolution.
- [ ] Exercise type `identify-interval`.
- [ ] Exercise type `identify-triad-quality`.
- [ ] Exercise type `identify-note-on-staff`.
- [ ] Exercise type `construct-triad`.
- [ ] Exercise type `compare-interval-presentation`.
- [ ] CLI validation calls each type's `parseSettings`.
- [ ] Practice launcher and session screens: prompt, replay, answer targets,
      immediate feedback, optional explanation, session summary.
- [ ] Flashcard session for `flashcard-set` notes.
- [ ] Deterministic seeds, stored per attempt.
- [ ] Skill evidence emitted per attempt.

Acceptance:

- Each of the five exercise types runs a full session from a note in the
  vault.
- Changing a setting in a note (for example, the interval list) changes the
  generated questions after a content publish, with no app rebuild.
- With a fixed seed, generation and evaluation are reproducible in tests.
- Invalid settings in a note are reported by the CLI.
- Replay, hint, and response time are recorded.
- Practice screens contain no support links or ads.

------------------------------------------------------------------------

## M5. Learner model and persistence (Phase 4)

**Goal:** the app can suggest useful practice from real performance, and
progress is portable.

Tasks:

- [ ] `AttemptStore` interface and `sembast_web` implementation.
- [ ] Append attempts and lesson progress after each session.
- [ ] Storage schema version and migration runner with fixture tests.
- [ ] Estimator (PLAN.md 9.4) with a single config object.
- [ ] Recommendation rules (PLAN.md 9.5) with human-readable reasons.
- [ ] First-run level selection that seeds starting suggestions.
- [ ] Home dashboard: continue, suggestion, quick practice.
- [ ] Progress screen: skills with provisional versus established status.
- [ ] Export to a versioned JSON file; import with replace or merge.
- [ ] Export reminder banner (never during practice).
- [ ] "Erase all progress" with confirmation.
- [ ] Request persistent browser storage and show backup guidance.

Acceptance:

- After a session with repeated misses on one skill, the home screen
  recommends an exercise set and a lesson for that skill, with a reason.
- A skill is not marked established with fewer attempts or variants than the
  configured minimums.
- Export, clear data, and import restores the same estimates and history.
- An export file from an older format version imports through a migration
  (tested with fixtures).
- Clearing site data and reloading starts a clean profile without errors.

------------------------------------------------------------------------

## M6. MVP content and polish (Phase 5, MVP slice)

**Goal:** the intervals and triads path from PROJECT.md section 17.

Tasks:

Lessons:

- [ ] Pitch and note names.
- [ ] Semitones and whole tones.
- [ ] Intervals.
- [ ] Major and minor thirds.
- [ ] Perfect fifths.
- [ ] Constructing major and minor triads.
- [ ] Diminished triads.

Practice:

- [ ] Interval identification by ear.
- [ ] Harmonic versus melodic comparison.
- [ ] Triad quality by ear (major, minor, diminished).
- [ ] Notes in a written triad.
- [ ] Construct a triad from root and formula.
- [ ] Flashcards for terms and chord formulas.

Supporting content:

- [ ] Skill notes for every referenced skill.
- [ ] `interval-types`, `chord-types`, `glossary`, and `exercise-presets`
      reference notes.
- [ ] `piano` and `guitar` instrument notes.
- [ ] MusicXML scores, diagrams, and audio examples with licenses recorded.

Quality:

- [ ] Accessibility review against PLAN.md 6.4.
- [ ] Manual device pass (desktop Chrome, Firefox, Edge; Android Chrome).
- [ ] Unsupported-browser notice for Safari and iOS.
- [ ] Prerequisite links and related topics populated.

Acceptance:

- A new learner can pick a level, read a lesson, hear and see its examples,
  run related practice, and see a recommendation based on results.
- All content passes `validate --strict` with no warnings.
- Every lesson links to at least one exercise set and one skill.
- No lesson page or practice screen fails accessibility checks in the
  manual checklist.

------------------------------------------------------------------------

## M7. Public release (Phase 6)

**Goal:** a public, free web app with a maintainable content pipeline.

Tasks:

- [ ] Finalize `--base-href` and, if used, a custom domain.
- [ ] About page with licenses and attributions generated from
      `docs/third-party.md`.
- [ ] Patreon link in footer and About (not during practice).
- [ ] Privacy statement: what is stored, where, how to export and erase.
- [ ] Error boundary and a user-readable error screen for fatal failures.
- [ ] Authoring guide: vault conventions, templates, commands, diagnostics.
- [ ] Contributor guide for content pull requests.
- [ ] Final license and third-party audit.
- [ ] Release checklist and version tagging.

Acceptance:

- The public URL works on direct link and refresh.
- A content-only pull request goes from merge to live without touching
  the app build.
- A contributor can add a lesson following the authoring guide alone.
- Every bundled asset has a recorded source and license.

------------------------------------------------------------------------

## M8. After the MVP (backlog, unordered)

- Rhythm exercises and rhythm notation interaction.
- Progression and cadence recognition; Roman numeral analysis.
- Seventh chords, extensions, modes, and scale exercises.
- Interactive notation (tap, fill-in, construct).
- Guitar-like timbre and sampled instruments.
- MIDI keyboard input (Web MIDI).
- Math rendering.
- Analytics decision (privacy-preserving only).
- Advertising review (AdSense eligibility, placement, consent).
- Safari and iOS support.
- Native Android and iOS builds.
- Content authoring tool with preview.
- Optional cloud sync and accounts.
