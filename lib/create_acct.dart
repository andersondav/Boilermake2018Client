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
                    'You are ${this.user.displayName}. ${userexists ? "Welcome Back!" : "Welcome new user!"}'),
                new Text(
                  'Please enter your areas of expertise',
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                new TextFormField(
                  controller: myController,
                ),
                // ignore: list_element_type_not_assignable
                RaisedButton(
                    child: Text('Submit'),
                    textColor: Colors.black54,
                    color: Theme.of(context).accentColor,
                    elevation: 4.0,
                    splashColor: Colors.blueGrey,
                    onPressed: _sendData),
                // ignore: argument_type_not_assignable
              ],
            ),
          ),
        ));
  }
}
