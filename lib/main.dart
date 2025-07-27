import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sweet_easy_pocket/extension.dart';
import 'chart_page.dart';
import 'common_widget.dart';
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'firebase_options.dart';
import 'constant.dart';
import 'homepage.dart';
import 'login_page.dart';

/// Main application entry point
/// Initializes all required services and configurations before launching the app
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

/// App Tracking Transparency initialization
/// Handles iOS privacy compliance for tracking authorization
/// Requests user permission for app tracking on iOS devices
Future<void> initATTPlugin(BuildContext context) async {
  final commonWidget = CommonWidget(context);
  /// Check current tracking authorization status
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  /// Show permission request dialog if status is not determined
  if (status == TrackingStatus.notDetermined && context.mounted) {
    await showDialog(context: context,
      builder: (context) => AlertDialog(
        title: commonWidget.alertTitleText(context.appTitle()),
        content: Text(context.thisApp()),
        actions: [
          CommonWidget(context).alertJudgeButton(context.ok(),
            color: purpleColor,
            onTap: () => context.popPage(),
          )
        ],
      ),
    );
    /// Add delay before requesting authorization
    await Future.delayed(const Duration(milliseconds: 200));
    /// Request tracking authorization from user
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

