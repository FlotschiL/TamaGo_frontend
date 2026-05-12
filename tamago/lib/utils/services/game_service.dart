import 'package:tamago/Objects/game_state.dart';
import 'package:tamago/utils/services/api_manager.dart'; // Your ApiClient file

class GameService {
  final ApiClient _client;
  GameService(this._client);

  Future<GameState> getStatus() async {
    final res = await _client.dio.get('/api/tama/status');
    return GameState.fromJson(res.data);
  }

  Future<void> rename(String name) async {
    await _client.dio.post('/api/tama/rename', data: {'name': name});
  }

  Future<GameState> feed(int foodId) async {
      final res = await _client.dio.post('/api/tama/feed/$foodId');
      return GameState.fromJson(res.data);
  }
}