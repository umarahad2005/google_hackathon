/// The single provider the ranking agent recommends.

library;

import '_json.dart';
import 'score_breakdown.dart';

class RecommendedProvider {
  const RecommendedProvider({
    required this.name,
    required this.category,
    this.rating,
    this.distanceKm,
    this.score,
    required this.scoreBreakdown,
    this.reasoning,
  });

  final String name;
  final String category;
  final double? rating;
  final double? distanceKm;
  final double? score;
  final ScoreBreakdown scoreBreakdown;
  final String? reasoning;

  factory RecommendedProvider.fromJson(Map<String, dynamic> json) =>
      RecommendedProvider(
        name: asString(json['name']) ?? 'Provider',
        category: asString(json['category']) ?? '',
        rating: asDouble(json['rating']),
        distanceKm: asDouble(json['distance_km']),
        score: asDouble(json['score']),
        scoreBreakdown:
            ScoreBreakdown.fromJson(asMap(json['score_breakdown'])),
        reasoning: asString(json['reasoning']),
      );
}
