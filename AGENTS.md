# Repository Guidelines

## Project Structure & Module Organization

OpenMusic follows Clean Architecture. `lib/main.dart` is the entry point; shared routing, dependency injection, services, themes, and utilities live in `lib/core/`. Feature code is divided into `lib/layers/data/` (Drift, data sources, DTOs, mappers, and implementations), `lib/layers/domain/` (entities, contracts, services, and use cases), and `lib/layers/presentation/` (BLoCs/Cubits, screens, and widgets). Keep dependencies flowing through domain abstractions.

Tests are in `test/`, with fakes in `test/support/`. Images and English/Russian translations live under `assets/`. Platform projects use the standard Flutter directories.

## Build, Test, and Development Commands

- `flutter pub get` installs locked dependencies.
- `flutter run` starts the app on a connected device or emulator.
- `flutter analyze` applies `flutter_lints` and project analyzer rules.
- `dart format lib test` formats Dart source and tests.
- `flutter test` runs the complete automated suite; use `flutter test test/lrc_parser_test.dart` for one file.
- `dart run build_runner build --delete-conflicting-outputs` regenerates Drift code after schema changes.
- `flutter build apk` builds an Android release artifact.

## Coding Style & Naming Conventions

Use two-space indentation and formatter output. Follow `analysis_options.yaml`, including `prefer_const_*`. Name files and directories `snake_case`, types `UpperCamelCase`, and variables or methods `lowerCamelCase`. Tests end in `_test.dart`. Inject dependencies through `lib/core/di/`, keep business rules in domain services/use cases, and do not hand-edit generated `*.g.dart` files.

## Testing Guidelines

The suite uses `flutter_test` for unit and widget tests. Add focused regression tests, using fakes instead of live network, audio, or filesystem dependencies. There is no enforced coverage threshold; protect affected paths and edge cases. For playback or platform changes, also run relevant scenarios in `TESTING.md`.

## Commit & Pull Request Guidelines

History favors short lowercase subjects such as `wave fix` and `moodmap`. Keep commits focused, but clarify action and scope: `fix player session restore`. Pull requests should explain the change, list validation, link issues, and include screenshots or recordings for UI work. Call out migrations, generated files, platform behavior, and new `--dart-define` requirements.

## Security & Configuration

Never commit `.env`, tokens, Spotify credentials, or Sentry DSNs. Supply secrets through local configuration or documented `--dart-define` values. Review telemetry and network changes for accidental PII collection.

## Test quality requirements

Tests must verify real observable behavior, not merely make the suite pass.

For every significant new or changed behavior:

* Add or update tests that would fail for at least one plausible incorrect implementation.
* For bug fixes, prefer a regression test that fails before the fix and passes after it.
* Do not weaken existing assertions just to make tests pass.
* Do not delete, skip, disable, or relax existing tests unless the requirement itself changed.
* Avoid weak assertions such as only checking `isNotNull`, `isA<T>()`, `findsOneWidget`, or that no exception was thrown. Assert meaningful values, state transitions, UI output, side effects, or dependency interactions.
* Prefer testing observable behavior over private implementation details.
* Do not copy production logic into the test to calculate the expected result. Expected values should come from requirements, fixtures, explicit constants, or independently derived rules.
* Cover relevant happy paths, error paths, boundary cases, empty states, invalid input, and state transitions.
* For Flutter widget tests, verify the effect of user actions, not only that widgets exist.
* When intermediate UI states matter, prefer explicit `pump()` calls over blindly using `pumpAndSettle()`.

Before considering a test complete, answer:

> What realistic broken implementation would this test catch?

If no plausible bug can be identified, strengthen the test.

For important behavior, mentally or temporarily test against plausible mutants such as:

* returning a constant value;
* reversing a boolean condition;
* changing `>` to `>=`;
* skipping validation;
* swallowing an exception;
* skipping a state transition;
* returning stale or incomplete data;
* performing an operation zero or two times instead of once.

A strong test should fail for at least one such broken implementation.

After changes, run:

```bash
dart format .
flutter analyze
flutter test
```

Never claim tests passed unless they were actually executed successfully.
