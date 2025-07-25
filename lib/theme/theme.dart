import 'package:attendzone_new/theme/custom_theme/elevated_button_theme.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    onSurface: Colors.white,
    primary: Colors.black,
      secondary: Colors.grey.withOpacity(0.5),
      surfaceContainer: Colors.grey.shade100,
      onSecondary: Colors.grey,
  ),
  elevatedButtonTheme: EElevatedButtonTheme.lightElevatedButtonTheme
);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      onSurface: Colors.black,
      primary: Colors.white,
      secondary: Colors.transparent,
      surfaceContainer: Colors.grey.shade900,
      onSecondary: Colors.grey,
    ),
    elevatedButtonTheme: EElevatedButtonTheme.darkElevatedButtonTheme
);