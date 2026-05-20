import 'package:tamago/utils/services/api_manager.dart';

class StoreService {
  final ApiClient _client;
  StoreService(this._client);

  // Lädt das zufällige Sortiment (3 Food, 2 Potions)
  Future<Map<String, dynamic>> getShopAssortment() async {
    final res = await _client.dio.get('/api/shop/items');
    return res.data;
  }

  // Aktuellen Kontostand aus dem Inventar holen
  Future<int> getBalance() async {
    final res = await _client.dio.get('/api/tama/inventory');
    return res.data['balance'];
  }

  // Food kaufen
  Future<int> buyFood(String name, int price, int saturation) async {
    final res = await _client.dio.post('/api/shop/buy/food', data: {
      "name": name,
      "price": price,
      "saturation": saturation,
    });
    return res.data['balance']; // Gibt neuen Kontostand zurück
  }

  // Trank kaufen
  Future<int> buyPotion(String name, int price, bool isPoison) async {
    final res = await _client.dio.post('/api/shop/buy/potion', data: {
      "name": name,
      "price": price,
      "isPoison": isPoison,
    });
    return res.data['balance'];
  }
}