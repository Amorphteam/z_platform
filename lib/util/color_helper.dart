import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../model/color_model.dart';
import '../config/app_owner_colors.dart';

enum ColorMode { dynamic, custom, owner }

class ColorHelper with ChangeNotifier {
  ColorMode _colorMode = AppOwnerColors.useOwnerColorsAsDefault ? ColorMode.owner : ColorMode.dynamic;
  CustomColorScheme? _customLightScheme;
  CustomColorScheme? _customDarkScheme;

  ColorMode get colorMode => _colorMode;
  CustomColorScheme? get customLightScheme => _customLightScheme;
  CustomColorScheme? get customDarkScheme => _customDarkScheme;

  ColorHelper() {
    _loadColorPreferences();
  }

  Future<void> _loadColorPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load color mode
    String? colorModeString = prefs.getString('colorMode');
    if (colorModeString != null) {
      _colorMode = ColorMode.values.firstWhere(
        (e) => e.toString() == colorModeString,
        orElse: () => AppOwnerColors.useOwnerColorsAsDefault ? ColorMode.owner : ColorMode.dynamic,
      );
    } else if (AppOwnerColors.useOwnerColorsAsDefault) {
      // Set owner colors as default if no preference is saved
      _colorMode = ColorMode.owner;
    }

    // Load custom light scheme
    String? lightSchemeString = prefs.getString('customLightScheme');
    if (lightSchemeString != null) {
      try {
        Map<String, dynamic> lightSchemeJson = json.decode(lightSchemeString);
        _customLightScheme = CustomColorScheme.fromJson(lightSchemeJson);
      } catch (e) {
        print('Error loading custom light scheme: $e');
      }
    }

    // Load custom dark scheme
    String? darkSchemeString = prefs.getString('customDarkScheme');
    if (darkSchemeString != null) {
      try {
        Map<String, dynamic> darkSchemeJson = json.decode(darkSchemeString);
        _customDarkScheme = CustomColorScheme.fromJson(darkSchemeJson);
      } catch (e) {
        print('Error loading custom dark scheme: $e');
      }
    }

    notifyListeners();
  }

  Future<void> setColorMode(ColorMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _colorMode = mode;
    await prefs.setString('colorMode', mode.toString());
    notifyListeners();
  }

  Future<void> setCustomLightScheme(CustomColorScheme scheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _customLightScheme = scheme;
    await prefs.setString('customLightScheme', json.encode(scheme.toJson()));
    notifyListeners();
  }

  Future<void> setCustomDarkScheme(CustomColorScheme scheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _customDarkScheme = scheme;
    await prefs.setString('customDarkScheme', json.encode(scheme.toJson()));
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _colorMode = ColorMode.dynamic;
    _customLightScheme = null;
    _customDarkScheme = null;
    
    await prefs.remove('colorMode');
    await prefs.remove('customLightScheme');
    await prefs.remove('customDarkScheme');
    
    notifyListeners();
  }

  // Get the appropriate color scheme based on current mode and theme
  ColorScheme? getColorScheme({
    required bool isDark,
    ColorScheme? dynamicLight,
    ColorScheme? dynamicDark,
  }) {
    if (_colorMode == ColorMode.owner) {
      // Use owner-defined colors
      return isDark 
          ? AppOwnerColors.getOwnerDarkScheme().toDarkColorScheme()
          : AppOwnerColors.getOwnerLightScheme().toColorScheme();
    } else if (_colorMode == ColorMode.dynamic) {
      return isDark ? dynamicDark : dynamicLight;
    } else {
      // Custom mode
      if (isDark) {
        return _customDarkScheme?.toDarkColorScheme();
      } else {
        return _customLightScheme?.toColorScheme();
      }
    }
  }

  // Check if we have custom schemes set
  bool get hasCustomSchemes => 
      _customLightScheme != null && _customDarkScheme != null;

  // Check if color picker should be hidden (owner colors locked)
  bool get shouldHideColorPicker => AppOwnerColors.hideColorPicker;

  // Check if owner colors are set as default
  bool get isOwnerColorsDefault => AppOwnerColors.useOwnerColorsAsDefault;

  // Generate a color scheme from a base color
  CustomColorScheme generateSchemeFromColor(Color baseColor, bool isDark) {
    // This is a simplified color generation - you can make it more sophisticated
    final hsl = HSLColor.fromColor(baseColor);
    
    if (isDark) {
      return CustomColorScheme(
        primary: baseColor,
        onPrimary: Colors.white,
        primaryContainer: hsl.withLightness(0.2).toColor(),
        onPrimaryContainer: Colors.white,
        secondary: hsl.withHue((hsl.hue + 60) % 360).toColor(),
        onSecondary: Colors.white,
        secondaryContainer: hsl.withHue((hsl.hue + 60) % 360).withLightness(0.2).toColor(),
        onSecondaryContainer: Colors.white,
        tertiary: hsl.withHue((hsl.hue + 120) % 360).toColor(),
        onTertiary: Colors.white,
        tertiaryContainer: hsl.withHue((hsl.hue + 120) % 360).withLightness(0.2).toColor(),
        onTertiaryContainer: Colors.white,
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: const Color(0xFF1C1B1F),
        onSurface: const Color(0xFFE6E1E5),
        surfaceVariant: const Color(0xFF49454F),
        onSurfaceVariant: const Color(0xFFCAC4D0),
        outline: const Color(0xFF938F99),
        outlineVariant: const Color(0xFF49454F),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFFE6E1E5),
        onInverseSurface: const Color(0xFF313033),
        inversePrimary: baseColor,
        surfaceTint: baseColor,
      );
    } else {
      return CustomColorScheme(
        primary: baseColor,
        onPrimary: Colors.white,
        primaryContainer: hsl.withLightness(0.9).toColor(),
        onPrimaryContainer: hsl.withLightness(0.1).toColor(),
        secondary: hsl.withHue((hsl.hue + 60) % 360).toColor(),
        onSecondary: Colors.white,
        secondaryContainer: hsl.withHue((hsl.hue + 60) % 360).withLightness(0.9).toColor(),
        onSecondaryContainer: hsl.withHue((hsl.hue + 60) % 360).withLightness(0.1).toColor(),
        tertiary: hsl.withHue((hsl.hue + 120) % 360).toColor(),
        onTertiary: Colors.white,
        tertiaryContainer: hsl.withHue((hsl.hue + 120) % 360).withLightness(0.9).toColor(),
        onTertiaryContainer: hsl.withHue((hsl.hue + 120) % 360).withLightness(0.1).toColor(),
        error: const Color(0xFFBA1A1A),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF410002),
        surface: const Color(0xFFFFFBFE),
        onSurface: const Color(0xFF1C1B1F),
        surfaceVariant: const Color(0xFFE7E0EC),
        onSurfaceVariant: const Color(0xFF49454F),
        outline: const Color(0xFF79747E),
        outlineVariant: const Color(0xFFCAC4D0),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFF313033),
        onInverseSurface: const Color(0xFFF4EFF4),
        inversePrimary: baseColor,
        surfaceTint: baseColor,
      );
    }
  }
}
