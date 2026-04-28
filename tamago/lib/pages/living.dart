import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tamago/utils/api_manager.dart';
import 'package:tamago/Objects/game_state.dart';


class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {
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
      debugPrint("Refreshing game state...");
      final newState = await _apiClient.getGameState();
      setState(() {
        _gameState = newState;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load Tama: $e";
      });
    }
  }

  Future<void> _feed() async {
    setState(() => _isLoading = true);
    try {
      final updatedState = await _apiClient.feed(1);
      setState(() {
        _gameState = updatedState;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pet() async {
    _refreshGameState();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _refreshGameState, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (_gameState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      // No AppBar here — it lives in MainGameNavigation
      body: Stack(
        children: [
          Column(
            children: [
              // --- 1. Statusleisten ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBar("Hunger", (_gameState!.hunger / 100), Colors.green),
                    _buildStatBar("Gesundheit", (_gameState!.health / 100), Colors.pink),
                    _buildStatBar("Status", _gameState!.alive ? 1.0 : 0.0, Colors.blue),
                  ],
                ),
              ),

              const Spacer(),

              // --- 2. Das Tier ---
              Center(
                child: Opacity(
                  opacity: _gameState!.alive ? 1.0 : 0.3,
                  child: Image.asset(
                    'assets/images/pet.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.pets, size: 100, color: Colors.brown),
                  ),
                ),
              ),

              const Spacer(),

              // --- 3. Interaktions-Buttons ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.restaurant, "Füttern", _gameState!.alive ? _feed : null),
                    _buildActionButton(Icons.videogame_asset, "Streicheln", _gameState!.alive ? _pet : null),
                  ],
                ),
              ),
            ],
          ),
          // Small overlay loader during actions
          if (_isLoading)
            const Positioned(top: 10, right: 10, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback? onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: onPressed == null ? Colors.grey : null,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
