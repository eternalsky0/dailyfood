class Ingredient {
  final int? id;
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final String? imageUrl;

  Ingredient({
    this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories_per_100g': caloriesPer100g,
      'proteins_per_100g': proteinsPer100g,
      'fats_per_100g': fatsPer100g,
      'carbs_per_100g': carbsPer100g,
      'image_url': imageUrl,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      caloriesPer100g: map['calories_per_100g'],
      proteinsPer100g: map['proteins_per_100g'],
      fatsPer100g: map['fats_per_100g'],
      carbsPer100g: map['carbs_per_100g'],
      imageUrl: map['image_url'],
    );
  }
}