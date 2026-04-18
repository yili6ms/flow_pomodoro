import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/session.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final today = stats.focusSecondsForDay(DateTime.now());
    final week = stats.last7DaysMinutes();
    final dist = stats.focusDistributionByTime();
    final l = AppLocalizations.of(context);
    final distLabels = [l.morning, l.afternoon, l.evening, l.night];

    final settings = context.watch<SettingsProvider>();
    final accent = context.liveAccent();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.statistics),
        backgroundColor: Colors.transparent,
      ),
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: _Card(
                      label: l.today,
                      value: formatFocusDuration(context, today)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Card(
                      label: l.sessions,
                      value: '${stats.totalCompletedSessions}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Card(
                      label: l.total,
                      value: formatFocusDuration(
                          context, stats.totalFocusSeconds)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l.last7Days,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _BarChart(values: week, labels: [
              l.minutesAgo(6),
              l.minutesAgo(5),
              l.minutesAgo(4),
              l.minutesAgo(3),
              l.minutesAgo(2),
              l.minutesAgo(1),
              l.today,
            ]),
            const SizedBox(height: 24),
            Text(l.focusDistribution,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _BarChart(
              values: dist.map((s) => (s / 60).round()).toList(),
              labels: distLabels,
            ),
            const SizedBox(height: 24),
            Text(l.recentSessions,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _RecentSessionsList(
              sessions: stats.recentSessions(limit: 5),
              accent: accent.primary,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  final List<FocusSession> sessions;
  final Color accent;
  const _RecentSessionsList({required this.sessions, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlowColors.bgDarkSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l.noSessionsYet,
          style: const TextStyle(color: FlowColors.textMuted, fontSize: 13),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: FlowColors.bgDarkSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sessions.length; i++) ...[
            _SessionTile(session: sessions[i], accent: accent),
            if (i < sessions.length - 1)
              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final FocusSession session;
  final Color accent;
  const _SessionTile({required this.session, required this.accent});

  String _timeAgo(BuildContext context, DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = (session.taskTitle != null && session.taskTitle!.isNotEmpty)
        ? session.taskTitle!
        : (session.intent != null && session.intent!.isNotEmpty)
            ? session.intent!
            : l.sessionUntitled;
    final statusColor = session.completed
        ? accent
        : FlowColors.textFaint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: session.completed
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.6),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_timeAgo(context, session.startedAt)} · '
                  '${session.completed ? l.sessionCompleted : l.sessionEndedEarly}',
                  style: const TextStyle(
                      fontSize: 11, color: FlowColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatFocusDuration(context, session.durationSeconds),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final String value;
  const _Card({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  color: FlowColors.textFaint,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  const _BarChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<int>(1, (a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: FlowColors.bgDarkSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(values.length, (i) {
            final v = values[i];
            final h = (v / maxV) * 110;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$v',
                        style: const TextStyle(
                            fontSize: 10, color: FlowColors.textMuted)),
                    const SizedBox(height: 2),
                    Container(
                      height: h.clamp(2.0, 110.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            FlowColors.focusPrimary,
                            FlowColors.focusGlow,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i],
                        style: const TextStyle(
                            fontSize: 10, color: FlowColors.textMuted)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
