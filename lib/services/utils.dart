import 'dart:async';
import 'dart:math';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Utils {
  final int sleepGoal;
  Utils({this.sleepGoal});
  static int _initialIntakeAmount = 0;
  static int _initialSleepAmount = 0;

  static void setAmount(int amount, bool isSleep) {
    if (isSleep) {
      _initialSleepAmount = amount;
    }
    _initialIntakeAmount = amount;
  }

  int getAmount(bool isSleep) {
    if (isSleep) {
      return _initialSleepAmount;
    }
    return _initialIntakeAmount;
  }

  int getTotalIntakeToday(List<WaterIntake> intakes, {String drinkType}) {
    int amount = 0;
    if (intakes != null && drinkType == null) {
      for (WaterIntake intake in intakes) {
        amount += intake.amount;
      }
      return amount;
    }
    if (intakes != null && drinkType != null) {
      for (WaterIntake intake
          in intakes.where((element) => element.drinkType == drinkType)) {
        amount += intake.amount;
      }
      return amount;
    }

    return amount;
  }

  int getTotalSleepToday(List<SleepData> naps) {
    int amount = 0;
    if (naps != null) {
      naps.forEach((element) {
        amount += element.duration;
      });
      return amount;
    }
    return amount;
  }

  double getWaterGoalAchievedPercent(List<WaterIntake> intakes, int goal) {
    int amount = getTotalIntakeToday(intakes);
    if (amount / goal < 1.0) {
      return amount / goal;
    }

    if (intakes == null) {
      return 0;
    }
    return 1.0;
  }

  double getSleepGoalAchievedPercent(List<SleepData> sleeps) {
    int amount = getTotalSleepToday(sleeps);
    if (amount / sleepGoal < 1.0) {
      return amount / sleepGoal;
    }

    if (sleeps == null) {
      return 0;
    }
    return 1.0;
  }

  double getAverageIntake(Map<String, List<WaterIntake>> allData) {
    int totalDays = allData.values.length;
    int totalIntakeAmount = 0;

    for (List<WaterIntake> intakes in allData.values) {
      totalIntakeAmount += getTotalIntakeToday(intakes);
    }
    if (totalDays != 0) {
      return (totalIntakeAmount / totalDays);
    }
    return 0;
  }

  double getAverageSleep(Map<String, List<SleepData>> allData) {
    int totalDays = allData.values.length;
    double totalSleepAmount = 0;

    for (List<SleepData> sleeps in allData.values) {
      totalSleepAmount += getTotalSleepToday(sleeps);
    }
    if (totalDays != 0) {
      return (totalSleepAmount / totalDays);
    }
    return 0;
  }

  double getFrequencyOfIntakePerDay(Map<String, List<WaterIntake>> allData) {
    int totalDays = allData.values.length;
    int totalIntakes = 0;

    for (List<WaterIntake> intakes in allData.values) {
      totalIntakes += intakes.length;
    }

    if (totalDays == 0) {
      return 0;
    }
    return totalIntakes / totalDays;
  }

  double getTargetAchievementRate(
      Map<String, List<WaterIntake>> allData, int goal) {
    int totalDays = allData.length;
    double allTargeAchive = 0.0;
    for (List<WaterIntake> intakes in allData.values) {
      allTargeAchive += getWaterGoalAchievedPercent(intakes, goal);
    }
    if (totalDays == 0) {
      return 0;
    }
    return allTargeAchive / totalDays;
  }

  Map<String, List<WaterIntake>> getInitialAllData() {
    return {
      "2020-08-11": [
        WaterIntake(amount: 0, time: "00:00", drinkType: "water", calories: 0)
      ]
    };
  }

  List<WaterIntake> getIntialIntakeData() {
    return [
      WaterIntake(amount: 0, time: "00:00", drinkType: "water", calories: 0)
    ];
  }

  // List<MlPerDay> listOfMlperDay(Map<String, List<WaterIntake>> allData) {
  //   List<MlPerDay> list = [];
  //   allData.forEach((key, value) {
  //     list.add(MlPerDay(
  //         getTotalIntakeTodayFromListOfIntakes(value), key, Colors.indigo));
  //   });
  //   return list;
  // }

  List<MlPerDay> listOfMlPerDay(
      Map<String, List<WaterIntake>> allData, String drinkType, bool forMonth) {
    List<MlPerDay> list = [];
    int days = forMonth ? 30 : 7;
    allData.forEach((key, value) {
      list.add(MlPerDay(getTotalIntakeToday(value, drinkType: drinkType), key,
          getDrinkColor(drinkType)));
    });
    int len = list.length;
    // print("length of list $len");

    if (len > days) {
      return list.sublist(list.length - 7);
    }
    if (len < days) {
      int j = days - len;
      List<MlPerDay> updatedList = [];
      updatedList.addAll(list);
      for (int i = 0; i < j; i++) {
        updatedList.add(MlPerDay(
            0,
            DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day - i - 1)),
            Colors.indigo));
      }
      updatedList.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

      // updatedList.forEach((element) {
      //   print(element.date);
      // });
      return updatedList;
    } else {
      return list;
    }
  }

  List<MinPerDay> listOfMinPerDay(
      Map<String, List<SleepData>> allData, bool forMonth) {
    List<MinPerDay> list = [];
    int days = forMonth ? 30 : 7;
    allData.forEach((key, value) {
      list.add(MinPerDay(getTotalSleepToday(value), key));
    });
    int len = list.length;
    // print("length of list $len");

    if (len > days) {
      return list.sublist(list.length - 7);
    }
    if (len < days) {
      int j = days - len;
      List<MinPerDay> updatedList = [];
      updatedList.addAll(list);
      for (int i = 0; i < j; i++) {
        updatedList.add(MinPerDay(
            0,
            DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day - i - 1))));
      }
      updatedList.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

      // updatedList.forEach((element) {
      //   print(element.date);
      // });
      return updatedList;
    } else {
      return list;
    }
  }

  List<MinPerDay> listOfMinAwakePerDay(
      Map<String, List<SleepData>> allData, bool forMonth) {
    List<MinPerDay> list = [];
    int days = forMonth ? 30 : 7;
    allData.forEach((key, value) {
      list.add(MinPerDay(getTotalSleepToday(value), key));
    });
    int len = list.length;
    // print("length of list $len");

    if (len > days) {
      return list.sublist(list.length - 7);
    }
    if (len < days) {
      int j = days - len;
      List<MinPerDay> updatedList = [];
      updatedList.addAll(list);
      for (int i = 0; i < j; i++) {
        updatedList.add(MinPerDay(
            1440,
            DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day - i - 1))));
      }
      updatedList.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

      // updatedList.forEach((element) {
      //   print(element.date);
      // });
      return updatedList;
    } else {
      return list;
    }
  }

  Color getDrinkColor(String type) {
    switch (type) {
      case "soda":
        {
          return Colors.green.shade300;
        }
      case "coffee":
        {
          return Colors.brown.shade500;
        }
      case "tea":
        {
          return Colors.brown.shade300;
        }
      case "juice":
        {
          return Colors.deepOrange.shade300;
        }

      default:
        {
          return Colors.blue.shade300;
        }
    }
  }
}

class DataConnectivityService {
  StreamController<DataConnectionStatus> connectivityStreamController =
      StreamController<DataConnectionStatus>();

  DataConnectivityService() {
    DataConnectionChecker().onStatusChange.listen((dataConnectionStatus) {
      connectivityStreamController.add(dataConnectionStatus);
    });
  }
}

class MlPerDay {
  final String date;
  final int amount;
  final charts.Color color;

  MlPerDay(this.amount, this.date, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
// "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? DateTime.now().month.toString().padLeft(2, '0') : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? (DateTime.now().day - i - 1).toString().padLeft(2, '0') : DateTime.now().day - i - 1}"

class UniqueColorGenerator {
  static Random random = new Random();
  static Color getColor() {
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }
}

class MinPerDay {
  final String date;
  final int duration;
  final Color color;

  MinPerDay(this.duration, this.date, {this.color});
}
