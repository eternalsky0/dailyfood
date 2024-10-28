class DayCard {
  final int? id;
  final String name;
  final int weekDay; 
  final List<Meal> meals;

  DayCard({
    this.id,
    required this.name,
    required this.weekDay,
    required this.meals,
  });

  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'week_day': weekDay,
    };
  }

  factory DayCard.fromMap(Map<String, dynamic> map) {
    return DayCard(
      id: map['id'],
      name: map['name'],
      weekDay: map['week_day'],
      meals: [], 
    );
  }
}