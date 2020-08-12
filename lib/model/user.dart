import 'package:water_recommender/model/waterIntake.dart';

class User {
  final String uid;
  final int age;

  User({this.uid, this.age});
}

class UserData {
  final String uid;
  final String name;
  final double goal;
  final List<WaterIntake> todayIntakes;
  final List<WaterData> waterIntakeData;

  UserData(
      {this.uid,
      this.name,
      this.goal,
      this.todayIntakes,
      this.waterIntakeData});

  
}
