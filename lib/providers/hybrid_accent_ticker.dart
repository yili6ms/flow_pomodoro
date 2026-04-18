import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/accent_color.dart';
import 'settings_provider.dart';

/// Continuously cycles a hue-rotated color pair used by the
/// [AccentColor.hybrid] accent. Frame-driven via [Ticker] (no busy [Timer])
/// and only runs while the hybrid accent is selected so the cost is zero
/// for the static palettes.
class HybridAccentTicker extends ChangeNotifier {
  HybridAccentTicker({
    Duration period = const Duration(seconds: 24),
  }) : _periodMicros = period.inMicroseconds {
    _ticker = Ticker(_onTick);
  }

  final int _periodMicros;
  late final Ticker _ticker;
  double _t = 0; // 0..1 — phase along the hue wheel

  /// Saturated leading color used for primary strokes / fills.
  Color get primary =>
      HSVColor.fromAHSV(1, (_t * 360) % 360, 0.78, 1.0).toColor();

  /// Slightly hue-shifted, lower-saturation companion used for glow / halos.
  Color get glow =>
      HSVColor.fromAHSV(1, (_t * 360 + 38) % 360, 0.45, 1.0).toColor();

  bool get isRunning => _ticker.isActive;

  void start() {
    if (!_ticker.isActive) _ticker.start();
  }

  void stop() {
    if (_ticker.isActive) _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    final next = (elapsed.inMicroseconds % _periodMicros) / _periodMicros;
    if ((next - _t).abs() < 0.0015) return;
    _t = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// Owns the lifecycle wiring: starts the ticker iff the user has chosen
/// [AccentColor.hybrid] in settings.
class HybridAccentController {
  HybridAccentController({
    required this.settings,
    required this.ticker,
  }) {
    settings.addListener(_sync);
    _sync();
  }

  final SettingsProvider settings;
  final HybridAccentTicker ticker;

  void _sync() {
    if (settings.accentColor.isDynamic) {
      ticker.start();
    } else {
      ticker.stop();
    }
  }

  void dispose() {
    settings.removeListener(_sync);
  }
}

/// Resolved accent snapshot. Stable for the current frame.
typedef LiveAccent = ({Color primary, Color glow});

extension LiveAccentX on BuildContext {
  /// Returns the currently active accent colors, watching the appropriate
  /// providers so the calling widget rebuilds when they change.
  ///
  /// For static palettes this watches [SettingsProvider] only.
  /// For [AccentColor.hybrid] it additionally watches [HybridAccentTicker],
  /// which fires per frame while playing.
  LiveAccent liveAccent() {
    final accent = watch<SettingsProvider>().accentColor;
    if (!accent.isDynamic) {
      return (primary: accent.primary, glow: accent.glow);
    }
    final t = watch<HybridAccentTicker>();
    return (primary: t.primary, glow: t.glow);
  }
}
