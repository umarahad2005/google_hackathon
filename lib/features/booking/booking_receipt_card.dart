/// Zimma AI — Booking Receipt Card.
///
/// A ticket-styled receipt that visually proves the agent executed a real
/// (simulated) booking action: perforated edge, deterministic barcode,
/// and a CONFIRMED stamp. Pops in via flutter_animate.

library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';

class BookingReceiptCard extends StatelessWidget {
  final Booking booking;
  final String providerName;

  const BookingReceiptCard({
    super.key,
    required this.booking,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: ZimmaTheme.card,
        borderRadius: BorderRadius.circular(ZimmaTheme.radiusLg),
        border: Border.all(
          color: ZimmaTheme.success.withValues(alpha: 0.22),
        ),
        boxShadow: ZimmaTheme.glow(ZimmaTheme.success, strength: 0.18),
      ),
      child: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              children: [
                _row(Icons.person_rounded, 'Provider', providerName),
                _row(Icons.access_time_rounded, 'Time',
                    _formatTime(booking.slotStart)),
                _row(Icons.monetization_on_rounded, 'Estimate',
                    booking.priceEstimate ?? 'N/A'),
              ],
            ),
          ),
          // Perforated tear line with side notches.
          SizedBox(
            height: 24,
            child: CustomPaint(
              size: const Size(double.infinity, 24),
              painter: _PerforationPainter(),
            ),
          ),
          _barcodeSection(),
        ],
      ),
    );

    // Pop-in: scale + fade so judges see the action "land".
    return card
        .animate()
        .fadeIn(duration: 360.ms, curve: Curves.easeOut)
        .scaleXY(
          begin: 0.88,
          end: 1.0,
          duration: 480.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZimmaTheme.success.withValues(alpha: 0.14),
            ZimmaTheme.success.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ZimmaTheme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ZimmaTheme.success, Color(0xFF2BB673)],
              ),
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusSm),
            ),
            child: const Icon(Icons.confirmation_number_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zimma Booking Receipt',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ZimmaTheme.textPrimary,
                  ),
                ),
                Text(
                  'بکنگ رسید',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: ZimmaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ZimmaTheme.success.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: ZimmaTheme.success.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: ZimmaTheme.success),
                const SizedBox(width: 5),
                Text(
                  booking.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: ZimmaTheme.success,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Icon(icon, size: 17, color: ZimmaTheme.textSecondary),
          const SizedBox(width: 11),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ZimmaTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ZimmaTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarcodePainter(seed: booking.bookingId),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BOOKING ID  ·  ${booking.shortCode}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ZimmaTheme.textPrimary,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(timeStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month]} ${dt.year}, '
          '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return timeStr;
    }
  }
}

/// Dashed tear line with two semicircular side notches — the "ticket" cut.
class _PerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const notchR = 11.0;
    final cy = size.height / 2;

    // Side notches (punch the card edges).
    final notch = Paint()
      ..color = ZimmaTheme.bgDeep
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, cy), notchR, notch);
    canvas.drawCircle(Offset(size.width, cy), notchR, notch);

    // Dashed line between the notches.
    final dash = Paint()
      ..color = ZimmaTheme.textSecondary.withValues(alpha: 0.35)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dashW = 6.0;
    const gap = 5.0;
    double x = notchR + 6;
    final endX = size.width - notchR - 6;
    while (x < endX) {
      canvas.drawLine(Offset(x, cy), Offset(x + dashW, cy), dash);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Deterministic faux-barcode generated from the booking id — no external
/// package, but every booking renders a unique, stable pattern.
class _BarcodePainter extends CustomPainter {
  final String seed;
  const _BarcodePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    // Stable hash → PRNG so the same booking always looks identical.
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final rng = math.Random(h == 0 ? 42 : h);

    final paint = Paint()..color = ZimmaTheme.textPrimary;
    double x = 0;
    while (x < size.width) {
      final w = 1.5 + rng.nextInt(4) * 1.2; // bar width
      final tall = rng.nextBool();
      final barH = tall ? size.height : size.height * 0.72;
      canvas.drawRect(
        Rect.fromLTWH(x, (size.height - barH) / 2, w, barH),
        paint,
      );
      x += w + (1.5 + rng.nextInt(3) * 1.1); // gap
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => old.seed != seed;
}
