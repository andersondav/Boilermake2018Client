import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

class HelperProfile extends StatefulWidget {
  HelperProfile({this.user, this.document});

  final FirebaseUser user;
  final DocumentSnapshot document;
  @override
  _HelperProfileState createState() => _HelperProfileState();
}

class _HelperProfileState extends State<HelperProfile> {

  DocumentSnapshot document;

  void initState() {
    super.initState();


    Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .get()
        .then((document) {

      this.setState(() => this.document = document);

      });
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
            new Container(
            width: 50.0,
            height: 50.0,
//            decoration: BoxDecoration(
//                shape: BoxShape.circle,
//                image: DecorationImage(
//                    fit: BoxFit.fill,
//                    image: NetworkImage(
//                        document.data["profile_pic"] + "?sz=50"))
//            ),
            ),
            new Container(
              height: 20.0,
            ),
            new Text(
              'Hello'
              //document.data['bio']
            ),
            new Container(
              height: 20.0,
            ),
            new ButtonTheme(
                minWidth: 200.0,
                height: 100.0,
                child: RaisedButton(
                    child: new Text('Message'),
                )
            ),
          ],
        ),
      ),
    );
  }
}