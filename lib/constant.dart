import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Input validation and formatting constants
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

/// AlertDialog styling constants
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
const double drawerUnitFontSize = 40;
const double drawerUnitItemHeight = 50;

/// Main body layout constants
const double percentBarLineHeight = 10.0;
const double percentBarLineRadius = 5.0;

/// SpreadSheet styling constants
const double spreadSheetDividerWidth = 1.0;

/// Chart styling constants
const List<int> chartBorderDashArray = [2, 5];

/// FloatingActionButton positioning constants
const double floatingActionButtonLeftMargin = 32;

/// Icon definitions for various UI elements
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
const IconData menuIcon = Icons.menu;
const IconData backIcon = CupertinoIcons.back;
const IconData openIcon = CupertinoIcons.plus;
const IconData closeIcon = Icons.close;
const IconData summaryIcon = Icons.ssid_chart;
const IconData lockIcon = CupertinoIcons.lock_circle;
const IconData thumbsUpIcon = CupertinoIcons.hand_thumbsup;
const IconData infoIcon = CupertinoIcons.info;

/// Color definitions for app theme
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
const List<Color> chartColorList = [pinkColor, purpleColor, blueColor];

