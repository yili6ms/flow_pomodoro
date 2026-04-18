// Generates seamless-looping noise audio assets used for the focus white noise
// feature. All files are mono 16-bit PCM WAV @ 22050 Hz.
//
// Run with:
//   dart run tool/gen_audio.dart
//
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 22050;
const double durationSeconds = 8.0;

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  _writeWav('${outDir.path}/white.wav', _whiteNoise());
  _writeWav('${outDir.path}/pink.wav', _pinkNoise());
  _writeWav('${outDir.path}/brown.wav', _brownNoise());
  _writeWav('${outDir.path}/rain.wav', _rainNoise());
  _writeWav('${outDir.path}/campfire.wav', _campfireNoise());
  _writeWav('${outDir.path}/river.wav', _riverNoise());
  _writeWav('${outDir.path}/ocean.wav', _oceanNoise());
  print('Generated noise assets in ${outDir.path}');
}

int get _totalSamples => (sampleRate * durationSeconds).round();

/// Crossfade the last `fadeSamples` of the buffer with the start so that
/// looping is seamless.
void _seamlessLoop(Float32List buf, {int fadeSamples = 1024}) {
  final n = buf.length;
  for (int i = 0; i < fadeSamples; i++) {
    final t = i / fadeSamples; // 0..1
    final tail = buf[n - fadeSamples + i];
    final head = buf[i];
    buf[i] = head * t + tail * (1 - t);
  }
  // Trim the (now redundant) tail by overwriting with cross-faded values too
  // is not required because we'll only output the head portion of length
  // (n - fadeSamples) won't help as we want full duration. Instead leave tail
  // as-is — our crossfade ensures buf[0] == buf[n-fadeSamples], which makes
  // looping by playing [0, n-fadeSamples) seamless. Callers should slice.
}

Float32List _whiteNoise() {
  final rng = math.Random(0xC0FFEE);
  final out = Float32List(_totalSamples);
  for (int i = 0; i < out.length; i++) {
    out[i] = (rng.nextDouble() * 2 - 1) * 0.5;
  }
  _seamlessLoop(out);
  return out;
}

/// Paul Kellet's pink noise filter (well-known approximation).
Float32List _pinkNoise() {
  final rng = math.Random(0xBADA55);
  final out = Float32List(_totalSamples);
  double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    b0 = 0.99886 * b0 + w * 0.0555179;
    b1 = 0.99332 * b1 + w * 0.0750759;
    b2 = 0.96900 * b2 + w * 0.1538520;
    b3 = 0.86650 * b3 + w * 0.3104856;
    b4 = 0.55000 * b4 + w * 0.5329522;
    b5 = -0.7616 * b5 - w * 0.0168980;
    final pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362;
    b6 = w * 0.115926;
    out[i] = (pink * 0.11).clamp(-1.0, 1.0);
  }
  _seamlessLoop(out);
  return out;
}

/// Brown noise: integrate white noise with a small leak to prevent drift.
Float32List _brownNoise() {
  final rng = math.Random(0xBE7);
  final out = Float32List(_totalSamples);
  double last = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    last = (last + w * 0.02) * 0.995;
    if (last > 1.0) last = 1.0;
    if (last < -1.0) last = -1.0;
    out[i] = last * 3.5;
    if (out[i] > 1.0) out[i] = 1.0;
    if (out[i] < -1.0) out[i] = -1.0;
  }
  _seamlessLoop(out);
  return out;
}

/// Rain: heavily low-passed brown noise plus randomized "droplet" transients.
Float32List _rainNoise() {
  final rng = math.Random(0x4A1);
  final out = Float32List(_totalSamples);

  // Filtered brown base — wetter, mid-frequency hiss
  double y = 0;
  double brown = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    brown = (brown + w * 0.05) * 0.99;
    // 1-pole low pass
    y += 0.15 * (brown - y);
    out[i] = y * 1.8;
  }

  // Sparse droplet transients (decaying high-frequency clicks)
  final dropletCount = (durationSeconds * 30).round();
  for (int d = 0; d < dropletCount; d++) {
    final pos = rng.nextInt(out.length - 200);
    final amp = 0.05 + rng.nextDouble() * 0.15;
    final decay = 60 + rng.nextInt(120);
    for (int k = 0; k < decay && pos + k < out.length; k++) {
      final env = math.exp(-k / (decay * 0.35));
      final tone = math.sin(k * (0.3 + rng.nextDouble() * 0.6));
      out[pos + k] += amp * env * tone;
    }
  }

  // Normalize to safe range
  double peak = 0;
  for (final v in out) {
    final av = v.abs();
    if (av > peak) peak = av;
  }
  if (peak > 0) {
    final scale = 0.9 / peak;
    for (int i = 0; i < out.length; i++) {
      out[i] *= scale;
    }
  }
  _seamlessLoop(out);
  return out;
}

/// Campfire: deep low-frequency rumble (heavily filtered brown) plus
/// random sharp crackle/pop transients.
Float32List _campfireNoise() {
  final rng = math.Random(0xF14E);
  final out = Float32List(_totalSamples);

  // Slow rumble: heavily smoothed brown noise
  double brown = 0;
  double y = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    brown = (brown + w * 0.04) * 0.992;
    // Two-pole low pass for warm rumble
    y += 0.06 * (brown - y);
    out[i] = y * 4.5;
  }

  // Sparse crackles: short bursts of high-freq decaying noise
  final crackleCount = (durationSeconds * 14).round();
  for (int c = 0; c < crackleCount; c++) {
    final pos = rng.nextInt(out.length - 400);
    final amp = 0.15 + rng.nextDouble() * 0.35;
    final decay = 30 + rng.nextInt(180);
    for (int k = 0; k < decay && pos + k < out.length; k++) {
      final env = math.exp(-k / (decay * 0.25));
      // High-frequency content (random + slight tone)
      final hf = (rng.nextDouble() * 2 - 1) * 0.7 +
          math.sin(k * (1.4 + rng.nextDouble() * 0.8)) * 0.3;
      out[pos + k] += amp * env * hf;
    }
  }

  // Occasional larger pops
  final popCount = (durationSeconds * 1.5).round();
  for (int p = 0; p < popCount; p++) {
    final pos = rng.nextInt(out.length - 80);
    final amp = 0.4 + rng.nextDouble() * 0.4;
    for (int k = 0; k < 80 && pos + k < out.length; k++) {
      final env = math.exp(-k / 18.0);
      out[pos + k] += amp * env * (rng.nextDouble() * 2 - 1);
    }
  }

  _normalizeTo(out, 0.92);
  _seamlessLoop(out);
  return out;
}

/// River: continuous fast-flowing water — filtered pink noise with subtle
/// slow amplitude shimmer and occasional bubble transients.
Float32List _riverNoise() {
  final rng = math.Random(0x819E2);
  final out = Float32List(_totalSamples);

  // Pink-ish base via Kellet
  double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
  // Band-pass-ish via two single-pole filters
  double lp = 0;
  double hp = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    b0 = 0.99886 * b0 + w * 0.0555179;
    b1 = 0.99332 * b1 + w * 0.0750759;
    b2 = 0.96900 * b2 + w * 0.1538520;
    b3 = 0.86650 * b3 + w * 0.3104856;
    b4 = 0.55000 * b4 + w * 0.5329522;
    b5 = -0.7616 * b5 - w * 0.0168980;
    final pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362;
    b6 = w * 0.115926;

    // Low pass to reduce hiss, then high-pass to remove rumble => "rushy" mid band
    lp += 0.35 * (pink * 0.10 - lp);
    hp = lp - hp * 0.0; // pass-through; keep simple
    out[i] = lp * 1.8;
  }

  // Subtle slow amplitude shimmer (whole-number cycles in 8s for seamless loop)
  for (int i = 0; i < out.length; i++) {
    final t = i / sampleRate;
    final shimmer = 0.85 +
        0.15 * math.sin(2 * math.pi * (1 / durationSeconds) * t) +
        0.05 * math.sin(2 * math.pi * (3 / durationSeconds) * t);
    out[i] *= shimmer;
  }

  // Occasional "bubble" transients — short low-freq sine bursts
  final bubbleCount = (durationSeconds * 4).round();
  for (int b = 0; b < bubbleCount; b++) {
    final pos = rng.nextInt(out.length - 300);
    final freq = 200 + rng.nextDouble() * 400; // Hz
    final decay = 80 + rng.nextInt(200);
    final amp = 0.06 + rng.nextDouble() * 0.10;
    for (int k = 0; k < decay && pos + k < out.length; k++) {
      final env = math.exp(-k / (decay * 0.4));
      final tone = math.sin(2 * math.pi * freq * (k / sampleRate));
      out[pos + k] += amp * env * tone;
    }
  }

  _normalizeTo(out, 0.85);
  _seamlessLoop(out);
  return out;
}

/// Ocean: slow waves washing in and out — filtered brown/pink noise with
/// a deep, slow amplitude envelope. The envelope completes exactly one
/// cycle over the loop length so it loops seamlessly.
Float32List _oceanNoise() {
  final rng = math.Random(0x0CEA);
  final out = Float32List(_totalSamples);

  // Filtered brown for deep wash
  double brown = 0;
  double lp = 0;
  for (int i = 0; i < out.length; i++) {
    final w = rng.nextDouble() * 2 - 1;
    brown = (brown + w * 0.05) * 0.996;
    lp += 0.10 * (brown - lp);
    out[i] = lp * 3.0;
  }

  // Two overlapping wave envelopes — one fundamental cycle + a half-cycle
  // overlay for variation; both integer multiples of 1/duration so loop is clean.
  for (int i = 0; i < out.length; i++) {
    final t = i / sampleRate;
    final w1 = 0.5 +
        0.5 * math.sin(2 * math.pi * (1 / durationSeconds) * t - math.pi / 2);
    final w2 = 0.5 +
        0.5 * math.sin(2 * math.pi * (2 / durationSeconds) * t + 0.7);
    final env = math.pow(w1 * 0.7 + w2 * 0.3, 1.6).toDouble();
    out[i] *= 0.25 + env * 0.95;
  }

  // Light foam — high-frequency hiss layered very softly during peaks
  for (int i = 0; i < out.length; i++) {
    final t = i / sampleRate;
    final peak =
        math.max(0.0, math.sin(2 * math.pi * (1 / durationSeconds) * t - math.pi / 2));
    if (peak > 0.4) {
      final hiss = (rng.nextDouble() * 2 - 1) * 0.05 * peak;
      out[i] += hiss;
    }
  }

  _normalizeTo(out, 0.88);
  _seamlessLoop(out);
  return out;
}

void _normalizeTo(Float32List buf, double targetPeak) {
  double peak = 0;
  for (final v in buf) {
    final av = v.abs();
    if (av > peak) peak = av;
  }
  if (peak <= 0) return;
  final scale = targetPeak / peak;
  for (int i = 0; i < buf.length; i++) {
    buf[i] *= scale;
  }
}

void _writeWav(String path, Float32List samples) {
  // We expose only [0, length - fadeSamples) for clean looping; but
  // simpler: just emit the whole buffer (the crossfade means the last
  // fadeSamples are redundant tail; players still loop the full file). For
  // our use case (audioplayers ReleaseMode.loop), gapless restart from a
  // crossfaded buffer is acceptable.
  final pcm = Int16List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    pcm[i] = v;
  }
  final byteData = pcm.buffer.asUint8List();

  final header = _wavHeader(
    dataLength: byteData.length,
    sampleRate: sampleRate,
    channels: 1,
    bitsPerSample: 16,
  );

  final file = File(path);
  final sink = file.openSync(mode: FileMode.write);
  sink.writeFromSync(header);
  sink.writeFromSync(byteData);
  sink.closeSync();
  print('  wrote $path  (${(byteData.length / 1024).toStringAsFixed(1)} KB)');
}

Uint8List _wavHeader({
  required int dataLength,
  required int sampleRate,
  required int channels,
  required int bitsPerSample,
}) {
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final b = BytesBuilder();
  b.add(_ascii('RIFF'));
  b.add(_u32(36 + dataLength));
  b.add(_ascii('WAVE'));
  b.add(_ascii('fmt '));
  b.add(_u32(16));
  b.add(_u16(1)); // PCM
  b.add(_u16(channels));
  b.add(_u32(sampleRate));
  b.add(_u32(byteRate));
  b.add(_u16(blockAlign));
  b.add(_u16(bitsPerSample));
  b.add(_ascii('data'));
  b.add(_u32(dataLength));
  return b.toBytes();
}

List<int> _ascii(String s) => s.codeUnits;
List<int> _u16(int v) => [v & 0xff, (v >> 8) & 0xff];
List<int> _u32(int v) =>
    [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff];
