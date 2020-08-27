import 'package:provider/provider.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter/material.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/utils.dart';

class RadialBarSleep extends StatefulWidget {
  @override
  _RadialBarSleepState createState() => _RadialBarSleepState();
}

class _RadialBarSleepState extends State<RadialBarSleep> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  @override
  Widget build(BuildContext context) {
    return getSleepRadialBarChart();
  }

  AnimatedCircularChart getSleepRadialBarChart() {
    return AnimatedCircularChart(
      key: _chartKey,
      size: Size(200.0, 200.0),
      initialChartData: getRadialBarData(),
      chartType: CircularChartType.Radial,
      edgeStyle: SegmentEdgeStyle.round,
    );
  }

  List<CircularStackEntry> getRadialBarData() {
    var allSleepData = Provider.of<Map<String, List<SleepData>>>(context);
    var todayNaps = Provider.of<List<SleepData>>(context);

    final List<MinPerDay> sleepData =
        Utils().listOfMinPerDay(allSleepData, false);
    final List<MinPerDay> awakeData =
        Utils().listOfMinPerDay(allSleepData, false);

    return [
      CircularStackEntry(
          sleepData.map(_sleepDataToCircularSegmentEntry).toList()
            ..add(CircularSegmentEntry(
                (1440 - Utils().getTotalSleepToday(todayNaps)).toDouble(),
                Colors.grey.shade500)),
          rankKey: "Rank key")
    ];
  }

  CircularSegmentEntry _sleepDataToCircularSegmentEntry(MinPerDay data) {
    return CircularSegmentEntry(data.duration.toDouble(), Colors.black,
        rankKey: data.date);
  }
}
