import 'package:flutter/material.dart';
import 'constant.dart';
import 'extension.dart';

/// Reusable UI components and styling utilities shared across the app:
/// backgrounds, text styles, buttons, and alert parts.
class CommonWidget {

  final BuildContext context;
  const CommonWidget(this.context);

  /// Background Decoration - Creates gradient background for app screens
  /// Uses light blue to light pink gradient with custom stops
  BoxDecoration backgroundDecoration() => BoxDecoration(
    gradient: LinearGradient(
      colors: [lightBlueColor, lightPinkColor],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
      stops: [0.1, 0.75],
    )
  );

  /// Circular Progress Indicator - Creates a centered loading indicator
  /// Overlays a semi-transparent background with centered progress indicator
  Widget myCircularProgressIndicator() => Stack(
    children: [
      Container(
        width: context.width(),
        height: context.height(),
        color: transpLightBlackColor,
      ),
      Center(child: CircularProgressIndicator())
    ]
  );

  /// Accent text style with the custom font and a light or dark shadow.
  TextStyle customAccentTextStyle(double fontSize, bool isDark) => TextStyle(
    color: whiteColor,
    fontSize: fontSize,
    fontFamily: context.customAccentFont(),
    fontWeight: FontWeight.bold,
    shadows: [customShadow(context, isDark)],
  );

  /// English Accent Text Style - Creates styled text for English content
  /// Uses "enAccent" font family with normal weight and light shadow
  TextStyle enAccentTextStyle(double fontSize) => TextStyle(
    color: whiteColor,
    fontSize: fontSize,
    fontFamily: "enAccent",
    fontWeight: FontWeight.normal,
    shadows: [customShadow(context, false)],
  );

  /// App Bar Bottom Line - Creates a white line at the bottom of app bars
  /// Uses responsive height based on context
  PreferredSize appBarBottomLine() => PreferredSize(
    preferredSize: Size.fromHeight(context.appBarBottomLineWidth()),
    child: Container(
      color: whiteColor,
      height: context.appBarBottomLineWidth()
    ),
  );

  /// Underline border for text fields in the given color.
  UnderlineInputBorder textFieldUnderLineBorder(Color color) => UnderlineInputBorder(
    borderSide: BorderSide(
      color: color,
      width: textFieldUnderLineWidth,
    ),
  );

  /// Text Field Text Style - Creates consistent text styling for input fields
  /// Uses bold weight with semi-transparent black color
  TextStyle textFieldTextStyle() => TextStyle(
    color: transpBlackColor,
    fontSize: context.alertFontSize(),
    fontFamily: "defaultFont",
    fontWeight: FontWeight.bold,
  );

  /// Hint text style for input fields.
  TextStyle textFieldHintStyle(double fontSize) => TextStyle(
    color: transpLightBlackColor,
    fontSize: fontSize,
    fontFamily: "defaultFont",
    fontWeight: FontWeight.bold,
  );

  /// Shadow for text and UI elements: transparent black when dark, purple otherwise.
  Shadow customShadow(BuildContext context, bool isDark) => Shadow(
    color: isDark ? transpBlackColor: purpleColor,
    blurRadius: context.shadowBlur(),
    offset: Offset(context.shadowOffset(), context.shadowOffset())
  );

  /// Circular action button decoration with a shadow.
  BoxDecoration actionButtonBoxDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(
      color: transpBlackColor,
      blurRadius: context.shadowBlur(),
      offset: Offset(context.shadowOffset(), context.shadowOffset()),
    )],
  );

  /// Tappable text button used inside alert dialogs.
  Widget alertJudgeButton(String text, {
    required Color color,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Text(text,
      style: TextStyle(
        color: color,
        fontSize: context.alertFontSize(),
        fontFamily: "defaultFont",
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  /// Alert Cancel Button - Creates a cancel button that closes the current page
  /// Uses semi-transparent black color and calls context.popPage()
  Widget alertCancelButton() => alertJudgeButton(
    context.cancel(),
    color: transpBlackColor,
    onTap: () => context.popPage(),
  );

  /// Circular plus/minus button for year and month navigation.
  Widget plusMinusButton({
    required bool isPlus,
    required Color color,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.plusMinusSize(),
      height: context.plusMinusSize(),
      decoration: actionButtonBoxDecoration(color),
      child: Icon(isPlus ? forwardIcon : backIcon,
        size: context.plusMinusIconSize(),
        color: whiteColor,
        shadows: [customShadow(context, true)],
      ),
    ),
  );

  /// Shows a success snack bar with a thumbs up icon.
  void showSuccessSnackBar(String title) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: whiteColor,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(thumbsUpIcon, color: purpleColor),
          Text(" $title",
            style: TextStyle(
              color: purpleColor,
              fontSize: context.loginFontSize(),
              fontFamily: "defaultFont",
              fontWeight: FontWeight.bold,
            )
          ),
        ],
      ),
    ),
  );

  /// Shows an error snack bar with an info icon; [message] may span multiple lines.
  void showFailedSnackBar(String title, String? message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: whiteColor,
      content: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(infoIcon, color: purpleColor),
            Text(" $title",
              style: TextStyle(
                color: purpleColor,
                fontSize: context.loginFontSize(),
                fontFamily: "defaultFont",
                fontWeight: FontWeight.bold,
              )
            ),
          ],
        ),
        if (message != null) SizedBox(height: context.snackBarMargin()),
        if (message != null) Text(message,
          style: TextStyle(
            color: purpleColor,
            fontSize: context.loginMessageSize(),
            fontFamily: "defaultFont",
            fontWeight: FontWeight.bold,
          )
        ),
      ]),
    ),
  );

  /// Bold title text for alert dialogs.
  Widget alertTitleText(String title) => Container(
    margin: EdgeInsets.only(bottom: alertTitleBottomMargin),
    child: Text(title,
      style: TextStyle(
        color: transpBlackColor,
        fontSize: context.alertTitleFontSize(),
        fontFamily: "defaultFont",
        fontWeight: FontWeight.bold,
      ),
    ),
  );


}

