import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Kawaii Allowance Tracker'**
  String get appTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'A simple app for managing your allowance.'**
  String get thisApp;

  /// Bottom label of list
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// Bottom label of summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Allowance
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// Spend money
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get spend;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get date;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// List of amount title label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amnt;

  /// Input list
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get input;

  /// Delete list
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Input text field
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// Open picker
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Not set
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance '**
  String get balance;

  /// Settings of Asset
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// Money spent label
  ///
  /// In en, this message translates to:
  /// **'Money spent'**
  String get moneySpent;

  /// Money left label
  ///
  /// In en, this message translates to:
  /// **'Money left'**
  String get moneyLeft;

  /// Month
  ///
  /// In en, this message translates to:
  /// **'[Month]'**
  String get month;

  /// Day hint
  ///
  /// In en, this message translates to:
  /// **'Select the day'**
  String get settingDateHint;

  /// No description provided for @settingItemHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Item'**
  String get settingItemHint;

  /// amount hint
  ///
  /// In en, this message translates to:
  /// **'Enter the amount'**
  String get settingAmntHint;

  /// reason hint
  ///
  /// In en, this message translates to:
  /// **'Enter the reason'**
  String get settingReasonHint;

  /// select unit hint
  ///
  /// In en, this message translates to:
  /// **'Select the unit'**
  String get selectUnitHint;

  /// modify date title
  ///
  /// In en, this message translates to:
  /// **'Modify the date'**
  String get modifyDateTitle;

  /// modify item title
  ///
  /// In en, this message translates to:
  /// **'Modify the item'**
  String get modifyItemTitle;

  /// modify amount title
  ///
  /// In en, this message translates to:
  /// **'Modify the amount'**
  String get modifyAmntTitle;

  /// Title label
  ///
  /// In en, this message translates to:
  /// **'\'s'**
  String get s;

  /// Title label
  ///
  /// In en, this message translates to:
  /// **'Allowance Tracker'**
  String get tracker;

  /// Setting your name
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get name;

  /// Setting name title
  ///
  /// In en, this message translates to:
  /// **'Setting your name'**
  String get settingNameTitle;

  /// Setting name hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settingNameHint;

  /// Setting currency unit
  ///
  /// In en, this message translates to:
  /// **'Currency unit'**
  String get unit;

  /// Setting currency unit title
  ///
  /// In en, this message translates to:
  /// **'Setting currency unit'**
  String get settingUnitTitle;

  /// Allowance
  ///
  /// In en, this message translates to:
  /// **'Initial assets'**
  String get initialAssets;

  /// No description provided for @settingInitialAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting your initial assets'**
  String get settingInitialAssetsTitle;

  /// No description provided for @settingInitialAssetsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your initial assets'**
  String get settingInitialAssetsHint;

  /// Allowance
  ///
  /// In en, this message translates to:
  /// **'Target assets'**
  String get targetAssets;

  /// Setting target assets title
  ///
  /// In en, this message translates to:
  /// **'Setting your target assets'**
  String get settingTargetAssetsTitle;

  /// Setting target assets hint
  ///
  /// In en, this message translates to:
  /// **'Enter your target assets'**
  String get settingTargetAssetsHint;

  /// Start date
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// Privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Signup
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// Delete Account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Try Login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get tryLogin;

  /// Try Logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tryLogout;

  /// Try Signup
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get trySignup;

  /// Delete your account?
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get tryDeleteAccount;

  /// Input email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Input password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Input confirm password
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPass;

  /// Input email hint
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail'**
  String get inputEmailHint;

  /// Input password hint
  ///
  /// In en, this message translates to:
  /// **'8+ chars (alnum & !@#\$&~)'**
  String get inputPasswordHint;

  /// Input confirm password hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter the password'**
  String get inputConfirmPassHint;

  /// Login successful
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// Login failed
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// Signup successful
  ///
  /// In en, this message translates to:
  /// **'Signup Successful'**
  String get signupSuccess;

  /// Signup failed
  ///
  /// In en, this message translates to:
  /// **'Signup Failed'**
  String get signupFailed;

  /// Logout successful
  ///
  /// In en, this message translates to:
  /// **'Logout Successful'**
  String get logoutSuccess;

  /// Logout failed
  ///
  /// In en, this message translates to:
  /// **'Logout Failed'**
  String get logoutFailed;

  /// Delete Account successful
  ///
  /// In en, this message translates to:
  /// **'Delete Account Successful'**
  String get deleteAccountSuccess;

  /// Delete Account failed
  ///
  /// In en, this message translates to:
  /// **'Delete Account Failed'**
  String get deleteAccountFailed;

  /// Send password reset email error
  ///
  /// In en, this message translates to:
  /// **'Send mail error'**
  String get sendEmailError;

  /// Sent verified email
  ///
  /// In en, this message translates to:
  /// **'Sent verified email'**
  String get sentVerifiedEmail;

  /// No description provided for @cantSendVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Can\'t send verified email'**
  String get cantSendVerifiedEmail;

  /// Sent password reset email
  ///
  /// In en, this message translates to:
  /// **'Sent password reset email'**
  String get sentPassResetEmail;

  /// No description provided for @cantSendPassResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Can\'t send password reset email'**
  String get cantSendPassResetEmail;

  /// Without login button
  ///
  /// In en, this message translates to:
  /// **'Use without logging in'**
  String get useWithoutLogin;

  /// Forgot password button
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPass;

  /// Password reset title
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordReset;

  /// Invalid email
  ///
  /// In en, this message translates to:
  /// **'The email address is badly formatted'**
  String get invalidEmail;

  /// Wrong password
  ///
  /// In en, this message translates to:
  /// **'The password is wrong'**
  String get wrongPassword;

  /// User not found
  ///
  /// In en, this message translates to:
  /// **'The email address is not registered'**
  String get userNotFound;

  /// User disabled
  ///
  /// In en, this message translates to:
  /// **'The email address has been disabled'**
  String get userDisabled;

  /// Email already in use
  ///
  /// In en, this message translates to:
  /// **'The email address has been already in use'**
  String get emailAlreadyInUse;

  /// Weak password
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get weakPassword;

  /// Too many requests
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tooManyRequests;

  /// Operation not allowed
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get operationNotAllowed;

  /// Login default error message
  ///
  /// In en, this message translates to:
  /// **'Failed to Login'**
  String get loginErrorMessage;

  /// Signup default error message
  ///
  /// In en, this message translates to:
  /// **'Failed to Signup'**
  String get signupErrorMessage;

  /// Store your data after login
  ///
  /// In en, this message translates to:
  /// **'Store your data'**
  String get storeDataAfterLogin;

  /// Get your data after login
  ///
  /// In en, this message translates to:
  /// **'Get your stored data'**
  String get getStoredData;

  /// Store your data after login
  ///
  /// In en, this message translates to:
  /// **'Store your data'**
  String get storeYourData;

  /// Successfully got your stored data
  ///
  /// In en, this message translates to:
  /// **'Got your stored data successfully'**
  String get getDataSuccess;

  /// Successfully stored your data
  ///
  /// In en, this message translates to:
  /// **'Stored your data successfully'**
  String get storeDataSuccess;

  /// Failed to get your stored data
  ///
  /// In en, this message translates to:
  /// **'Failed to get your stored data'**
  String get getDataFailed;

  /// Failed to store your data
  ///
  /// In en, this message translates to:
  /// **'Failed to store your data'**
  String get storeDataFailed;

  /// No stored data available
  ///
  /// In en, this message translates to:
  /// **'No stored data available'**
  String get noDataAvailable;

  /// Confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @confirmGetServerData.
  ///
  /// In en, this message translates to:
  /// **'Stocked data has been found.\nDo you want to restore it?\nThe current data will be overwritten.'**
  String get confirmGetServerData;

  /// Confirm store data
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore current data?\nThe previous data will be overwritten.'**
  String get confirmStoreLocalData;

  /// Confirm delete account
  ///
  /// In en, this message translates to:
  /// **'The authentication credentials and stored data will be deleted.\nPlease be careful as recovery will not be possible once deleted.'**
  String get confirmDeleteAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
