import 'package:flutter/material.dart';
import '../model/color_model.dart';

/// App Owner Color Configuration
/// Modify these colors to customize your app's appearance
class AppOwnerColors {
  // Set this to true to use owner-defined colors as default (users can still customize)
  static const bool useOwnerColorsAsDefault = true;
  
  // Set this to true to completely lock colors (hide color picker from users)
  static const bool hideColorPicker = false;
  
  // Owner-defined color schemes
  static const CustomColorScheme ownerLightScheme = CustomColorScheme(
    primary: Color(0xFF2E7D32), // Green
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC8E6C9),
    onPrimaryContainer: Color(0xFF1B5E20),
    secondary: Color(0xFF1976D2), // Blue
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFBBDEFB),
    onSecondaryContainer: Color(0xFF0D47A1),
    tertiary: Color(0xFF7B1FA2), // Purple
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE1BEE7),
    onTertiaryContainer: Color(0xFF4A148C),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFF81C784),
    surfaceTint: Color(0xFF2E7D32),
  );

  static const CustomColorScheme ownerDarkScheme = CustomColorScheme(
    primary: Color(0xFF81C784), // Light Green
    onPrimary: Color(0xFF1B5E20),
    primaryContainer: Color(0xFF388E3C),
    onPrimaryContainer: Color(0xFFC8E6C9),
    secondary: Color(0xFF64B5F6), // Light Blue
    onSecondary: Color(0xFF0D47A1),
    secondaryContainer: Color(0xFF1565C0),
    onSecondaryContainer: Color(0xFFBBDEFB),
    tertiary: Color(0xFFBA68C8), // Light Purple
    onTertiary: Color(0xFF4A148C),
    tertiaryContainer: Color(0xFF8E24AA),
    onTertiaryContainer: Color(0xFFE1BEE7),
    error: Color(0xFFEF5350),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: Color(0xFFFFCDD2),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF2E7D32),
    surfaceTint: Color(0xFF81C784),
  );

  // Alternative color schemes - you can create multiple themes
  static const CustomColorScheme alternativeLightScheme = CustomColorScheme(
    primary: Color(0xFFD32F2F), // Red
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFCDD2),
    onPrimaryContainer: Color(0xFFB71C1C),
    secondary: Color(0xFF5D4037), // Brown
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD7CCC8),
    onSecondaryContainer: Color(0xFF3E2723),
    tertiary: Color(0xFF455A64), // Blue Grey
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCFD8DC),
    onTertiaryContainer: Color(0xFF263238),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFFFAB91),
    surfaceTint: Color(0xFFD32F2F),
  );

  static const CustomColorScheme alternativeDarkScheme = CustomColorScheme(
    primary: Color(0xFFFFAB91), // Light Red
    onPrimary: Color(0xFFB71C1C),
    primaryContainer: Color(0xFFE53935),
    onPrimaryContainer: Color(0xFFFFCDD2),
    secondary: Color(0xFFBCAAA4), // Light Brown
    onSecondary: Color(0xFF3E2723),
    secondaryContainer: Color(0xFF5D4037),
    onSecondaryContainer: Color(0xFFD7CCC8),
    tertiary: Color(0xFF90A4AE), // Light Blue Grey
    onTertiary: Color(0xFF263238),
    tertiaryContainer: Color(0xFF455A64),
    onTertiaryContainer: Color(0xFFCFD8DC),
    error: Color(0xFFEF5350),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: Color(0xFFFFCDD2),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFFD32F2F),
    surfaceTint: Color(0xFFFFAB91),
  );

  // Method to get the current owner color scheme
  static CustomColorScheme getOwnerLightScheme() {
    // You can add logic here to switch between different schemes
    // For example, based on app version, user type, etc.
    return ownerLightScheme;
  }

  static CustomColorScheme getOwnerDarkScheme() {
    return ownerDarkScheme;
  }

  // Method to get alternative schemes
  static CustomColorScheme getAlternativeLightScheme() {
    return alternativeLightScheme;
  }

  static CustomColorScheme getAlternativeDarkScheme() {
    return alternativeDarkScheme;
  }
}
