/// Zimma AI — Recommendation Screen (Screen 3)
///
/// The recommended provider with score breakdown, reasoning and a clear
/// "Book" action. Now driven by typed models (no raw maps).

library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../booking/booking_screen.dart';

class RecommendationScreen extends StatelessWidget {
  final ServiceRequest request;

  const RecommendationScreen({super.key, required this.request});

  RecommendedProvider? get _recommended => request.recommended;
  Booking? get _booking => request.booking;

  @override
  Widget build(BuildContext context) {
    final recommended = _recommended;

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
                    Expanded(
                      child: Text(
                        'Recommended for you',
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (recommended != null) ...[
                        Entrance(child: _buildProviderCard(recommended)),
                        const SizedBox(height: ZimmaTheme.space4),
                        Entrance(
                          delay: ZimmaTheme.motionFast,
                          child: _buildScoreBreakdown(recommended),
                        ),
                        const SizedBox(height: ZimmaTheme.space4),
                        Entrance(
                          delay: const Duration(milliseconds: 260),
                          child: _buildReasoningCard(),
                        ),
                      ] else
                        _buildNoResult(),
                    ],
                  ),
                ),
              ),
              if (_booking != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Entrance(child: _buildBookingAction(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(RecommendedProvider p) {
    return DepthCard(
      level: 4,
      glowColor: ZimmaTheme.primary,
      borderColor: ZimmaTheme.primary.withValues(alpha: 0.25),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: ZimmaTheme.primaryGradient,
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusLg),
              boxShadow: ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.35),
            ),
            child: Text(
              '⭐ #1 RECOMMENDED',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            p.name,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ZimmaTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            p.category.replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ZimmaTheme.secondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                icon: Icons.location_on_rounded,
                value: '${p.distanceKm?.toStringAsFixed(1) ?? '?'} km',
                label: 'Distance',
                color: ZimmaTheme.secondary,
              ),
              _StatChip(
                icon: Icons.star_rounded,
                value: p.rating?.toStringAsFixed(1) ?? 'N/A',
                label: 'Rating',
                color: ZimmaTheme.accent,
              ),
              _StatChip(
                icon: Icons.score_rounded,
                value: p.score?.toStringAsFixed(3) ?? '?',
                label: 'AI Score',
                color: ZimmaTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(RecommendedProvider p) {
    final b = p.scoreBreakdown;
    return DepthCard(
      level: 1,
      radius: ZimmaTheme.radiusMd,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ZimmaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _ScoreBar(
            label: 'Distance (40%)',
            value: b.distance,
            color: ZimmaTheme.secondary,
          ),
          const SizedBox(height: 10),
          _ScoreBar(
            label: 'Availability (25%)',
            value: b.availability,
            color: ZimmaTheme.success,
          ),
          const SizedBox(height: 10),
          _ScoreBar(
            label: 'Rating (25%)',
            value: b.rating,
            color: ZimmaTheme.accent,
          ),
          const SizedBox(height: 10),
          _ScoreBar(
            label: 'Price Fit (10%)',
            value: b.priceFit,
            color: ZimmaTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningCard() {
    final reasoning = _recommended?.reasoning;
    final bookingReasoning = _booking?.reasoning;

    return DepthCard(
      level: 1,
      radius: ZimmaTheme.radiusMd,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  size: 18, color: ZimmaTheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Why this provider?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ZimmaTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (reasoning != null) ...[
            const SizedBox(height: 8),
            Text(
              reasoning,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ZimmaTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (bookingReasoning != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    size: 16, color: ZimmaTheme.success),
                const SizedBox(width: 6),
                Text(
                  'Booking',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ZimmaTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              bookingReasoning,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ZimmaTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoResult() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: ZimmaTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No results yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: ZimmaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingAction(BuildContext context) {
    final booking = _booking;
    if (booking == null) return const SizedBox.shrink();

    return Pressable(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BookingScreen(
            requestId: request.requestId,
            booking: booking,
            providerName: _recommended?.name ?? 'Provider',
          ),
        ));
      },
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
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
            const Icon(Icons.check_circle_rounded,
                size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'View Booking',
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(ZimmaTheme.radiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ZimmaTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: ZimmaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: ZimmaTheme.textSecondary,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: ZimmaTheme.motionSlow,
            curve: ZimmaTheme.easeEmphasized,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 7,
            ),
          ),
        ),
      ],
    );
  }
}
