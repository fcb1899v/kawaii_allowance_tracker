# Sweet Easy Pocket - Allowance Management App

<div align="center">
  <img src="assets/icon/android_icon.png" alt="Sweet Easy Pocket Icon" width="120" height="120">
  <br>
  <strong>Easy and cute allowance management for everyone</strong>
  <br>
</div>

## 📱 Application Overview

Sweet Easy Pocket is a Flutter-based allowance management app for Android & iOS that helps users track their daily allowance, spending, and savings with a cute, user-friendly interface.
It features financial tracking, charts, and cloud synchronization through Cloud Firestore.

### 🎯 Key Features

- **Allowance Tracking**: Track daily allowance, spending, and savings
- **Cross-platform Support**: Android & iOS compatibility
- **Multi-language Support**: Japanese, English
- **Google Mobile Ads**: Banner ads
- **Firebase Integration**: Analytics, App Check, Auth, Cloud Firestore
- **Charts**: Visual representation of financial data using fl_chart
- **Responsive Design**: Adaptive UI for different screen sizes
- **Data Synchronization**: Local and cloud data management

## 🚀 Technology Stack

### Frameworks & Libraries

- **Flutter**: 3.47.0+
- **Dart**: 3.13.0+
- **Firebase**: Analytics, App Check, Auth, Cloud Firestore
- **Google Mobile Ads**: Banner ads

### Core Features

- **Charts**: fl_chart
- **State Management**: hooks_riverpod, flutter_hooks
- **Localization**: flutter_localizations, intl
- **Local Storage**: shared_preferences
- **Environment Variables**: flutter_dotenv
- **Floating Action Button**: flutter_speed_dial
- **Progress Indicators**: percent_indicator
- **Splash**: flutter_native_splash

## 📋 Prerequisites

- Flutter 3.47.0+ (required by Android Gradle Plugin 9: earlier versions force the Kotlin Gradle Plugin onto modules that AGP 9 compiles itself)
- Dart 3.13.0+
- Android Studio / Xcode
- Firebase project (Analytics, App Check, Auth, Cloud Firestore)
- `firebase-tools` (`npm i -g firebase-tools`) and `flutterfire_cli` (`dart pub global activate flutterfire_cli`), then `firebase login`

## 🛠️ Setup

### 1. Clone the Repository
```bash
git clone https://github.com/fcb1899v/kawaii_allowance_tracker.git
cd kawaii_allowance_tracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configuration Files Setup

**Environment variables.** Copy `assets/.env_example` to `assets/.env` and fill in the values.
The template lists every key with what it is for, and is the one place that list is maintained.
`pubspec.yaml` declares `assets/.env`, so the file has to exist or the build fails.
Debug builds use Google's demo ad units and need no real ids, and the demo unit for an inline adaptive request is not the same id as the fixed-size one.
Debug builds also read the App Check debug tokens from this file (`lib/constant.dart`).

**Android signing, release only.** Copy `android/key.properties.example` to `android/key.properties` and fill it in.
Nothing in it ships inside the app, and the two passwords are real secrets: together with the keystore they let anyone publish an update Play accepts as coming from you.
Keep the keystore outside the repository and back both up.
A release built without this file falls back to the debug signing config, which produces an artifact Play rejects.

### 4. Firebase Configuration

1. Create a Firebase project.
2. Enable Cloud Firestore, Email/Password Authentication, and Analytics.
3. Run `flutterfire configure`.
   It writes `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart` and the `flutter` section of `firebase.json`.
   **None of them are in git**, so run it after a fresh clone.
4. **Restore the `firestore` section of `firebase.json`.**
   `flutterfire configure` writes only the `flutter` section, and that one line is what points `firebase deploy` at the rules this repository defines.
   The whole file ends up like this, with the `flutter` block left exactly as the tool wrote it:

   ```json
   {
     "firestore": { "rules": "firestore.rules" },
     "flutter": { "...": "written by flutterfire configure; leave it alone" }
   }
   ```

   `flutterfire configure` merges rather than overwrites, so running it again later keeps this section.
5. Deploy the Firestore rules.
   `firestore.rules` binds every read and write to the signed-in owner of `users/{uid}`, and the file itself explains what it does and does not cover.
   ```bash
   firebase deploy --only firestore:rules --project <PROJECT_ID>
   ```
6. Register the App Check providers: debug tokens for emulators and simulators, Play Integrity and DeviceCheck for release.
   The app activates App Check at startup and asks for a token immediately (`lib/main.dart`), so a missing registration shows up at launch rather than on the first Firestore call.

### 5. Run the Application
```bash
flutter devices                 # take the id of the one you want
flutter run -d <device-id>
```

## 🎮 Application Structure

```
lib/
├── main.dart                    # Application entry point
├── homepage.dart                # Main dashboard interface
├── home_widget.dart             # Home page widgets
├── chart_page.dart              # Financial charts
├── login_page.dart              # Email and password sign in
├── auth_manager.dart            # Authentication management
├── firebase_manager.dart        # Firestore and App Check operations
├── admob_banner.dart            # Banner advertisement management
├── common_widget.dart           # Reusable UI components
├── constant.dart                # Constant definitions
├── extension.dart               # Extension functions for responsive design
├── firebase_options.dart        # Written by flutterfire configure, not in git
└── l10n/                        # Localization
    ├── app_en.arb
    ├── app_ja.arb
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_ja.dart

firestore.rules                  # Firestore security rules

assets/
├── icon/                        # App icons
│   ├── android_icon.png        # Android adaptive icon foreground
│   ├── ios_icon.png            # iOS app icon
│   ├── play_icon.png           # Play store icon
│   └── splash_icon.png         # Splash screen icon
└── fonts/                      # Font files
    ├── pacifico.ttf           # Pacifico font
    ├── riipopkkr.otf          # RiiPop font
    └── yasashisagothic.otf    # Yasashisa Gothic font
```

## 📱 Supported Platforms

- **Android**: API 24+ (`flutter.minSdkVersion`), compiled and targeted at API 37
- **iOS**: iOS 15.0+ (the Runner target's `IPHONEOS_DEPLOYMENT_TARGET`; the project-level value is 17.0)

## 🔧 Development

### Code Analysis
```bash
flutter analyze   # expected: No issues found!
```

### Run Tests

This repository has no `test/` directory, so `flutter analyze` is the only check that runs here.

### Build
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 📄 License

This project is not open source.
The source is published so that it can be read, and all rights are reserved.
See [LICENSE](LICENSE) for what that permits.
Third-party components keep their own licenses, listed below.

## 🤝 Contributing

Issue reports are welcome.
Pull requests are not accepted, because the code is not licensed for redistribution.

## 📞 Support

If you have any problems or questions, please create an issue on GitHub.

## Licenses & Credits

This app uses the following third-party components:

- Flutter (BSD 3-Clause License)
- firebase_core, firebase_analytics, firebase_app_check, firebase_auth, cloud_firestore (BSD 3-Clause License)
- google_mobile_ads (Apache License 2.0)
- Google Mobile Ads Android SDK (Android Software Development Kit License): `play-services-ads`, pulled in by google_mobile_ads
- Google Mobile Ads iOS SDK (proprietary Google binary; its CocoaPods spec declares only a Google copyright notice, with no open-source license): `Google-Mobile-Ads-SDK`, pulled in by google_mobile_ads
- User Messaging Platform, the consent SDK (Android Software Development Kit License): `com.google.android.ump:user-messaging-platform`, pulled in by google_mobile_ads
- User Messaging Platform on iOS (proprietary Google binary, declared the same way as the iOS ads SDK): `GoogleUserMessagingPlatform`, pulled in by `Google-Mobile-Ads-SDK`
- fl_chart (MIT License)
- hooks_riverpod, flutter_hooks (MIT License)
- shared_preferences (BSD 3-Clause License)
- flutter_launcher_icons (MIT License)
- flutter_native_splash (MIT License)
- intl (BSD 3-Clause License)
- flutter_localizations (BSD 3-Clause License)
- cupertino_icons (MIT License)
- flutter_speed_dial (MIT License)
- percent_indicator (BSD 2-Clause License)
- flutter_dotenv (MIT License)

For details of each license, please refer to [pub.dev](https://pub.dev/) or the LICENSE file in each repository.
