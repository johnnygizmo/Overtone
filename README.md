# Overtone

More than the notes.

An open music learning platform: theory, ear training, rhythm, and instrument
knowledge, with progress stored privately in your own browser.

- Product scope: [Planning/PROJECT.md](Planning/PROJECT.md)
- Architecture: [Planning/PLAN.md](Planning/PLAN.md)
- Work breakdown: [Planning/MILESTONES.md](Planning/MILESTONES.md)

## Repository layout

| Path | Contents |
|---|---|
| `apps/overtone_web` | Flutter web app |
| `packages/music_domain` | Pure Dart music theory model |
| `packages/overtone_content` | Content vault parsing, validation, index building |
| `packages/exercise_engine` | Exercise types, generation, evaluation |
| `packages/learner_model` | Attempts, mastery, recommendations |
| `tools/overtone_cli` | The `overtone` command (`content validate`, `build`, `new`) |
| `content/` | Obsidian vault of lessons and exercises (added in M2) |

## Development

Requires Flutter (stable) with Dart 3.13 or newer.

```sh
flutter pub get                                # resolves the whole workspace
flutter analyze
dart run tools/check_deps.dart                 # package dependency directions
cd packages/music_domain && dart test          # repeat per package
cd apps/overtone_web && flutter test
cd apps/overtone_web && flutter run -d chrome
dart run tools/overtone_cli/bin/overtone.dart content --help
```

## Licenses

- Code: GPL-3.0 (see [LICENSE](LICENSE)).
- Lesson content: CC BY-SA.
