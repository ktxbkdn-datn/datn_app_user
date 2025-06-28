import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade200,
  ),
  // Disable spell checking globally for all text fields
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.blue.withOpacity(0.3),
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // This will disable spell check for all TextFormField/TextField in the app
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  // These settings help prevent spell check highlighting
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    bodyLarge: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87),
    titleMedium: TextStyle(color: Colors.black87),
    titleSmall: TextStyle(color: Colors.black87),
    displayLarge: TextStyle(color: Colors.black87),
    displayMedium: TextStyle(color: Colors.black87),
    displaySmall: TextStyle(color: Colors.black87),
    headlineLarge: TextStyle(color: Colors.black87),
    headlineMedium: TextStyle(color: Colors.black87),
    headlineSmall: TextStyle(color: Colors.black87),
    labelLarge: TextStyle(color: Colors.black87),
    labelMedium: TextStyle(color: Colors.black87),
    labelSmall: TextStyle(color: Colors.black87),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
  ),
  // Disable spell checking globally for all text fields
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.blue.withOpacity(0.3),
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // This will disable spell check for all TextFormField/TextField in the app
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  // These settings help prevent spell check highlighting
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    bodyLarge: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white70),
    titleMedium: TextStyle(color: Colors.white70),
    titleSmall: TextStyle(color: Colors.white70),
    displayLarge: TextStyle(color: Colors.white70),
    displayMedium: TextStyle(color: Colors.white70),
    displaySmall: TextStyle(color: Colors.white70),
    headlineLarge: TextStyle(color: Colors.white70),
    headlineMedium: TextStyle(color: Colors.white70),
    headlineSmall: TextStyle(color: Colors.white70),
    labelLarge: TextStyle(color: Colors.white70),
    labelMedium: TextStyle(color: Colors.white70),
    labelSmall: TextStyle(color: Colors.white70),
  ),
);