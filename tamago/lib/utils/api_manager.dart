import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late Dio _dio;

  // Placeholder for your Base URL
  static const String baseUrl = "http://localhost:8080";

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    // Add our Auth & Logging Interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  // --- AUTH MANAGEMENT ---
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Fetch your token from local storage (SecureStorage, SharedPreferences, etc.)
        String? token = null; 

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // TODO: Handle Token Refresh logic or redirect to Login
          print("Unauthorized - Token expired or invalid");
        }
        return handler.next(e);
      },
    );
  }

  // --- DYNAMIC REQUEST METHODS ---

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  Future<bool> login(String username,  String password) async {
    try {
      late Response res;
      res =  await _dio.post('/login', queryParameters: {'username': username, 'password': password});
      return res.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  Future<bool> register(String username,  String password) async {
    try {
      late Response res;
      res =  await _dio.post('/register', data: {'username': username, 'password': password});
      return res.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Custom Error Handling
  dynamic _handleError(DioException e) {
    // You can expand this to return custom Exception classes 
    // based on e.response?.statusCode
    debugPrint(e.toString());
    return e.message ?? "An unknown error occurred";
  }
}