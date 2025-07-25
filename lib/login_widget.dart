import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constant.dart';
import 'extension.dart';
import 'home_widget.dart';
import 'widget.dart';

void showSuccessSnackBar(BuildContext context, String title) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: whiteColor,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(thumbsUpIcon, color: purpleColor),
            Text(" $title",
              style: loginTextStyle(context, purpleColor)
            ),
          ],
        ),
      ),
    );

void showFailedSnackBar(BuildContext context, String title, String? message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: whiteColor,
        content: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(infoIcon, color: purpleColor),
              Text(" $title",
                style: loginTextStyle(context, purpleColor)
              ),
            ],
          ),
          if (message != null) SizedBox(height: context.snackBarMargin()),
          if (message != null) Text(message,
            style: loginMessageTextStyle(context, purpleColor)
          ),
        ]),
      ),
    );


loginTitleText(BuildContext context) =>
    Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: context.loginTitleMarginBottom()),
      child: Text(context.appTitle(),
        style: TextStyle(
          color: whiteColor,
          fontSize: context.loginTitleSize(),
          fontFamily: context.customAccentFont(),
          fontWeight: FontWeight.bold,
          shadows: [customShadow(false, shadowOffset)],
        )
      )
    );

loginButtonImage(BuildContext context, bool isSignUp, isEmailInput, isPasswordInput, isConfirmPassInput) =>
    Container(
      margin: EdgeInsets.only(
        top: context.loginButtonMarginTop(),
        bottom: context.loginButtonMarginBottom()
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.loginButtonRadius()),
        child: Container(
          alignment: Alignment.center,
          width: context.loginButtonWidth(),
          height: context.loginButtonHeight(),
          color: (!(isEmailInput && isPasswordInput && isConfirmPassInput)).selectButtonColor(),
          child: loginText(context, isSignUp ? context.trySignup(): context.tryLogin(), whiteColor),
        ),
      ),
    );

moveSignupText(BuildContext context) =>
    Container(
      margin: EdgeInsets.only(
        top: context.moveSignupMarginTop(),
        bottom: context.moveSignupMarginBottom()
      ),
      child: loginUnderLineText(context, context.trySignup(), purpleColor),
    );

forgetPassText(BuildContext context) =>
    Container(
      margin: EdgeInsets.only(top: context.forgetPassMarginTop()),
      child: loginUnderLineText(context, context.forgotPass(), whiteColor)
    );

InputDecoration loginInputDecoration(BuildContext context, String input) =>
    InputDecoration(
      prefixIcon: loginPrefixIcon(context, input),
      prefixIconConstraints: BoxConstraints(
        minWidth: context.loginInputIconSpace(),
        minHeight: context.loginInputIconSpace(),
      ),
      focusedBorder: textFieldUnderLineBorder(purpleColor),
      counterStyle: TextStyle(fontSize: context.loginCounterCharSize()),
      hintText: context.loginFormHint(input),
      hintStyle: textFieldHintStyle(context.loginHintSize()),
      labelText: context.loginFormLabel(input),
      labelStyle: loginTextStyle(context, purpleColor),
    );

Icon loginPrefixIcon(BuildContext context, String input) =>
    Icon(input.loginPrefixIcon(),
      color: transpLightBlackColor,
      size: context.loginIconSize(),
    );

loginSuffixIcon(BuildContext context, bool isVisible) =>
    Container(
      margin: EdgeInsets.only(
        top: context.loginVisibleMarginTop(),
        right: context.loginVisibleMarginRight(),
      ),
      alignment: Alignment.bottomRight,
      child: Icon(isVisible.visibleIcon(),
        color: isVisible.visibleIconColor(),
        size: context.loginIconSize(),
      )
    );

Text loginText(BuildContext context, String title, Color color) =>
    Text(title,
      style: loginTextStyle(context, color),
    );

TextStyle loginTextStyle(BuildContext context, Color color) =>
    TextStyle(
      color: color,
      fontSize: context.loginFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );

Text loginUnderLineText(BuildContext context, String title, Color color) =>
    Text(title,
      style: TextStyle(
        color: color,
        fontSize: context.loginFontSize(),
        fontFamily: "defaultFont",
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    );

alertAllowTitleText(BuildContext context) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.info, size: alertIconSize),
        SizedBox(width: alertIconMargin),
        alertTitleText(context, context.confirmation()),
      ]
    );

TextStyle loginMessageTextStyle(BuildContext context, Color color) =>
    TextStyle(
      color: color,
      fontSize: context.loginMessageSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );
