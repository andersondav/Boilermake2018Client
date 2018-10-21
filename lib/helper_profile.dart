import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat.dart';

class HelperProfile extends StatefulWidget {
  HelperProfile({this.user, this.document});

  final FirebaseUser user;
  final DocumentSnapshot document;
  @override
  _HelperProfileState createState() => _HelperProfileState();
}

class _HelperProfileState extends State<HelperProfile> {
  void _chat() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new ChatScreen(
                  helper: widget.document['email'],
                  helpee: widget.user.email,
                  isHelper: false,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Profile Info'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(widget.document.data['name'],
                style: new TextStyle(fontSize: 40.0)),
            new Container(
              width: 75.0,
              height: 75.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          widget.document.data["profile_pic"] + "?sz=75"))),
            ),
            new Container(
              height: 20.0,
            ),
            new Text(widget.document.data['bio']),
            new Container(
              height: 20.0,
            ),
            new ButtonTheme(
                minWidth: 200.0,
                height: 100.0,
                child: RaisedButton(
                  child: new Text('Message'),
                  onPressed: _chat,
                )),
          ],
        ),
      ),
    );
  }
}
