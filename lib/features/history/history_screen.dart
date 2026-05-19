/// History tab — the signed-in user's past service requests. Tap any
/// item to re-open its live agent trace + result.

library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../trace/trace_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'History',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ZimmaTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: ZimmaTheme.primary,
                  onRefresh: () async {
                    ref.invalidate(historyProvider);
                    await ref.read(historyProvider.future);
                  },
                  child: async.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: ZimmaTheme.primary),
                    ),
                    error: (e, _) => _Empty(
                      icon: Icons.cloud_off_rounded,
                      title: 'Couldn\'t load history',
                      subtitle: 'Pull down to retry.',
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return _Empty(
                          icon: Icons.inbox_rounded,
                          title: 'No requests yet',
                          subtitle:
                              'Your booked services will appear here.',
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) => _HistoryCard(
                          item: items[i],
                        )
                            .animate()
                            .fadeIn(
                                delay: (40 * i).ms, duration: 320.ms)
                            .slideY(begin: 0.12, end: 0),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({Color bg, Color fg, String label}) _statusStyle(RequestState s) {
  switch (s) {
    case RequestState.completed:
    case RequestState.followUpScheduled:
      return (
        bg: ZimmaTheme.success.withValues(alpha: 0.15),
        fg: ZimmaTheme.success,
        label: 'Completed'
      );
    case RequestState.confirmed:
      return (
        bg: ZimmaTheme.primary.withValues(alpha: 0.15),
        fg: ZimmaTheme.primary,
        label: 'Confirmed'
      );
    case RequestState.recommended:
      return (
        bg: ZimmaTheme.secondary.withValues(alpha: 0.15),
        fg: ZimmaTheme.secondary,
        label: 'Recommended'
      );
    case RequestState.failed:
    case RequestState.noProvider:
      return (
        bg: ZimmaTheme.error.withValues(alpha: 0.15),
        fg: ZimmaTheme.error,
        label: 'Unresolved'
      );
    default:
      return (
        bg: ZimmaTheme.warning.withValues(alpha: 0.15),
        fg: ZimmaTheme.warning,
        label: 'In progress'
      );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final st = _statusStyle(item.state);
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: ZimmaTheme.primaryGradient,
                  borderRadius:
                      BorderRadius.circular(ZimmaTheme.radiusMd),
                ),
                child: const Icon(Icons.handyman_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ZimmaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.providerName ??
                          item.location ??
                          (item.rawMessage ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ZimmaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: st.bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  st.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: st.fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 140),
        Icon(icon, size: 56, color: ZimmaTheme.textSecondary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZimmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ZimmaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
