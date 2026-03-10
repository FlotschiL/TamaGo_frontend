import 'package:flutter/material.dart';
import "package:tamago/main.dart";
// ==========================================
// 1. LOGIN SCREEN (Auth Structure)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _mockLogin() {
    // TODO: Implement actual secure storage saving here later.
    final username = _usernameController.text;
    final password = _passwordController.text;
    print("Credentials saved for: $username (Bypassing auth...)");

    // Bypass login and navigate to the Main Game UI
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainGameNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _mockLogin,
                child: const Text('Enter Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
