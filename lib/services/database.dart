import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';

import 'package:water_recommender/model/waterIntake.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userDataCollections =
      Firestore.instance.collection('userData');

  Future updateUserData(
    String name,
    double goal,
  ) async {
    return await userDataCollections.document(uid).setData(<String, dynamic>{
      'name': name,
      'goal': goal,
    }).catchError((e) => print(e));
  }

  Future updateDailyData(WaterIntake waterIntake) async {
    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document("today")
        .setData({
      "todayIntakes": FieldValue.arrayUnion([waterIntake.toJson()])
    }).catchError((e) => print(e));
  }

  Future updateWaterData(WaterData waterData) async {
    return await userDataCollections
        .document(uid)
        .collection("waterData")
        .document('all')
        .setData({
      'waterData': FieldValue.arrayUnion([waterData.toJson()])
    }).catchError((e) => print(e));
  }

  UserData _userDataFromSnapShot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      goal: snapshot.data['goal'],
      name: snapshot.data['name'],
      todayIntakes: snapshot.data['todayIntakes'],
      waterIntakeData: snapshot.data['waterIntakeData'],
    );
  }

  WaterIntake _dailyDataFromSnapshot(DocumentSnapshot snapshot) {
    return WaterIntake.fromJson(snapshot.data);
  }

  WaterData _waterDataFromSnapshot(DocumentSnapshot snapshot) {
    return WaterData.fromJson(snapshot.data);
  }

  //get UserData stream
  Stream<UserData> get userData {
    return userDataCollections
        .document(uid)
        .snapshots()
        .map(_userDataFromSnapShot);
  }

  //get Dalily Data strem

  Stream<WaterIntake> get dailyIntake {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .document('today')
        .snapshots()
        .map(_dailyDataFromSnapshot);
  }

  Stream<WaterData> get waterData {
    return userDataCollections
        .document(uid)
        .collection("waterData")
        .document("all")
        .snapshots()
        .map(_waterDataFromSnapshot);
  }
}
