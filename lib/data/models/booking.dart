/// A confirmed booking for the recommended provider.

library;

import '_json.dart';

class Booking {
  const Booking({
    required this.bookingId,
    this.slotStart,
    this.priceEstimate,
    this.status = 'confirmed',
    this.confirmationMessage,
    this.reasoning,
  });

  final String bookingId;
  final String? slotStart; // ISO-8601; UI formats it
  final String? priceEstimate;
  final String status;
  final String? confirmationMessage;
  final String? reasoning;

  /// First 8 chars of the id, upper-cased — the short receipt code.
  String get shortCode => bookingId.isEmpty
      ? '????????'
      : bookingId.substring(0, bookingId.length.clamp(0, 8)).toUpperCase();

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        bookingId: asString(json['booking_id']) ?? '',
        slotStart: asString(json['slot_start']),
        priceEstimate: asString(json['price_estimate']),
        status: asString(json['status']) ?? 'confirmed',
        confirmationMessage: asString(json['confirmation_message']),
        reasoning: asString(json['reasoning']),
      );
}
