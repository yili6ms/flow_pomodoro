<div align="center">

# 🌅 Flow Pomodoro

**A focus app designed to help you enter and stay in flow state.**

Pomodoro timer · Lightweight tasks · Calm animations · Local-only & private

[![Build](https://img.shields.io/badge/build-Android%20%7C%20Windows%20%7C%20Linux-blue)](.github/workflows/build.yml)
[![Tests](https://img.shields.io/badge/tests-40%20passing-brightgreen)](#testing)
[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)

</div>

---

## ✨ What it does

Flow Pomodoro is a productivity app built around the **Pomodoro technique** and the **flow state model**. It combines structured time blocks with guided transitions, ambient animations, and minimal UI that fades as your focus deepens.

The experience adapts across 5 phases — **pre-focus → initiation → stabilization → deep flow → exit** — with animation intensity decreasing as you settle into deep work, helping you stay there.

## Features

- ⏱️ **Pomodoro timer** — 25/5/15 default with custom durations, auto-switch, configurable rounds before long break
- 🌬️ **Flow Gate transition** — short breathing animation + intent-setting microcopy before each session
- 🎨 **4 selectable animation styles** — Orb · Wave · Particles · Fireworks
- 🌈 **6 accent colors** — Coral · Violet · Emerald · Gold · Sky · Rose
- 🔊 **White noise loops** — Off · White · Pink · Brown · Rain · Campfire · River · Ocean (procedurally generated, with volume control)
- ✅ **Lightweight tasks** — quick add, set active, track pomodoros per task (no project hierarchies, no clutter)
- 📊 **Statistics** — today / total / 7-day trend / focus-by-time-of-day distribution
- 🌓 **Themes** — system / light / dark
- ♿ **Accessibility** — reduce-motion toggle, optional haptics
- 🔒 **100% local & offline** — no accounts, no network, no telemetry

## Platforms

| Platform | Status     | Output                     |
|----------|------------|----------------------------|
| Android  | ✅ Built    | `app-release.apk` / `.aab` |
| Windows  | ✅ Built    | `flow_pomodoro.exe`        |
| Linux    | ✅ Built    | bundle (`tar.gz`)          |
| iOS      | ⛔ Not enabled | —                          |
| macOS / Web | ⛔ Not enabled | —                       |

## Quick start

```bash
cd flow_pomodoro
flutter pub get
flutter run -d windows         # or: -d android, -d linux
```

## Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# Windows
flutter build windows --release

# Linux (run on a Linux host with: clang cmake ninja-build pkg-config libgtk-3-dev)
flutter build linux --release
```

CI builds all three on every push — see [`.github/workflows/build.yml`](.github/workflows/build.yml). Tagged pushes (`v*`) publish a GitHub Release with all artifacts attached.

## Testing

```bash
cd flow_pomodoro
flutter test       # 40 tests across models, providers, timer logic, widget smoke
flutter analyze    # clean
```

Coverage areas:
- **Models** — JSON roundtrips, defaults, null-safety
- **Providers** — settings persistence + clamping, task CRUD + active tracking, stats aggregation (per-day, last-7-days, time-of-day buckets), **resilience to corrupt SharedPreferences blobs**
- **Timer** — full lifecycle via `fake_async`: start / pause / resume / stop, ticking, flow-stage transitions (initiation → stabilization → deep), focus-completion → round increment + session recording, long-break-every-Nth-round
- **Widgets** — app routing, screen navigation, active-task banner reactivity

## Architecture

```
lib/
├── main.dart                    # MultiProvider wiring + app entry
├── models/
│   ├── task.dart                # Task with JSON serialization
│   ├── session.dart             # FocusSession (defensive parsing)
│   ├── flow_animation_style.dart  # Orb | Wave | Particles | Fireworks
│   └── accent_color.dart        # 6-color palette
├── providers/                   # ChangeNotifier + shared_preferences
│   ├── settings_provider.dart   # durations, theme, accent, animation, motion
│   ├── task_provider.dart       # CRUD + active task tracking
│   ├── stats_provider.dart      # session history + aggregations
│   └── timer_provider.dart      # phase + status + tick loop
├── screens/
│   ├── welcome_screen.dart      # onboarding (duration pick)
│   ├── home_screen.dart         # central orb + active task + Start
│   ├── focus_intent_screen.dart # "What will you do…"
│   ├── focus_session_screen.dart # Flow Gate → orb + ring + timer
│   ├── tasks_screen.dart        # list + add + select
│   ├── stats_screen.dart        # cards + bar charts
│   └── settings_screen.dart     # all preferences
├── widgets/
│   ├── flow_orb.dart            # animated central core
│   ├── flow_ring.dart           # circular progress ring
│   ├── flow_wave.dart           # ripple wave style
│   ├── flow_particles.dart      # drifting particles style
│   ├── flow_fireworks.dart      # bursting fireworks style
│   ├── flow_visual.dart         # AnimatedSwitcher style picker
│   └── flow_entry_overlay.dart  # Flow Gate transition
├── theme/
│   └── app_theme.dart           # palette + light/dark themes
└── tool/
    └── gen_assets.dart          # generates icon + splash PNGs
```

### Animation behavior

The Flow Core's motion intensity is driven by elapsed focus time (per the design doc):

| Stage          | Elapsed   | Motion factor |
|----------------|-----------|---------------|
| Initiation     | 0–3 min   | 1.0           |
| Stabilization  | 3–15 min  | 0.7           |
| Deep flow      | 15+ min   | 0.35          |

UI chrome (round counter, task title, controls) also fades during deep flow so the timer becomes nearly the only thing on screen.

### Accessibility

- **Reduce motion** clamps animation intensity to 0.3 globally and shortens the Flow Gate transition.
- **Haptics** can be disabled (off by default in tests).
- **High contrast** is implicitly supported via the dark theme.

## Branding & assets

App icon + splash are generated programmatically from a single source script:

```bash
dart run tool/gen_assets.dart                    # writes assets/icon*.png, splash.png
dart run flutter_launcher_icons                  # → Android adaptive + Windows .ico
dart run flutter_native_splash:create            # → Android 12 splash + legacy
```

The orb design uses the brand palette: dark canvas `#0F1115` with a coral `#FF7A59` core and `#FFB199` glow.

## Privacy & security

- **No network access** — there is no `INTERNET` permission on Android, no network code anywhere
- **No analytics, no crash reporting, no remote config**
- **All data stored locally** via `shared_preferences` (Android: app sandbox; Windows: registry; Linux: `~/.config/`)
- **Defensive deserialization** — corrupt or tampered storage degrades gracefully (logs + reset) rather than crashing

## Tech stack

- [Flutter](https://flutter.dev) 3.41 / Dart 3.11
- [provider](https://pub.dev/packages/provider) — state management
- [shared_preferences](https://pub.dev/packages/shared_preferences) — local persistence
- [fake_async](https://pub.dev/packages/fake_async) — deterministic timer tests
- [image](https://pub.dev/packages/image) — programmatic asset generation
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons), [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)

## Project background

See [`flow_pomodoro_app_product_spec_design_doc.md`](../flow_pomodoro_app_product_spec_design_doc.md) for the full product spec and design philosophy:

> *"The app is designed to facilitate flow, not interrupt it."*

## License

TBD — add a license before publishing.
