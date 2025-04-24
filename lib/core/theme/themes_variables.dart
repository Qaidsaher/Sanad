import 'package:flutter/material.dart';

/// ------------------------
/// THEME DEFINITIONS
/// ------------------------

/// Blue Light Theme
final ThemeData blueLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF0D47A1),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D47A1),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  // Elevated button styling
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
  ),
  // Additional button themes
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFF0D47A1),
      side: const BorderSide(color: Color(0xFF0D47A1)),
    ),
  ),
  // Card and icon styling
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
  // Input decoration styling
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.blue.shade50,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

/// Indigo Dark Theme
final ThemeData indigoDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1A237E),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A237E),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFF1A237E),
      side: const BorderSide(color: Color(0xFF1A237E)),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.indigo.shade900,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

/// Green Light Theme remains unchanged.
final ThemeData greenLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF388E3C),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF388E3C),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF388E3C),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(color: Colors.black87, fontSize: 57),
    displayMedium: const TextStyle(color: Colors.black87, fontSize: 45),
    displaySmall: const TextStyle(color: Colors.black87, fontSize: 36),
    headlineLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: const TextStyle(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: const TextStyle(
      color: Colors.black87,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle(color: Colors.black87, fontSize: 16),
    titleSmall: const TextStyle(color: Colors.black54, fontSize: 14),
    bodyLarge: const TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: const TextStyle(color: Colors.black87, fontSize: 14),
    bodySmall: const TextStyle(color: Colors.black54, fontSize: 12),
    labelLarge: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(color: Colors.white, fontSize: 14),
    labelSmall: const TextStyle(color: Colors.white, fontSize: 12),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF388E3C),
    onPrimary: Colors.white,
    secondary: Color(0xFF81C784),
    onSecondary: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.green.shade50,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.green.shade100,
    suffixIconColor: Colors.green.shade100,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
);

/// Green Dark Theme
final ThemeData greenDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF2E7D32),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D32),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      side: const BorderSide(color: Color(0xFF2E7D32)),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.green.shade800,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.green.shade300,
    suffixIconColor: Colors.green.shade300,
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

/// Red Light Theme
final ThemeData redLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFD32F2F),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD32F2F),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFFD32F2F),
      side: const BorderSide(color: Color(0xFFD32F2F)),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.red.shade50,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

/// Red Dark Theme
final ThemeData redDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFB71C1C),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB71C1C),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFFB71C1C),
      side: const BorderSide(color: Color(0xFFB71C1C)),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.red.shade900,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

/// Additional Green Themes with Enhanced Contrast

/// Green Contrast Light Theme
final ThemeData greenContrastLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2E7D32),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D32),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      side: const BorderSide(color: Color(0xFF2E7D32)),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(color: Colors.black87, fontSize: 57),
    displayMedium: const TextStyle(color: Colors.black87, fontSize: 45),
    displaySmall: const TextStyle(color: Colors.black87, fontSize: 36),
    headlineLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: const TextStyle(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: const TextStyle(
      color: Colors.black87,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: const TextStyle(
      color: Colors.black87,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle(color: Colors.black87, fontSize: 16),
    titleSmall: const TextStyle(color: Colors.black87, fontSize: 14),
    bodyLarge: const TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: const TextStyle(color: Colors.black87, fontSize: 14),
    bodySmall: const TextStyle(color: Colors.black87, fontSize: 12),
    labelLarge: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(color: Colors.white, fontSize: 14),
    labelSmall: const TextStyle(color: Colors.white, fontSize: 12),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2E7D32),
    onPrimary: Colors.white,
    secondary: Color(0xFF81C784),
    onSecondary: Colors.black87,
    background: Colors.white,
    onBackground: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.green.shade100,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.green.shade700,
    suffixIconColor: Colors.green.shade700,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
);

/// Green Contrast Dark Theme
final ThemeData greenContrastDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1B5E20),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B5E20),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFF1B5E20),
      side: const BorderSide(color: Color(0xFF1B5E20)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 16),
  ).apply(bodyColor: Colors.white, displayColor: Colors.white),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF1B5E20),
    onPrimary: Colors.white,
    secondary: const Color(0xFF66BB6A),
    onSecondary: Colors.black87,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey,
    onSurface: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.green.shade800,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.green.shade300,
    suffixIconColor: Colors.green.shade300,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
);
