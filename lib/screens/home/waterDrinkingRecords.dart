import 'dart:ui';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  List<WaterIntake> intakes;
  _WaterRecordPageState({this.intakes});

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
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text(
              "Today's data",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: ListOfDrinks(),
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
  WaterIntake recentlyDeleted;
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    final intakes = Provider.of<List<WaterIntake>>(context);
    final userData = Provider.of<UserData>(context);
    double _percentOfGoal = 0.0;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          _percentOfGoal = intakes[index].amount / userData.goal;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Slidable(
              actionPane: SlidableBehindActionPane(),
              secondaryActions: [
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.redAccent,
                  icon: Icons.delete,
                  onTap: () {
                    recentlyDeleted = intakes[index];
                    DatabaseService(uid: user.uid)
                        .removeDailyDrinkData([intakes[index]]);
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                              "${intakes[index].amount} ml ${intakes[index].drinkType.toUpperCase()} removed"),
                        ),
                        Expanded(
                            flex: 1,
                            child: FlatButton(
                              onPressed: () {
                                DatabaseService(uid: user.uid)
                                    .addDailyWaterData(recentlyDeleted);
                              },
                              child: Text(
                                "Undo",
                                style: TextStyle(color: Colors.lightGreen),
                              ),
                            ))
                      ],
                    )));
                  },
                )
              ],
              key: UniqueKey(),
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
                      leading: IconButton(
                        icon: _getDrinkIcon(index, intakes),
                        onPressed: () {},
                      ),
                      title: Text(intakes[index].drinkType),
                    ),
                  ],
                ),
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
