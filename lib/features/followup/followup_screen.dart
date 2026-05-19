/// Zimma AI — Follow-Up Status Screen (Screen 5)
///
/// Live follow-up lifecycle. Polling lives in [followupControllerProvider];
/// this screen just watches [FollowupState] and paints it.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';

class FollowUpScreen extends ConsumerWidget {
  final String requestId;
  final String bookingId;
  final String providerName;

  const FollowUpScreen({
    super.key,
    required this.requestId,
    required this.bookingId,
    required this.providerName,
  });

  static const Map<String, IconData> _kindIcons = {
    'reminder': Icons.alarm_rounded,
    'status': Icons.local_shipping_rounded,
    'completion': Icons.check_circle_rounded,
    'rating_request': Icons.star_rounded,
  };

  static const Map<String, Color> _kindColors = {
    'reminder': ZimmaTheme.warning,
    'status': Color(0xFF6FB7E8),
    'completion': ZimmaTheme.success,
    'rating_request': ZimmaTheme.accent,
  };

  static const Map<String, String> _kindLabels = {
    'reminder': '⏰ Reminder | یاد دہانی',
    'status': '🚗 Status Update | صورتحال',
    'completion': '✅ Completed | مکمل',
    'rating_request': '⭐ Rate Service | درجہ بندی',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(followupControllerProvider(requestId));
    final followups = fs.followups;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Row(
                  children: [
                    Pressable(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: ZimmaTheme.minTouch,
                        height: ZimmaTheme.minTouch,
                        alignment: Alignment.center,
                        child:
                            const Icon(Icons.arrow_back_ios_rounded, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Service Status',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: ZimmaTheme.minTouch),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Entrance(child: _providerCard(fs.isComplete)),
              ),
              const SizedBox(height: ZimmaTheme.space5),
              Expanded(
                child: followups.isEmpty
                    ? _loadingState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: followups.length,
                        itemBuilder: (context, index) =>
                            _timelineRow(followups, index),
                      ),
              ),
              if (fs.isComplete)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Entrance(child: _completionBanner()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerCard(bool isComplete) {
    return DepthCard(
      level: 3,
      radius: ZimmaTheme.radiusMd,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: ZimmaTheme.brandGradient,
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusSm),
              boxShadow: ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.3),
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
                  providerName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ZimmaTheme.textPrimary,
                  ),
                ),
                Text(
                  isComplete ? '✅ Service Complete' : '⏳ In Progress…',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? ZimmaTheme.success
                        : ZimmaTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ZimmaTheme.secondary,
            strokeWidth: 2.4,
          ),
          const SizedBox(height: ZimmaTheme.space4),
          Text(
            'Loading follow-ups…',
            style: GoogleFonts.inter(color: ZimmaTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(List<FollowUp> followups, int index) {
    final fu = followups[index];
    final isDone = fu.isDone;
    final isActive =
        !isDone && index == followups.indexWhere((f) => !f.isDone);

    final color = _kindColors[fu.kind] ?? ZimmaTheme.primary;
    final icon = _kindIcons[fu.kind] ?? Icons.circle;
    final isLast = index == followups.length - 1;

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDone
                          ? color.withValues(alpha: 0.2)
                          : isActive
                              ? color.withValues(alpha: 0.28)
                              : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isDone || isActive
                            ? color
                            : color.withValues(alpha: 0.3),
                        width: isDone || isActive ? 1.8 : 1,
                      ),
                      boxShadow: isActive
                          ? ZimmaTheme.glow(color, strength: 0.4)
                          : null,
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : icon,
                      size: 16,
                      color: isDone || isActive
                          ? color
                          : color.withValues(alpha: 0.45),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDone
                            ? color.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DepthCard(
                level: isActive ? 3 : 1,
                radius: ZimmaTheme.radiusMd,
                padding: const EdgeInsets.all(14),
                glowColor: isActive ? color : null,
                borderColor: isDone || isActive
                    ? color.withValues(alpha: 0.28)
                    : Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _kindLabels[fu.kind] ?? fu.kind,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDone || isActive
                                  ? color
                                  : ZimmaTheme.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDone
                                ? color.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDone ? '✓ Done' : fu.status,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? color
                                  : ZimmaTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (fu.message.isNotEmpty && (isDone || isActive)) ...[
                      const SizedBox(height: 8),
                      Text(
                        fu.message,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ZimmaTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _completionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ZimmaTheme.success, Color(0xFF2BB673)],
        ),
        borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
        boxShadow: ZimmaTheme.glow(ZimmaTheme.success, strength: 0.45),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_rounded,
              color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(
            'Service Complete! 🎉',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
