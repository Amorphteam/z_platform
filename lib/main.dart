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
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => BookmarkCubit(),
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MaterialApp(
            title: 'منصة مساحة',
            theme: ThemeData(
              colorScheme: lightDynamic,
              useMaterial3: true,
              fontFamily: 'SFProDisplay',
              brightness: Brightness.light,
              scaffoldBackgroundColor: lightDynamic?.surfaceVariant,
              cardTheme: CardTheme(
                color: lightDynamic?.surface, // or surfaceVariant
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            darkTheme: ThemeData(
              colorScheme: darkDynamic,
              brightness: Brightness.dark,
              fontFamily: 'SFProDisplay',
              useMaterial3: true,

              scaffoldBackgroundColor: darkDynamic?.surfaceVariant,
              cardTheme: CardTheme(
                color: darkDynamic?.surface, // or surfaceVariant
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            onGenerateRoute: RouteGenerator.generateRoute,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
          ),
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
