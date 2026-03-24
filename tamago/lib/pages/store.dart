import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text('Store', style: TextStyle(fontSize: 24)),
          const Text('Buy stuff for you pet!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { /* Feed logic */ },
            child: const Text('Buy'),
          )
        ],
      ),
    );
  }
}