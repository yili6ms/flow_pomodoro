# Flow Pomodoro v0.0.2

A small but soothing release — three new ambient soundscapes for your focus sessions.

## ✨ New

- 🔥 **Campfire** — deep low-frequency rumble layered with sparse crackles and the occasional pop
- 🏞️ **River** — continuous mid-band water rush with subtle shimmer and bubble transients
- 🌊 **Ocean** — slow, deep waves washing in and out (envelope loops cleanly with the buffer)

All three are procedurally generated alongside the existing White / Pink / Brown / Rain loops — no third-party audio is bundled. Picker is in **Settings → White noise** and the in-session quick-switch icon in the focus screen header.

## 🛠️ Internal

- `WhiteNoise` enum extended (`campfire`, `river`, `ocean` + matching ids, labels, icons, asset paths)
- `tool/gen_audio.dart` — 3 new generators (filtered brown rumble + crackle/pop bursts; pink-band river with bubble sines; deep brown wash with multi-cycle ocean envelope)
- New assets: `assets/audio/{campfire,river,ocean}.wav` (~340 KB each, 8 s @ 22.05 kHz mono)
- Bumped version → `0.0.2+2`

## ✅ Quality

- `flutter analyze` — clean
- `flutter test` — 43/43 passing
- Builds verified on Windows; CI builds Android / Windows / Linux

## 📦 Downloads

| Platform | Asset |
|----------|-------|
| **Android** | `flow_pomodoro-v0.0.2.apk` · `flow_pomodoro-v0.0.2.aab` |
| **Windows** | `flow_pomodoro-v0.0.2-windows.zip` |
| **Linux**   | `flow_pomodoro-v0.0.2-linux-x64.tar.gz` |

> Linux audio playback requires GStreamer base + good plugins:
> `sudo apt install libgtk-3-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good`

---

**Tag:** `v0.0.2` · **Channel:** stable · **Previous:** [v0.0.1](./RELEASE_NOTES_v0.0.1.md)
