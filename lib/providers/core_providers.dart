/// Dependency-injection roots. Everything flows from here: swap the Dio
/// or repository in tests by overriding one provider.

library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../data/zimma_api.dart';
import '../data/zimma_repository.dart';

final dioProvider = Provider<Dio>((ref) => DioClient.create());

final zimmaApiProvider =
    Provider<ZimmaApi>((ref) => ZimmaApi(ref.watch(dioProvider)));

final zimmaRepositoryProvider = Provider<ZimmaRepository>(
  (ref) => ZimmaRepository(ref.watch(zimmaApiProvider)),
);
