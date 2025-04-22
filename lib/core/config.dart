import 'package:flutter/material.dart';

// Import your auth pages (e.g., login.dart) as needed/// ------------------------
/// THEME DEFINITIONS
/// ------------------------
final ThemeData blueLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF0D47A1),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D47A1),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.black87, fontSize: 20),
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF0D47A1),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFFC107),
    onSecondary: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.grey,
    onSurface: Colors.black,
  ),
);

final ThemeData indigoDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1A237E),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A237E),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF1A237E),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFFAB00),
    onSecondary: Colors.black,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey,
    onSurface: Colors.white,
  ),
);

final ThemeData greenLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF388E3C),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF388E3C),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C)),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.black87, fontSize: 20),
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF388E3C),
    onPrimary: Colors.white,
    secondary: const Color(0xFF81C784),
    onSecondary: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.grey,
    onSurface: Colors.black,
  ),
);

final ThemeData greenDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF2E7D32),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D32),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF2E7D32),
    onPrimary: Colors.white,
    secondary: const Color(0xFF66BB6A),
    onSecondary: Colors.black,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey,
    onSurface: Colors.white,
  ),
);

final ThemeData redLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFD32F2F),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD32F2F),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.black87, fontSize: 20),
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFD32F2F),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFF5252),
    onSecondary: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.grey,
    onSurface: Colors.black,
  ),
);

final ThemeData redDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFB71C1C),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB71C1C),
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFB71C1C),
    onPrimary: Colors.white,
    secondary: const Color(0xFFD32F2F),
    onSecondary: Colors.black,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey,
    onSurface: Colors.white,
  ),
);
