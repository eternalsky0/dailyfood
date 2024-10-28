enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

class Meal {
  final int? id;
  final String name;
  final MealType type;
  final List<Dish> dishes;
  final String? imageUrl;
  final DateTime time;

  Meal({
    this.id,
    required this.name,
    required this.type,
    required this.dishes,
    this.imageUrl,
    required this.time,
  });

  double get totalCalories {
    return dishes.fold(0, (sum, dish) => sum + dish.totalCalories);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'image_url': imageUrl,
      'time': time.toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      type: MealType.values[map['type']],
      dishes: [], 
      imageUrl: map['image_url'],
      time: DateTime.parse(map['time']),
    );
  }
}


