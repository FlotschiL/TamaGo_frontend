class GameState {
  final int id;
  final String name;
  final bool nameSet;
  final String? activeSkin; // Marked nullable since the API returned null
  final int hunger;
  final int health;
  final bool alive;
  final bool sick;
  final List<Emotion> emotions;

  GameState({
    required this.id,
    required this.name,
    required this.nameSet,
    this.activeSkin,
    required this.hunger,
    required this.health,
    required this.alive,
    required this.sick,
    required this.emotions,
  });

  // Convert a Map (parsed JSON) into a GameState object
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      id: json['id'],
      name: json['name'],
      nameSet: json['nameSet'] ?? false,
      activeSkin: json['activeSkin'],
      hunger: json['hunger'],
      health: json['health'],
      alive: json['alive'],
      sick: json['sick'] ?? false,
      emotions: (json['emotions'] as List? ?? [])
          .map((emotionJson) => Emotion.fromJson(emotionJson as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert a GameState object back into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameSet': nameSet,
      'activeSkin': activeSkin,
      'hunger': hunger,
      'health': health,
      'alive': alive,
      'sick': sick,
      'emotions': emotions.map((emotion) => emotion.toJson()).toList(),
    };
  }
}

class Emotion {
  final int id;
  final String emotionType;
  final int intensity;

  Emotion({
    required this.id,
    required this.emotionType,
    required this.intensity,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      id: json['id'],
      emotionType: json['emotionType'],
      intensity: json['intensity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotionType': emotionType,
      'intensity': intensity,
    };
  }
}