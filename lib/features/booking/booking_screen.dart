/// Zimma AI — Booking Confirmation Screen (Screen 4)
///
/// Confirmed booking with receipt, bilingual confirmation, and navigation
/// to follow-up. Driven by the typed [Booking] model.

library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../followup/followup_screen.dart';

class BookingScreen extends StatelessWidget {
  final String requestId;
  final Booking booking;
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
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                    const Spacer(),
                    const SizedBox(width: ZimmaTheme.minTouch),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      Entrance(child: _successHeader()),
                      const SizedBox(height: ZimmaTheme.space6),
                      Entrance(
                        delay: ZimmaTheme.motionFast,
                        child: _receiptCard(),
                      ),
                      const SizedBox(height: ZimmaTheme.space4),
                      Entrance(
                        delay: const Duration(milliseconds: 260),
                        child: _confirmationCard(),
                      ),
                      if (booking.reasoning != null) ...[
                        const SizedBox(height: ZimmaTheme.space4),
                        Entrance(
                          delay: const Duration(milliseconds: 340),
                          child: _reasoningCard(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Entrance(child: _trackButton(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ZimmaTheme.success, Color(0xFF2BB673)],
            ),
            borderRadius: BorderRadius.circular(ZimmaTheme.radiusXl),
            boxShadow: ZimmaTheme.glow(ZimmaTheme.success, strength: 0.5),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: ZimmaTheme.space5),
        Text(
          'بکنگ کنفرم',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
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
      ],
    );
  }

  Widget _receiptCard() {
    return DepthCard(
      level: 3,
      borderColor: ZimmaTheme.success.withValues(alpha: 0.22),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'Provider',
            value: providerName,
          ),
          const Divider(color: Colors.white10, height: 24),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: _formatTime(booking.slotStart),
          ),
          const Divider(color: Colors.white10, height: 24),
          _DetailRow(
            icon: Icons.monetization_on_rounded,
            label: 'Estimate',
            value: booking.priceEstimate ?? 'N/A',
          ),
          const Divider(color: Colors.white10, height: 24),
          _DetailRow(
            icon: Icons.receipt_rounded,
            label: 'Booking ID',
            value: booking.shortCode,
          ),
          const Divider(color: Colors.white10, height: 24),
          _DetailRow(
            icon: Icons.verified_rounded,
            label: 'Status',
            value: booking.status.toUpperCase(),
            valueColor: ZimmaTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _confirmationCard() {
    return DepthCard(
      level: 1,
      radius: ZimmaTheme.radiusMd,
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
                  fontWeight: FontWeight.w700,
                  color: ZimmaTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.confirmationMessage ?? '',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: ZimmaTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasoningCard() {
    return DepthCard(
      level: 1,
      radius: ZimmaTheme.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 14, color: ZimmaTheme.primary.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                'AI Reasoning',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ZimmaTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.reasoning ?? '',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: ZimmaTheme.textSecondary.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackButton(BuildContext context) {
    return Pressable(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FollowUpScreen(
            requestId: requestId,
            bookingId: booking.bookingId,
            providerName: providerName,
          ),
        ));
      },
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ZimmaTheme.secondary, Color(0xFF3C9C74)],
          ),
          borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
          boxShadow: ZimmaTheme.glow(ZimmaTheme.secondary, strength: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule_rounded,
                size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Track Service Status',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(timeStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month]} ${dt.year}, '
          '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return timeStr;
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
              fontWeight: FontWeight.w700,
              color: valueColor ?? ZimmaTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
