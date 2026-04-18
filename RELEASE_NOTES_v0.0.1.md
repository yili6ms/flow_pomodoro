# Flow Pomodoro v0.0.1

The first public release of **Flow Pomodoro** — a focused, art-forward Pomodoro timer designed around *flow state*, not just countdowns.

> _"One thing at a time."_

---

## ✨ Highlights

- **Flow Gate transition** — short breathing animation + intent-setting microcopy before each session
- **Adaptive flow visuals** — the central animation evolves through *initiation → stabilization → deep flow* phases as your session deepens, and quiets the surrounding UI
- **Modern art-forward UI** — animated aurora gradient backgrounds, frosted glass surfaces, gradient-pill buttons, hairline display typography
- **5 white-noise loops** — Off · White · Pink · Brown · Rain (procedurally generated, no third-party audio bundled)
- **4 selectable animation styles** — Orb · Wave · Particles · Fireworks
- **6 accent colors** — Coral · Violet · Emerald · Gold · Sky · Rose
- **Lightweight task list** — quick add, set active, track pomodoros per task — no projects, no clutter
- **Statistics** — today / total / 7-day trend / focus distribution by time of day
- **100% local & offline** — no accounts, no network, no telemetry, no analytics

## ⚙️ Configurable

- Focus duration (1–180 min, default 25)
- Short break (1–60 min, default 5)
- Long break (1–90 min, default 15)
- Rounds before long break (2–10, default 4)
- Auto-switch phases
- Reduce motion · Haptics · Theme (System / Light / Dark)

## 📦 Downloads

| Platform | Asset |
|----------|-------|
| **Android** | `app-release.apk` · `app-release.aab` |
| **Windows** | `flow_pomodoro-windows.zip` (unzip and run `flow_pomodoro.exe`) |
| **Linux** | `flow_pomodoro-linux-x64.tar.gz` (extract and run `./flow_pomodoro`) |

> Linux requires GTK 3 and (for white noise playback) GStreamer base plugins:
> `sudo apt install libgtk-3-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good`

## 🔒 Privacy

Flow Pomodoro stores **all** data — settings, tasks, and session history — locally via `shared_preferences`. It makes **zero** network calls, requests no runtime permissions on Android beyond what desktop platforms grant by default, and has no analytics or crash reporting SDKs bundled.

## 🛠️ Under the hood

- Flutter 3.41 / Dart 3.11 · Material 3
- `provider` + `shared_preferences` for state
- `audioplayers` for ambient loops
- Procedurally-generated icon, splash, and noise assets (`tool/gen_assets.dart`, `tool/gen_audio.dart`)
- Defensive JSON / date parsing (corrupt local storage cannot crash the app)
- 43 unit & widget tests · CI on Android / Windows / Linux

## 🧪 Known limitations

- iOS, macOS, and Web targets are not enabled in this release
- Background timer continuation is not implemented; closing the app stops the timer
- Notifications are not yet wired up — phase transitions rely on the visible window + haptics

## 🙏 Thanks

Inspired by every quiet hour you've ever wished you'd protected. Built by Alex, with Copilot.

---

**Tag:** `v0.0.1` · **Channel:** stable
