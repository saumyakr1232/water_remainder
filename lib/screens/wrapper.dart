import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/shared/loading.dart';
import 'authenticate/authenticate.dart';
import 'home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user == null ? Authenticate() : Home();
  }
}
