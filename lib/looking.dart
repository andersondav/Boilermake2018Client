import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';

import 'util.dart';
import 'helper_profile.dart';

class LookerScreen extends StatelessWidget {
  LookerScreen({this.loc, this.user});

  final LatLng loc;
  final FirebaseUser user;

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
                    return _HelperItem(
                      loc: loc,
                      document: document,
                      user: user,
                    );
                  }).toList(),
                );
            }
          },
        ));
  }
}

class _HelperItem extends StatefulWidget {
  _HelperItem({this.loc, this.document, this.user});

  final LatLng loc;
  final DocumentSnapshot document;
  final FirebaseUser user;

  @override
  _HelperItemState createState() => _HelperItemState();
}

class _HelperItemState extends State<_HelperItem> {
  double distance = -1.0;
  String locationName;

  _goToProfile() {
    print('switching...');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new HelperProfile(
                user: widget.user, document: widget.document)));
  }

  @override
  void initState() {
    super.initState();

    dataFromPlaceID(widget.document["location"]).then((data) {
      var distance = Distance();

      var miles = distance.as(LengthUnit.Mile, data.loc, widget.loc);

      setState(() {
        this.distance = miles;
        this.locationName = data.name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
        onTap: _goToProfile,
        leading: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        widget.document.data["profile_pic"] + "?sz=50")))),
        title: Text(widget.document['name']),
        subtitle:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(widget.document['skills']),
            Text(
                ' ${distance == -1 ? "Loading distance..." : '$distance miles'}',
                style: TextStyle(fontStyle: FontStyle.italic))
          ]),
          Container(
              width: 100.0,
              child: Text(
                  this.locationName == null ? "Loading..." : this.locationName,
                  overflow: TextOverflow.ellipsis))
        ]));
  }
}
