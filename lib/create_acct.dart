import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'manage_acct.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<FirebaseUser> _handleSignIn() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return user;
}

// Define a Custom Form Widget
class AcctCreation extends StatefulWidget {
  @override
  _AcctCreationState createState() => new _AcctCreationState();
}

class _AcctCreationState extends State<AcctCreation> {
  FirebaseUser user;

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

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => new ManageAccount(user: user)));
  }

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final myController = TextEditingController();

  Widget _buildLoading() {
    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCreateAcct() {
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
                new Text('Welcome new user: ${this.user.displayName}'),
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

  @override
  void initState() {
    super.initState();

    () async {
      // start logging in
      FirebaseUser user = await _handleSignIn();
      DocumentSnapshot document = await Firestore.instance
          .collection('helpers')
          .document(user.email.toLowerCase())
          .get();

      if (document.exists) {
        // they arlready have an account, go to manage_acct
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new ManageAccount(user: user)));
      } else {
        setState(() {
          this.user = user;
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // still loading
      return _buildLoading();
    } else {
      return _buildCreateAcct();
    }
  }
}
