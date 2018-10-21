import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

import 'manage_acct.dart';
import 'util.dart';

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
  Prediction location;
  bool valid = false;

  void _getLoc(BuildContext context) async {
    Prediction pre = await showGooglePlacesAutocomplete(
        apiKey: MAPS_API_KEY, context: context);

    setState(() => location = pre);
  }

  void _sendData() async {
    // upload the credentials
    await Firestore.instance
        .collection('helpers')
        .document(this.user.email.toLowerCase())
        .setData({
      'email': this.user.email,
      'name': this.user.displayName,
      'skills': skillsController.text,
      'profile_pic': this.user.photoUrl,
      'location': location.placeId,
      'bio': bioController.text,
    });

    Navigator.pop(
        context); // pop this off, if we go back we should go back to the main screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new ManageAccount(user: user)),
    );
  }

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final skillsController = TextEditingController();
  final bioController = TextEditingController();

  void setValidity() {
    setState(() {
      valid = skillsController.text.isNotEmpty &&
          bioController.text.isNotEmpty &&
          location != null;
    });
  }

  Widget _buildLoading() {
    return new Scaffold(
        appBar: new AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCreateAcct() {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Helper Data Entry'),
        ),
        body: new Center(
          child: new ListView(
            padding: new EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  'You are logged in as ${this.user.displayName}. Welcome new user!',
                  style: new TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                new Divider(
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
                new Divider(
                  height: 20.0,
                ),
                new TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: skillsController,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                new Divider(
                  height: 20.0,
                ),
                new Text(
                  'Please enter your bio',
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                new Divider(
                  height: 20.0,
                ),
                new TextFormField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  controller: bioController,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                new Divider(
                  height: 30.0,
                ),
                // ignore: list_element_type_not_assignable
                FlatButton(
                  child: Row(children: [
                    Icon(Icons.map),
                    Flexible(
                        child: Container(
                            child: Text(
                      location != null
                          ? location.description
                          : 'Pick a location',
                      overflow: TextOverflow.ellipsis,
                    ))),
                  ]),
                  onPressed: () => _getLoc(context),
                ),

                new Divider(
                  height: 20.0,
                ),
                ButtonTheme(
                  height: 50.0,
                  minWidth: 80.0,
                  child: RaisedButton(
                    splashColor: Colors.grey,
                    color: Colors.blue,
                    onPressed: valid ? _sendData : null,
                    child: new Text('Submit',
                        style: new TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        )),
                  ),
                ),
                // ignore: argument_type_not_assignable
              ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    skillsController.addListener(setValidity);
    bioController.addListener(setValidity);

    () async {
      // start logging in
      FirebaseUser user = await _handleSignIn();
      DocumentSnapshot document = await Firestore.instance
          .collection('helpers')
          .document(user.email.toLowerCase())
          .get();

      if (document.exists) {
        // they arlready have an account, go to manage_acct
        Navigator.pop(
            context); // pop this off, if we go back we should go back to the main screen
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
