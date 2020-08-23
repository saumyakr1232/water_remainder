import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'dart:async';

class DatabaseService {
  final String uid;
  String _curDate =
      "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? DateTime.now().month.toString().padLeft(2, '0') : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? DateTime.now().day.toString().padLeft(2, '0') : DateTime.now().day}";
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

  Future updateDailyData(List<WaterIntake> waterIntakes) async {
    // print("called updateDailyData with $waterIntakes");

    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "todayIntakes": FieldValue.arrayUnion(
          [for (var waterIntake in waterIntakes) waterIntake.toJson()])
    }, merge: false);
  }

  Future addDailyData(WaterIntake waterIntake) async {
    // print("called updateDailyData with ${waterIntake.json()}");

    return await userDataCollections
        .document(uid)
        .collection("dailyData")
        .document(_curDate)
        .setData({
      "todayIntakes": FieldValue.arrayUnion([waterIntake.toJson()])
    }, merge: true);
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

  Stream<Map<String, List<WaterIntake>>> get allData {
    return userDataCollections
        .document(uid)
        .collection("dailyData")
        .snapshots()
        .map(_allDataFromQuerySnapshot);
    //     .then((querySnapshot) {
    //   snapshots = querySnapshot.documents;
    //   print(snapshots.first.documentID);
    // });
  }

  Map<String, List<WaterIntake>> _allDataFromQuerySnapshot(
      QuerySnapshot querySnapshot) {
    // print('Called _allDataFromQuerySnapshot $querySnapshot');
    List<DocumentSnapshot> snapshots = querySnapshot.documents;
    Map<String, List<WaterIntake>> map = {};
    for (DocumentSnapshot snapshot in snapshots) {
      map[snapshot.documentID] = _dailyDataFromSnapshot(snapshot);
    }
    return map;
  }
}
