import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/screens/home/waterDrinkingRecords.dart';
import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/services/database.dart';
import 'package:water_recommender/services/utils.dart';

import 'addDrinkBottomSheet.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).userData,
        ),
        StreamProvider.value(value: DatabaseService(uid: user.uid).dailyIntake),
      ],
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScrollStarted = false;
  bool isScrollOnStart = true;
  ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      isScrollStarted = true;
      isScrollOnStart = false;
    });
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        isScrollOnStart = false;
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        isScrollOnStart = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthServices _auth = AuthServices();
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.indigo.shade200, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.center,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor:
              isScrollOnStart ? Colors.transparent : Colors.indigo.shade300,
          elevation: 0.0,
          title: Text(
            "Drink Water",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24.0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.black,
              onPressed: () {
                _auth.signOut();
              },
              iconSize: 24.0,
            ),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              _onStartScroll(scrollNotification.metrics);
            }

            return true;
          },
          child: SingleChildScrollView(
            controller: _controller,
            child: HomePageContent(),
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int amount = 0;

  Future setAmount(int intake) async {
    print("intake $intake");
    while (amount < intake) {
      setState(() {
        amount += 1;
      });

      await Future.delayed(Duration(microseconds: 500));
    }
    while (intake < amount) {
      setState(() {
        amount -= 1;
      });
      await Future.delayed(Duration(microseconds: 500));
    }
  }

  List<bool> isSelected = [true, false];

  double percentGoalAchieved = 0.0;
  bool _isUpdating = false;
  bool _waveIsAdded = false;

  @override
  Widget build(BuildContext context) {
    void _showRecordDringkSheet() {
      showModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: RecordDrinkPage());
          });
    }

    UserData userData = Provider.of<UserData>(context) ??
        UserData(goal: 0, name: "new user", uid: "");
    final intakes = Provider.of<List<WaterIntake>>(context);
    setState(() {
      percentGoalAchieved =
          Utils().getGoalAchievedPercent(intakes, userData.goal);
      print(percentGoalAchieved);
    });
    setAmount(Utils().getTotalIntakeTodayFromListOfIntakes(intakes));

    var children2 = [
      //TODO: add another wave
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
                        Icon(Icons.report,
                            size: 18.0, color: Colors.indigo.shade700),
                        SizedBox(width: 4.0),
                        Text(
                          "Drink some Water ${userData.name.toUpperCase()}",
                          style: TextStyle(
                              color: Colors.indigo.shade600,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(width: 8.0),
                        Icon(Icons.arrow_forward_ios,
                            size: 15.0, color: Colors.indigo.shade600)
                      ],
                    ),
                  )),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Text(
            amount.toString(),
            style: TextStyle(color: Colors.indigo.shade800, fontSize: 90.0),
          ),
          Row(
            children: [
              FlatButton(
                child: Text(
                    "${(percentGoalAchieved * 100).round()} % completed",
                    style: TextStyle(fontWeight: FontWeight.normal)),
                onPressed: () {},
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
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
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          SizedBox(
            height: 80.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildClipOval(50),
              buildClipOval(150),
              buildClipOval(200),
              buildClipOval(250),
              buildClipOval(300)
            ],
          ),
        ],
      ),
    ];

    void addWave() {
      print("addWave called");
      setState(() {
        children2 = children2
          ..insert(
              1,
              Opacity(
                opacity: 0.8,
                child: LiquidLinearProgressIndicator(
                  value: percentGoalAchieved,
                  direction: Axis.vertical,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(Colors.red.shade200),
                ),
              ));
      });
      print(children2);
    }

    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Stack(children: children2),
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
                  onPressed: _showRecordDringkSheet,
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
                              Text("Today's water drinking records"),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  print("called");
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WaterRecordPage()));
                                },
                              )
                            ],
                          ),
                          AbsorbPointer(
                            child: Container(
                              height: intakes != null && intakes.length > 3
                                  ? 3 * 56.0
                                  : intakes != null ? intakes.length * 56.0 : 0,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text("${intakes[index].drinkType}"),
                                    leading: _getDrinkIcon(index, intakes),
                                    trailing: Text("${intakes[index].time}"),
                                  );
                                },
                                itemCount: intakes != null
                                    ? intakes.length > 3 ? 3 : intakes.length
                                    : 0,
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
                SizedBox(
                  height: 40.0,
                  child: ToggleButtons(
                    children: [
                      Padding(
                        child: Text("Past 7 days"),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                      ),
                      Padding(
                        child: Text("Last month"),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                      ),
                    ],
                    borderColor: Colors.indigo.shade400,
                    disabledBorderColor: Colors.indigo.shade400,
                    selectedBorderColor: Colors.indigo.shade400,
                    fillColor: Colors.indigo.shade400,
                    color: Colors.indigo.shade400,
                    selectedColor: Colors.white,
                    isSelected: isSelected,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    onPressed: (int index) {
                      setState(() {
                        isSelected = isSelected.reversed.toList();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "750",
                                style: TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text("ml/days",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal))
                            ],
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                          ),
                          Text(
                            "Average water \nintake",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "2",
                                style: TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text("times per day",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal))
                            ],
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                          ),
                          Text(
                            "Average \nfrequency of \nwater intake",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text("%",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal))
                            ],
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                          ),
                          Text(
                            "Target \nachievement rate",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                    ],
                  ),
                ),
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

  Widget buildClipOval(int capacity) {
    var user = Provider.of<User>(context);
    return !_isUpdating
        ? Opacity(
            opacity: 0.8,
            child: GestureDetector(
              onTap: () async {
                print(DateTime.now().toString());
                setState(() {
                  _isUpdating = true;
                });

                await DatabaseService(uid: user.uid).updateDailyData(WaterIntake(
                    amount: capacity,
                    time:
                        "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
                    drinkType: "water",
                    calories: 0));

                setState(() {
                  _isUpdating = false;
                });
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
          )
        : CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
          );
  }
}
