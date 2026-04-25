import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../providers/settings_provider.dart';
import 'notification_scheduler.dart';

class NotificationService implements NotificationScheduler {
  static const _phaseCompleteId = 1001;
  static const _channelId = 'flow_pomodoro_timer';
  static const _channelName = 'Timer alerts';
  static const _channelDescription = 'Focus and break completion alerts';

  final SettingsProvider settings;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService({
    required this.settings,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open Flow Pomodoro',
    );
    const windows = WindowsInitializationSettings(
      appName: 'Flow Pomodoro',
      appUserModelId: 'FlowPomodoro.App',
      guid: '8b4f37f1-4b3a-4d16-a4d7-2e15d46b1e7e',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
        windows: windows,
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await init();
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          true;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final mac = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      return await mac?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          true;
    }

    return true;
  }

  @override
  Future<void> schedulePhaseComplete({
    required NotificationPhase phase,
    required Duration remaining,
  }) async {
    await init();
    await cancelPhaseComplete();
    if (!settings.notificationsEnabled || remaining <= Duration.zero) return;
    if (kIsWeb) return;

    final message = _messageFor(phase);
    final scheduledAt = tz.TZDateTime.now(tz.local).add(remaining);

    await _plugin.zonedSchedule(
      id: _phaseCompleteId,
      title: message.title,
      body: message.body,
      scheduledDate: scheduledAt,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: phase.name,
    );
  }

  @override
  Future<void> cancelPhaseComplete() async {
    if (!_initialized || kIsWeb) return;
    await _plugin.cancel(id: _phaseCompleteId);
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
          defaultActionName: 'Open Flow Pomodoro',
        ),
        windows: WindowsNotificationDetails(
          duration: WindowsNotificationDuration.short,
        ),
      );

  _NotificationMessage _messageFor(NotificationPhase phase) {
    final useZh = settings.language == 'zh';
    return switch (phase) {
      NotificationPhase.focus => useZh
          ? const _NotificationMessage('专注完成', '休息一下，让注意力恢复。')
          : const _NotificationMessage(
              'Focus complete',
              'Take a break and let your attention recover.',
            ),
      NotificationPhase.shortBreak || NotificationPhase.longBreak => useZh
          ? const _NotificationMessage('休息结束', '准备好后，开始下一轮专注。')
          : const _NotificationMessage(
              'Break complete',
              'Start the next focus round when you are ready.',
            ),
      NotificationPhase.idle => useZh
          ? const _NotificationMessage('心流番茄钟', '计时已结束。')
          : const _NotificationMessage('Flow Pomodoro', 'Timer finished.'),
    };
  }
}

class _NotificationMessage {
  final String title;
  final String body;

  const _NotificationMessage(this.title, this.body);
}
