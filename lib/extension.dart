import 'dart:math';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'constant.dart';

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

extension ContextExt on BuildContext {

  //Common
  void pushPage(String page) => Navigator.of(this).pushNamedAndRemoveUntil(page, (_) => false);
  void popPage() => Navigator.pop(this);
  //Language
  String lang() => Localizations.localeOf(this).languageCode;
  int inputItemMaxLength() => (lang() == "ja") ? inputJaItemMaxLength: inputEnItemMaxLength;
  int inputNameMaxLength() => (lang() == "ja") ? inputJaNameMaxLength: inputEnNameMaxLength;
  String customEnFont() => (lang() == "ja") ? 'defaultFont': 'enAccent';
  String customJaFont() => (lang() == "ja") ? 'jaAccent': 'defaultFont';
  String customAccentFont() => (lang() == "ja") ? 'jaAccent': 'enAccent';
  double appBarFontSize() => (lang() == "ja") ? appBarJaFontSize: appBarEnFontSize;
  double alertTitleFontSize() => (lang() == "ja") ? alertTitleJaSize: alertTitleEnSize;
  double alertFontSize() => (lang() == "ja") ? alertFontJaSize: alertFontEnSize;
  String defaultUnit() => (lang() == "ja") ? "¥": "\$";
  List<String> unitList() => (lang() == "ja") ? jaUnitList: enUnitList;
  FontWeight customWeight() => (lang() == "ja") ? FontWeight.normal: FontWeight.bold;
  //Size
  double width() => MediaQuery.of(this).size.width;
  double maxWidth() => (width() > 660) ? 660: width();
  double height() => MediaQuery.of(this).size.height;
  double top() => MediaQuery.of(this).padding.top;
  double bottom() => MediaQuery.of(this).padding.bottom;
  double displayHeight() => height() - top() - bottom() - admobHeight();
  //Drawer
  double drawerWidth() => maxWidth() * drawerWidthRate;
  double drawerTitleHeightRate(String name) =>
      (drawerTitle(name) == title()) ? drawerTitleNoNameHeightRate: drawerTitleExistNameHeightRate;
  double drawerTitleHeight(String name) => maxWidth() * drawerTitleHeightRate(name);
  double drawerTitleBorderRadius() => maxWidth() * drawerTitleBorderRadiusRate;
  double drawerTitleFontSize() => maxWidth() * drawerTitleFontSizeRate;
  double drawerMenuListIconSize() => maxWidth() * drawerMenuListIconSizeRate;
  double drawerMenuListFontSize() => maxWidth() * drawerMenuListFontSizeRate;
  double drawerMenuListMarginTop() => maxWidth() * drawerMenuListMarginTopRate;
  double drawerMenuListMargin() => height() * drawerMenuListMarginRate;
  double drawerMenuListSubTitleMarginTop() => maxWidth() * drawerMenuListSubTitleMarginTopRate;
  BorderRadius drawerBorderRadius() => BorderRadius.only(
    topRight: Radius.circular(drawerTitleBorderRadius()),
    bottomRight: Radius.circular(drawerTitleBorderRadius()),
  );

  //Main Body
  double mainBodyMarginTop() => height() * mainBodyMarginTopRate;
  double balanceFontSize() => maxWidth() * (lang() == "ja" ? balanceJaFontSizeRate: balanceEnFontSizeRate);
  double balanceUnitSize() => maxWidth() * balanceUnitSizeRate;
  double balanceMoneySize() => maxWidth() * balanceMoneySizeRate;
  double balanceMoneyShiftSize() => maxWidth() * balanceMoneyShiftSizeRate;
  double balanceMarginHorizontal() => maxWidth() * balanceMarginHorizontalRate;
  double percentMarginBottom() => height() * percentMarginBottomRate;
  double percentBarWidth() => (width() * percentBarWidthRate > percentBarMaxWidth) ? percentBarMaxWidth: width() * percentBarWidthRate;
  double plusMinusSize() => height() * plusMinusSizeRate;
  double plusMinusMarginTop() => maxWidth() * plusMinusMarginTopRate;
  double plusMinusIconSize() => height() * plusMinusIconSizeRate;
  double plusMinusSpace() => height() * plusMinusSpaceRate;
  double monthYearFontSize() => maxWidth() * monthYearFontSizeRate;
  //Floating Action Button
  double floatingActionBottomMargin() => admobHeight() + height() * floatingActionBottomMarginRate;
  double floatingActionButtonSize() => maxWidth() * floatingActionButtonSizeRate;
  double floatingActionIconSize() => maxWidth() * floatingActionIconSizeRate;
  double speedDialIconSize() => maxWidth() * speedDialIconSizeRate;
  double speedDialChildButtonSize() => maxWidth() * speedDialChildButtonSizeRate;
  double speedDialChildIconSize() => maxWidth() * speedDialChildIconSizeRate;
  double speedDialSpaceFontSize() => maxWidth() * speedDialSpaceFontSizeRate;
  double speedDialSpacing() => maxWidth() * speedDialSpacingRate;
  double speedDialSpaceHeight() => maxWidth() * speedDialSpaceHeightRate;
  //Chart & SpreadSheet
  double scrollViewMarginHorizontal() => width() * scrollViewMarginHorizontalRate;
  double scrollViewMarginVertical() => height() * scrollViewMarginVerticalRate;
  double spreadSheetCornerRadius() => height() * spreadSheetCornerRadiusRate;
  double spreadSheetFontSize() => height() * spreadSheetFontSizeRate;
  double spreadSheetIconSize() => height() * spreadSheetIconSizeRate;
  double spreadSheetRowHeight() => height() * spreadSheetRowHeightRate;
  double spreadSheetColumnSpacing() => height() * spreadSheetColumnSpacingRate;
  double deleteButtonWidth() => height() * deleteButtonWidthRate;
  //Chart
  double chartHeight() => height() * chartHeightRate;
  double chartWidth() => (width() > 1000) ? 1000: width();
  double chartBarWidth() => height() * chartBarWidthRate;
  double chartDotWidth() => height() * chartDotWidthRate;
  double chartBorderWidth() => height() * chartBorderWidthRate;
  double chartVerticalBorderWidth() => height() * chartVerticalBorderWidthRate;
  double chartHorizontalBorderWidth() => height() * chartHorizontalBorderWidthRate;
  double chartTitleFontSize() => height() * chartTitleFontSizeRate;
  double chartBottomMargin() => height() * chartBottomMarginRate;
  double chartTopAxisNameSize() => height() * chartTopAxisNameSizeRate;
  double chartBottomAxisNameSize() => height() * chartBottomAxisNameSizeRate;
  double chartTopMarginLeft() => height() * chartTopMarginLeftRate;
  double chartBottomMarginLeft() => height() * chartBottomMarginLeftRate;
  double chartBottomFontSize() => height() * chartBottomFontSizeRate;
  double chartLeftReservedSize() => width() * chartLeftReservedSizeRate;
  double chartBottomReservedSize() => width() * chartBottomReservedSizeRate;
  double chartAxisFontSize() => width() * chartAxisFontSizeRate;
  //Login
  double loginTitleSize() => maxWidth() * (lang() == "ja" ? loginJaTitleSizeRate: loginEnTitleSizeRate);
  double loginIconSize() => maxWidth() * loginIconSizeRate;
  double loginFontSize() => maxWidth() * loginFontSizeRate;
  double loginMessageSize() => maxWidth() * loginMessageSizeRate;
  double loginHintSize(String input) =>
      maxWidth() * ((input == "password") ? loginPassHintSizeRate: loginHintSizeRate);
  double loginTitleMarginTop() => maxWidth() * loginTitleMarginTopRate;
  double loginTitleMarginBottom() => maxWidth() * loginTitleMarginBottomRate;
  double loginInputAreaRadius() => maxWidth() * loginInputAreaRadiusRate;
  double loginInputAreaWidth() => maxWidth() * loginInputAreaWidthRate;
  double loginInputAreaPadding() => maxWidth() * loginInputAreaPaddingRate;
  double loginInputIconSpace() => maxWidth() * loginInputIconSpaceRate;
  double loginTextFieldMarginBottom() => maxWidth() * loginTextFieldMarginBottomRate;
  double loginButtonWidth() => maxWidth() * loginButtonWidthRate;
  double loginButtonHeight() => maxWidth() * loginButtonHeightRate;
  double loginButtonRadius() => loginButtonHeight() / 2;
  double loginButtonMarginTop() => maxWidth() * loginButtonMarginTopRate;
  double loginButtonMarginBottom() => maxWidth() * loginButtonMarginBottomRate;
  double moveSignupMarginTop() => maxWidth() * moveSignupMarginTopRate;
  double moveSignupMarginBottom() => maxWidth() * moveSignupMarginBottomRate;
  double forgetPassMarginTop() => maxWidth() * forgetPassMarginTopRate;
  double loginCounterCharSize() => maxWidth() * loginCounterCharSizeRate;
  double loginVisibleMarginTop() => maxWidth() * loginVisibleMarginTopRate;
  double loginVisibleMarginRight() => maxWidth() * loginVisibleMarginRightRate;
  double snackBarMargin() => maxWidth() * snackBarMarginRate;

      //Admob
  double admobHeight() => admobMinimumHeight + ((height() < 600) ? 0: (height() < 1000) ? (height() - 600) / 8: 50);
  double admobWidth() => width() - 100;
  // Localize String
  String appTitle() => AppLocalizations.of(this)!.appTitle;
  String thisApp() => AppLocalizations.of(this)!.thisApp;
  String title() => AppLocalizations.of(this)!.title;
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
  //Drawer
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
  //Login
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
  //Auth
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

  //Firestore
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

  //Common
  String orNotSet(String text) =>
      (text == "") ? notSet(): text;
  String judgeText(String judge) =>
      (judge == "ok") ? ok(): (judge == "no") ? no(): canceled();
  //AppBar
  String appBarTitleText(bool isSelectSummary) =>
      (isSelectSummary) ? list():summary();
  String popupMenuText(bool isSelectSummary) =>
      (isSelectSummary) ? tryLogout(): tryLogin();
  //Drawer
  String drawerTitle(String name) =>
      (name.isEmpty || name == notSet()) ? title():
      (lang() == "ja") ? "$name${s()}\n\n${tracker()}":
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
  //SpreadSheet
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
  //Chart
  String chartTitle(Color color) =>
      (color == pinkColor) ? assets():
      (color == blueColor) ? moneySpent():
      moneyLeft();
  //Login
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

extension StringExt on String {

  //common
  void debugPrint() {
    if (kDebugMode) print(this);
  }

  //
  int toInt(int defaultInt) =>
      (int.parse(this) >= 0) ? int.parse(this): defaultInt;
  double toDouble(double defaultDouble) =>
      (double.parse(this) >= 0.0) ? double.parse(this): defaultDouble;
  List<List<int>> toListListDate() {
    final originalData = this.replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<int>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<int> sublist = stringValues.map((value) => int.parse(value)).toList();
      data.add(sublist);
    }
    return data;
  }
  List<List<String>> toListListItem() {
    final originalData = this.replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<String>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<String> sublist = stringValues.map((value) => value.replaceAll('"', '')).toList();
      data.add(sublist);
    }
    return data;
  }
  List<List<double>> toListListAmnt() {
    final originalData = this.replaceAll("[[", "").replaceAll("]]", "");
    List<String> outerList = originalData.split("],[");
    List<List<double>> data = [];
    for (String innerList in outerList) {
      List<String> stringValues = innerList.replaceAll("[", "").replaceAll("]", "").split(",");
      List<double> sublist = stringValues.map((value) => double.parse(value)).toList();
      data.add(sublist);
    }
    return data;
  }

  //SharedPreferences this is key
  setSharedPrefString(SharedPreferences prefs, String value) {
    "${this.replaceAll("Key","")}: $value".debugPrint();
    prefs.setString(this, value);
  }
  setSharedPrefDouble(SharedPreferences prefs, double value) {
    "${this.replaceAll("Key","")}: $value".debugPrint();
    prefs.setDouble(this, value);
  }
  setSharedPrefInt(SharedPreferences prefs, int value) {
    "${this.replaceAll("Key","")}: $value".debugPrint();
    prefs.setInt(this, value);
  }
  setSharedPrefBool(SharedPreferences prefs, bool value) {
    "${this.replaceAll("Key","")}: $value".debugPrint();
    prefs.setBool(this, value);
  }
  getSharedPrefString(SharedPreferences prefs, String defaultString) {
    String data = prefs.getString(this) ?? defaultString;
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
  getSharedPrefDouble(SharedPreferences prefs, double defaultDouble) {
    double data = prefs.getDouble(this) ?? defaultDouble;
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
  getSharedPrefInt(SharedPreferences prefs, int defaultInt) {
    int data = prefs.getInt(this) ?? defaultInt;
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
  getSharedPrefBool(SharedPreferences prefs, bool defaultBool) {
    bool data = prefs.getBool(this) ?? defaultBool;
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
  getIntList(SharedPreferences prefs, int maxIndex) {
    List<int> data = List.generate(maxIndex + 1, (i) => prefs.getInt("$this$i") ?? 1);
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
  getDoubleList(SharedPreferences prefs, int maxIndex) {
    List<double> data = List.generate(maxIndex + 1, (i) => prefs.getDouble("$this$i") ?? 0.0);
    "${this.replaceAll("Key","")}: $data".debugPrint();
    return data;
  }
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
  //Input SpeedDial
  bool setIsInput(bool isDay) {
    final isInput = RegExp(isDay ? dayValidation: amountValidation).hasMatch(this);
    "inputFlag: $isInput".debugPrint();
    return isInput;
  }
  int setInputDay(bool isInput) {
    final inputDay = isInput ? this.toInt(0): 0;
    "inputDay: $inputDay".debugPrint();
    return inputDay;
  }
  bool setIsDayInput(bool isInput) {
    final isDayInput = (isInput && this.toInt(0).correctDay() > 0);
    "isDayInput: $isDayInput".debugPrint();
    return isDayInput;
  }
  String setInputItem(BuildContext context, bool isInput, bool isSpend) {
    final inputItem = (isInput) ? this: "";
    "inputItem: $inputItem".debugPrint();
    return inputItem;
  }
  bool setIsItemInput(bool isInput, bool isSpend) {
    final isItemInput = isInput;
    "isItemInput: $isItemInput".debugPrint();
    return isItemInput;
  }
  double setInputAmount(bool isInput, bool isSpend, String unit) {
    this.debugPrint();
    final inputAmount = (isInput) ? isSpend.setPlusMinus() * this.toDouble(0.0): 0.0;
    "inputAmount: $inputAmount".debugPrint();
    return inputAmount;
  }
  bool setIsAmountInput(bool isInput) {
    final isAmountInput = (isInput && this.toDouble(0.0) != 0.0);
    "isAmountInput: $isAmountInput".debugPrint();
    return isAmountInput;
  }

  bool setIsInitialAssetsInput(bool isInput) {
    final isAssetsInput = isInput ? (this.toDouble(0.0) >= 0.0) : false;
    "isAmountInput: $isAssetsInput".debugPrint();
    return isAssetsInput;
  }

  //unit
  int numberDigit() => (this == '¥') ? 0: 2;

  //day
  String addZero() => (this.toInt(0) < 10) ? "0$this": "$this";
  int removeZero() => (this[0] == "0") ? this[1].toInt(1): this.toInt(1);

  //startDate
  int toDay() => this.split("/")[1].removeZero();
  int toMonth() => this.split("/")[0].removeZero();
  int toYear() => this.split("/")[2].toInt(2023);
  int toDateInt() => toYear() * 10000 + toMonth() * 100 + toDay();
  int toCurrentIndex() => 12 * (DateTime.now().year - toYear()) + DateTime.now().month - toMonth();

  DateTime toThisDate(int index) =>
      DateTime(toYear() + (index + toMonth()) ~/ 12, (toMonth() + index) % 12, toDay());
  DateTime toThisMonthFirstDay(int index) =>
      DateTime(toThisDate(index).year, toThisDate(index).month, 1);
  DateTime toThisMonthLastDay(int index) =>
      DateTime(toThisDate(index).year, toThisDate(index).month, toThisDate(index).month.lastDay());
  String stringThisMonthYear(int index) => ""
      "${toThisDate(index).month.toString().addZero()}/${toThisDate(index).year}";
  String stringThisYear(int index) =>
      "${toThisDate(index).year}";
  String stringThisMonthDay(int index, int day) =>
      (day > 0 && day < toThisDate(index).month.lastDay()) ? "${toThisDate(index).month}/${day.toString().addZero()}": "-";
  Color yearPlusMinusColor(bool isPlus, int index, int maxIndex) =>
      ((!isPlus && (toThisDate(index).year == toThisDate(0).year)) || (isPlus && (toThisDate(index).year >= toThisDate(maxIndex).year))).selectButtonColor();
  Color monthPlusMinusColor(bool isPlus, int index) =>
      (!isPlus && (index == 0)).selectButtonColor();
  int toTargetIndex(int index, int i) =>
      i - toMonth() + 1 + 12 * (toThisDate(index).year - toYear());
  bool isNotExistChartData(int index, int maxIndex, double spotX) =>
      (toTargetIndex(index, (spotX - 1).toInt()) < 0) || (toTargetIndex(index, (spotX - 1).toInt()) > maxIndex);

  ///input
  //drawer
  IconData drawerAlertIcon() => (this == "name") ? nameIcon: amntIcon;
  Color drawerAlertColor() => (this == "initialAssets") ? pinkColor: purpleColor;
  //spreadsheet
  IconData spreadSheetAlertIcon() => (this == "amnt") ? amntIcon: itemIcon;
  //login
  IconData loginPrefixIcon() =>
      (this == "email" || this == "reset") ? nameIcon: lockIcon;
  List<FilteringTextInputFormatter> loginInputFormat() =>
      (this == "email" || this == "reset") ? inputEmailFormat: inputPasswordFormat;
  bool isLoginObscureText(bool isVisible) =>
      ((this == "password" || this == "confirmPass") && !isVisible);
}

extension MapDynamicExt on Map<String, dynamic> {

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

extension DoubleExt on double {

  //amount
  double toAbs() =>
      (this < 0) ? this * (-1.0): this;
  String formatNumber(String unit) =>
      "${NumberFormat((unit == "¥") ? "#,###": "#,##0.00").format(this.toAbs())}";
  String stringBalance(String unit) =>
      "${(this <= 0.0) ? "0": formatNumber(unit)}";
  String stringAmount(String unit) =>
      "${(this == 0.0) ? "": formatNumber(unit)}";
  String stringAssets(BuildContext context, String unit) =>
      "${(this == 0.0) ? "0": (this > 0.0) ? formatNumber(unit): context.notSet()}";
  String stringItem(BuildContext context, String item) =>
      (this == 0.0 || item.isEmpty) ? "": item;
  Color amountColor() =>
      (this == 0.0) ? whiteColor: (this > 0.0) ? pinkColor: blueColor;
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

extension BoolExt on bool {

  Color speedDialColor() =>
      (this) ? blueColor: pinkColor;   //isSpend
  IconData speedDialIcon() =>
      (this) ? itemIcon: unitIcon;     //isSpend
  Color selectButtonColor() =>
      (this) ? grayColor: purpleColor; //isInput
  double setPlusMinus() =>
      (this) ? -1.0: 1.0;              //isSpend
  IconData visibleIcon() =>
      this ? eyeOnIcon: eyeOffIcon;
  Color visibleIconColor() =>
      this ? purpleColor: transpLightBlackColor;
}

extension IntExt on int {

  int lastDay() =>
      (this == 2 || this == 4 || this == 6 || this == 9 || this == 12) ? 30: 31; //month
  int correctDay() =>
      (this > 0 && this < lastDay()) ? this: 0; //day
}

extension DateExt on DateTime? {

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

extension ListMapExt on List<Map> {

  Future<void> allowanceListSort() async{
    this.sort((a, b) => a["date"].compareTo(b["date"]));
  }
}

extension ListDoubleExt on List<double> {

  double toAllowance() =>
      List.generate(this.length, (i) => (this[i] > 0.0) ? this[i]: 0.0).reduce((a, b) => a + b);
  double toBalance() =>
      List.generate(this.length, (i) => this[i]).reduce((a, b) => a + b);
  double toSpends() =>
    List.generate(this.length, (i) => (this[i] < 0.0) ? (-1.0) * this[i]: 0.0).reduce((a, b) => a + b);
  double toPercent() =>
      (toBalance() < 0 || toAllowance() == 0) ? 0.0: toBalance() / toAllowance();

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
    for (var i = 0; i < this.length; i++) {
      prefs.setDouble("$key$i", this[i]);
    }
    "${key.replaceAll("Key", "")}: $this".debugPrint();
  }

  List<AllowanceList> getAllowanceList(List<int> date, List<String> item) =>
      List.generate(this.length, (i) => AllowanceList(date[i], item[i], this[i]));

  List<FlSpot> chartData(int index, int maxIndex, String startDate) =>
      List.generate(12, (int i) {
        int targetIndex = startDate.toTargetIndex(index, i);
        // "i: $i, targetIndex: $targetIndex".debugPrint();
        return FlSpot((i + 1).toDouble(), (targetIndex < 0 || maxIndex < targetIndex || this[targetIndex] < 0) ? 0.0: this[targetIndex]);
      }).where((spot) =>
        !startDate.isNotExistChartData(index, maxIndex, spot.x)
      ).toList();

  List<FlSpot> targetChartData(double targetAssets) =>
      List.generate(12, (int i) => FlSpot((i + 1).toDouble(), targetAssets));
}

extension ListAllowanceListExt on List<AllowanceList> {

  List<int> getDateFromAllowanceList() =>
      List.generate(this.length, (i) => this[i].date);
  List<String> getItemFromAllowanceList() =>
      List.generate(this.length, (i) => this[i].item);
  List<double> getAmntFromAllowanceList() =>
      List.generate(this.length, (i) => this[i].amnt);
}

extension ListIntExt on List<int> {

  setIntList(SharedPreferences prefs, String key) {
    for (var i = 0; i < this.length; i++) {
      prefs.setInt("$key$i", this[i]);
    }
    "${key.replaceAll("Key", "")}: $this".debugPrint();
  }
}

extension ListListDoubleExt on List<List<double>> {

  int calcMaxIndex() {
    "maxIndex: ${this.length - 1}".debugPrint();
    return this.length - 1;
  }
  List<int> calcListNumber() {
    "listNumber: ${List.generate(this.length, (i) => this[i].length)}".debugPrint();
    return List.generate(this.length, (i) => this[i].length);
  }
  List<double> calcPercent(int maxIndex) {
    "percent: ${List.generate(maxIndex + 1, (i) => this[i].toPercent())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toPercent());
  }
  List<double> calcBalance(int maxIndex) {
    "balance: ${List.generate(maxIndex + 1, (i) => this[i].toBalance())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toBalance());
  }
  List<double> calcSpends(int maxIndex) {
    "spends: ${List.generate(maxIndex + 1, (i) => this[i].toSpends())}".debugPrint();
    return List.generate(maxIndex + 1, (i) => this[i].toSpends());
  }
}


