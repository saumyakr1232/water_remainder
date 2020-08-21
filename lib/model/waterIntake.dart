import 'dart:convert';


class WaterIntake {
  final int amount;
  final String time;

  WaterIntake({this.amount, this.time});

  Map toJson() {
    return {
      "amount": amount,
      "time": time,
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> map) {
    // final map = jsonDecode(json) as Map<String, dynamic>;
    return WaterIntake(
        amount: map['amount'] as int, time: map['time'] as String);
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
        isGoalAchieved: map['isGoalAchieved']as bool);
  }
}



