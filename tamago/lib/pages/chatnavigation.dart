import 'package:flutter/material.dart';
import 'package:tamago/pages/chat.dart';

// Da wir vorerst keine externen Imports nutzen, definieren wir die Klasse lokal 
// oder du importierst sie, falls sie in einer anderen Datei liegt.
class AppColors {
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color elementsPrimary = Color(0xFF505081);
  static const Color error = Color(0xFFBA1A1A);
}

class ChatNavigationTrigger extends StatelessWidget {
  final Color? color;

  const ChatNavigationTrigger({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final isChatOpen = ModalRoute.of(context)?.settings.name == '/chat';

    return FloatingActionButton(
      heroTag: 'chat_button',
      // Nutzt elementsPrimary oder Error-Rot
      backgroundColor: isChatOpen ? AppColors.error : (color ?? AppColors.elementsPrimary),
      foregroundColor: AppColors.textLight,
      
      // Guide: Buttons sind Ovale/Circles (25px)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),

      onPressed: () {
        if (isChatOpen) {
          Navigator.pop(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
              settings: const RouteSettings(name: '/chat'),
            ),
          );
        }
      },
      child: Icon(isChatOpen ? Icons.close : Icons.chat_bubble),
    );
  }
}