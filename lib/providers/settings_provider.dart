import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/accent_color.dart';
import '../models/flow_animation_style.dart';
import '../models/white_noise.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kFocusMin = 'settings.focusMinutes';
  static const _kShortBreakMin = 'settings.shortBreakMinutes';
  static const _kLongBreakMin = 'settings.longBreakMinutes';
  static const _kRoundsBeforeLong = 'settings.roundsBeforeLongBreak';
  static const _kAutoSwitch = 'settings.autoSwitch';
  static const _kThemeMode = 'settings.themeMode'; // 'system'|'light'|'dark'
  static const _kReduceMotion = 'settings.reduceMotion';
  static const _kHaptics = 'settings.haptics';
  static const _kOnboarded = 'settings.onboarded';
  static const _kAnimStyle = 'settings.animationStyle';
  static const _kAccent = 'settings.accentColor';
  static const _kWhiteNoise = 'settings.whiteNoise';
  static const _kNoiseVolume = 'settings.noiseVolume';
  static const _kLanguage = 'settings.language'; // 'system'|'en'|'zh'

  int focusMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int roundsBeforeLongBreak = 4;
  bool autoSwitch = false;
  bool reduceMotion = false;
  bool haptics = true;
  bool onboarded = false;
  ThemeMode themeMode = ThemeMode.dark;
  FlowAnimationStyle animationStyle = FlowAnimationStyle.orb;
  AccentColor accentColor = AccentColor.coral;
  WhiteNoise whiteNoise = WhiteNoise.off;
  double noiseVolume = 0.5;

  /// 'system' (follow device locale), 'en', or 'zh'. Persisted as a string.
  /// Use [locale] to convert to a [Locale] (or null for system).
  String language = 'system';

  Locale? get locale => switch (language) {
        'en' => const Locale('en'),
        'zh' => const Locale('zh'),
        _ => null,
      };

  late SharedPreferences _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    focusMinutes = _prefs.getInt(_kFocusMin) ?? 25;
    shortBreakMinutes = _prefs.getInt(_kShortBreakMin) ?? 5;
    longBreakMinutes = _prefs.getInt(_kLongBreakMin) ?? 15;
    roundsBeforeLongBreak = _prefs.getInt(_kRoundsBeforeLong) ?? 4;
    autoSwitch = _prefs.getBool(_kAutoSwitch) ?? false;
    reduceMotion = _prefs.getBool(_kReduceMotion) ?? false;
    haptics = _prefs.getBool(_kHaptics) ?? true;
    onboarded = _prefs.getBool(_kOnboarded) ?? false;
    final tm = _prefs.getString(_kThemeMode) ?? 'dark';
    themeMode = switch (tm) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    animationStyle =
        FlowAnimationStyle.fromId(_prefs.getString(_kAnimStyle));
    accentColor = AccentColor.fromId(_prefs.getString(_kAccent));
    whiteNoise = WhiteNoise.fromId(_prefs.getString(_kWhiteNoise));
    noiseVolume = (_prefs.getDouble(_kNoiseVolume) ?? 0.5).clamp(0.0, 1.0);
    final lang = _prefs.getString(_kLanguage) ?? 'system';
    language = (lang == 'en' || lang == 'zh') ? lang : 'system';
    notifyListeners();
  }

  Future<void> setFocusMinutes(int v) async {
    focusMinutes = v.clamp(1, 180);
    await _prefs.setInt(_kFocusMin, focusMinutes);
    notifyListeners();
  }

  Future<void> setShortBreakMinutes(int v) async {
    shortBreakMinutes = v.clamp(1, 60);
    await _prefs.setInt(_kShortBreakMin, shortBreakMinutes);
    notifyListeners();
  }

  Future<void> setLongBreakMinutes(int v) async {
    longBreakMinutes = v.clamp(1, 90);
    await _prefs.setInt(_kLongBreakMin, longBreakMinutes);
    notifyListeners();
  }

  Future<void> setRoundsBeforeLongBreak(int v) async {
    roundsBeforeLongBreak = v.clamp(2, 10);
    await _prefs.setInt(_kRoundsBeforeLong, roundsBeforeLongBreak);
    notifyListeners();
  }

  Future<void> setAutoSwitch(bool v) async {
    autoSwitch = v;
    await _prefs.setBool(_kAutoSwitch, v);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool v) async {
    reduceMotion = v;
    await _prefs.setBool(_kReduceMotion, v);
    notifyListeners();
  }

  Future<void> setHaptics(bool v) async {
    haptics = v;
    await _prefs.setBool(_kHaptics, v);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };
    await _prefs.setString(_kThemeMode, s);
    notifyListeners();
  }

  Future<void> setOnboarded(bool v) async {
    onboarded = v;
    await _prefs.setBool(_kOnboarded, v);
    notifyListeners();
  }

  Future<void> setAnimationStyle(FlowAnimationStyle v) async {
    animationStyle = v;
    await _prefs.setString(_kAnimStyle, v.id);
    notifyListeners();
  }

  Future<void> setAccentColor(AccentColor v) async {
    accentColor = v;
    await _prefs.setString(_kAccent, v.id);
    notifyListeners();
  }

  Future<void> setWhiteNoise(WhiteNoise v) async {
    whiteNoise = v;
    await _prefs.setString(_kWhiteNoise, v.id);
    notifyListeners();
  }

  Future<void> setNoiseVolume(double v) async {
    noiseVolume = v.clamp(0.0, 1.0);
    await _prefs.setDouble(_kNoiseVolume, noiseVolume);
    notifyListeners();
  }

  Future<void> setLanguage(String v) async {
    language = (v == 'en' || v == 'zh') ? v : 'system';
    await _prefs.setString(_kLanguage, language);
    notifyListeners();
  }
}
