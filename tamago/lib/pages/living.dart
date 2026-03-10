import 'package:flutter/material.dart';

void main() {
  runApp(const TamagotchiApp());
}
class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const LivingRoomPage(),
    );
  }
}

class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {
  // Beispiel-Werte für das Tier
  double hunger = 0.7;
  double happiness = 0.5;

  void _feed() {
    setState(() {
      hunger = (hunger + 0.1).clamp(0.0, 1.0);
    });
  }

  void _play() {
    setState(() {
      happiness = (happiness + 0.1).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ein gemütlicher Hintergrund
      backgroundColor: const Color(0xFFFDF5E6), 
      appBar: AppBar(
        title: const Text('Wohnzimmer'),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
      ),
      body: Column(
        children: [
          // --- 1. Statusleisten ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBar("Hunger", hunger, Colors.green),
                _buildStatBar("Glück", happiness, Colors.pink),
              ],
            ),
          ),

          const Spacer(),

          // --- 2. Das Tier (PNG) ---
          Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Ein kleiner Schatten unter dem Tier
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                //PNG Bild
                Image.asset(
                  'assets/images/pet.png', // Hier Pfad zu deinem PNG einfügen
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  // Falls die Datei noch fehlt, zeigt ein Icon als Platzhalter
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.pets, size: 100, color: Colors.brown),
                ),
              ],
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
                _buildActionButton(Icons.restaurant, "Füttern", _feed),
                _buildActionButton(Icons.videogame_asset, "Spielen", _play),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hilfs-Widget für die Stats
  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  // Hilfs-Widget für die Buttons
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}