import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
import 'package:tamago/utils/services/service_locator.dart';  

// --- DUMMY MODEL ---
class MinigameItem {
  final int id;
  final String name;
  final String routeName;

  MinigameItem({required this.id, required this.name, required this.routeName});
}

class GameRoomScreen extends StatefulWidget {
  const GameRoomScreen({Key? key}) : super(key: key);

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  List<MinigameItem> _gameInventory = [];
  bool _isLoading = true;
  MinigameItem? _selectedGame;
  int _totalCoins = 0;

  @override
  void initState() {
    super.initState();
    _fetchGameInventory();
  }

  Future<void> _fetchGameInventory() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _gameInventory = [
        MinigameItem(id: 0, name: 'Runner', routeName: '/runner'),
        MinigameItem(id: 1, name: 'Jump', routeName: '/jump'),
        MinigameItem(id: 2, name: 'Puzzle', routeName: '/puzzle'),
      ];
      _isLoading = false;
    });
  }

  Future<void> _launchGame(MinigameItem game) async {
    setState(() => _selectedGame = null);

    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyMinigameScreen(gameName: game.name),
      ),
    );

    if (result != null && result is int) {
      await _saveCoinsToBackend(game.name, result);
    }
  }

  Future<void> _saveCoinsToBackend(String gameName, int score) async {
    final int coinsEarned = (score / 10).floor();
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _totalCoins += coinsEarned;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          '!! $gameName COMPLETED !! EARNED $coinsEarned COINS',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary, 
            fontWeight: FontWeight.bold
          ),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, 
      floatingActionButton: const ChatNavigationTrigger(),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. RETRO STATUS BAR (Header)
            // ==========================================
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.onSurface, width: 4),
                boxShadow: [
                  BoxShadow(color: colorScheme.onSurface, offset: const Offset(4, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📍 ARCADE_ROOM',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    color: colorScheme.primary,
                    child: Text(
                      '🪙 $_totalCoins',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. UNIFIED CONSOLE UNIT (Center System)
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    border: Border.all(color: colorScheme.onSurface, width: 4),
                  ),
                  child: Column(
                    children: [
                      // Game Screen Viewport
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/animations/BaseTama/BaseTama1.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.videogame_asset,
                              size: 100,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      
                      // Integrated Cartridge Drop Zone / Slot
                      DragTarget<MinigameItem>(
                        onAcceptWithDetails: (details) => _launchGame(details.data),
                        builder: (context, candidateData, rejectedData) {
                          final isHovering = candidateData.isNotEmpty;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isHovering 
                                  ? colorScheme.secondary.withOpacity(0.4) 
                                  : colorScheme.surface,
                              border: Border(
                                top: BorderSide(color: colorScheme.onSurface, width: 4),
                              ),
                            ),
                            child: Center(
                              child: isHovering
                                  ? Text(
                                      '👉 DROP TO BOOT GAME 👈',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_downward, color: colorScheme.onSurface.withOpacity(0.5), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'INSERT CARTRIDGE HERE',
                                          style: TextStyle(
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_downward, color: colorScheme.onSurface.withOpacity(0.5), size: 18),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 3. PHYSICAL CARTRIDGE DOCK & RACK (Bottom)
            // ==========================================
            Container(
              margin: const EdgeInsets.all(12),
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.onSurface, width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Banner for the shelf
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: colorScheme.onSurface,
                    child: Text(
                      'MY_GAME_SHELF',
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  // The Split View inside the rack
                  Expanded(
                    child: Row(
                      children: [
                        // Left Column: The Unlocked Games Picker
                        Expanded(
                          flex: 3,
                          child: _isLoading
                              ? Center(child: Text("LOADING...", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)))
                              : _gameInventory.isEmpty
                                  ? Center(child: Text("EMPTY SHELF", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.4))))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _gameInventory.length,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      itemBuilder: (context, index) {
                                        final game = _gameInventory[index];
                                        final isSelected = _selectedGame?.id == game.id;
                                        final spriteId = game.id % 4;

                                        return _PixelButton(
                                          isSelected: isSelected,
                                          colorScheme: colorScheme,
                                          onTap: () => setState(() => _selectedGame = game),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Image.asset(
                                                    'assets/Sprites/$spriteId.png',
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 28),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                game.name.toUpperCase(),
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        
                        // Right Divider Line
                        Container(width: 4, color: colorScheme.onSurface),

                        // Right Column: The "Active Hand" (Draggable Slot)
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: colorScheme.secondary.withOpacity(0.1),
                            child: Center(
                              child: _selectedGame == null
                                  ? Text(
                                      'GRAB\nGAME',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold),
                                    )
                                  : Draggable<MinigameItem>(
                                      data: _selectedGame,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Image.asset(
                                          'assets/Sprites/${_selectedGame!.id % 4}.png',
                                          width: 65,
                                          height: 65,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 40),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.2,
                                        child: Image.asset(
                                          'assets/Sprites/${_selectedGame!.id % 4}.png',
                                          width: 55,
                                          height: 55,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 40),
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          border: Border.all(width: 3, color: colorScheme.primary),
                                          boxShadow: [
                                            BoxShadow(color: colorScheme.onSurface, offset: const Offset(4, 4)),
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/Sprites/${_selectedGame!.id % 4}.png',
                                          width: 45,
                                          height: 45,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 30),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
        width: 75,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            width: 4,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.15),
                offset: const Offset(3, 3),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// --- DUMMY MINIGAME SCREEN ---
class DummyMinigameScreen extends StatelessWidget {
  final String gameName;
  const DummyMinigameScreen({super.key, required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PLAYING: $gameName', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(context, 180), // Emits 180 score points
              child: const Text('WIN GAME & COLLECT COINS'),
            )
          ],
        ),
      ),
    );
  }
}