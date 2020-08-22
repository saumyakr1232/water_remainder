import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/database.dart';

class RecordDrinkPage extends StatefulWidget {
  @override
  _RecordDrinkPageState createState() => _RecordDrinkPageState();
}

class _RecordDrinkPageState extends State<RecordDrinkPage> {
  int _currentCapacity = 25;
  var _isCardSelected = [false, false, false, false, false];
  var _selectedDrinkType = "";
  var _calories = 0;
  var amount = 0;
  TimeOfDay _time = TimeOfDay.now();
  Map<String, int> _caloriesContent = {
    "water": 0,
    "coffee": 10,
    "tea": 12,
    "soda": 20,
    "juice": 30
  };
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Please select type of drink"),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                      color: _isCardSelected[0]
                          ? Colors.indigo.shade500
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      elevation: 2.0,
                      child: IconButton(
                        icon: Icon(
                          SimpleLineIcons.drop,
                          color: _isCardSelected[0]
                              ? Colors.white
                              : Colors.indigo.shade500,
                        ),
                        onPressed: () {
                          _toggleButtons(0);
                          setState(() {
                            _selectedDrinkType = "water";
                            _calories =
                                (_caloriesContent[_selectedDrinkType] * amount)
                                    .round();
                          });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Water",
                      style: TextStyle(color: Colors.indigo.shade500),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Card(
                    color: _isCardSelected[1]
                        ? Colors.indigo.shade500
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    elevation: 2.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.local_cafe_outlined,
                        color: _isCardSelected[1]
                            ? Colors.white
                            : Colors.indigo.shade500,
                      ),
                      onPressed: () {
                        _toggleButtons(1);
                        setState(() {
                          _selectedDrinkType = "coffee";
                          _calories =
                              (_caloriesContent[_selectedDrinkType] * amount)
                                  .round();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Coffee",
                      style: TextStyle(color: Colors.indigo.shade500),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Card(
                      color: _isCardSelected[2]
                          ? Colors.indigo.shade500
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      elevation: 2.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.emoji_food_beverage_outlined,
                          color: _isCardSelected[2]
                              ? Colors.white
                              : Colors.indigo.shade500,
                        ),
                        onPressed: () {
                          _toggleButtons(2);
                          setState(() {
                            _selectedDrinkType = "tea";
                            _calories =
                                (_caloriesContent[_selectedDrinkType] * amount)
                                    .round();
                          });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Tea",
                      style: TextStyle(color: Colors.indigo.shade500),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Card(
                      color: _isCardSelected[3]
                          ? Colors.indigo.shade500
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      elevation: 2.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.local_drink_outlined,
                          color: _isCardSelected[3]
                              ? Colors.white
                              : Colors.indigo.shade500,
                        ),
                        onPressed: () {
                          _toggleButtons(3);
                          setState(() {
                            _selectedDrinkType = "soda";
                            _calories =
                                (_caloriesContent[_selectedDrinkType] * amount)
                                    .round();
                          });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Soda",
                      style: TextStyle(color: Colors.indigo.shade500),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Card(
                      color: _isCardSelected[4]
                          ? Colors.indigo.shade500
                          : Colors.white,
                      key: UniqueKey(),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      elevation: 2.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.local_bar_outlined,
                          color: _isCardSelected[4]
                              ? Colors.white
                              : Colors.indigo.shade500,
                        ),
                        onPressed: () {
                          _toggleButtons(4);
                          setState(() {
                            _selectedDrinkType = "juice";
                            _calories =
                                (_caloriesContent[_selectedDrinkType] * amount)
                                    .round();
                          });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Juice",
                      style: TextStyle(color: Colors.indigo.shade500),
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text("Please select volume of drink"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
            child: Text(
              "$_currentCapacity ml",
              style: TextStyle(color: Colors.indigo.shade400, fontSize: 32.0),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(AntDesign.minuscircleo),
                  onPressed: () {
                    if (_currentCapacity >= 50) {
                      setState(() {
                        _currentCapacity -= 25;
                        amount -= 25;
                        _calories -=
                            (_caloriesContent[_selectedDrinkType] * 25).round();
                      });
                    }
                  }),
              Expanded(
                child: Slider(
                  value: _currentCapacity.toDouble(),
                  activeColor: Colors.indigo[400],
                  inactiveColor: Colors.indigo[300],
                  min: 25,
                  max: 2000,
                  divisions: 79,
                  onChanged: (val) {
                    setState(() {
                      _calories =
                          (_caloriesContent[_selectedDrinkType] * val).round();
                      amount = val.round();
                      return _currentCapacity = val.round();
                    });
                  },
                ),
              ),
              IconButton(
                  icon: Icon(AntDesign.pluscircleo),
                  onPressed: () {
                    if (_currentCapacity <= 1975) {
                      setState(() {
                        _currentCapacity += 25;
                        amount += 25;
                        _calories +=
                            (_caloriesContent[_selectedDrinkType] * 25).round();
                      });
                    }
                  }),
            ],
          ),
          Text("Contains approximately $_calories kcal"),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(showPicker(
                  context: context, value: _time, onChange: _onTimeChanged));
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(child: Text("Drank at")),
                    Text("${_time.hour}:${_time.minute}",
                        style: TextStyle(color: Colors.indigo.shade200)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Colors.grey.shade500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: FlatButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.indigo.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.indigo.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0),
                    ),
                    onPressed: () async {
                      await _updateData(user);
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  Future _updateData(User user) async {
    return DatabaseService(uid: user.uid).updateDailyData(WaterIntake(
        amount: _currentCapacity,
        time: "${_time.hour}:${_time.minute}",
        drinkType: _selectedDrinkType,
        calories: _calories));
  }

  void _toggleButtons(int index) {
    // print("On called $_isCardSelected");
    setState(() {
      _isCardSelected[index] = !_isCardSelected[index];
      for (int i = 0; i < 5; i++) {
        if (i != index) {
          _isCardSelected[i] = false;
        }
      }
    });
    // print("On exit $_isCardSelected");
  }

  void _onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }
}
