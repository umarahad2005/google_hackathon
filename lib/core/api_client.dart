/// Zimma AI — API Client
///
/// Dio-based HTTP client for the FastAPI backend.
/// Handles SSE streaming for the live agent trace.

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class ZimmaApiClient {
  final Dio _dio;
  // Change this to your backend URL
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost

  ZimmaApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ));

  /// POST /api/requests — Create a service request
  Future<Map<String, dynamic>> createRequest({
    required String message,
    String? audioUrl,
    String userId = 'demo-user',
  }) async {
    final response = await _dio.post('/api/requests', data: {
      'message': message,
      'audio_url': audioUrl,
      'user_id': userId,
    });
    return response.data;
  }

  /// GET /api/requests/{id} — Get request status
  Future<Map<String, dynamic>> getRequest(String requestId) async {
    final response = await _dio.get('/api/requests/$requestId');
    return response.data;
  }

  /// GET /api/requests/{id}/trace — SSE trace stream
  Stream<Map<String, dynamic>> streamTrace(String requestId) {
    final controller = StreamController<Map<String, dynamic>>();

    _dio
        .get(
          '/api/requests/$requestId/trace',
          options: Options(
            responseType: ResponseType.stream,
            headers: {'Accept': 'text/event-stream'},
          ),
        )
        .then((response) {
      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      stream.listen(
        (data) {
          buffer += utf8.decode(data);
          final lines = buffer.split('\n');
          buffer = lines.removeLast(); // Keep incomplete line in buffer

          for (final line in lines) {
            if (line.startsWith('data: ')) {
              try {
                final jsonStr = line.substring(6);
                final parsed = json.decode(jsonStr) as Map<String, dynamic>;
                controller.add(parsed);

                // Check for completion
                if (parsed['type'] == 'done') {
                  controller.close();
                  return;
                }
              } catch (e) {
                // Skip malformed events
              }
            }
          }
        },
        onError: (e) {
          controller.addError(e);
          controller.close();
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
        },
      );
    }).catchError((e) {
      controller.addError(e);
      controller.close();
    });

    return controller.stream;
  }

  /// POST /api/requests/{id}/confirm
  Future<Map<String, dynamic>> confirmRequest(
    String requestId, {
    String? providerId,
  }) async {
    final response = await _dio.post('/api/requests/$requestId/confirm', data: {
      'provider_id': providerId,
      'action': 'accept',
    });
    return response.data;
  }

  /// GET /api/bookings/{id}/receipt
  Future<Map<String, dynamic>> getReceipt(String bookingId) async {
    final response = await _dio.get('/api/bookings/$bookingId/receipt');
    return response.data;
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
