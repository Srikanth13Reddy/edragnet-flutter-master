import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/signup_model.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/succes_response.dart';
import 'package:dragnet/screens/common/login_screen.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignUpState();
  }
}

class SignUpState extends State<SignUpPage> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Position _currentPosition;
  String _latitude;
  String _longitude;
  String _currentAddress;
  bool _isLoading = false;
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getCurrentLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _latitude = _currentPosition.latitude.toString();
        _longitude = _currentPosition.longitude.toString();
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await Geolocator().placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.name},${place.thoroughfare},${place.subLocality},${place.locality},${place.administrativeArea},${place.country},${place.postalCode}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: CustomProgressBar(
          isLoading: _isLoading,
          widget: loginCard(context),
        ),
      ),
    );
  }

  Widget _logo() {
    AssetImage asset = AssetImage("images/map_logo.png");
    Image image = Image(
      alignment: Alignment.topCenter,
      image: asset,
      width: 330.0,
      height: 220.0,
      fit: BoxFit.cover,
    );
    Padding padding = Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: image,
    );
    var align = Align(
      alignment: Alignment.topCenter,
      child: padding,
    );
    return align;
  }

  Widget _signUpButton() {
    var loginBtn = Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 45.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.all(10.0),
          color: BlueColor,
          textColor: Colors.white,
          child: Text(SignUp_Text,
              textScaleFactor: 1.15, style: btnTextStyleWhite),
          onPressed: () {
            setState(() async {
              if (_formKey.currentState.validate()) {
                bool connectionResult = await Utility.checkConnection();
                if (connectionResult) {
                  setState(() {
                    _isLoading = true;
                  });

                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    SignUpModel newPost = new SignUpModel(
                        name: userNameController.text,
                        profileImage: '',
                        email: emailController.text,
                        password: passwordController.text,
                        latitude: _latitude,
                        longitude: _longitude,
                        address: _currentAddress,
                        phoneNumber: phoneNumberController.text,
                        roleId: 3);
                    await createUserPost(SignUp_Url, body: newPost.toMap());
                  } else {
                    _errorAlert(context,
                        Error_Password_And_Confirm_Password_do_not_match);
                  }
                } else {
                  Utility.showToast(context, Error_No_Internet_Text);
                }
              }
            });
          },
        ),
      ),
    );
    return loginBtn;
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

  Future createUserPost(String url, {Map body}) async {
    try {
      API.postAPI(url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          final Map parsed = json.decode(response.body);
          debugPrint('Response body: ${parsed}');
          final user = SuccessResponse.fromJson(parsed);
          setState(() {
            _isLoading = false;
          });

          Utility.showToast(context, user.message);

          setState(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => LoginPage()));
            _clearInputs();
          });

          //_ackAlert(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          Utility.showAlert(context, 'Error', user.errorMessage);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _clearInputs() {
    emailController.text = '';
    userNameController.text = "";
    phoneNumberController.text = "";
    passwordController.text = '';
    confirmPasswordController.text = "";
  }

  Widget _userNameTextField() {
    var username = TextFormField(
      style: textBoxTextStyleBlack,
      controller: userNameController,
      validator: (String value) {
        if (value.isEmpty) {
          return Error_UserName_Empty;
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          suffixIcon: Icon(
            FontAwesomeIcons.user,
            color: MediumGreyColor,
            size: 18,
          ),
          hintText: UserName_Text,
          hintStyle: textBoxHintTextStyle,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: username,
    );
  }

  Widget _emailTextField() {
    var email = TextFormField(
      style: textBoxTextStyleBlack,
      controller: emailController,
      validator: (String value) {
        if (value.isEmpty) {
          return Error_Email_Empty;
        } else {
          var _isValid = validateEmail(value);
          if (_isValid) {
            return Error_Invalid_Email_Format;
          } else {
            return null;
          }
        }
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: AshColor,
        suffixIcon: Icon(
          FontAwesomeIcons.envelope,
          color: MediumGreyColor,
          size: 18,
        ),
        hintText: Email_Text,
        hintStyle: textBoxHintTextStyle,
        enabledBorder: textBoxEnabledUnderlineDecoration,
        focusedBorder: textBoxFocusedUnderlineDecoration,
        errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      child: email,
    );
  }

  Widget _phoneNoTextField() {
    var phone = TextFormField(
      style: textBoxTextStyleBlack,
      controller: phoneNumberController,
      validator: (String value) {
        if (value.isEmpty) {
          return Error_PhoneNumber_Empty;
        } else if (value.length < 10) {
          return Error_PhoneNumber_MaxLength;
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        filled: true,
        fillColor: AshColor,
        suffixIcon: Icon(
          FontAwesomeIcons.phone,
          color: MediumGreyColor,
          size: 18,
        ),
        hintText: PhoneNo_hint_Text,
        hintStyle: textBoxHintTextStyle,
        enabledBorder: textBoxEnabledUnderlineDecoration,
        focusedBorder: textBoxFocusedUnderlineDecoration,
        errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      child: phone,
    );
  }

  Widget _passwordTextField() {
    var password = TextFormField(
      obscureText: _passwordVisible,
      style: textBoxTextStyleBlack,
      controller: passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return Error_please_enter_the_password;
        } else {
          if (value.length < 6)
            return Error_Password_should_have_at_least_6_characters;
          else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          iconSize: 20,
          icon: Icon(
            _passwordVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            color: MediumGreyColor,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              if (_passwordVisible) {
                _passwordVisible = false;
              } else {
                _passwordVisible = true;
              }
            });
          },
        ),
        filled: true,
        fillColor: AshColor,
        hintText: Password_Text,
        hintStyle: textBoxHintTextStyle,
        enabledBorder: textBoxEnabledUnderlineDecoration,
        focusedBorder: textBoxFocusedUnderlineDecoration,
        errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      child: password,
    );
  }

  Widget _confirmPasswordTextField() {
    var password = TextFormField(
      obscureText: _confirmPasswordVisible,
      style: textBoxTextStyleBlack,
      controller: confirmPasswordController,
      validator: (String value) {
        if (value.isEmpty) {
          return Error_please_enter_the_confirm_password;
        } else {
          if (passwordController.text != value) {
            return Error_Password_And_Confirm_Password_do_not_match;
          } else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          iconSize: 20,
          icon: Icon(
            _confirmPasswordVisible
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            color: MediumGreyColor,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              if (_confirmPasswordVisible) {
                _confirmPasswordVisible = false;
              } else {
                _confirmPasswordVisible = true;
              }
            });
          },
        ),
        filled: true,
        fillColor: AshColor,
        hintText: ConfirmPassword_Text,
        hintStyle: textBoxHintTextStyle,
        enabledBorder: textBoxEnabledUnderlineDecoration,
        focusedBorder: textBoxFocusedUnderlineDecoration,
        errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      child: password,
    );
  }

  Widget loginCard(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(left: 30, right: 30),
        children: <Widget>[
          _logo(),
          Center(
            child: Text(
              Get_Started_Text,
              style: titleTextStyleBlack,
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Center(
            child: Text(
              Hello_There_Sign_Up_Text,
              style: subTitleTextStyleGrey,
            ),
          ),
          SizedBox(
            height: 3,
          ),
          _orSignIn(),
          SizedBox(
            height: 35,
          ),
          _userNameTextField(),
          SizedBox(
            height: 5,
          ),
          _emailTextField(),
          SizedBox(
            height: 5,
          ),
          _phoneNoTextField(),
          SizedBox(
            height: 5,
          ),
          _passwordTextField(),
          SizedBox(
            height: 5,
          ),
          _confirmPasswordTextField(),
          SizedBox(
            height: 10,
          ),
          _signUpButton(),
        ],
      ),
    );
  }

  Widget _orSignIn() {
    var text = RichText(
      text: TextSpan(
        text: Or_Text + "   ",
        style: subTitleTextStyleGrey,
        children: <TextSpan>[
          TextSpan(
            text: SignIn_Text,
            style: subTitleTextStyleBlue,
          ),
        ],
      ),
    );
    var align = Align(
      alignment: Alignment.center,
      child: text,
    );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      },
      child: align,
    );
  }
}
