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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kawaii Allowance Tracker'**
  String get appTitle;

  /// No description provided for @thisApp.
  ///
  /// In en, this message translates to:
  /// **'A simple app for managing your allowance.'**
  String get thisApp;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// No description provided for @spend.
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

  /// No description provided for @amnt.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amnt;

  /// No description provided for @input.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get input;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance '**
  String get balance;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @moneySpent.
  ///
  /// In en, this message translates to:
  /// **'Money spent'**
  String get moneySpent;

  /// No description provided for @moneyLeft.
  ///
  /// In en, this message translates to:
  /// **'Money left'**
  String get moneyLeft;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'[Month]'**
  String get month;

  /// No description provided for @settingDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select the day'**
  String get settingDateHint;

  /// No description provided for @settingItemHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Item'**
  String get settingItemHint;

  /// No description provided for @settingAmntHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount'**
  String get settingAmntHint;

  /// No description provided for @settingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason'**
  String get settingReasonHint;

  /// No description provided for @selectUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Select the unit'**
  String get selectUnitHint;

  /// No description provided for @modifyDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify the date'**
  String get modifyDateTitle;

  /// No description provided for @modifyItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify the item'**
  String get modifyItemTitle;

  /// No description provided for @modifyAmntTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify the amount'**
  String get modifyAmntTitle;

  /// No description provided for @s.
  ///
  /// In en, this message translates to:
  /// **'\'s'**
  String get s;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Allowance Tracker'**
  String get tracker;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get name;

  /// No description provided for @settingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting your name'**
  String get settingNameTitle;

  /// No description provided for @settingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settingNameHint;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Currency unit'**
  String get unit;

  /// No description provided for @settingUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting currency unit'**
  String get settingUnitTitle;

  /// No description provided for @initialAssets.
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

  /// No description provided for @targetAssets.
  ///
  /// In en, this message translates to:
  /// **'Target assets'**
  String get targetAssets;

  /// No description provided for @settingTargetAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting your target assets'**
  String get settingTargetAssetsTitle;

  /// No description provided for @settingTargetAssetsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your target assets'**
  String get settingTargetAssetsHint;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @tryLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get tryLogin;

  /// No description provided for @tryLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tryLogout;

  /// No description provided for @trySignup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get trySignup;

  /// No description provided for @tryDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get tryDeleteAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPass;

  /// No description provided for @inputEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail'**
  String get inputEmailHint;

  /// No description provided for @inputPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'8+ chars (alnum & !@#\$&~)'**
  String get inputPasswordHint;

  /// No description provided for @inputConfirmPassHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the password'**
  String get inputConfirmPassHint;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signup Successful'**
  String get signupSuccess;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup Failed'**
  String get signupFailed;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logout Successful'**
  String get logoutSuccess;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout Failed'**
  String get logoutFailed;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Successful'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Failed'**
  String get deleteAccountFailed;

  /// No description provided for @sendEmailError.
  ///
  /// In en, this message translates to:
  /// **'Send mail error'**
  String get sendEmailError;

  /// No description provided for @sentVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Sent verified email'**
  String get sentVerifiedEmail;

  /// No description provided for @cantSendVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Can\'t send verified email'**
  String get cantSendVerifiedEmail;

  /// No description provided for @sentPassResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Sent password reset email'**
  String get sentPassResetEmail;

  /// No description provided for @cantSendPassResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Can\'t send password reset email'**
  String get cantSendPassResetEmail;

  /// No description provided for @useWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Use without logging in'**
  String get useWithoutLogin;

  /// No description provided for @forgotPass.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPass;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordReset;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is badly formatted'**
  String get invalidEmail;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is wrong'**
  String get wrongPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'The email address is not registered'**
  String get userNotFound;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'The email address has been disabled'**
  String get userDisabled;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'The email address has been already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get weakPassword;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tooManyRequests;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get operationNotAllowed;

  /// No description provided for @loginErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to Login'**
  String get loginErrorMessage;

  /// No description provided for @signupErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to Signup'**
  String get signupErrorMessage;

  /// No description provided for @storeDataAfterLogin.
  ///
  /// In en, this message translates to:
  /// **'Store your data'**
  String get storeDataAfterLogin;

  /// No description provided for @getStoredData.
  ///
  /// In en, this message translates to:
  /// **'Get your stored data'**
  String get getStoredData;

  /// No description provided for @storeYourData.
  ///
  /// In en, this message translates to:
  /// **'Store your data'**
  String get storeYourData;

  /// No description provided for @getDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Got your stored data successfully'**
  String get getDataSuccess;

  /// No description provided for @storeDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Stored your data successfully'**
  String get storeDataSuccess;

  /// No description provided for @getDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get your stored data'**
  String get getDataFailed;

  /// No description provided for @storeDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to store your data'**
  String get storeDataFailed;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stored data available'**
  String get noDataAvailable;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @confirmGetServerData.
  ///
  /// In en, this message translates to:
  /// **'Stocked data has been found.\nDo you want to restore it?\nThe current data will be overwritten.'**
  String get confirmGetServerData;

  /// No description provided for @confirmStoreLocalData.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore current data?\nThe previous data will be overwritten.'**
  String get confirmStoreLocalData;

  /// No description provided for @confirmDeleteAccount.
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
