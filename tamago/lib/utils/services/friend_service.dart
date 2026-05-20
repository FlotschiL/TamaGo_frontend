import 'package:flutter/widgets.dart';
import 'package:tamago/utils/services/api_manager.dart'; 
import 'model/friend.dart'; 

class FriendService {
  final ApiClient _client;
  FriendService(this._client);

  // Liste: GET /api/friends/list
  Future<List<Friend>> getFriendsList() async {
debugPrint("Fetching friends list...");
try {
  final res = await _client.dio.get('/api/friends/list');
  if (res.data == null) return [];
  
  // Normalize the data handle if it's nested in a "friends" key or just the raw body
  final data = res.data is Map && res.data['friends'] is List
      ? res.data['friends']
      : res.data;

  if (data is List) {
    // Check if the first element is a String to be safe, then map accordingly
    return data.map((item) {
      if (item is String) {
        // Option A: Use a custom constructor designed for just a username
        return Friend.fromUsername(item); 
        
        // Option B: If you don't want a new constructor, mock the map structure:
        // return Friend.fromJson({'username': item});
      }
      
      // Fallback if the API ever switches back to objects
      return Friend.fromJson(item as Map<String, dynamic>);
    }).toList();
  }
  return [];
} catch (e) {
  debugPrint('Error fetching friends list: $e');
  return [];
}
  }

  // NEW - Pending Requests: GET /api/friends/request/pending
  Future<List<Friend>> getPendingRequests() async {
    debugPrint("Fetching pending friend requests...");
    final res = await _client.dio.get('/api/friends/requests/pending');
    debugPrint(res.data.toString());
    if (res.data == null || res.data is! List) {
      return [];
    }
    return (res.data as List).map((json) {
      // Enforce 'PENDING' status for items returning from this endpoint
      final item = Friend.fromJson(json);
      return Friend(
        id: item.id, 
        username: item.username, 
        status: 'PENDING',
      );
    }).toList();
  }

  // Anfrage: POST /api/friends/request/{username}
  Future<bool> sendFriendRequest(String username) async {
    debugPrint("Sending friend request to: $username");
    final res = await _client.dio.post('/api/friends/request/$username');
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Annehmen: POST /api/friends/request/{requestId}/accept
  Future<bool> acceptFriendRequest(int requestId) async {
    debugPrint("Accepting friend request ID: $requestId");
    final res = await _client.dio.post('/api/friends/request/$requestId/accept');
    return res.statusCode == 200;
  }
}