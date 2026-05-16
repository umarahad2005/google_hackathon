/// Zimma AI — Recommendation Screen (Screen 3)
///
/// Shows the recommended provider with score breakdown,
/// reasoning, alternatives, and "Book Now" action.
///
/// Priority: #3 per agents/skills/flutter-feature.md

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../booking/booking_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> result;

  const RecommendationScreen({
    super.key,
    required this.requestId,
    required this.result,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final ZimmaApiClient _api = ZimmaApiClient();
  bool _isBooking = false;

  Map<String, dynamic>? get _recommended {
    final result = widget.result['result'];
    if (result is Map) return result['recommended'] as Map<String, dynamic>?;
    return null;
  }

  Map<String, dynamic>? get _booking {
    final result = widget.result['result'];
    if (result is Map) return result['booking'] as Map<String, dynamic>?;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _recommended;

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
                    Expanded(
                      child: Text(
                        'Recommended for you',
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (recommended != null) ...[
                        // Provider card
                        _buildProviderCard(recommended),
                        const SizedBox(height: 16),
                        // Score breakdown
                        _buildScoreBreakdown(recommended),
                        const SizedBox(height: 16),
                        // Reasoning
                        _buildReasoningCard(),
                      ] else
                        _buildNoResult(),
                    ],
                  ),
                ),
              ),

              // Book Now button
              if (_booking != null) _buildBookingAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final rating = provider['rating'];
    final distance = provider['distance_km'];
    final score = provider['score'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ZimmaTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ZimmaTheme.secondary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ZimmaTheme.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rank badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: ZimmaTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⭐ #1 RECOMMENDED',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Provider name
          Text(
            provider['name'] ?? 'Provider',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ZimmaTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            (provider['category'] ?? '').toString().replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ZimmaTheme.secondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                icon: Icons.location_on_rounded,
                value: '${distance?.toStringAsFixed(1) ?? '?'} km',
                label: 'Distance',
                color: const Color(0xFF00BCD4),
              ),
              _StatChip(
                icon: Icons.star_rounded,
                value: rating?.toStringAsFixed(1) ?? 'N/A',
                label: 'Rating',
                color: const Color(0xFFFFD700),
              ),
              _StatChip(
                icon: Icons.score_rounded,
                value: score?.toStringAsFixed(3) ?? '?',
                label: 'AI Score',
                color: ZimmaTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(Map<String, dynamic> provider) {
    final breakdown = provider['score_breakdown'] as Map<String, dynamic>? ?? {};

    return Container(
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
          Text(
            'Score Breakdown',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZimmaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _ScoreBar(
            label: 'Distance (40%)',
            value: (breakdown['distance'] as num?)?.toDouble() ?? 0,
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(height: 8),
          _ScoreBar(
            label: 'Availability (25%)',
            value: (breakdown['availability'] as num?)?.toDouble() ?? 0,
            color: ZimmaTheme.success,
          ),
          const SizedBox(height: 8),
          _ScoreBar(
            label: 'Rating (25%)',
            value: (breakdown['rating'] as num?)?.toDouble() ?? 0,
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 8),
          _ScoreBar(
            label: 'Price Fit (10%)',
            value: (breakdown['price_fit'] as num?)?.toDouble() ?? 0,
            color: ZimmaTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningCard() {
    final result = widget.result['result'];
    final reasoning = result is Map ? result['recommended']?['reasoning'] : null;
    // Also check for booking reasoning
    final bookingReasoning = result is Map
        ? result['booking']?['reasoning']
        : null;

    return Container(
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
              const Icon(Icons.psychology_rounded,
                  size: 18, color: ZimmaTheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Why this provider?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZimmaTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (reasoning != null) ...[
            const SizedBox(height: 8),
            Text(
              reasoning.toString(),
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
                    fontWeight: FontWeight.w600,
                    color: ZimmaTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              bookingReasoning.toString(),
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
    return Center(
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
    );
  }

  Widget _buildBookingAction() {
    final booking = _booking;
    if (booking == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ZimmaTheme.success, Color(0xFF00C853)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ZimmaTheme.success.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BookingScreen(
                  requestId: widget.requestId,
                  booking: booking,
                  providerName: _recommended?['name'] ?? 'Provider',
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
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'View Booking',
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
