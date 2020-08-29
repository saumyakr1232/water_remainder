import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_recommender/model/sleepData.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'dart:async';

import 'package:water_recommender/services/utils.dart';

class DatabaseService {
  final String uid;
  final int sleepGoal;
  final int waterGoal;
  String _curDate =
      "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? DateTime.now().month.toString().padLeft(2, '0') : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? DateTime.now().day.toString().padLeft(2, '0') : DateTime.now().day}";
  DatabaseService({this.uid, this.waterGoal, this.sleepGoal});

  final CollectionReference userDataCollections =
      Firestore.instance.collection('userData');

  Future updateUserData(
    String name,
    int goal,
  ) async {
    return await userDataCollections.document(uid).setData(<String, dynamic>{
      'name': name,
      'goal': goal,
    }, merge: true).catchError((e) => print(e));
  }

  Future removeDailyDrinkData(List<WaterIntake> waterIntakes) async {
    // print("called updateDailyData with $waterIntakes");

    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "todayIntakes": FieldValue.arrayRemove(
          [for (var waterIntake in waterIntakes) waterIntake.toJson()])
    }, merge: true);
  }

  Future removeDailySleepData(List<SleepData> sleeps) async {
    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "sleepData":
          FieldValue.arrayRemove([for (var sleep in sleeps) sleep.toJson()])
    }, merge: true);
  }

  Future addDailyWaterData(WaterIntake waterIntake) async {
    // print("called updateDailyData with ${waterIntake.json()}");
    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "todayIntakes": FieldValue.arrayUnion([waterIntake.toJson()])
    }, merge: true);
  }

  Future addDailySleepData(SleepData sleep) async {
    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "sleepData": FieldValue.arrayUnion([sleep.toJson()])
    }, merge: true);
  }

  UserData _userDataFromSnapShot(DocumentSnapshot snapshot) {
    if (snapshot.data != null) {
      return UserData(
        uid: uid,
        goal: snapshot.data['goal'],
        name: snapshot.data['name'],
      );
    }
    return null;
  }

  List<WaterIntake> _dailyWaterDataFromSnapshot(DocumentSnapshot snapshot) {
    List<WaterIntake> intakes = [];
    List<dynamic> list = [];
    try {
      list = snapshot.data['todayIntakes'];
      if (list == null) {
        return [];
      }
    } catch (e) {
      print("Error _dailyDataFromSnapshot ${e.toString()}");
    }

    list.forEach((element) {
      intakes.add(WaterIntake.fromJson(element));
    });

    return intakes;
  }

  List<SleepData> _dailySleepDataFromSnapshot(DocumentSnapshot snapshot) {
    List<SleepData> naps = [];
    List<dynamic> list = [];
    try {
      list = snapshot.data['sleepData'];
      if (list == null) {
        return [];
      }
    } catch (e) {
      print("Error _dailyDataFromSnapshot ${e.toString()}");
    }

    list.forEach((element) {
      naps.add(SleepData.fromJson(element));
    });

    return naps;
  }

  //get UserData stream
  Stream<UserData> get userData {
    return userDataCollections
        .document(uid)
        .snapshots()
        .map(_userDataFromSnapShot);
  }

  //get Dalily Data strem

  Stream<List<WaterIntake>> get dailyIntake {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .snapshots()
        .map(_dailyWaterDataFromSnapshot);
  }

  Stream<Map<String, List<WaterIntake>>> get allWaterData {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .limit(30)
        .snapshots()
        .map(_allWaterDataFromQuerySnapshot);
  }

  Stream<Map<String, List<SleepData>>> get allSleepData {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .snapshots()
        .map(_allSleepDataFromQuerySnapshot);
  }

  Stream<List<SleepData>> get todaySleepData {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .snapshots()
        .map(_dailySleepDataFromSnapshot);
  }

  Stream<double> get avgSleep {
    return todaySleepData
        .map(Utils(sleepGoal: sleepGoal).getSleepGoalAchievedPercent);
  }

  Map<String, List<WaterIntake>> _allWaterDataFromQuerySnapshot(
      QuerySnapshot querySnapshot) {
    // print('Called _allDataFromQuerySnapshot $querySnapshot');
    List<DocumentSnapshot> snapshots = querySnapshot.documents;
    Map<String, List<WaterIntake>> map = {};
    for (DocumentSnapshot snapshot in snapshots) {
      map[snapshot.documentID] = _dailyWaterDataFromSnapshot(snapshot);
    }
    return map;
  }

  Map<String, List<SleepData>> _allSleepDataFromQuerySnapshot(
      QuerySnapshot querySnapshot) {
//    querySnapshot.documents.forEach((element) {
//      print(element.data);
//    });
    // print('Called _allDataFromQuerySnapshot $querySnapshot');
    List<DocumentSnapshot> snapshots = querySnapshot.documents;
    Map<String, List<SleepData>> map = {};
    for (DocumentSnapshot snapshot in snapshots) {
      map[snapshot.documentID] = _dailySleepDataFromSnapshot(snapshot);
    }
    return map;
  }
}
