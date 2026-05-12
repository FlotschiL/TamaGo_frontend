import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
import 'package:tamago/utils/services/chat_service.dart';
import 'package:tamago/utils/services/api_manager.dart';

// Farben
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
  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  late ChatService _chatService;

  int? _currentSessionId;

  bool _isLoading = true;
  bool _isTyping = false;

  // Styles
  final TextStyle _headingStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  final TextStyle _bodyStyle = const TextStyle(
    fontSize: 16,
  );

  @override
  void initState() {
    super.initState();

    _chatService = ChatService(ApiClient());

    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final sessions =
          await _chatService.getSessions();

      if (sessions.isNotEmpty) {
        // Neueste Session
        _currentSessionId =
            sessions.last['id'];
      } else {
        final newSession =
            await _chatService.createSession(
          "Neuer Chat",
        );

        _currentSessionId =
            newSession['id'];
      }

      await _loadHistory();
    } catch (e) {
      debugPrint(
        "Initialisierungsfehler: $e",
      );

      _showError(
        "Chat konnte nicht geladen werden.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    if (_currentSessionId == null) return;

    try {
      final history =
          await _chatService.getSessionHistory(
        _currentSessionId!,
      );

      if (!mounted) return;

      setState(() {
        _messages.clear();

        for (var msg in history) {
          _messages.insert(0, {
            "text": msg['content'] ?? "",
            "isUser":
                msg['isFromUser'] ?? false,
          });
        }
      });
    } catch (e) {
      debugPrint("History Fehler: $e");

      _showError(
        "Historie konnte nicht geladen werden.",
      );
    }
  }

  Future<void> _handleSend() async {
    if (_controller.text.trim().isEmpty ||
        _currentSessionId == null) {
      return;
    }

    final userText =
        _controller.text.trim();

    _controller.clear();

    setState(() {
      _messages.insert(0, {
        "text": userText,
        "isUser": true,
      });

      _isTyping = true;
    });

    try {
      final aiReply =
          await _chatService.talkToAI(
        userText,
        _currentSessionId!,
      );

      if (!mounted) return;

      setState(() {
        _isTyping = false;

        _messages.insert(0, {
          "text": aiReply,
          "isUser": false,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      _showError(
        "Tama ist gerade schüchtern (Verbindungsproblem).",
      );
    }
  }

  void _showError(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor:
            AppColors.elementsPrimary,

        title: Text(
          "Chat mit Tama",
          style: _headingStyle.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    itemCount:
                        _messages.length +
                            (_isTyping ? 1 : 0),

                    itemBuilder:
                        (context, index) {
                      // Typing Indicator
                      if (_isTyping &&
                          index == 0) {
                        return _buildTypingIndicator();
                      }

                      final msgIndex =
                          _isTyping
                              ? index - 1
                              : index;

                      // Sicherheit gegen negative Indizes
                      if (msgIndex < 0 ||
                          msgIndex >=
                              _messages
                                  .length) {
                        return const SizedBox();
                      }

                      final msg =
                          _messages[msgIndex];

                      return _buildMessageBubble(
                        msg['text'],
                        msg['isUser'],
                      );
                    },
                  ),
                ),

                _buildInput(),
              ],
            ),

      floatingActionButton:
          const ChatNavigationTrigger(),
    );
  }

  // Typing Animation
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        margin:
            const EdgeInsets.symmetric(
          vertical: 4,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: AppColors.bgSecondary,

          borderRadius:
              BorderRadius.circular(8),
        ),

        child: const Text(
          "...",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    bool isUser,
  ) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        margin:
            const EdgeInsets.symmetric(
          vertical: 4,
        ),

        padding: const EdgeInsets.all(12),

        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  0.75,
        ),

        decoration: BoxDecoration(
          color: isUser
              ? AppColors
                  .elementsSecondary
              : AppColors.bgSecondary,

          borderRadius:
              BorderRadius.circular(8),
        ),

        child: Text(
          text,
          style: _bodyStyle.copyWith(
            color: isUser
                ? AppColors.textLight
                : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,

              style: _bodyStyle,

              decoration: InputDecoration(
                filled: true,

                fillColor:
                    AppColors.bgPrimary,

                hintText:
                    "Schreib etwas...",

                hintStyle:
                    _bodyStyle.copyWith(
                  color: AppColors
                      .textDark
                      .withOpacity(0.5),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(8),

                  borderSide:
                      BorderSide.none,
                ),
              ),

              onSubmitted: (_) =>
                  _handleSend(),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration: BoxDecoration(
              color:
                  AppColors.elementsPrimary,

              borderRadius:
                  BorderRadius.circular(
                25,
              ),
            ),

            child: IconButton(
              icon: const Icon(
                Icons.send,
                color:
                    AppColors.textLight,
              ),

              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}