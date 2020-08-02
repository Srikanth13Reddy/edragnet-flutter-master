import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/login_model.dart';
import 'package:dragnet/models/requests/providerlogin_request.dart';
import 'package:dragnet/models/requests/savedeviceid_request.dart';
import 'package:dragnet/models/requests/updatenotification_request.dart';
import 'package:dragnet/models/responses/crime_details.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/login_response_model.dart';
import 'package:dragnet/models/responses/providerlogin_response.dart';
import 'package:dragnet/screens/admin/admin_home.dart';
import 'package:dragnet/screens/agent/agent_home.dart';
import 'package:dragnet/screens/common/forgotpassword_screen.dart';
import 'package:dragnet/screens/common/google_signin.dart';
import 'package:dragnet/screens/common/signup_screen.dart';
import 'package:dragnet/screens/user/home_screen.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  int _userId = 0;
  bool _passwordVisible = true;
  String crimeId;
  String crimeName;
  String crimeDescription;
  String occurrenceAddress;
  String occurrenceLatitude;
  String occurrenceLongitude;
  String timeOfOccurrence;
  String dateOfOccurrence;
  String notificationId;
  String severity;
  String _notificationTokenId = '';
  var _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: "santhoshr@apptomate.co");
  TextEditingController passwordController =
      TextEditingController(text: "123456");
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  String _timeZone;

  @override
  void initState() {
    super.initState();
    _checkTimeZone();
    _initializeFirebaseFcmPushNotification();
  }

  _checkTimeZone() async {
    try {
      _timeZone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      _timeZone = 'Failed to get the timezone.';
    }
    if (!mounted) return;
  }

  void _initializeFirebaseFcmPushNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);

    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message ${message}');
        displayNotification(message);
        var id = message['data']['crimeId'];
        crimeId = id.toString();
        crimeName = message['data']['crimeName'];
        crimeDescription = message['data']['crimeDescription'];
        occurrenceAddress = message['data']['occurrenceAddress'];
        occurrenceLatitude = message['data']['occurrenceLatitude'];
        occurrenceLongitude = message['data']['occurrenceLongitude'];
        timeOfOccurrence = message['data']['timeOfOccurrence'];
        dateOfOccurrence = message['data']['dateOfOccurence'];
        notificationId = message['data']['notificationId'];
        severity = message['data']['severity'];
      },
      //onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) {
        var id = message['data']['crimeId'];
        crimeId = id.toString();
        crimeName = message['data']['crimeName'];
        crimeDescription = message['data']['crimeDescription'];
        occurrenceAddress = message['data']['occurrenceAddress'];
        occurrenceLatitude = message['data']['occurrenceLatitude'];
        occurrenceLongitude = message['data']['occurrenceLongitude'];
        timeOfOccurrence = message['data']['timeOfOccurrence'];
        dateOfOccurrence = message['data']['dateOfOccurence'];
        notificationId = message['data']['notificationId'];
        severity = message['data']['severity'];
        if (message != null) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new HomePage(
                        isMissing: true,
                        crimeDetails: CrimeDetails(
                          this.crimeId,
                          crimeName,
                          crimeDescription,
                          occurrenceAddress,
                          occurrenceLatitude,
                          occurrenceLongitude,
                          timeOfOccurrence,
                          dateOfOccurrence,
                          notificationId,
                          severity,
                        ),
                      )));
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        var id = message['data']['crimeId'];
        crimeId = id.toString();
        crimeName = message['data']['crimeName'];
        crimeDescription = message['data']['crimeDescription'];
        occurrenceAddress = message['data']['occurrenceAddress'];
        occurrenceLatitude = message['data']['occurrenceLatitude'];
        occurrenceLongitude = message['data']['occurrenceLongitude'];
        timeOfOccurrence = message['data']['timeOfOccurrence'];
        dateOfOccurrence = message['data']['dateOfOccurence'];
        notificationId = message['data']['notificationId'];
        severity = message['data']['severity'];

        if (message != null) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new HomePage(
                        isMissing: true,
                        crimeDetails: CrimeDetails(
                          this.crimeId,
                          crimeName,
                          crimeDescription,
                          occurrenceAddress,
                          occurrenceLatitude,
                          occurrenceLongitude,
                          timeOfOccurrence,
                          dateOfOccurrence,
                          notificationId,
                          severity,
                        ),
                      )));
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      if (token != null) {
        _notificationTokenId = token;
        print(token);
      }
    });
  }

  void _updateNotificationStatus(int _notificationId) async {
    UpdateUserNotificationModel newPost = new UpdateUserNotificationModel(
      notificationId: _notificationId,
    );
    UpdateUserNotificationModel p = await updateNotificationPost(
        Update_Notification_Url,
        body: newPost.toMap());
  }

  Future updateNotificationPost(String url, {Map body}) async {
    try {
      API.postAPI(url, "", body).then((response) {
        final int statusCode = response.statusCode;
      });
    } catch (e) {
      print(e);
    }
  }

  Future displayNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channelid', 'flutterfcm', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['data']['crimeName'],
      message['data']['occurrenceAddress'],
      platformChannelSpecifics,
      payload: message['data']['crimeId'],
    );
  }

  Future onSelectNotification(String payload) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => HomePage(
              isMissing: true,
              crimeDetails: CrimeDetails(
                this.crimeId,
                crimeName,
                crimeDescription,
                occurrenceAddress,
                occurrenceLatitude,
                occurrenceLongitude,
                timeOfOccurrence,
                dateOfOccurrence,
                notificationId,
                severity,
              ),
            )));
    _updateNotificationStatus(int.parse(this.crimeId));
  }

  Map<String, dynamic> notification;
  Map<String, dynamic> data;
  void _saveNotificationData(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      data = message['data'];
    }
    if (message.containsKey('notification')) {
      notification = message['notification'];
    }
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              Utility.showToast(context, "Notification Clicked");
            },
          ),
        ],
      ),
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
    }
    if (message.containsKey('notification')) {
      final dynamic notification = message['notification'];
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

  Widget _forgotPassword() {
    var forgot = FlatButton(
      padding: EdgeInsets.only(right: 0, top: 5.0),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ForgotPasswordPage()));
      },
      child: Text(
        ForgotPassword_Text,
        style: subTitleTextStyleBlue,
      ),
    );
    var align = Align(
      child: forgot,
      alignment: Alignment.center,
    );
    return align;
  }

  Widget _loginButton() {
    var loginBtn = Padding(
      padding: EdgeInsets.only(top: 20.0),
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
          child: Text(
            SignIn_Text,
            textScaleFactor: 1.15,
            style: btnTextStyleWhite,
          ),
          onPressed: () {
            setState(() async {
              if (_formKey.currentState.validate()) {
                bool connectionResult = await Utility.checkConnection();
                if (connectionResult) {
                  setState(() {
                    _isLoading = true;
                  });
                  LoginModel newPost = new LoginModel(
                    email: emailController.text,
                    password: passwordController.text,
                    timeZone: _timeZone,
                  );
                  await _loginPost(Login_Url, body: newPost.toMap());
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
        hintText: Email_hint_Text,
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

  Widget _passwordTextField() {
    var password = TextFormField(
      controller: passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return "please enter the password";
        } else {
          if (value.length < 6)
            return "Password should have at least 6 characters";
          else {
            return null;
          }
        }
      },
      style: textBoxTextStyleBlack,
      obscureText: _passwordVisible,
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
        hintText: Password_hint_Text,
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

  Widget loginCard(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 30, right: 30),
        child: ListView(
          children: <Widget>[
            _logo(),
            Center(
              child: Text(
                Welcome_Back_Text,
                style: titleTextStyleBlack,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Center(
              child: Text(
                Hello_There_Text,
                style: subTitleTextStyleGrey,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            _orCreateNewAccount(),
            SizedBox(
              height: 40,
            ),
            _emailTextField(),
            SizedBox(
              height: 10,
            ),
            _passwordTextField(),
            SizedBox(
              height: 6,
            ),
            _loginButton(),
            _forgotPassword(),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    indent: 10,
                    endIndent: 20,
                    thickness: 1,
                    color: BorderColor,
                  ),
                ),
                Text(
                  'or',
                  style: subTitleTextStyleGrey,
                ),
                Expanded(
                  child: Divider(
                    indent: 20,
                    endIndent: 10,
                    thickness: 1,
                    color: BorderColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            _googleLoginButton(),
            SizedBox(
              height: 15,
            ),
            //_signUpButton()
          ],
        ),
      ),
    );
  }

  Widget _orCreateNewAccount() {
    var text = RichText(
      text: TextSpan(
        text: Or_Text + "   ",
        style: subTitleTextStyleGrey,
        children: <TextSpan>[
          TextSpan(
            text: Create_New_Account_Text,
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
            MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
      },
      child: align,
    );
  }

  Future _loginPost(String url, {Map body}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API.postAPI(url, "", body).then((response) async {
        setState(() {
          _isLoading = false;
        });
        final int statusCode = response.statusCode;
        print("statusCode $statusCode");
        if (statusCode == 200) {
          final Map parsed = json.decode(response.body);
          final user = LoginResponse.fromJson(parsed);
          final sharedPref = await SharedPreferences.getInstance();
          sharedPref.setInt('UserId', user.userId);
          sharedPref.setBool('IsGoogleLoggedIn', false);
          _userId = user.userId;
          sharedPref.setString('UserName', user.name);
          sharedPref.setString('Email', user.email);
          sharedPref.setString('ProfileImage', user.profileImage);
          sharedPref.setBool("isLoggedIn", true);
          sharedPref.setInt('RoleId', user.roleId);
          sharedPref.setString('AccessToken', user.token);
          _saveDeviceIdAPI();
          _clearInputs();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {

                if(user.roleId==1)
                  {
                    return AdminHome();
                  }else if (user.roleId==2)
                    {
                      return AgentHome();
                    }else
                      {
                        return HomePage(
                          isMissing: false,
                          crimeDetails:
                          CrimeDetails('', '', '', '', '', '', '', '', '', ''),
                        );
                      }


              },
            ),
          );
        } else {
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          Utility.showToast(context, user.errorMessage);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveDeviceIdAPI() async {
    SaveDeviceIdRequest newPost = new SaveDeviceIdRequest(
        userId: _userId, deviceId: _notificationTokenId);
    await saveDeviceIdPost(Save_DeviceId_Url, body: newPost.toMap());
  }

  Future saveDeviceIdPost(String url, {Map body}) async {
    try {
      API.postAPI(url, "", body).then((response) {
        final int statusCode = response.statusCode;
      });
    } catch (e) {
      print(e);
    }
  }

  void _clearInputs() {
    emailController.text = '';
    passwordController.text = '';
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

  Widget _googleLoginButton() {
    var startBtn = Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 20.0, right: 20),
      child: SizedBox(
        height: 45.0,
        width: double.infinity,
        child: new RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          icon: Image.asset("images/google_logo.png"),
          color: DarkAshColor,
          textColor: Colors.white,
          label: Text(
            Connect_With_Google_Text,
            style: btnTextStyleGrey,
          ),
          onPressed: () {
            setState(() async {
              signInWithGoogle().whenComplete(() {
                _updateGoogleSignIn();
              });
            });
          },
        ),
      ),
    );
    return startBtn;
  }

  void _updateGoogleSignIn() async {
    ProviderLogin newPost = new ProviderLogin(
      loginProvider: "com.google",
      loginProviderKey: provider,
      timeZone: _timeZone,
    );
    await createEmailAuthenticationPost(Provider_Login_Url,
        body: newPost.toMap());
  }

  Future createEmailAuthenticationPost(String url, {Map body}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API.postAPI(url, "", body).then((response) async {
        final int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        if (statusCode == 200) {
          final Map parsed = json.decode(response.body);
          final user = GoogleLoginResponse.fromJson(parsed);
          final sharedPre = await SharedPreferences.getInstance();
          _userId = user.userId;
          sharedPre.setBool("isLoggedIn", false);
          sharedPre.setBool('IsGoogleLoggedIn', true);
          sharedPre.setString('UserName', name);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          );
        } else {
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          Utility.showToast(context, user.errorMessage);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
