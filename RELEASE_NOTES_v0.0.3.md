# Flow Pomodoro 0.0.3

A polish + reach release: the app speaks Chinese now, picks up a living "Hybrid" accent, opens with an animated brand intro, and lets you swap the focus visualisation on the fly. Released under the MIT license.

## ✨ Highlights

### 🌐 Internationalization (English + 简体中文)
- Full i18n infrastructure powered by `flutter_localizations` + ARB files
- Every UI string in the app is now localized (~80 keys)
- Ships with English and Simplified Chinese translations out of the box
- New **Language** picker in Settings: System / English / 中文
- App title in the OS task switcher follows the chosen locale

### 🌈 Hybrid live accent color
- New **Hybrid** accent option that smoothly cycles through the hue wheel during animations (24-second period)
- Powered by an efficient `Ticker`-driven `ChangeNotifier` (no extra `AnimationController` rebuilds)
- Rendered in Settings as a rainbow `SweepGradient` swatch so you can preview at a glance
- All six visualization-bearing screens automatically pick up the live color

### 🎬 Switch animations on the fly
- Tap the central visual on the Home screen to cycle Orb → Wave → Particles → Fireworks
- New popup picker in the focus session header to switch styles mid-session
- Smooth cross-fade between styles via `AnimatedSwitcher`

### 🚪 Leave-confirmation dialog
- A focus session is sacred — accidental back-presses, swipes, or nav taps now show a "Leave session?" dialog
- All four exit paths (system back, header back, bottom-tab nav, in-app push) honored
- Confirming exit cleanly ends the session

### 🚀 Animated splash intro
- ~2-second branded intro plays right after the native splash:
  - Orb scales up + fades in
  - "FLOW" eyebrow + wordmark
  - Tagline reveal
  - Soft fade into Welcome / Home
- Uses your saved animation style and live accent so first-frame already feels personal
- Honors **Reduce Motion** (collapses to a quick fade)

### 📜 MIT License
- Project is now officially licensed under MIT (Copyright © 2026 Alex Li)
- Free for personal and commercial use, modification, and redistribution

### 📖 README & CI polish
- Live CI status badge (now points at the real `build.yml` workflow on `master`)
- Latest-release, platforms, and license badges
- New "Continuous Integration & Releases" section explaining the tag → `release/<tag>/` flow
- Linux build dependencies documented (gstreamer)

## 🧪 Quality

- `flutter analyze`: 0 issues
- `flutter test`: **43 / 43 passing**
- Builds verified on Android, Windows, and Linux via GitHub Actions

## 📥 Downloads

Binaries for this tag are published to [`release/0.0.3/`](https://github.com/yili6ms/flow_pomodoro/tree/master/release/0.0.3) on `master`:

- **Android** — `flow_pomodoro-0.0.3.apk` (or `.aab`)
- **Windows** — `flow_pomodoro-0.0.3-windows.zip`
- **Linux** — `flow_pomodoro-0.0.3-linux-x64.tar.gz` (requires `libgstreamer1.0-0` + `libgstreamer-plugins-base1.0-0`)

## 🙏 Credits

Built with Flutter 3.41 · provider · audioplayers · shared_preferences

---

**Full changelog:** [`0.0.2...0.0.3`](https://github.com/yili6ms/flow_pomodoro/compare/0.0.2...0.0.3)
