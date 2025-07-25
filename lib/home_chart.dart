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
  const MyHomeChart({super.key});

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
        allowanceDate.value = "dateKey".getSharedPrefString(prefs, "${[[0]]}").toString().toListListDate();
        allowanceItem.value = "itemKey".getSharedPrefString(prefs, "${[[""]]}").toString().toListListItem();
        allowanceAmnt.value = "amntKey".getSharedPrefString(prefs, "${[[0.0]]}").toString().toListListAmnt();
        maxIndex.value = allowanceAmnt.value.calcMaxIndex();
        index.value = maxIndex.value;
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
                chartLineData(context, list.chartData(index.value, maxIndex.value, startDate.value), color),
                if (isAddTarget) chartLineData(context, list.targetChartData(targetAssets.value), purpleColor),
              ],
              minY: 0,
              maxY: list.reduce(max).maxChartY(null),
              gridData: chartGridData(context),
              backgroundColor: transpWhiteColor,
              borderData: chartBorderData(context),
              titlesData: flTitlesData(context, list, unit.value, color)
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
        Center(child: Text(startDate.value.stringThisYear(index.value),
          style: enAccentTextStyle(context, context.monthYearFontSize())
        )),
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
