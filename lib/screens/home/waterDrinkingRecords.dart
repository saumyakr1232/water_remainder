import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/database.dart';

class DrinkingRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaterRecordPage();
  }
}

class WaterRecordPage extends StatefulWidget {
  @override
  _WaterRecordPageState createState() => _WaterRecordPageState();
}

class _WaterRecordPageState extends State<WaterRecordPage> {
  bool _isEditModeOn = false;
  bool _canShowSelectAll = true;
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
    final User user = Provider.of<User>(context);

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
              "Drink Water",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    setState(() {
                      _isEditModeOn = !_isEditModeOn;
                    });
                  },
                  child: Text("Edit"))
            ],
            leading: _isEditModeOn
                ? _canShowSelectAll
                    ? FlatButton(
                        onPressed: () {},
                        child: Text(
                          "all",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                    : FlatButton(
                        onPressed: () {},
                        child: Text(
                          "- all",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
              child: Provider.value(
                child: ListOfDrinks(),
                value: _isEditModeOn,
              ),
              controller: _controller,
            ),
          ),
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
  List<bool> _selectedForEdit = [];

  @override
  Widget build(BuildContext context) {
    final intakes = Provider.of<List<WaterIntake>>(context);
    final _isEditModeOn = Provider.of<bool>(context);
    final userData = Provider.of<UserData>(context);
    double _percentOfGoal = 0.0;
    return SizedBox(
      height: 800,
      child: ListView.builder(
        itemBuilder: (context, index) {
          _percentOfGoal = intakes[index].amount / userData.goal;
          print(_percentOfGoal);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: SizedBox(
                      height: 60.0,
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
                    leading: _isEditModeOn
                        ? Checkbox(
                            value: _selectedForEdit.isEmpty
                                ? false
                                : _selectedForEdit[index],
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
                        : _getDrinkIcon(index, intakes),
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
