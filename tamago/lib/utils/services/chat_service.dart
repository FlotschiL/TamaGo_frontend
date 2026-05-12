import 'package:tamago/utils/services/api_manager.dart'; // Your ApiClient file
class ChatService {
  final ApiClient _client;
  ChatService(this._client);

  Future<List<dynamic>> getMessages() async {
    final res = await _client.dio.get('/api/chat/history');
    return res.data;
  }

  Future<void> sendMessage(String text) async {
    await _client.dio.post('/api/chat/send', data: {'message': text});
  }
}