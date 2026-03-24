import 'package:flutter/material.dart';

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