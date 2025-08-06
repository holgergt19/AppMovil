import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores base (originales conservados)
  static const Color primary = Color(0xFF008000); // Verde
  static const Color secondary = Color(0xFFD32F2F); // Rojo
  static const Color accent = Color(0xFFFFC107); // Amarillo

  // Paleta "Dark-Chrome"
  static final Color background = const Color(0xFF121416);
  static final Color surface = const Color(0xFF1B1F24);
  static final Color surfaceVariant = const Color(0xFF2E3033);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ColorScheme adaptado
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      background: background,
      surface: surface,
      surfaceVariant: surfaceVariant,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.white70,
      onSurface: Colors.white70,
    ),

    // Fondo principal
    scaffoldBackgroundColor: background,

    // Tipografía moderna con Poppins
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white70, displayColor: Colors.white),

    // AppBar estilo cromado oscuro
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      centerTitle: true,
      elevation: 4,
      surfaceTintColor: primary,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Campos de entrada con efecto metálico oscuro
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface.withOpacity(0.4),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
      labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: surfaceVariant, width: 1.2),
      ),
      prefixIconColor: accent,
    ),

    // Botones elevados con esquinas redondeadas y sombra suave
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        shadowColor: Colors.black45,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Enlaces y TextButton con acento cromado
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Scroll overscroll desactivado
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
