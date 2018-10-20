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
  DocumentSnapshot document;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _EditSkillsArea(
                initState: document['skills'],
                user: widget.user,
              ),
              Divider(),
              _DeleteAccountButton(user: widget.user)
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
          Text('Skills'),
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
