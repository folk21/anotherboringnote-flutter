---
type: Feature Catalog
title: Stable feature IDs
description: Persistent cross-spec capability vocabulary for the Flutter app.
---
# Stable features

Feature IDs are durable uppercase names and must not encode implementation stages or current status.

| Feature ID | Owner | Contract |
|---|---|---|
| `RUNTIME.OFFLINE_FIRST` | architecture / storage | CRUD and reader require no network |
| `NOTES.MANAGEMENT` | notes | list, create, open, duplicate, delete |
| `NOTES.EDITOR` | notes + ui | dedicated plain-text draft editor |
| `STORAGE.PLAIN_TEXT` | notes + native adapter | UTF-8 .txt and versioned index.json |
| `READER.VIEW` | reader + ui | full-window read-only text view |
| `READER.MODES` | reader | Private, Normal, Large, Presentation |
| `READER.ZOOM` | reader | reflow typography, transient zoom |
| `READER.ORIENTATION` | reader + ui | mobile orientation policy/override |
| `READER.APPEARANCE` | reader | preset/custom colors and fonts |
| `SETTINGS.PERSISTENCE` | reader + storage | separate versioned properties |
| `PLATFORM.FLUTTER` | architecture | Dart/Flutter shared UI and logic |
| `PLATFORM.ANDROID` | Flutter host | Android build and integration |
| `PLATFORM.IOS` | Flutter host | iOS build and integration |
| `PLATFORM.DESKTOP` | Flutter host | macOS, Windows, Linux desktop |
| `PLATFORM.WEB_PREVIEW` | web adapter | browser-local visual preview |
| `TESTING.DETERMINISTIC_LOCAL` | test tooling | no network/external services in tests |
| `DEVELOPMENT.AI_STAGE_WORKFLOW` | docs/ai + scripts | MAIN/WORKER, implementation plan and STATE.json |

Preserve product IDs from the KMP source where their semantics remain. Platform IDs change when the platform implementation changes. See the active port spec for unverified parity.
