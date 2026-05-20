import 'package:tamago/utils/services/api_manager.dart';

class ChatService {
  final ApiClient _client;
  ChatService(this._client);

  // Holt alle verfügbaren Chat-Sitzungen
  Future<List<dynamic>> getSessions() async {
    final res = await _client.dio.get('/api/chat/sessions');
    return res.data;
  }

  // Erstellt eine neue Sitzung
  Future<Map<String, dynamic>> createSession(String title) async {
    final res = await _client.dio.post('/api/chat/sessions', data: {'title': title});
    return res.data;
  }

  // Lädt die Historie einer spezifischen Sitzung
  Future<List<dynamic>> getSessionHistory(int sessionId) async {
    final res = await _client.dio.get('/api/chat/sessions/$sessionId/history');
    return res.data;
  }

  // Sendet Nachricht an KI und erhält Antwort (wird automatisch gespeichert)
  Future<String> talkToAI(String message, int sessionId) async {
    final res = await _client.dio.post('/api/llm/talk', data: {
      'message': message,
      'sessionId': sessionId,
    });
    return res.data['reply']; // Gibt den "reply" String zurück
  }
}