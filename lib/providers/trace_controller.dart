/// Owns the live agent-trace lifecycle for one request: SSE stream +
/// a resilient polling fallback + final-result load. The screen just
/// watches [TraceState] — all the orchestration lives here.

library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

class TraceState {
  const TraceState({
    this.events = const [],
    this.isComplete = false,
    this.result,
  });

  final List<TraceEvent> events;
  final bool isComplete;
  final ServiceRequest? result;

  bool get canViewRecommendation => isComplete && result != null;

  TraceState copyWith({
    List<TraceEvent>? events,
    bool? isComplete,
    ServiceRequest? result,
  }) =>
      TraceState(
        events: events ?? this.events,
        isComplete: isComplete ?? this.isComplete,
        result: result ?? this.result,
      );
}

class TraceController extends AutoDisposeFamilyNotifier<TraceState, String> {
  StreamSubscription<TraceEvent>? _sub;
  bool _polling = false;

  @override
  TraceState build(String requestId) {
    ref.onDispose(() => _sub?.cancel());
    // Defer side-effects: _start → _fallbackPoll reads `state`, which must
    // not happen until build() has returned the initial state.
    Future.microtask(() => _start(requestId));
    return const TraceState();
  }

  void _start(String requestId) {
    final repo = ref.read(zimmaRepositoryProvider);

    _sub = repo.traceStream(requestId).listen(
      (event) {
        if (event.isDone) {
          _loadFinal(requestId);
          return;
        }
        state = state.copyWith(events: [...state.events, event]);
      },
      onError: (_) => _fallbackPoll(requestId),
      onDone: () {
        if (!state.isComplete) _fallbackPoll(requestId);
      },
      cancelOnError: true,
    );

    // Also poll in parallel so a dropped SSE never strands the screen.
    _fallbackPoll(requestId);
  }

  Future<void> _loadFinal(String requestId) async {
    try {
      final sr = await ref.read(zimmaRepositoryProvider).getRequest(requestId);
      state = state.copyWith(isComplete: true, result: sr);
    } catch (_) {
      state = state.copyWith(isComplete: true);
    }
  }

  Future<void> _fallbackPoll(String requestId) async {
    if (_polling || state.isComplete) return;
    _polling = true;
    try {
      await for (final sr
          in ref.read(zimmaRepositoryProvider).poll(requestId)) {
        if (sr.state.isTerminal) {
          state = state.copyWith(isComplete: true, result: sr);
          return;
        }
      }
    } finally {
      _polling = false;
    }
  }
}

final traceControllerProvider = NotifierProvider.autoDispose
    .family<TraceController, TraceState, String>(TraceController.new);
