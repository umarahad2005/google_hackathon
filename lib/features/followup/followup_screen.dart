/// Zimma AI — Follow-Up Status Screen (Screen 5)
///
/// Live follow-up lifecycle. Polling lives in [followupControllerProvider].
/// On top of the timeline, the steps are surfaced as realistic, one-at-a-
/// time notification popups: every ~20s the next step alerts and the user
/// must acknowledge ("Got it") before the next one fires.

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';

/// Seconds between each step's notification popup.
const _stepInterval = Duration(seconds: 20);

class FollowUpScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String bookingId;
  final String providerName;

  const FollowUpScreen({
    super.key,
    required this.requestId,
    required this.bookingId,
    required this.providerName,
  });

  @override
  ConsumerState<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends ConsumerState<FollowUpScreen> {
  static const Map<String, IconData> _kindIcons = {
    'reminder': Icons.alarm_rounded,
    'status': Icons.local_shipping_rounded,
    'completion': Icons.check_circle_rounded,
    'rating_request': Icons.star_rounded,
  };

  static const Map<String, Color> _kindColors = {
    'reminder': ZimmaTheme.warning,
    'status': Color(0xFF3FA9F5),
    'completion': ZimmaTheme.success,
    'rating_request': ZimmaTheme.accent,
  };

  static const Map<String, String> _kindLabels = {
    'reminder': '⏰ Reminder | یاد دہانی',
    'status': '🚗 Status Update | صورتحال',
    'completion': '✅ Completed | مکمل',
    'rating_request': '⭐ Rate Service | درجہ بندی',
  };

  bool _narrativeStarted = false;
  bool _running = false;
  int _shownCount = 0;

  Future<void> _runNarrative(List<FollowUp> followups) async {
    if (_running) return;
    _running = true;
    for (var i = 0; i < followups.length; i++) {
      await Future<void>.delayed(_stepInterval);
      if (!mounted) return;
      await _showStepDialog(followups[i], i + 1, followups.length);
      if (!mounted) return;
      setState(() => _shownCount = i + 1);
    }
  }

  Future<void> _showStepDialog(FollowUp fu, int step, int total) {
    final color = _kindColors[fu.kind] ?? ZimmaTheme.primary;
    final icon = _kindIcons[fu.kind] ?? Icons.notifications_rounded;
    final title = _kindLabels[fu.kind] ?? fu.kind;
    final isRating = fu.kind == 'rating_request';

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // must press to continue ("enter")
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: ZimmaTheme.raised(radius: ZimmaTheme.radiusLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                  boxShadow: ZimmaTheme.glow(color, strength: 0.3),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ZimmaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Step $step of $total · ${widget.providerName}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZimmaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              if (fu.message.isNotEmpty)
                Text(
                  fu.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.55,
                    color: ZimmaTheme.textSecondary,
                  ),
                ),
              const SizedBox(height: 20),
              Pressable(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: ZimmaTheme.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(ZimmaTheme.radiusMd),
                    boxShadow:
                        ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.35),
                  ),
                  child: Text(
                    isRating ? 'Rate & finish' : 'Got it, continue',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(followupControllerProvider(widget.requestId));
    final followups = fs.followups;

    // Kick off the one-at-a-time notification narrative once the
    // follow-up plan is available.
    if (!_narrativeStarted && followups.isNotEmpty) {
      _narrativeStarted = true;
      final snapshot = List<FollowUp>.from(followups);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runNarrative(snapshot);
      });
    }

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
                  widget.providerName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ZimmaTheme.textPrimary,
                  ),
                ),
                Text(
                  isComplete
                      ? '✅ Service Complete'
                      : '⏳ In Progress · step $_shownCount',
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
    // A step is "done" in the UI once its popup has been acknowledged.
    final isDone = index < _shownCount;
    final isActive = index == _shownCount && _shownCount < followups.length;

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
                              : ZimmaTheme.surfaceLight,
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
                            : ZimmaTheme.textSecondary
                                .withValues(alpha: 0.12),
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
                                : ZimmaTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDone
                                ? '✓ Done'
                                : isActive
                                    ? 'Now'
                                    : 'Pending',
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
