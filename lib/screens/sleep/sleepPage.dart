import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/screens/commonWidgits.dart';
import 'package:water_recommender/screens/sleep/sleepRadialBar.dart';
import 'package:water_recommender/services/database.dart';

class SleepPage extends StatefulWidget {
  final Function() notifyParent;
  SleepPage({this.notifyParent});
  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  int _amount = 0;
  Future _setAmount(int intake) async {
    while (_amount < intake) {
      setState(() {
        _amount += 1;
      });

      await Future.delayed(Duration(microseconds: 5000));
    }
    while (intake < _amount) {
      setState(() {
        _amount -= 1;
      });
      await Future.delayed(Duration(microseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    var allSleepData = Provider.of<Map<String, List<SleepData>>>(context);
    var todayNaps = Provider.of<List<SleepData>>(context);
    var dataConnectionStatus = Provider.of<DataConnectionStatus>(context);
    UserData userData = Provider.of<UserData>(context) ??
        UserData(goal: 0, name: "new user", uid: "");
    var user = Provider.of<User>(context);
    var avgSleep = Provider.of<double>(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Stack(children: [
          Row(
            children: [
              RadialBarSleep(),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Column(
            children: [
              SizedBox(
                height: 200.0,
                child: Center(
                  child: Container(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: AmountCounter(true),
                        ),
                        Text(
                          "hrs",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  FlatButton(
                    child: Text("${(avgSleep * 100).round()} % completed",
                        style: TextStyle(fontWeight: FontWeight.normal)),
                    onPressed: () {
                      allSleepData.forEach((key, value) {
                        print("$key : $value");
                      });
                    },
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Row(children: [
                      Text(
                        "Goal ${userData.goal} ml",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18.0,
                      )
                    ]),
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ]),
      ),
      SizedBox(
        height: 1000.0,
        child: Placeholder(),
      )
    ]);
  }
}
