import 'dart:math';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'constant.dart';

/// Allowance data model class
class AllowanceList {
  final int date;
  final String item;
  final double amnt;
  AllowanceList(
      this.date,
      this.item,
      this.amnt,
      );
}

/// BuildContext extensions for UI utilities and localization
extension ContextExt on BuildContext {

  // Common navigation methods
  void pushPage(String page) => Navigator.of(this).pushNamedAndRemoveUntil(page, (_) => false);
  void popPage() => Navigator.pop(this);
  
  // Language and localization methods
  String lang() => Localizations.localeOf(this).languageCode;
  int inputItemMaxLength() => (lang() == "ja") ? inputJaItemMaxLength: inputEnItemMaxLength;
  int inputNameMaxLength() => (lang() == "ja") ? inputJaNameMaxLength: inputEnNameMaxLength;
  String customEnFont() => (lang() == "ja") ? 'defaultFont': 'enAccent';
  String customJaFont() => (lang() == "ja") ? 'jaAccent': 'defaultFont';
  String customAccentFont() => (lang() == "ja") ? 'jaAccent': 'enAccent';
  double alertTitleFontSize() => (lang() == "ja") ? alertTitleJaSize: alertTitleEnSize;
  double alertFontSize() => (lang() == "ja") ? alertFontJaSize: alertFontEnSize;
  String defaultUnit() => (lang() == "ja") ? "¥": "\$";
  List<String> unitList() => (lang() == "ja") ? jaUnitList: enUnitList;
  FontWeight customWeight() => (lang() == "ja") ? FontWeight.normal: FontWeight.bold;
  
  // Screen size and layout methods
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;
  double maxWidth() => (width() > 600) ? 600: width();
  double top() => MediaQuery.of(this).padding.top;
  double bottom() => MediaQuery.of(this).padding.bottom;
  double displayHeight() => height() - top() - bottom() - admobHeight();
  double shadowBlur() => maxWidth() * 0.005;
  double shadowOffset() => maxWidth() * 0.005;

  // AppBar styling methods
  double appBarHeight() => maxWidth() * 0.15;
  double appBarFontSize() => maxWidth() * ((lang() == "ja") ? 0.07: 0.08);
  double appBarTitleIconSpace() => maxWidth() * 0.04;
  double appBarIconSize() => maxWidth() * 0.08;
  double appBarBottomLineWidth() => maxWidth() * 0.01;

  // Drawer styling methods
  double drawerWidth() => maxWidth() * 0.9;
  double drawerTitleHeightRate(String name) =>
      (drawerTitle(name) == appTitle()) ? 0.22: 0.33;
  double drawerTitleHeight(String name) => maxWidth() * drawerTitleHeightRate(name);
  double drawerTitleBorderRadius() => maxWidth() * 0.1;
  double drawerTitleFontSize() => maxWidth() * 0.06;
  double drawerMenuListIconSize() => maxWidth() * 0.08;
  double drawerMenuListFontSize() => maxWidth() * 0.04;
  double drawerMenuListMarginTop() => maxWidth() * 0.03;
  double drawerMenuListMargin() => height() * 0.01;
  double drawerMenuListSubTitleMarginTop() => maxWidth() * 0.02;
  BorderRadius drawerBorderRadius() => BorderRadius.only(
    topRight: Radius.circular(drawerTitleBorderRadius()),
    bottomRight: Radius.circular(drawerTitleBorderRadius()),
  );

  // Main body layout methods
  double mainBodyMarginTop() => height() * 0.03;
  double balanceFontSize() => maxWidth() * (lang() == "ja" ? 0.07: 0.09);
  double balanceUnitSize() => maxWidth() * 0.10;
  double balanceMoneySize() => maxWidth() * 0.12;
  double balanceMoneyShiftSize() => maxWidth() * 0.025;
  double balanceMarginHorizontal() => maxWidth() * 0.05;
  double percentMarginBottom() => height() * 0.03;
  double percentBarWidth() => (width() * 0.8 > 600.0) ? 600.0: width() * 0.8;
  double plusMinusSize() => height() * 0.04;
  double plusMinusMarginTop() => maxWidth() * 0.03;
  double plusMinusIconSize() => height() * 0.032;
  double plusMinusSpace() => height() * 0.2;
  double monthYearFontSize() => maxWidth() * 0.07;

  // Spreadsheet styling methods
  double scrollViewMarginHorizontal() => width() * 0.05;
  double scrollViewMarginVertical() => height() * 0.015;
  double spreadSheetCornerRadius() => height() * 0.018;
  double spreadSheetFontSize() => height() * 0.02;
  double spreadSheetIconSize() => height() * 0.025;
  double spreadSheetRowHeight() => height() * 0.05;
  double spreadSheetColumnSpacing() => height() * 0.015;
  double deleteButtonWidth() => height() * 0.03;

  // Chart styling methods
  double chartHeight() => height() * 0.40;
  double chartWidth() => (width() > 1000) ? 1000: width();
  double chartBarWidth() => height() * 0.005;
  double chartDotWidth() => height() * 0.006;
  double chartBorderWidth() => height() * 0.002;
  double chartVerticalBorderWidth() => height() * 0.0005;
  double chartHorizontalBorderWidth() => height() * 0.002;
  double chartTitleFontSize() => height() * 0.03;
  double chartTopAxisNameSize() => height() * 0.07;
  double chartTopMarginLeft() => height() * 0.04;
  double chartBottomMargin() => height() * 0.01;
  double chartBottomAxisNameSize() => height() * 0.05;
  double chartBottomMarginLeft() => height() * 0.03;
  double chartBottomFontSize() => height() * 0.025;
  double chartLeftReservedSize() => width() * 0.12;
  double chartBottomReservedSize() => width() * 0.06;
  double chartAxisFontSize() => width() * 0.03;

  // Floating action button styling methods
  double floatingActionBottomMargin() => admobHeight() + height() * 0.02;
  double floatingActionButtonSize() => maxWidth() * 0.12;
  double floatingActionIconSize() => maxWidth() * 0.08;
  double speedDialIconSize() => maxWidth() * 0.07;
  double speedDialChildButtonSize() => maxWidth() * 0.13;
  double speedDialChildFontSize() => maxWidth() * 0.05;
  double speedDialChildIconSize() => maxWidth() * 0.08;
  double speedDialSpaceFontSize() => maxWidth() * 0.04;
  double speedDialSpacing() => maxWidth() * 0.01;
  double speedDialSpaceHeight() => maxWidth() * 0.04;

  // Login page styling methods
  double loginTitleSize() => maxWidth() * 0.075;
  double loginIconSize() => maxWidth() * 0.07;
  double loginFontSize() => maxWidth() * 0.045;
  double loginMessageSize() => maxWidth() * 0.04;
  double loginHintSize() => maxWidth() * 0.04;
  double loginTitleMarginTop() => maxWidth() * 0.15;
  double loginTitleMarginBottom() => maxWidth() * 0.08;
  double loginInputAreaRadius() => maxWidth() * 0.08;
  double loginInputAreaWidth() => maxWidth() * 0.92;
  double loginInputAreaPadding() => maxWidth() * 0.06;
  double loginInputIconSpace() => maxWidth() * 0.1;
  double loginTextFieldMarginBottom() => maxWidth() * 0.05;
  double loginButtonWidth() => maxWidth() * 0.70;
  double loginButtonHeight() => maxWidth() * 0.14;
  double loginButtonRadius() => loginButtonHeight() / 2;
  double loginButtonMarginTop() => maxWidth() * 0.04;
  double loginButtonMarginBottom() => maxWidth() * 0.04;
  double moveSignupMarginTop() => maxWidth() * 0.02;
  double moveSignupMarginBottom() => maxWidth() * 0.04;
  double forgetPassMarginTop() => maxWidth() * 0.08;
  double loginCounterCharSize() => maxWidth() * 0.02;
  double loginVisibleMarginTop() => maxWidth() * 0.04;
  double loginVisibleMarginRight() => maxWidth() * 0.02;
  double snackBarMargin() => maxWidth() * 0.03;

  // AdMob sizing methods
  double admobHeight() => (height() < 600) ? 50: (height() < 1000) ? (height() / 8 - 25): 100;
  double admobWidth() => width();

  // Localized string getters
  String appTitle() => AppLocalizations.of(this)!.appTitle;
  String thisApp() => AppLocalizations.of(this)!.thisApp;
  String s() => AppLocalizations.of(this)!.s;
  String tracker() => AppLocalizations.of(this)!.tracker;
  String notSet() => AppLocalizations.of(this)!.notSet;
  String allowance() => AppLocalizations.of(this)!.allowance;
  String assets() => AppLocalizations.of(this)!.assets;
  String balance() => AppLocalizations.of(this)!.balance;
  String spends() => AppLocalizations.of(this)!.spend;
  String moneyLeft() => AppLocalizations.of(this)!.moneyLeft;
  String moneySpent() => AppLocalizations.of(this)!.moneySpent;
  String month() => AppLocalizations.of(this)!.month;
  String list() => AppLocalizations.of(this)!.list;
  String summary() => AppLocalizations.of(this)!.summary;
  String delete() => AppLocalizations.of(this)!.delete;
  String cancel() => AppLocalizations.of(this)!.cancel;
  String modifyDateTitle() => AppLocalizations.of(this)!.modifyDateTitle;
  String modifyItemTitle() => AppLocalizations.of(this)!.modifyItemTitle;
  String modifyAmntTitle() => AppLocalizations.of(this)!.modifyAmntTitle;
  String settingDateHint() => AppLocalizations.of(this)!.settingDateHint;
  String settingItemHint() => AppLocalizations.of(this)!.settingItemHint;
  String settingAmntHint() => AppLocalizations.of(this)!.settingAmntHint;
  String settingReasonHint() => AppLocalizations.of(this)!.settingReasonHint;
  
  // Drawer localized strings
  String name() => AppLocalizations.of(this)!.name;
  String settingNameTitle() => AppLocalizations.of(this)!.settingNameTitle;
  String settingNameHint() => AppLocalizations.of(this)!.settingNameHint;
  String unit() => AppLocalizations.of(this)!.unit;
  String settingUnitTitle() => AppLocalizations.of(this)!.settingUnitTitle;
  String initialAssets() => AppLocalizations.of(this)!.initialAssets;
  String settingInitialAssetsTitle() => AppLocalizations.of(this)!.settingInitialAssetsTitle;
  String targetAssets() => AppLocalizations.of(this)!.targetAssets;
  String settingTargetAssetsTitle() => AppLocalizations.of(this)!.settingTargetAssetsTitle;
  String startDate() => AppLocalizations.of(this)!.startDate;
  
  // Login localized strings
  String success() => AppLocalizations.of(this)!.success;
  String error() => AppLocalizations.of(this)!.error;
  String login() => AppLocalizations.of(this)!.login;
  String signup() => AppLocalizations.of(this)!.signup;
  String deleteAccount() => AppLocalizations.of(this)!.deleteAccount;
  String tryLogin() => AppLocalizations.of(this)!.tryLogin;
  String tryLogout() => AppLocalizations.of(this)!.tryLogout;
  String trySignup() => AppLocalizations.of(this)!.trySignup;
  String tryDeleteAccount() => AppLocalizations.of(this)!.tryDeleteAccount;
  String email() => AppLocalizations.of(this)!.email;
  String password() => AppLocalizations.of(this)!.password;
  String confirmPass() => AppLocalizations.of(this)!.confirmPass;
  String inputEmailHint() => AppLocalizations.of(this)!.inputEmailHint;
  String inputPasswordHint() => AppLocalizations.of(this)!.inputPasswordHint;
  String inputConfirmPassHint() => AppLocalizations.of(this)!.inputConfirmPassHint;
  String forgotPass() => AppLocalizations.of(this)!.forgotPass;
  String passwordReset() => AppLocalizations.of(this)!.passwordReset;
  String ok() => AppLocalizations.of(this)!.ok;
  String no() => AppLocalizations.of(this)!.no;
  String canceled() => AppLocalizations.of(this)!.cancel;
  
  // Auth error localized strings
  String invalidEmail() => AppLocalizations.of(this)!.invalidEmail;
  String wrongPassword() => AppLocalizations.of(this)!.wrongPassword;
  String userNotFound() => AppLocalizations.of(this)!.userNotFound;
  String userDisabled() => AppLocalizations.of(this)!.userDisabled;
  String tooManyRequests() => AppLocalizations.of(this)!.tooManyRequests;
  String operationNotAllowed() => AppLocalizations.of(this)!.operationNotAllowed;
  String emailAlreadyInUse() => AppLocalizations.of(this)!.emailAlreadyInUse;
  String weakPassword() => AppLocalizations.of(this)!.weakPassword;
  String loginSuccess() => AppLocalizations.of(this)!.loginSuccess;
  String loginFailed() => AppLocalizations.of(this)!.loginFailed;
  String logoutSuccess() => AppLocalizations.of(this)!.logoutSuccess;
  String logoutFailed() => AppLocalizations.of(this)!.logoutFailed;
  String signupSuccess() => AppLocalizations.of(this)!.signupSuccess;
  String signupFailed() => AppLocalizations.of(this)!.signupFailed;
  String deleteAccountSuccess() => AppLocalizations.of(this)!.deleteAccountSuccess;
  String deleteAccountFailed() => AppLocalizations.of(this)!.deleteAccountFailed;
  String loginErrorMessage() => AppLocalizations.of(this)!.loginErrorMessage;
  String signupErrorMessage() => AppLocalizations.of(this)!.signupErrorMessage;
  String sendMailError() => AppLocalizations.of(this)!.sendEmailError;
  String sentVerifiedEmail() => AppLocalizations.of(this)!.sentVerifiedEmail;
  String cantSendVerifiedEmail() => AppLocalizations.of(this)!.cantSendVerifiedEmail;
  String sentPassResetMail() => AppLocalizations.of(this)!.sentPassResetEmail;
  String cantSendPassResetEmail() => AppLocalizations.of(this)!.cantSendPassResetEmail;
  
  // Firestore localized strings
  String storeDataAfterLogin() => AppLocalizations.of(this)!.storeDataAfterLogin;
  String getStoredData() => AppLocalizations.of(this)!.getStoredData;
  String storeYourData() => AppLocalizations.of(this)!.storeYourData;
  String getDataSuccess() => AppLocalizations.of(this)!.getDataSuccess;
  String storeDataSuccess() => AppLocalizations.of(this)!.storeDataSuccess;
  String getDataFailed() => AppLocalizations.of(this)!.getDataFailed;
  String storeDataFailed() => AppLocalizations.of(this)!.storeDataFailed;
  String noDataAvailable() => AppLocalizations.of(this)!.noDataAvailable;
  String confirmation() => AppLocalizations.of(this)!.confirmation;
  String confirmGetServerData() => AppLocalizations.of(this)!.confirmGetServerData;
  String confirmStoreLocalData() => AppLocalizations.of(this)!.confirmStoreLocalData;
  String confirmDeleteAccount() => AppLocalizations.of(this)!.confirmDeleteAccount;

  // Common utility methods
  String orNotSet(String text) => (text == "") ? notSet(): text;
  String judgeText(String judge) => (judge == "ok") ? ok(): (judge == "no") ? no(): canceled();

  // AppBar text methods
  String appBarTitleText(bool isSelectSummary) => (isSelectSummary) ? list(): summary();
  String popupMenuText(bool isSelectSummary) => (isSelectSummary) ? tryLogout(): tryLogin();

  // Drawer text methods
  String drawerTitle(String name) =>
      (name.isEmpty || name == notSet()) ? appTitle():
      "$name${s()}\n${tracker()}";
  String drawerAlertTitle(String input) =>
      (input == "unit") ? settingUnitTitle():
      (input == "initialAssets") ? settingInitialAssetsTitle():
      (input == "targetAssets") ? settingTargetAssetsTitle():
      settingNameTitle();
  String drawerAlertHint(String input) =>
      " ${(input == "name") ? settingNameHint(): settingAmntHint()}";
  String drawerLoginTitle(bool isLogin, bool isStoreData) =>
      (!isLogin) ? storeDataAfterLogin():
      (isStoreData) ? storeYourData():
      getStoredData();
  
  // Spreadsheet text methods
  String spreadSheetAlertTitleText(String input) =>
      (input == "item") ? modifyItemTitle():
      (input == "amnt") ? modifyAmntTitle():
      modifyDateTitle();
  String spreadSheetAlertHint(String input, bool isSpend) =>
      " ${(input == "amnt") ? settingAmntHint(): (isSpend) ? settingItemHint(): settingReasonHint()}";
  Locale selectDayLocale() =>
      (lang() == "ja") ? Locale('ja', 'JP'): Locale('en', 'US');
  String speedDialTitle(bool isSpend) =>
      (isSpend) ? spends(): allowance();
  
  // Chart text methods
  String chartTitle(Color color) =>
      (color == pinkColor) ? assets():
      (color == blueColor) ? moneySpent():
      moneyLeft();
  
  // Login text methods
  String loginAppBarTitleText(bool isMoveSignUp) =>
      (isMoveSignUp) ? signup(): login();
  String loginFormLabel(String input) =>
      (input == "password") ? password():
      (input == "confirmPass") ? confirmPass():
      email();
  String loginFormHint(String input) =>
      (input == "password") ? inputPasswordHint():
      (input == "confirmPass") ? inputConfirmPassHint():
      inputEmailHint();
  String loginErrorCodeMessage(String errorCode, String todo) =>
      (errorCode == 'invalid-email') ? invalidEmail():
      (errorCode == 'wrong-password') ? wrongPassword():
      (errorCode == 'user-not-found') ? userNotFound():
      (errorCode == 'user-disabled') ? userDisabled():
      (errorCode == 'too-many-requests') ? tooManyRequests():
      (errorCode == 'operation-not-allowed') ? operationNotAllowed():
      (errorCode == 'email-already-in-use') ? emailAlreadyInUse():
      (errorCode == 'weak-password') ? weakPassword():
      (todo == "login") ? loginErrorMessage():
      (todo == "signup") ? signupErrorMessage():
      cantSendPassResetEmail();
}

/// String extensions for data conversion and SharedPreferences operations
extension StringExt on String {

  // Debug print method
  void debugPrint() {
    if (kDebugMode) print(this);
  }

  // Data conversion methods
  int toInt(int defaultInt) =>
      (int.parse(this) >= 0) ? int.parse(this): defaultInt;
  double toDouble(double defaultDouble) =>
      (double.parse(this) >= 0.0) ? double.parse(this): defaultDouble;
  
  // Convert string to 2D list of dates
  List<List<int>> toListListDate() {
    final originalData = replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<int>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<int> sublist = stringValues.map((value) => int.parse(value)).toList();
      data.add(sublist);
    }
    return data;
  }
  
  // Convert string to 2D list of items
  List<List<String>> toListListItem() {
    final originalData = replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<String>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<String> sublist = stringValues.map((value) => value.replaceAll('"', '')).toList();
      data.add(sublist);
    }
    return data;
  }
  
  // Convert string to 2D list of amounts
  List<List<double>> toListListAmnt() {
    final originalData = replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<double>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<double> sublist = stringValues.map((value) => double.parse(value)).toList();
      data.add(sublist);
    }
    return data;
  }

  // SharedPreferences setter methods
  setSharedPrefString(SharedPreferences prefs, String value) {
    "${replaceAll("Key","")}: $value".debugPrint();
    prefs.setString(this, value);
  }
  setSharedPrefDouble(SharedPreferences prefs, double value) {
    "${replaceAll("Key","")}: $value".debugPrint();
    prefs.setDouble(this, value);
  }
  setSharedPrefInt(SharedPreferences prefs, int value) {
    "${replaceAll("Key","")}: $value".debugPrint();
    prefs.setInt(this, value);
  }
  setSharedPrefBool(SharedPreferences prefs, bool value) {
    "${replaceAll("Key","")}: $value".debugPrint();
    prefs.setBool(this, value);
  }
  
  // SharedPreferences getter methods
  getSharedPrefString(SharedPreferences prefs, String defaultString) {
    "${replaceAll("Key","")}: ${prefs.getString(this) ?? defaultString}".debugPrint();
    return prefs.getString(this) ?? defaultString;
  }
  getSharedPrefDouble(SharedPreferences prefs, double defaultDouble) {
    "${replaceAll("Key","")}: ${prefs.getDouble(this) ?? defaultDouble}".debugPrint();
    return prefs.getDouble(this) ?? defaultDouble;
  }
  getSharedPrefInt(SharedPreferences prefs, int defaultInt) {
    "${replaceAll("Key","")}: ${prefs.getInt(this) ?? defaultInt}".debugPrint();
    return prefs.getInt(this) ?? defaultInt;
  }
  getSharedPrefBool(SharedPreferences prefs, bool defaultBool) {
    "${replaceAll("Key","")}: ${prefs.getBool(this) ?? defaultBool}".debugPrint();
    return prefs.getBool(this) ?? defaultBool;
  }
  
  // List getter methods for SharedPreferences
  getIntList(SharedPreferences prefs, int maxIndex) {
    "${replaceAll("Key","")}: ${List.generate(maxIndex + 1, (i) => prefs.getInt("$this$i") ?? 1)}".debugPrint();
    return List.generate(maxIndex + 1, (i) => prefs.getInt("$this$i") ?? 1);
  }
  getDoubleList(SharedPreferences prefs, int maxIndex) {
    "${replaceAll("Key","")}: ${List.generate(maxIndex + 1, (i) => prefs.getDouble("$this$i") ?? 0.0)}".debugPrint();
    return List.generate(maxIndex + 1, (i) => prefs.getDouble("$this$i") ?? 0.0);
  }
  
  // Allowance data getter methods
  getAllowanceDate(SharedPreferences prefs, int maxIndex, List<int> allowanceDate) {
    List<List<int>> data = List.generate(maxIndex + 1, (i) =>
      List.generate(allowanceDate[i], (j) => prefs.getInt("$this${i}_$j") ?? 0)
    );
    "AllowanceDate: $data".debugPrint();
    return data;
  }
  getAllowanceItem(SharedPreferences prefs, int maxIndex, List<int> allowanceItem) {
    List<List<String>> data = List.generate(maxIndex + 1, (i) =>
      List.generate(allowanceItem[i], (j) => prefs.getString("$this${i}_$j") ?? "")
    );
    "AllowanceItem: $data".debugPrint();
    return data;
  }
  getAllowanceAmnt(SharedPreferences prefs, int maxIndex, List<int> allowanceAmnt) {
    List<List<double>> data = List.generate(maxIndex + 1, (i) =>
      List.generate(allowanceAmnt[i], (j) => prefs.getDouble("$this${i}_$j") ?? 0.0)
    );
    "AllowanceAmnt: $data".debugPrint();
    return data;
  }
  
  // Input validation methods for SpeedDial
  bool setIsInput(bool isDay) {
    "inputFlag: ${RegExp(isDay ? dayValidation: amountValidation).hasMatch(this)}".debugPrint();
    return RegExp(isDay ? dayValidation: amountValidation).hasMatch(this);
  }
  int setInputDay(bool isInput) {
    "inputDay: ${isInput ? toInt(0): 0}".debugPrint();
    return isInput ? toInt(0): 0;
  }
  bool setIsDayInput(bool isInput, int year) {
    "isDayInput: ${(isInput && toInt(0).correctDay(year) > 0)}".debugPrint();
    return (isInput && toInt(0).correctDay(year) > 0);
  }
  String setInputItem(BuildContext context, bool isInput, bool isSpend) {
    "inputItem: ${(isInput) ? this: ""}".debugPrint();
    return (isInput) ? this: "";
  }
  bool setIsItemInput(bool isInput) {
    "isItemInput: $isInput".debugPrint();
    return isInput;
  }
  double setInputAmount(bool isInput, bool isSpend, String unit) {
    "inputAmount: ${(isInput) ? isSpend.setPlusMinus() * toDouble(0.0): 0.0}".debugPrint();
    return (isInput) ? isSpend.setPlusMinus() * toDouble(0.0): 0.0;
  }
  bool setIsAmountInput(bool isInput) {
    "isAmountInput: ${(isInput && toDouble(0.0) != 0.0)}".debugPrint();
    return (isInput && toDouble(0.0) != 0.0);
  }
  bool setIsInitialAssetsInput(bool isInput) {
    "isAmountInput: ${isInput ? (toDouble(0.0) >= 0.0) : false}".debugPrint();
    return isInput ? (toDouble(0.0) >= 0.0) : false;
  }

  // Currency unit methods
  int numberDigit() => (this == '¥') ? 0: 2;

  // Date formatting methods
  String addZero() => (toInt(0) < 10) ? "0$this": this;
  int removeZero() => (this[0] == "0") ? this[1].toInt(1): toInt(1);

  // Start date parsing methods
  int toDay() => split("/")[1].removeZero();
  int toMonth() => split("/")[0].removeZero();
  int toYear() => split("/")[2].toInt(2023);
  int toDateInt() => toYear() * 10000 + toMonth() * 100 + toDay();
  int currentIndex() => 12 * (DateTime.now().year - toYear()) + (DateTime.now().month - toMonth());

  // Date calculation methods
  DateTime toThisDate(int index) =>
      DateTime(toYear() + (index + toMonth()) ~/ 12, (toMonth() + index) % 12, toDay());
  DateTime toThisMonthFirstDay(int index) =>
      DateTime(toThisDate(index).year, toThisDate(index).month, 1);
  DateTime toThisMonthLastDay(int index) =>
      DateTime(toThisDate(index).year, toThisDate(index).month, toThisDate(index).month.lastDay(toThisDate(index).year));
  String stringThisMonthYear(int index) => ""
      "${toThisDate(index).month.toString().addZero()}/${toThisDate(index).year}";
  String stringThisYear(int index) =>
      "${toThisDate(index).year}";
  String stringThisMonthDay(int index, int day) =>
      (day > 0 && day < toThisDate(index).month.lastDay(toThisDate(index).year) + 1) ? "${toThisDate(index).month}/${day.toString().addZero()}": "-";
  
  // Navigation color methods
  Color yearPlusMinusColor(bool isPlus, int index, int maxIndex) =>
      ((!isPlus && (toThisDate(index).year == toThisDate(0).year)) || (isPlus && (toThisDate(index).year >= toThisDate(maxIndex).year))).selectButtonColor();
  Color monthPlusMinusColor(bool isPlus, int index) =>
      (!isPlus && (index == 0)).selectButtonColor();
  
  // Chart data methods
  int toTargetIndex(int index, int i) =>
      i - toMonth() + 1 + 12 * (toThisDate(index).year - toYear());
  bool isNotExistChartData(int index, int maxIndex, double spotX) =>
      (toTargetIndex(index, (spotX - 1).toInt()) < 0) || (toTargetIndex(index, (spotX - 1).toInt()) > maxIndex);

  // UI icon and color methods
  IconData drawerAlertIcon() => (this == "name") ? nameIcon: amntIcon;
  Color drawerAlertColor() => (this == "initialAssets") ? pinkColor: purpleColor;
  IconData spreadSheetAlertIcon() => (this == "amnt") ? amntIcon: itemIcon;
  IconData loginPrefixIcon() =>
      (this == "email" || this == "reset") ? nameIcon: lockIcon;
  List<FilteringTextInputFormatter> loginInputFormat() =>
      (this == "email" || this == "reset") ? inputEmailFormat: inputPasswordFormat;
  bool isLoginObscureText(bool isVisible) =>
      ((this == "password" || this == "confirmPass") && !isVisible);
}

/// Map extensions for Firestore data handling
extension MapDynamicExt on Map<String, dynamic> {

  // Firestore data getter methods
  String getFirestoreString(SharedPreferences prefs, String key, String initialValue) {
    key.setSharedPrefString(prefs, this[key] ?? initialValue);
    return this[key] ?? initialValue;
  }
  double getFirestoreDouble(SharedPreferences prefs, String key, double initialValue) {
    key.setSharedPrefDouble(prefs, this[key] ?? initialValue);
    return this[key] ?? initialValue;
  }
  List<List<int>> getFirestoreDate(SharedPreferences prefs) {
    "dateKey".setSharedPrefString(prefs, (this["dateKey"] ?? "[[0]]"));
    return (this["dateKey"] ?? "[[0]]").toString().toListListDate();
  }
  List<List<String>> getFirestoreItem(SharedPreferences prefs) {
    "itemKey".setSharedPrefString(prefs, (this["itemKey"] ?? "[[""]]"));
    return (this["itemKey"] ?? "[[""]]").toString().toListListItem();
  }
  List<List<double>> getFirestoreAmnt(SharedPreferences prefs) {
    "amntKey".setSharedPrefString(prefs, (this["amntKey"] ?? "[[0.0]]"));
    return (this["amntKey"] ?? "[[0.0]]").toString().toListListAmnt();
  }
}

/// Double extensions for formatting and calculations
extension DoubleExt on double {

  // Size methods
  Size circleSize() => Size(this, this);

  // Amount formatting methods
  double toAbs() =>
      (this < 0) ? this * (-1.0): this;
  String formatNumber(String unit) =>
      NumberFormat((unit == "¥") ? "#,###": "#,##0.00").format(toAbs());
  String stringBalance(String unit) =>
      (this <= 0.0) ? "0": formatNumber(unit);
  String stringAmount(String unit) =>
      (this == 0.0) ? "": formatNumber(unit);
  String stringAssets(BuildContext context, String unit) =>
      (this == 0.0) ? "0": (this > 0.0) ? formatNumber(unit): context.notSet();
  String stringItem(BuildContext context, String item) =>
      (this == 0.0 || item.isEmpty) ? "": item;
  Color amountColor() =>
      (this == 0.0) ? whiteColor: (this > 0.0) ? pinkColor: blueColor;
  
  // Chart Y-axis calculation
  double toChartY() =>
      (this == 0) ? 0:
      (this < 10) ? 10:
      (this < 20) ? 20:
      (this < 50) ? 50:
      (this < 100) ? 100:
      (this < 200) ? 200:
      (this < 500) ? 500:
      (this < 1000) ? 1000:
      (this < 2000) ? 2000:
      (this < 5000) ? 5000:
      (this < 10000) ? 10000:
      (this < 20000) ? 20000:
      (this < 50000) ? 50000:
      (this < 100000) ? 100000:
      (this < 200000) ? 200000:
      (this < 500000) ? 500000:
      (this < 1000000) ? 1000000:
      (this < 2000000) ? 2000000:
      (this < 5000000) ? 5000000:
      10000000;
  double maxChartY(double? targetAssets) =>
      ((targetAssets == null) ? this: max(this, targetAssets)).toChartY();
}

/// Boolean extensions for UI styling
extension BoolExt on bool {

  Color speedDialColor() =>
      (this) ? blueColor: pinkColor;   // isSpend
  IconData speedDialIcon() =>
      (this) ? itemIcon: unitIcon;     // isSpend
  Color selectButtonColor() =>
      (this) ? grayColor: purpleColor; // isInput
  double setPlusMinus() =>
      (this) ? -1.0: 1.0;              // isSpend
  IconData visibleIcon() =>
      this ? eyeOnIcon: eyeOffIcon;
  Color visibleIconColor() =>
      this ? purpleColor: transpLightBlackColor;
}

/// Integer extensions for date calculations
extension IntExt on int {

  // Leap year calculation
  bool isLeapYear() => (this % 4 == 0 && this % 100 != 0) || (this % 400 == 0);
  
  // Last day of month calculation
  int lastDay(int year) =>
    (this == 2 && year.isLeapYear()) ? 29:
    (this == 2) ? 28:
    [4, 6, 9, 11].contains(this) ? 30:
    31;
  
  // Day validation methods
  bool isCorrectDay(int year) => (this > 0 && this < lastDay(year) + 1);
  int correctDay(int year) => isCorrectDay(year) ? this: 0;
}

/// DateTime extensions for formatting
extension DateExt on DateTime? {

  // Date formatting methods
  String toMonthString() => this!.month.toString().addZero();
  String toDayString() => this!.day.toString().addZero();
  String toYearString() => this!.year.toString();
  String toHourString() => this!.hour.toString().addZero();
  String toMinuteString() => this!.minute.toString().addZero();
  String toSecondString() => this!.second.toString().addZero();
  String toDateString() => "${toMonthString()}/${toDayString()}/${toYearString()}";
  String toDateTimeString() =>
      "${toYearString()}${toMonthString()}${toDayString()}${toHourString()}${toMinuteString()}${toSecondString()}";
  int toDateTimeInt() => int.parse(toDateTimeString());
}

/// List<Map> extensions for sorting
extension ListMapExt on List<Map> {

  // Sort allowance list by date
  Future<void> allowanceListSort() async {
    sort((a, b) => a["date"].compareTo(b["date"]));
  }
}

/// List<double> extensions for calculations and chart data
extension ListDoubleExt on List<double> {

  // Financial calculations
  double toAllowance() =>
      List.generate(length, (i) => (this[i] > 0.0) ? this[i]: 0.0).reduce((a, b) => a + b);
  double toBalance() =>
      List.generate(length, (i) => this[i]).reduce((a, b) => a + b);
  double toSpends() =>
    List.generate(length, (i) => (this[i] < 0.0) ? (-1.0) * this[i]: 0.0).reduce((a, b) => a + b);
  double toPercent() =>
      (toBalance() < 0 || toAllowance() == 0) ? 0.0: toBalance() / toAllowance();

  // Assets calculation methods
  List<double> calcAssets(int maxIndex, double initialAssets) {
    List<double> assets = [];
    double sum = initialAssets;
    for (var i = 0; i < maxIndex + 1; i++) {
      sum += this[i];
      assets.add(sum);
    }
    "assets: $assets".debugPrint();
    return assets;
  }
  List<double> saveCalcAssets(SharedPreferences prefs, int maxIndex, double initialAssets) {
    calcAssets(maxIndex, initialAssets).setDoubleList(prefs, "spendsKey");
    return calcAssets(maxIndex, initialAssets);
  }
  setDoubleList(SharedPreferences prefs, String key) {
    for (var i = 0; i < length; i++) {
      prefs.setDouble("$key$i", this[i]);
    }
    "${key.replaceAll("Key", "")}: $this".debugPrint();
  }

  // Allowance list conversion
  List<AllowanceList> getAllowanceList(List<int> date, List<String> item) =>
      List.generate(length, (i) => AllowanceList(date[i], item[i], this[i]));

  // Chart data generation methods
  List<FlSpot> chartData(int index, int maxIndex, String startDate) =>
      List.generate(12, (int i) {
        int targetIndex = startDate.toTargetIndex(index, i);
        return FlSpot((i + 1).toDouble(), (targetIndex < 0 || maxIndex < targetIndex || this[targetIndex] < 0) ? 0.0: this[targetIndex]);
      }).where((spot) =>
        !startDate.isNotExistChartData(index, maxIndex, spot.x)
      ).toList();

  List<FlSpot> targetChartData(double targetAssets) =>
      List.generate(12, (int i) => FlSpot((i + 1).toDouble(), targetAssets));
}

/// List<AllowanceList> extensions for data extraction
extension ListAllowanceListExt on List<AllowanceList> {

  // Extract data from allowance list
  List<int> getDateFromAllowanceList() =>
      List.generate(length, (i) => this[i].date);
  List<String> getItemFromAllowanceList() =>
      List.generate(length, (i) => this[i].item);
  List<double> getAmntFromAllowanceList() =>
      List.generate(length, (i) => this[i].amnt);
}

/// List<int> extensions for SharedPreferences operations
extension ListIntExt on List<int> {

  // Save integer list to SharedPreferences
  setIntList(SharedPreferences prefs, String key) {
    for (var i = 0; i < length; i++) {
      prefs.setInt("$key$i", this[i]);
    }
    "${key.replaceAll("Key", "")}: $this".debugPrint();
  }
}

/// List<List<double>> extensions for financial calculations
extension ListListDoubleExt on List<List<double>> {

  // Calculate maximum index
  int calcMaxIndex() {
    "maxIndex: ${length - 1}".debugPrint();
    return length - 1;
  }
  
  // Calculate list numbers
  List<int> calcListNumber() {
    "listNumber: ${List.generate(length, (i) => this[i].length)}".debugPrint();
    return List.generate(length, (i) => this[i].length);
  }
  
  // Calculate percentages
  List<double> calcPercent(int maxIndex) {
    "percent: ${List.generate(maxIndex + 1, (i) => this[i].toPercent())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toPercent());
  }
  
  // Calculate balances
  List<double> calcBalance(int maxIndex) {
    "balance: ${List.generate(maxIndex + 1, (i) => this[i].toBalance())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toBalance());
  }
  
  // Calculate spends
  List<double> calcSpends(int maxIndex) {
    "spends: ${List.generate(maxIndex + 1, (i) => this[i].toSpends())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toSpends());
  }
}


