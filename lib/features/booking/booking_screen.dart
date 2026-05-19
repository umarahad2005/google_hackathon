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
import 'booking_receipt_card.dart';

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
                      BookingReceiptCard(
                        booking: booking,
                        providerName: providerName,
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

}
