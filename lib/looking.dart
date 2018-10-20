import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
