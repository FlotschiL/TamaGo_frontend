import 'package:flutter/material.dart';
import "package:tamago/utils/RootInitializer.dart";
import "package:tamago/utils/injection_container.dart" as di;
import "package:tamago/pages/living.dart";
import "package:tamago/pages/kitchen.dart";
import "package:tamago/pages/bath.dart";
import "package:tamago/pages/store.dart";

void main() {
  // 1. Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. "Connect" the container by running the registration logic
  // Use 'await' if your init function is asynchronous
  di.init();

  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamaGo!',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start at the Login Screen
      home: const RootInitializer(),
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
    const StoreScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
