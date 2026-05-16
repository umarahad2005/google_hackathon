/// Zimma AI — Follow-Up Status Screen (Screen 5)
///
/// Shows the live follow-up lifecycle: reminder → en_route →
/// in_progress → completed → rating. Powered by Supabase Realtime.
///
/// Priority: #5 per agents/skills/flutter-feature.md

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';

class FollowUpScreen extends StatefulWidget {
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
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final ZimmaApiClient _api = ZimmaApiClient();
  List<Map<String, dynamic>> _followups = [];
  Timer? _pollTimer;
  bool _isComplete = false;

  static const Map<String, IconData> _kindIcons = {
    'reminder': Icons.alarm_rounded,
    'status': Icons.local_shipping_rounded,
    'completion': Icons.check_circle_rounded,
    'rating_request': Icons.star_rounded,
  };

  static const Map<String, Color> _kindColors = {
    'reminder': Color(0xFFFF9800),
    'status': Color(0xFF2196F3),
    'completion': ZimmaTheme.success,
    'rating_request': Color(0xFFFFD700),
  };

  static const Map<String, String> _kindLabels = {
    'reminder': '⏰ Reminder | یاد دہانی',
    'status': '🚗 Status Update | صورتحال',
    'completion': '✅ Completed | مکمل',
    'rating_request': '⭐ Rate Service | درجہ بندی',
  };

  @override
  void initState() {
    super.initState();
    _loadFollowups();
    // Poll for updates every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadFollowups();
    });
  }

  Future<void> _loadFollowups() async {
    try {
      final result = await _api.getRequest(widget.requestId);
      final followups = result['followups'] as List? ?? [];
      final state = result['state'] as String? ?? '';

      if (mounted) {
        setState(() {
          _followups = followups.cast<Map<String, dynamic>>();
          _isComplete = state == 'COMPLETED';
        });

        if (_isComplete) {
          _pollTimer?.cancel();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZimmaTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Service Status',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Provider card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: ZimmaTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: ZimmaTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
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
                              fontWeight: FontWeight.w600,
                              color: ZimmaTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _isComplete
                                ? '✅ Service Complete'
                                : '⏳ In Progress...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _isComplete
                                  ? ZimmaTheme.success
                                  : ZimmaTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Follow-up timeline
              Expanded(
                child: _followups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: ZimmaTheme.secondary,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading follow-ups...',
                              style: GoogleFonts.inter(
                                color: ZimmaTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _followups.length,
                        itemBuilder: (context, index) {
                          final fu = _followups[index];
                          final kind = fu['kind'] as String? ?? '';
                          final status = fu['status'] as String? ?? 'scheduled';
                          final message = fu['message'] as String? ?? '';
                          final isDone = status == 'done' || status == 'sent';
                          final isActive = !isDone && index == _followups
                              .indexWhere((f) =>
                                  f['status'] != 'done' && f['status'] != 'sent');

                          final color = _kindColors[kind] ?? ZimmaTheme.primary;
                          final icon = _kindIcons[kind] ?? Icons.circle;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline connector
                                SizedBox(
                                  width: 40,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isDone
                                              ? color.withValues(alpha: 0.2)
                                              : isActive
                                                  ? color.withValues(alpha: 0.3)
                                                  : Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isDone ? color : color.withValues(alpha: 0.3),
                                            width: isDone ? 2 : 1,
                                          ),
                                        ),
                                        child: Icon(
                                          isDone ? Icons.check_rounded : icon,
                                          size: 16,
                                          color: isDone
                                              ? color
                                              : color.withValues(alpha: isDone || isActive ? 1.0 : 0.4),
                                        ),
                                      ),
                                      if (index < _followups.length - 1)
                                        Container(
                                          width: 2,
                                          height: 30,
                                          color: isDone
                                              ? color.withValues(alpha: 0.3)
                                              : Colors.white.withValues(alpha: 0.05),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Content
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? color.withValues(alpha: 0.05)
                                          : isActive
                                              ? color.withValues(alpha: 0.08)
                                              : ZimmaTheme.card.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDone
                                            ? color.withValues(alpha: 0.2)
                                            : isActive
                                                ? color.withValues(alpha: 0.3)
                                                : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _kindLabels[kind] ?? kind,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDone || isActive
                                                      ? color
                                                      : ZimmaTheme.textSecondary,
                                                ),
                                              ),
                                            ),
                                            // Status badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDone
                                                    ? color.withValues(alpha: 0.15)
                                                    : isActive
                                                        ? Colors.white.withValues(alpha: 0.08)
                                                        : Colors.white.withValues(alpha: 0.03),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isDone ? '✓ Done' : status,
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDone
                                                      ? color
                                                      : ZimmaTheme.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Message
                                        if (message.isNotEmpty &&
                                            (isDone || isActive)) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            message,
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
                          );
                        },
                      ),
              ),

              // Completion banner
              if (_isComplete)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ZimmaTheme.success, Color(0xFF00C853)],
                    ),
                    borderRadius: BorderRadius.circular(14),
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
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
