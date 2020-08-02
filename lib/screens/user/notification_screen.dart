import 'dart:convert';

import 'package:dragnet/models/responses/getusernotification_response.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationsPageState();
  }
}

class NotificationsPageState extends State<NotificationsPage> {
  var users = new List<GetUserNotification>();
  int _userId;
  bool _isLoading = false;
  int selected = -1; //attention

  @override
  void initState() {
    // TODO: implement initState
    _loadGlobalValues();
    super.initState();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('UserId') ?? '';
      _GetNotificationRequest();
    });
  }

  void _GetNotificationRequest() async {
    setState(() {
      _isLoading = true;
    });
    var url = Notification_Url + _userId.toString();
    print("url $url");
    http.Response response = await http.get(
      url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    // sample info available in response
    int statusCode = response.statusCode;
    print("statusCode $statusCode");
    if (statusCode == 200) {
      Iterable list = json.decode(response.body);
      setState(() {
        users =
            list.map((model) => GetUserNotification.fromJson(model)).toList();
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Some Thing Went Wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: BgColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: BlackColor, //change your color here
        ),
        backgroundColor: BgColor,
        title: Text(
          Notification_Text,
          style: appBarTitleTextStyle,
        ),
      ),
      body: CustomProgressBar(
        isLoading: _isLoading,
        widget: _listView(),
      ),
    );
  }

  Widget _listView() {
    Color getColor(value) {
      if (value == "red")
        return Colors.red;
      else if (value == "orange")
        return Colors.orange;
      else
        return Colors.yellowAccent;
    }

    PageStorageKey _key;
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 8.0,
          margin: EdgeInsets.all(0.0),
          child: Container(
            // padding: EdgeInsets.only(top: 5, bottom: 5),
            decoration: BoxDecoration(color: BgColor),
            child: ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Image.asset(
                  "images/noticication_warn.png",
                  height: 45,
                  width: 45,
                ),
              ),
              title: Text(
                users[index].crimeName,
                style: textStyleBlackBold,
              ),
              subtitle: Text(
                users[index].notificationSendDate,
                style: notificationTimeTextStyle,
              ),
              trailing: Text(
                users[index].timeOfOccurence,
                style: notificationTimeTextStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
