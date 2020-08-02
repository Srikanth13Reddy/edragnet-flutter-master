import 'dart:io';

import 'package:dragnet/screens/common/edit_profile.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/widgets/custom_profile_image.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  int _userId;
  String _userName;
  String _email;
  String _phoneNumber;
  String ProfileImage;
  Image _profileIcon;
  File _image;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Load the global value to my page
    _loadGlobalValues();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Try reading data from the counter key. If it doesn't exist, return 0.
      _userId = prefs.getInt('UserId') ?? 0;
      _userName = prefs.getString('UserName') ?? '';
      _email = prefs.getString('Email') ?? '';
      _phoneNumber = prefs.getString('PhoneNumber') ?? '+91 7904613073';
      ProfileImage =
          prefs.getString('ProfileImage') ?? 'images/profilemenu.jpg';

      if (ProfileImage != null) {
        _profileIcon = Image.network(
          ProfileImage,
        );
      } else {
        AssetImage asset = AssetImage("images/dragnetlogo.png");
        Image image = Image(
          image: asset,
        );
        _profileIcon = image;
      }
      userNameController.text = _userName;
      emailController.text = _email;
      phoneNoController.text = _phoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SafeArea(
            child: CustomProgressBar(
      isLoading: _isLoading,
      widget: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _header(),
            _profileImage(),
          ],
        ),
      ),
    )));
  }

  var _placeholderImage = AssetImage('images/profile.png');
  Widget _profileImage() {
    var cont = Container(
      margin: EdgeInsets.only(top: 30.0),
      child: CustomProfileImage(url: ProfileImage, radius: 60),
    );
    var row = Row(
      children: <Widget>[
        SizedBox(
          width: 20,
        ),
        cont,
        SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              _userName,
              style: appBarTitleTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.envelope,
                  color: ProfileTextColor,
                  size: 20,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  _email,
                  style: profileTextStyle,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.phone,
                  color: ProfileTextColor,
                  size: 20,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  _phoneNumber,
                  style: profileTextStyle,
                ),
              ],
            ),
          ],
        ),
      ],
    );
    return row;
  }

  Widget _header() {
    var row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 5,
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              Profile_Text,
              style: appBarTitleTextStyle,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.edit,
            color: MediumGreyColor,
            size: 20,
          ),
          onPressed: () {
            onEditClicked();
          },
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
    Padding pad = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: row,
    );
    return pad;
  }

  void onEditClicked() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => EditProfilePage()),
    );
  }
}
