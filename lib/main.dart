import 'dart:math';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith/route_generator.dart';
import 'package:hadith/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:hadith/util/theme_helper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  lockOrientation(); // Lock orientation based on device type
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeHelper(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final themeHelper = Provider.of<ThemeHelper>(context);

    const ColorScheme lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1B1C17),
      onPrimary: Color(0xFFEEEEEE),
      secondary: Colors.blue,
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1B1C17),
      primaryContainer: Color(0xFFCDEF84),
      onPrimaryContainer: Color(0xFF141F00),
      secondaryContainer: Color(0xFF1B1C17),
      onSecondaryContainer: Color(0xFF171E09),
      tertiaryContainer: Color(0xFFBCECE4),
      onTertiaryContainer: Color(0xFF00201D),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surfaceContainerHighest: Color(0xFFE2E4D4),
      onSurfaceVariant: Color(0xFFf6f8f7),
      outline: Color(0xFF76786B),
      outlineVariant: Color(0xFFC6C8B9),
    );

    const ColorScheme darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFEEEEEE),
      secondary: Colors.blue,
      onSecondary: Color(0xFF111111),
      error: Color(0xFFBA1A1A),
      secondaryContainer: Color(0xFFFFFFFF),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFF111111),
      onSurface: Color(0xFFEEEEEE),
      onSurfaceVariant: Color(0xFF121413),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      colorScheme: lightColorScheme,
      fontFamily: 'SFProDisplay',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0xFF90CAF9), // Red color for selection
        selectionHandleColor: Color(0xFF90CAF9), // Red color for handles
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      colorScheme: darkColorScheme,
      fontFamily: 'SFProDisplay',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0x4490CAF9), // Red color for selection
        selectionHandleColor: Color(0xFFa0a0af), // Red color for handles
      ),
    );

    return BlocProvider(
      create: (_) => BookmarkCubit(),
      child: MaterialApp(
        title: 'الحديث الشريف',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeHelper.themeMode,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        builder: (context, child) {
          // Detect current brightness (light or dark mode)
          final brightness = MediaQuery.of(context).platformBrightness;

          // Set the navigation bar color dynamically
          // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          //   systemNavigationBarColor:
          //   brightness == Brightness.dark ? Color(0xFF111111) : Color(0xFFD3C8C8),
          //   systemNavigationBarIconBrightness:
          //   brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          // ));

          return child!;
        },
      ),
    );
  }
}

void lockOrientation() {
  if (isMobileDevice()) {
    // Lock orientation for mobile devices
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    // Allow full rotation for larger devices
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

bool isMobileDevice() {
  // Get device information
  final window = WidgetsBinding.instance.window;
  final width = window.physicalSize.width / window.devicePixelRatio;
  final height = window.physicalSize.height / window.devicePixelRatio;

  // Calculate diagonal screen size in inches
  final diagonalInPixels = sqrt(pow(window.physicalSize.width, 2) +
      pow(window.physicalSize.height, 2));
  final diagonalInInches = diagonalInPixels / (window.devicePixelRatio * 160);

  // Consider devices with diagonal less than 7 inches as mobile
  return diagonalInInches < 7.0;
}
