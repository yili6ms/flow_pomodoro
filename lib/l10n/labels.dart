import 'package:flutter/widgets.dart';

import '../models/accent_color.dart';
import '../models/flow_animation_style.dart';
import '../models/white_noise.dart';
import '../providers/timer_provider.dart';
import 'app_localizations.dart';

/// Convenience helpers that map enum values to their translated labels.
///
/// Kept in one place so screens don't repeat the same `switch` blocks and so
/// adding a new locale only requires editing the ARB files.
extension LocalizedFlowAnimationStyle on FlowAnimationStyle {
  String localizedLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      FlowAnimationStyle.orb => l.animOrb,
      FlowAnimationStyle.wave => l.animWave,
      FlowAnimationStyle.particles => l.animParticles,
      FlowAnimationStyle.fireworks => l.animFireworks,
    };
  }
}

extension LocalizedAccentColor on AccentColor {
  String localizedLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      AccentColor.coral => l.accentCoral,
      AccentColor.violet => l.accentViolet,
      AccentColor.emerald => l.accentEmerald,
      AccentColor.gold => l.accentGold,
      AccentColor.sky => l.accentSky,
      AccentColor.rose => l.accentRose,
      AccentColor.hybrid => l.accentHybrid,
    };
  }
}

extension LocalizedWhiteNoise on WhiteNoise {
  String localizedLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      WhiteNoise.off => l.noiseOff,
      WhiteNoise.white => l.noiseWhite,
      WhiteNoise.pink => l.noisePink,
      WhiteNoise.brown => l.noiseBrown,
      WhiteNoise.rain => l.noiseRain,
      WhiteNoise.campfire => l.noiseCampfire,
      WhiteNoise.river => l.noiseRiver,
      WhiteNoise.ocean => l.noiseOcean,
    };
  }
}

/// Localized [TimerPhase] label (replaces hard-coded `TimerProvider.phaseLabel`
/// in UI code; the provider's own label is kept for tests / debugging).
String localizedPhaseLabel(BuildContext context, TimerPhase phase) {
  final l = AppLocalizations.of(context);
  return switch (phase) {
    TimerPhase.idle => l.phaseReady,
    TimerPhase.focus => l.phaseFocus,
    TimerPhase.shortBreak => l.phaseShortBreak,
    TimerPhase.longBreak => l.phaseLongBreak,
  };
}

/// Format a focus duration in seconds to a localized short string.
/// Mirrors the previous `_fmtMin` helper in StatsScreen.
String formatFocusDuration(BuildContext context, int seconds) {
  final l = AppLocalizations.of(context);
  final m = seconds ~/ 60;
  if (m < 60) return l.minutesShortFmt(m);
  final h = m ~/ 60;
  final r = m % 60;
  return l.hoursMinutesShort(h, r);
}
