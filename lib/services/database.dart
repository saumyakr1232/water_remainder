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
        .updateData({
      "todayIntakes": FieldValue.arrayUnion([waterIntake.toJson()])
    }).catchError((e) => print(e));
  }

  Future updateWaterData(WaterData waterData) async {
    return await userDataCollections
        .document(uid)
        .collection("waterData")
        .document('all')
        .updateData({
      'waterData': FieldValue.arrayUnion([waterData.toJson()])
    }).catchError((e) => print(e));
  }

  UserData _userDataFromSnapShot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      goal: snapshot.data['goal'],
      name: snapshot.data['name'],
    );
  }

  List<WaterIntake> _dailyDataFromSnapshot(DocumentSnapshot snapshot) {
    List<WaterIntake> intakes = [];
    for (Map<dynamic, dynamic> map in snapshot.data['todayIntakes']) {
      print(map);
      intakes.add(WaterIntake.fromJson(map));
    }

    return intakes;
  }

  List<WaterData> _waterDataFromSnapshot(DocumentSnapshot snapshot) {
    List<WaterData> waterData = [];

    for (Map<dynamic, dynamic> map in snapshot.data['waterData']) {
      waterData.add(WaterData.fromJson(map));
    }
    return waterData;
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
        .document('today')
        .snapshots()
        .map(_dailyDataFromSnapshot);
  }

  Stream<List<WaterData>> get waterData {
    return userDataCollections
        .document(uid)
        .collection("waterData")
        .document("all")
        .snapshots()
        .map(_waterDataFromSnapshot);
  }

  // void test() async {
  //   userDataCollections
  //     ..document(uid)
  //         .collection("dailyData")
  //         .document('today')
  //         .get()
  //         .then((value) {
  //       print(value.data);
  //     });
  // }

}
