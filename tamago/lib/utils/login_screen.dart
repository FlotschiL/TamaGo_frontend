import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
// import 'package:tamago/api/api_manager.dart'; // Ensure this is imported
import 'package:tamago/main.dart';
import 'package:tamago/utils/services/api_manager.dart'; 

class LoginScreen extends StatefulWidget {
  final String? errorMessage;
  const LoginScreen({super.key, this.errorMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(widget.errorMessage!, isError: true);
      });
    }
  }

  // --- Logic for Login ---
  Future<void> _login() async {
    await _performAuthAction(
      action: () => GetIt.I<ApiClient>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      ),
      successMessage: "Welcome back!",
    );
  }

  // --- Logic for Register ---
  Future<void> _register() async {
    await _performAuthAction(
      action: () => GetIt.I<ApiClient>().register(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      ),
      successMessage: "Account created successfully!",
    );
  }

  // Helper to prevent code duplication for login/register
  Future<void> _performAuthAction({
    required Future<bool> Function() action,
    required String successMessage,
  }) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await action();

      if (success) {
        // Save credentials for auto-login next time
        await _storage.write(key: 'username', value: username);
        await _storage.write(key: 'password', value: password);


        if (!mounted) return;
        _showSnackBar(successMessage);
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainGameNavigation()),
        );
      } else {
        _showSnackBar("Action failed. Please try again.", isError: true);
      }
    } catch (e) {
      _showSnackBar("Connection error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                // Primary Action: Login
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enter Game'),
                ),
                const SizedBox(height: 12),
                // Secondary Action: Register
                OutlinedButton(
                  onPressed: _register,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.teal),
                  ),
                  child: const Text('Create New Account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}