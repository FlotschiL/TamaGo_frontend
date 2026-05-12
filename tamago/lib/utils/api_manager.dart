import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tamago/Objects/game_state.dart';


class ApiClient {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  // Placeholder for your Base URL
  static const String baseUrl = "http://10.0.2.2:8080";

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
  Future<bool> login(String username, String password) async {
    try {
      late Response res;
      res =  await _dio.post('/api/auth/login', data: {'password': password, 'username': username});
      if (res.statusCode == 200) {
        // Extract the token from your specific JSON structure
        final token = res.data['token']; 
        
        // Persist it securely
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  Future<bool> register(String username,  String password) async {
    try {
      late Response res;
      res =  await _dio.post('/api/auth/register', data: {'username': username, 'password': password});
      if (res.statusCode == 200) {
        // Extract the token from your specific JSON structure
        final token = res.data['token']; 
        
        // Persist it securely
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
      return false;    
      } on DioException catch (e) {
      throw _handleError(e);
    }
  }
    Future<bool> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
      _dio.options.headers.remove('Authorization');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

    Future<GameState> getGameState() async {
    try {
      late Response res;
      final token = await _storage.read(key: 'auth_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      debugPrint("Fetching game state with token: $token");
      res =  await _dio.get('/api/tama/status');
      if(res.statusCode != 200) {
        throw "Failed to fetch game state";
      }
      return GameState.fromJson(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
      Future<GameState> feed(int foodId) async {
    try {
      late Response res;
      final token = await _storage.read(key: 'auth_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      res =  await _dio.post('/api/tama/feed/$foodId');
      if(res.statusCode != 200) {
        throw "Failed to fetch game state";
      }
      return GameState.fromJson(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
    Future<bool> rename(String newName) async {
    try {
      late Response res;
      final token = await _storage.read(key: 'auth_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      res =  await _dio.post('/api/tama/rename', data: {'name': newName});
      if(res.statusCode != 200) {
        return false;
      }
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  // Custom Error Handling
  dynamic _handleError(DioException e) {
    // You can expand this to return custom Exception classes 
    // based on e.response?.statusCode
    debugPrint(e.toString());
    debugPrint(e.response?.data.toString() ?? "No response data");
    return e.message ?? "An unknown error occurred";
  }
}