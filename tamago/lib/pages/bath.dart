import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';

class BathroomScreen extends StatefulWidget {
  const BathroomScreen({super.key});
  @override
  State<BathroomScreen> createState() => _BathroomScreenState();
}


class _BathroomScreenState extends State<BathroomScreen> {
  int _frameIndex = 0;
  Timer? _timer;

  final List<String> _petFrames = [
    'assets/animations/BaseTama/BaseTama1.png',
    'assets/animations/BaseTama/BaseTama2.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _frameIndex = (_frameIndex + 1) % _petFrames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _petFrames[_frameIndex],
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pets, size: 100, color: Colors.brown),
              ),

              //const Icon(Icons.bathtub, size: 100, color: Colors.lightBlue),
              const SizedBox(height: 20),
              const Text('Bathroom', style: TextStyle(fontSize: 24)),
              const Text('Keep your pet clean.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  /* Clean logic */
                },
                child: const Text('Clean'),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: const ChatNavigationTrigger(color: Colors.lightBlue),
        ),
      ],
    );
  }
}
