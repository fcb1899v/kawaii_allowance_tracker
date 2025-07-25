import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'extension.dart';
import 'constant.dart';
import 'login_widget.dart';
import 'widget.dart';

///App Tracking Transparency
initATTPlugin(BuildContext context) async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined && context.mounted) {
    await showCupertinoDialog(context: context,
      builder: (context) => CupertinoAlertDialog(
        title: alertTitleText(context, context.appTitle()),
        content: Text(context.thisApp()),
        actions: [
          CupertinoDialogAction(
            child: alertJudgeButtonText(context, "ok", purpleColor),
            onPressed: () => context.popPage(),
          )
        ],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

///Alert Dialog
alertTitleText(BuildContext context, String title) =>
    Container(
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

ThemeData selectDateTheme(BuildContext context, bool isSpend) =>
    Theme.of(context).copyWith(
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

///Shared Preference
//Initialize
initializeSharedPreferences() async =>
  await SharedPreferences.getInstance();

///Firestore
//Set Data
setDataFireStore(BuildContext context, SharedPreferences prefs, bool isLogin, bool isFirstSaveFinish, String key, dynamic setValue, int currentDateTime) async {
  final currentTime = DateTime.now().toDateTimeInt();
  if (isLogin && isFirstSaveFinish) {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      await docRef.set({key: setValue}, SetOptions(merge: true));
      await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
      await "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentTime);
    } on FirebaseException catch (e) {
      '${e.code}: $e'.debugPrint();
      if (context.mounted) showFailedSnackBar(context, context.storeDataFailed(), null);
    }
  }
}

setStringFirestore(BuildContext context, SharedPreferences prefs, bool isLogin, bool isFirstSaveFinish, String key, String setValue) async {
  final currentDateTime = DateTime.now().toDateTimeInt();
  await key.setSharedPrefString(prefs, setValue);
  await "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
  if (context.mounted) await setDataFireStore(context, prefs, isLogin, isFirstSaveFinish, key, setValue, currentDateTime);
}

setDoubleFirestore(BuildContext context, SharedPreferences prefs, bool isLogin, bool isFirstSaveFinish, String key, double setValue) async {
  final currentDateTime = DateTime.now().toDateTimeInt();
  await key.setSharedPrefDouble(prefs, setValue);
  await "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
  if (context.mounted) await setDataFireStore(context, prefs, isLogin, isFirstSaveFinish, key, setValue, currentDateTime);
}

setAllowanceDataFirestore(BuildContext context, SharedPreferences prefs, bool isLogin, bool isAllowData, List<List<int>> allowanceDate, List<List<String>> allowanceItem, List<List<double>> allowanceAmnt) async {
  final currentDateTime = DateTime.now().toDateTimeInt();
  await "dateKey".setSharedPrefString(prefs, jsonEncode(allowanceDate));
  await "itemKey".setSharedPrefString(prefs, jsonEncode(allowanceItem));
  await "amntKey".setSharedPrefString(prefs, jsonEncode(allowanceAmnt));
  await "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
  if (isLogin && isAllowData) {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      "user: $user".debugPrint();
      DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      await docRef.set({"dateKey": jsonEncode(allowanceDate)}, SetOptions(merge: true));
      await docRef.set({"itemKey": jsonEncode(allowanceItem)}, SetOptions(merge: true));
      await docRef.set({"amntKey": jsonEncode(allowanceAmnt)}, SetOptions(merge: true));
      await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
      await "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
    } on FirebaseException catch (e) {
      '${e.code}: $e'.debugPrint();
      if (context.mounted) showFailedSnackBar(context, context.storeDataFailed(), null);
    }
  }
}

//Get Data
Future<int> getServerSaveDateTime() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot snapshot = await docRef.get();
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data!["serverSaveDateTimeKey"] != null) {
        "serverSaveDateTime: ${data["serverSaveDateTimeKey"]}".debugPrint();
        return data["serverSaveDateTimeKey"];
      } else {
        "serverSaveDateTime: current time".debugPrint();
        return DateTime.now().toDateTimeInt();
      }
    } else {
      "serverSaveDateTime: current time".debugPrint();
      return DateTime.now().toDateTimeInt();
    }
  } catch (e) {
    "Error: $e' -> serverSaveDateTime: current time}".debugPrint();
    return DateTime.now().toDateTimeInt();
  }
}

///AppBar
Widget appBarTitle(BuildContext context, bool isSelectSummary) =>
    Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(isSelectSummary ? summaryIcon: listIcon,
          size: appBarIconSize,
          color: whiteColor,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: appBarTitleIconSpace),
          child: appBarTitleText(context, context.appBarTitleText(!isSelectSummary)),
        )
      ]
    );

PopupMenuItem appBarPopupMenu(BuildContext context, String value) =>
    PopupMenuItem(
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

///Drawer
Widget drawerHeader(BuildContext context, String name) =>
    SizedBox(
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
              shadows: [
                Shadow(
                  color: transpBlackColor,
                  blurRadius: shadowBlur,
                  offset: Offset(shadowOffset, shadowOffset)
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
    );

TextStyle selectUnitTextStyle(BuildContext context) =>
    TextStyle(
      color: transpBlackColor,
      fontSize: drawerUnitFontSize,
      fontFamily: "Roboto",
      fontWeight: FontWeight.bold,
    );

menuNameListTile(BuildContext context, String name) =>
    Container(
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
    );

menuUnitListTile(BuildContext context, String unit) =>
    Container(
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
    );

menuAssetsListTile(BuildContext context, double initialAssets, String unit, bool isInitial) =>
    Container(
      margin: EdgeInsets.all(context.drawerMenuListMargin()),
      child: ListTile(
        leading: Icon(amntIcon, size: context.drawerMenuListIconSize()),
        title: Text(isInitial ? context.initialAssets(): context.targetAssets(),
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
            Text(initialAssets.stringAssets(context, unit),
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
    );

menuLoginTile(BuildContext context, bool isLogin, bool isSaveData) =>
    Container(
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
    );

menuDeleteAccountListTile(BuildContext context, String name) =>
    Container(
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
    );

menuStartDateListTile(BuildContext context, String startDate) =>
    Container(
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

InputDecoration drawerAlertDecoration(BuildContext context, String input) =>
    InputDecoration(
      prefixIcon: textFieldPrefixIcon(input.drawerAlertIcon()),
      focusedBorder: textFieldUnderLineBorder(input.drawerAlertColor()),
      counterStyle: TextStyle(fontSize: counterCharSize),
      hintText: context.drawerAlertHint(input),
      hintStyle: textFieldHintStyle(context.alertFontSize()),
    );

///MainBody
//Plus Minus Button
plusMinusImage(BuildContext context, bool isPlus, Color color) =>
    Container(
      width: context.plusMinusSize(),
      height: context.plusMinusSize(),
      decoration: actionButtonBoxDecoration(color),
      child: Icon(isPlus ? forwardIcon : backIcon,
        size: context.plusMinusIconSize(),
        color: whiteColor,
        shadows: [customShadow(true, shadowOffset)],
      ),
    );

//Balance View
balanceView(BuildContext context, double balance, String unit) =>
    Container(
      margin: EdgeInsets.symmetric(horizontal: context.balanceMarginHorizontal()),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.balance(), style: customAccentTextStyle(context, context.balanceFontSize(), false)),
          Text(unit,
            style: TextStyle(
              color: whiteColor,
              fontSize: context.balanceUnitSize(),
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
              shadows: [customShadow(false, shadowOffset)],
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
                shadows: [customShadow(false, shadowOffset)],
              )
            ),
          ),
        ],
      ),
    );

//Percent View
percentView(BuildContext context, double percent) =>
    Container(
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

///SpreadSheet
List<DataColumn> dataColumnTitles(BuildContext context) =>
    [
      dataColumnIcon(context, dateIcon),
      dataColumnDivider(),
      dataColumnIcon(context, itemIcon),
      dataColumnDivider(),
      dataColumnIcon(context, amntIcon),
      dataColumnDivider(),
      dataColumnIcon(context, deleteIcon),
    ];

DataColumn dataColumnIcon(BuildContext context, IconData icon) =>
    DataColumn(
      label: Expanded(
        child: Icon(icon, 
          color: whiteColor, 
          size: context.spreadSheetIconSize(),
          shadows: [customShadow(true, shadowOffset)],
        )
      )
    );

DataColumn dataColumnDivider() =>
    DataColumn(
      label: VerticalDivider(
        color: whiteColor, 
        thickness: spreadSheetDividerWidth
      ),
    );


TextStyle spreadSheetTextStyle(BuildContext context, double amount) =>
    TextStyle(
      color: amount.amountColor(),
      fontSize: context.spreadSheetFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
    );

TextStyle spreadSheetAmountTextStyle(BuildContext context, double amount, bool isUnit) =>
    TextStyle(
      color: amount.amountColor(),
      fontSize: context.spreadSheetFontSize(),
      fontFamily: isUnit ? "Roboto": "defaultFont",
      fontWeight: FontWeight.bold,
    );

spreadSheetText(BuildContext context, double amount, String text) =>
    SizedBox(
      width: double.infinity,
      child: Text(text,
        style: spreadSheetTextStyle(context, amount),
        textAlign: TextAlign.left,
        maxLines: 1,
      ),
    );

spreadSheetAmountText(BuildContext context, double amount, String text, String unit) =>
    SizedBox(
      width: double.infinity,
      child: Row(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(unit, style: spreadSheetAmountTextStyle(context, amount, true), maxLines: 1),
          Text(text, style: spreadSheetAmountTextStyle(context, amount, false), maxLines: 1),
        ]
      )
    );

PopupMenuItem deleteButtonImage(BuildContext context, double amount, int id, int listNumber) =>
    PopupMenuItem(
      padding: EdgeInsets.all(10.0),
      value: "1",
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(deleteIcon,
            color: amount.amountColor(),
            size: alertIconSize,
          ),
          Text((id == listNumber - 1) ? "": "  ${context.delete()}",
            style: TextStyle(
              color: amount.amountColor(),
              fontSize: context.alertFontSize(),
              fontFamily: "default",
              fontWeight: FontWeight.bold
            ),
          ),
        ]
      ),
    );

InputDecoration spreadSheetAlertDecoration(BuildContext context, String input, bool isSpend) =>
    InputDecoration(
      prefixIcon: textFieldPrefixIcon(input.spreadSheetAlertIcon()),
      focusedBorder: textFieldUnderLineBorder(isSpend.speedDialColor()),
      counterStyle: TextStyle(fontSize: counterCharSize),
      hintText: context.spreadSheetAlertHint(input, isSpend),
      hintStyle: textFieldHintStyle(context.alertFontSize()),
    );

summaryButtonImage(BuildContext context) =>
    Container(
      width: context.floatingActionButtonSize(),
      height: context.floatingActionButtonSize(),
      margin: EdgeInsets.only(left: floatingActionButtonLeftMargin),
      decoration: actionButtonBoxDecoration(purpleColor),
      child: Icon(summaryIcon,
        size: context.floatingActionIconSize(),
        color: whiteColor,
        shadows: [customShadow(true, shadowOffset)],
      ),
    );

///Chart
LineTouchData chartTouchData() =>
    LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => whiteColor,
      ),
    );

LineChartBarData chartLineData(BuildContext context, List<FlSpot> flSpotList, Color color) =>
    LineChartBarData(
      spots: flSpotList,
      color: color,
      barWidth: context.chartBarWidth(),
      dotData:  FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: context.chartDotWidth(),
          color: color,
          strokeColor: whiteColor,
        ),
      ),
    );

FlGridData chartGridData(BuildContext context) =>
    FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (_) => FlLine(
        color: whiteColor,
        strokeWidth: context.chartHorizontalBorderWidth(),
        dashArray: chartBorderDashArray,
      ),
      getDrawingVerticalLine: (_) => FlLine(
        color: whiteColor,
        strokeWidth: context.chartVerticalBorderWidth(),
        dashArray: chartBorderDashArray,
      ),
    );

FlBorderData chartBorderData(BuildContext context) =>
    FlBorderData(
      show: true,
      border: Border.all(
        color: whiteColor,
        width: context.chartBorderWidth()
      )
    );

SideTitles bottomAxisNumber(BuildContext context) =>
    SideTitles(
      showTitles: true,
      interval: 1,
      reservedSize: context.chartBottomReservedSize(),
      getTitlesWidget: (value, meta) => SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(meta.formattedValue,
          style: defaultAccentTextStyle(context, context.chartAxisFontSize()),
        ),
      )
    );

Widget bottomAxisTitleText(BuildContext context) =>
    Container(
      margin: EdgeInsets.only(left: context.chartBottomMarginLeft()),
      child: Text(context.month(),
        style: defaultAccentTextStyle(context, context.chartBottomFontSize())
      ),
    );

SideTitles leftAxisNumber(BuildContext context, List<double> list) =>
    SideTitles(
      showTitles: true,
      interval: list.reduce(max).maxChartY(null) / 5,
      reservedSize: context.chartLeftReservedSize(),
      getTitlesWidget: (value, meta) => SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(meta.formattedValue,
          style: defaultAccentTextStyle(context, context.chartAxisFontSize()),
        ),
      )
    );

FlTitlesData flTitlesData(BuildContext context, List<double> list, String unit, Color color) => FlTitlesData(
  show: true,
  topTitles: AxisTitles(
    axisNameSize: context.chartTopAxisNameSize(),
    axisNameWidget: chartTitleText(context, unit, color),
  ),
  bottomTitles: AxisTitles(
    sideTitles: bottomAxisNumber(context),
    axisNameSize: context.chartBottomAxisNameSize(),
    axisNameWidget: bottomAxisTitleText(context),
  ),
  leftTitles: AxisTitles(sideTitles: leftAxisNumber(context, list)),
  rightTitles: AxisTitles(axisNameWidget: SizedBox(width: 0)),
);


Widget chartTitleText(BuildContext context, String unit, Color color) =>
    Container(
      margin: EdgeInsets.only(left: context.chartTopMarginLeft()),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("[$unit] ",
            style: TextStyle(
              color: whiteColor,
              fontSize: context.chartTitleFontSize(),
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
              shadows: [customShadow(false, shadowOffset)],
            ),
          ),
          Text("${context.chartTitle(color)} ",
            style: TextStyle(
              color: whiteColor,
              fontSize:context.chartTitleFontSize(),
              fontFamily: context.customAccentFont(),
              fontWeight: FontWeight.bold,
              shadows: [customShadow(false, shadowOffset)],
            )
          ),
        ]
      ),
    );

