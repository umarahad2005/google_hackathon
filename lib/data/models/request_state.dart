/// Lifecycle state of a service request, as returned by the backend.

library;

enum RequestState {
  $new('NEW'),
  processing('PROCESSING'),
  recommended('RECOMMENDED'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  followUpScheduled('FOLLOW_UP_SCHEDULED'),
  noProvider('NO_PROVIDER'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const RequestState(this.wire);

  /// The exact string the API uses.
  final String wire;

  static RequestState fromWire(String? value) {
    if (value == null) return RequestState.unknown;
    for (final s in RequestState.values) {
      if (s.wire == value) return s;
    }
    return RequestState.unknown;
  }

  /// Terminal states the trace/poll loops stop on.
  bool get isTerminal => const {
        RequestState.completed,
        RequestState.confirmed,
        RequestState.followUpScheduled,
        RequestState.failed,
        RequestState.noProvider,
      }.contains(this);

  bool get isComplete => this == RequestState.completed;
}
