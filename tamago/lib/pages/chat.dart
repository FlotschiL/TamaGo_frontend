import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
import 'package:tamago/utils/services/chat_service.dart';
import 'package:tamago/utils/services/api_manager.dart';
import 'package:tamago/utils/services/friend_service.dart'; // Ensure this path is correct
import 'package:tamago/utils/services/model/friend.dart'; // Ensure this path is correct

// Farben (Consistent with your existing theme)
abstract class AppColors {
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color textDark = Color(0xFF161616);
  static const Color bgPrimary = Color(0xFFFDF9AC);
  static const Color bgSecondary = Color(0xFFDAD68F);
  static const Color elementsPrimary = Color(0xFF505081);
  static const Color elementsSecondary = Color(0xFF78A083);
}

// --- CHAT SCREEN ---
class ChatScreen extends StatefulWidget {
  final String tamaName;
  final int? initialSessionId;

  const ChatScreen({
    super.key,
    this.tamaName = "Tama",
    this.initialSessionId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ChatService _chatService;

  int? _currentSessionId;
  bool _isLoading = true;
  bool _isTyping = false;

  final TextStyle _headingStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  final TextStyle _bodyStyle = const TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(ApiClient());

    if (widget.initialSessionId != null) {
      _currentSessionId = widget.initialSessionId;
      _loadHistory();
      _isLoading = false;
    } else {
      _initializeChat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final sessions = await _chatService.getSessions();
      if (sessions.isNotEmpty) {
        _currentSessionId = sessions.last['id'];
      } else {
        final newSession = await _chatService.createSession("Neuer Chat");
        _currentSessionId = newSession['id'];
      }
      await _loadHistory();
    } catch (e) {
      debugPrint("Initialisierungsfehler: $e");
      _showError("Chat konnte nicht geladen werden.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    if (_currentSessionId == null) return;
    try {
      final history = await _chatService.getSessionHistory(_currentSessionId!);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (var msg in history) {
          bool userFlag = msg['fromUser'] == true || msg['fromUser'] == 1;
          _messages.insert(0, {"text": msg['content'] ?? "", "isUser": userFlag});
        }
      });
    } catch (e) {
      _showError("Historie konnte nicht geladen werden.");
    }
  }

  Future<void> _handleSend() async {
    if (_controller.text.trim().isEmpty || _currentSessionId == null) return;
    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.insert(0, {"text": userText, "isUser": true});
      _isTyping = true;
    });

    try {
      final aiReply = await _chatService.talkToAI(userText, _currentSessionId!);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.insert(0, {"text": aiReply, "isUser": false});
      });
    } catch (e) {
      if (mounted) setState(() => _isTyping = false);
      _showError("Tama ist gerade schüchtern.");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.elementsPrimary,
        title: Text("Chat mit ${widget.tamaName}", style: _headingStyle.copyWith(color: AppColors.textLight)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == 0) return _buildTypingIndicator();
                      final msgIndex = _isTyping ? index - 1 : index;
                      if (msgIndex < 0 || msgIndex >= _messages.length) return const SizedBox();
                      final msg = _messages[msgIndex];
                      return _buildMessageBubble(msg['text'], msg['isUser']);
                    },
                  ),
                ),
                _buildInput(),
              ],
            ),
      floatingActionButton: const ChatNavigationTrigger(),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(8)),
        child: const Text("...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.elementsSecondary : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: _bodyStyle.copyWith(color: isUser ? AppColors.textLight : AppColors.textDark)),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.bgSecondary, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: _bodyStyle,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgPrimary,
                hintText: "Schreib etwas...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(color: AppColors.elementsPrimary, shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.send, color: AppColors.textLight), onPressed: _handleSend),
          ),
        ],
      ),
    );
  }
}

// --- FRIEND LIST SCREEN ---
class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late FriendService _friendService;
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _friendService = FriendService(client);
    _chatService = ChatService(client);
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text("Tama-Freunde"),
        backgroundColor: AppColors.elementsPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Ausstehende Anfragen"),
              _buildPendingRequests(),
              _buildSectionTitle("Meine Freunde"),
              _buildFriendsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.elementsPrimary)),
    );
  }

  Widget _buildPendingRequests() {
    return FutureBuilder<List<Friend>>(
      future: _friendService.getPendingRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final request = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: AppColors.bgSecondary.withOpacity(0.5),
              child: ListTile(
                title: Text(request.username),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        if (request.id != null) {
                          await _friendService.acceptFriendRequest(request.id!);
                          _refresh();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFriendsList() {
    return FutureBuilder<List<Friend>>(
      future: _friendService.getFriendsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Noch keine Freunde gefunden.")));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final friend = snapshot.data![index];
            return ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.elementsSecondary, child: Icon(Icons.pets, color: Colors.white)),
              title: Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Klick zum Chatten"),
              onTap: () => _startChat(context, friend.username),
            );
          },
        );
      },
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Freund hinzufügen"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Username eingeben")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
          ElevatedButton(
            onPressed: () async {
              await _friendService.sendFriendRequest(controller.text);
              if (mounted) Navigator.pop(context);
              _refresh();
            },
            child: const Text("Senden"),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, String friendName) async {
    try {
      final session = await _chatService.createSession("Chat mit $friendName");
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatScreen(initialSessionId: session['id'], tamaName: friendName)),
      );
    } catch (e) {
      debugPrint("Fehler: $e");
    }
  }
}