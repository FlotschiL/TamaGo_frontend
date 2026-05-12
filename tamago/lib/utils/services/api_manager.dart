import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
class ApiClient {
  late final Dio dio;
  final _storage = const FlutterSecureStorage();
  static const String baseUrl = "http://10.0.2.2:8080";

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Global Auth: Automatically attach token to every outgoing request
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        debugPrint("API Error: ${e.error} | Response: ${e.type}");
        return handler.next(e);
      },
    ));
  }

  // Shared error mapping
  Exception handleError(DioException e) {
    final message = e.response?.data['message'] ?? e.message ?? "Unknown Error";
    return Exception(message);
  }
}