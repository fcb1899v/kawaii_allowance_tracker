import 'package:flutter/material.dart';
import 'extension.dart';
import 'constant.dart';

BoxDecoration backgroundDecoration() =>
    BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBlueColor, lightPinkColor],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          stops: [0.1, 0.75],
        )
    );

myCircularProgressIndicator(BuildContext context) =>
    Stack(children: [
      Container(
        width: context.width(),
        height: context.height(),
        color: transpLightBlackColor,
      ),
      Center(child: CircularProgressIndicator())
    ]);

Size circleSize(double size) =>
    Size(size, size);

TextStyle customAccentTextStyle(BuildContext context, double fontSize, bool isDark) =>
    TextStyle(
      color: whiteColor,
      fontSize: fontSize,
      fontFamily: context.customAccentFont(),
      fontWeight: FontWeight.bold,
      shadows: [customShadow(isDark, shadowOffset)],
    );

TextStyle unitAccentTextStyle(BuildContext context, double fontSize) =>
    TextStyle(
      color: whiteColor,
      fontSize: fontSize,
      fontFamily: "Roboto",
      fontWeight: FontWeight.bold,
      shadows: [customShadow(false, shadowOffset)],
    );

TextStyle enAccentTextStyle(BuildContext context, double fontSize) =>
    TextStyle(
      color: whiteColor,
      fontSize: fontSize,
      fontFamily: "enAccent",
      fontWeight: FontWeight.normal,
      shadows: [customShadow(false, shadowOffset)],
    );

TextStyle defaultAccentTextStyle(BuildContext context, double fontSize) =>
    TextStyle(
      color: whiteColor,
      fontSize: fontSize,
      fontFamily: "default",
      fontWeight: FontWeight.bold,
      shadows: [customShadow(false, shadowOffset)],
    );

Text appBarTitleText(BuildContext context, String title) =>
    Text(title, style: customAccentTextStyle(context, context.appBarFontSize(), true));

PreferredSize appBarBottomLine() =>
    PreferredSize(
      child: Container(color: whiteColor, height: appBarBottomLineWidth),
      preferredSize: Size.fromHeight(appBarBottomLineWidth),
    );

Icon textFieldPrefixIcon(IconData icon) =>
    Icon(icon,
      color: transpLightBlackColor,
      size: alertIconSize,
    );

UnderlineInputBorder textFieldUnderLineBorder(Color color) =>
    UnderlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: textFieldUnderLineWidth,
      ),
    );

TextStyle textFieldTextStyle(BuildContext context) =>
    TextStyle(
      color: transpBlackColor,
      fontSize: context.alertFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );

TextStyle textFieldHintStyle(double fontSize) =>
    TextStyle(
      color: transpLightBlackColor,
      fontSize: fontSize,
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );

Shadow customShadow(bool isDark, double shadowOffset) =>
    Shadow(
      color: isDark ? transpBlackColor: purpleColor,
      blurRadius: shadowBlur,
      offset: Offset(shadowOffset, shadowOffset)
    );

BoxDecoration actionButtonBoxDecoration(Color color) =>
    BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: transpBlackColor,
          blurRadius: shadowBlur,
          offset: Offset(shadowOffset, shadowOffset),
        ),
      ],
    );

Text alertJudgeButtonText(BuildContext context, String judge, Color? color) =>
    Text(context.judgeText(judge),
      style: alertJudgeButtonTextStyle(context, color),
    );

TextStyle alertJudgeButtonTextStyle(BuildContext context, Color? color) =>
    TextStyle(
      color: color,
      fontSize: context.alertFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );