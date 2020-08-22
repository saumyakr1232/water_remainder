import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';

import 'package:water_recommender/model/waterIntake.dart';

class DatabaseService {
  final String uid;
  String _curDate =
      "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
  DatabaseService({this.uid});

  final CollectionReference userDataCollections =
      Firestore.instance.collection('userData');

  Future updateUserData(
    String name,
    int goal,
  ) async {
    return await userDataCollections.document(uid).setData(<String, dynamic>{
      'name': name,
      'goal': goal,
    }).catchError((e) => print(e));
  }

  Future updateDailyData(WaterIntake waterIntake) async {
    print("called updateDailyData with ${waterIntake.json()}");

    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "todayIntakes": FieldValue.arrayUnion([waterIntake.toJson()])
    }, merge: true);
  }

  Future updateWaterData(WaterData waterData) async {
    return await userDataCollections
        .document(uid)
        .collection("waterData")
        .document('all')
        .setData({
      'waterData': FieldValue.arrayUnion([waterData.toJson()])
    }, merge: true).catchError((e) => print(e));
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
    List<dynamic> list = [];
    try {
      list = snapshot.data['todayIntakes'];
    } catch (e) {
      print("Error _dailyDataFromSnapshot ${e.toString()}");
    }

    for (Map<dynamic, dynamic> map in list) {
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
        .document(_curDate)
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



}
