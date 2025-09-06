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

import 'api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    await initializeDateFormatting('ar'); // Initialize Arabic locale

    // Run date operations in background
    // await Future.microtask(() async {
    //   await TimeZoneHelper.initialize(); // Initialize TimeZoneHelper
    //   final hijriDates = await DateHelper().getHijriDates();
    //   final todayHijri = await DateHelper().getTodayCalendarHijri(qamariDate: hijriDates);
    //   final AMPM = await DateHelper.handleAMPM();
    //   print('Now in hijri: $todayHijri / ${AMPM?.ampm}');
    // });

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
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final themeHelper = Provider.of<ThemeHelper>(context);

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      // colorScheme: lightColorScheme,
      fontFamily: 'SFProDisplay',
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(),
        ),
      ),
      // colorScheme: darkColorScheme,
      fontFamily: 'SFProDisplay',
    );

    return BlocProvider(
      create: (_) => BookmarkCubit(),
      child: MaterialApp(
        title: 'المعارف الفاطمية',
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
  final diagonalInPixels = sqrt(pow(window.physicalSize.width, 2) +
      pow(window.physicalSize.height, 2));
  final diagonalInInches = diagonalInPixels / (window.devicePixelRatio * 160);

  // Consider devices with diagonal less than 7 inches as mobile
  return diagonalInInches < 7.0;
}
