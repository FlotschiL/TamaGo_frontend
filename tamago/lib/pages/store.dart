import 'package:flutter/material.dart';

// 1. Store Item Model
class StoreItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int price;
  final Color color;

  StoreItem({
    required this.id, 
    required this.name, 
    required this.description, 
    required this.icon, 
    required this.price, 
    required this.color
  });
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _userCoins = 1250; // Mock currency

  final List<StoreItem> _shopItems = [
    StoreItem(id: '1', name: 'PIXEL_CAKE', description: 'RESTORES_MAX_HUNGER', icon: Icons.cake, price: 50, color: Colors.pinkAccent),
    StoreItem(id: '2', name: 'SUPER_SOAP', description: 'ULTRA_CLEAN_SHINE', icon: Icons.soap, price: 30, color: Colors.lightBlueAccent),
    StoreItem(id: '3', name: 'GOLD_HAT', description: 'LOOKS_VERY_FANCY', icon: Icons.theater_comedy, price: 500, color: Colors.amber),
    StoreItem(id: '4', name: 'ENERGY_DRINK', description: 'NO_SLEEP_NEEDED', icon: Icons.bolt, price: 120, color: Colors.greenAccent),
    StoreItem(id: '5', name: 'TOY_MOUSE', description: 'INCREASES_HAPPINESS', icon: Icons.mouse, price: 80, color: Colors.grey),
    StoreItem(id: '6', name: 'MYSTERY_BOX', description: 'WHAT_IS_INSIDE?', icon: Icons.help_outline, price: 200, color: Colors.deepPurpleAccent),
  ];

  void _purchaseItem(StoreItem item) {
    if (_userCoins >= item.price) {
      setState(() => _userCoins -= item.price);
      _showPixelDialog("SUCCESS", "YOU_BOUGHT_${item.name}!");
    } else {
      _showPixelDialog("ERROR", "NOT_ENOUGH_COINS!");
    }
  }

  void _showPixelDialog(String title, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: Border.all(color: colorScheme.onSurface, width: 4),
        title: Text(title, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                border: Border.all(color: colorScheme.onSurface, width: 2),
              ),
              child: Text("OK", style: TextStyle(color: colorScheme.onSecondary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // --- CURRENCY HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("MARKET_PLAZA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text("$_userCoins", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- ITEM GRID ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _shopItems.length,
              itemBuilder: (context, index) {
                final item = _shopItems[index];
                return _buildStoreCard(item, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(StoreItem item, ColorScheme colorScheme) {
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
              color: item.color.withOpacity(0.1),
              child: Icon(item.icon, size: 48, color: item.color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(item.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 8), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _purchaseItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      border: Border.all(color: colorScheme.onSurface, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text("${item.price}", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
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