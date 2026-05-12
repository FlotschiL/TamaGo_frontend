import 'package:flutter/material.dart';

abstract class AppColors {
  // Text Colors
  static const Color textLight = Color(0xFFF7F5ED);
  static const Color textDark = Color(0xFF161616);

  // Backgrounds
  static const Color bgPrimary = Color(0xFFFDF9AC);
  static const Color bgSecondary = Color(0xFFDAD68F);

  // UI Elements
  static const Color elementsPrimary = Color(0xFF505081);
  static const Color elementsSecondary = Color(0xFF3F3F74);
}
final myColorScheme = ColorScheme(
    brightness: Brightness.light,
    
    // Primary "Element"
    primary: AppColors.elementsPrimary,
    onPrimary: AppColors.textLight, // White-ish text on dark blue
    
    // Secondary "Element"
    secondary: AppColors.elementsSecondary,
    onSecondary: AppColors.textLight,
    
    // Backgrounds
    background: AppColors.bgPrimary,
    onBackground: AppColors.textDark, // Dark text on light yellow
    
    // Surfaces (Cards, Dialogs)
    surface: AppColors.bgSecondary,
    onSurface: AppColors.textDark,
    
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
  );