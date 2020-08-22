import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/database.dart';

class DrinkingRecord extends StatelessWidget {
  final List<WaterIntake> intakes;
  DrinkingRecord({this.intakes});
  @override
  Widget build(BuildContext context) {
    return WaterRecordPage(
      intakes: intakes,
    );
  }
}

class WaterRecordPage extends StatefulWidget {
  final List<WaterIntake> intakes;
  WaterRecordPage({this.intakes});
  @override
  _WaterRecordPageState createState() =>
      _WaterRecordPageState(intakes: intakes);
}

class _WaterRecordPageState extends State<WaterRecordPage> {
  bool _isEditModeOn = false;
  bool _canShowSelectAll = true;
  bool isScrollStarted = false;
  bool isScrollOnStart = true;
  ScrollController _controller;
  List<bool> _selectedForEdit = [];

  List<WaterIntake> intakes;
  _WaterRecordPageState({this.intakes});

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
    final User user = Provider.of<User>(context);
    int sizeOfIntakesList = intakes.length;
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).dailyIntake,
        ),
        StreamProvider.value(value: DatabaseService(uid: user.uid).userData)
      ],
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade400, Colors.white])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor:
                isScrollOnStart ? Colors.transparent : Colors.indigo.shade400,
            elevation: 0.0,
            title: Text(
              "Today's data",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),
            ),
            actions: [
              _isEditModeOn
                  ? FlatButton(
                      onPressed: () {
                        setState(() {
                          _isEditModeOn = !_isEditModeOn;
                        });
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : FlatButton(
                      onPressed: () {
                        setState(() {
                          _isEditModeOn = !_isEditModeOn;
                        });
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
            ],
            leading: _isEditModeOn
                ? _canShowSelectAll
                    ? FlatButton(
                        onPressed: () {
                          setState(() {
                            _selectedForEdit = [
                              for (var i = 0; i < sizeOfIntakesList; i++) true
                            ];
                            _canShowSelectAll = !_canShowSelectAll;
                          });
                        },
                        child: Text(
                          "all",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                    : FlatButton(
                        padding: EdgeInsets.all(4.0),
                        onPressed: () {
                          setState(() {
                            _selectedForEdit = [
                              for (var i = 0; i < sizeOfIntakesList; i++) false
                            ];
                            _canShowSelectAll = !_canShowSelectAll;
                          });
                        },
                        child: Text(
                          "Deselect all",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.0),
                        ),
                      )
                : IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollStartNotification) {
                _onStartScroll(scrollNotification.metrics);
              }

              return true;
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: MultiProvider(
                providers: [
                  Provider.value(
                    value: _isEditModeOn,
                  ),
                  Provider.value(
                    value: _selectedForEdit,
                  ),
                ],
                child: ListOfDrinks(),
              ),
              controller: _controller,
            ),
          ),
          floatingActionButton: _isEditModeOn
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    print(_selectedForEdit);
                    print(intakes.length);
                    List<WaterIntake> updatedIntake = [];
                    List<bool> updatedSelectedForEdit = [];
                    setState(() {
                      sizeOfIntakesList = intakes.length;
                      for (var i = 0; i < intakes.length; i++) {
                        print("value outside  $i");
                        if (!_selectedForEdit[i]) {
                          print("value of $i");
                          updatedIntake.add(intakes[i]);
                          updatedSelectedForEdit.add(_selectedForEdit[i]);
                        }
                      }
                    });
                    print(intakes.length);
                    print("$updatedSelectedForEdit vs old $_selectedForEdit");
                    await DatabaseService(uid: user.uid)
                        .updateDailyData(updatedIntake);
                    setState(() {
                      _selectedForEdit = updatedSelectedForEdit;
                      intakes = updatedIntake;
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  label: Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(Icons.delete_outline),
                  backgroundColor: Colors.indigo.shade200,
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class ListOfDrinks extends StatefulWidget {
  @override
  _ListOfDrinksState createState() => _ListOfDrinksState();
}

class _ListOfDrinksState extends State<ListOfDrinks> {
  @override
  Widget build(BuildContext context) {
    final intakes = Provider.of<List<WaterIntake>>(context);
    final _isEditModeOn = Provider.of<bool>(context);
    final userData = Provider.of<UserData>(context);
    double _percentOfGoal = 0.0;
    List<bool> _selectedForEdit = Provider.of<List<bool>>(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          _percentOfGoal = intakes[index].amount / userData.goal;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: SizedBox(
                      height: 72.0,
                      child: LiquidLinearProgressIndicator(
                        value: _percentOfGoal,
                        direction: Axis.horizontal,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.indigo.shade200),
                      ),
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.transparent,
                    trailing: Text(intakes[index]
                        .time
                        .substring(0, intakes[index].time.lastIndexOf(':'))),
                    subtitle: Text("${intakes[index].amount}"),
                    leading: _isEditModeOn
                        ? Checkbox(
                            value: _selectedForEdit.isEmpty
                                ? false
                                : _selectedForEdit.length == intakes.length
                                    ? _selectedForEdit[index]
                                    : false,
                            onChanged: (_) {
                              setState(() {
                                _selectedForEdit.isEmpty
                                    ? _selectedForEdit.addAll(
                                        intakes.map((e) => false).toList())
                                    : _selectedForEdit[index] =
                                        !_selectedForEdit[index];
                              });
                            },
                          )
                        : IconButton(
                            icon: _getDrinkIcon(index, intakes),
                            onPressed: () {},
                          ),
                    title: Text(intakes[index].drinkType),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: intakes == null ? 0 : intakes.length,
      ),
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
