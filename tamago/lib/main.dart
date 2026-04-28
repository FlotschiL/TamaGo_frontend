import 'package:flutter/material.dart';
import "package:tamago/utils/RootInitializer.dart";
import "package:tamago/utils/api_manager.dart";
import "package:tamago/utils/injection_container.dart" as di;
import "package:tamago/pages/living.dart";
import "package:tamago/pages/kitchen.dart";
import "package:tamago/pages/bath.dart";
import "package:tamago/pages/store.dart";
import 'package:tamago/Objects/game_state.dart';
import 'package:get_it/get_it.dart';
import "package:tamago/utils/app_colors.dart";


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint("Initializing DI...");
    di.init();
    debugPrint("Starting App...");
  } catch (e, stack) {
    debugPrint("CRASH DURING INIT: $e");
    debugPrint(stack.toString());
  }

  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamaGo!',
      theme: ThemeData(
      useMaterial3: true,
      colorScheme: myColorScheme,
      // You can also define global text styles here
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
      ),
    ),
      home: const RootInitializer(),
    );
  }
}


// ==========================================
// MAIN NAVIGATION SHELL (The "Rooms")
// ==========================================
class MainGameNavigation extends StatefulWidget {
  const MainGameNavigation({super.key});

  @override
  State<MainGameNavigation> createState() => _MainGameNavigationState();
}

class _MainGameNavigationState extends State<MainGameNavigation> {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  int _currentIndex = 0;
  GameState? _gameState;

  final List<Widget> _rooms = [
    const LivingRoomPage(),
    const KitchenScreen(),
    const BathroomScreen(),
    const StoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    try {
      final state = await _apiClient.getGameState();
      setState(() => _gameState = state);
    } catch (e) {
      debugPrint("Failed to load game state in nav: $e");
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleLogout() {
    GetIt.I<ApiClient>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootInitializer()),
      (route) => false,
    );
  }

  Future<void> _showRenameDialog() async {
    final controller = TextEditingController(text: _gameState?.name ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename your pet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _gameState?.name) {
      try {
        await _apiClient.rename(newName);
        _loadGameState(); // Refresh to show new name
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to rename: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _gameState?.name ?? 'Tamagotchi',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Rename pet',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _showRenameDialog,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 28),
            onSelected: (value) {
              if (value == 'profile') { /* Navigator.push... */ }
              if (value == 'settings') { /* Navigator.push... */ }
              if (value == 'logout') _handleLogout();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _rooms,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
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
