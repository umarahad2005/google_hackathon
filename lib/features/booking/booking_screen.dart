/// Zimma AI — Booking Confirmation Screen (Screen 4)
///
/// Shows confirmed booking with receipt, bilingual confirmation,
/// and navigation to follow-up status.
///
/// Priority: #4 per agents/skills/flutter-feature.md

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../followup/followup_screen.dart';

class BookingScreen extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> booking;
  final String providerName;

  const BookingScreen({
    super.key,
    required this.requestId,
    required this.booking,
    required this.providerName,
  });

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Success animation
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ZimmaTheme.success, Color(0xFF00C853)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ZimmaTheme.success.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'بکنگ کنفرم',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ZimmaTheme.success,
                        ),
                      ),
                      Text(
                        'Booking Confirmed!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: ZimmaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Booking details card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: ZimmaTheme.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ZimmaTheme.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: Icons.person_rounded,
                              label: 'Provider',
                              value: providerName,
                            ),
                            const Divider(
                              color: Colors.white10,
                              height: 24,
                            ),
                            _DetailRow(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: _formatTime(booking['slot_start']),
                            ),
                            const Divider(
                              color: Colors.white10,
                              height: 24,
                            ),
                            _DetailRow(
                              icon: Icons.monetization_on_rounded,
                              label: 'Estimate',
                              value: booking['price_estimate'] ?? 'N/A',
                            ),
                            const Divider(
                              color: Colors.white10,
                              height: 24,
                            ),
                            _DetailRow(
                              icon: Icons.receipt_rounded,
                              label: 'Booking ID',
                              value: (booking['booking_id'] ?? '').toString().substring(0, 8).toUpperCase(),
                            ),
                            const Divider(
                              color: Colors.white10,
                              height: 24,
                            ),
                            _DetailRow(
                              icon: Icons.verified_rounded,
                              label: 'Status',
                              value: (booking['status'] ?? 'confirmed').toString().toUpperCase(),
                              valueColor: ZimmaTheme.success,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirmation message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ZimmaTheme.card.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ZimmaTheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.message_rounded,
                                    size: 16, color: ZimmaTheme.secondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirmation Message',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ZimmaTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              booking['confirmation_message'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: ZimmaTheme.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reasoning
                      if (booking['reasoning'] != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ZimmaTheme.card.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 14,
                                      color: ZimmaTheme.primary.withValues(alpha: 0.7)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI Reasoning',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: ZimmaTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                booking['reasoning'].toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ZimmaTheme.textSecondary.withValues(alpha: 0.7),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Follow-up button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FollowUpScreen(
                            requestId: requestId,
                            bookingId: booking['booking_id'] ?? '',
                            providerName: providerName,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.schedule_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Track Service Status',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  String _formatTime(dynamic timeStr) {
    if (timeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(timeStr.toString());
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month]} ${dt.year}, $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return timeStr.toString();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ZimmaTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ZimmaTheme.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? ZimmaTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
