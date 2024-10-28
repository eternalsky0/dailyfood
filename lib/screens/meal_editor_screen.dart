import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal.dart';
import '../models/dish.dart';
import '../services/database_service.dart';
import '../widgets/image_picker_widget.dart';

class MealEditorScreen extends StatefulWidget {
  final Meal? meal;
  final int dayId;
  final VoidCallback onSaved;

  const MealEditorScreen({
    Key? key,
    this.meal,
    required this.dayId,
    required this.onSaved,
  }) : super(key: key);

  @override
  _MealEditorScreenState createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  MealType _selectedType = MealType.breakfast;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _imageUrl;
  List<Dish> _selectedDishes = [];

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      _nameController.text = widget.meal!.name;
      _selectedType = widget.meal!.type;
      _selectedTime = TimeOfDay.fromDateTime(widget.meal!.time);
      _imageUrl = widget.meal!.imageUrl;
      _selectedDishes = List.from(widget.meal!.dishes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal != null ? 'Редактировать прием пищи' : 'Новый прием пищи'),
        actions: [
          TextButton(
            onPressed: _saveMeal,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImagePickerWidget(
              initialImageUrl: _imageUrl,
              onImageSelected: (String? url) {
                setState(() {
                  _imageUrl = url;
                }); 
}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MealType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип приема пищи',
                border: OutlineInputBorder(),
              ),
              items: MealType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getMealTypeName(type)),
                );
              }).toList(),
              onChanged: (MealType? value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Время',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Блюда',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildDishList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addDish,
              icon: const Icon(Icons.add),
              label: const Text('Добавить блюдо'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishList() {
    return Column(
      children: [
        if (_selectedDishes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Нет добавленных блюд',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ...List.generate(_selectedDishes.length, (index) {
          final dish = _selectedDishes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: dish.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(dish.imageUrl!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.restaurant),
              title: Text(dish.name),
              subtitle: Text('${dish.totalCalories.toStringAsFixed(0)} ккал'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _selectedDishes.removeAt(index);
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _addDish() async {
    final result = await Navigator.push<Dish>(
      context,
      MaterialPageRoute(
        builder: (context) => const DishEditorScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDishes.add(result);
      });
    }
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack:
        return 'Перекус';
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final meal = Meal(
      id: widget.meal?.id,
      name: _nameController.text,
      type: _selectedType,
      dishes: _selectedDishes,
      imageUrl: _imageUrl,
      time: dateTime,
    );

    try {
      if (widget.meal == null) {
        await DatabaseService.instance.createMealForDay(widget.dayId, meal);
      } else {
        await DatabaseService.instance.updateMeal(meal);
      }

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при сохранении приема пищи'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}