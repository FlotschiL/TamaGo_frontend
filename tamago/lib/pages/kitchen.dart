import 'package:flutter/material.dart';

// --- Mocking your AppColors for the example to compile ---

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
  List<FoodItem> _fridgeInventory = [];
  bool _isLoading = true;
  FoodItem? _selectedFood;
  bool _isFridgeVisible = true; // 👈 NEW: Controls fridge visibility

  @override
  void initState() {
    super.initState();
    _fetchFridgeInventory();
  }

  Future<void> _fetchFridgeInventory() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _fridgeInventory = [
        FoodItem(id: '1', name: 'APPLE', icon: Icons.apple, color: Colors.red),
        FoodItem(id: '2', name: 'CARROT', icon: Icons.auto_awesome_mosaic, color: Colors.orange),
        FoodItem(id: '3', name: 'PIZZA', icon: Icons.local_pizza, color: Colors.orangeAccent),
        FoodItem(id: '4', name: 'CAKE', icon: Icons.cake, color: Colors.pinkAccent),
      ];
      _isLoading = false;
    });
  }

  void _feedTamagotchi(FoodItem food) {
    setState(() {
      _fridgeInventory.removeWhere((item) => item.id == food.id);
      _selectedFood = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          'YUM! FED ${food.name}!',
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  // 👈 NEW: Toggle fridge visibility
  void _toggleFridge() {
    setState(() {
      _isFridgeVisible = !_isFridgeVisible;
      if (!_isFridgeVisible) {
        _selectedFood = null; // Deselect when hiding fridge
      }
    });
  }

@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return Scaffold(
    backgroundColor: colorScheme.background,
    body: Stack(
      children: [
        // ==========================================
        // BACKGROUND: Kitchen image (rendered first = behind everything)
        // ==========================================
        Positioned.fill(
          child: Image.asset(
            'assets/backgrounds/kitchen.png',
            fit: BoxFit.cover,
          ),
        ),

        // ==========================================
        // FOREGROUND: All UI content in a Column
        // ==========================================
        Column(
          children: [
            // ==========================================
            // TOP: The Tamagotchi
            // ==========================================
            Expanded(
              flex: 3,
              child: Center(
                child: DragTarget<FoodItem>(
                  onAcceptWithDetails: (details) => _feedTamagotchi(details.data),
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isHovering ? colorScheme.primary.withOpacity(0.1) : null,
                        border: isHovering ? Border.all(width: 4, color: colorScheme.primary) : null,
                      ),
                      child: Center(
                        child: Image.asset(
                          isHovering
                              ? 'assets/animations/BaseTama/BaseTama2.png'
                              : 'assets/animations/BaseTama/BaseTama1.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            isHovering ? Icons.face_retouching_natural : Icons.catching_pokemon,
                            size: 120,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==========================================
            // MIDDLE: Toggle Box + Fridge (Pixel-style shelf)
            // ==========================================
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // 👈 Clickable toggle box
                  GestureDetector(
                    onTap: _toggleFridge,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isFridgeVisible ? colorScheme.primary : colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.onSurface,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withOpacity(0.3),
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFridgeVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: _isFridgeVisible ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isFridgeVisible ? 'HIDE_FRIDGE' : 'SHOW_FRIDGE',
                            style: TextStyle(
                              color: _isFridgeVisible ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 👈 Fridge content - only shown when _isFridgeVisible is true
                  if (_isFridgeVisible)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.85), // 👈 Slight transparency to see background
                          border: Border(
                            top: BorderSide(color: colorScheme.onSurface, width: 6),
                            bottom: BorderSide(color: colorScheme.onSurface, width: 2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              color: colorScheme.primary,
                              child: Text(
                                'FRIDGE_INVENTORY',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _isLoading
                                  ? Center(child: Text("LOADING...", style: TextStyle(color: colorScheme.onSurface)))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _fridgeInventory.length,
                                      itemBuilder: (context, index) {
                                        final food = _fridgeInventory[index];
                                        final isSelected = _selectedFood?.id == food.id;
                                        return _PixelButton(
                                          isSelected: isSelected,
                                          colorScheme: colorScheme,
                                          onTap: () => setState(() => _selectedFood = food),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(food.icon, size: 32, color: food.color),
                                              const SizedBox(height: 4),
                                              Text(
                                                food.name,
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==========================================
            // BOTTOM: The Food Slot (Hand-off Area)
            // ==========================================
            Container(
              height: 140,
              width: double.infinity,
              color: colorScheme.secondary.withOpacity(0.2),
              child: Center(
                child: _selectedFood == null
                    ? Text('SELECT_ITEMS', style: TextStyle(color: colorScheme.primary.withOpacity(0.5)))
                    : Draggable<FoodItem>(
                        data: _selectedFood,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Icon(_selectedFood!.icon, size: 80, color: _selectedFood!.color),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.2,
                          child: Icon(_selectedFood!.icon, size: 70, color: _selectedFood!.color),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.9), // 👈 Slight transparency
                            border: Border.all(width: 4, color: colorScheme.primary),
                            boxShadow: [
                              BoxShadow(color: colorScheme.onSurface, offset: const Offset(6, 6)),
                            ],
                          ),
                          child: Icon(_selectedFood!.icon, size: 60, color: _selectedFood!.color),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}}
// --- Helper Widget for Retro Block Buttons ---
class _PixelButton extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _PixelButton({
    required this.child,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            width: 4,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.2),
                offset: const Offset(4, 4),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}