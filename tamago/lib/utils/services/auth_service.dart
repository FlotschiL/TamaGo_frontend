import 'package:tamago/utils/services/api_manager.dart'; // Your ApiClient file
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiClient _client;
  final _storage = const FlutterSecureStorage();

  AuthService(this._client);

  Future<bool> login(String username, String password) async {
    final res = await _client.dio.post('/api/auth/login', data: {'username': username, 'password': password});
    if (res.statusCode == 200) {
      await _storage.write(key: 'auth_token', value: res.data['token']);
      return true;
    }
    return false;
  }
  Future<bool> register(String username, String password) async {
      final res = await _client.dio.post('/api/auth/register', 
        data: {'username': username, 'password': password}
      );
      
      if (res.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: res.data['token']);
        return true;
      }
      return false;

  }

  Future<void> logout() async => await _storage.delete(key: 'auth_token');
}