import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
import 'package:tamago/utils/services/service_locator.dart';
// Wichtig: Importiere hier das neue InventoryItem Modell aus deinem TamaService
import 'package:tamago/utils/services/tama_service.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  final TamaService _tamaService = services.tama;

  bool _isLoading = true;
  InventoryItem? _selectedItem; // Nutzt jetzt das kombinierte Modell
  bool _isFridgeVisible = true;

  @override
  void initState() {
    super.initState();
    _fetchFridgeInventory();
  }

  Future<void> _fetchFridgeInventory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _tamaService.getFoodInventory();
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Inventory Error: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load fridge inventory.')),
      );
    }
  }

  // --- ITEM ANWENDEN (FOOD ODER POTION) ---
  Future<void> _useItemOnTamagotchi(InventoryItem item) async {
    try {
      String successMessage = "";

      if (item.type == InventoryItemType.food) {
        // API Call für Füttern
        await _tamaService.feedPet(item.id);
        successMessage =
            'YUM! FED ${item.name.toUpperCase()} (+${item.saturation} SAT)!';
      } else {
        // API Call für Trank nutzen
        await _tamaService.usePotion(item.id);
        successMessage = item.isPoison == true
            ? 'OH NO! USED POISON: ${item.name.toUpperCase()}!'
            : 'HEALED! USED ${item.name.toUpperCase()}!';
      }

      await services.game.getStatus();
      setState(() {
        _selectedItem = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            successMessage,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
    } catch (e) {
      debugPrint("Use Item Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to use item. Try again!')),
      );
    }
  }

  void _toggleFridge() {
    setState(() {
      _isFridgeVisible = !_isFridgeVisible;
      if (!_isFridgeVisible) {
        _selectedItem = null;
      }
    });
  }

  // Helper für die Icons im Kühlschrank
  IconData _getItemIcon(InventoryItem item) {
    if (item.type == InventoryItemType.food) {
      return Icons.fastfood;
    } else {
      return item.isPoison == true ? Icons.dangerous : Icons.local_drink;
    }
  }

  // Helper für die Sprite-Pfade im Kühlschrank
  String _getItemImagePath(InventoryItem item) {
    final name = item.name.toLowerCase();
    if (name.contains('banane') || name.contains('banana')) {
      return 'assets/Sprites/0.png';
    } else if (name.contains('burger')) {
      return 'assets/Sprites/1.png';
    } else if (name.contains('cake') || name.contains('kuchen')) {
      return 'assets/Sprites/2.png';
    } else if (name.contains('salat') || name.contains('salad')) {
      return 'assets/Sprites/3.png';
    }

    // Fallback: Falls der Name nicht matcht, nutzen wir z.B. das erste Bild
    // oder steuern es über den Index/ID, falls deine API IDs von 0-3 mitsendet.
    return 'assets/Sprites/0.png';
  }

  // Helper für die Retro-Farben im Kühlschrank
  Color _getItemColor(InventoryItem item) {
    if (item.type == InventoryItemType.food) {
      return Colors.orangeAccent;
    } else {
      return item.isPoison == true ? Colors.redAccent : Colors.greenAccent;
    }
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
              child: DragTarget<InventoryItem>(
                onAcceptWithDetails: (details) =>
                    _useItemOnTamagotchi(details.data),
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isHovering
                          ? colorScheme.primary.withOpacity(0.1)
                          : null,
                      border: isHovering
                          ? Border.all(width: 4, color: colorScheme.primary)
                          : null,
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
                          isHovering
                              ? Icons.face_retouching_natural
                              : Icons.catching_pokemon,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isFridgeVisible
                          ? colorScheme.primary
                          : colorScheme.surface,
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
                          _isFridgeVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _isFridgeVisible
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isFridgeVisible
                              ? 'HIDE INVENTORY'
                              : 'SHOW INVENTORY',
                          style: TextStyle(
                            color: _isFridgeVisible
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
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
                          top: BorderSide(
                            color: colorScheme.onSurface,
                            width: 6,
                          ),
                          bottom: BorderSide(
                            color: colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            color: colorScheme.primary,
                            child: Text(
                              'KITCHEN CABINET',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _isLoading
                                ? Center(
                                    child: Text(
                                      "LOADING...",
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : ListenableBuilder(
                                    listenable: _tamaService,
                                    builder: (context, child) {
                                      final inventory = _tamaService.inventory;

                                      if (inventory.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "NO ITEMS OWNED",
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: inventory.length,
                                        itemBuilder: (context, index) {
                                          final item = inventory[index];
                                          final isSelected =
                                              _selectedItem?.id == item.id &&
                                              _selectedItem?.type == item.type;
                                          final itemColor = _getItemColor(item);

                                          return _PixelButton(
                                            isSelected: isSelected,
                                            colorScheme: colorScheme,
                                            onTap: () => setState(
                                              () => _selectedItem = item,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Image.asset(
                                                      _getItemImagePath(item),
                                                      filterQuality:
                                                          FilterQuality.none,
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Icon(
                                                            _getItemIcon(item),
                                                            size: 32,
                                                            color:
                                                                _getItemColor(
                                                                  item,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  item.name.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                              ],
                                            ),
                                          );
                                        },
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
          // BOTTOM: The Food/Potion Slot (Hand-off Area)
          // ==========================================
          Container(
            height: 140,
            width: double.infinity,
            color: colorScheme.secondary.withOpacity(0.2),
            child: Center(
              child: _selectedItem == null
                  ? Text(
                      'DRAG ITEM TO PET',
                      style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Draggable<InventoryItem>(
                      data: _selectedItem,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          _getItemImagePath(_selectedItem!),
                          width: 64,
                          height: 64,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getItemIcon(_selectedItem!),
                            size: 64,
                            color: _getItemColor(_selectedItem!),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          _getItemImagePath(_selectedItem!),
                          width: 56,
                          height: 56,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          border: Border.all(
                            width: 4,
                            color: colorScheme.primary,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface,
                              offset: const Offset(6, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getItemIcon(_selectedItem!),
                              size: 48,
                              color: _getItemColor(_selectedItem!),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedItem!.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: 85,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(color: colorScheme.onSurface, offset: const Offset(3, 3)),
          ],
        ),
        child: child,
      ),
    );
  }
}
