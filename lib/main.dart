import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/screens/home/waterDrinkingRecords.dart';
import 'package:water_recommender/screens/sleep/sleepPage.dart';
import 'package:water_recommender/screens/wrapper.dart';
import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/services/utils.dart';

import 'model/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: AuthServices().user,
          initialData: User(uid: "loading"),
        ),
        StreamProvider(create: (_) {
          return DataConnectivityService().connectivityStreamController.stream;
        })
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => Wrapper(),
          '/sleepPage': (context) => SleepPage()
        },
      ),
    );
  }
}
