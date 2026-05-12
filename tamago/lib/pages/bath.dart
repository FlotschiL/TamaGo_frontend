import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tamago/utils/api_manager.dart';
import 'package:tamago/Objects/game_state.dart';
import 'package:tamago/pages/chatnavigation.dart';


class BathroomPage extends StatefulWidget {
  const BathroomPage({super.key});

  @override
  State<BathroomPage> createState() => _BathroomPageState();
}

class _BathroomPageState extends State<BathroomPage> {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

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
      final newState = await _apiClient.getGameState();
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

  Future<void> _bathe() async {
    /*setState(() => _isLoading = true);
    try {
      final updatedState = await _apiClient.bathe(1);
      setState(() {
        _gameState = updatedState;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }*/
  }

  Future<void> _clean() async {
    /*setState(() => _isLoading = true);
    try {
      final updatedState = await _apiClient.clean(1);
      setState(() {
        _gameState = updatedState;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }*/
  }

  // --- UI HELPERS (Identical to LivingRoomPage for consistency) ---

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
          // Background Image - Bathroom Theme
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/living.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          Column(
            children: [
              // Dashboard (Status Bars - Bathroom Specific)
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.85),
                  border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPixelStatBar("HYGIENE",  100, Colors.blue, colorScheme),
                    _buildPixelStatBar("HEALTH",  80, Colors.green, colorScheme),
                    _buildPixelStatBar("HAPPY", 90, Colors.pink, colorScheme),
                  ],
                ),
              ),

              const Spacer(),

              // The Pet in Bathroom Scene
              Center(
                child: Opacity(
                  opacity: _gameState!.alive ? 1.0 : 0.4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Optional: Bubble effect when clean/happy
                      if (true)
                        Positioned(
                          top: -20,
                          right: -10,
                          child: Icon(
                            Icons.bubble_chart,
                            color: Colors.blue.withOpacity(0.7),
                            size: 30,
                          ),
                        ),
                      Image.asset(
                        'assets/animations/BaseTama/BaseTama1.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.bathtub, 
                          size: 120, 
                          color: colorScheme.onSurface
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Controls - Bathroom Specific
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
                      label: "BATHE",
                      icon: Icons.bathtub,
                      onPressed: _gameState!.alive ? _bathe : null,
                      color: Colors.blue,
                      colorScheme: colorScheme,
                    ),
                    _buildPixelButton(
                      label: "CLEAN",
                      icon: Icons.cleaning_services,
                      onPressed: _gameState!.alive ? _clean : null,
                      color: Colors.orange,
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