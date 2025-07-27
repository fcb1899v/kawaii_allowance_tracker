import 'package:flutter/material.dart';
import 'constant.dart';
import 'extension.dart';

/// CommonWidget class - Provides reusable UI components and styling utilities
/// Contains methods for creating consistent UI elements across the application
/// Handles background decorations, text styles, buttons, and alert components
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

  /// Custom Accent Text Style - Creates styled text with custom font and shadow
  /// Parameters:
  /// - fontSize: Size of the text
  /// - isDark: Whether to use dark shadow effect
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

  /// Text Field Underline Border - Creates custom underline border for text fields
  /// Parameters:
  /// - color: Color of the underline border
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

  /// Text Field Hint Style - Creates styling for placeholder text in input fields
  /// Parameters:
  /// - fontSize: Size of the hint text
  TextStyle textFieldHintStyle(double fontSize) => TextStyle(
    color: transpLightBlackColor,
    fontSize: fontSize,
    fontFamily: "defaultFont",
    fontWeight: FontWeight.bold,
  );

  /// Custom Shadow - Creates shadow effect for text and UI elements
  /// Parameters:
  /// - isDark: Whether to use dark shadow (transparent black) or light shadow (purple)
  Shadow customShadow(BuildContext context, bool isDark) => Shadow(
    color: isDark ? transpBlackColor: purpleColor,
    blurRadius: context.shadowBlur(),
    offset: Offset(context.shadowOffset(), context.shadowOffset())
  );

  /// Action Button Box Decoration - Creates circular button with shadow effect
  /// Parameters:
  /// - color: Background color of the button
  BoxDecoration actionButtonBoxDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(
      color: transpBlackColor,
      blurRadius: context.shadowBlur(),
      offset: Offset(context.shadowOffset(), context.shadowOffset()),
    )],
  );

  /// Alert Judge Button - Creates a clickable text button for alerts
  /// Parameters:
  /// - text: Button text to display
  /// - color: Text color
  /// - onTap: Function to execute when button is tapped
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

  /// Plus Minus Button - Creates circular navigation buttons for year/month navigation
  /// Parameters:
  /// - isPlus: Whether this is a forward (+) or backward (-) button
  /// - color: Button background color
  /// - onTap: Function to execute when button is tapped
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

  /// Show Success Snack Bar - Displays a success message with thumbs up icon
  /// Parameters:
  /// - title: Success message to display
  /// Uses white background with purple text and icon
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

  /// Show Failed Snack Bar - Displays an error message with info icon
  /// Parameters:
  /// - title: Error title to display
  /// - message: Optional detailed error message
  /// Uses white background with purple text and icon, supports multi-line messages
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

  /// Alert Title Text - Creates styled title text for alert dialogs
  /// Parameters:
  /// - title: Title text to display
  /// Uses semi-transparent black color with bold weight and bottom margin
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

