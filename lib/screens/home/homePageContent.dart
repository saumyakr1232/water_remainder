import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/screens/home/graph.dart';
import 'package:water_recommender/screens/home/waterDrinkingRecords.dart';
import 'package:water_recommender/services/database.dart';
import 'package:water_recommender/services/utils.dart';
import 'package:water_recommender/shared/constants.dart';
import '../commonWidgets.dart';
import 'addDrinkBottomSheet.dart';
import 'package:intl/intl.dart';

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _avgWaterIntake;
  int _avgFreqIntake;
  int _targetAchieveRate;
  double percentGoalAchieved;
  UserData userData;
  List<Widget> firstChildren = [];

  Future<void> _showModifyWaterGoalDialog(BuildContext context) async {
    // var _controller = TextEditingController(text:"${userData.goal}");
    int newGoal = userData.goal;
    return showDialog<void>(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return AlertDialog(
            title: Text("Daily target"),
            content: TextFormField(
              autofocus: true,
              decoration: textInputDecoration.copyWith(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                ),
              ),
              cursorColor: Colors.indigo,
              textAlignVertical: TextAlignVertical.bottom,
              initialValue: "${userData.goal}",
              onChanged: (value) {
                newGoal = int.parse(value);
                print(newGoal);
              },
              keyboardType: TextInputType.numberWithOptions(
                  signed: false, decimal: false),
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () async {
                  print(newGoal);
                  Navigator.pop(context);
                  await DatabaseService(uid: userData.uid)
                      .updateUserData(userData.name, newGoal);
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  void _showRecordDrinkSheet() {
    showModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) {
          return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: RecordDrinkPage());
        });
  }

  @override
  Widget build(BuildContext context) {
    print("called build ");

//    print("Called from _homePageContentState");
//    var dataConnectionStatus = Provider.of<DataConnectionStatus>(context);
    var allSleepData = Provider.of<Map<String, List<SleepData>>>(context);
    var allWaterData = Provider.of<Map<String, List<WaterIntake>>>(context);
    userData = Provider.of<UserData>(context) ??
        UserData(goal: 0, name: "new user", uid: ""); // TODO: fix this

    final List<WaterIntake> intakes = Provider.of<List<WaterIntake>>(context);

    percentGoalAchieved =
        Utils().getWaterGoalAchievedPercent(intakes, userData.goal);
    _avgWaterIntake = Utils().getAverageIntake(allWaterData).round();
    _avgFreqIntake = Utils().getFrequencyOfIntakePerDay(allWaterData).round();
    _targetAchieveRate =
        (Utils().getTargetAchievementRate(allWaterData, userData.goal) * 100)
            .round();

    // This widget will cover the half of the screen
    firstChildren = [
      LiquidLinearProgressIndicator(
        value: percentGoalAchieved,
        direction: Axis.vertical,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(Colors.indigo.shade200),
      ),
      Column(
        children: [
          Row(
            children: [
              FlatButton(
                  onPressed: () {},
                  child: Container(
                    child: Row(
                      children: [
                        Text(
                          "Drink some Water ${userData.name.toUpperCase()}",
                          style: TextStyle(
                              color: Colors.indigo.shade600,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  )),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          AmountCounter(false),
          Row(
            children: [
              FlatButton(
                child: Text(
                    "${(percentGoalAchieved * 100).round()} % completed",
                    style: TextStyle(fontWeight: FontWeight.normal)),
                onPressed: () {
                  _showModifyWaterGoalDialog(context);
                },
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
              ),
              FlatButton(
                onPressed: () {
                  _showModifyWaterGoalDialog(context);
                },
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
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          SizedBox(
            height: 80.0,
          ),
          Cups()
        ],
      ),
    ];
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Stack(children: firstChildren),
        ),

        SizedBox(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.indigo.shade200, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.center,
            )),
            child: Column(
              children: [
                FlatButton(
                  height: 35.0,
                  onPressed: _showRecordDrinkSheet,
                  child: Text(
                    "Record drink",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 2.0, horizontal: 32.0),
                  color: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                WaterRecordPage(
                                                  intakes: intakes,
                                                )));
                                  },
                                  child:
                                      Text("Today's water drinking records")),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WaterRecordPage(
                                            intakes: intakes,
                                          )));
                                },
                              )
                            ],
                          ),
                          AbsorbPointer(
                            child: Container(
                              height: intakes.length > 3
                                  ? 3 * 56.0
                                  : intakes.length * 56.0,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text("${intakes[index].drinkType}"),
                                    leading: _getDrinkIcon(index, intakes),
                                    trailing: Text("${intakes[index].time}"),
                                  );
                                },
                                itemCount:
                                    intakes.length > 3 ? 3 : intakes.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                SizedBox(height: 35.0, child: CustomToggleButton()),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$_avgFreqIntake",
                                  style: TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                Text("times/day",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                            ),
                            Text(
                              "Average \nfrequency of \nwater intake",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              "$_avgWaterIntake",
                              style: TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text("ml/days",
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(fontWeight: FontWeight.normal)),
                            Text(
                              "Average water \nintake",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$_targetAchieveRate",
                                  style: TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                Text("%",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                            ),
                            Text(
                              "Target \nachievement \nrate",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        ),
                      ),
                    ],
                  ),
                ),
                const GraphView(),
              ],
            ),
          ),
        ),
        // Test(),
      ]),
    );
  }

  Icon _getDrinkIcon(int index, List<WaterIntake> intakes) {
    switch (intakes[index].drinkType) {
      case "soda":
        {
          return Icon(
            Icons.local_drink_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "coffee":
        {
          return Icon(
            Icons.local_cafe_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "tea":
        {
          return Icon(
            Icons.emoji_food_beverage_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "juice":
        {
          return Icon(
            Icons.local_bar_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }

      default:
        {
          return Icon(
            SimpleLineIcons.drop,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
    }
  }
}

class Cups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    print("Called from Cups");
    final User user = Provider.of<User>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildClipOval(50, user),
        buildClipOval(150, user),
        buildClipOval(200, user),
        buildClipOval(250, user),
        buildClipOval(300, user)
      ],
    );
  }

  Widget buildClipOval(int capacity, User user) {
    return Opacity(
      opacity: 0.8,
      child: GestureDetector(
        onTap: () {
          DatabaseService(uid: user.uid).addDailyWaterData(
            WaterIntake(
                amount: capacity,
                time: "${DateFormat.Hms().format(DateTime.now())}",
                drinkType: "water",
                calories: 0),
          );
//          DatabaseService(uid: user.uid).addDailySleepData(SleepData(
//              duration: 120,
//              startTime: "${DateFormat.Hms().format(DateTime.now())}"));
        },
        child: Card(
          color: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  SimpleLineIcons.drop,
                  color: Colors.indigo.shade500,
                  size: 16.0,
                ),
                Text(
                  capacity.toString(),
                  style: TextStyle(
                      color: Colors.indigo.shade500,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
