class GameState {
  final int id;
  final String name;
  final int hunger;
  final int health;
  final bool alive;

  GameState({
    required this.id,
    required this.name,
    required this.hunger,
    required this.health,
    required this.alive,
  });

  // Convert a Map (parsed JSON) into a GameState object
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      id: json['id'],
      name: json['name'],
      hunger: json['hunger'],
      health: json['health'],
      alive: json['alive'],
    );
  }

  // Convert a GameState object back into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hunger': hunger,
      'health': health,
      'alive': alive,
    };
  }
}