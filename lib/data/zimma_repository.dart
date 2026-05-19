/// Higher-level orchestration over [ZimmaApi]. Controllers depend on this,
/// not on Dio/SSE details. Keeps polling/terminal logic in one place.

library;

import 'models/models.dart';
import 'zimma_api.dart';

class ZimmaRepository {
  ZimmaRepository(this._api);

  final ZimmaApi _api;

  Future<CreateRequestResponse> submitRequest(
    String message, {
    String? audioUrl,
  }) =>
      _api.createRequest(message: message, audioUrl: audioUrl);

  Future<ServiceRequest> getRequest(String requestId) =>
      _api.getRequest(requestId);

  Future<List<HistoryItem>> listRequests({int limit = 50}) =>
      _api.listRequests(limit: limit);

  Future<UserProfile> getProfile() => _api.getProfile();

  Future<UserProfile> updateProfile({String? displayName, String? langPref}) =>
      _api.updateProfile(displayName: displayName, langPref: langPref);

  Stream<TraceEvent> traceStream(String requestId) =>
      _api.streamTrace(requestId);

  /// Polls `getRequest` on an interval, yielding each snapshot. Transient
  /// errors are swallowed (the loop keeps trying). Completes when a
  /// terminal state is reached or [maxAttempts] is exhausted.
  Stream<ServiceRequest> poll(
    String requestId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 30,
  }) async* {
    for (var i = 0; i < maxAttempts; i++) {
      await Future<void>.delayed(interval);
      try {
        final sr = await _api.getRequest(requestId);
        yield sr;
        if (sr.state.isTerminal) return;
      } catch (_) {
        // keep polling
      }
    }
  }
}
