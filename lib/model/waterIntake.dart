import 'dart:convert';

class WaterIntake {
  final int amount;
  final String time;
  final String drinkType;
  final int calories;

  WaterIntake({this.amount, this.time, this.drinkType, this.calories});

  Map toJson() {
    return {
      "amount": amount,
      "time": time,
      "drinkType": drinkType,
      "calories": calories
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> map) {
    // final map = jsonDecode(json) as Map<String, dynamic>;
    return WaterIntake(
        amount: map['amount'] as int, time: map['time'] as String, drinkType: map['drinkType'] as String , calories: map['calories'] as int);
  }

  String json() {
    return jsonEncode(this);
  }
}

class WaterData {
  final double goal;
  final double intake;
  final String date;
  final bool isGoalAchieved;

  WaterData({this.goal, this.intake, this.date, this.isGoalAchieved});

  Map toJson() {
    return {
      'goal': goal,
      'intake': intake,
      'date': date,
      'isGoalAchieved': isGoalAchieved
    };
  }

  String json() {
    return jsonEncode(this);
  }

  factory WaterData.fromJson(Map<String, dynamic> map) {
    // final map = jsonDecode(json) as Map<String, dynamic>;
    return WaterData(
        goal: map['goal'] as double,
        intake: map['intake'] as double,
        date: map['date'] as String,
        isGoalAchieved: map['isGoalAchieved'] as bool);
  }
}
