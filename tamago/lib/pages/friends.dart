import 'package:flutter/material.dart';
import 'package:tamago/pages/chatnavigation.dart';
import 'package:tamago/utils/services/service_locator.dart';
import 'package:tamago/utils/services/model/friend.dart'; // Import the Friend model  
class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Friend> _friends = [];
  List<Friend> _pendingRequests = []; // Track separate API response payload
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFriendsAndRequests();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriendsAndRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Execute both API calls asynchronously in parallel
      final responses = await Future.wait([
        services.friend.getFriendsList(),
        services.friend.getPendingRequests(),
      ]);

      setState(() {
        _friends = responses[0];
        _pendingRequests = responses[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "FAILED TO SYNC PORTAL data: $e";
      });
    }
  }

  Future<void> _sendRequest() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final success = await services.friend.sendFriendRequest(username);
      _usernameController.clear();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("FRIEND REQUEST SENT!")),
        );
      }
      _fetchFriendsAndRequests();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "COULD NOT SEND REQUEST";
      });
    }
  }

  Future<void> _acceptRequest(int id) async {
    setState(() => _isLoading = true);
    try {
      final success = await services.friend.acceptFriendRequest(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("REQUEST ACCEPTED!")),
        );
      }
      _fetchFriendsAndRequests();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "COULD NOT ACCEPT REQUEST";
      });
    }
  }

  // --- UI PIXEL HELPERS ---

  Widget _buildPixelButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required ColorScheme colorScheme,
    double fontSize = 12,
  }) {
    final bool isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled ? colorScheme.surface.withOpacity(0.5) : color,
          border: Border.all(
            color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onSurface,
            width: 3,
          ),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: colorScheme.onSurface,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 16,
              color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onPrimary
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isDisabled ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(Friend friend, ColorScheme colorScheme) {
    final isPending = friend.status.toUpperCase() == 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        border: Border.all(color: colorScheme.onSurface, width: 3),
        boxShadow: [
          BoxShadow(color: colorScheme.onSurface, offset: const Offset(3, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.onSurface, width: 2),
              color: Colors.grey[200],
            ),
            child: Image.asset(
              'assets/animations/BaseTama/BaseTama1.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username.toUpperCase(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                if (isPending)
                  Text(
                    "INCOMING REQUEST",
                    style: TextStyle(fontSize: 10, color: colorScheme.secondary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          if (isPending)
            _buildPixelButton(
              label: "ACCEPT",
              icon: Icons.check,
              onPressed: () => _acceptRequest(friend.id),
              color: Colors.green,
              colorScheme: colorScheme,
              fontSize: 10,
            )
          else
            Icon(Icons.star, color: Colors.amber[600], size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: const ChatNavigationTrigger(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/living.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Top Control Bar
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.95),
                  border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 4)),
                ),
                child: Column(
                  children: [
                    Text(
                      "FRIENDS PORTAL",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border.all(color: colorScheme.onSurface, width: 3),
                            ),
                            child: TextField(
                              controller: _usernameController,
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "ENTER USERNAME...",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPixelButton(
                          label: "ADD",
                          icon: Icons.person_add,
                          onPressed: _isLoading ? null : _sendRequest,
                          color: colorScheme.primary,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Data Lists Section
              Expanded(
                child: _errorMessage != null
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: colorScheme.surface,
                          //border: Border.all(color: colorScheme.error, width: 3),
                          child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(top: 12, bottom: 80),
                        children: [
                          // Render Pending Requests from the dedicated endpoint
                          if (_pendingRequests.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              child: Text("REQUESTS (${_pendingRequests.length})", 
                                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 12)),
                            ),
                            ..._pendingRequests.map((f) => _buildFriendTile(f, colorScheme)),
                            const Divider(height: 24, thickness: 2, indent: 16, endIndent: 16),
                          ],
                          
                          // Render Established Friends
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Text("MY FRIENDS (${_friends.length})", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 12)),
                          ),
                          if (_friends.isEmpty && _pendingRequests.isEmpty && !_isLoading)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text("NO FRIENDS FOUND YET", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
                              ),
                            ),
                          ..._friends.map((f) => _buildFriendTile(f, colorScheme)),
                        ],
                      ),
              ),
            ],
          ),

          if (_isLoading)
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: colorScheme.secondary,
                  //border: Border.all(color: colorScheme.onSurface, width: 2),
                  child: Text("SYNCING...", style: TextStyle(color: colorScheme.onSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}