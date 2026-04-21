import 'package:flutter/material.dart';
import 'package:tamago/pages/chat.dart';

class ChatNavigationTrigger extends StatelessWidget {
  final Color color;

  const ChatNavigationTrigger({
    super.key,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    // Prüfen, ob wir bereits im ChatScreen sind
    final isChatOpen = ModalRoute.of(context)?.settings.name == '/chat';

    return FloatingActionButton(
      heroTag: 'chat_button',
      backgroundColor: isChatOpen ? Colors.red : color, // Farbe ändern, wenn offen
      onPressed: () {
        if (isChatOpen) {
          // Wenn offen, dann schließen (zurück zum vorherigen Screen)
          Navigator.pop(context);
        } else {
          // Wenn geschlossen, zum Chat navigieren
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
              settings: const RouteSettings(name: '/chat'), // Name vergeben!
            ),
          );
        }
      },
      // Icon ändern: Chat-Blase oder Schließen-Kreuz
      child: Icon(
        isChatOpen ? Icons.close : Icons.chat_bubble,
        color: Colors.white,
      ),
    );
  }
}