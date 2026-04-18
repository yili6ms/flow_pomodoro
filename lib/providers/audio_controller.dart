import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/white_noise.dart';
import 'settings_provider.dart';
import 'timer_provider.dart';

/// Plays the configured ambient white-noise loop while a focus session is
/// running. Stops automatically on pause / break / idle.
///
/// The controller is intentionally tolerant of audio backend failures
/// (e.g. missing GStreamer plugins on Linux) — playback errors are logged
/// but never thrown, so the rest of the app continues to work.
class AudioController {
  final SettingsProvider settings;
  final TimerProvider timer;
  final AudioPlayer _player;

  WhiteNoise _activeChoice = WhiteNoise.off;
  bool _isPlaying = false;
  bool _disposed = false;

  AudioController({
    required this.settings,
    required this.timer,
    AudioPlayer? player,
  }) : _player = player ?? AudioPlayer(playerId: 'flow.whitenoise') {
    _player.setReleaseMode(ReleaseMode.loop);
    settings.addListener(_sync);
    timer.addListener(_sync);
  }

  /// Re-evaluate desired playback state and reconcile with the player.
  Future<void> _sync() async {
    if (_disposed) return;
    final shouldPlay = timer.isFocus &&
        timer.status == TimerStatus.running &&
        settings.whiteNoise != WhiteNoise.off;

    try {
      // Always keep volume in sync so live slider changes apply immediately.
      await _player.setVolume(settings.noiseVolume);
    } catch (e) {
      _logFail('setVolume', e);
    }

    if (!shouldPlay) {
      if (_isPlaying) {
        try {
          await _player.stop();
        } catch (e) {
          _logFail('stop', e);
        }
        _isPlaying = false;
        _activeChoice = WhiteNoise.off;
      }
      return;
    }

    final choice = settings.whiteNoise;
    if (!_isPlaying || _activeChoice != choice) {
      final asset = choice.assetPath;
      if (asset == null) return;
      try {
        await _player.stop();
        await _player.play(AssetSource(asset), volume: settings.noiseVolume);
        _isPlaying = true;
        _activeChoice = choice;
      } catch (e) {
        _logFail('play(${choice.id})', e);
        _isPlaying = false;
      }
    }
  }

  void _logFail(String op, Object e) {
    if (kDebugMode) {
      debugPrint('AudioController $op failed: $e');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    settings.removeListener(_sync);
    timer.removeListener(_sync);
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
