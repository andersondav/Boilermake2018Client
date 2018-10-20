import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'looking.dart';
import 'create_acct.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

void main() => runApp(new MyApp());

Future<FirebaseUser> _handleSignIn() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  print("signed in " + user.displayName);
  return user;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          primarySwatch: Colors.blue, backgroundColor: Colors.black54),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _askingForHelp() {
    print("TODO: insert transition to list of helpers");
    Firestore.instance.collection('helpers').snapshots().forEach(
        (QuerySnapshot a) => a.documents
            .toList()
            .forEach((DocumentSnapshot a) => print(a.data["name"])));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'I am...',
              style: new TextStyle(
                fontSize: 40.0,
                color: Color(
                    0xAACFB53B), //psuedo old gold because actual old gold does not come for some reason
              ),
            ),
            new Container(
              height: 10.0,
            ),
            // ignore: list_element_type_not_assignable
            ButtonTheme(
              minWidth: 200.0,
              height: 100.0,
              child: InitialOptions(
                  text: 'Looking for help',
                  handleFunc: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new LookerScreen()),
                    );
                  }),
            ),
            new Container(
              height: 20.0,
            ),
            ButtonTheme(
              minWidth: 200.0,
              height: 100.0,
              child: InitialOptions(
                  text: 'Offering help',
                  handleFunc: () {
                    _handleSignIn().then(((user) {
                      Firestore.instance
                          .collection('helpers')
                          .document(user.email.toLowerCase())
                          .get()
                          .then((DocumentSnapshot document) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new AcctCreation(
                                    user: user,
                                    userdocument: document,
                                  )),
                        );
                      });
                    }));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class InitialOptions extends RaisedButton {
  InitialOptions({Key key, this.text, this.handleFunc}) : super(key: key);

  final String text;

  final Function handleFunc;

  MaterialColor buttonColor;

  void _setColor() {
    if (this.text == "Offering help") {
      this.buttonColor = MaterialColor(0xAACFB53B, null);
    } else {
      this.buttonColor = MaterialColor(0xAACFB53B, null);
    }
  }

  Widget build(BuildContext context) {
    _setColor();
    return new RaisedButton(
        child: Text(this.text,
            style: new TextStyle(
              fontSize: 30.0,
              color: Colors.black54,
            )),
        color: this.buttonColor,
        elevation: 4.0,
        splashColor: Colors.blueGrey,
        onPressed: handleFunc);
  }
}
