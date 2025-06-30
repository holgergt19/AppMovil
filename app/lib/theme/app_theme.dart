import 'package:flutter/material.dart';

class AppTheme {
  // Colores basados en la bandera tsáchila
  static const Color primary = Color(0xFF008000); // Verde
  static const Color secondary = Color(0xFFD32F2F); // Rojo
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF212121);
  static const Color accent = Color(0xFFFFC107); // Amarillo

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: accent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
