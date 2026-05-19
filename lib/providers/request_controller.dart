/// Submits a new service request. The screen watches this for the
/// loading/error state and calls [submit] which returns the new id.

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

class RequestController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Returns the created request, or null if it failed (error is in [state]).
  Future<CreateRequestResponse?> submit(String message) async {
    if (message.trim().isEmpty) return null;
    state = const AsyncLoading<void>();
    try {
      final res =
          await ref.read(zimmaRepositoryProvider).submitRequest(message);
      state = const AsyncData<void>(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final requestControllerProvider =
    AsyncNotifierProvider<RequestController, void>(RequestController.new);
