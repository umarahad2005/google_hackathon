/// Weighted score components for a recommended provider (0..1 each).

library;

import '_json.dart';

class ScoreBreakdown {
  const ScoreBreakdown({
    this.distance = 0,
    this.availability = 0,
    this.rating = 0,
    this.priceFit = 0,
  });

  final double distance; // 40%
  final double availability; // 25%
  final double rating; // 25%
  final double priceFit; // 10%

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) => ScoreBreakdown(
        distance: asDouble(json['distance']) ?? 0,
        availability: asDouble(json['availability']) ?? 0,
        rating: asDouble(json['rating']) ?? 0,
        priceFit: asDouble(json['price_fit']) ?? 0,
      );
}
