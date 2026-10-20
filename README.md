---
type: Project Overview
title: Another Boring Note Flutter
description: Separate Flutter/Dart implementation of the offline-first notes and reader product, with stage-gated AI-assisted development.
---
# Another Boring Note — Flutter

**A new standalone repository**, not a Kotlin Multiplatform module and not an overlay patch to the original repository.

Flutter/Dart port of the original Another Boring Note KMP application. The product remains an intentionally minimal, offline-first, title-less plain-text notes app with a dedicated read-only reader. Flutter replaces Compose and JVM/Android hosts; there is no Kotlin shared layer or backend.

## Implemented in source (acceptance pending)

- Note list with two-line previews and updated-first ordering; create, open, edit, duplicate, and delete.
- Explicit save/discard and destructive confirmation on empty existing-note save.
- Full-window read-only Reader with Private, Normal, Large, and Presentation modes, font size reflow zoom, colors, presets and local imported TTF/OTF.
- Reader preferences in the version-1 KMP-compatible `reader.properties` format.
- Desktop/mobile native local storage using UTF-8 `notes/<id>.txt` and versioned `index.json`; web local storage for fast visual checks.
- App-level navigation, Help, keyboard shortcuts, mobile orientation request policy and zoom controls.

**Status:** Dart/Flutter compilation and interactive platform checks have **not** been run in the packaging environment. Source-level readiness is not equivalent to an accepted cross-platform port. Track outstanding acceptance in [the active spec state](docs/specs/active/subspecs/flutter-port-parity/STATE.json).

## First run on an Intel MacBook Pro (2020)

Install the **Intel x64** Flutter SDK, Xcode command-line tools and, for native macOS/iOS, full Xcode. See [docs/INSTALLATION.md](docs/INSTALLATION.md). Then in the unzipped project directory:

```bash
flutter doctor -v
bash scripts/bootstrap.sh
flutter run -d macos
```

For the fastest UI preview without the full Xcode setup (Chrome required):

```bash
bash scripts/bootstrap.sh
flutter run -d chrome
```

`bootstrap.sh` generates standard Flutter native/web runner directories **inside this repository** using `flutter create`; these are intentionally not supplied as hand-authored files. After bootstrap, review and commit the generated platform directories to your new GitHub repository (for example, `git init -b main`, `git add .`, `git commit -m "feat: initialize Flutter app"`). This keeps the new repo independently buildable. Flutter supports Intel macOS at the time of this draft but plans to deprecate it in future SDK versions; pin an x64-compatible Flutter version before upgrading on the Intel machine.

## Platforms and native data

- macOS desktop: `flutter run -d macos`; native `.txt` storage under the sandbox-scoped `getApplicationSupportDirectory()/AnotherBoringNoteFlutter/abn-data` by default.
- Android: `flutter run -d <android-device-id>`; app-private `.txt` storage.
- iOS Simulator: `flutter run -d <simulator-id>`; app-private `.txt` storage; requires macOS + Xcode.
- Web: `flutter run -d chrome`; persistent browser storage, **not** `.txt` files on disk.
- Windows/Linux: supported Flutter target scaffolds; **build and run on their respective OS** rather than cross-compiling native desktop runners on macOS.

`ABN_DATA_DIR=abn-flutter-smoke flutter run -d macos` isolates test data **inside the macOS App Sandbox container**. On macOS, do not point `ABN_DATA_DIR` at `/tmp` or an arbitrary `$HOME` directory; the sandbox normally denies writes outside its container. Never point this at valuable existing KMP data without first making a backup. The on-disk formats are compatible by design, but there is no tested automated migration.

## Validation

```bash
python3 scripts/spec_state.py validate
bash scripts/run_checks.sh
```

The check script runs `flutter pub get`, a non-mutating `dart format` check, `flutter analyze`, and `flutter test`. Bootstrap formats the source once to satisfy this gate. Native/mobile manual verification is described in [docs/TESTS.md](docs/TESTS.md).

## Architecture and AI development

- [Architecture](docs/ARCHITECTURE.md), [porting matrix](docs/PORTING_MATRIX.md), [implementation](docs/IMPLEMENTATION.md), [features](docs/FEATURES.md), [roadmap](docs/ROADMAP.md).
- [Installation](docs/INSTALLATION.md), [usage](docs/USAGE.md), [testing](docs/TESTS.md).
- [Spec lifecycle](docs/specs/README.md), [AI model/worker workflow](docs/ai/WORKFLOW.md), [implementation template](docs/ai/IMPLEMENTATION_TEMPLATE.md), [state schema](docs/ai/STATE_SCHEMA.md), [active implementation plan](docs/specs/active/subspecs/flutter-port-parity/implementation.md) and [machine-readable state](docs/specs/active/subspecs/flutter-port-parity/STATE.json).

The **MAIN model** (e.g., ChatGPT) owns intent, specification, stage-specific `implementation.md`, acceptance, and `STATE.json`. An **Aider WORKER** implements a single approved bounded stage in a dedicated Git branch. Worker output is not self-accepting. Human review and actual validation remain mandatory. See `AGENTS.md` before changing this repository.
