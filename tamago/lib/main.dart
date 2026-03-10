import 'package:flutter/material.dart';
import "package:tamago/utils/login_screen.dart";
import "package:tamago/pages/living.dart";
void main() {
  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi Clone',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start at the Login Screen
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 2. MAIN NAVIGATION SHELL (The "Rooms")
// ==========================================
class MainGameNavigation extends StatefulWidget {
  const MainGameNavigation({super.key});

  @override
  State<MainGameNavigation> createState() => _MainGameNavigationState();
}

class _MainGameNavigationState extends State<MainGameNavigation> {
  int _currentIndex = 0;

  // List of our "Room" widgets. 
  // As your app grows, these will be moved to their own files.
  final List<Widget> _rooms = [
    const LivingRoomScreen(),
    const KitchenScreen(),
    const BathroomScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tamagotchi'),
        centerTitle: true,
        actions: [
          // A placeholder for overall stats (like coins or level)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Level 5', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      // The body switches out based on the selected navigation tab
      body: IndexedStack(
        index: _currentIndex,
        children: _rooms,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chair),
            label: 'Living Room',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Kitchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bathtub),
            label: 'Bathroom',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. THE ROOMS (UI Placeholders)
// ==========================================

/*class LivingRoomScreen extends StatelessWidget {
  const LivingRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chair, size: 100, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text('Living Room', style: TextStyle(fontSize: 24)),
          const Text('Where your pet rests and gets petted.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { /* Pet logic */ },
            child: const Text('Pet the Tamagotchi'),
          )
        ],
      ),
    );
  }
}
*/
class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text('Kitchen', style: TextStyle(fontSize: 24)),
          const Text('Time to eat!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { /* Feed logic */ },
            child: const Text('Feed'),
          )
        ],
      ),
    );
  }
}

class BathroomScreen extends StatelessWidget {
  const BathroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bathtub, size: 100, color: Colors.lightBlue),
          const SizedBox(height: 20),
          const Text('Bathroom', style: TextStyle(fontSize: 24)),
          const Text('Keep your pet clean.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { /* Clean logic */ },
            child: const Text('Clean'),
          )
        ],
      ),
    );
  }
}