import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Flow Pomodoro'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Enter the flow.\nOne thing at a time.'**
  String get welcomeTagline;

  /// No description provided for @chooseFocusDuration.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR FOCUS DURATION'**
  String get chooseFocusDuration;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String minutesShort(int m);

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @homeQuote.
  ///
  /// In en, this message translates to:
  /// **'“One thing at a time.”'**
  String get homeQuote;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noActiveTask.
  ///
  /// In en, this message translates to:
  /// **'No active task'**
  String get noActiveTask;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @tapToChoose.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose what to focus on'**
  String get tapToChoose;

  /// No description provided for @labelFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get labelFocus;

  /// No description provided for @labelBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get labelBreak;

  /// No description provided for @labelRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get labelRound;

  /// No description provided for @minShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minShort;

  /// No description provided for @startFocus.
  ///
  /// In en, this message translates to:
  /// **'Start Focus'**
  String get startFocus;

  /// No description provided for @resumeCurrentSession.
  ///
  /// In en, this message translates to:
  /// **'Resume current session'**
  String get resumeCurrentSession;

  /// No description provided for @animationChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Animation: {label}'**
  String animationChangedTo(String label);

  /// No description provided for @intentionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'INTENTION'**
  String get intentionEyebrow;

  /// No description provided for @intentionPrompt.
  ///
  /// In en, this message translates to:
  /// **'What will you do\nin this session?'**
  String get intentionPrompt;

  /// No description provided for @intentionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Draft chapter outline'**
  String get intentionHint;

  /// No description provided for @intentionFooter.
  ///
  /// In en, this message translates to:
  /// **'Stay with the task. Let focus settle.'**
  String get intentionFooter;

  /// No description provided for @enterTheFlow.
  ///
  /// In en, this message translates to:
  /// **'Enter the flow'**
  String get enterTheFlow;

  /// No description provided for @endSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get endSessionTitle;

  /// No description provided for @endSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Your focus session is still in progress. Leaving now will end it and record only the time so far.'**
  String get endSessionBody;

  /// No description provided for @stayFocused.
  ///
  /// In en, this message translates to:
  /// **'Stay focused'**
  String get stayFocused;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @animationStyleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Animation style'**
  String get animationStyleTooltip;

  /// No description provided for @whiteNoiseTooltip.
  ///
  /// In en, this message translates to:
  /// **'White noise'**
  String get whiteNoiseTooltip;

  /// No description provided for @roundN.
  ///
  /// In en, this message translates to:
  /// **'Round {n}'**
  String roundN(int n);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @startBreak.
  ///
  /// In en, this message translates to:
  /// **'Start break'**
  String get startBreak;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// No description provided for @newTaskHint.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskHint;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get noTasksYet;

  /// No description provided for @archivedTasks.
  ///
  /// In en, this message translates to:
  /// **'Archived tasks'**
  String get archivedTasks;

  /// No description provided for @archiveTask.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTask;

  /// No description provided for @unarchiveTask.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get unarchiveTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTask;

  /// No description provided for @pomodorosCount.
  ///
  /// In en, this message translates to:
  /// **'{n,plural, =0{No pomodoros}=1{1 pomodoro}other{{n} pomodoros}}'**
  String pomodorosCount(int n);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days (minutes)'**
  String get last7Days;

  /// No description provided for @focusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Focus distribution by time of day'**
  String get focusDistribution;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'M-{n}'**
  String minutesAgo(int n);

  /// No description provided for @minutesShortFmt.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String minutesShortFmt(int m);

  /// No description provided for @hoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String hoursMinutesShort(int h, int m);

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet — finish or end one to see it here.'**
  String get noSessionsYet;

  /// No description provided for @sessionEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'Ended early'**
  String get sessionEndedEarly;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionCompleted;

  /// No description provided for @sessionUntitled.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get sessionUntitled;

  /// No description provided for @flowBloomTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow complete'**
  String get flowBloomTitle;

  /// No description provided for @flowBloomBody.
  ///
  /// In en, this message translates to:
  /// **'You stayed with one thing.'**
  String get flowBloomBody;

  /// No description provided for @sessionSummaryFocusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus time: {duration}'**
  String sessionSummaryFocusTime(String duration);

  /// No description provided for @continueToBreak.
  ///
  /// In en, this message translates to:
  /// **'Continue to break'**
  String get continueToBreak;

  /// No description provided for @sectionTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get sectionTimer;

  /// No description provided for @sectionExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get sectionExperience;

  /// No description provided for @sectionAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get sectionAnimation;

  /// No description provided for @sectionAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get sectionAccentColor;

  /// No description provided for @sectionWhiteNoise.
  ///
  /// In en, this message translates to:
  /// **'White noise'**
  String get sectionWhiteNoise;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @focusDuration.
  ///
  /// In en, this message translates to:
  /// **'Focus duration'**
  String get focusDuration;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get longBreak;

  /// No description provided for @roundsBeforeLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Rounds before long break'**
  String get roundsBeforeLongBreak;

  /// No description provided for @autoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Auto-switch phases'**
  String get autoSwitch;

  /// No description provided for @autoSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically start break after focus completes'**
  String get autoSwitchSubtitle;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptics;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert when focus or break time ends'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in system settings.'**
  String get notificationsDenied;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @phaseReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get phaseReady;

  /// No description provided for @phaseFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get phaseFocus;

  /// No description provided for @phaseShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get phaseShortBreak;

  /// No description provided for @phaseLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get phaseLongBreak;

  /// No description provided for @animOrb.
  ///
  /// In en, this message translates to:
  /// **'Orb'**
  String get animOrb;

  /// No description provided for @animWave.
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get animWave;

  /// No description provided for @animParticles.
  ///
  /// In en, this message translates to:
  /// **'Particles'**
  String get animParticles;

  /// No description provided for @animFireworks.
  ///
  /// In en, this message translates to:
  /// **'Fireworks'**
  String get animFireworks;

  /// No description provided for @accentCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get accentCoral;

  /// No description provided for @accentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// No description provided for @accentEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get accentEmerald;

  /// No description provided for @accentGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get accentGold;

  /// No description provided for @accentSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get accentSky;

  /// No description provided for @accentRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get accentRose;

  /// No description provided for @accentHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get accentHybrid;

  /// No description provided for @noiseOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get noiseOff;

  /// No description provided for @noiseWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get noiseWhite;

  /// No description provided for @noisePink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get noisePink;

  /// No description provided for @noiseBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get noiseBrown;

  /// No description provided for @noiseRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get noiseRain;

  /// No description provided for @noiseCampfire.
  ///
  /// In en, this message translates to:
  /// **'Campfire'**
  String get noiseCampfire;

  /// No description provided for @noiseRiver.
  ///
  /// In en, this message translates to:
  /// **'River'**
  String get noiseRiver;

  /// No description provided for @noiseOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get noiseOcean;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
