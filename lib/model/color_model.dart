import 'package:flutter/material.dart';

enum ColorMode { dynamic, custom }

class CustomColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  final Color surfaceTint;

  const CustomColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.surfaceTint,
  });

  // Convert to Flutter's ColorScheme
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );
  }

  // Convert to Flutter's ColorScheme for dark theme
  ColorScheme toDarkColorScheme() {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'primary': primary.value,
      'onPrimary': onPrimary.value,
      'primaryContainer': primaryContainer.value,
      'onPrimaryContainer': onPrimaryContainer.value,
      'secondary': secondary.value,
      'onSecondary': onSecondary.value,
      'secondaryContainer': secondaryContainer.value,
      'onSecondaryContainer': onSecondaryContainer.value,
      'tertiary': tertiary.value,
      'onTertiary': onTertiary.value,
      'tertiaryContainer': tertiaryContainer.value,
      'onTertiaryContainer': onTertiaryContainer.value,
      'error': error.value,
      'onError': onError.value,
      'errorContainer': errorContainer.value,
      'onErrorContainer': onErrorContainer.value,
      'surface': surface.value,
      'onSurface': onSurface.value,
      'surfaceVariant': surfaceVariant.value,
      'onSurfaceVariant': onSurfaceVariant.value,
      'outline': outline.value,
      'outlineVariant': outlineVariant.value,
      'shadow': shadow.value,
      'scrim': scrim.value,
      'inverseSurface': inverseSurface.value,
      'onInverseSurface': onInverseSurface.value,
      'inversePrimary': inversePrimary.value,
      'surfaceTint': surfaceTint.value,
    };
  }

  // Create from JSON
  factory CustomColorScheme.fromJson(Map<String, dynamic> json) {
    return CustomColorScheme(
      primary: Color(json['primary']),
      onPrimary: Color(json['onPrimary']),
      primaryContainer: Color(json['primaryContainer']),
      onPrimaryContainer: Color(json['onPrimaryContainer']),
      secondary: Color(json['secondary']),
      onSecondary: Color(json['onSecondary']),
      secondaryContainer: Color(json['secondaryContainer']),
      onSecondaryContainer: Color(json['onSecondaryContainer']),
      tertiary: Color(json['tertiary']),
      onTertiary: Color(json['onTertiary']),
      tertiaryContainer: Color(json['tertiaryContainer']),
      onTertiaryContainer: Color(json['onTertiaryContainer']),
      error: Color(json['error']),
      onError: Color(json['onError']),
      errorContainer: Color(json['errorContainer']),
      onErrorContainer: Color(json['onErrorContainer']),
      surface: Color(json['surface']),
      onSurface: Color(json['onSurface']),
      surfaceVariant: Color(json['surfaceVariant']),
      onSurfaceVariant: Color(json['onSurfaceVariant']),
      outline: Color(json['outline']),
      outlineVariant: Color(json['outlineVariant']),
      shadow: Color(json['shadow']),
      scrim: Color(json['scrim']),
      inverseSurface: Color(json['inverseSurface']),
      onInverseSurface: Color(json['onInverseSurface']),
      inversePrimary: Color(json['inversePrimary']),
      surfaceTint: Color(json['surfaceTint']),
    );
  }

  // Default color schemes
  static const CustomColorScheme defaultLight = CustomColorScheme(
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
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
    inversePrimary: Color(0xFFD0BCFF),
    surfaceTint: Color(0xFF6750A4),
  );

  static const CustomColorScheme defaultDark = CustomColorScheme(
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
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
    inversePrimary: Color(0xFF6750A4),
    surfaceTint: Color(0xFFD0BCFF),
  );
}
