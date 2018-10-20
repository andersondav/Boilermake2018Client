import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black54
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
              child: initialOptions(text: 'Looking for help', redirScreen: new LookerScreen()),
            ),
            new Container(
              height: 20.0,
            ),
            ButtonTheme(
              minWidth: 200.0,
              height: 100.0,

              child: initialOptions(text: 'Offering help', redirScreen: new HelperScreen()),
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
        child: Text(
            this.text,
          style: new TextStyle(
            fontSize: 30.0,
            color: Colors.black54,
          )
        ),
        color: this.buttonColor,
        elevation: 4.0,
        splashColor: Colors.blueGrey,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => this.redirScreen),
          );
        }
    );
  }
}

class LookerScreen extends StatefulWidget {
  @override
  _LookerScreenState createState() => _LookerScreenState();
}

class _LookerScreenState extends State<LookerScreen> {
  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Nearby Helpers"),
        ),
        body: new Center(

        )
    );
  }
}

// Define a Custom Form Widget
class HelperScreen extends StatefulWidget {
  @override
  _HelperScreenState createState() => _HelperScreenState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _HelperScreenState extends State<HelperScreen> {

  void _sendData(String dataToSend) {
    print('Data sent');
    //send data
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
    _sendData(String dataToSend) {
      print('data sent');
    }
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
                  onPressed: () {
                    print('data sent');
                  }
              ),
              // ignore: argument_type_not_assignable
            ],
          ),
        ),

        // ignore: duplicate_named_argument
      ),
    );
  }
}