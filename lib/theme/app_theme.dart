import 'package:flutter/material.dart';

/// Color palette inspired by the design doc:
/// - Focus / Deep Flow: warm coral/orange tones
/// - Break: cool blue/teal tones
class FlowColors {
  static const focusPrimary = Color(0xFFFF7A59);
  static const focusDeep = Color(0xFFE5634A);
  static const focusGlow = Color(0xFFFFB199);

  static const breakPrimary = Color(0xFF4FB3BF);
  static const breakDeep = Color(0xFF2E8A95);
  static const breakGlow = Color(0xFF8FD7DD);

  // Deeper near-black canvas; redesigned UI uses Aurora over the top.
  static const bgDark = Color(0xFF08090C);
  static const bgDarkSoft = Color(0xFF14171F);
  static const surfaceGlass = Color(0x1AFFFFFF);
  static const stroke = Color(0x22FFFFFF);
  static const textPrimary = Color(0xFFF5F4F2);
  static const textMuted = Color(0xFF9AA0A6);
  static const textFaint = Color(0xFF6B6F76);
}

class AppTheme {
  static TextTheme _textTheme(TextTheme base, Color body) {
    return base
        .apply(bodyColor: body, displayColor: body, fontFamily: 'Roboto')
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w200,
            letterSpacing: -1.2,
            color: body,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w200,
            letterSpacing: -0.8,
            color: body,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: -0.3,
            color: body,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: body,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: body,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            height: 1.45,
            color: body,
          ),
        );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FlowColors.bgDark,
      colorScheme: base.colorScheme.copyWith(
        primary: FlowColors.focusPrimary,
        secondary: FlowColors.breakPrimary,
        surface: FlowColors.bgDarkSoft,
        surfaceContainerHighest: FlowColors.surfaceGlass,
      ),
      textTheme: _textTheme(base.textTheme, FlowColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      dividerColor: FlowColors.stroke,
      iconTheme: const IconThemeData(color: FlowColors.textMuted),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        selectedColor: FlowColors.focusPrimary.withValues(alpha: 0.25),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        labelStyle: const TextStyle(color: FlowColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: FlowColors.focusPrimary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.10),
        thumbColor: FlowColors.focusGlow,
        overlayColor: FlowColors.focusPrimary.withValues(alpha: 0.18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        hintStyle: const TextStyle(color: FlowColors.textFaint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: FlowColors.focusGlow.withValues(alpha: 0.6), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlowColors.focusPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFAF7F4),
      colorScheme: base.colorScheme.copyWith(
        primary: FlowColors.focusPrimary,
        secondary: FlowColors.breakPrimary,
      ),
      textTheme: _textTheme(base.textTheme, const Color(0xFF222222)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF222222),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlowColors.focusPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
