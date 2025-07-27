import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'extension.dart';
import 'constant.dart';
import 'common_widget.dart';

/// Home widget class that provides UI components for the allowance tracker
/// Contains all the widget methods for the main homepage including AppBar, Drawer,
/// data table, and floating action buttons
class HomeWidget {

  final BuildContext context;
  final bool isLogin;
  const HomeWidget(this.context,{
    required this.isLogin,
  });

  /// Get common widget instance for shared UI components
  /// Provides access to common styling and widget methods
  CommonWidget commonWidget() => CommonWidget(context);

  /// AppBar widget for the main homepage
  /// Displays title, navigation controls, and user action menu
  PreferredSize homeAppBar({
    required bool isLogin,
    required bool isSummary,
    required Function() onTapBack,
    required Function() onTapLogout,
  }) => PreferredSize(
    preferredSize: Size.fromHeight(context.appBarHeight()),
    child: AppBar(
      automaticallyImplyLeading: !isSummary,
      leading: (isSummary) ? IconButton(
        icon: Icon(backIcon),
        onPressed: onTapBack,
      ): null,
      iconTheme: IconThemeData(color: whiteColor),
      title: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSummary ? summaryIcon : listIcon,
            size: context.appBarIconSize(),
            color: whiteColor,
          ),
          SizedBox(width: context.appBarTitleIconSpace()),
          Text(context.appBarTitleText(!isSummary),
            style: commonWidget().customAccentTextStyle(context.appBarFontSize(), true)
          )
        ]
      ),
      centerTitle: true,
      backgroundColor: purpleColor,
      bottom: commonWidget().appBarBottomLine(),
      actions: [
        (!isSummary) ? PopupMenuButton(
          onSelected: (_) => (isLogin) ? SharedPreferences.getInstance().then((prefs) => onTapLogout()) : context.pushPage("/l"),
          icon: Icon(moreIcon, color: whiteColor),
          initialValue: context.popupMenuText(isLogin),
          itemBuilder: (context) => [appBarPopupMenu(context.popupMenuText(isLogin))]
        ) : SizedBox(width:kToolbarHeight),

      ],
    ),
  );

  /// Popup menu item for AppBar actions
  /// Displays login/logout option with appropriate styling
  PopupMenuItem appBarPopupMenu(String value) => PopupMenuItem(
    padding: EdgeInsets.all(0.0),
    value: 1,
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 10),
        Icon(nameIcon,
          color: purpleColor,
          size: alertIconSize,
        ),
        Text(" $value  ",
          style: TextStyle(
            color: purpleColor,
            fontSize: context.alertFontSize(),
            fontFamily: "defaultFont",
            fontWeight: FontWeight.bold,
          ),
        ),
      ]
    ),
  );

  /// Drawer header widget with user name display
  /// Shows personalized greeting with custom styling and shadow effects
  Widget drawerHeader(String name) => SizedBox(
    height: context.drawerTitleHeight(name),
    child: DrawerHeader(
      decoration: BoxDecoration(color: purpleColor),
      child: Container(
        alignment: Alignment.center,
        child: Text(context.drawerTitle(name),
          style: TextStyle(
            color: whiteColor,
            fontSize: context.drawerTitleFontSize(),
            fontFamily: context.customAccentFont(),
            fontWeight: FontWeight.bold,
            shadows: [commonWidget().customShadow(context, true)]
          ),
          textAlign: TextAlign.center,
        ),
      ),
    )
  );

  /// Menu list tile for user name editing
  /// Allows users to tap and edit their name through a dialog
  Widget menuNameListTile(String name, {
    required Function(String) onChanged,
    required Function() onConfirm,
  }) => GestureDetector(
    onTap: () => nameFieldDialog(
      onChanged:  onChanged,
      onConfirm: onConfirm
    ),
    child: Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(nameIcon,
          size: context.drawerMenuListIconSize()
        ),
        title: Text(context.name(),
          style: TextStyle(
            color: transpBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: context.drawerMenuListSubTitleMarginTop()),
          child:Text(context.orNotSet(name),
            style: TextStyle(
              color: transpLightBlackColor,
              fontSize: context.drawerMenuListFontSize(),
              fontFamily: context.customJaFont(),
              fontWeight: context.customWeight(),
            )
          ),
        ),
        trailing: Icon(forwardIcon),
      ),
    ),
  );

  /// Dialog for setting user name
  /// Provides text input field with validation and confirmation
  void nameFieldDialog({
    required Function(String) onChanged,
    required Function() onConfirm,
  }) => showDialog(context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.drawerAlertTitle("name")),
      content: TextField(
        controller: TextEditingController(),
        decoration: drawerAlertDecoration("name"),
        keyboardType: TextInputType.name,
        cursorWidth: alertCursorWidth,
        cursorHeight: alertCursorHeight,
        cursorColor: "name".drawerAlertColor(),
        maxLength: context.inputNameMaxLength(),
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        autofocus: true,
        onChanged: (value) => onChanged(value),
      ),
      actions: [
        commonWidget().alertCancelButton(),
        const Spacer(),
        commonWidget().alertJudgeButton(
          context.ok(),
          color: purpleColor,
          onTap: onConfirm,
        ),
      ],
    ),
  );

  /// Menu list tile for currency unit selection
  /// Allows users to select their preferred currency unit
  Widget menuUnitListTile(String unit, {
    required Function(String?) onChanged,
  }) => GestureDetector(
    onTap: () => unitDropDownListDialog(unit,
      onChanged: onChanged
    ),
    child: Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(unitIcon, size: context.drawerMenuListIconSize()),
        title: Text(context.unit(),
          style: TextStyle(
            color: transpBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: context.drawerMenuListSubTitleMarginTop()),
          child:Text(unit,
            style: TextStyle(
              color: transpLightBlackColor,
              fontSize: context.drawerMenuListFontSize(),
              fontFamily: "Roboto",
              fontWeight: context.customWeight(),
            )
          ),
        ),
        trailing: Icon(forwardIcon),
      ),
    ),
  );

  /// Dialog for selecting currency unit
  /// Provides dropdown selection for different currency units
  void unitDropDownListDialog(String unit, {
    required Function(String?) onChanged,
  }) => showDialog(context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.drawerAlertTitle("unit")),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [DropdownButton(
            style: TextStyle(
              color: transpBlackColor,
              fontSize: drawerUnitFontSize,
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
            ),
            value: unit,
            itemHeight: max(kMinInteractiveDimension, drawerUnitItemHeight),
            items: context.unitList().map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: onChanged,
          )],
        ),
      ),
    ),
  );

  /// Menu list tile for initial assets setting
  /// Displays current initial assets and allows editing
  Widget menuInitialAssetsTile(double initial, {
    required String unit,
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => GestureDetector(
    onTap: () => setInitialAssetsDialog(
      onChanged: onChanged,
      onConfirm: onConfirm
    ),
    child: Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(amntIcon, size: context.drawerMenuListIconSize()),
        title: Text(context.initialAssets(),
          style: TextStyle(
            color: transpBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: context.drawerMenuListSubTitleMarginTop()),
          child: Row(children: [
            Text(unit,
              style: TextStyle(
                color: transpLightBlackColor,
                fontSize: context.drawerMenuListFontSize(),
                fontFamily: "Roboto",
                fontWeight: context.customWeight(),
              )
            ),
            Text(initial.stringAssets(context, unit),
              style: TextStyle(
                color: transpLightBlackColor,
                fontSize: context.drawerMenuListFontSize(),
                fontFamily: context.customJaFont(),
                fontWeight: context.customWeight(),
              )
            ),
          ])
        ),
        trailing: Icon(forwardIcon),
      ),
    ),
  );

  /// Dialog for setting initial assets amount
  /// Provides numeric input with decimal support and validation
  void setInitialAssetsDialog({
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => showDialog(context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.drawerAlertTitle("initialAssets")),
      content: TextField(
        controller: TextEditingController(),
        style: commonWidget().textFieldTextStyle(),
        decoration: drawerAlertDecoration("initialAssets"),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: inputMoneyFormat,
        cursorWidth: alertCursorWidth,
        cursorHeight: alertCursorHeight,
        cursorColor: "initialAssets".drawerAlertColor(),
        maxLength: inputMoneyMaxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        autofocus: true,
        onChanged: onChanged,
      ),
      actions: [
        commonWidget().alertCancelButton(),
        commonWidget().alertJudgeButton(context.ok(),
          color: pinkColor,
          onTap: onConfirm,
        ),
      ],
    ),
  );

  /// Menu list tile for login/data synchronization
  /// Shows different options for saving or retrieving data from server
  Widget menuLoginTile({
    required bool isSaveData,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(isSaveData ? Icons.save: Icons.download,
          size: context.drawerMenuListIconSize()
        ),
        title: Text(context.login(),
          style: TextStyle(
            color: transpBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: context.drawerMenuListSubTitleMarginTop()),
          child: Text(context.drawerLoginTitle(isLogin, isSaveData),
            style: TextStyle(
              color: transpLightBlackColor,
              fontSize: context.drawerMenuListFontSize(),
              fontFamily: context.customJaFont(),
              fontWeight: context.customWeight(),
            ),
          ),
        ),
        trailing: Icon(forwardIcon),
      ),
    )
  );

  /// Menu list tile for displaying start date
  /// Shows the date when allowance tracking began (read-only)
  Widget menuStartDateListTile(String startDate) => Container(
    margin: EdgeInsets.all(context.drawerMenuListMargin()),
    child: ListTile(
      leading: Icon(dateIcon, size: context.drawerMenuListIconSize()),
      title: Text(context.startDate(),
        style: TextStyle(
          color: transpBlackColor,
          fontSize: context.drawerMenuListFontSize(),
          fontFamily: context.customJaFont(),
          fontWeight: context.customWeight(),
        )
      ),
      subtitle: Container(
        margin: EdgeInsets.only(top: context.drawerMenuListSubTitleMarginTop()),
        child:Text(context.orNotSet(startDate),
          style: TextStyle(
            color: transpLightBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
      ),
    ),
  );

  /// Menu list tile for account deletion
  /// Provides confirmation dialog before deleting user account
  Widget menuDeleteAccountTile(String name, {
    required void Function() onTap
  }) => GestureDetector(
    onTap: () => showDialog(context: context,
      builder: (context) => AlertDialog(
        title: commonWidget().alertTitleText(context.tryDeleteAccount()),
        content: Text(context.confirmDeleteAccount()),
        actions: [
          commonWidget().alertCancelButton(),
          const Spacer(),
          commonWidget().alertJudgeButton(context.ok(),
            color: pinkColor,
            onTap: onTap
          ),
        ],
      ),
    ),
    child: Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(nameIcon, size: context.drawerMenuListIconSize()),
        title: Text(context.deleteAccount(),
          style: TextStyle(
            color: transpBlackColor,
            fontSize: context.drawerMenuListFontSize(),
            fontFamily: context.customJaFont(),
            fontWeight: context.customWeight(),
          )
        ),
        trailing: Icon(forwardIcon),
      ),
    )
  );

  /// Input decoration for drawer alert dialogs
  /// Provides consistent styling for text input fields in dialogs
  InputDecoration drawerAlertDecoration(String input) => InputDecoration(
    prefixIcon: Icon(input.drawerAlertIcon(),
      color: transpLightBlackColor,
      size: alertIconSize,
    ),
    prefixIconConstraints: BoxConstraints(
      minWidth: context.loginInputIconSpace() * 0.5,
      minHeight: context.loginInputIconSpace() * 0.5,
    ),
    focusedBorder: commonWidget().textFieldUnderLineBorder(input.drawerAlertColor()),
    counterStyle: TextStyle(fontSize: counterCharSize),
    hintText: context.drawerAlertHint(input),
    hintStyle: commonWidget().textFieldHintStyle(context.alertFontSize()),
  );

  /// Main body content widgets
  /// Balance display widget showing current allowance balance
  Widget balanceView(double balance, String unit) => Container(
    margin: EdgeInsets.symmetric(horizontal: context.balanceMarginHorizontal()),
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.balance(), style: commonWidget().customAccentTextStyle(context.balanceFontSize(), false)),
        Text(unit,
          style: TextStyle(
            color: whiteColor,
            fontSize: context.balanceUnitSize(),
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
            shadows: [commonWidget().customShadow(context, false)],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: context.balanceMoneyShiftSize()),
          child: Text(balance.stringBalance(unit),
            style: TextStyle(
              color: whiteColor,
              fontSize: context.balanceMoneySize(),
              fontFamily: "enAccent",
              fontWeight: FontWeight.normal,
              shadows: [commonWidget().customShadow(context, false)],
            )
          ),
        ),
      ],
    ),
  );

  /// Percentage indicator widget showing allowance usage
  /// Displays linear progress bar with animation
  Widget percentView(double percent) => Container(
    margin: EdgeInsets.only(bottom: context.percentMarginBottom()),
    child: LinearPercentIndicator(
      width: context.percentBarWidth(),
      lineHeight: percentBarLineHeight,
      percent: percent,
      barRadius: Radius.circular(percentBarLineRadius),
      animation: true,
      animationDuration: 1000,
      backgroundColor: whiteColor,
      progressColor: purpleColor,
      alignment: MainAxisAlignment.center,
    ),
  );

  /// Spreadsheet data table column definitions
  /// Defines the structure and styling of the data table headers
  List<DataColumn> dataColumnTitles() => [
    dataColumnIcon(dateIcon),
    dataColumnDivider(),
    dataColumnIcon(itemIcon),
    dataColumnDivider(),
    dataColumnIcon(amntIcon),
    dataColumnDivider(),
    dataColumnIcon(deleteIcon),
  ];

  /// Data column with icon header
  /// Creates column header with icon and shadow effects
  DataColumn dataColumnIcon(IconData icon) => DataColumn(
    label: Expanded(
      child: Icon(icon,
        color: whiteColor,
        size: context.spreadSheetIconSize(),
        shadows: [commonWidget().customShadow(context, true)],
      )
    )
  );

  /// Data column divider for visual separation
  /// Creates vertical divider between columns
  DataColumn dataColumnDivider() => DataColumn(
    label: VerticalDivider(
      color: whiteColor,
      thickness: spreadSheetDividerWidth
    ),
  );

  /// Data cell divider for row separation
  /// Creates vertical divider within data cells
  DataCell dataCellDivider() => DataCell(
    VerticalDivider(
      color: grayColor,
      thickness: spreadSheetDividerWidth
    )
  );

  /// Date selection button for spreadsheet
  /// Allows users to select and modify dates for allowance entries
  DataCell spreadSheetDateButton(int date, {
    required double amount,
    required String startDate,
    required int index,
    required int id,
    required Function(DateTime?, int) onSelected,
  }) => DataCell(
    GestureDetector(
      onTap: () async {
        if (amount == 0.0) return;
        DateTime? picked = await showDatePicker(
          context: context,
          builder: (context, child) => Theme(
            data: selectDateTheme(amount < 0),
            child: child!
          ),
          initialDate: startDate.toThisDate(index),
          firstDate: startDate.toThisMonthFirstDay(index),
          lastDate: startDate.toThisMonthLastDay(index),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          locale: context.selectDayLocale(),
          helpText: context.modifyDateTitle(),
        );
        'Selected date: $picked'.debugPrint();
        onSelected(picked, id);
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(startDate.stringThisDay(index, date),
          style: TextStyle(
            color: amount.amountColor(),
            fontSize: context.spreadSheetFontSize(),
            fontFamily: "defaultFont",
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
        ),
      ),
    ),
  );

  /// Theme configuration for date picker
  /// Applies custom styling based on whether it's a spend or income entry
  ThemeData selectDateTheme(bool isSpend) => Theme.of(context).copyWith(
    colorScheme: ColorScheme.light(
      primary: isSpend.setPlusMinus().amountColor(),
      onPrimary: whiteColor,
    ),
    textTheme: TextTheme(
      titleSmall: TextStyle(fontSize: 0.0),
      labelSmall: TextStyle(fontSize: alertDateFontSize),
      bodySmall: TextStyle(fontSize: alertDateFontSize),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: transpBlackColor,
          textStyle: TextStyle(
            fontSize: context.alertFontSize(),
            fontFamily: "defaultFont",
            fontWeight: FontWeight.bold,
          )
      ),
    ),
  );

  /// Item input button for spreadsheet
  /// Allows editing of item descriptions through dialog
  DataCell spreadSheetItemButton(String item, {
    required double amount,
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => DataCell(
    GestureDetector(
      onTap: () {
        if (amount != 0.0) {
          inputItemDialog(
            amount: amount,
            onChanged: onChanged,
            onConfirm: onConfirm,
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(amount.stringItem(context, item),
          style: TextStyle(
            color: amount.amountColor(),
            fontSize: context.spreadSheetFontSize(),
            fontFamily: "defaultFont",
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
        ),
      ),
    ),
  );

  /// Dialog for editing item descriptions
  /// Provides text input for modifying allowance item names
  void inputItemDialog({
    required double amount,
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => showDialog(context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.spreadSheetAlertTitleText("item")),
      content: spreadSheetTextField(
        label: "item",
        amount: amount,
        onChanged: onChanged
      ),
      actions: [
        commonWidget().alertCancelButton(),
        const Spacer(),
        commonWidget().alertJudgeButton(context.ok(),
          color: (amount < 0).speedDialColor(),
          onTap: onConfirm,
        ),
      ],
    ),
  );

  /// Amount input button for spreadsheet
  /// Allows editing of allowance amounts through dialog
  DataCell spreadSheetAmountButton(double amount, {
    required String unit,
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => DataCell(
    GestureDetector(
      onTap: () {
        if (amount != 0.0) {
          amountInputDialog(amount,
            onChanged: onChanged,
            onConfirm: onConfirm,
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(unit,
              style:  TextStyle(
                color: amount.amountColor(),
                fontSize: context.spreadSheetFontSize(),
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1
            ),
            Text(amount.stringAmount(unit),
              style: TextStyle(
                color: amount.amountColor(),
                fontSize: context.spreadSheetFontSize(),
                fontFamily: "defaultFont",
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1
            ),
          ]
        ),
      ),
    ),
  );

  /// Dialog for editing allowance amounts
  /// Provides numeric input with decimal support for amount modification
  void amountInputDialog(double amount, {
    required Function(String) onChanged,
    required void Function() onConfirm,
  }) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.spreadSheetAlertTitleText("amnt")),
      content: spreadSheetTextField(
        label: "amnt",
        amount: amount,
        onChanged: onChanged,
      ),
      actions: [
        commonWidget().alertCancelButton(),
        const Spacer(),
        commonWidget().alertJudgeButton(
          context.ok(),
          color: (amount < 0).speedDialColor(),
          onTap: onConfirm,
        ),
      ],
    ),
  );

  /// Delete button for spreadsheet entries
  /// Provides popup menu for deleting allowance entries
  DataCell spreadSheetDeleteButton({
    required double amount,
    required int id,
    required int listNumber,
    required void Function(String) onSelected,
  }) => DataCell((amount == 0.0) ? Text(""): Container(
    width: context.deleteButtonWidth(),
    alignment: Alignment.centerLeft,
    child: PopupMenuButton(
      onSelected: onSelected,
      icon: Icon(moreIcon, color: amount.amountColor()),
      iconSize: context.spreadSheetFontSize(),
      initialValue: "",
      itemBuilder: (BuildContext context) => [PopupMenuItem(
        padding: EdgeInsets.all(10.0),
        value: "1",
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(deleteIcon,
              color: amount.amountColor(),
              size: alertIconSize,
            ),
            Text((id == listNumber - 1) ? "": " ${context.delete()}",
              style: TextStyle(
                  color: amount.amountColor(),
                  fontSize: context.alertFontSize(),
                  fontFamily: "default",
                  fontWeight: FontWeight.bold
              ),
            ),
          ]
        ),
      )]),
    ),
  );

  /// Text field for spreadsheet dialogs
  /// Provides consistent text input for item and amount editing
  TextField spreadSheetTextField({
    required String label,
    required double amount,
    required Function(String) onChanged,
  }) => TextField(
    style: commonWidget().textFieldTextStyle(),
    controller: TextEditingController(),
    keyboardType: (label == "amnt") ? TextInputType.numberWithOptions(decimal: true): null,
    inputFormatters: (label == "amnt") ? inputMoneyFormat: null,
    decoration: spreadSheetAlertDecoration(label, amount < 0),
    cursorWidth: alertCursorWidth,
    cursorHeight: alertCursorHeight,
    cursorColor: amount.amountColor(),
    maxLength: (label == "amnt") ? inputMoneyMaxLength: context.inputItemMaxLength(),
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    autofocus: true,
    onChanged: onChanged,
  );

  /// Input decoration for spreadsheet alert dialogs
  /// Provides styling for text fields in spreadsheet editing dialogs
  InputDecoration spreadSheetAlertDecoration(String input, bool isSpend) => InputDecoration(
    prefixIcon: Icon(input.spreadSheetAlertIcon(),
      color: transpLightBlackColor,
      size: alertIconSize,
    ),
    prefixIconConstraints: BoxConstraints(
      minWidth: context.loginInputIconSpace(),
      minHeight: context.loginInputIconSpace(),
    ),
    focusedBorder: commonWidget().textFieldUnderLineBorder(isSpend.speedDialColor()),
    counterStyle: TextStyle(fontSize: counterCharSize),
    hintText: context.spreadSheetAlertHint(input, isSpend),
    hintStyle: commonWidget().textFieldHintStyle(context.alertFontSize()),
  );

  /// Floating action button widgets
  /// Summary button for switching to summary view
  Widget summaryButton({
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.floatingActionButtonSize(),
      height: context.floatingActionButtonSize(),
      margin: EdgeInsets.only(left: floatingActionButtonLeftMargin),
      decoration: commonWidget().actionButtonBoxDecoration(purpleColor),
      child: Icon(summaryIcon,
        size: context.floatingActionIconSize(),
        color: whiteColor,
        shadows: [commonWidget().customShadow(context, true)],
      ),
    ),
  );

  /// Speed dial widget for quick allowance entry
  /// Provides floating action button with expandable options for spend/income
  Widget speedDialForInputs({
    required String startDate,
    required int index,
    required Function(DateTime?, bool) onSelected,
  }) => Container(
    decoration: commonWidget().actionButtonBoxDecoration(purpleColor),
    child: SpeedDial(
      icon: openIcon,
      activeIcon: closeIcon,
      iconTheme: IconThemeData(size: context.speedDialIconSize()),
      direction: SpeedDialDirection.up,
      buttonSize: context.floatingActionButtonSize().circleSize(),
      childrenButtonSize: context.speedDialChildButtonSize().circleSize(),
      spaceBetweenChildren: context.speedDialSpaceHeight(),
      foregroundColor: whiteColor,
      backgroundColor: purpleColor,
      curve: Curves.bounceIn,
      spacing: context.speedDialSpacing(),
      children: [true, false].map((isSpend) => spreadSheetSpeedDialChild(
        isSpend: isSpend,
        onTap: () => allowanceSelectDateDialog(
          startDate: startDate,
          index: index,
          isSpend: isSpend,
          onSelected: (picked, isSpend) => onSelected(picked, isSpend),
        ),
      )).toList(),
    ),
  );

  /// Speed dial child button for spend/income options
  /// Creates individual buttons for spend and income entry
  SpeedDialChild spreadSheetSpeedDialChild({
    required bool isSpend,
    required void Function() onTap,
  }) => SpeedDialChild(
    foregroundColor: whiteColor,
    backgroundColor: isSpend.speedDialColor(),
    label: context.speedDialTitle(isSpend),
    labelBackgroundColor: isSpend.speedDialColor(),
    labelStyle: TextStyle(
      color: whiteColor,
      fontSize: context.speedDialChildFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    ),
    child: Icon(isSpend.speedDialIcon(),
      size: context.speedDialChildIconSize(),
      shadows: [commonWidget().customShadow(context, false)],
    ),
    onTap: onTap,
  );

  /// Date picker dialog for allowance entry
  /// Allows users to select date for new allowance or spend entry
  Future<void> allowanceSelectDateDialog({
    required String startDate,
    required int index,
    required bool isSpend,
    required Function(DateTime?, bool) onSelected,
  }) async {
    DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) => Theme(
        data: selectDateTheme(isSpend),
        child: child!
      ),
      initialDate: startDate.toThisDate(index),
      firstDate: startDate.toThisMonthFirstDay(index),
      lastDate: startDate.toThisMonthLastDay(index),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: context.selectDayLocale(),
      helpText: context.settingDateHint(),
    );
    'Selected date: $picked'.debugPrint();
    onSelected(picked, isSpend);
  }

  /// Input dialog for new allowance entries
  /// Provides form for entering item and amount for new allowance/spend
  void allowanceInputDialog({
    required bool isSpend,
    required Function(String, bool) onChangedItem,
    required Function(String, bool) onChangedAmount,
    required Function(bool) onConfirm,
  }) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.speedDialTitle(isSpend)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spreadSheetTextField(
            label: "item",
            amount: isSpend ? -1.0: 1.0,
            onChanged: (value) => onChangedItem(value, isSpend), //onChangeItem(value, isSpend),
          ),
          spreadSheetTextField(
            label: "amnt",
            amount: isSpend ? -1.0: 1.0,
            onChanged: (value) => onChangedAmount(value, isSpend),  //onChangeAmount(value, isSpend),
          ),
        ],
      ),
      actions: [
        commonWidget().alertCancelButton(),
        commonWidget().alertJudgeButton(context.ok(),
          color: isSpend.speedDialColor(),
          onTap: () => onConfirm(isSpend) //setNewAllowance(isSpend)
        ),
      ],
    ),
  );
}

