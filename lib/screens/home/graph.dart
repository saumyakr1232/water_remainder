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

    var chartWidget = Padding(
      padding: EdgeInsets.all(20.0),
      child: SizedBox(
        child: charts.BarChart(
          getGraph(_showMonthGraph),
          animate: true,
          defaultRenderer: new charts.BarRendererConfig(
              groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
        ),
        height: 200.0,
      ),
    );
    var chartWidgetMonth = SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          child: charts.BarChart(
            getGraph(_showMonthGraph),
            animate: true,
            domainAxis: charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)),
            defaultRenderer: new charts.BarRendererConfig(
                groupingType: charts.BarGroupingType.stacked,
                strokeWidthPx: 2.0),
          ),
          height: 200.0,
          width: 700.0,
        ),
      ),
      scrollDirection: Axis.horizontal,
    );
    var colorMappingDeatail = Container(
      height: 100.0,
      margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              FlatButton.icon(
                  padding: EdgeInsets.all(4.0),
                  onPressed: null,
                  icon:
                      Icon(Icons.circle, color: Utils().getDrinkColor("water")),
                  label: Text("Water")),
              FlatButton.icon(
                  padding: EdgeInsets.all(4.0),
                  onPressed: null,
                  icon:
                      Icon(Icons.circle, color: Utils().getDrinkColor("soda")),
                  label: Text("soda")),
              FlatButton.icon(
                  padding: EdgeInsets.all(4.0),
                  onPressed: null,
                  icon:
                      Icon(Icons.circle, color: Utils().getDrinkColor("juice")),
                  label: Text("juice")),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton.icon(
                  padding: EdgeInsets.all(4.0),
                  onPressed: null,
                  icon: Icon(Icons.circle, color: Utils().getDrinkColor("tea")),
                  label: Text("Tea")),
              FlatButton.icon(
                  padding: EdgeInsets.all(4.0),
                  onPressed: null,
                  icon: Icon(Icons.circle,
                      color: Utils().getDrinkColor("coffee")),
                  label: Text("Coffee")),
            ],
          )
        ],
      ),
    );
    return _showMonthGraph
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              chartWidgetMonth,
              colorMappingDeatail,
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              chartWidget,
              colorMappingDeatail,
            ],
          );
  }

  List<charts.Series<MlPerDay, String>> getGraph(bool _showMonthGraph) {
    var allData = Provider.of<Map<String, List<WaterIntake>>>(context);
    var waterDataWeek = Utils().listOfMlPerDay(allData, "water", false);
    var waterDataMonth = Utils().listOfMlPerDay(allData, "water", true);
    var sodaDataWeek = Utils().listOfMlPerDay(allData, "soda", false);
    var sodaDataMonth = Utils().listOfMlPerDay(allData, "soda", true);
    var teaDataWeek = Utils().listOfMlPerDay(allData, "tea", false);
    var teaDataMonth = Utils().listOfMlPerDay(allData, "tea", true);
    var coffeeDataWeek = Utils().listOfMlPerDay(allData, "coffee", false);
    var coffeeDataMonth = Utils().listOfMlPerDay(allData, "coffee", true);
    var juiceDataWeek = Utils().listOfMlPerDay(allData, "juice", false);
    var juiceDataMonth = Utils().listOfMlPerDay(allData, "juice", true);

    return !_showMonthGraph
        ? [
            new charts.Series<MlPerDay, String>(
                data: waterDataWeek,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'waterDataWeek',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: sodaDataWeek,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'sodaDataWeek',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: teaDataWeek,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'teaDataWeek',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: coffeeDataWeek,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'coffeeDataWeek',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: juiceDataWeek,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'juiceDataWeek',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat.EEEE()
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
          ]
        : [
            new charts.Series<MlPerDay, String>(
                data: waterDataMonth,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'waterDataMonth',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: sodaDataMonth,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'sodaDataMonth',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: teaDataMonth,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'teaDataMonth',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: coffeeDataMonth,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'coffeeDataMonth',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3)),
            new charts.Series<MlPerDay, String>(
                data: juiceDataMonth,
                measureFn: (MlPerDay mlPerDay, _) => mlPerDay.amount,
                colorFn: (MlPerDay mlPerDay, _) => mlPerDay.color,
                id: 'juiceDataMonth',
                // fillColorFn: (_, __) =>
                //     charts.MaterialPalette.blue.shadeDefault.lighter,
                domainFn: (MlPerDay mlPerDay, _) => DateFormat('dd-MM')
                    .format(DateTime.parse(mlPerDay.date))
                    .substring(0, 3))
          ];
  }
}
