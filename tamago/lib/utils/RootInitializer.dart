import 'package:flutter/material.dart';
import "package:tamago/main.dart";
import "package:tamago/utils/login_screen.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:get_it/get_it.dart';
import 'package:tamago/utils/services/api_manager.dart';

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
    // Adding a tiny delay or yielding to the event loop can help
    await Future.delayed(Duration.zero); 

    const storage = FlutterSecureStorage();
    final username = await storage.read(key: 'username');
    final password = await storage.read(key: 'password');

    if (username == null || password == null) {
      return _navigateToLogin();
    }

    try {
      // Ensure ApiClient is actually registered in GetIt before this runs!
      final res = await GetIt.I<ApiClient>().login(username, password);
      
      if (res) {
        _navigateToMain();
      } else {
        _navigateToLogin(error: "Session expired. Please login again.");
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
      MaterialPageRoute(builder: (context) => const MainGameNavigation()),
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