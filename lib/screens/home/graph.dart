import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/utils.dart';
import 'package:intl/intl.dart';

class GraphView extends StatefulWidget {
  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  Widget build(BuildContext context) {
    bool _showMonthGraph = Provider.of<bool>(context);
    var allData = Provider.of<Map<String, List<WaterIntake>>>(context);
    var dataWeek = Utils().listOfMlPerDayWeek(allData);
    var dataMonth = Utils().listOfMlPerDayMonth(allData);
    print(dataWeek.length);
    var seriesWeek = [
      new charts.Series<MlPerDay, String>(
          data: dataWeek,
          measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
          colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
          id: 'mls',
          domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
              .format(DateTime.parse(mlPerDay.date))
              .substring(0, 3))
    ];

    var seriesMonth = [
      new charts.Series<MlPerDay, String>(
          data: dataMonth,
          measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
          colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
          id: 'mls',
          domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
              .format(DateTime.parse(mlPerDay.date))
              .substring(0, 3))
    ];

    var chartWidget = Padding(
      padding: EdgeInsets.all(20.0),
      child: SizedBox(
        child: charts.BarChart(
          seriesWeek,
          animate: true,
        ),
        height: 200.0,
      ),
    );
    var chartWidgetMonth = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: SizedBox(
          child: charts.BarChart(
            seriesMonth,
            animate: true,
          ),
          height: 200.0,
          width: 700.0,
        ),
      ),
      scrollDirection: Axis.horizontal,
      
    );
    return _showMonthGraph ? chartWidgetMonth : chartWidget;
  }
}
