import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({this.helper, this.helpee, this.isHelper});

  final String helper;
  final String helpee;
  final bool isHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${isHelper ? helpee : helper}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('helpers')
            .document(helper.toLowerCase())
            .collection(helpee.toLowerCase())
            .orderBy('sent', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            // case ConnectionState.waiting:
            //   return new Text('Loading...');
            default:
              return Stack(children: [
                Container(
                    height: MediaQuery.of(context).size.height - 130.0,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      reverse: true,
                      shrinkWrap: true,
                      children:
                          snapshot.connectionState == ConnectionState.waiting
                              ? []
                              : snapshot.data.documents.map(
                                  (DocumentSnapshot document) {
                                    return _Message(
                                        text: document["text"],
                                        me: (isHelper &&
                                                document["from"] == helper) ||
                                            (!isHelper &&
                                                document["from"] == helpee));
                                  },
                                ).toList(),
                    )),
                Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: _MessageSender(
                      helper: helper,
                      helpee: helpee,
                      isHelper: isHelper,
                    ))
              ]);
          }
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  _Message({this.text, this.me});

  final String text;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Chip(label: Text(text))],
      mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }
}

class _MessageSender extends StatefulWidget {
  _MessageSender({this.helper, this.helpee, this.isHelper});

  final String helper;
  final String helpee;
  final bool isHelper;

  @override
  _MessageSenderState createState() => _MessageSenderState();
}

class _MessageSenderState extends State<_MessageSender> {
  final controller = TextEditingController();

  bool valid = false;

  void _send() {
    Firestore.instance
        .collection("/helpers")
        .document(widget.helper)
        .collection(widget.helpee)
        .document()
        .setData({
      'text': controller.text,
      'from': widget.isHelper ? widget.helper : widget.helpee,
      'sent': Timestamp.now(),
    });

    controller.text = '';
  }

  @override
  void initState() {
    super.initState();

    controller
        .addListener(() => setState(() => valid = controller.text.isNotEmpty));
  }

  @override
  Widget build(BuildContext conext) {
    return Row(
      children: [
        Flexible(child: TextFormField(controller: controller)),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: valid ? _send : null,
        ),
      ],
    );
  }
}
