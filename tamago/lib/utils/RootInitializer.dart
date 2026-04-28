import 'package:flutter/material.dart';
import "package:tamago/main.dart";
import "package:tamago/utils/login_screen.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:get_it/get_it.dart';
import 'package:tamago/utils/api_manager.dart';

class RootInitializer extends StatefulWidget {
  const RootInitializer({super.key});

  @override
  State<RootInitializer> createState() => _RootInitializerState();
}

class _RootInitializerState extends State<RootInitializer> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    const storage = FlutterSecureStorage();
    
    // 1. Check for stored credentials
    String? username = await storage.read(key: 'username');
    String? password = await storage.read(key: 'password');

    if (username == null || password == null) {
      _navigateToLogin();
      return;
    }

    // 2. Call Login API 
    // Assuming your api_manager is registered via GetIt or similar
    try {
      // Replace 'GetIt.I<ApiManager>()' with your actual injection call
      final res = await GetIt.I<ApiClient>().login(username, password);

      if (res) {
        _navigateToMain();
      } else {
        _navigateToLogin(error: "Couldn't connect to server");
      }
    } catch (e) {
      _navigateToLogin(error: "Connection error: $e");
    }
  }

  void _navigateToLogin({String? error}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen(errorMessage: error)),
    );
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TamagotchiApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is what the user sees while the checks are running
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Or your custom logo/splash
      ),
    );
  }
}