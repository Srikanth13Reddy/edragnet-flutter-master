import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/forgetpassword_request.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/succes_response.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ResetPasswordPage extends StatefulWidget {
  final String Email;

  ResetPasswordPage({Key key, this.Email}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ResetPasswordPageState();
  }
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  String _email;
  var _formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    _email = widget.Email;
    return Scaffold(
      body: CustomProgressBar(
        isLoading: _isLoading,
        widget: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _logo(),
              _titleText(),
              _passwordTextField(),
              _confirmPasswordTextField(),
              _doneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    AssetImage asset = AssetImage("images/map_logo.png");
    Image image = Image(
      alignment: Alignment.topCenter,
      image: asset,
      width: 300.0,
      height: 220.0,
      fit: BoxFit.cover,
    );
    Padding padding = Padding(
      padding: EdgeInsets.only(top: 80.0),
      child: image,
    );
    return padding;
  }

  bool _newPasswordVisible = true;
  bool _confirmPasswordVisible = true;

  Widget _passwordTextField() {
    var password = TextFormField(
      obscureText: _newPasswordVisible,
      style: textBoxTextStyleBlack,
      controller: newPasswordController,
      validator: (String value) {
        if (value == "") {
          return "please enter the password";
        } else {
          if (value.length < 6)
            return "Password should have at least 6 characters";
          else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          iconSize: 20,
          icon: Icon(
            _newPasswordVisible
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            color: MediumGreyColor,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              if (_newPasswordVisible) {
                _newPasswordVisible = false;
              } else {
                _newPasswordVisible = true;
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
        //errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 25, right: 25, top: 35),
      child: password,
    );
  }

  Widget _confirmPasswordTextField() {
    var password = TextFormField(
      obscureText: _confirmPasswordVisible,
      style: textBoxTextStyleBlack,
      controller: confirmPasswordController,
      validator: (String value) {
        if (value == "") {
          return "please enter the confirm password";
        } else {
          if (newPasswordController.text != value) {
            return "Password and Confirm Password do not match.";
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
      borderOnForeground: true,
      margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: password,
    );
  }

  Widget _titleText() {
    return Center(
      child: Text(
        Reset_Password_Text,
        style: titleTextStyleBlack,
      ),
    );
  }

  Widget _doneButton() {
    var loginBtn = Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25, top: 35),
      child: SizedBox(
        width: double.infinity,
        height: 45.0,
        // height: double.infinity,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.all(10.0),
          color: BlueColor,
          child: Text(
            Update_Text,
            textScaleFactor: 1.15,
            style: btnTextStyleWhite,
          ),
          onPressed: () {
            setState(() async {
              if (_formKey.currentState.validate()) {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  ForgetPassword newPost = new ForgetPassword(
                      email: _email, password: newPasswordController.text);

                  ForgetPassword p = await updatePasswordPut(
                      Update_Password_Url,
                      body: newPost.toMap());
                } else {
                  _errorAlert(
                      context, 'Password and Confirm Password do not match.');
                }
              }
            });
          },
        ),
      ),
    );
    return loginBtn;
  }

  Future updatePasswordPut(String url, {Map body}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API.putAPI(Update_Password_Url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          print(statusCode);
          final jsonData = json.decode(response.body);
          final user = SuccessResponse.fromJson(jsonData);
          _successAlert(context, user.message);
        } else {
          setState(() {
            _isLoading = false;
          });
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          print("Map Body ${user.errorMessage}");
          _errorAlert(context, user.errorMessage);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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

  Future<bool> _successAlert(BuildContext context, String succes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 25, top: 10),
          title: Text('Success'),
          content: Text(succes),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', ModalRoute.withName('/login'));
              },
            ),
          ],
        );
      },
    );
  }
}
