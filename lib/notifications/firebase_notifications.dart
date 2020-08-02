import 'dart:io';

import 'package:dragnet/notifications/local_notications_helper.dart';
import 'package:dragnet/screens/user/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FirebaseNotifications {
  BuildContext context;
  String _message = '';
  String _title = '';
  int _id;
  FirebaseMessaging _firebaseMessaging;
  final notifications = FlutterLocalNotificationsPlugin();

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
    //Local Notification or Background Notification
    final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _message = message['aps']['alert'];
        } else {
          _message = message['notification']['body'];
          _title = message['notification']['title'];
          _id = message['notification']['id'];
          showOngoingNotification(notifications,
              title: _title, body: _message, id: _id);
        }
        print('on message $_message');
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _message = message['aps']['alert'];
        } else {
          _message = message['notification']['body'];
        }
        print('on resume $_message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          _message = message['aps']['alert'];
        } else {
          _message = message['notification']['body'];
        }
        print('on launch $_message');
      },
    );

//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> msg) {
//        if (Theme.of(conte).platform == TargetPlatform.iOS)
//          _message = msg['aps']['alert'];
//        else
//          _message = msg['notification']['body'];
//        print(_message);
//        //showNotification(msg);
//      },
//      //onBackgroundMessage: myBackgroundMessageHandler,
//      onResume: (Map<String, dynamic> msg) {
//        //showNotification(msg);
//        if (Theme.of(context).platform == TargetPlatform.iOS)
//          _message = msg['aps']['alert'];
//        else
//          _message = msg['notification']['body'];
//        print(_message);
//      },
//      onLaunch: (Map<String, dynamic> msg) {
//        //showNotification(msg);
//        if (Theme.of(context).platform == TargetPlatform.iOS)
//          _message = msg['aps']['alert'];
//        else
//          _message = msg['notification']['body'];
//        print(_message);
//      },
//    );
  }

//  void _showItemDialog(Map<String, dynamic> message) {
//    <bool>(
//      context: context,
//      builder: (_) => _buildDialog(context, _itemForMessage(message)),
//    ).then((bool shouldNavigate) {
//      if (shouldNavigate == true) {
//        _navigateToItemDetail(message);
//      }
//    });
//  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    return Future<void>.value();
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
