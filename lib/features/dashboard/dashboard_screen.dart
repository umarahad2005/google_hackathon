/// Dashboard (Home tab) — greeting, gamified progress (level/XP, streak,
/// badges), at-a-glance stats, recent activity, and the primary CTA.

library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../shell/home_shell.dart';
import '../trace/trace_screen.dart';

class _Stats {
  _Stats(List<HistoryItem> items) {
    total = items.length;
    completed = items
        .where((i) =>
            i.state == RequestState.completed ||
            i.state == RequestState.followUpScheduled)
        .length;
    final now = DateTime.now();
    thisWeek = items.where((i) {
      final d = DateTime.tryParse(i.createdAt ?? '');
      return d != null && now.difference(d).inDays < 7;
    }).length;

    // Streak: consecutive days (incl. today/yesterday) with ≥1 request.
    final days = <DateTime>{};
    for (final i in items) {
      final d = DateTime.tryParse(i.createdAt ?? '');
      if (d != null) days.add(DateTime(d.year, d.month, d.day));
    }
    var s = 0;
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (days.contains(cursor)) {
      s++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    streak = s;

    xp = completed * 100 + total * 25;
    level = 1 + xp ~/ 500;
    xpInLevel = xp % 500;
  }

  late final int total;
  late final int completed;
  late final int thisWeek;
  late final int streak;
  late final int xp;
  late final int level;
  late final int xpInLevel;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final profile = ref.watch(profileProvider);
    final name = profile.maybeWhen(
      data: (p) => p.displayName,
      orElse: () => 'there',
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: ZimmaTheme.primary,
            onRefresh: () async {
              ref.invalidate(historyProvider);
              ref.invalidate(profileProvider);
              await ref.read(historyProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                Row(
                  children: [
                    const ZimmaLogo(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salaam, $name 👋',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ZimmaTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'What do you need done today?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ZimmaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 360.ms).slideY(begin: -0.15),
                const SizedBox(height: 20),
                history.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: ZimmaTheme.primary)),
                  ),
                  error: (_, _) => _body(context, ref, _Stats(const []),
                      const []),
                  data: (items) =>
                      _body(context, ref, _Stats(items), items),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, _Stats s,
      List<HistoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LevelCard(s: s)
            .animate()
            .fadeIn(delay: 80.ms, duration: 360.ms)
            .slideY(begin: 0.12),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    'Requests', '${s.total}', Icons.bolt_rounded,
                    ZimmaTheme.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard('Completed', '${s.completed}',
                    Icons.verified_rounded, ZimmaTheme.success)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard('This week', '${s.thisWeek}',
                    Icons.calendar_today_rounded, ZimmaTheme.secondary)),
          ],
        ).animate().fadeIn(delay: 160.ms, duration: 360.ms),
        const SizedBox(height: 14),
        _Badges(s: s)
            .animate()
            .fadeIn(delay: 220.ms, duration: 360.ms),
        const SizedBox(height: 16),
        Pressable(
          onTap: () => ref.read(homeTabProvider.notifier).state = 1,
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: ZimmaTheme.brandGradient,
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusLg),
              boxShadow:
                  ZimmaTheme.glow(ZimmaTheme.accent, strength: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Start a new request',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 280.ms).scale(
            begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
        const SizedBox(height: 24),
        Text(
          'Recent activity',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: ZimmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            'No activity yet — your bookings will show here.',
            style: GoogleFonts.inter(
                fontSize: 13, color: ZimmaTheme.textSecondary),
          )
        else
          ...items.take(3).map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentRow(item: it),
              )),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.s});
  final _Stats s;

  @override
  Widget build(BuildContext context) {
    final progress = s.xpInLevel / 500.0;
    return DepthCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: ZimmaTheme.brandGradient,
                    borderRadius:
                        BorderRadius.circular(ZimmaTheme.radiusMd),
                  ),
                  child: Text(
                    '${s.level}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${s.level}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ZimmaTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${s.xp} XP · ${500 - s.xpInLevel} XP to next',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ZimmaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: ZimmaTheme.accent, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${s.streak}d',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ZimmaTheme.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: ZimmaTheme.motionSlow,
                curve: ZimmaTheme.easeEmphasized,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 9,
                  backgroundColor:
                      ZimmaTheme.primary.withValues(alpha: 0.14),
                  valueColor:
                      const AlwaysStoppedAnimation(ZimmaTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: ZimmaTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ZimmaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.s});
  final _Stats s;

  @override
  Widget build(BuildContext context) {
    final badges = <(IconData, String, bool)>[
      (Icons.flag_rounded, 'First job', s.total >= 1),
      (Icons.repeat_rounded, 'Regular', s.total >= 5),
      (Icons.workspace_premium_rounded, 'Power user', s.total >= 15),
      (Icons.emoji_events_rounded, 'Finisher', s.completed >= 3),
    ];
    return DepthCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ZimmaTheme.primary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (ic, lbl, unlocked) in badges)
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: unlocked
                              ? ZimmaTheme.brandGradient
                              : null,
                          color: unlocked
                              ? null
                              : ZimmaTheme.surfaceLight,
                        ),
                        child: Icon(
                          ic,
                          color: unlocked
                              ? Colors.white
                              : ZimmaTheme.textSecondary
                                  .withValues(alpha: 0.5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lbl,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: unlocked
                              ? ZimmaTheme.textPrimary
                              : ZimmaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final title = (item.serviceType ?? 'Service')
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase());
    return Pressable(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TraceScreen(
            requestId: item.requestId,
            message: item.rawMessage ?? title,
          ),
        ),
      ),
      child: DepthCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: ZimmaTheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title${item.providerName != null ? ' · ${item.providerName}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZimmaTheme.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: ZimmaTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
