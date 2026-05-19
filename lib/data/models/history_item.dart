/// One past service request in the History feed (GET /api/requests).

library;

import 'request_state.dart';

class HistoryItem {
  const HistoryItem({
    required this.requestId,
    required this.state,
    this.rawMessage,
    this.serviceType,
    this.location,
    this.providerName,
    this.createdAt,
  });

  final String requestId;
  final RequestState state;
  final String? rawMessage;
  final String? serviceType;
  final String? location;
  final String? providerName;
  final String? createdAt;

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        requestId: (j['request_id'] ?? '').toString(),
        state: RequestState.fromWire(j['state'] as String?),
        rawMessage: j['raw_message'] as String?,
        serviceType: j['service_type'] as String?,
        location: j['location'] as String?,
        providerName: j['provider_name'] as String?,
        createdAt: j['created_at'] as String?,
      );
}
