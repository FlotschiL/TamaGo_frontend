import 'package:flutter/widgets.dart';
import 'package:tamago/Objects/game_state.dart';
import 'package:tamago/utils/services/api_manager.dart'; // Your ApiClient file
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tamago/utils/services/model/foodItem.dart';
class GameService {
  final ApiClient _client;
  GameService(this._client);

  Future<GameState> getStatus() async {
    debugPrint("Fetching game state:");
    debugPrint("${await FlutterSecureStorage().read(key: 'auth_token')}"); // Debug token retrieval
    final res = await _client.dio.get('/api/tama/status');
    debugPrint("Fetched game state: ${res.data}");
    return GameState.fromJson(res.data);
  }

  Future<void> rename(String name) async {
    await _client.dio.post('/api/tama/rename', data: {'name': name});
  }

  Future<bool> feed(int foodId) async {
    final res = await _client.dio.post('/api/tama/feed/$foodId');
    return res.statusCode == 200;
  }

  Future<List<FoodItem>> getFoodInventory() async {
    final res = await _client.dio.get('/api/tama/inventory');
    List<FoodItem> fridgeInventory = [];
    
    if (res.data != null && res.data['food'] != null) {
      final List<dynamic> foodData = res.data['food'];
      fridgeInventory = foodData.map((item) => FoodItem.fromJson(item)).toList();
    }
    return fridgeInventory;
  }

  Future<bool> pet(int placeId) async {
       final res;
      
       debugPrint("Petting place ID: $placeId");
      switch (placeId) {
        case 1:
          res = await _client.dio.post('/api/pet/happyplusstrong');
          break;
        case 2:
          res = await _client.dio.post('/api/pet/happyplusslight');
          break;
        case 3:
          res = await _client.dio.post('/api/pet/happyminus');
          break;
        default:
          throw Exception("Invalid place ID");
      }
    return res.statusCode == 200;
  }
}

