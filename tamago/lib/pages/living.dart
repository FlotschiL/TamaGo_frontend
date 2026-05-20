import 'package:flutter/material.dart';
import 'package:tamago/Objects/game_state.dart';
import 'package:tamago/pages/chatnavigation.dart';

import 'package:tamago/utils/services/service_locator.dart';

class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {

  GameState? _gameState;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshGameState();
  }

  Future<void> _refreshGameState() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final newState = await services.game.getStatus();
      setState(() {
        _gameState = newState;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "SYSTEM ERROR: $e";
      });
    }
  }

  Future<void> _pet(int placeId) async {
    _refreshGameState();
    await services.game.pet(placeId);
  }

  // --- UI HELPERS ---

  Widget _buildPixelStatBar(String label, double value, Color barColor, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.onSurface, width: 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(color: barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPixelButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final bool isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled ? colorScheme.surface.withOpacity(0.5) : color,
          border: Border.all(
            color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onSurface,
            width: 4,
          ),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: colorScheme.onSurface,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onPrimary
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Safe helper to extract emotion intensity
  double _getEmotionIntensity(String type, double fallback) {
    if (_gameState == null) return fallback;
    try {
      final emotion = _gameState!.emotions.firstWhere(
        (e) => e.emotionType.trim() == type.trim(),
      );
      return emotion.intensity / 100;
    } catch (_) {
      return fallback; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 1. ERROR STATE
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.error, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildPixelButton(
                  label: "RETRY",
                  icon: Icons.refresh,
                  onPressed: _refreshGameState,
                  color: colorScheme.primary,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. INITIAL LOADING STATE 
    if (_gameState == null && _isLoading) {
      return Scaffold(
        body: Center(
          child: Text(
            "LOADING...",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      );
    }

    // 3. EMPTY / NULL STATE 
    if (_gameState == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "NO PET FOUND",
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildPixelButton(
                label: "RELOAD",
                icon: Icons.refresh,
                onPressed: _refreshGameState,
                color: colorScheme.primary,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      );
    }

    // 4. MAIN GAME UI
    return Scaffold(
      floatingActionButton: const ChatNavigationTrigger(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/living.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          Column(
            children: [
              // Dashboard (Status Bars)
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.85),
                  border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPixelStatBar("HUNGER", _getEmotionIntensity("HAPPY", 0.5), colorScheme.primary, colorScheme),
                    _buildPixelStatBar("HEALTH", (_gameState!.health / 100).clamp(0.0, 1.0), Colors.green, colorScheme),
                    _buildPixelStatBar("ALIVE", _gameState!.alive ? 1.0 : 0.0, colorScheme.secondary, colorScheme),
                  ],
                ),
              ),

              const Spacer(),

              // The Pet (Now with Swipe Zones)
              Center(
                child: Opacity(
                  opacity: _gameState!.alive ? 1.0 : 0.4,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      children: [
                        // The Sprite
                        Positioned.fill(
                          child: Image.asset(
                            'assets/animations/BaseTama/BaseTama1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.cruelty_free, 
                              size: 120, 
                              color: colorScheme.onSurface
                            ),
                          ),
                        ),
                        
                        // Invisible Petting Zones layered over the Sprite
                        if (_gameState!.alive)
                          Positioned.fill(
                            child: Column(
                              children: [
                                // TOP ZONE (1)
                                Expanded(
                                  child: GestureDetector(
                                    // onPanStart fires once when a swipe begins
                                    onPanStart: (_) => _pet(1),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // MIDDLE ZONE (2)
                                Expanded(
                                  child: GestureDetector(
                                    onPanStart: (_) => _pet(2),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // BOTTOM ZONE (3)
                                Expanded(
                                  child: GestureDetector(
                                    onPanStart: (_) => _pet(3),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(), // Replaces the old action bar so the pet stays visually centered
            ],
          ),

          // Action Overlay Loader
          if (_isLoading)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: colorScheme.primary,
                  child: Text("BUSY...", style: TextStyle(color: colorScheme.onPrimary, fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}