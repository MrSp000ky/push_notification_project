import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() {
    const seedColor = Color.fromARGB(255, 52, 255, 160);

    return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        listTileTheme: const ListTileThemeData(iconColor: seedColor));
  }
}