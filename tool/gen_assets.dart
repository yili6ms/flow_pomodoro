// Generates the Flow Pomodoro app icon and splash logo as PNG files.
//
// Run with:
//   dart run tool/gen_assets.dart
//
// ignore_for_file: avoid_print
//
// Outputs:
//   assets/icon.png            — 1024x1024 full-bleed (for adaptive icon foreground & legacy)
//   assets/icon_foreground.png — 1024x1024 foreground orb (transparent bg, for adaptive icon)
//   assets/splash.png          — 768x768 centered orb on transparent bg
//   assets/branding.png        — small "Flow Pomodoro" wordmark for splash bottom

import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

// --- Brand colors (mirror lib/theme/app_theme.dart) ---
const _bg = [0x0F, 0x11, 0x15]; // FlowColors.bgDark
const _coral = [0xFF, 0x7A, 0x59]; // focusPrimary
const _coralDeep = [0xE5, 0x63, 0x4A]; // focusDeep
const _coralGlow = [0xFF, 0xB1, 0x99]; // focusGlow

img.Color _rgba(List<int> c, double a) =>
    img.ColorRgba8(c[0], c[1], c[2], (a * 255).round().clamp(0, 255));

double _smoothstep(double e0, double e1, double x) {
  final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

/// Linearly blend `over` (rgba) onto `base` (rgb), returns rgba8.
img.Color _blend(List<int> base, List<int> over, double a) {
  final inv = 1 - a;
  return img.ColorRgba8(
    (base[0] * inv + over[0] * a).round().clamp(0, 255),
    (base[1] * inv + over[1] * a).round().clamp(0, 255),
    (base[2] * inv + over[2] * a).round().clamp(0, 255),
    255,
  );
}

/// Paints the Flow Orb into `image`. Optionally fills a dark background.
void _paintOrb(img.Image image, {required bool dark, double scale = 1.0}) {
  final w = image.width;
  final h = image.height;
  final cx = w / 2.0;
  final cy = h / 2.0;
  final maxR = math.min(w, h) / 2.0;

  // Stage radii (fractions of maxR)
  final rHalo = maxR * 0.95 * scale;
  final rBody = maxR * 0.62 * scale;
  final rCore = maxR * 0.32 * scale;

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final d = math.sqrt(dx * dx + dy * dy);

      // Background
      double bgA = dark ? 1.0 : 0.0;
      List<int> baseRgb = dark ? _bg : [0, 0, 0];

      // Halo: glow color, alpha falls from rHalo*0.45 → rHalo
      final halo = (1 - _smoothstep(rHalo * 0.35, rHalo, d)) * 0.55;

      // Body: coral, falls from 0 → rBody
      final body = (1 - _smoothstep(rBody * 0.2, rBody, d)) * 0.95;

      // Core: white-hot center
      final core = (1 - _smoothstep(rCore * 0.0, rCore, d)) * 0.95;

      // Compose (over background or transparent)
      double r, g, b, a;
      if (dark) {
        r = baseRgb[0].toDouble();
        g = baseRgb[1].toDouble();
        b = baseRgb[2].toDouble();
        a = 255;
      } else {
        r = 0; g = 0; b = 0; a = 0;
      }

      void over(List<int> c, double alpha) {
        if (alpha <= 0) return;
        if (a == 0) {
          r = c[0].toDouble(); g = c[1].toDouble(); b = c[2].toDouble();
          a = (alpha * 255);
        } else {
          final na = alpha; // source alpha 0..1
          r = r * (1 - na) + c[0] * na;
          g = g * (1 - na) + c[1] * na;
          b = b * (1 - na) + c[2] * na;
          a = math.min(255, a + alpha * 255);
        }
      }

      // Layer order: halo (glow), body (deep coral), body (coral), core (warm white)
      over(_coralGlow, halo);
      over(_coralDeep, body * 0.4);
      over(_coral, body * 0.7);
      over([255, 230, 210], core * 0.85);

      // Background already set above; the base (dark) doesn't have alpha
      // overrides because we composited onto it. Suppress unused warning.
      // ignore: unused_local_variable
      final _ = bgA;

      image.setPixel(
        x,
        y,
        img.ColorRgba8(
          r.round().clamp(0, 255),
          g.round().clamp(0, 255),
          b.round().clamp(0, 255),
          a.round().clamp(0, 255),
        ),
      );
    }
  }

  // Slow orbit highlights (3 small bright dots) for "fancy"
  final orbitR = maxR * 0.78 * scale;
  for (int i = 0; i < 3; i++) {
    final angle = (i / 3) * math.pi * 2 - math.pi / 6;
    final px = (cx + orbitR * math.cos(angle)).round();
    final py = (cy + orbitR * math.sin(angle)).round();
    img.fillCircle(
      image,
      x: px,
      y: py,
      radius: (maxR * 0.025).round(),
      color: _rgba(_coralGlow, 0.95),
      antialias: true,
    );
  }

  // Subtle outer arc highlight (top-left rim of the orb)
  // gives the icon depth without requiring real 3D shading.
  for (double t = 0; t < math.pi / 1.6; t += 0.005) {
    final ang = math.pi + math.pi * 0.15 + t;
    final px = (cx + (rBody * 0.98) * math.cos(ang)).round();
    final py = (cy + (rBody * 0.98) * math.sin(ang)).round();
    if (px < 0 || py < 0 || px >= w || py >= h) continue;
    final p = image.getPixel(px, py);
    image.setPixel(
        px,
        py,
        _blend(
          [p.r.toInt(), p.g.toInt(), p.b.toInt()],
          [255, 240, 220],
          0.35,
        ));
  }
}

/// Draw a rounded-rect mask: zero alpha outside the rounded square.
void _applyRoundedMask(img.Image image, {required double radiusFactor}) {
  final w = image.width;
  final h = image.height;
  final r = math.min(w, h) * radiusFactor;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      double inset = 0;
      if (x < r && y < r) {
        final dx = r - x, dy = r - y;
        inset = math.sqrt(dx * dx + dy * dy) - r;
      } else if (x > w - r && y < r) {
        final dx = x - (w - r), dy = r - y;
        inset = math.sqrt(dx * dx + dy * dy) - r;
      } else if (x < r && y > h - r) {
        final dx = r - x, dy = y - (h - r);
        inset = math.sqrt(dx * dx + dy * dy) - r;
      } else if (x > w - r && y > h - r) {
        final dx = x - (w - r), dy = y - (h - r);
        inset = math.sqrt(dx * dx + dy * dy) - r;
      }
      if (inset > 0) {
        // Soft 1px AA edge.
        final aa = (1 - inset.clamp(0, 1)).clamp(0.0, 1.0);
        final p = image.getPixel(x, y);
        image.setPixel(
          x,
          y,
          img.ColorRgba8(
            p.r.toInt(),
            p.g.toInt(),
            p.b.toInt(),
            (p.a.toInt() * aa).round(),
          ),
        );
      }
    }
  }
}

void main() {
  final assets = Directory('assets')..createSync(recursive: true);
  print('Generating assets in ${assets.path}/ ...');

  // 1) Full-bleed icon (dark bg + orb), with rounded corners for legacy launchers.
  final icon = img.Image(width: 1024, height: 1024, numChannels: 4);
  // Fill dark bg first.
  img.fill(icon, color: img.ColorRgba8(_bg[0], _bg[1], _bg[2], 255));
  _paintOrb(icon, dark: true, scale: 0.78);
  _applyRoundedMask(icon, radiusFactor: 0.22);
  File('assets/icon.png').writeAsBytesSync(img.encodePng(icon));

  // 2) Adaptive-icon foreground: orb on transparent bg.
  final fg = img.Image(width: 1024, height: 1024, numChannels: 4);
  _paintOrb(fg, dark: false, scale: 0.55); // smaller; safe-zone aware
  File('assets/icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  // 3) Splash centered logo (transparent).
  final splash = img.Image(width: 768, height: 768, numChannels: 4);
  _paintOrb(splash, dark: false, scale: 0.85);
  File('assets/splash.png').writeAsBytesSync(img.encodePng(splash));

  print('Done.');
  for (final f in ['icon', 'icon_foreground', 'splash']) {
    final s = File('assets/$f.png').lengthSync();
    print('  assets/$f.png  ${(s / 1024).toStringAsFixed(1)} KB');
  }
}
