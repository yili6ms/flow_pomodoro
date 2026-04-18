# Changelog

All notable releases of **Flow Pomodoro**, newest first.
Tags follow `MAJOR.MINOR.PATCH` (no `v` prefix). Each release also has signed binaries committed to [`release/<tag>/`](./release) on `master` and a corresponding [GitHub Release](https://github.com/yili6ms/flow_pomodoro/releases).

---

## 0.0.3 — 2026-04-18

A polish + reach release: the app speaks Chinese now, picks up a living "Hybrid" accent, opens with an animated brand intro, and lets you swap the focus visualisation on the fly. Released under the MIT license.

### ✨ Highlights

#### 🌐 Internationalization (English + 简体中文)
- Full i18n infrastructure powered by `flutter_localizations` + ARB files
- Every UI string in the app is now localized (~80 keys)
- Ships with English and Simplified Chinese translations out of the box
- New **Language** picker in Settings: System / English / 中文
- App title in the OS task switcher follows the chosen locale

#### 🌈 Hybrid live accent color
- New **Hybrid** accent option that smoothly cycles through the hue wheel during animations (24-second period)
- Powered by an efficient `Ticker`-driven `ChangeNotifier` (no extra `AnimationController` rebuilds)
- Rendered in Settings as a rainbow `SweepGradient` swatch so you can preview at a glance
- All six visualization-bearing screens automatically pick up the live color

#### 🎬 Switch animations on the fly
- Tap the central visual on the Home screen to cycle Orb → Wave → Particles → Fireworks
- New popup picker in the focus session header to switch styles mid-session
- Smooth cross-fade between styles via `AnimatedSwitcher`

#### 🚪 Leave-confirmation dialog
- A focus session is sacred — accidental back-presses, swipes, or nav taps now show a "Leave session?" dialog
- All four exit paths (system back, header back, bottom-tab nav, in-app push) honored
- Confirming exit cleanly ends the session

#### 🚀 Animated splash intro
- ~2-second branded intro plays right after the native splash:
  - Orb scales up + fades in
  - "FLOW" eyebrow + wordmark
  - Tagline reveal
  - Soft fade into Welcome / Home
- Uses your saved animation style and live accent so first-frame already feels personal
- Honors **Reduce Motion** (collapses to a quick fade)

#### 📜 MIT License
- Project is now officially licensed under MIT (Copyright © 2026 Alex Li)
- Free for personal and commercial use, modification, and redistribution

#### 📖 README & CI polish
- Live CI status badge (now points at the real `build.yml` workflow on `master`)
- Latest-release, platforms, and license badges
- New "Continuous Integration & Releases" section explaining the tag → `release/<tag>/` flow
- Linux build dependencies documented (gstreamer)

### 🧪 Quality
- `flutter analyze`: 0 issues
- `flutter test`: **43 / 43 passing**
- Builds verified on Android, Windows, and Linux via GitHub Actions

### 📥 Downloads
Binaries for this tag are published to [`release/0.0.3/`](./release/0.0.3) on `master`:
- **Android** — `flow_pomodoro-0.0.3.apk` (or `.aab`)
- **Windows** — `flow_pomodoro-0.0.3-windows.zip`
- **Linux** — `flow_pomodoro-0.0.3-linux-x64.tar.gz` (requires `libgstreamer1.0-0` + `libgstreamer-plugins-base1.0-0`)

**Full changelog:** [`0.0.2...0.0.3`](https://github.com/yili6ms/flow_pomodoro/compare/0.0.2...0.0.3)

---

## 0.0.2 — 2026-04-18

A small but soothing release — three new ambient soundscapes for your focus sessions.

### ✨ New
- 🔥 **Campfire** — deep low-frequency rumble layered with sparse crackles and the occasional pop
- 🏞️ **River** — continuous mid-band water rush with subtle shimmer and bubble transients
- 🌊 **Ocean** — slow, deep waves washing in and out (envelope loops cleanly with the buffer)

All three are procedurally generated alongside the existing White / Pink / Brown / Rain loops — no third-party audio is bundled. Picker is in **Settings → White noise** and the in-session quick-switch icon in the focus screen header.

### 🛠️ Internal
- `WhiteNoise` enum extended (`campfire`, `river`, `ocean` + matching ids, labels, icons, asset paths)
- `tool/gen_audio.dart` — 3 new generators (filtered brown rumble + crackle/pop bursts; pink-band river with bubble sines; deep brown wash with multi-cycle ocean envelope)
- New assets: `assets/audio/{campfire,river,ocean}.wav` (~340 KB each, 8 s @ 22.05 kHz mono)
- Bumped version → `0.0.2+2`

### ✅ Quality
- `flutter analyze` — clean
- `flutter test` — 43/43 passing
- Builds verified on Windows; CI builds Android / Windows / Linux

### 📦 Downloads
| Platform | Asset |
|----------|-------|
| **Android** | `flow_pomodoro-0.0.2.apk` · `flow_pomodoro-0.0.2.aab` |
| **Windows** | `flow_pomodoro-0.0.2-windows.zip` |
| **Linux**   | `flow_pomodoro-0.0.2-linux-x64.tar.gz` |

> Linux audio playback requires GStreamer base + good plugins:
> `sudo apt install libgtk-3-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good`

**Full changelog:** [`0.0.1...0.0.2`](https://github.com/yili6ms/flow_pomodoro/compare/0.0.1...0.0.2)

---

## 0.0.1 — 2026-04-18

The first public release of **Flow Pomodoro** — a focused, art-forward Pomodoro timer designed around *flow state*, not just countdowns.

> _"One thing at a time."_

### ✨ Highlights
- **Flow Gate transition** — short breathing animation + intent-setting microcopy before each session
- **Adaptive flow visuals** — the central animation evolves through *initiation → stabilization → deep flow* phases as your session deepens, and quiets the surrounding UI
- **Modern art-forward UI** — animated aurora gradient backgrounds, frosted glass surfaces, gradient-pill buttons, hairline display typography
- **5 white-noise loops** — Off · White · Pink · Brown · Rain (procedurally generated, no third-party audio bundled)
- **4 selectable animation styles** — Orb · Wave · Particles · Fireworks
- **6 accent colors** — Coral · Violet · Emerald · Gold · Sky · Rose
- **Lightweight task list** — quick add, set active, track pomodoros per task — no projects, no clutter
- **Statistics** — today / total / 7-day trend / focus distribution by time of day
- **100% local & offline** — no accounts, no network, no telemetry, no analytics

### ⚙️ Configurable
- Focus duration (1–180 min, default 25)
- Short break (1–60 min, default 5)
- Long break (1–90 min, default 15)
- Rounds before long break (2–10, default 4)
- Auto-switch phases
- Reduce motion · Haptics · Theme (System / Light / Dark)

### 📦 Downloads
| Platform | Asset |
|----------|-------|
| **Android** | `app-release.apk` · `app-release.aab` |
| **Windows** | `flow_pomodoro-windows.zip` (unzip and run `flow_pomodoro.exe`) |
| **Linux** | `flow_pomodoro-linux-x64.tar.gz` (extract and run `./flow_pomodoro`) |

> Linux requires GTK 3 and (for white noise playback) GStreamer base plugins:
> `sudo apt install libgtk-3-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good`

### 🔒 Privacy
Flow Pomodoro stores **all** data — settings, tasks, and session history — locally via `shared_preferences`. It makes **zero** network calls, requests no runtime permissions on Android beyond what desktop platforms grant by default, and has no analytics or crash reporting SDKs bundled.

### 🛠️ Under the hood
- Flutter 3.41 / Dart 3.11 · Material 3
- `provider` + `shared_preferences` for state
- `audioplayers` for ambient loops
- Procedurally-generated icon, splash, and noise assets (`tool/gen_assets.dart`, `tool/gen_audio.dart`)
- Defensive JSON / date parsing (corrupt local storage cannot crash the app)
- 43 unit & widget tests · CI on Android / Windows / Linux

### 🧪 Known limitations
- iOS, macOS, and Web targets are not enabled in this release
- Background timer continuation is not implemented; closing the app stops the timer
- Notifications are not yet wired up — phase transitions rely on the visible window + haptics

### 🙏 Thanks
Inspired by every quiet hour you've ever wished you'd protected. Built by Alex, with Copilot.
