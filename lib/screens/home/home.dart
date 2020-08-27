import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:water_recommender/screens/home/homePageContent.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/screens/sleep/sleepPage.dart';

import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/services/database.dart';
import 'package:water_recommender/services/utils.dart';

class Home extends StatelessWidget {
//  String test = "initial";
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
          value: DatabaseService(uid: user.uid).allWaterData,
          initialData: Utils().getInitialAllData(),
        ),
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).allSleepData,
        ),
        StreamProvider.value(
          value: DatabaseService(uid: user.uid).todaySleepData,
        ),
      ],
      child: HomePage(),
    );
  }
}

class CustomTab {
  final String title;
  final Color colorPrimary;
  final Color colorSecondary;
  Color unselectedLabelColor = Colors.white;
  Color labelColor = Colors.indigo;
  Color indicatorColor = Colors.indigo.shade600;
  CustomTab(
      {this.title,
      this.colorPrimary,
      this.colorSecondary,
      this.unselectedLabelColor,
      this.indicatorColor,
      this.labelColor});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
//  final GlobalKey<SleepPageState()> _key = GlobalKey();
  final List<CustomTab> _tabs = [
    CustomTab(
        title: "Drink",
        colorPrimary: Colors.indigo.shade300,
        labelColor: Colors.indigo.shade900,
        unselectedLabelColor: Colors.white,
        colorSecondary: Colors.white,
        indicatorColor: Colors.indigo.shade900),
    CustomTab(
        title: "Sleep",
        colorPrimary: Colors.black,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.white,
        colorSecondary: Colors.white),
  ];
  CustomTab _tabHandler;
  TabController _tabController;
  bool isScrollStarted = false;
  bool isScrollOnStart = true;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _tabHandler = _tabs[0];
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleSelected);
    _tabController.addListener(_resetScrollBools);
  }

  void _resetScrollBools() {
    setState(() {
      isScrollStarted = false;
      isScrollOnStart = true;
    });
  }

  void _handleSelected() {
    setState(() {
      _tabHandler = _tabs[_tabController.index];
    });
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
    UserData userData = Provider.of<UserData>(context) ??
        UserData(goal: 0, name: "new user", uid: "");
    var user = Provider.of<User>(context);
//    print("called from _HomePageState");
    final AuthServices _auth = AuthServices();
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [_tabHandler.colorPrimary, _tabHandler.colorSecondary],
        begin: Alignment.topCenter,
        end: Alignment.center,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor:
              isScrollOnStart ? Colors.transparent : _tabHandler.colorPrimary,
          elevation: 0.0,
          title: Text(
            _tabHandler.title,
            style: TextStyle(
                color: _tabHandler.indicatorColor,
                fontWeight: FontWeight.bold,
                fontSize: 24.0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              color: _tabHandler.indicatorColor,
              onPressed: () {
                _auth.signOut();
              },
              iconSize: 24.0,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                  icon: Icon(
                SimpleLineIcons.drop,
              )),
              Tab(
                icon: Icon(Icons.call),
              )
            ],
            unselectedLabelColor: _tabHandler.unselectedLabelColor,
            labelColor: _tabHandler.labelColor,
            indicatorColor: _tabHandler.indicatorColor,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _onStartScroll(scrollNotification.metrics);
                }

                return true;
              },
              child: SingleChildScrollView(
                  controller: _controller, child: HomePageContent()),
            ),
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _onStartScroll(scrollNotification.metrics);
                }

                return true;
              },
              child: SingleChildScrollView(
                controller: _controller,
                child: StreamProvider.value(
                    value:
                        DatabaseService(uid: user.uid, sleepGoal: userData.goal)
                            .avgSleep,
                    initialData: 0.0,
                    child: SleepPage()),
              ),
            ),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}

// var allData = Provider.of<Map<String, List<WaterIntake>>>(context);
