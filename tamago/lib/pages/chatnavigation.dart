// import 'package:flutter/material.dart';
// import 'chat.dart'; // Importiere hier deine Chat-Datei

// class ChatNavigationTrigger extends StatelessWidget {
//   final Color color;
//   final bool showBadge;

//   const ChatNavigationTrigger({
//     super.key,
//     this.color = Colors.teal,
//     this.showBadge = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.topRight,
//       children: [
//         FloatingActionButton(
//           heroTag: 'chat_button', // Wichtig, falls mehrere FABs existieren
//           backgroundColor: color,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const ChatScreen()),
//             );
//           },
//           child: const Icon(Icons.chat_bubble, color: Colors.white),
//         ),
//         if (showBadge)
//           Positioned(
//             right: 0,
//             top: 0,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
//               child: const Text(
//                 '1',
//                 style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
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