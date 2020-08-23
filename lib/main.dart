import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        ),
        StreamProvider(create: (_) {
          return DataConnectivityService().connectivityStreamController.stream;
        })
      ],
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
