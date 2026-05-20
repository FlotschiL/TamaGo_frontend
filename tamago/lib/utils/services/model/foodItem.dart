class FoodItem {
  final int id;
  final String name;
  final int saturation;

  FoodItem({
    required this.id, 
    required this.name, 
    required this.saturation,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      saturation: json['saturation'] as int? ?? 0,
    );
  }
}
