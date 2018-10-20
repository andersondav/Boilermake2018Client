import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define a Custom Form Widget
class AcctCreation extends StatelessWidget {
  AcctCreation({this.user, this.userdocument});

  final FirebaseUser user;
  final DocumentSnapshot userdocument;

  void _sendData() {
    // upload the credentials
    Firestore.instance
        .collection('helpers')
        .document(this.user.email.toLowerCase())
        .setData({
      'email': this.user.email,
      'name': this.user.displayName,
      'skills': myController.text,
      'profile_pic': this.user.photoUrl,
      'location': 'TODO',
    });
  }

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // see if they are already a user
    bool userexists = userdocument.exists;
    if (userexists) {
      myController.text = userdocument.data['skills'];
    }

    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('Helper Data Entry'),
        ),
        body: new Center(
          child: new Container(
            padding: const EdgeInsets.all(32.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                    'You are logged in as ${this.user.displayName}. ${userexists ? "Welcome Back!" : "Welcome new user!"}',
                    style: new TextStyle(
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                ),
                new Container(
                  height: 20.0,
                ),
                new Text(
                  'Please enter your skills',
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                new Container(
                  height: 20.0,
                ),
                new TextFormField(
                  controller: myController,
                  decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: new EdgeInsets.fromLTRB(
                          10.0, 30.0, 10.0, 10.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(12.0),
                      ),
                      ),
                ),
                new Container(
                  height: 20.0,
                ),
                // ignore: list_element_type_not_assignable
                ButtonTheme(
                    height: 50.0,
                    minWidth: 80.0,
                    child: RaisedButton(
                      splashColor: Colors.grey,
                      color: Colors.blue,
                      onPressed: _sendData,
                      child: new Text(
                          'Submit',
                          style: new TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                          )
                      ),
                    ),
                ),
                // ignore: argument_type_not_assignable
                new Container(
                  height: 70.0,
                )
              ],
            ),
          ),
        ));
  }
}
