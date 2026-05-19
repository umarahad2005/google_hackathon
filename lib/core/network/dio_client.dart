/// Single configured Dio instance for the whole app. One place owns the
/// base URL, timeouts and logging — screens never construct HTTP clients.
///
/// Override the backend at build/run time (no code change):
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

library;

import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  DioClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zimma-ai.fastapicloud.dev',
  );

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    // Attach the Supabase access token to every request so the backend
    // can identify the user (multi-tenancy). Read at request time so it
    // always reflects the current session (incl. silent refreshes).
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            dev.log('→ ${options.method} ${options.uri}', name: 'api');
            handler.next(options);
          },
          onResponse: (response, handler) {
            dev.log(
              '← ${response.statusCode} ${response.requestOptions.uri}',
              name: 'api',
            );
            handler.next(response);
          },
          onError: (e, handler) {
            dev.log(
              '× ${e.response?.statusCode ?? e.type} '
              '${e.requestOptions.uri}',
              name: 'api',
            );
            handler.next(e);
          },
        ),
      );
    }

    return dio;
  }

  /// Current Supabase JWT, or null if unconfigured / signed out.
  static String? _accessToken() {
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }
}
