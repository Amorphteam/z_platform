import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zahra/route_generator.dart';
import 'package:zahra/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:zahra/util/date_helper.dart';
import 'package:zahra/util/theme_helper.dart';
import 'package:zahra/util/time_zone_helper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    await initializeDateFormatting('ar'); // Initialize Arabic locale

  } catch (e) {
    print('Error during initialization: $e');
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  lockOrientation(); // Lock orientation based on device type

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeHelper(),
      child: const MyApp(),
    ),
  );

  configureOneSignal();
}

void configureOneSignal() {
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  // Initialize with your OneSignal App ID
  OneSignal.initialize("dc7d3a2d-c66a-4344-a0fe-f47795bfd2c3");

  // Configure notification appearance
  OneSignal.User.pushSubscription.optIn();
  
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
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
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFD3C8C8),
      secondary: Color(0xFF5A6147),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xffd2ceca),
      onSurface: Color(0xFF1B1C17),
      primaryContainer: Color(0xFFebebeb),
      onPrimaryContainer: Color(0xFF141F00),
      secondaryContainer: Color(0xFF007d81),
      onSecondaryContainer: Color(0xFF171E09),
      tertiaryContainer: Color(0xFFBCECE4),
      onTertiaryContainer: Color(0xFF00201D),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surfaceContainerHighest: Color(0xFFE2E4D4),
      onSurfaceVariant: Color(0xFF45483C),
      outline: Color(0xFF76786B),
      outlineVariant: Color(0xFFC6C8B9),
    );

    const ColorScheme darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff070707),
      onPrimary: Color(0xFF111111),
      secondary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF121212),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFF000000),
      onSecondaryContainer: Color(0xFF1FD7DD),
      onSurface: Color(0xffffffff),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0xFF9F9F9E), // Selection background color
        selectionHandleColor: Color(0xFF9F9F9E), // Selection handle color
        cursorColor: Color(0xFF9F9F9E), // Cursor color
      ),
      colorScheme: lightColorScheme,
      fontFamily: 'SFProDisplay',
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0xFF1FD7DD), // Selection background color
        selectionHandleColor: Color(0xFF1FD7DD), // Selection handle color
        cursorColor: Color(0xFF1FD7DD), // Cursor color
      ),
      colorScheme: darkColorScheme,
      fontFamily: 'SFProDisplay',
    );

    return BlocProvider(
      create: (_) => BookmarkCubit(),
      child: MaterialApp(
        title: 'نهج البلاغة',
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
