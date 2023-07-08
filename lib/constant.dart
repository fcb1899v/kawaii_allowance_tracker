import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

//Input
const int inputMoneyMaxLength = 8;
const int inputEnItemMaxLength = 18;
const int inputJaItemMaxLength = 12;
const int inputEnNameMaxLength = 12;
const int inputJaNameMaxLength = 12;
const List<String> jaUnitList = ["¥", "\$", "€", "£"];
const List<String> enUnitList = ["\$", "€", "£", "¥"];
const dayValidation = r"^[0-9]{1,}$";
const amountValidation = r"^[0-9.]{1,}$";
const emailValidation = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const passwordValidation = r'^[a-zA-Z0-9.a-zA-Z0-9!@#\$&*~]{7,19}$';
const emailInputChar = r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~@]{1,}";
const passwordInputChar = r'^[a-zA-Z0-9.a-zA-Z0-9!@#\$&*~]{1,}';
List<FilteringTextInputFormatter> inputMoneyFormat = [
  FilteringTextInputFormatter.allow(RegExp(amountValidation)),
];
List<FilteringTextInputFormatter> inputEmailFormat = [
  FilteringTextInputFormatter.allow(RegExp(emailInputChar))
];
List<FilteringTextInputFormatter> inputPasswordFormat = [
  FilteringTextInputFormatter.allow(RegExp(passwordInputChar))
];
//
const shadowBlur = 1.5;
const shadowOffset = 2.5;
// AlertDialog
const alertCursorWidth = 3.0;
const alertCursorHeight = 20.0;
const alertDateFontSize = 18.0;
const alertTitleEnSize = 20.0;
const alertTitleJaSize = 18.0;
const alertFontEnSize = 18.0;
const alertFontJaSize = 18.0;
const alertIconSize = 24.0;
const alertIconMargin = 8.0;
const alertTitleBottomMargin = 10.0;
const textFieldUnderLineWidth = 2.0;
const counterCharSize = 14.0;
// AppBar
const double appBarHeight = 60.0;
const double appBarTitleIconSpace = 16.0;
const double appBarEnFontSize = 32.0;
const double appBarJaFontSize = 28.0;
const double appBarIconSize = 28.0;
const double appBarPopupFontSize = 24.0;
const double appBarBottomLineWidth = 1.0;
const double popupMenuIconSize = 28.0;
// Drawer
const double drawerWidthRate = 0.9;
const double drawerTitleBorderRadiusRate = 0.1;
const double drawerTitleNoNameHeightRate = 0.22;
const double drawerTitleExistNameHeightRate = 0.33;
const double drawerTitleFontSizeRate = 0.07;
const double drawerMenuListIconSizeRate = 0.08;
const double drawerMenuListFontSizeRate = 0.04;
const double drawerMenuListMarginTopRate = 0.03;
const double drawerMenuListMarginRate = 0.01;
const double drawerMenuListSubTitleMarginTopRate = 0.02;
const double drawerUnitFontSize = 40;
const double drawerUnitItemHeight = 50;
// MainBody
const double mainBodyMarginTopRate = 0.03;
const double balanceJaFontSizeRate = 0.07;
const double balanceEnFontSizeRate = 0.09;
const double balanceUnitSizeRate = 0.10;
const double balanceMoneySizeRate = 0.12;
const double balanceMoneyShiftSizeRate = 0.025;
const double balanceMarginHorizontalRate = 0.05;
const double percentMarginBottomRate = 0.03;
const double percentBarMaxWidth = 600.0;
const double percentBarWidthRate = 0.8;
const double percentBarLineHeight = 10.0;
const double percentBarLineRadius = percentBarLineHeight / 2;
const double plusMinusSizeRate = 0.04;
const double plusMinusMarginTopRate = 0.03;
const double plusMinusIconSizeRate = 0.032;
const double plusMinusSpaceRate = 0.2;
const double monthYearFontSizeRate = 0.07;
const double admobMinimumHeight = 50;
// SpreadSheet
const double scrollViewMarginHorizontalRate = 0.05;
const double scrollViewMarginVerticalRate = 0.015;
const double spreadSheetCornerRadiusRate = 0.018;
const double spreadSheetFontSizeRate = 0.02;
const double spreadSheetIconSizeRate = 0.025;
const double spreadSheetDividerWidth = 1.0;
const double spreadSheetRowHeightRate = 0.05;
const double spreadSheetColumnSpacingRate = 0.015;
const double spreadSheetShadowOffset = 0.5;
const double deleteButtonWidthRate = 0.03;
const double deleteButtonWidth = 20;
const double deleteButtonIconSize = 16;
const double deleteButtonFontSize = 16;
// Chart
const double chartHeightRate = 0.40;
const double chartBarWidthRate = 0.005;
const double chartDotWidthRate = 0.006;
const double chartBorderWidthRate = 0.002;
const double chartVerticalBorderWidthRate = 0.0005;
const double chartHorizontalBorderWidthRate = 0.002;
const double chartTitleFontSizeRate = 0.03;
const double chartTopAxisNameSizeRate = 0.07;
const double chartTopMarginLeftRate = 0.04;
const double chartBottomMarginRate = 0.01;
const double chartBottomAxisNameSizeRate = 0.05;
const double chartBottomMarginLeftRate = 0.03;
const double chartBottomFontSizeRate = 0.025;
const double chartLeftReservedSizeRate = 0.12;
const double chartBottomReservedSizeRate = 0.06;
const double chartAxisFontSizeRate = 0.03;
const List<int> chartBorderDashArray = [2, 5];
// FloatingActionButton
const double floatingActionBottomMarginRate = 0.02;
const double floatingActionButtonSizeRate = 0.12;
const double floatingActionIconSizeRate = 0.08;
const double floatingActionButtonLeftMargin = 32;
const double speedDialIconSizeRate = 0.07;
const double speedDialChildButtonSizeRate = 0.14;
const double speedDialChildFontSize = 20;
const double speedDialChildIconSizeRate = 0.08;
const double speedDialSpaceFontSizeRate = 0.04;
const double speedDialSpacingRate = 0.01;
const double speedDialSpaceHeightRate = 0.04;
// Login
const loginEnTitleSizeRate = 0.10;
const loginJaTitleSizeRate = 0.075;
const loginFontSizeRate = 0.045;
const loginMessageSizeRate = 0.04;
const loginHintSizeRate = 0.04;
const loginPassHintSizeRate = 0.04;
const loginIconSizeRate = 0.07;
const loginCounterCharSizeRate = 0.02;
const loginTitleMarginTopRate = 0.15;
const loginTitleMarginBottomRate = 0.08;
const loginInputAreaRadiusRate = 0.08;
const loginInputAreaWidthRate = 0.92;
const loginInputAreaPaddingRate = 0.06;
const loginInputIconSpaceRate = 0.1;
const loginTextFieldWidthRate = 0.3;
const loginTextFieldMarginBottomRate = 0.05;
const loginButtonWidthRate = 0.70;
const loginButtonHeightRate = 0.14;
const loginButtonMarginTopRate = 0.04;
const loginButtonMarginBottomRate = 0.04;
const loginVisibleMarginTopRate = 0.04;
const loginVisibleMarginRightRate = 0.02;
const moveSignupMarginTopRate = 0.02;
const moveSignupMarginBottomRate = 0.04;
const forgetPassMarginTopRate = 0.08;
const snackBarMarginRate = 0.03;
// IconData
const IconData nameIcon = CupertinoIcons.profile_circled;
const IconData unitIcon = CupertinoIcons.money_dollar;
const IconData eyeOnIcon = Icons.visibility;
const IconData eyeOffIcon = Icons.visibility_off;
const IconData listIcon = CupertinoIcons.table;
const IconData dateIcon = Icons.calendar_month;
const IconData itemIcon = Icons.shopping_basket_outlined;
const IconData amntIcon = CupertinoIcons.money_dollar_circle;
const IconData deleteIcon = CupertinoIcons.delete;
const IconData moreIcon = Icons.more_vert;
const IconData forwardIcon = CupertinoIcons.forward;
const IconData backIcon = CupertinoIcons.back;
const IconData openIcon = CupertinoIcons.plus;
const IconData closeIcon = Icons.close;
const IconData summaryIcon = Icons.ssid_chart;
const IconData lockIcon = CupertinoIcons.lock_circle;
const IconData thumbsUpIcon = CupertinoIcons.hand_thumbsup;
const IconData infoIcon = CupertinoIcons.info;
// Color
const Color transpColor = Colors.transparent;
const Color blackColor = Colors.black;
const Color whiteColor = Colors.white;
const Color grayColor = Color.fromRGBO(128, 128, 128, 1);
const Color transpWhiteColor = Color.fromRGBO(255, 255, 255, 0.3);
const Color transpBlackColor = Color.fromRGBO(0, 0, 0, 0.6);
const Color transpLightBlackColor = Color.fromRGBO(0, 0, 0, 0.3);
const Color purpleColor = Color.fromRGBO(128, 64, 255, 1);       //#8040ff
const Color lightPurpleColor = Color.fromRGBO(192, 128, 255, 1); //#c080ff
const Color pinkColor = Color.fromRGBO(255, 0, 255, 1);          //#ff00ff
const Color lightPinkColor = Color.fromRGBO(255, 64, 255, 1);    //#ff40ff
const Color blueColor = Color.fromRGBO(0, 192, 255, 1);          //#00c0ff
const Color lightBlueColor = Color.fromRGBO(0, 255, 255, 1);     //#00ffff

