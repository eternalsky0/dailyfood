class Dish {
  final int? id;
  final String name;
  final List<DishIngredient> ingredients;
  final String? imageUrl;

  Dish({
    this.id,
    required this.name,
    required this.ingredients,
    this.imageUrl,
  });

  double get totalCalories {
    return ingredients.fold(0, (sum, ingredient) => 
      sum + (ingredient.weight * ingredient.ingredient.caloriesPer100g / 100));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      name: map['name'],
      ingredients: [], 
      imageUrl: map['image_url'],
    );
  }
}

class DishIngredient {
  final Ingredient ingredient;
  final double weight; 

  DishIngredient({
    required this.ingredient,
    required this.weight,
  });
}