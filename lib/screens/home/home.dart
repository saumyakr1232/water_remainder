import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:water_recommender/screens/home/homePageContent.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';

import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/services/database.dart';
import 'package:water_recommender/services/utils.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).userData,
        ),
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).dailyIntake,
          initialData: Utils().getIntialIntakeData(),
        ),
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).allData,
          initialData: Utils().getInitialAllData(),
        ),
      ],
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScrollStarted = false;
  bool isScrollOnStart = true;
  ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      isScrollStarted = true;
      isScrollOnStart = false;
    });
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        isScrollOnStart = false;
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        isScrollOnStart = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthServices _auth = AuthServices();
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.indigo.shade200, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.center,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor:
              isScrollOnStart ? Colors.transparent : Colors.indigo.shade300,
          elevation: 0.0,
          title: Text(
            "Drink Water",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24.0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.black,
              onPressed: () {
                _auth.signOut();
              },
              iconSize: 24.0,
            ),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              _onStartScroll(scrollNotification.metrics);
            }

            return true;
          },
          child: SingleChildScrollView(
            controller: _controller,
            child: HomePageContent(),
          ),
        ),
      ),
    );
  }
}

// var allData = Provider.of<Map<String, List<WaterIntake>>>(context);
