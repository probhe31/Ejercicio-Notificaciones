import 'package:flutter_fcm_3/api/messaging.dart';
import 'package:flutter_fcm_3/model/message.dart';
import 'package:flutter_fcm_3/page/first_page.dart';
import 'package:flutter_fcm_3/page/second_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  final TextEditingController titleController =
      TextEditingController(text: 'Test Form Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Test Form Body');

  @override
  void initState() {
    super.initState();
    final List<String> topics = ['all', 'CURSO_ADS', 'CURSO_DCS', 'CURSO_DSD'];
    for (var topic in topics) {
      _firebaseMessaging.unsubscribeFromTopic(topic);
    }
    var topic = 'CURSO_DSD';
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.subscribeToTopic(topic);
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];
        print("onResume: " + notification.toString());

        setState(() {
          bodyvalue = "onResume: " + notification['body'].toString();
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
        handleRouting(notification);
      },
      onLaunch: (Map<String, dynamic> message) async {
        //print("onLaunch: $message");
        final notification = message['data'];
        print("onLaunch: " + notification.toString());

        setState(() {
          bodyvalue = notification['body'] != null
              ? "onLaunch: " + notification['body'].toString()
              : "null";
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
        handleRouting(notification);
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
        final notification = message['data'];

        print("onResume: " + notification['title']);

        setState(() {
          bodyvalue = "onResume: " + notification['body'].toString();
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
        handleRouting(notification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  void handleRouting(dynamic notification) {
    switch (notification['title']) {
      case 'first':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
        break;
      case 'second':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => SecondPage()));
        break;
    }
  }

  String dropdownValue = 'all';
  String bodyvalue = "";
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Text("body value: " + bodyvalue),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['all', 'CURSO_ADS', 'CURSO_DCS', 'CURSO_DSD']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          RaisedButton(
            onPressed: sendNotification,
            child: Text('Send'),
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(Message message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  Future sendNotification() async {
    final response = await Messaging.sendToTopic(
        title: titleController.text,
        body: bodyController.text,
        topic: dropdownValue
        // fcmToken: fcmToken,
        );
    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
  }
}
