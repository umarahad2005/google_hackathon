/// The service-request envelope returned by the API, plus the nested AI
/// `result` (recommended provider + booking) and the create response.

library;

import '_json.dart';
import 'booking.dart';
import 'follow_up.dart';
import 'recommended_provider.dart';
import 'request_state.dart';

/// Response of `POST /api/requests`.
class CreateRequestResponse {
  const CreateRequestResponse({required this.requestId, required this.state});

  final String requestId;
  final RequestState state;

  factory CreateRequestResponse.fromJson(Map<String, dynamic> json) =>
      CreateRequestResponse(
        requestId: asString(json['request_id']) ?? '',
        state: RequestState.fromWire(asString(json['state'])),
      );
}

/// The nested `result` object — what the agents produced.
class RequestResult {
  const RequestResult({this.recommended, this.booking});

  final RecommendedProvider? recommended;
  final Booking? booking;

  factory RequestResult.fromJson(Map<String, dynamic> json) {
    final rec = json['recommended'];
    final bk = json['booking'];
    return RequestResult(
      recommended: rec is Map
          ? RecommendedProvider.fromJson(Map<String, dynamic>.from(rec))
          : null,
      booking: bk is Map
          ? Booking.fromJson(Map<String, dynamic>.from(bk))
          : null,
    );
  }
}

/// Response of `GET /api/requests/{id}`.
class ServiceRequest {
  const ServiceRequest({
    required this.requestId,
    required this.state,
    this.intent,
    this.result,
    this.traceCount = 0,
    this.createdAt,
    this.followups = const [],
  });

  final String requestId;
  final RequestState state;
  final Object? intent;
  final RequestResult? result;
  final int traceCount;
  final String? createdAt;
  final List<FollowUp> followups;

  RecommendedProvider? get recommended => result?.recommended;
  Booking? get booking => result?.booking;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'];
    return ServiceRequest(
      requestId: asString(json['request_id']) ?? '',
      state: RequestState.fromWire(asString(json['state'])),
      intent: json['intent'],
      result: rawResult is Map
          ? RequestResult.fromJson(Map<String, dynamic>.from(rawResult))
          : null,
      traceCount: asInt(json['trace_count']) ?? 0,
      createdAt: asString(json['created_at']),
      followups: asMapList(json['followups'])
          .map(FollowUp.fromJson)
          .toList(growable: false),
    );
  }
}
