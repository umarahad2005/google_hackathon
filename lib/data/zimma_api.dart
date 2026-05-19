/// Typed transport over the FastAPI backend. Every method returns a model
/// (never a raw Map) and throws [ApiException] (never a DioException), so
/// callers and the UI deal with one error type.

library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/network/api_exception.dart';
import 'models/models.dart';

class ZimmaApi {
  ZimmaApi(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/requests — create a service request, returns its id.
  Future<CreateRequestResponse> createRequest({
    required String message,
    String? audioUrl,
    String? userId,
  }) {
    return _guard(() async {
      final res = await _dio.post('/api/requests', data: {
        'message': message,
        'audio_url': audioUrl,
        // Identity comes from the bearer token; only sent if explicitly
        // overridden (kept for tests / non-auth fallback).
        'user_id': ?userId,
      });
      return CreateRequestResponse.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// GET /api/requests/{id} — current state + accumulated result.
  Future<ServiceRequest> getRequest(String requestId) {
    return _guard(() async {
      final res = await _dio.get('/api/requests/$requestId');
      return ServiceRequest.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// GET /api/requests/{id}/trace — SSE stream of agent steps.
  ///
  /// Yields one [TraceEvent] per `data:` line and closes after the
  /// `{"type":"done"}` terminator (also surfaced as a final event).
  Stream<TraceEvent> streamTrace(String requestId) {
    final controller = StreamController<TraceEvent>();

    _dio
        .get<ResponseBody>(
      '/api/requests/$requestId/trace',
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    )
        .then((response) {
      final body = response.data;
      if (body == null) {
        controller.close();
        return;
      }
      var buffer = '';
      body.stream.listen(
        (chunk) {
          buffer += utf8.decode(chunk, allowMalformed: true);
          final lines = buffer.split('\n');
          buffer = lines.removeLast();
          for (final line in lines) {
            if (!line.startsWith('data: ')) continue;
            try {
              final parsed =
                  json.decode(line.substring(6)) as Map<String, dynamic>;
              final event = TraceEvent.fromJson(parsed);
              controller.add(event);
              if (event.isDone) {
                controller.close();
                return;
              }
            } catch (_) {
              // Skip malformed/heartbeat lines.
            }
          }
        },
        onError: (Object e) {
          if (!controller.isClosed) {
            controller.addError(
              e is DioException
                  ? ApiException.fromDio(e)
                  : const ApiException(
                      ApiErrorKind.unknown, 'Trace stream failed.'),
            );
            controller.close();
          }
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
        },
        cancelOnError: true,
      );
    }).catchError((Object e) {
      if (!controller.isClosed) {
        controller.addError(
          e is DioException
              ? ApiException.fromDio(e)
              : const ApiException(
                  ApiErrorKind.unknown, 'Could not open trace stream.'),
        );
        controller.close();
      }
    });

    return controller.stream;
  }

  /// POST /api/requests/{id}/confirm — confirm the recommendation.
  Future<ServiceRequest> confirmRequest(
    String requestId, {
    String? providerId,
  }) {
    return _guard(() async {
      final res = await _dio.post('/api/requests/$requestId/confirm', data: {
        'provider_id': providerId,
        'action': 'accept',
      });
      return ServiceRequest.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// GET /api/bookings/{id}/receipt
  Future<Booking> getReceipt(String bookingId) {
    return _guard(() async {
      final res = await _dio.get('/api/bookings/$bookingId/receipt');
      return Booking.fromJson(Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// GET /api/requests — the caller's past requests (History).
  Future<List<HistoryItem>> listRequests({int limit = 50}) {
    return _guard(() async {
      final res = await _dio.get(
        '/api/requests',
        queryParameters: {'limit': limit},
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      final items = (data['items'] as List? ?? const []);
      return items
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  /// GET /api/profile
  Future<UserProfile> getProfile() {
    return _guard(() async {
      final res = await _dio.get('/api/profile');
      return UserProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// PATCH /api/profile — update display_name / lang_pref.
  Future<UserProfile> updateProfile({
    String? displayName,
    String? langPref,
  }) {
    return _guard(() async {
      final res = await _dio.patch('/api/profile', data: {
        'display_name': ?displayName,
        'lang_pref': ?langPref,
      });
      return UserProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
    });
  }

  /// GET /health
  Future<bool> healthCheck() async {
    try {
      final res = await _dio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
