import 'package:flutter/material.dart';

class AppThemes {
  // Tema untuk Mode Terang (Light Mode)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepOrange,
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade100,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepOrange.shade400,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // Tema untuk Mode Gelap (Dark Mode)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.amber,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepOrange.shade400,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}