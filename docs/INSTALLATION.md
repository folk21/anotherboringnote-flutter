---
type: Installation Guide
title: Flutter toolchain and platform setup
description: New-repository setup, Intel macOS requirements, generated platform runners, and device-specific first runs.
---
# Install and bootstrap

## Intel MacBook Pro (2020)

1. Confirm `uname -m` prints `x86_64` and check the macOS version (`sw_vers`). Use the **Intel x64** SDK artifact, not the Apple Silicon/ARM64 bundle. Flutter announced a phase-out of Intel Mac development; if current stable no longer supports your host when installing, choose and pin a documented last Intel-compatible stable release instead of changing architecture.
2. Install Git, Xcode Command Line Tools (`xcode-select --install`), and the Intel Flutter SDK: <https://docs.flutter.dev/install/manual>. Add `<flutter-sdk>/bin` to the `PATH` in `~/.zprofile`, then open a fresh terminal.
3. To develop a native macOS app or iOS simulator app, install a version of **full Xcode** compatible with the installed macOS, accept licenses, ensure `xcode-select` points to Xcode, and install CocoaPods when reported as missing by `flutter doctor -v`. For browser-only UI inspection, Chrome and the Flutter SDK are sufficient.
4. For Android emulator/physical phone, install Android Studio + SDK/platform tools. You do not need Android Studio just to run the web preview.

Check:

```bash
uname -m
flutter --version
flutter doctor -v
flutter devices
```

## Create native/web Flutter host scaffolds

This ZIP contains the authored app and tests but **deliberately omits Flutter-generated platform runner templates** (which depend on Flutter release/toolchain). On a machine with Flutter SDK:

```bash
cd anotherboringnote_flutter
bash scripts/bootstrap.sh
```

This invokes `flutter create --project-name anotherboringnote_flutter --org com.peiwae --platforms=android,ios,macos,web,windows,linux .` adds the required macOS file-picker read-only entitlements, then runs `flutter pub get` and `dart format lib test`. Inspect `git status`, native bundle identifiers, permissions, signing and runner configuration, then **commit the generated platform files** to the new repository. The bootstrap is intended for a fresh unzipped project; do not run with `--overwrite` on a modified project.

The default generated app identifiers are development placeholders. Set your own Android application ID and Apple Bundle IDs before distribution. Never add signing secrets to Git.

## Visual UI test — browser (lowest friction)

```bash
flutter devices
flutter run -d chrome
```

Create a note, reopen it, change reader mode/zoom, visit Settings, edit, duplicate and delete it. Browser storage lives in the chosen browser profile. This is a rapid UI smoke check, not proof of native file storage or mobile gesture behavior.

## Visual UI test — native macOS desktop

```bash
flutter config --enable-macos-desktop
flutter devices
ABN_DATA_DIR=abn-flutter-smoke flutter run -d macos
```

Use a **disposable data directory** to avoid accidental changes to historical KMP content. macOS keeps this relative dataset under its app-specific sandboxed Application Support directory. To locate the saved index, run `find "$HOME/Library/Containers" -path "*/AnotherBoringNoteFlutter/abn-flutter-smoke/index.json" -print` and open the adjacent `notes/<id>.txt`. An absolute override such as `/tmp/abn-flutter-smoke` is usually inaccessible from a sandboxed macOS app and can produce `PathAccessException (Operation not permitted)`. Without `ABN_DATA_DIR`, the macOS default is `getApplicationSupportDirectory()/AnotherBoringNoteFlutter/abn-data` (inside the sandbox).

## Visual UI test — Android

Start an Android emulator from Android Studio or connect an Android device with USB debugging enabled, then:

```bash
flutter devices
flutter run -d <android-device-id>
```

Replace the device ID with one printed by `flutter devices`. Confirm rotation, pinch zoom, system Back, editor discard, permissions and virtual keyboard behavior on a device. Native data stays inside app-private storage.

## Visual UI test — iOS Simulator

On macOS with full Xcode, install a Simulator runtime via Xcode and start a simulator:

```bash
open -a Simulator
flutter devices
flutter run -d <ios-simulator-id>
```

If Xcode, CocoaPods, Simulator runtime or device signing is not configured, `flutter doctor -v` identifies missing prerequisites. On Intel Macs, some recent iOS runtimes/Xcode releases may no longer support the host OS: use a mutually compatible toolchain. Physical iOS devices require Apple signing configuration.

## Other operating systems

Run native Windows builds **on Windows** (Visual Studio Desktop development with C++), Linux builds **on Linux** (clang, cmake, ninja and GTK libraries). Example: `flutter run -d windows` or `flutter run -d linux` on the respective host. Web preview is available on all supported Flutter development OSes.

## Problems and troubleshooting

- `flutter: command not found`: the Intel SDK's `bin` is missing from your shell PATH.
- `No supported devices`: configure at least one target (`flutter devices`, Chrome, Xcode or Android emulator).
- macOS/iOS build error: use `flutter doctor -v`; full Xcode is distinct from CLI tools.
- Plugin/package resolution error: confirm internet access for initial `flutter pub get` and SDK/package version compatibility; do not change dependencies speculatively.
- Existing KMP notes not visible: the Flutter data directory is intentionally separate. Follow `docs/USAGE.md` for a backup-first compatibility inspection.

Sources: Flutter install <https://docs.flutter.dev/install/manual>; macOS setup <https://docs.flutter.dev/platform-integration/macos/setup>; platform support <https://docs.flutter.dev/reference/supported-platforms>.
