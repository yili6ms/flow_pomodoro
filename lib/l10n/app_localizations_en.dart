// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Flow Pomodoro';

  @override
  String get welcomeTagline => 'Enter the flow.\nOne thing at a time.';

  @override
  String get chooseFocusDuration => 'CHOOSE YOUR FOCUS DURATION';

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String get begin => 'Begin';

  @override
  String get homeQuote => '“One thing at a time.”';

  @override
  String get tasks => 'Tasks';

  @override
  String get stats => 'Stats';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get noActiveTask => 'No active task';

  @override
  String get active => 'Active';

  @override
  String get tapToChoose => 'Tap to choose what to focus on';

  @override
  String get labelFocus => 'Focus';

  @override
  String get labelBreak => 'Break';

  @override
  String get labelRound => 'Round';

  @override
  String get minShort => 'min';

  @override
  String get startFocus => 'Start Focus';

  @override
  String get resumeCurrentSession => 'Resume current session';

  @override
  String animationChangedTo(String label) {
    return 'Animation: $label';
  }

  @override
  String get intentionEyebrow => 'INTENTION';

  @override
  String get intentionPrompt => 'What will you do\nin this session?';

  @override
  String get intentionHint => 'e.g. Draft chapter outline';

  @override
  String get intentionFooter => 'Stay with the task. Let focus settle.';

  @override
  String get enterTheFlow => 'Enter the flow';

  @override
  String get endSessionTitle => 'End this session?';

  @override
  String get endSessionBody =>
      'Your focus session is still in progress. Leaving now will end it and record only the time so far.';

  @override
  String get stayFocused => 'Stay focused';

  @override
  String get endSession => 'End session';

  @override
  String get animationStyleTooltip => 'Animation style';

  @override
  String get whiteNoiseTooltip => 'White noise';

  @override
  String roundN(int n) {
    return 'Round $n';
  }

  @override
  String get done => 'Done';

  @override
  String get startBreak => 'Start break';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get endLabel => 'End';

  @override
  String get newTaskHint => 'New task';

  @override
  String get noTasksYet => 'No tasks yet.';

  @override
  String get archivedTasks => 'Archived tasks';

  @override
  String get archiveTask => 'Archive';

  @override
  String get unarchiveTask => 'Restore';

  @override
  String get deleteTask => 'Delete';

  @override
  String pomodorosCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pomodoros',
      one: '1 pomodoro',
      zero: 'No pomodoros',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get sessions => 'Sessions';

  @override
  String get total => 'Total';

  @override
  String get last7Days => 'Last 7 days (minutes)';

  @override
  String get focusDistribution => 'Focus distribution by time of day';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String minutesAgo(int n) {
    return 'M-$n';
  }

  @override
  String minutesShortFmt(int m) {
    return '${m}m';
  }

  @override
  String hoursMinutesShort(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String get noSessionsYet =>
      'No sessions yet — finish or end one to see it here.';

  @override
  String get sessionEndedEarly => 'Ended early';

  @override
  String get sessionCompleted => 'Completed';

  @override
  String get sessionUntitled => 'Focus';

  @override
  String get flowBloomTitle => 'Flow complete';

  @override
  String get flowBloomBody => 'You stayed with one thing.';

  @override
  String sessionSummaryFocusTime(String duration) {
    return 'Focus time: $duration';
  }

  @override
  String get continueToBreak => 'Continue to break';

  @override
  String get sectionTimer => 'Timer';

  @override
  String get sectionExperience => 'Experience';

  @override
  String get sectionAnimation => 'Animation';

  @override
  String get sectionAccentColor => 'Accent color';

  @override
  String get sectionWhiteNoise => 'White noise';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get focusDuration => 'Focus duration';

  @override
  String get shortBreak => 'Short break';

  @override
  String get longBreak => 'Long break';

  @override
  String get roundsBeforeLongBreak => 'Rounds before long break';

  @override
  String get autoSwitch => 'Auto-switch phases';

  @override
  String get autoSwitchSubtitle =>
      'Automatically start break after focus completes';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Alert when focus or break time ends';

  @override
  String get notificationsDenied =>
      'Notifications are disabled in system settings.';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get volume => 'Volume';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get phaseReady => 'Ready';

  @override
  String get phaseFocus => 'Focus';

  @override
  String get phaseShortBreak => 'Short Break';

  @override
  String get phaseLongBreak => 'Long Break';

  @override
  String get animOrb => 'Orb';

  @override
  String get animWave => 'Wave';

  @override
  String get animParticles => 'Particles';

  @override
  String get animFireworks => 'Fireworks';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentEmerald => 'Emerald';

  @override
  String get accentGold => 'Gold';

  @override
  String get accentSky => 'Sky';

  @override
  String get accentRose => 'Rose';

  @override
  String get accentHybrid => 'Hybrid';

  @override
  String get noiseOff => 'Off';

  @override
  String get noiseWhite => 'White';

  @override
  String get noisePink => 'Pink';

  @override
  String get noiseBrown => 'Brown';

  @override
  String get noiseRain => 'Rain';

  @override
  String get noiseCampfire => 'Campfire';

  @override
  String get noiseRiver => 'River';

  @override
  String get noiseOcean => 'Ocean';
}
