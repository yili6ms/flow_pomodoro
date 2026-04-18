import 'package:flutter/material.dart';

/// Ambient audio options playable during focus sessions.
enum WhiteNoise {
  off,
  white,
  pink,
  brown,
  rain;

  String get label => switch (this) {
        WhiteNoise.off => 'Off',
        WhiteNoise.white => 'White',
        WhiteNoise.pink => 'Pink',
        WhiteNoise.brown => 'Brown',
        WhiteNoise.rain => 'Rain',
      };

  String get id => switch (this) {
        WhiteNoise.off => 'off',
        WhiteNoise.white => 'white',
        WhiteNoise.pink => 'pink',
        WhiteNoise.brown => 'brown',
        WhiteNoise.rain => 'rain',
      };

  /// Asset path inside the app bundle (null for [off]).
  String? get assetPath => switch (this) {
        WhiteNoise.off => null,
        WhiteNoise.white => 'audio/white.wav',
        WhiteNoise.pink => 'audio/pink.wav',
        WhiteNoise.brown => 'audio/brown.wav',
        WhiteNoise.rain => 'audio/rain.wav',
      };

  IconData get icon => switch (this) {
        WhiteNoise.off => Icons.volume_off_rounded,
        WhiteNoise.white => Icons.blur_on_rounded,
        WhiteNoise.pink => Icons.graphic_eq_rounded,
        WhiteNoise.brown => Icons.waves_rounded,
        WhiteNoise.rain => Icons.water_drop_rounded,
      };

  static WhiteNoise fromId(String? id) => switch (id) {
        'white' => WhiteNoise.white,
        'pink' => WhiteNoise.pink,
        'brown' => WhiteNoise.brown,
        'rain' => WhiteNoise.rain,
        _ => WhiteNoise.off,
      };
}
