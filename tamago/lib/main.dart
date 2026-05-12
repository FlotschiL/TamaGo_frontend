import 'package:flutter/material.dart';
import "package:tamago/utils/RootInitializer.dart";
import "package:tamago/utils/services/api_manager.dart";
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
  di.init();
  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamaGo!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: myColorScheme, // Your custom scheme
        // Force a blocky/monospace font globally for that retro feel
        fontFamily: 'monospace', 
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: AppColors.textDark),
        ),
      ),
      home: const RootInitializer(),
    );
  }
}

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
    const BathroomPage(), // Assuming this is your bath page
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
      debugPrint("Failed to load: $e");
    }
  }

  void _handleLogout() {
    GetIt.I<ApiClient>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootInitializer()),
      (route) => false,
    );
  }

  // --- RETRO RENAME DIALOG ---
  Future<void> _showRenameDialog() async {
    final controller = TextEditingController(text: _gameState?.name ?? '');
    final colorScheme = Theme.of(context).colorScheme;

    final newName = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => Container(), // Required
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: Border.all(color: colorScheme.onSurface, width: 4), // Sharp corners
            title: Text("NAME_YOUR_PET", style: TextStyle(color: colorScheme.primary, fontSize: 14)),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colorScheme.onSurface, width: 2)),
              ),
            ),
            actions: [
              _PixelActionBtn(
                label: "CANCEL", 
                onPressed: () => Navigator.pop(context), 
                color: colorScheme.surface
              ),
              _PixelActionBtn(
                label: "SAVE", 
                onPressed: () => Navigator.pop(context, controller.text.trim()), 
                color: colorScheme.secondary
              ),
            ],
          ),
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _gameState?.name) {
      try {
        await _apiClient.rename(newName);
        _loadGameState();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('RENAME_FAILED')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 4)),
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (_gameState?.name ?? 'TAMAGOTCHI').toUpperCase(),
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: _showRenameDialog,
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.account_box, color: colorScheme.onPrimary, size: 30),
                color: colorScheme.surface,
                offset: const Offset(0, 50),
                shape: Border.all(color: colorScheme.onSurface, width: 3), // Pixel menu
                onSelected: (value) {
                  if (value == 'logout') _handleLogout();
                },
                itemBuilder: (context) => [
                  _buildPixelPopupItem('profile', Icons.person, 'PROFILE'),
                  _buildPixelPopupItem('settings', Icons.settings, 'SETTINGS'),
                  const PopupMenuDivider(height: 1),
                  _buildPixelPopupItem('logout', Icons.logout, 'LOGOUT', isDestructive: true),
                ],
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _rooms,
      ),
      // --- CUSTOM PIXEL BOTTOM NAV ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.onSurface, // The "Outline" color
          border: Border(top: BorderSide(color: colorScheme.onSurface, width: 2)),
        ),
        child: BottomNavigationBar(
          backgroundColor: colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: colorScheme.onPrimary,
          unselectedItemColor: colorScheme.onPrimary.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: [
            _buildPixelNavItem(Icons.chair, 'HOME'),
            _buildPixelNavItem(Icons.restaurant, 'EAT'),
            _buildPixelNavItem(Icons.bathtub, 'WASH'),
            _buildPixelNavItem(Icons.shopping_cart, 'SHOP'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildPixelNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon, size: 28),
      ),
      label: label,
    );
  }

  PopupMenuItem<String> _buildPixelPopupItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : null, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : null)),
        ],
      ),
    );
  }
}

// --- Internal Helper for Pixel Buttons ---
class _PixelActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _PixelActionBtn({required this.label, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
        ),
        child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
    );
  }
}