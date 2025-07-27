# Sweet Easy Pocket - Allowance Management App

<div align="center">
  <img src="assets/icon/android_icon.png" alt="Sweet Easy Pocket Icon" width="120" height="120">
  <br>
  <strong>Easy and cute allowance management for everyone</strong>
  <br>
</div>

## 📱 Application Overview

Sweet Easy Pocket is a Flutter-based allowance management app for Android & iOS that helps users track their daily allowance, spending, and savings with a cute, user-friendly interface.
It features comprehensive financial tracking, beautiful charts, and cloud synchronization for secure data management.

### 🎯 Key Features

- **Allowance Tracking**: Track daily allowance, spending, and savings
- **Cross-platform Support**: Android & iOS compatibility
- **Multi-language Support**: Japanese, English (2 languages)
- **Google Mobile Ads**: Banner ads integration
- **Firebase Integration**: Firestore for cloud data synchronization, Authentication for user management
- **Beautiful Charts**: Visual representation of financial data using fl_chart
- **Responsive Design**: Adaptive UI for different screen sizes
- **Customizable Settings**: Personal information and preferences
- **Data Synchronization**: Local and cloud data management

## 🚀 Technology Stack

### Frameworks & Libraries
- **Flutter**: 3.3.0+
- **Dart**: 2.18.0+
- **Firebase**: Firestore, Authentication, Analytics
- **Google Mobile Ads**: Banner advertisement display

### Core Features
- **Charts**: fl_chart for beautiful financial visualizations
- **State Management**: hooks_riverpod, flutter_hooks for reactive UI
- **Localization**: flutter_localizations with multi-language support
- **Shared Preferences**: Local data storage
- **Firebase Firestore**: Cloud data synchronization
- **Firebase Auth**: User authentication and account management
- **Responsive Design**: Adaptive layouts for various screen sizes
- **App Tracking Transparency**: iOS privacy compliance
- **Floating Action Button**: flutter_speed_dial for quick actions
- **Progress Indicators**: percent_indicator for visual feedback

## 📋 Prerequisites

- Flutter 3.3.0+
- Dart 2.18.0+
- Android Studio / Xcode
- Firebase (Firestore, Authentication, Analytics)

## 🛠️ Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd sweet_easy_pocket
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Variables Setup
Create `assets/.env` file and configure required environment variables:
```env
IOS_BANNER_UNIT_ID="your-ios-banner-id"
ANDROID_BANNER_UNIT_ID="your-android-banner-id"
IOS_BANNER_TEST_ID="your-ios-test-banner-id"
ANDROID_BANNER_TEST_ID="your-android-test-banner-id"
```

### 4. Firebase Configuration
1. Create a Firebase project
2. Enable Firestore, Authentication, and Analytics
3. Place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. These files are automatically excluded by .gitignore

### 5. Run the Application
```bash
# Android
flutter run

# iOS
cd ios
pod install
cd ..
flutter run
```

## 🎮 Application Structure

```
lib/
├── main.dart                    # Application entry point
├── homepage.dart                # Main dashboard interface
├── chart_page.dart              # Financial charts and analytics
├── login_page.dart              # User authentication
├── auth_manager.dart            # Authentication management
├── firebase_manager.dart        # Firestore data operations
├── admob_banner.dart            # Banner advertisement management
├── common_widget.dart           # Reusable UI components
├── home_widget.dart             # Home page widgets
├── constant.dart                # Constant definitions
├── extension.dart               # Extension functions for responsive design
├── firebase_options.dart        # Firebase configuration
└── l10n/                        # Localization
    ├── app_en.arb
    ├── app_ja.arb
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_ja.dart

assets/
├── icon/                        # App icons
│   ├── android_icon.png        # Android app icon
│   ├── ios_icon.png            # iOS app icon
│   ├── play_icon.png           # Play store icon
│   └── splash_icon.png         # Splash screen icon
├── fonts/                      # Font files
│   ├── pacifico.ttf           # Pacifico font
│   ├── riipopkkr.otf          # RiiPop font
│   └── yasashisagothic.otf    # Yasashisa Gothic font
└── .env                        # Environment variables
```

## 🎨 Features

### Financial Tracking
- **Allowance Management**: Track daily, weekly, and monthly allowances
- **Spending Log**: Record expenses with categories and descriptions
- **Balance Calculation**: Automatic balance and savings calculation
- **Asset Tracking**: Monitor total assets and financial goals
- **Percentage Tracking**: Visual progress indicators for financial goals

### Data Visualization
- **Monthly Charts**: Visual representation of spending patterns
- **Balance Charts**: Track balance changes over time
- **Spending Analysis**: Analyze spending by category
- **Progress Tracking**: Visual progress towards financial goals
- **Chart Navigation**: Year-based navigation through historical data

### User Interface
- **Cute Design**: Sweet-themed interface with adorable elements
- **Responsive Layout**: Adapts to different screen sizes
- **Floating Action Button**: Quick access to add allowance/spending
- **Speed Dial**: Easy navigation between different actions
- **Intuitive Navigation**: Easy-to-use navigation system

### Data Management
- **Local Storage**: Secure local data storage with SharedPreferences
- **Cloud Sync**: Firebase Firestore synchronization
- **Data Permissions**: Granular control over local and server data
- **Backup & Restore**: Automatic data backup and synchronization

### Authentication
- **User Registration**: Create new accounts with email/password
- **Login System**: Secure user authentication
- **Password Reset**: Email-based password recovery
- **Account Management**: User profile and settings
- **Logout Functionality**: Secure account logout

### Additional Features
- **App Tracking Transparency**: iOS privacy compliance
- **Analytics**: Firebase Analytics integration
- **Banner Ads**: Google Mobile Ads integration
- **Multi-language Support**: Japanese and English localization
- **Custom Fonts**: Pacifico, RiiPop, and Yasashisa Gothic fonts

## 📱 Supported Platforms

- **Android**: API 23+
- **iOS**: iOS 14.0+

## 🔧 Development

### Code Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Build
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 🔒 Security

This project includes security measures to protect sensitive financial information:
- Firebase Authentication for secure user management
- Firestore security rules for data protection
- Local data encryption for sensitive information
- Secure API key management through environment variables
- App Tracking Transparency compliance for iOS

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Pull requests and issue reports are welcome.

## 📞 Support

If you have any problems or questions, please create an issue on GitHub.

## 🚀 Getting Started

For new developers:
1. Follow the setup instructions above
2. Check the application structure
3. Review the Firebase configuration
4. Start with the main.dart file to understand the app flow

---

<div align="center">
  <strong>Sweet Easy Pocket</strong> - Easy and cute allowance management for everyone!
</div>

## Licenses & Credits

This app uses the following open-source libraries:

- Flutter (BSD 3-Clause License)
- firebase_core, firebase_firestore, firebase_auth, firebase_analytics (Apache License 2.0)
- google_mobile_ads (Apache License 2.0)
- fl_chart (MIT License)
- hooks_riverpod, flutter_hooks (MIT License)
- shared_preferences (BSD 3-Clause License)
- flutter_launcher_icons (MIT License)
- flutter_native_splash (MIT License)
- intl (BSD 3-Clause License)
- flutter_localizations (BSD 3-Clause License)
- cupertino_icons (MIT License)
- flutter_speed_dial (MIT License)
- percent_indicator (MIT License)
- flutter_dotenv (MIT License)
- app_tracking_transparency (MIT License)

For details of each license, please refer to [pub.dev](https://pub.dev/) or the LICENSE file in each repository.
