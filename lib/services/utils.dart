import 'dart:async';
import 'package:intl/intl.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Utils {
  int getTotalIntakeTodayFromListOfIntakes(List<WaterIntake> intakes) {
    int amount = 0;
    if (intakes != null) {
      for (WaterIntake intake in intakes) {
        amount += intake.amount;
      }
      return amount;
    }
    return amount;
  }

  double getGoalAchievedPercent(List<WaterIntake> intakes, int goal) {
    int amount = getTotalIntakeTodayFromListOfIntakes(intakes);
    if (amount / goal < 1.0) {
      return amount / goal;
    }

    if (intakes == null) {
      return 0;
    }
    return 1;
  }

  double getAverageIntake(Map<String, List<WaterIntake>> allData) {
    int totalDays = allData.values.length;
    int totalIntakeAmount = 0;

    for (List<WaterIntake> intakes in allData.values) {
      totalIntakeAmount += getTotalIntakeTodayFromListOfIntakes(intakes);
    }
    if (totalDays != 0) {
      return (totalIntakeAmount / totalDays);
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
      allTargeAchive += getGoalAchievedPercent(intakes, goal);
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

  List<MlPerDay> listOfMlperDay(Map<String, List<WaterIntake>> allData) {
    List<MlPerDay> list = [];
    allData.forEach((key, value) {
      list.add(MlPerDay(
          getTotalIntakeTodayFromListOfIntakes(value), key, Colors.indigo));
    });
    return list;
  }

  List<MlPerDay> listOfMlPerDayWeek(Map<String, List<WaterIntake>> allData) {
    List<MlPerDay> list = [];

    allData.forEach((key, value) {
      list.add(MlPerDay(
          getTotalIntakeTodayFromListOfIntakes(value), key, Colors.indigo));
    });
    int len = list.length;
    print("length of list $len");

    if (len > 7) {
      return list.sublist(list.length - 7);
    }
    if (len < 7) {
      int j = 7 - len;
      List<MlPerDay> updatedList = [];
      updatedList.addAll(list);
      for (int i = 0; i < j; i++) {
        updatedList.add(MlPerDay(
            0,
            DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day - i - 1)),
            Colors.indigo));
      }
      updatedList.sort((a, b) =>
          DateTime.parse(a.date).day.compareTo(DateTime.parse(b.date).day));

      updatedList.forEach((element) {
        print(element.date);
      });
      return updatedList;
    } else {
      return list;
    }
  }

  List<MlPerDay> listOfMlPerDayMonth(Map<String, List<WaterIntake>> allData) {
    List<MlPerDay> list = [];

    allData.forEach((key, value) {
      list.add(MlPerDay(
          getTotalIntakeTodayFromListOfIntakes(value), key, Colors.indigo));
    });
    int len = list.length;
    print("length of list $len");

    if (len > 30) {
      return list.sublist(list.length - 30);
    }
    if (len < 30) {
      int j = 30 - len;
      List<MlPerDay> updatedList = [];
      updatedList.addAll(list);
      for (int i = 0; i < j; i++) {
        updatedList.add(MlPerDay(
            0,
            DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day - i - 1)),
            Colors.indigo));
      }
      updatedList.sort((a, b) =>
          DateTime.parse(a.date).day.compareTo(DateTime.parse(b.date).day));

      updatedList.forEach((element) {
        print(element.date);
      });
      return updatedList;
    } else {
      return list;
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
