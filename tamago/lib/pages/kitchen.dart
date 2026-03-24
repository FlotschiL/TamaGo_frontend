import 'package:flutter/material.dart';

// 1. A simple data model for our Food
class FoodItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  FoodItem({required this.id, required this.name, required this.icon, required this.color});
}

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  // State variables
  List<FoodItem> _fridgeInventory = [];
  bool _isLoading = true;
  FoodItem? _selectedFood;

  @override
  void initState() {
    super.initState();
    _fetchFridgeInventory();
  }

  // 2. Mock API Call to get food
  Future<void> _fetchFridgeInventory() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _fridgeInventory = [
        FoodItem(id: '1', name: 'Apple', icon: Icons.apple, color: Colors.red),
        FoodItem(id: '2', name: 'Carrot', icon: Icons.grass, color: Colors.orange), // grass icon as placeholder
        // Using local icons for simplicity, but you could use Image.network later
        FoodItem(id: '3', name: 'Pizza', icon: Icons.local_pizza, color: Colors.orangeAccent),
        FoodItem(id: '4', name: 'Cake', icon: Icons.cake, color: Colors.pinkAccent),
      ];
      _isLoading = false;
    });
  }

  void _feedTamagotchi(FoodItem food) {
    setState(() {
      // Remove food from inventory and clear the slot
      _fridgeInventory.removeWhere((item) => item.id == food.id);
      _selectedFood = null;
    });

    // Show the success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pet fed a tasty ${food.name}!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ==========================================
        // TOP: The Tamagotchi (The DragTarget)
        // ==========================================
        Expanded(
          flex: 3,
          child: Center(
            child: DragTarget<FoodItem>(
              // This is what happens when the user drops the food here
              onAcceptWithDetails: (details) {
                _feedTamagotchi(details.data);
              },
              // The builder lets us change how the pet looks when food is hovering
              builder: (context, candidateData, rejectedData) {
                final isFoodHovering = candidateData.isNotEmpty;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isFoodHovering ? Colors.teal.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    // Open mouth if food is hovering!
                    isFoodHovering ? Icons.sentiment_very_satisfied : Icons.pets, 
                    size: 120, 
                    color: Colors.teal.shade700,
                  ),
                );
              },
            ),
          ),
        ),

        // ==========================================
        // MIDDLE: The Fridge Inventory
        // ==========================================
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              border: const Border(top: BorderSide(color: Colors.blueGrey, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Fridge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fridgeInventory.length,
                        itemBuilder: (context, index) {
                          final food = _fridgeInventory[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFood = food;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedFood?.id == food.id ? Colors.teal : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(food.icon, size: 40, color: food.color),
                                  Text(food.name, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),

        // ==========================================
        // BOTTOM: The Food Slot (The Draggable)
        // ==========================================
        Container(
          height: 120,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: Center(
            child: _selectedFood == null 
              ? const Text('Tap food from the fridge to select', style: TextStyle(color: Colors.grey))
              : Draggable<FoodItem>(
                  // The data that gets passed to the DragTarget
                  data: _selectedFood,
                  // What the user sees under their finger while dragging
                  feedback: Material(
                    color: Colors.transparent,
                    child: Icon(_selectedFood!.icon, size: 80, color: _selectedFood!.color),
                  ),
                  // What gets left behind in the slot while dragging
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Icon(_selectedFood!.icon, size: 60, color: _selectedFood!.color),
                  ),
                  // The default look of the slot before dragging
                  child: Icon(_selectedFood!.icon, size: 60, color: _selectedFood!.color),
                ),
          ),
        ),
      ],
    );
  }
}