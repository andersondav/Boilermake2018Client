import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

import 'util.dart';
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
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
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
  void _getHelp() async {
    // get the location
    Prediction p = await showGooglePlacesAutocomplete(
        apiKey: MAPS_API_KEY,
        context: context,
        hint: 'Enter the area that you live in...');

    print("Done with google");

    var loc = (await dataFromPlaceID(p.placeId)).loc;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new LookerScreen(loc: loc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                  text: 'Looking for help', handleFunc: _getHelp),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new AcctCreation()));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class InitialOptions extends StatelessWidget {
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
