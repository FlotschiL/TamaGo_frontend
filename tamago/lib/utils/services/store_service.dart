import 'package:tamago/utils/services/api_manager.dart';

class StoreService {
  final ApiClient _client;
  StoreService(this._client);

  // GET /api/shop/items
  Future<Map<String, dynamic>> getShopAssortment() async {
    final res = await _client.dio.get('/api/shop/items');
    return res.data; // Enthält "food" und "potions" Listen
  }

  // GET /api/tama/inventory
  Future<int> getBalance() async {
    final res = await _client.dio.get('/api/tama/inventory');
    // Laut Doku ist balance direkt im Inventory-Objekt
    return res.data['balance'] ?? 0;
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
}