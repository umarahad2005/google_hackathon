/// History + profile data providers (auto-refresh on invalidate).

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

final historyProvider =
    FutureProvider.autoDispose<List<HistoryItem>>((ref) async {
  return ref.watch(zimmaRepositoryProvider).listRequests();
});

final profileProvider =
    FutureProvider.autoDispose<UserProfile>((ref) async {
  return ref.watch(zimmaRepositoryProvider).getProfile();
});
