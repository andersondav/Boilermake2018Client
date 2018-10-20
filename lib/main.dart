import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() => runApp(new MyApp());

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
      backgroundColor: Colors.deepOrangeAccent,
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
                color: Colors.black54,
              ),
            ),
            new Container(
              height: 10.0,
            ),
            // ignore: list_element_type_not_assignable
            ButtonTheme(
              minWidth: 200.0,
              height: 100.0,
              child: initialOptions(
                  text: 'Looking for help', redirScreen: new LookerScreen()),
            ),
            new Container(
              height: 20.0,
            ),
            ButtonTheme(
              minWidth: 200.0,
              height: 100.0,
              child: initialOptions(
                  text: 'Offering help', redirScreen: new HelperScreen()),
            ),
            // ignore: argument_type_not_assignable
          ],
        ),
        // ignore: duplicate_named_argument
      ),
    );
  }
}

class initialOptions extends RaisedButton {
  initialOptions({Key key, this.text, this.redirScreen}) : super(key: key);

  final String text;

  final StatefulWidget redirScreen;

  MaterialColor buttonColor;

  void _test() {
    print('Alrighty');
  }

  void _setColor() {
    if (this.text == "Offering help") {
      this.buttonColor = Colors.green;
    } else {
      this.buttonColor = Colors.blue;
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => this.redirScreen),
          );
        });
  }
}

class LookerScreen extends StatefulWidget {
  @override
  _LookerScreenState createState() => _LookerScreenState();
}

class _LookerScreenState extends State<LookerScreen> {
  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Nearby Helpers"),
        ),
        body: new Center());
  }
}

// Define a Custom Form Widget
class HelperScreen extends StatefulWidget {
  @override
  _HelperScreenState createState() => _HelperScreenState();
}

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

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _HelperScreenState extends State<HelperScreen> {
  void _sendData() {
    _handleSignIn().then((user) {
      // TODO: check for duplicates, and if there is one allow for editing of stuff

      // upload the credentials
      Firestore.instance.collection('helpers').document().setData({
        'email': user.email,
        'name': user.displayName,
        'skills': myController.text,
        'location': 'TODO',
      });
    });
  }

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
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
                'Please enter your areas of expertise',
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              new TextFormField(
                controller: myController,
                initialValue: null,
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

        // ignore: duplicate_named_argument
      ),
    );
  }
}

class Messaging extends StatefulWidget {
  @override
  _MessagingState createState() => new _MessagingState();
}

class _MessagingState extends State<Messaging> {
  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print(message);
    });

    _firebaseMessaging.subscribeToTopic("tester");
    print("Subscribed");

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Messaging"),
        ),
        body: Column(
          children: [
            Row(
              children: [Chip(label: Text("Hello"))],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            Row(
              children: [Chip(label: Text("Goodbye"))],
              mainAxisAlignment: MainAxisAlignment.start,
            )
          ],
        ));
  }
}
