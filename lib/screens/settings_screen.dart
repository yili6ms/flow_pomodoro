import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/accent_color.dart';
import '../models/flow_animation_style.dart';
import '../models/white_noise.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final accent = s.accentColor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: s.reduceMotion,
        child: SafeArea(
          child: ListView(
          children: [
            _section('Timer'),
            _NumberTile(
              label: 'Focus duration',
              value: s.focusMinutes,
              suffix: 'min',
              min: 1,
              max: 180,
              onChanged: s.setFocusMinutes,
            ),
            _NumberTile(
              label: 'Short break',
              value: s.shortBreakMinutes,
              suffix: 'min',
              min: 1,
              max: 60,
              onChanged: s.setShortBreakMinutes,
            ),
            _NumberTile(
              label: 'Long break',
              value: s.longBreakMinutes,
              suffix: 'min',
              min: 1,
              max: 90,
              onChanged: s.setLongBreakMinutes,
            ),
            _NumberTile(
              label: 'Rounds before long break',
              value: s.roundsBeforeLongBreak,
              suffix: '',
              min: 2,
              max: 10,
              onChanged: s.setRoundsBeforeLongBreak,
            ),
            SwitchListTile(
              title: const Text('Auto-switch phases'),
              subtitle: const Text(
                  'Automatically start break after focus completes'),
              value: s.autoSwitch,
              onChanged: s.setAutoSwitch,
            ),
            const Divider(),
            _section('Experience'),
            SwitchListTile(
              title: const Text('Reduce motion'),
              value: s.reduceMotion,
              onChanged: s.setReduceMotion,
            ),
            SwitchListTile(
              title: const Text('Haptic feedback'),
              value: s.haptics,
              onChanged: s.setHaptics,
            ),
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(_themeLabel(s.themeMode)),
              trailing: PopupMenuButton<ThemeMode>(
                onSelected: s.setThemeMode,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: ThemeMode.system, child: Text('System')),
                  PopupMenuItem(
                      value: ThemeMode.light, child: Text('Light')),
                  PopupMenuItem(
                      value: ThemeMode.dark, child: Text('Dark')),
                ],
              ),
            ),
            const Divider(),
            _section('Animation'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FlowAnimationStyle.values.map((style) {
                  final selected = s.animationStyle == style;
                  return ChoiceChip(
                    label: Text(style.label),
                    selected: selected,
                    onSelected: (_) => s.setAnimationStyle(style),
                  );
                }).toList(),
              ),
            ),
            _section('Accent color'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AccentColor.values.map((c) {
                  final selected = s.accentColor == c;
                  return GestureDetector(
                    onTap: () => s.setAccentColor(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.primary,
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
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            _section('White noise'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WhiteNoise.values.map((n) {
                  final selected = s.whiteNoise == n;
                  return ChoiceChip(
                    avatar: Icon(n.icon, size: 18),
                    label: Text(n.label),
                    selected: selected,
                    onSelected: (_) => s.setWhiteNoise(n),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('Volume'),
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
                'Flow Pomodoro · v0.1',
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

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12, letterSpacing: 1.2, color: Colors.grey)),
      );
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
