import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/generateotp_request.dart';
import 'package:dragnet/models/requests/otpverify_request.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/succes_response.dart';
import 'package:dragnet/screens/common/resetpassword_screen.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OtpPage extends StatefulWidget {
  final String email;

  OtpPage({Key key, this.email}) : super(key: key);
  @override
  OtpPageState createState() => OtpPageState();
}

class OtpPageState extends State<OtpPage> {
  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();
  TextEditingController controller3 = new TextEditingController();
  TextEditingController controller4 = new TextEditingController();
  TextEditingController controller5 = new TextEditingController();
  TextEditingController controller6 = new TextEditingController();
  TextEditingController currController = new TextEditingController();
  String _email = '';
  bool _isLoading = false;
  var numberTextStyle =
      TextStyle(color: BlackColor, fontSize: 25.0, fontWeight: FontWeight.w400);

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
  }

  @override
  void initState() {
    super.initState();
    currController = controller1;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _email = widget.email;
    });
    List<Widget> widgetList = [
      Padding(
        padding: EdgeInsets.only(left: 0.0, right: 2.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
                color: Color(0xFFeaeaea),
                border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
                borderRadius: new BorderRadius.circular(4.0)),
            child: new TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
              ],
              enabled: false,
              controller: controller1,
              autofocus: false,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, color: Colors.black),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color(0xFFeaeaea),
              border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            controller: controller2,
            autofocus: false,
            enabled: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color(0xFFeaeaea),
              border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            keyboardType: TextInputType.number,
            controller: controller3,
            textAlign: TextAlign.center,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color(0xFFeaeaea),
              border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller4,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color(0xFFeaeaea),
              border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller5,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color(0xFFeaeaea),
              border: new Border.all(width: 1.0, color: Color(0xFFeaeaea)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller6,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 2.0, right: 0.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: _resendOtpButton(),
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomProgressBar(
          isLoading: _isLoading,
          widget: ListView(
            children: <Widget>[
              _logo(),
              Center(
                child: Text(
                  Otp_Verification_Text,
                  style: titleTextStyleBlack,
                ),
              ),
              Center(
                child: Text(
                  Otp_Verification_Hint_Text,
                  style: subTitleTextStyleGrey,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Flexible(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GridView.count(
                        crossAxisCount: 8,
                        mainAxisSpacing: 10.0,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.vertical,
                        children: List<Container>.generate(
                          8,
                          (int index) => Container(child: widgetList[index]),
                        ),
                      ),
                    ]),
                flex: 25,
              ),
              SizedBox(
                height: 20,
              ),
              Flexible(
                // fit: FlexFit.tight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 16.0, right: 0.0, bottom: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("1");
                              },
                              child: Text("1",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("2");
                              },
                              child: Text("2",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("3");
                              },
                              child: Text("3",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("4");
                              },
                              child: Text("4",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("5");
                              },
                              child: Text("5",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("6");
                              },
                              child: Text("6",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("7");
                              },
                              child: Text("7",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("8");
                              },
                              child: Text("8",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("9");
                              },
                              child: Text("9",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MaterialButton(
                                onPressed: () {
                                  deleteText();
                                },
                                child: Icon(
                                  Icons.backspace,
                                  color: Colors.grey,
                                )),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inputTextToField("0");
                              },
                              child: Text("0",
                                  style: numberTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            MaterialButton(
                                onPressed: () {
                                  matchOtp();
                                },
                                child: Icon(
                                  FontAwesomeIcons.check,
                                  color: Colors.green,
                                  size: 25,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                flex: 90,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resendOtpButton() {
    var text = RichText(
      text: TextSpan(
        text: Dont_Receive_Otp_Text + "   ",
        style: subTitleTextStyleGrey,
        children: <TextSpan>[
          TextSpan(
            text: Resend_Otp_Text,
            style: subTitleTextStyleBlue,
          ),
        ],
      ),
    );
//    var align = Align(
//      alignment: Alignment.center,
//      child: text,
//    );
    return FlatButton(
      onPressed: () async {
        GenerateOTP newPost = new GenerateOTP(email: _email);
        await resendOTPPut(Generate_Otp_Url, body: newPost.toMap());
      },
      child: text,
    );
  }

  Widget _logo() {
    AssetImage asset = AssetImage("images/map_logo.png");
    Image image = Image(
      alignment: Alignment.topCenter,
      image: asset,
      width: 330.0,
      height: 250.0,
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

  void inputTextToField(String str) {
    //Edit first textField
    if (currController == controller1) {
      controller1.text = str;
      currController = controller2;
    }

    //Edit second textField
    else if (currController == controller2) {
      controller2.text = str;
      currController = controller3;
    }

    //Edit third textField
    else if (currController == controller3) {
      controller3.text = str;
      currController = controller4;
    }

    //Edit fourth textField
    else if (currController == controller4) {
      controller4.text = str;
      currController = controller5;
    }

    //Edit fifth textField
    else if (currController == controller5) {
      controller5.text = str;
      currController = controller6;
    }

    //Edit sixth textField
    else if (currController == controller6) {
      controller6.text = str;
      currController = controller6;
    }
  }

  void deleteText() {
    if (currController.text.length == 0) {
    } else {
      currController.text = "";
      currController = controller5;
      return;
    }

    if (currController == controller1) {
      controller1.text = "";
    } else if (currController == controller2) {
      controller1.text = "";
      currController = controller1;
    } else if (currController == controller3) {
      controller2.text = "";
      currController = controller2;
    } else if (currController == controller4) {
      controller3.text = "";
      currController = controller3;
    } else if (currController == controller5) {
      controller4.text = "";
      currController = controller4;
    } else if (currController == controller6) {
      controller5.text = "";
      currController = controller5;
    }
  }

  void matchOtp() async {
    String _OtpValue = '';

    _OtpValue = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text +
        controller5.text +
        controller6.text;
    if (_OtpValue.length == 6) {
      OTPVerify newPost = new OTPVerify(otpValue: _OtpValue, email: _email);
      await verifyOTPPut(Otp_Verify_Url, body: newPost.toMap());
    } else {
      _errorAlert(context, 'Please enter 6 digit OTP.');
    }
  }

  Future verifyOTPPut(String url, {Map body}) async {
    setState(() {
      _isLoading = true;
    });
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

  Future resendOTPPut(String url, {Map body}) async {
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

  Future<bool> _successAlert(BuildContext context, String success) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 25, top: 10),
          title: Text('Success'),
          content: Text(success),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                print("success $success");
                if (success == "OTP sent successfully.") {
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ResetPasswordPage(
                            Email: _email,
                          )));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
