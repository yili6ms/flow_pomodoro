// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '心流番茄钟';

  @override
  String get welcomeTagline => '进入心流。\n一次只做一件事。';

  @override
  String get chooseFocusDuration => '选择专注时长';

  @override
  String minutesShort(int m) {
    return '$m 分钟';
  }

  @override
  String get begin => '开始';

  @override
  String get homeQuote => '「一次只做一件事。」';

  @override
  String get tasks => '任务';

  @override
  String get stats => '统计';

  @override
  String get statistics => '统计数据';

  @override
  String get settings => '设置';

  @override
  String get noActiveTask => '暂无任务';

  @override
  String get active => '进行中';

  @override
  String get tapToChoose => '点击选择要专注的任务';

  @override
  String get labelFocus => '专注';

  @override
  String get labelBreak => '休息';

  @override
  String get labelRound => '轮次';

  @override
  String get minShort => '分';

  @override
  String get startFocus => '开始专注';

  @override
  String get resumeCurrentSession => '继续当前会话';

  @override
  String animationChangedTo(String label) {
    return '动画:$label';
  }

  @override
  String get intentionEyebrow => '意图';

  @override
  String get intentionPrompt => '本次专注\n你将完成什么?';

  @override
  String get intentionHint => '例如:撰写章节大纲';

  @override
  String get intentionFooter => '专注于任务。让心流沉淀。';

  @override
  String get enterTheFlow => '进入心流';

  @override
  String get endSessionTitle => '结束本次会话?';

  @override
  String get endSessionBody => '本次专注会话仍在进行中。现在离开将结束它,并仅记录已完成的时长。';

  @override
  String get stayFocused => '继续专注';

  @override
  String get endSession => '结束会话';

  @override
  String get animationStyleTooltip => '动画风格';

  @override
  String get whiteNoiseTooltip => '白噪音';

  @override
  String roundN(int n) {
    return '第 $n 轮';
  }

  @override
  String get done => '完成';

  @override
  String get startBreak => '开始休息';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get endLabel => '结束';

  @override
  String get newTaskHint => '新任务';

  @override
  String get noTasksYet => '暂无任务。';

  @override
  String pomodorosCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个番茄',
      zero: '无番茄',
    );
    return '$_temp0';
  }

  @override
  String get today => '今天';

  @override
  String get sessions => '次数';

  @override
  String get total => '总计';

  @override
  String get last7Days => '近 7 天(分钟)';

  @override
  String get focusDistribution => '按时段的专注分布';

  @override
  String get morning => '上午';

  @override
  String get afternoon => '下午';

  @override
  String get evening => '傍晚';

  @override
  String get night => '夜晚';

  @override
  String minutesAgo(int n) {
    return '前$n';
  }

  @override
  String minutesShortFmt(int m) {
    return '$m分';
  }

  @override
  String hoursMinutesShort(int h, int m) {
    return '$h时 $m分';
  }

  @override
  String get recentSessions => '最近的专注';

  @override
  String get noSessionsYet => '还没有专注记录 — 完成或结束一次专注后会出现在这里。';

  @override
  String get sessionEndedEarly => '提前结束';

  @override
  String get sessionCompleted => '已完成';

  @override
  String get sessionUntitled => '专注';

  @override
  String get sectionTimer => '计时器';

  @override
  String get sectionExperience => '体验';

  @override
  String get sectionAnimation => '动画';

  @override
  String get sectionAccentColor => '强调色';

  @override
  String get sectionWhiteNoise => '白噪音';

  @override
  String get sectionLanguage => '语言';

  @override
  String get focusDuration => '专注时长';

  @override
  String get shortBreak => '短休息';

  @override
  String get longBreak => '长休息';

  @override
  String get roundsBeforeLongBreak => '长休息前的轮数';

  @override
  String get autoSwitch => '自动切换阶段';

  @override
  String get autoSwitchSubtitle => '专注结束后自动开始休息';

  @override
  String get reduceMotion => '减少动画';

  @override
  String get haptics => '触感反馈';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '专注或休息结束时提醒';

  @override
  String get notificationsDenied => '系统设置中已关闭通知权限。';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get volume => '音量';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get phaseReady => '就绪';

  @override
  String get phaseFocus => '专注';

  @override
  String get phaseShortBreak => '短休息';

  @override
  String get phaseLongBreak => '长休息';

  @override
  String get animOrb => '光球';

  @override
  String get animWave => '波浪';

  @override
  String get animParticles => '粒子';

  @override
  String get animFireworks => '烟花';

  @override
  String get accentCoral => '珊瑚';

  @override
  String get accentViolet => '紫罗兰';

  @override
  String get accentEmerald => '翠绿';

  @override
  String get accentGold => '金';

  @override
  String get accentSky => '天空';

  @override
  String get accentRose => '玫瑰';

  @override
  String get accentHybrid => '彩虹';

  @override
  String get noiseOff => '关闭';

  @override
  String get noiseWhite => '白噪';

  @override
  String get noisePink => '粉噪';

  @override
  String get noiseBrown => '棕噪';

  @override
  String get noiseRain => '雨声';

  @override
  String get noiseCampfire => '篝火';

  @override
  String get noiseRiver => '溪流';

  @override
  String get noiseOcean => '海洋';
}
