import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dragnet/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class Utility {
  static Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await (new Connectivity().checkConnectivity());

    debugPrint(connectivityResult.toString());

    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> showAlert(
      BuildContext context, String text, String description) async {
    var alert = new AlertDialog(
//      content: Container(
//        child: Row(
//          children: <Widget>[Text(text)],
//        ),
//      ),
      elevation: 6,
      title: Text(text),
      content: Text(description),
      actions: <Widget>[
        new FlatButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ))
      ],
    );

    showDialog(
        //to prevent outside touch to close the alert dialogue..,
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return alert;
        }).then((val) {
      return true;
    });
  }

  static Future<void> showToast(BuildContext context, String messages) async {
    CustomToast.show(messages, context,
        backgroundColor: Colors.black87,
        backgroundRadius: 5,
        gravity: CustomToast.bottom,
        duration: CustomToast.lengthLong,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ));
  }
}
