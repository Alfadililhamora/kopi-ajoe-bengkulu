import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF231F1E);
  static const Color coffeeBrown = Color(0xFF4A2C2A);
  static const Color accentTerracotta = Color(0xFFC86D6B);
  static const Color creamSurface = Color(0xFFF7F3EE);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color statusOpen = Color(0xFF2E7D32);
  static const Color statusClosed = Color(0xFFC62828);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: coffeeBrown,
        primary: coffeeBrown,
        secondary: accentTerracotta,
        surface: creamSurface,
      ),
      scaffoldBackgroundColor: creamSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coffeeBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
