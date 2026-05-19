/// A single typed error the UI can reason about, mapped from any
/// DioException. Screens show [message]; logs/telemetry can use [kind].

library;

import 'package:dio/dio.dart';

enum ApiErrorKind { network, timeout, server, badResponse, cancelled, unknown }

class ApiException implements Exception {
  const ApiException(this.kind, this.message, {this.statusCode});

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          ApiErrorKind.timeout,
          'The server took too long to respond. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          ApiErrorKind.network,
          'Can\'t reach the server. Check your connection.',
        );
      case DioExceptionType.cancel:
        return const ApiException(ApiErrorKind.cancelled, 'Request cancelled.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final detail = _detail(e.response?.data);
        return ApiException(
          code != null && code >= 500
              ? ApiErrorKind.server
              : ApiErrorKind.badResponse,
          detail ?? 'Request failed (${code ?? 'unknown'}).',
          statusCode: code,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(ApiErrorKind.unknown,
            e.message ?? 'Something went wrong. Please try again.');
    }
  }

  static String? _detail(dynamic data) {
    if (data is Map) {
      final d = data['detail'] ?? data['error'] ?? data['message'];
      if (d != null) return d.toString();
    }
    return null;
  }

  @override
  String toString() => message;
}
