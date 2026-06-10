import 'package:flutter/foundation.dart';
import 'package:tamago/utils/services/api_manager.dart';

// --- INVENTORY ITEM TYPE ---
enum InventoryItemType { food, potion }

// --- UNIFIED INVENTORY ITEM MODEL ---
class InventoryItem {
  final int id;
  final String name;
  final InventoryItemType type;
  final int? saturation;
  final bool? isPoison;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    this.saturation,
    this.isPoison,
  });
}

class TamaService with ChangeNotifier {
  final ApiClient _client;
  
  // Zentrales Inventar für Essen UND Tränke
  List<InventoryItem> _inventory = [];
  List<InventoryItem> get inventory => _inventory;

  TamaService(this._client);

  /// Holt das komplette Inventar (Food & Potions) vom Backend
  Future<List<InventoryItem>> getFoodInventory() async {
    final res = await _client.dio.get('/api/tama/inventory');
    
    final List<dynamic> foodList = res.data['food'] ?? [];
    final List<dynamic> potionList = res.data['potions'] ?? [];
    
    List<InventoryItem> updatedInventory = [];

    // Food mappen
    for (var f in foodList) {
      updatedInventory.add(InventoryItem(
        id: f['id'],
        name: f['name'],
        saturation: f['saturation'],
        type: InventoryItemType.food,
      ));
    }

    // Potions mappen
    for (var p in potionList) {
      updatedInventory.add(InventoryItem(
        id: p['id'],
        name: p['name'],
        isPoison: p['isPoison'],
        type: InventoryItemType.potion,
      ));
    }
    
    _inventory = updatedInventory;
    notifyListeners(); 
    return _inventory;
  }

  /// Füttert das Haustier mit der angegebenen Food ID
  Future<void> feedPet(int foodId) async {
    await _client.dio.post('/api/tama/feed/$foodId');
    
    // Direkt lokal aus der Liste entfernen
    _inventory.removeWhere((item) => item.id == foodId && item.type == InventoryItemType.food);
    notifyListeners();
  }

  /// Nutzt einen Trank auf das Haustier mit der angegebenen Potion ID
  Future<void> usePotion(int potionId) async {
    await _client.dio.post('/api/tama/usePotion/$potionId');
    
    // Direkt lokal aus der Liste entfernen
    _inventory.removeWhere((item) => item.id == potionId && item.type == InventoryItemType.potion);
    notifyListeners();
  }
}