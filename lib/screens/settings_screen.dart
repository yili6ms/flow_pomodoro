import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/accent_color.dart';
import '../models/flow_animation_style.dart';
import '../models/white_noise.dart';
import '../providers/settings_provider.dart';
import '../services/notification_scheduler.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final accent = s.accentColor;
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.settings),
        backgroundColor: Colors.transparent,
      ),
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: s.reduceMotion,
        child: SafeArea(
          child: ListView(
          children: [
            _section(l.sectionTimer),
            _NumberTile(
              label: l.focusDuration,
              value: s.focusMinutes,
              suffix: l.minShort,
              min: 1,
              max: 180,
              onChanged: s.setFocusMinutes,
            ),
            _NumberTile(
              label: l.shortBreak,
              value: s.shortBreakMinutes,
              suffix: l.minShort,
              min: 1,
              max: 60,
              onChanged: s.setShortBreakMinutes,
            ),
            _NumberTile(
              label: l.longBreak,
              value: s.longBreakMinutes,
              suffix: l.minShort,
              min: 1,
              max: 90,
              onChanged: s.setLongBreakMinutes,
            ),
            _NumberTile(
              label: l.roundsBeforeLongBreak,
              value: s.roundsBeforeLongBreak,
              suffix: '',
              min: 2,
              max: 10,
              onChanged: s.setRoundsBeforeLongBreak,
            ),
            SwitchListTile(
              title: Text(l.autoSwitch),
              subtitle: Text(l.autoSwitchSubtitle),
              value: s.autoSwitch,
              onChanged: s.setAutoSwitch,
            ),
            const Divider(),
            _section(l.sectionExperience),
            SwitchListTile(
              title: Text(l.reduceMotion),
              value: s.reduceMotion,
              onChanged: s.setReduceMotion,
            ),
            SwitchListTile(
              title: Text(l.haptics),
              value: s.haptics,
              onChanged: s.setHaptics,
            ),
            SwitchListTile(
              title: Text(l.notifications),
              subtitle: Text(l.notificationsSubtitle),
              value: s.notificationsEnabled,
              onChanged: (enabled) => _setNotifications(
                context: context,
                settings: s,
                enabled: enabled,
              ),
            ),
            ListTile(
              title: Text(l.theme),
              subtitle: Text(_themeLabel(context, s.themeMode)),
              trailing: PopupMenuButton<ThemeMode>(
                onSelected: s.setThemeMode,
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: ThemeMode.system, child: Text(l.themeSystem)),
                  PopupMenuItem(
                      value: ThemeMode.light, child: Text(l.themeLight)),
                  PopupMenuItem(
                      value: ThemeMode.dark, child: Text(l.themeDark)),
                ],
              ),
            ),
            ListTile(
              title: Text(l.sectionLanguage),
              subtitle: Text(_languageLabel(context, s.language)),
              trailing: PopupMenuButton<String>(
                onSelected: s.setLanguage,
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'system', child: Text(l.languageSystem)),
                  PopupMenuItem(
                      value: 'en', child: Text(l.languageEnglish)),
                  PopupMenuItem(
                      value: 'zh', child: Text(l.languageChinese)),
                ],
              ),
            ),
            const Divider(),
            _section(l.sectionAnimation),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FlowAnimationStyle.values.map((style) {
                  final selected = s.animationStyle == style;
                  return ChoiceChip(
                    label: Text(style.localizedLabel(context)),
                    selected: selected,
                    onSelected: (_) => s.setAnimationStyle(style),
                  );
                }).toList(),
              ),
            ),
            _section(l.sectionAccentColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AccentColor.values.map((c) {
                  final selected = s.accentColor == c;
                  final isHybrid = c.isDynamic;
                  return GestureDetector(
                    onTap: () => s.setAccentColor(c),
                    child: Tooltip(
                      message: c.localizedLabel(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isHybrid ? null : c.primary,
                          gradient: isHybrid
                              ? const SweepGradient(
                                  colors: [
                                    Color(0xFFFF5C5C),
                                    Color(0xFFFFB347),
                                    Color(0xFFFFE066),
                                    Color(0xFF6BD968),
                                    Color(0xFF59A8FF),
                                    Color(0xFF8E7CFF),
                                    Color(0xFFE85A8A),
                                    Color(0xFFFF5C5C),
                                  ],
                                )
                              : null,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (selected)
                              BoxShadow(
                                color: c.glow.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            _section(l.sectionWhiteNoise),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WhiteNoise.values.map((n) {
                  final selected = s.whiteNoise == n;
                  return ChoiceChip(
                    avatar: Icon(n.icon, size: 18),
                    label: Text(n.localizedLabel(context)),
                    selected: selected,
                    onSelected: (_) => s.setWhiteNoise(n),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(l.volume),
              subtitle: Slider(
                value: s.noiseVolume,
                onChanged: s.whiteNoise == WhiteNoise.off
                    ? null
                    : s.setNoiseVolume,
              ),
              trailing: Text('${(s.noiseVolume * 100).round()}%'),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${l.appName} · v0.1',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }

  String _themeLabel(BuildContext c, ThemeMode m) {
    final l = AppLocalizations.of(c);
    return switch (m) {
      ThemeMode.system => l.themeSystem,
      ThemeMode.light => l.themeLight,
      ThemeMode.dark => l.themeDark,
    };
  }

  String _languageLabel(BuildContext c, String code) {
    final l = AppLocalizations.of(c);
    return switch (code) {
      'en' => l.languageEnglish,
      'zh' => l.languageChinese,
      _ => l.languageSystem,
    };
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12, letterSpacing: 1.2, color: Colors.grey)),
      );

  Future<void> _setNotifications({
    required BuildContext context,
    required SettingsProvider settings,
    required bool enabled,
  }) async {
    final l = AppLocalizations.of(context);
    final notifications = context.read<NotificationScheduler>();
    if (!enabled) {
      await notifications.cancelPhaseComplete();
      await settings.setNotificationsEnabled(false);
      return;
    }

    final allowed = await notifications.requestPermissions();
    if (!context.mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.notificationsDenied)));
      return;
    }
    await settings.setNotificationsEnabled(true);
  }
}

class _NumberTile extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final int min;
  final int max;
  final Future<void> Function(int) onChanged;

  const _NumberTile({
    required this.label,
    required this.value,
    required this.suffix,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$value${suffix.isEmpty ? '' : ' $suffix'}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
