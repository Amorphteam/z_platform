import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masaha/route_generator.dart';
import 'package:masaha/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:masaha/util/date_helper.dart';
import 'package:masaha/util/theme_helper.dart';
import 'package:masaha/util/color_helper.dart';
import 'package:masaha/util/time_zone_helper.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    await Firebase.initializeApp();
    await initializeDateFormatting('ar'); // Initialize Arabic locale


  } catch (e) {
    print('Error during initialization: $e');
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  lockOrientation(); // Lock orientation based on device type

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeHelper()),
        ChangeNotifierProvider(create: (context) => ColorHelper()),
      ],
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
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => BookmarkCubit(),
      child: Consumer2<ThemeHelper, ColorHelper>(
        builder: (context, themeHelper, colorHelper, child) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              // Get the appropriate color scheme based on color mode
              final lightScheme = colorHelper.getColorScheme(
                isDark: false,
                dynamicLight: lightDynamic,
                dynamicDark: darkDynamic,
              );
              
              final darkScheme = colorHelper.getColorScheme(
                isDark: true,
                dynamicLight: lightDynamic,
                dynamicDark: darkDynamic,
              );

              return MaterialApp(
                title: 'منصة مساحة',
                themeMode: themeHelper.themeMode,
                theme: ThemeData(
                  colorScheme: lightScheme,
                  useMaterial3: true,
                  fontFamily: 'SFProDisplay',
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: lightScheme?.surfaceVariant,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkScheme,
                  brightness: Brightness.dark,
                  fontFamily: 'SFProDisplay',
                  useMaterial3: true,
                  scaffoldBackgroundColor: darkScheme?.surfaceVariant,
                ),
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                onGenerateRoute: RouteGenerator.generateRoute,
                navigatorObservers: [
                  FirebaseAnalyticsObserver(analytics: analytics),
                ],
              );
            },
          );
        },
      ),
    );
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
