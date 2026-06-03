import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
// These imports are kept so your project doesn't break, 
// though we aren't using the service locator anymore!
import 'package:tamago/utils/services/service_locator.dart';  
import 'package:tamago/utils/services/model/foodItem.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  List<FoodItem> _fridgeInventory = [];
  bool _isLoading = true;
  FoodItem? _selectedFood;
  bool _isFridgeVisible = true;

  @override
  void initState() {
    super.initState();
    _fetchFridgeInventory();
  }

  // 👈 FAKED LOCAL FETCH
  Future<void> _fetchFridgeInventory() async {
    setState(() => _isLoading = true);
    
    // Simulate a short network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    setState(() {
      // Dummy data injection using your FoodItem model
      _fridgeInventory = [
        FoodItem(id: 0, name: 'Apple', saturation: 15),
        FoodItem(id: 1, name: 'Pizza Slice', saturation: 40),
        FoodItem(id: 2, name: 'Burger', saturation: 50),
        FoodItem(id: 3, name: 'Milk Carton', saturation: 10),
        FoodItem(id: 4, name: 'Cake', saturation: 30),
      ];
      _isLoading = false;
    });
  }

  // 👈 FAKED LOCAL ACTION
  Future<void> _feedTamagotchi(FoodItem food) async {
    // Simulate a quick backend process delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Always succeed locally
    const success = true; 
    
    if (success) {
      setState(() {
        _fridgeInventory.removeWhere((item) => item.id == food.id);
        _selectedFood = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            'YUM! FED ${food.name.toUpperCase()} (+${food.saturation} SAT)!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary, 
              fontWeight: FontWeight.bold
            ),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to feed your Tamagotchi. Try again!')),
      );
    }
  }

  void _toggleFridge() {
    setState(() {
      _isFridgeVisible = !_isFridgeVisible;
      if (!_isFridgeVisible) {
        _selectedFood = null; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, 
      floatingActionButton: const ChatNavigationTrigger(),
      body: Column(
        children: [
          // ==========================================
          // TOP: The Tamagotchi DragTarget
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
          // MIDDLE: Toggle Box + Fridge Shelf
          // ==========================================
          Expanded(
            flex: 2,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleFridge,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isFridgeVisible ? colorScheme.primary : colorScheme.surface,
                      border: Border.all(color: colorScheme.onSurface, width: 4),
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

                if (_isFridgeVisible)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.85),
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
                                ? Center(child: Text("LOADING...", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)))
                                : _fridgeInventory.isEmpty
                                    ? Center(child: Text("FRIDGE IS EMPTY", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)))
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _fridgeInventory.length,
                                        itemBuilder: (context, index) {
                                          final food = _fridgeInventory[index];
                                          final isSelected = _selectedFood?.id == food.id;
                                          
                                          // Wrap ID to fit 0-3 sprite availability if dummy item ID is higher
                                          final spriteId = food.id % 4; 

                                          return _PixelButton(
                                            isSelected: isSelected,
                                            colorScheme: colorScheme,
                                            onTap: () => setState(() => _selectedFood = food),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Image.asset(
                                                      'assets/Sprites/$spriteId.png',
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                                        'assets/Sprites/0.png', // Strict fallback to sprite 0 instead of generic Icon
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  food.name,
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
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
                        child: Image.asset(
                          'assets/Sprites/${_selectedFood!.id % 4}.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/Sprites/0.png', width: 80, height: 80),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          'assets/Sprites/${_selectedFood!.id % 4}.png',
                          width: 70,
                          height: 70,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/Sprites/0.png', width: 70, height: 70),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          border: Border.all(width: 4, color: colorScheme.primary),
                          boxShadow: [
                            BoxShadow(color: colorScheme.onSurface, offset: const Offset(6, 6)),
                          ],
                        ),
                        child: Image.asset(
                          'assets/Sprites/${_selectedFood!.id % 4}.png',
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/Sprites/0.png', width: 60, height: 60),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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