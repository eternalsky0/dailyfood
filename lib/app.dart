import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';

class FoodDiaryApp extends StatelessWidget {
  const FoodDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}