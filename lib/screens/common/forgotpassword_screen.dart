import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/generateotp_request.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/succes_response.dart';
import 'package:dragnet/screens/common/otp_screen.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ForgotPasswordPageState();
  }
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomProgressBar(
        isLoading: _isLoading,
        widget: _body(),
      ),
    );
  }

  Widget _body() {
    var col = Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _logo(),
        _titleText(),
        SizedBox(
          height: 5,
        ),
        Center(
          child: Text(
            ForgotPassword_hint_Text,
            style: subTitleTextStyleGrey,
          ),
        ),
        _emailTextFormField(),
        _sendButton(),
      ],
    );

    var _form = Form(key: _formKey, child: col);
    return _form;
  }

  Widget _logo() {
    AssetImage asset = AssetImage("images/map_logo.png");
    Image image = Image(
      alignment: Alignment.topCenter,
      image: asset,
      width: 300.0,
      height: 250.0,
      fit: BoxFit.cover,
    );
    Padding padding = Padding(
      padding: EdgeInsets.only(top: 100.0),
      child: image,
    );
    var align = Align(
      alignment: Alignment.topCenter,
      child: padding,
    );
    return align;
  }

  Widget _titleText() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        ForgotPassword_Text,
        style: titleTextStyleBlack,
      ),
    );
  }

  TextEditingController emailController = TextEditingController();

  Widget _emailTextFormField() {
    var email = TextFormField(
      // keyboardType: TextInputType.emailAddress,
      style: textBoxTextStyleBlack,
      controller: emailController,
      validator: (String value) {
        if (value.isEmpty) {
          return "provide your mail id to proceed.";
        } else {
          var isValid = validateEmail(value);
          if (isValid) {
            return "Not a Valid Email Format.";
          } else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AshColor,
        suffixIcon: Icon(
          FontAwesomeIcons.envelope,
          color: MediumGreyColor,
          size: 18,
        ),
        hintText: Email_hint_Text,
        hintStyle: textBoxHintTextStyle,
        enabledBorder: textBoxEnabledUnderlineDecoration,
        focusedBorder: textBoxFocusedUnderlineDecoration,
        errorStyle: textBoxErrorTextStyle,
      ),
    );
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 30, right: 30, top: 25),
      child: email,
    );
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

  Widget _sendButton() {
    var loginBtn = Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30, top: 25),
      child: SizedBox(
        width: double.infinity,
        height: 45.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.all(10.0),
          color: BlueColor,
          child: Text(
            Get_Otp_Text,
            textScaleFactor: 1.15,
            style: btnTextStyleWhite,
          ),
          onPressed: () {
            setState(() async {
              if (_formKey.currentState.validate()) {
                GenerateOTP newPost =
                    new GenerateOTP(email: emailController.text);
                await generateOTPPut(Generate_Otp_Url, body: newPost.toMap());
              }
            });
          },
        ),
      ),
    );
    return loginBtn;
  }

  Future generateOTPPut(String url, {Map body}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API.putAPI(url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => OtpPage(
                          email: emailController.text,
                        )));
              },
            ),
          ],
        );
      },
    );
  }
}
