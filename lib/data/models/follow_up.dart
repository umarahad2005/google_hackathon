/// A follow-up lifecycle item (reminder / status / completion / rating).

library;

import '_json.dart';

class FollowUp {
  const FollowUp({
    required this.kind,
    required this.status,
    this.message = '',
  });

  final String kind;
  final String status;
  final String message;

  bool get isDone => status == 'done' || status == 'sent';

  factory FollowUp.fromJson(Map<String, dynamic> json) => FollowUp(
        kind: asString(json['kind']) ?? '',
        status: asString(json['status']) ?? 'scheduled',
        message: asString(json['message']) ?? '',
      );
}
