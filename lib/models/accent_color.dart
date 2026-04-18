import 'package:flutter/material.dart';

/// Accent color choices for the focus visuals.
/// Break mode keeps its cool teal palette.
enum AccentColor {
  coral,
  violet,
  emerald,
  gold,
  sky,
  rose,
  hybrid;

  String get label => switch (this) {
        AccentColor.coral => 'Coral',
        AccentColor.violet => 'Violet',
        AccentColor.emerald => 'Emerald',
        AccentColor.gold => 'Gold',
        AccentColor.sky => 'Sky',
        AccentColor.rose => 'Rose',
        AccentColor.hybrid => 'Hybrid',
      };

  String get id => name;

  /// True when the accent should be driven by a [HybridAccentTicker]
  /// instead of returning a constant color.
  bool get isDynamic => this == AccentColor.hybrid;

  Color get primary => switch (this) {
        AccentColor.coral => const Color(0xFFFF7A59),
        AccentColor.violet => const Color(0xFF8E7CFF),
        AccentColor.emerald => const Color(0xFF3FBF8F),
        AccentColor.gold => const Color(0xFFE5B142),
        AccentColor.sky => const Color(0xFF59A8FF),
        AccentColor.rose => const Color(0xFFE85A8A),
        // Static fallback when ticker is not yet running.
        AccentColor.hybrid => const Color(0xFFB377FF),
      };

  Color get glow => switch (this) {
        AccentColor.coral => const Color(0xFFFFB199),
        AccentColor.violet => const Color(0xFFC0B5FF),
        AccentColor.emerald => const Color(0xFF8AE3BF),
        AccentColor.gold => const Color(0xFFFAD98A),
        AccentColor.sky => const Color(0xFF9CCBFF),
        AccentColor.rose => const Color(0xFFFFA1BD),
        AccentColor.hybrid => const Color(0xFFE5C8FF),
      };

  static AccentColor fromId(String? id) {
    for (final c in AccentColor.values) {
      if (c.id == id) return c;
    }
    return AccentColor.coral;
  }
}
