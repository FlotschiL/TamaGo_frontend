import 'package:tamago/utils/services/api_manager.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _apiClient.get('/users/$userId');
    return response.data;
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    await _apiClient.post('/users/update', data: userData);
  }
}