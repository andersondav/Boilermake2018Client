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
              child: initialOptions(
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
              child: initialOptions(
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
                              builder: (context) => new HelperScreen(
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

class initialOptions extends RaisedButton {
  initialOptions({Key key, this.text, this.handleFunc}) : super(key: key);

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

// Define a Custom Form Widget
class HelperScreen extends StatefulWidget {
  HelperScreen({this.user, this.userdocument});

  final FirebaseUser user;
  final DocumentSnapshot userdocument;

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
    // upload the credentials
    Firestore.instance
        .collection('helpers')
        .document(this.widget.user.email.toLowerCase())
        .setData({
      'email': this.widget.user.email,
      'name': this.widget.user.displayName,
      'skills': myController.text,
      'profile_pic': this.widget.user.photoUrl,
      'location': 'TODO',
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
    // see if they are already a user
    bool userexists = widget.userdocument.exists;
    if (userexists) {
      myController.text = widget.userdocument.data['skills'];
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
                    'You are ${this.widget.user.displayName}. ${userexists ? "Welcome Back!" : "Welcome new user!"}'),
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

class LookerScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Nearby Helpers"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('helpers').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      leading: Image.network(
                          document.data["profile_pic"] + "?sz=64"),
                      title: new Text(document['name']),
                      subtitle: new Text(document['skills']),
                    );
                  }).toList(),
                );
            }
          },
        ));
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
