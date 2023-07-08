import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'admob_banner.dart';
import 'extension.dart';
import 'home_widget.dart';
import 'constant.dart';
import 'widget.dart';

class MyHomeChart extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ///Allowance Data
    final index = useState(0);
    final maxIndex = useState(0);
    final listNumber = useState([1]);
    final allowanceDate = useState([[0]]);
    final allowanceItem = useState([[""]]);
    final allowanceAmnt = useState([[0.0]]);
    final balance = useState([0.0]);
    final spends = useState([0.0]);
    final assets = useState([0.0]);

    ///Personal Data
    final unit = useState("\$");
    final initialAssets = useState(0.0);
    final targetAssets = useState(0.0);
    final currentDate = DateTime.now().toDateString();
    final startDate = useState(currentDate);

    ///Get Allowance Data
    getAllowanceData() {
      initializeSharedPreferences().then((prefs) {
        unit.value = "unitKey".getSharedPrefString(prefs, context.defaultUnit());
        initialAssets.value = "initialAssetsKey".getSharedPrefDouble(prefs, 0.0);
        targetAssets.value = "targetAssetsKey".getSharedPrefDouble(prefs, 0.0);
        startDate.value = "startDateKey".getSharedPrefString(prefs, currentDate);
        index.value = startDate.value.toCurrentIndex();
        allowanceDate.value = "dateKey".getSharedPrefString(prefs, "${[[0]]}").toString().toListListDate();
        allowanceItem.value = "itemKey".getSharedPrefString(prefs, "${[[""]]}").toString().toListListItem();
        allowanceAmnt.value = "amntKey".getSharedPrefString(prefs, "${[[0.0]]}").toString().toListListAmnt();
        maxIndex.value = allowanceAmnt.value.calcMaxIndex();
        listNumber.value = allowanceAmnt.value.calcListNumber();
        balance.value = allowanceAmnt.value.calcBalance(maxIndex.value);
        spends.value = allowanceAmnt.value.calcSpends(maxIndex.value);
        assets.value = balance.value.calcAssets(maxIndex.value, initialAssets.value);
      });
    }

    ///Next Year
    changeYear(bool isPlus) async {
      for (int i = 0; i < 12; i++) {
        if (isPlus && (index.value < maxIndex.value)) index.value++;
        if (!isPlus && (index.value > 0)) index.value--;
      }
      "index: ${index.value}".debugPrint();
    }

    LineTouchData chartTouchData() =>
        LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: whiteColor
          ),
        );

    FlDotData chartDotData(Color color) =>
        FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: context.chartDotWidth(),
            color: color,
            strokeColor: whiteColor,
          ),
        );

    LineChartBarData chartLineData(List<FlSpot> flSpotList, Color color) =>
        LineChartBarData(
          spots: flSpotList,
          color: color,
          barWidth: context.chartBarWidth(),
          dotData: chartDotData(color),
        );

    FlGridData chartGridData() =>
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

    FlBorderData chartBorderData() =>
        FlBorderData(
          show: true,
          border: Border.all(
            color: whiteColor,
            width: context.chartBorderWidth()
          )
        );

    chartTitleText(Color color) =>
        Container(
          margin: EdgeInsets.only(left: context.chartTopMarginLeft()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("[${unit.value}] ", style: unitAccentTextStyle(context, context.chartTitleFontSize())),
              Text("${context.chartTitle(color)} ",
                style: customAccentTextStyle(context, context.chartTitleFontSize(), false)
              ),
            ]
          ),
        );

    SideTitles bottomAxisNumber() =>
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

    bottomAxisTitleText() =>
        Container(
          margin: EdgeInsets.only(left: context.chartBottomMarginLeft()),
          child: Text(context.month(),
            style: defaultAccentTextStyle(context, context.chartBottomFontSize())
          ),
        );

    SideTitles leftAxisNumber(List<double> list) =>
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

    ///Chart
    Widget summaryChart(List<double> list, Color color, bool isAddTarget) =>
        Container(
          height: context.chartHeight(),
          width: context.chartWidth(),
          margin: EdgeInsets.only(bottom: context.chartBottomMargin()),
          child: LineChart(
            LineChartData(
              lineTouchData: chartTouchData(),
              lineBarsData: [
                chartLineData(list.chartData(index.value, maxIndex.value, startDate.value), color),
                if (isAddTarget) chartLineData(list.targetChartData(targetAssets.value), purpleColor),
              ],
              minY: 0,
              maxY: list.reduce(max).maxChartY(null),
              gridData: chartGridData(),
              backgroundColor: transpWhiteColor,
              borderData: chartBorderData(),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  axisNameSize: context.chartTopAxisNameSize(),
                  axisNameWidget: chartTitleText(color),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: bottomAxisNumber(),
                  axisNameSize: context.chartBottomAxisNameSize(),
                  axisNameWidget: bottomAxisTitleText(),
                ),
                leftTitles: AxisTitles(sideTitles: leftAxisNumber(list)),
                rightTitles: AxisTitles(axisNameWidget: SizedBox(width: 0)),
              ),
            ),
          ),
        );

    ///UseEffect for Initialize
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeSharedPreferences().then((prefs) => getAllowanceData());
      });
      return null;
    }, []);

    ///Main
    return Column(children: [
      ///PlusMinus
      Stack(children: [
        Container(
          margin: EdgeInsets.only(top: context.plusMinusMarginTop()),
          child: Row(children: [
            Spacer(flex: 1),
            GestureDetector(
              child: plusMinusImage(context, false, startDate.value.yearPlusMinusColor(false, index.value, maxIndex.value)),
              onTap: () =>  changeYear(false),
            ),
            SizedBox(width: context.plusMinusSpace()),
            GestureDetector(
              child: plusMinusImage(context, true, startDate.value.yearPlusMinusColor(true, index.value, maxIndex.value)),
              onTap: () =>  changeYear(true),
            ),
            Spacer(flex: 1),
          ]),
        ),
        Center(child: monthYearText(context, startDate.value.stringThisYear(index.value)))
      ]),
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scrollViewMarginHorizontal(),
            vertical: context.scrollViewMarginVertical(),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Column(children: [
                if (assets.value.reduce(max) > 0) summaryChart(assets.value, pinkColor, false),
                if (balance.value.reduce(max) > 0) summaryChart(balance.value, purpleColor, false),
                if (spends.value.reduce(max) > 0) summaryChart(spends.value, blueColor, false),
              ])
            ),
          ),
        ),
      ),
      AdBannerWidget(),
    ]);
  }
}
