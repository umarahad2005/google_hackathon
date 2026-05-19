/// Polls a request's follow-up lifecycle every 2s until the service is
/// COMPLETED, then stops. The screen watches [FollowupState].

library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

class FollowupState {
  const FollowupState({this.followups = const [], this.isComplete = false});

  final List<FollowUp> followups;
  final bool isComplete;
}

class FollowupController
    extends AutoDisposeFamilyNotifier<FollowupState, String> {
  Timer? _timer;

  @override
  FollowupState build(String requestId) {
    ref.onDispose(() => _timer?.cancel());
    _load(requestId);
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _load(requestId),
    );
    return const FollowupState();
  }

  Future<void> _load(String requestId) async {
    try {
      final sr = await ref.read(zimmaRepositoryProvider).getRequest(requestId);
      final complete = sr.state.isComplete;
      state = FollowupState(followups: sr.followups, isComplete: complete);
      if (complete) _timer?.cancel();
    } catch (_) {
      // transient — next tick retries
    }
  }
}

final followupControllerProvider = NotifierProvider.autoDispose
    .family<FollowupController, FollowupState, String>(FollowupController.new);
