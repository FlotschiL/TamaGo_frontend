import 'package:flutter/material.dart';
// --- ADD THESE IMPORTS ---
import 'package:tamago/utils/services/store_service.dart';
import 'package:tamago/utils/services/service_locator.dart';

// --- ITEM TYPES ---
enum ItemType { food, potion }

// --- SHOP ITEM MODEL ---
class ShopItem {
  final String name;
  final int price;
  final ItemType type;
  final String imagePath;

  final int? saturation;
  final bool? isPoison;

  ShopItem({
    required this.name,
    required this.price,
    required this.type,
    required this.imagePath,
    this.saturation,
    this.isPoison,
  });
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // --- INJECT REAL API CLIENT ---
  // Note: If your service locator uses a different name (like 'sl' or 'getIt'),
  // change `locator` to match your setup.
  final StoreService _storeService = services.store;

  int _userCoins = 0;
  bool _isLoading = false;

  List<ShopItem> _availableItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOAD STORE DATA ---
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Parallel loading for better performance
      final results = await Future.wait([
        _storeService.getBalance(),
        _storeService.getShopAssortment(),
      ]);

      final int balance = results[0] as int;
      final Map<String, dynamic> assortment =
          results[1] as Map<String, dynamic>;

      List<ShopItem> items = [];

      // --- FOOD MAPPING ---
      if (assortment['food'] != null) {
        int foodIndex = 0;
        for (var f in assortment['food']) {
          // Falls die API mehr als 4 Items liefert, verhindert % 4 einen Absturz
          int spriteId = foodIndex % 4;

          // Alternativ nach Namen mappen, falls die API-Reihenfolge nicht fix ist:
          // if (f['name'].toString().toLowerCase() == 'banana') spriteId = 0;

          items.add(
            ShopItem(
              name: f['name'],
              price: f['price'],
              saturation: f['saturation'],
              type: ItemType.food,
              imagePath: 'assets/Sprites/$spriteId.png', // <-- Dynamischer Pfad
            ),
          );
          foodIndex++;
        }
      }

      // --- POTION MAPPING ---
      if (assortment['potions'] != null) {
        for (var p in assortment['potions']) {
          items.add(
            ShopItem(
              name: p['name'],
              price: p['price'],
              isPoison: p['isPoison'],
              type: ItemType.potion,
              // Falls du für Tränke auch Sprites hast (z.B. 4.png), hier eintragen:
              imagePath: p['isPoison'] == true
                  ? 'assets/Sprites/Posion.png' // Beispielhaft Salat/Gift
                  : 'assets/Sprites/0.png',
            ),
          );
        }
      }

      setState(() {
        _userCoins = balance;
        _availableItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Store Error: $e");
      _showPixelDialog("ERROR", "CONNECTION_FAILED");
      setState(() => _isLoading = false);
    }
  }

  // --- PURCHASE ITEM ---
  Future<void> _purchaseItem(ShopItem item) async {
    if (_userCoins < item.price) {
      _showPixelDialog("ERROR", "NOT ENOUGH COINS!");
      return;
    }

    try {
      int newBalance;

      if (item.type == ItemType.food) {
        newBalance = await _storeService.buyFood(
          item.name,
          item.price,
          item.saturation!,
        );
      } else {
        newBalance = await _storeService.buyPotion(
          item.name,
          item.price,
          item.isPoison!,
        );
      }

      setState(() {
        _userCoins = newBalance;
      });

      await services.tama.getFoodInventory();

      _showPixelDialog("SUCCESS", "${item.name.toUpperCase()} BOUGHT!");
    } catch (e) {
      debugPrint("Purchase Error: $e");
      _showPixelDialog("ERROR", "PURCHASE_FAILED");
    }
  }

  // --- DIALOG ---
  void _showPixelDialog(String title, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: Border.all(color: colorScheme.onSurface, width: 4),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                border: Border.all(color: colorScheme.onSurface, width: 2),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ITEM ICONS ---
  IconData _getItemIcon(ShopItem item) {
    switch (item.type) {
      case ItemType.food:
        return Icons.fastfood;
      case ItemType.potion:
        return item.isPoison == true ? Icons.dangerous : Icons.local_drink;
    }
  }

  // --- ITEM COLORS ---
  Color _getItemColor(ShopItem item) {
    switch (item.type) {
      case ItemType.food:
        return Colors.orangeAccent;
      case ItemType.potion:
        return item.isPoison == true ? Colors.redAccent : Colors.greenAccent;
    }
  }

  // --- ITEM DESCRIPTION ---
  String _getItemDescription(ShopItem item) {
    switch (item.type) {
      case ItemType.food:
        return "SATURATION +${item.saturation}";
      case ItemType.potion:
        return item.isPoison == true ? "POISON EFFECT" : "HEALING EFFECT";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.onSurface, width: 4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "MARKET PLAZA",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$_userCoins",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- LOADING ---
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          // --- EMPTY ---
          else if (_availableItems.isEmpty)
            const Expanded(child: Center(child: Text("NO ITEMS AVAILABLE")))
          // --- GRID ---
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _availableItems.length,
                itemBuilder: (context, index) {
                  final item = _availableItems[index];
                  return _buildStoreCard(item, colorScheme);
                },
              ),
            ),
        ],
      ),
    );
  }

  // --- STORE CARD ---
  Widget _buildStoreCard(ShopItem item, ColorScheme colorScheme) {
    final itemColor = _getItemColor(item);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.onSurface, width: 4),
        boxShadow: [
          BoxShadow(color: colorScheme.onSurface, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
Expanded(
            child: Container(
              color: itemColor.withOpacity(0.1),
              padding: const EdgeInsets.all(12), // Etwas Platz zum Rand lassen
              child: Image.asset(
                item.imagePath,
                filterQuality: FilterQuality.none, // Perfekt für Pixel-Art!
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback, falls ein Pfad mal nicht existiert
                  return Icon(_getItemIcon(item), size: 48, color: itemColor);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _getItemDescription(item),
                  style: const TextStyle(fontSize: 8),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _purchaseItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${item.price}",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// NOTE: The mock StoreService class that was previously at the bottom has been removed!
