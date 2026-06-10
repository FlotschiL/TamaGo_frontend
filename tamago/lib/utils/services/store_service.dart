import 'package:tamago/utils/services/api_manager.dart';

class StoreService {
  final ApiClient _client;
  StoreService(this._client);

  // GET /api/shop/items
  Future<Map<String, dynamic>> getShopAssortment() async {
    final res = await _client.dio.get('/api/shop/items');
    return res.data; // Contains "food" and "potions" lists
  }

  // GET /api/tama/inventory
  Future<int> getBalance() async {
    final res = await _client.dio.get('/api/tama/inventory');
    return res.data['balance'] ?? 0;
  }

  // GET /api/tama/inventory (Extracting food items list for the Kitchen)
  Future<List<dynamic>> getFoodInventory() async {
    final res = await _client.dio.get('/api/tama/inventory');
    return res.data['food'] ?? [];
  }

  // POST /api/shop/buy/food
  Future<int> buyFood(String name, int price, int saturation) async {
    final res = await _client.dio.post('/api/shop/buy/food', data: {
      "name": name,
      "price": price,
      "saturation": saturation,
    });
    return res.data['balance']; 
  }

  // POST /api/shop/buy/potion
  Future<int> buyPotion(String name, int price, bool isPoison) async {
    final res = await _client.dio.post('/api/shop/buy/potion', data: {
      "name": name,
      "price": price,
      "isPoison": isPoison,
    });
    return res.data['balance'];
  }

  // POST /api/tama/feed/{foodId}
  Future<void> feedPet(int foodId) async {
    await _client.dio.post('/api/tama/feed/$foodId');
  }
}