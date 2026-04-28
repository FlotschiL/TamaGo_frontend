import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';

// Lokale Kopie der AppColors für die Unabhängigkeit
abstract class AppColors {
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color textDark = Color(0xFF161616);
  static const Color bgPrimary = Color(0xFFFDF9AC);
  static const Color bgSecondary = Color(0xFFDAD68F);
  static const Color elementsPrimary = Color(0xFF505081);
  static const Color elementsSecondary = Color(0xFF78A083);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hallo! Wie geht es dir?", "sender": "Tama", "isUser": false},
  ];

  // Styles gemäß Style-Guide
  TextStyle get _bodyStyle => const TextStyle(
      fontFamily: 'JosefinSans', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic, color: AppColors.textDark);
  
  TextStyle get _headingStyle => const TextStyle(
      fontFamily: 'JosefinSans', fontWeight: FontWeight.w400, color: AppColors.textDark);

  void _handleSend() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.insert(0, {"text": _controller.text, "sender": "Du", "isUser": true});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text("Chat mit Tama", style: _headingStyle.copyWith(color: AppColors.textLight)),
        backgroundColor: AppColors.elementsPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // User = Secondary (Grün), Tama = Background Secondary (Beige)
                      color: isUser ? AppColors.elementsSecondary : AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(4), // Guide: 4px für Textboxen/Bubbles
                    ),
                    child: Text(msg['text'], style: _bodyStyle.copyWith(
                      color: isUser ? AppColors.textLight : AppColors.textDark
                    )),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
      floatingActionButton: const ChatNavigationTrigger(),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.bgSecondary,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: _bodyStyle,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgPrimary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                hintText: "Schreib etwas...",
                hintStyle: _bodyStyle.copyWith(
                  color: AppColors.textDark.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.elementsPrimary, borderRadius: BorderRadius.circular(25)),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.textLight),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}