import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
// Ensure these paths match your actual project structure:
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

  // 👈 LIVE BACKEND FETCH
  Future<void> _fetchFridgeInventory() async {
    setState(() => _isLoading = true);
    try {
      // Calls the service layer which returns the correct package model
      final inventory = await services.game.getFoodInventory();
      setState(() {
        _fridgeInventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle connection/API error logging here
    }
  }

  // 👈 LIVE BACKEND ACTION
  Future<void> _feedTamagotchi(FoodItem food) async {
    final success = await services.game.feed(food.id);
    
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
            'YUM! FED ${food.name} (+${food.saturation} SAT)!',
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
      backgroundColor: colorScheme.surface, // changed from deprecated .background
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
                                ? Center(child: Text("LOADING...", style: TextStyle(color: colorScheme.onSurface)))
                                : _fridgeInventory.isEmpty
                                    ? Center(child: Text("FRIDGE IS EMPTY", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)))
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
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Image.asset(
                                                      'assets/sprites/${food.id}.png',
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 32),
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
                          'assets/sprites/${_selectedFood!.id}.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 80),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          'assets/sprites/${_selectedFood!.id}.png',
                          width: 70,
                          height: 70,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 70),
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
                          'assets/sprites/${_selectedFood!.id}.png',
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 60),
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