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

  // --- UI HELPERS (Moved outside build for clarity) ---

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Error State
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

    // 2. Initial Loading State
    if (_gameState == null) {
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

    // 3. Main Game UI
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
                    _buildPixelStatBar("HUNGER", _gameState!.hunger / 100, colorScheme.primary, colorScheme),
                    _buildPixelStatBar("HEALTH", _gameState!.health / 100, Colors.green, colorScheme),
                    _buildPixelStatBar("ALIVE", _gameState!.alive ? 1.0 : 0.0, colorScheme.secondary, colorScheme),
                  ],
                ),
              ),

              const Spacer(),

              // The Pet
              Center(
                child: Opacity(
                  opacity: _gameState!.alive ? 1.0 : 0.4,
                  child: Image.asset(
                    'assets/animations/BaseTama/BaseTama1.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.cruelty_free, 
                      size: 120, 
                      color: colorScheme.onSurface
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action Controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.85),
                  border: Border(top: BorderSide(color: colorScheme.onSurface, width: 6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPixelButton(
                      label: "PET+",
                      icon: Icons.front_hand,
                      onPressed: _gameState!.alive ? () => _pet(1) : null,
                      color: colorScheme.secondary,
                      colorScheme: colorScheme,
                    ),
 
                  ],
                ),
              ),
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