import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admob_banner.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';

/// Chart page widget that displays allowance tracking data in graphical format
/// Uses fl_chart library to create line charts for assets, balance, and spending
class ChartPage extends HookConsumerWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /// Allowance Data - State variables for storing allowance tracking information
    final index = useState(0);
    final maxIndex = useState(0);
    final listNumber = useState([1]);
    final allowanceDate = useState([[0]]);
    final allowanceItem = useState([[""]]);
    final allowanceAmnt = useState([[0.0]]);
    final balance = useState([0.0]);
    final spends = useState([0.0]);
    final assets = useState([0.0]);

    /// Personal Data - User preferences and settings
    final unit = useState("\$");
    final initialAssets = useState(0.0);
    final targetAssets = useState(0.0);
    final currentDate = DateTime.now().toDateString();
    final startDate = useState(currentDate);

    /// Widget instances for common UI components
    final commonWidget = CommonWidget(context);
    final chartWidget = ChartWidget(context);

    /// Get Allowance Data - Loads saved allowance data from SharedPreferences
    /// Retrieves all stored allowance information and calculates derived values
    getAllowanceData() {
      SharedPreferences.getInstance().then((prefs) {
        // Load user preferences and settings
        unit.value = "unitKey".getSharedPrefString(prefs, (context.mounted) ? context.defaultUnit(): "\$");
        initialAssets.value = "initialAssetsKey".getSharedPrefDouble(prefs, 0.0);
        targetAssets.value = "targetAssetsKey".getSharedPrefDouble(prefs, 0.0);
        startDate.value = "startDateKey".getSharedPrefString(prefs, currentDate);
        // Load allowance tracking data
        allowanceDate.value = "dateKey".getSharedPrefString(prefs, "${[[0]]}").toString().toListListDate();
        allowanceItem.value = "itemKey".getSharedPrefString(prefs, "${[[""]]}").toString().toListListItem();
        allowanceAmnt.value = "amntKey".getSharedPrefString(prefs, "${[[0.0]]}").toString().toListListAmnt();
        // Calculate derived values for chart display
        maxIndex.value = allowanceAmnt.value.calcMaxIndex();
        index.value = startDate.value.currentIndex();
        listNumber.value = allowanceAmnt.value.calcListNumber();
        balance.value = allowanceAmnt.value.calcBalance(maxIndex.value);
        spends.value = allowanceAmnt.value.calcSpends(maxIndex.value);
        assets.value = balance.value.calcAssets(maxIndex.value, initialAssets.value);
      });
    }

    /// Next Year - Navigate between years in the chart
    /// Moves 12 months forward or backward based on the isPlus parameter
    changeYear(bool isPlus) async {
      for (int i = 0; i < 12; i++) {
        if (isPlus && (index.value < maxIndex.value)) index.value++;
        if (!isPlus && (index.value > 0)) index.value--;
      }
      "index: ${index.value}".debugPrint();
    }

    /// UseEffect for Initialize - Loads data when widget is first created
    /// Runs after the widget is built to ensure proper initialization
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SharedPreferences.getInstance().then((prefs) => getAllowanceData());
      });
      return null;
    }, []);

    /// Main UI Layout - Returns the complete chart page structure
    return Column(children: [
      /// PlusMinus Navigation - Year navigation controls with current year display
      Stack(children: [
        Container(
          margin: EdgeInsets.only(top: context.plusMinusMarginTop()),
          child: Row(children: [
            Spacer(flex: 1),
            // Previous year button
            commonWidget.plusMinusButton(isPlus: false,
              color: startDate.value.yearPlusMinusColor(false, index.value, maxIndex.value),
              onTap: () =>  changeYear(false),
            ),
            SizedBox(width: context.plusMinusSpace()),
            // Next year button
            commonWidget.plusMinusButton(isPlus: true,
              color: startDate.value.yearPlusMinusColor(true, index.value, maxIndex.value),
              onTap: () =>  changeYear(true),
            ),
            Spacer(flex: 1),
          ]),
        ),
        // Current year display
        Center(child: Text(startDate.value.stringThisYear(index.value),
          style: commonWidget.enAccentTextStyle(context.monthYearFontSize())
        )),
      ]),
      
      /// Chart Display Area - Scrollable container with multiple charts
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scrollViewMarginHorizontal(),
            vertical: context.scrollViewMarginVertical(),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                // Generate charts for assets, balance, and spends if data exists
                children: [assets.value, balance.value, spends.value].asMap().entries.map((entry) =>
                  entry.value.reduce(max) > 0 ? chartWidget.summaryChart(entry.value,
                    color: chartColorList[entry.key],
                    index: index.value,
                    maxIndex: maxIndex.value,
                    startDate: startDate.value,
                    unit: unit.value,
                  ) : null
                ).whereType<Widget>().toList()
              )
            ),
          ),
        ),
      ),
      /// Advertisement Banner - Display at bottom of page
      AdBannerWidget(),
    ]);
  }
}

/// ChartWidget class - Handles the creation and configuration of chart components
/// Provides methods for creating line charts with custom styling and data
class ChartWidget {

  final BuildContext context;
  const ChartWidget(this.context);

  /// Get CommonWidget instance for shared UI components
  CommonWidget commonWidget() => CommonWidget(context);

  /// Summary Chart - Creates a line chart widget for displaying allowance data
  /// Parameters:
  /// - list: Data points to display on the chart
  /// - color: Chart line color
  /// - index: Current month index
  /// - maxIndex: Maximum available month index
  /// - startDate: Start date for date calculations
  /// - unit: Currency unit for display
  Widget summaryChart(List<double> list, {
    required Color color,
    required int index,
    required int maxIndex,
    required String startDate,
    required String unit,
  }) => Container(
    height: context.chartHeight(),
    width: context.chartWidth(),
    margin: EdgeInsets.only(bottom: context.chartBottomMargin()),
    child: LineChart(
      LineChartData(
        lineTouchData: chartTouchData(),
        lineBarsData: [chartLineData(list.chartData(index, maxIndex, startDate), color)],
        minY: 0,
        maxY: list.reduce(max).maxChartY(null),
        gridData: chartGridData(),
        backgroundColor: transpWhiteColor,
        borderData: chartBorderData(),
        titlesData: flTitlesData(list, unit, color)
      ),
    ),
  );

  /// Chart Touch Data - Configures touch interaction for the chart
  /// Sets up tooltip display when user taps on chart points
  LineTouchData chartTouchData() => LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => whiteColor,
    ),
  );

  /// Chart Line Data - Configures the appearance of the chart line
  /// Sets line color, width, and dot styling for data points
  LineChartBarData chartLineData(List<FlSpot> flSpotList, Color color) => LineChartBarData(
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

  /// Chart Grid Data - Configures the grid lines on the chart
  /// Sets up horizontal and vertical grid lines with custom styling
  FlGridData chartGridData() => FlGridData(
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

  /// Chart Border Data - Configures the border around the chart
  /// Sets border color and width for chart container
  FlBorderData chartBorderData() => FlBorderData(
    show: true,
    border: Border.all(
      color: whiteColor,
      width: context.chartBorderWidth()
    )
  );

  /// Bottom Axis Number - Configures the bottom axis labels (month numbers)
  /// Sets up interval and styling for month number display
  SideTitles bottomAxisNumber() => SideTitles(
    showTitles: true,
    interval: 1,
    reservedSize: context.chartBottomReservedSize(),
    getTitlesWidget: (value, meta) => SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(meta.formattedValue,
        style: defaultAccentTextStyle(context.chartAxisFontSize()),
      ),
    )
  );

  /// Bottom Axis Title Text - Creates the "Month" label for bottom axis
  /// Displays the month label with custom styling
  Widget bottomAxisTitleText() => Container(
    margin: EdgeInsets.only(left: context.chartBottomMarginLeft()),
    child: Text(context.month(),
      style: defaultAccentTextStyle(context.chartBottomFontSize())
    ),
  );

  /// Left Axis Number - Configures the left axis labels (amount values)
  /// Sets up interval and styling for amount value display
  SideTitles leftAxisNumber(List<double> list) => SideTitles(
    showTitles: true,
    interval: list.reduce(max).maxChartY(null) / 5,
    reservedSize: context.chartLeftReservedSize(),
    getTitlesWidget: (value, meta) => SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(meta.formattedValue,
        style: defaultAccentTextStyle(context.chartAxisFontSize()),
      ),
    )
  );

  /// Default Accent Text Style - Creates consistent text styling for chart labels
  /// Applies white color, bold font weight, and custom shadow effects
  TextStyle defaultAccentTextStyle(double fontSize) => TextStyle(
    color: whiteColor,
    fontSize: fontSize,
    fontFamily: "default",
    fontWeight: FontWeight.bold,
    shadows: [commonWidget().customShadow(context, false)],
  );

  /// Fl Titles Data - Configures all chart titles and axis labels
  /// Sets up top title, bottom axis, left axis, and right axis
  FlTitlesData flTitlesData(List<double> list, String unit, Color color) => FlTitlesData(
    show: true,
    topTitles: AxisTitles(
      axisNameSize: context.chartTopAxisNameSize(),
      axisNameWidget: chartTitleText(unit, color),
    ),
    bottomTitles: AxisTitles(
      sideTitles: bottomAxisNumber(),
      axisNameSize: context.chartBottomAxisNameSize(),
      axisNameWidget: bottomAxisTitleText(),
    ),
    leftTitles: AxisTitles(sideTitles: leftAxisNumber(list)),
    rightTitles: AxisTitles(axisNameWidget: SizedBox(width: 0)),
  );

  /// Chart Title Text - Creates the top title for the chart
  /// Displays currency unit and chart type (Assets/Balance/Spends)
  Widget chartTitleText(String unit, Color color) => Container(
    margin: EdgeInsets.only(left: context.chartTopMarginLeft()),
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Currency unit display
        Text("[$unit] ",
          style: TextStyle(
            color: whiteColor,
            fontSize: context.chartTitleFontSize(),
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
            shadows: [commonWidget().customShadow(context, false)],
          ),
        ),
        // Chart type display (Assets/Balance/Spends)
        Text("${context.chartTitle(color)} ",
          style: TextStyle(
            color: whiteColor,
            fontSize:context.chartTitleFontSize(),
            fontFamily: context.customAccentFont(),
            fontWeight: FontWeight.bold,
            shadows: [commonWidget().customShadow(context, false)],
          )
        ),
      ]
    ),
  );
}
