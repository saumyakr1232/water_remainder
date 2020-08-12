import 'package:flutter/material.dart';
import 'package:water_recommender/services/auth.dart';
import 'package:water_recommender/shared/constants.dart';
import 'package:water_recommender/shared/loading.dart';
import 'package:numberpicker/numberpicker.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthServices _auth = AuthServices();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  NumberPicker decimalNumberPicker;

//text field states
  String email = "";
  String password = "";
  String error = "";
  String name = '';
  double goal = 0.0;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: AppBar(
              title: Text("Register"),
              elevation: 0.0,
              backgroundColor: Colors.blue[400],
              actions: [
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    widget.toggleView();
                  },
                  label: Text("Sign in"),
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            val.isEmpty ? "Enter an Email" : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Password"),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (val) => val.length < 6
                            ? 'Enter a password 6+ char long'
                            : null,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Name"),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: (val) =>
                            val.isEmpty ? 'Enter a valid name' : null,
                        onChanged: (val) {
                          setState(() {
                            name = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        color: Colors.pink[400],
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0.0),
                        child: FlatButton.icon(
                            color: Colors.white,
                            onPressed: () => _showDoubleDialog(),
                            icon: Icon(Icons.track_changes_rounded),
                            label: Text(
                              "$goal Liters",
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });

                            dynamic resutl = await _auth
                                .registerWithEmailAndPassword(email, password, name, goal);
                            if (resutl == null) {
                              setState(() {
                                error = 'please apply a valid email';
                              });
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        },
                        color: Colors.pink[400],
                        child: Text('Register',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Future _showDoubleDialog() async {
    await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.decimal(
          minValue: 1,
          maxValue: 5,
          initialDoubleValue: 1,
          title: new Text("Pick a Goal Amount"),
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() => goal = value);
        // decimalNumberPicker.animateDecimalAndInteger(value);
      }
    });
  }
}
