import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/services/database.dart';

class Home extends StatelessWidget {
  final AuthServices _auth = AuthServices();
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
      value: DatabaseService().userData,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            FlatButton(
                onPressed: () {
                  _auth.signOut();
                },
                child: Text('sign out'))
          ],
        ),
        body: Test(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          return Center(
            child: Text(userData.name + " ${userData.goal}"),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
