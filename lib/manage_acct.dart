import 'package:boilermake2018/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

import 'create_acct.dart';

class ManageAccount extends StatefulWidget {
  ManageAccount({this.user});

  final FirebaseUser user;

  @override
  _ManageAccountState createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  DocumentSnapshot document;
  Prediction location;
  String locationName = 'loading...';

  void initState() {
    super.initState();


    Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .get()
        .then((document) {

        this.setState(() => this.document = document);

      dataFromPlaceID(document["location"]).then((data) {
        setState(() {
          this.locationName = data.name;
        });
      });
    });
  }

  void _getLoc(BuildContext context) async {
    Prediction pre = await showGooglePlacesAutocomplete(
        apiKey: MAPS_API_KEY, context: context);

    await Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .setData({'location': pre.placeId}, merge: true);

    setState(() => location = pre);
  }

  Widget _buildLoading() {
    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildLoaded() {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Helper Account')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _EditSkillsArea(
                initState: document['skills'],
                user: widget.user,
              ),
              Divider(
                height: 10.0
              ),
              _EditBioArea(
                initState: document['bio'],
                user: widget.user,
              ),
              Divider(
                  height: 10.0
              ),
              FlatButton(
                child: Row(children: [
                  Icon(Icons.map),
                  Flexible(
                      child: Container(
                          child: Text(
                            location != null
                                ? location.description
                                : locationName,
                            overflow: TextOverflow.ellipsis,
                          ))),
                ]),
                onPressed: () => _getLoc(context),
              ),
              Divider(
                height: 10.0,
              ),
              _DeleteAccountButton(user: widget.user),

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (document == null) {
      return _buildLoading();
    } else {
      return _buildLoaded();
    }
  }
}

class _DeleteAccountButton extends StatelessWidget {
  _DeleteAccountButton({this.user});

  final FirebaseUser user;

  void _deleteAccount(BuildContext context) async {
    await Firestore.instance
        .collection('helpers')
        .document(user.email.toLowerCase())
        .delete();

    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text("Account Deleted"),
    ));

    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () => _deleteAccount(context),
      child: Text('Delete Account'),
      color: Colors.red,
    );
  }
}

class _EditSkillsArea extends StatelessWidget {
  _EditSkillsArea({initState: String, this.user})
      : skillsController = TextEditingController(text: initState);

  final TextEditingController skillsController;
  final FirebaseUser user;

  void _saveSkills(BuildContext context) async {
    await Firestore.instance
        .collection('helpers')
        .document(user.email.toLowerCase())
        .setData({'skills': skillsController.text}, merge: true);

    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text("Skills Saved"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Skills',
              style: TextStyle(
                fontSize: 20.0,
              )
          ),
          TextFormField(
            controller: skillsController,
          ),
          RaisedButton(
            child: Text('Save Skills'),
            onPressed: () => _saveSkills(context),
          ),
        ]);
  }
}

class _EditBioArea extends StatelessWidget {
  _EditBioArea({initState: String, this.user})
      : bioController = TextEditingController(text: initState);

  final TextEditingController bioController;
  final FirebaseUser user;

  void _saveSkills(BuildContext context) async {
    await Firestore.instance
        .collection('helpers')
        .document(user.email.toLowerCase())
        .setData({'bio': bioController.text}, merge: true);

    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text("Bio Saved"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Bio',
          style: TextStyle(
            fontSize: 20.0,
          )
          ),
          Container(
            height: 10.0,
          ),
          TextFormField(
            // ignore: argument_type_not_assignable
          decoration: new InputDecoration(
            filled: true,
            contentPadding: new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
            border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(12.0),
            ),
          ),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: bioController,
          ),
          RaisedButton(
            child: Text('Save Bio'),
            onPressed: () => _saveSkills(context),
          ),
        ]);
  }
}