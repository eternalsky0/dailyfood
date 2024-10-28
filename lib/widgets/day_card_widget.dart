import 'package:flutter/material.dart';
import '../models/day_card.dart';
import '../models/meal.dart';
import 'meal_card_widget.dart';

class DayCardWidget extends StatelessWidget {
  final DayCard dayCard;
  final VoidCallback onChanged;

  const DayCardWidget({
    Key? key,
    required this.dayCard,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayCard.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Всего калорий: ${dayCard.totalCalories.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayDetailsScreen(
                          dayCard: dayCard,
                          onSaved: onChanged,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: dayCard.meals.isEmpty
                ? Center(
                    child: Text(
                      'Нет приемов пищи',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayCard.meals.length,
                    itemBuilder: (context, index) {
                      return MealCardWidget(
                        meal: dayCard.meals[index],
                        onChanged: onChanged,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}