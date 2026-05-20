import 'package:flutter/material.dart';
import 'package:tamago/pages/chat.dart';
// Make sure this import points to your actual chat_screen file
import 'package:tamago/pages/chat_list_screen.dart';
import 'package:tamago/utils/services/api_manager.dart';
import 'package:tamago/utils/services/friend_service.dart';
import 'package:tamago/utils/services/model/friend.dart';

class TamaContact {
  final String name;
  final String lastMessage;
  final int sessionId;
  final Color color;

  const TamaContact({
    required this.name,
    required this.lastMessage,
    required this.sessionId,
    required this.color,
  });
}
class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late FriendService _friendService;

  @override
  void initState() {
    super.initState();
    // Initialize your new service
    _friendService = FriendService(ApiClient());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text("Tama-Freunde"),
        backgroundColor: AppColors.elementsPrimary,
        actions: [
          // Add a button to see pending requests
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddFriendDialog(context),
          )
        ],
      ),
      body: FutureBuilder<List<Friend>>(
        future: _friendService.getFriendsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(child: Text("Noch keine Freunde gefunden."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                color: AppColors.bgSecondary,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Bereit zum Chatten!"),
                  onTap: () => _startChat(context, friend.username),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Freund hinzufügen"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Username eingeben"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
          ElevatedButton(
            onPressed: () async {
              final success = await _friendService.sendFriendRequest(controller.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Anfrage gesendet!" : "Fehler beim Senden")),
                );
              }
            }, 
            child: const Text("Senden"),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, String friendName) {
     // Your existing navigation to ChatScreen
  }
}