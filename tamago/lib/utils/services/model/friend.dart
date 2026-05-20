class Friend {
  final int id; // acts as requestId for pending items
  final String username;
  final String status; // 'PENDING' or 'ACCEPTED'

  Friend({
    required this.id,
    required this.username,
    required this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? json['requestId'] ?? 0,
      username: json['username'] ?? 'Unknown User',
      status: json['status'] ?? 'ACCEPTED',
    );
  }
  factory Friend.fromUsername(String username) {
    return Friend(
      id: 0, // Fallback ID
      username: username,
      status: 'ACCEPTED', // Fallback status
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'status': status,
    };
  }
}