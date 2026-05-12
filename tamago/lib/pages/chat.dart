import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tamago/pages/chatnavigation.dart';

// Lokale Kopie der AppColors
abstract class AppColors {
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color textDark = Color(0xFF161616);
  static const Color bgPrimary = Color(0xFFFDF9AC);
  static const Color bgSecondary = Color(0xFFDAD68F);
  static const Color elementsPrimary = Color(0xFF505081);
  static const Color elementsSecondary = Color(0xFF78A083);
}

class ChatScreen extends StatefulWidget {
  final String? authToken; // Der JWT Token von der Login-Seite
  const ChatScreen({super.key, this.authToken});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  int? _currentSessionId;
  
  // Konfiguration
  final String baseUrl = "http://localhost:8080";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // --- API LOGIK ---

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    try {
      // 1. Sitzungen abrufen
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/sessions'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (response.statusCode == 200) {
        List sessions = jsonDecode(response.body);
        if (sessions.isEmpty) {
          // 2. Wenn keine Sitzung existiert, eine neue erstellen
          await _createNewSession();
        } else {
          // Die neueste Sitzung nehmen
          _currentSessionId = sessions.last['id'];
          await _loadHistory();
        }
      }
    } catch (e) {
      _showError("Verbindung zum Server fehlgeschlagen.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewSession() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/sessions'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"title": "Chat mit Tama"}),
    );
    if (response.statusCode == 200) {
      final session = jsonDecode(response.body);
      _currentSessionId = session['id'];
    }
  }

  Future<void> _loadHistory() async {
    if (_currentSessionId == null) return;
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/sessions/$_currentSessionId/history'),
      headers: {'Authorization': 'Bearer ${widget.authToken}'},
    );

    if (response.statusCode == 200) {
      List history = jsonDecode(response.body);
      setState(() {
        _messages.clear();
        for (var msg in history) {
          _messages.add({
            "text": msg['content'],
            "isUser": msg['isFromUser'],
          });
        }
        // Umkehren für ListView.builder(reverse: true)
        _messages.sort((a, b) => b.hashCode.compareTo(a.hashCode)); 
      });
    }
  }

  Future<void> _handleSend() async {
    if (_controller.text.trim().isEmpty || _currentSessionId == null) return;

    final userText = _controller.text;
    _controller.clear();

    // Lokale UI sofort aktualisieren
    setState(() {
      _messages.insert(0, {"text": userText, "isUser": true});
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/llm/talk'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "message": userText,
          "sessionId": _currentSessionId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.insert(0, {"text": data['reply'], "isUser": false});
        });
      }
    } catch (e) {
      _showError("Nachricht konnte nicht gesendet werden.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI STYLES ---

  TextStyle get _bodyStyle => const TextStyle(
      fontFamily: 'JosefinSans', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic, color: AppColors.textDark);
  
  TextStyle get _headingStyle => const TextStyle(
      fontFamily: 'JosefinSans', fontWeight: FontWeight.w400, color: AppColors.textDark);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text("Chat mit Tama", style: _headingStyle.copyWith(color: AppColors.textLight)),
        backgroundColor: AppColors.elementsPrimary,
        elevation: 0,
        actions: [
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.textLight, strokeWidth: 2),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Neue Nachrichten unten
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.elementsSecondary : AppColors.bgSecondary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isUser ? 12 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 12),
                      ),
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
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
      ),
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
              onSubmitted: (_) => _handleSend(),
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