import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[800],
  colorScheme: ColorScheme.dark(
    secondary: Colors.grey[600] ?? Colors.grey, // Providing a default color
  ),
  canvasColor: Colors.grey[900],
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
  ),
);

