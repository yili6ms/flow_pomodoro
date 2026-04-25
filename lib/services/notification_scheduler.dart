enum NotificationPhase { idle, focus, shortBreak, longBreak }

extension NotificationPhaseLabel on NotificationPhase {
  bool get isBreak =>
      this == NotificationPhase.shortBreak || this == NotificationPhase.longBreak;
}

abstract class NotificationScheduler {
  Future<void> init();

  Future<bool> requestPermissions();

  Future<void> schedulePhaseComplete({
    required NotificationPhase phase,
    required Duration remaining,
  });

  Future<void> cancelPhaseComplete();
}

class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> schedulePhaseComplete({
    required NotificationPhase phase,
    required Duration remaining,
  }) async {}

  @override
  Future<void> cancelPhaseComplete() async {}
}
