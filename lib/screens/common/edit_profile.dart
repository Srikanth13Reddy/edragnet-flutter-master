import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cache_image/cache_image.dart';
import 'package:dragnet/models/requests/signup_model.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/succes_response.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditProfilePageState();
  }
}

class EditProfilePageState extends State<EditProfilePage> {
  var _formKey = GlobalKey<FormState>();
  double screenHeight;
  TextEditingController userNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  Color borderColor = Color.fromRGBO(218, 218, 218, 1);
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
    super.initState();
    _loadGlobalValues();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Try reading data from the counter key. If it doesn't exist, return 0.
      _userId = prefs.getInt('UserId') ?? 0;
      _userName = prefs.getString('UserName') ?? '';
      _email = prefs.getString('Email') ?? '';
      _phoneNumber = prefs.getString('PhoneNumber') ?? '';
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
      print(ProfileImage);

      userNameController.text = _userName;
      emailController.text = _email;
      phoneNoController.text = _phoneNumber;
    });
  }

  void _updateGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Try reading data from the counter key. If it doesn't exist, return 0.
      _userId = prefs.getInt('UserId') ?? 0;
      prefs.setString('UserName', userNameController.text);
      prefs.setString('Email', emailController.text);
      prefs.setString('PhoneNumber', phoneNoController.text);
      prefs.setString('ProfileImage', ProfileImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: CustomProgressBar(
          isLoading: _isLoading,
          widget: Column(
            children: <Widget>[
              _header(),
              Expanded(
                child: _form(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  var _placeholderImage = AssetImage('images/profile.png');
  Widget _profileImage() {
    var cont = Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(top: 30.0),
        width: 140.0,
        height: 140.0,
        decoration: new BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              ),
            ],
            shape: BoxShape.circle,
            image: new DecorationImage(
              fit: BoxFit.cover,
              image: ProfileImage != null
                  ? CacheImage(ProfileImage)
                  : _placeholderImage,
            )));
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: cont,
        ),
        Positioned(
          top: 120,
          right: 0,
          left: 100,
          child: Container(
            // margin: EdgeInsets.only(top: 50.0),
            width: 35.0,
            height: 35.0,
            decoration: new BoxDecoration(
              color: Color.fromRGBO(24, 133, 239, 1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
              ),
              onPressed: () {
                _showPoppup(context);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _userNameTextFormField() {
    Padding email = Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0, bottom: 10.0),
        child: TextFormField(
          // keyboardType: TextInputType.emailAddress,
          style: textBoxTextStyleBlack,
          controller: userNameController,
          validator: (String value) {
            if (value.isEmpty) {
              return "please enter the username";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintStyle: textBoxHintTextStyle,
            labelText: UserName_Text,
            labelStyle: textBoxTextStyleGrey,
            errorStyle: textBoxErrorTextStyle,
            hintText: "Your User Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
          ),
        ));
    return email;
  }

  Widget _emailTextFormField() {
    Padding email = Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: TextFormField(
          // keyboardType: TextInputType.emailAddress,
          style: textBoxTextStyleBlack,
          controller: emailController,
          validator: (String value) {
            if (value.isEmpty) {
              return "please enter the mail Id.";
            } else {
              var _isValid = validateEmail(value);
              if (_isValid) {
                return "Not a Valid Email Format.";
              } else {
                return null;
              }
            }
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintStyle: textBoxHintTextStyle,
            labelText: Email_Text,
            labelStyle: textBoxTextStyleGrey,
            errorStyle: textBoxErrorTextStyle,
            hintText: Email_hint_Text,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
          ),
        ));
    return email;
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  // var controller = new MaskedTex(mask: '(000) 000 0000');

  Widget _phoneTextFormField() {
    Padding email = Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: TextFormField(
          // keyboardType: TextInputType.emailAddress,
          style: textBoxTextStyleBlack,
          controller: phoneNoController,
          validator: (String value) {
            if (value.isEmpty) {
              return "please enter your phone number";
            } else if (value.length < 10) {
              return "Phone number should be 10 digits";
            } else {
              return null;
            }
          },
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintStyle: textBoxHintTextStyle,
            labelText: PhoneNo_hint_Text,
            labelStyle: textBoxTextStyleGrey,
            errorStyle: textBoxErrorTextStyle,
            hintText: "Your Phone Number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
          ),
        ));
    return email;
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
              EditProfile_Text,
              style: appBarTitleTextStyle,
            ),
          ),
        ),
      ],
    );
    Padding pad = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: row,
    );
    return pad;
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          _profileImage(),
          _userNameTextFormField(),
          //_fullNameTextFormField(),
          _emailTextFormField(),
          _phoneTextFormField(),
          Align(
            child: _updateButton(),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }

  var _imagePath;
  //Open Camera Functionality
  Future openCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      _imagePath = image.path;
      getUploadImg(_image, "AHC.jpg");
    });
  }

  //Pick Image from Gallery
  Future openGallery() async {
    var gallery = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = gallery;
      _imagePath = gallery.path;
      getUploadImg(_image, "AHC.jpg");
    });
  }

  Widget _takeButton() {
    var loginBtn = Padding(
        padding: EdgeInsets.only(top: 40.0, bottom: 10.0, left: 25, right: 25),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          // height: double.infinity,
          child: new RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(10.0),
            color: Color.fromRGBO(27, 29, 77, 1),
            textColor: Colors.white,
            child: Text(
              'Take Photo',
              //textScaleFactor: 1.25,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              setState(() async {
                Navigator.pop(context);
                openCamera();
              });
            },
          ),
        ));
    return loginBtn;
  }

  Widget _chooseButton() {
    var loginBtn = Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25, right: 25),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          // height: double.infinity,
          child: new RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(10.0),
            color: Color.fromRGBO(24, 133, 239, 1),
            textColor: Colors.white,
            child: Text(
              'Choose Photo',
              //textScaleFactor: 1.25,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              setState(() async {
                Navigator.pop(context);
                openGallery();
              });
            },
          ),
        ));
    return loginBtn;
  }

  Widget _updateButton() {
    var updateBtn = Padding(
        padding: EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: 140,
          height: 45.0,
          // height: double.infinity,
          child: new RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.all(10.0),
            color: DarkBlueColor,
            textColor: Colors.white,
            child: Text(
              Update_Text,
              textScaleFactor: 1.15,
              style: btnTextStyleWhite,
            ),
            onPressed: () {
              setState(() async {
                if (_formKey.currentState.validate()) {
                  SignUpModel newPost = new SignUpModel(
                    userId: _userId,
                    name: userNameController.text,
                    profileImage: ProfileImage,
                    email: emailController.text,
                    phoneNumber: phoneNoController.text,
                  );
                  await createPost(Update_User_Url, body: newPost.toMap());
                }
              });
            },
          ),
        ));
    var row = Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        Expanded(
          child: updateBtn,
        ),
        Expanded(
          child: SizedBox(),
        ),
      ],
    );
    return row;
  }

  Future getUploadImg(_image, name) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API
          .uploadImageAPI(Upload_Image_Url, _image, _imagePath, name)
          .then((response) async {
        final int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        if (statusCode == 200) {
          String reply = await response.stream.transform(utf8.decoder).join();
          Map valueMap = json.decode(reply);
          var icon = valueMap['fileUrl'];
          setState(() async {
            ProfileImage = icon;
            _updateGlobalValues();
            _profileIcon = Image.network(
              ProfileImage,
            );
            _isLoading = false;
            SignUpModel newPost = new SignUpModel(
              userId: _userId,
              profileImage: ProfileImage,
            );
            await _uploadImageUrl(Update_User_Url, body: newPost.toMap());
          });
        } else {
          await response.stream.transform(utf8.decoder).join();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _uploadImageUrl(String url, {Map body}) async {
    setState(() {
      _isLoading = true;
    });
    http
        .put(
      url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
      body: jsonEncode(body),
    )
        .then((http.Response response) async {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        Utility.showToast(context, Image_uploaded_successfully_Text);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  //custom poppup for user able tos select image options..
  Widget _showPoppup(BuildContext context) {
    showDialog(
      //to avoid outside touch close the dialog
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Container(
            //margin: EdgeInsets.only(left: 10, right: 10),
            height: 350.0,
            width: double.infinity,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 30),
                Center(
                  child: Text(
                    "Upload Profile Photo",
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Color.fromRGBO(27, 29, 77, 1),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "      Would you like to take photo or choose existing photo?",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Color.fromRGBO(27, 29, 77, 1),
                      ),
                    ),
                  ),
                ),
                _takeButton(),
                _chooseButton(),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      textScaleFactor: 1.25,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(27, 29, 77, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future createPost(String url, {Map body}) async {
    setState(() {
      _isLoading = true;
    });
    http
        .put(
      url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
      body: json.encode(body),
    )
        .then((http.Response response) async {
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        setState(() {
          _isLoading = false;
          _updateGlobalValues();
        });
        final Map parsed = json.decode(response.body);
        final user = SuccessResponse.fromJson(parsed);
        await Utility.showAlert(context, 'Success', user.message);
      } else {
        setState(() {
          _isLoading = false;
        });
        final Map parsed = json.decode(response.body);
        final user = ErrorResponse.fromJson(parsed);
        debugPrint('Response Error: ${user.errorMessage}');
        await Utility.showAlert(context, 'Error', user.errorMessage);
        throw new Exception("Error while fetching data");
        //_errorAlert(context);
      }
    });
  }

  // Error Alert Widget & Function
  Future<bool> _errorAlert(BuildContext context, String error) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 25, top: 10),
          title: Text('Error'),
          content: Text(error),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
