import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'firebase_options.dart';
import 'chart_page.dart';
import 'constant.dart';
import 'firebase_manager.dart';
import 'homepage.dart';
import 'login_page.dart';

/// Main application entry point
/// Initializes all required services and configurations before launching the app
// No ATT call here. On iOS the UMP form shows Google's IDFA explainer and then
// raises the system ATT prompt itself, so asking again from the app put a second
// explainer in front of a user who had already answered. Removed in NEO first;
// see 03_Developer/technical/2026-08-25_elevatorneo_att_gate_removal.md
Future<void> main() async {
  /// Initialize Flutter binding and preserve splash screen
  /// Ensures proper initialization of Flutter engine and keeps splash screen visible
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  /// Configure system UI and device orientation
  /// Sets up system UI overlays and locks device to portrait orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }
  /// Load environment variables from .env file
  await dotenv.load(fileName: "assets/.env");
  /// Initialize Firebase services
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  /// App Check, because this app reads and writes Cloud Firestore and uses
  /// Firebase Auth. Both are products App Check can enforce; Analytics is not.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: androidAppCheckProvider,
    providerApple: appleAppCheckProvider,
  );
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  /// Ask for a token now. activate() above only registers the provider, so
  /// without this nothing knows whether App Check works until a call fails
  await refreshAppCheckReady();
  /// Launch the application with Riverpod provider scope
  runApp(const ProviderScope(child: MyApp()));
  /// Initialize Google Mobile Ads
  MobileAds.instance.initialize();
}

/// Main application widget
/// Configures the MaterialApp with routing, theming, and localization
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      /// Set initial route to homepage
      initialRoute: "/h",
      /// Maps route names to their corresponding page widgets
      routes: {
        "/l": (context) => LoginPage(), // Login page route
        "/h":  (context) => HomePage(), // Homepage route
        "/c":  (context) => ChartPage(), // Chart page route
      },
      /// Removes the debug indicator from the top-right corner
      debugShowCheckedModeBanner: false,
      /// Shows in recent apps list and other system interfaces
      title: "Kawaii Allowance Tracker",
      /// Enables multi-language support for the application
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      /// Sets up color scheme, brightness, and visual density
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(primary: purpleColor),
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      /// Monitors navigation events for Firebase Analytics and route management
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        RouteObserver<ModalRoute>(),
      ],
    );
}


