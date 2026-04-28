import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';


class ChatMessage {
  final String text;
  final String senderName;
  final bool isUser; // Um zu entscheiden, ob die Nachricht rechts oder links steht

  ChatMessage({
    required this.text, 
    required this.senderName, 
    this.isUser = false
  });
}


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hallo! Wie geht es dir heute?", senderName: "Tama"),
  ];

  void _handleSend() {
    if (_controller.text.isEmpty) return;

    setState(() {
      // 1. Nachricht des Users hinzufügen
      _messages.insert(0, ChatMessage(
        text: _controller.text,
        senderName: "Du",
        isUser: true,
      ));
    });

    String userText = _controller.text;
    _controller.clear();

    // 2. Mockup-Antwort vom Tamagotchi (nach einer kurzen Verzögerung)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(0, ChatMessage(
            text: "Bitte füttern!",
            senderName: "Tama",
            isUser: false,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat mit Tama"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Nachrichten-Liste
          Expanded(
            child: ListView.builder(
              reverse: true, // Neue Nachrichten unten anzeigen
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          
          // Eingabebereich
          _buildInputArea(),
        ],
      ),
      floatingActionButton: const ChatNavigationTrigger(color: Colors.lightBlue),
    );
  }

  // Hilfs-Widget für die Sprechblasen
  Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.teal.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(15),
            bottomLeft: msg.isUser ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.senderName,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(msg.text),
          ],
        ),
      ),
    );
  }

  // Hilfs-Widget für das Textfeld
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Schreib etwas...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.teal),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}