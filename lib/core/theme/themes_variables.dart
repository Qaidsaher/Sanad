import 'package:flutter/material.dart';

/// ------------------------
/// THEME DEFINITIONS
/// ------------------------

/// Blue Light Theme
final ThemeData blueLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF1976D2), // Changed from green to blue
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1976D2), // Changed from green to blue
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
      backgroundColor: const Color(0xFF1976D2), // Changed from green to blue
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: TextTheme(
    // Text colors remain largely the same as they are mostly black/white
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
      // White labels should still work well on blue buttons
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(color: Colors.white, fontSize: 14),
    labelSmall: const TextStyle(color: Colors.white, fontSize: 12),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1976D2), // Changed from green to blue
    onPrimary: Colors.white,
    secondary: Color(0xFF64B5F6), // Changed from light green to light blue
    onSecondary:
        Colors.black, // Or Colors.white if the light blue is very light
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    error: Color(0xFFD32F2F), // Standard error color
    onError: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.blue.shade50, // Changed from green.shade50
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor:
        Colors
            .blue
            .shade200, // Changed from green.shade100, slightly darker for visibility
    suffixIconColor:
        Colors
            .blue
            .shade200, // Changed from green.shade100, slightly darker for visibility
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF1976D2),
  ), // Changed from green to blue
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  // You might want to add other specific theme properties if needed for a blue theme
  // For example, FloatingActionButtonThemeData, TabBarTheme, etc.
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF1976D2), // Primary blue
    foregroundColor: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF1976D2), // Primary blue
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF1976D2); // Selected checkbox color: primary blue
      }
      return null; // Use default color for other states (e.g., unselected)
    }),
    checkColor: MaterialStateProperty.all<Color?>(
      Colors.white,
    ), // Color of the check mark
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF1976D2); // Selected radio color: primary blue
      }
      return null; // Use default color for other states
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFF1976D2,
        ); // Thumb color when switch is on: primary blue
      }
      return null; // Use default color for other states
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF1976D2).withAlpha(
          0x80,
        ); // Track color when switch is on: lighter primary blue
      }
      return null; // Use default color for other states
    }),
  ),
);

/// Indigo Dark Theme
final ThemeData indigoDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(
    0xFF64B5F6,
  ), // Brighter Blue (Blue 300) for dark theme
  scaffoldBackgroundColor: const Color(
    0xFF121212,
  ), // Standard dark theme background
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1565C0), // Darker Blue (Blue 800) for AppBar
    elevation: 4, // Or 0 or 1 for a flatter dark theme look
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF64B5F6), // Brighter blue for buttons
      foregroundColor:
          Colors.black, // Black text on this brighter blue for contrast
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: const TextTheme(
    // Light text colors for dark backgrounds
    displayLarge: TextStyle(color: Colors.white70, fontSize: 57),
    displayMedium: TextStyle(color: Colors.white70, fontSize: 45),
    displaySmall: TextStyle(color: Colors.white70, fontSize: 36),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(color: Colors.white70, fontSize: 16),
    titleSmall: TextStyle(color: Colors.white54, fontSize: 14),
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
    labelLarge: TextStyle(
      // For buttons etc.
      color: Colors.black, // Matching ElevatedButton foregroundColor
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      color: Colors.black87,
      fontSize: 14,
    ), // Adjust if used on dark bg
    labelSmall: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ), // Adjust if used on dark bg
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF64B5F6), // Brighter Blue (Blue 300)
    onPrimary: Colors.black, // Text on primary color
    secondary: const Color(
      0xFF90CAF9,
    ), // Even Lighter Blue (Blue 200) for accents
    onSecondary: Colors.black, // Text on secondary color
    background: const Color(0xFF121212),
    onBackground: Colors.white70,
    surface: const Color(0xFF1E1E1E), // Slightly lighter than background
    onSurface: Colors.white,
    error: const Color(0xFFCF6679), // Standard dark theme error color
    onError: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color(0xFF64B5F6),
        width: 2.0,
      ), // Primary color focus
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.grey.shade400,
    suffixIconColor: Colors.grey.shade400,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF64B5F6),
  ), // Use the brighter primary blue
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: const Color(0xFF1E1E1E), // Surface color for cards
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF64B5F6), // Primary blue
    foregroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF64B5F6), // Primary blue
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF64B5F6); // Selected checkbox color: primary blue
      }
      return Colors.grey.shade700; // Unselected color
    }),
    checkColor: MaterialStateProperty.all<Color?>(
      Colors.black,
    ), // Color of the check mark
    side: BorderSide(color: Colors.grey.shade600),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF64B5F6); // Selected radio color: primary blue
      }
      return Colors.grey.shade700;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF64B5F6); // Thumb color when switch is on
      }
      return Colors.grey.shade400;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFF64B5F6,
        ).withOpacity(0.5); // Track color when switch is on
      }
      return Colors.grey.shade700;
    }),
    trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.12),
    thickness: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.12),
    labelStyle: TextStyle(color: Colors.white70),
    selectedColor: const Color(0xFF64B5F6).withOpacity(0.3),
    secondarySelectedColor: const Color(0xFF64B5F6),
    padding: const EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2A2A2A),
    textStyle: const TextStyle(color: Colors.white70),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(
      0xFF1565C0,
    ), // Can match AppBar or be a surface color
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white.withOpacity(0.7),
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white.withOpacity(0.7),
    indicatorColor: const Color(0xFF64B5F6), // Primary blue for indicator
    indicatorSize: TabBarIndicatorSize.tab,
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
  primaryColor: const Color(
    0xFF66BB6A,
  ), // A slightly brighter green (Green 400) for dark theme
  scaffoldBackgroundColor: const Color(
    0xFF121212,
  ), // Standard dark theme background
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D32), // Darker Green (Green 800) for AppBar
    elevation: 4, // Or 0 or 1 for a flatter dark theme look if preferred
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF66BB6A), // Brighter green for buttons
      foregroundColor:
          Colors.black, // Black text on this brighter green for contrast
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: const TextTheme(
    // Light text colors for dark backgrounds
    displayLarge: TextStyle(color: Colors.white70, fontSize: 57),
    displayMedium: TextStyle(color: Colors.white70, fontSize: 45),
    displaySmall: TextStyle(color: Colors.white70, fontSize: 36),
    headlineLarge: TextStyle(
      color: Colors.white, // More emphasis for headlines
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(color: Colors.white70, fontSize: 16),
    titleSmall: TextStyle(color: Colors.white54, fontSize: 14),
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
    labelLarge: TextStyle(
      // For buttons etc.
      color: Colors.black, // Matching ElevatedButton foregroundColor
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(color: Colors.black87, fontSize: 14),
    labelSmall: TextStyle(color: Colors.black54, fontSize: 12),
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF66BB6A), // Brighter Green (Green 400)
    onPrimary: Colors.black, // Text on primary color
    secondary: const Color(
      0xFF81C784,
    ), // Light Green (Green 300), can be adjusted
    onSecondary: Colors.black, // Text on secondary color
    background: const Color(0xFF121212),
    onBackground: Colors.white70,
    surface: const Color(
      0xFF1E1E1E,
    ), // Slightly lighter than background for cards, dialogs
    onSurface: Colors.white,
    error: const Color(0xFFCF6679), // Standard dark theme error color
    onError: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.08), // Subtle fill for text fields
    hintStyle: TextStyle(color: Colors.grey.shade500),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700), // Visible border
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color(0xFF66BB6A),
        width: 2.0,
      ), // Primary color focus
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.grey.shade400,
    suffixIconColor: Colors.grey.shade400,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF66BB6A),
  ), // Use the brighter primary green
  cardTheme: CardTheme(
    elevation: 2, // Lower elevation can look better in dark themes
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: const Color(0xFF1E1E1E), // Surface color for cards
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF66BB6A), // Primary green
    foregroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF66BB6A), // Primary green
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFF66BB6A,
        ); // Selected checkbox color: primary green
      }
      return Colors.grey.shade700; // Unselected color
    }),
    checkColor: MaterialStateProperty.all<Color?>(
      Colors.black,
    ), // Color of the check mark
    side: BorderSide(color: Colors.grey.shade600),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF66BB6A); // Selected radio color: primary green
      }
      return Colors.grey.shade700; // Unselected color
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF66BB6A); // Thumb color when switch is on
      }
      return Colors.grey.shade400; // Thumb color when switch is off
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFF66BB6A,
        ).withOpacity(0.5); // Track color when switch is on
      }
      return Colors.grey.shade700; // Track color when switch is off
    }),
    trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.12),
    thickness: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.12),
    labelStyle: TextStyle(color: Colors.white70),
    selectedColor: const Color(0xFF66BB6A).withOpacity(0.3),
    secondarySelectedColor: const Color(
      0xFF66BB6A,
    ), // For avatar circle when selected
    padding: const EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2A2A2A), // Darker surface for popups
    textStyle: const TextStyle(color: Colors.white70),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(
      0xFF2E7D32,
    ), // Can match AppBar or be a surface color
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white.withOpacity(0.7),
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white, // Color for the selected tab's label
    unselectedLabelColor: Colors.white.withOpacity(
      0.7,
    ), // Color for unselected tab labels
    indicatorColor: const Color(0xFF66BB6A), // Color of the tab indicator.
    indicatorSize: TabBarIndicatorSize.tab,
  ),
);

/// Red Light Theme
final ThemeData redLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFD32F2F), // Changed to red
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD32F2F), // Changed to red
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
      backgroundColor: const Color(0xFFD32F2F), // Changed to red
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: TextTheme(
    // Text colors remain largely the same
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
      // White labels good on red buttons
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(color: Colors.white, fontSize: 14),
    labelSmall: const TextStyle(color: Colors.white, fontSize: 12),
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFD32F2F), // Changed to red
    onPrimary: Colors.white,
    secondary: const Color(0xFFE57373), // Changed to light red
    onSecondary: Colors.black, // Or Colors.white if the light red is very light
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    error: const Color(
      0xFFB00020,
    ), // A common error red, distinct or same as primary
    onError: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.red.shade50, // Changed to red.shade50
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.red.shade200, // Changed to red.shade200
    suffixIconColor: Colors.red.shade200, // Changed to red.shade200
  ),
  iconTheme: const IconThemeData(color: Color(0xFFD32F2F)), // Changed to red
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFD32F2F), // Primary red
    foregroundColor: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFD32F2F), // Primary red
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFD32F2F); // Selected checkbox color: primary red
      }
      return null;
    }),
    checkColor: MaterialStateProperty.all<Color?>(Colors.white),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFD32F2F); // Selected radio color: primary red
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFFD32F2F,
        ); // Thumb color when switch is on: primary red
      }
      return null;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFFD32F2F,
        ).withAlpha(0x80); // Track color: lighter primary red
      }
      return null;
    }),
  ),
);

/// Red Dark Theme
final ThemeData redDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(
    0xFFE57373,
  ), // Brighter Red (Red 300) for dark theme
  scaffoldBackgroundColor: const Color(
    0xFF121212,
  ), // Standard dark theme background
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFC62828), // Darker Red (Red 800) for AppBar
    elevation: 4, // Or 0 or 1 for a flatter dark theme look
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE57373), // Brighter red for buttons
      foregroundColor:
          Colors.black, // Black text on this brighter red for contrast
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textTheme: const TextTheme(
    // Light text colors for dark backgrounds
    displayLarge: TextStyle(color: Colors.white70, fontSize: 57),
    displayMedium: TextStyle(color: Colors.white70, fontSize: 45),
    displaySmall: TextStyle(color: Colors.white70, fontSize: 36),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(color: Colors.white70, fontSize: 16),
    titleSmall: TextStyle(color: Colors.white54, fontSize: 14),
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
    labelLarge: TextStyle(
      // For buttons etc.
      color: Colors.black, // Matching ElevatedButton foregroundColor
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      color: Colors.black87,
      fontSize: 14,
    ), // Consider context
    labelSmall: TextStyle(
      color: Colors.black54,
      fontSize: 12,
    ), // Consider context
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFE57373), // Brighter Red (Red 300)
    onPrimary: Colors.black, // Text on primary color
    secondary: const Color(
      0xFFEF9A9A,
    ), // Even Lighter Red (Red 200) for accents
    onSecondary: Colors.black, // Text on secondary color
    background: const Color(0xFF121212),
    onBackground: Colors.white70,
    surface: const Color(0xFF1E1E1E), // Slightly lighter than background
    onSurface: Colors.white,
    error: const Color(
      0xFFCF6679,
    ), // Standard dark theme error color (pinkish red)
    onError: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color(0xFFE57373),
        width: 2.0,
      ), // Primary color focus
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    prefixIconColor: Colors.grey.shade400,
    suffixIconColor: Colors.grey.shade400,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFE57373),
  ), // Use the brighter primary red
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: const Color(0xFF1E1E1E), // Surface color for cards
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFE57373), // Primary red
    foregroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFE57373), // Primary red
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFE57373); // Selected checkbox color: primary red
      }
      return Colors.grey.shade700; // Unselected color
    }),
    checkColor: MaterialStateProperty.all<Color?>(
      Colors.black,
    ), // Color of the check mark
    side: BorderSide(color: Colors.grey.shade600),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFE57373); // Selected radio color: primary red
      }
      return Colors.grey.shade700;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFE57373); // Thumb color when switch is on
      }
      return Colors.grey.shade400;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.selected)) {
        return const Color(
          0xFFE57373,
        ).withOpacity(0.5); // Track color when switch is on
      }
      return Colors.grey.shade700;
    }),
    trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.12),
    thickness: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.12),
    labelStyle: TextStyle(color: Colors.white70),
    selectedColor: const Color(0xFFE57373).withOpacity(0.3),
    secondarySelectedColor: const Color(0xFFE57373),
    padding: const EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2A2A2A),
    textStyle: const TextStyle(color: Colors.white70),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(
      0xFFC62828,
    ), // Can match AppBar or be a surface color
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white.withOpacity(0.7),
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white.withOpacity(0.7),
    indicatorColor: const Color(0xFFE57373), // Primary red for indicator
    indicatorSize: TabBarIndicatorSize.tab,
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
