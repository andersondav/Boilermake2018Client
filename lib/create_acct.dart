import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

import 'manage_acct.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

const MAPS_API_KEY = 'AIzaSyDx51vyR0IGRSrrtD9FVS6HVQOLWeRzGQ0';

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

    Navigator.pop(
        context); // pop this off, if we go back we should go back to the main screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new ManageAccount(user: user)),
    );
  }

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final myController = TextEditingController();
  final myController2 = TextEditingController();

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
            child: new ListView(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  'You are logged in as ${this.user.displayName}. Welcome new user!',
                  style: new TextStyle(color: Colors.white),
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
                    contentPadding:
                        new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                new Container(
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
                new Container(
                  height: 20.0,
                ),
                new TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  controller: myController2,
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
                new Container(
                  height: 20.0,
                ),
                // ignore: list_element_type_not_assignable
                new LocPickerButton(
                  onResponse: (a) => print(a),
                ),
                ButtonTheme(
                  height: 50.0,
                  minWidth: 80.0,
                  child: RaisedButton(
                    splashColor: Colors.grey,
                    color: Colors.blue,
                    onPressed: _sendData,
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

class LocPickerButton extends StatefulWidget {
  LocPickerButton({this.onResponse});

  Function onResponse;

  @override
  _LocPickerButtonState createState() => _LocPickerButtonState();
}

class _LocPickerButtonState extends State<LocPickerButton> {
  Prediction prediction;

  void _getLoc(BuildContext context) async {
    Prediction pre = await showGooglePlacesAutocomplete(
        apiKey: MAPS_API_KEY, context: context);

    setState(() => prediction = pre);
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(children: [
        Icon(Icons.map),
        Text(prediction != null ? prediction.description : 'Pick a location')
      ]),
      onPressed: () => _getLoc(context),
    );
  }
}
