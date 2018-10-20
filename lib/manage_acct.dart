import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAccount extends StatefulWidget {
  ManageAccount({this.user});

  final FirebaseUser user;

  @override
  _ManageAccountState createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  _ManageAccountState() : skillsController = TextEditingController();

  DocumentSnapshot document;

  final TextEditingController skillsController;

  void _saveSkills() {
    Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .setData({'skills': skillsController.text}, merge: true);
  }

  void _deleteAccount() {
    Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .delete();

    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  Widget _buildLoading() {
    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildLoaded() {
    skillsController.text = document['skills'];

    return Scaffold(
      appBar: AppBar(title: Text('Manage Helper Account')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Skills'),
              TextFormField(
                controller: skillsController,
              ),
              RaisedButton(
                child: Text('Save Skills'),
                onPressed: _saveSkills,
              ),
              Divider(),
              RaisedButton(
                child: Text('Delete Account'),
                color: Colors.red,
                onPressed: _deleteAccount,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection('helpers')
        .document(widget.user.email.toLowerCase())
        .get()
        .then((document) => this.setState(() => this.document = document));
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
