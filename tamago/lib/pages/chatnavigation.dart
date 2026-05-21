import 'package:flutter/material.dart';
import 'package:tamago/pages/chat.dart';

class AppColors {
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color elementsPrimary = Color(0xFF505081);
}

class ChatNavigationTrigger extends StatelessWidget {
  final Color? color;

  const ChatNavigationTrigger({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final isChatOpen = ModalRoute.of(context)?.settings.name == '/chat';
    final colorScheme = Theme.of(context).colorScheme;

    // Wenn der Chat offen ist, verschwindet der Button komplett
    if (isChatOpen) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
            settings: const RouteSettings(name: '/chat'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color ?? AppColors.elementsPrimary,
          // Der markante Pixel-Rahmen
          border: Border.all(
            color: colorScheme.onSurface,
            width: 3,
          ),
          // Der harte "Retro"-Schatten ohne Blur
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              "CHAT",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}