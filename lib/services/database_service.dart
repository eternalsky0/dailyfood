import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ingredient.dart';
import '../models/dish.dart';
import '../models/meal.dart';
import '../models/day_card.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories_per_100g REAL NOT NULL,
        proteins_per_100g REAL NOT NULL,
        fats_per_100g REAL NOT NULL,
        carbs_per_100g REAL NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dish_ingredients (
        dish_id INTEGER,
        ingredient_id INTEGER,
        weight REAL NOT NULL,
        FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        time TEXT NOT NULL,
        image_url TEXT,
        day_id INTEGER,
        FOREIGN KEY (day_id) REFERENCES day_cards (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_dishes (
        meal_id INTEGER,
        dish_id INTEGER,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE day_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        week_day INTEGER NOT NULL
      )
    ''');
  }

  Future<int> createIngredient(Ingredient ingredient) async {
    final db = await database;
    return await db.insert('ingredients', ingredient.toMap());
  }

  Future<Ingredient> readIngredient(int id) async {
    final db = await database;
    final maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ingredient.fromMap(maps.first);
    } else {
      throw Exception('Ingredient not found');
    }
  }

  Future<List<DayCard>> getAllDayCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('day_cards');
    
    List<DayCard> dayCards = [];
    for (var map in maps) {
      DayCard dayCard = DayCard.fromMap(map);
      final meals = await getMealsForDay(dayCard.id!);
      dayCards.add(DayCard(
        id: dayCard.id,
        name: dayCard.name,
        weekDay: dayCard.weekDay,
        meals: meals,
      ));
    }
    return dayCards;
  }

  Future<List<Meal>> getMealsForDay(int dayId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meals',
      where: 'day_id = ?',
      whereArgs: [dayId],
    );

    List<Meal> meals = [];
    for (var map in maps) {
      Meal meal = Meal.fromMap(map);

      final dishes = await getDishesForMeal(meal.id!);
      meals.add(Meal(
        id: meal.id,
        name: meal.name,
        type: meal.type,
        dishes: dishes,
        imageUrl: meal.imageUrl,
        time: meal.time,
      ));
    }
    return meals;
  }

}