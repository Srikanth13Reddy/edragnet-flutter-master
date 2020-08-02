import 'package:dragnet/models/responses/crime_details.dart';
import 'package:dragnet/screens/admin/admin_home.dart';
import 'package:dragnet/screens/agent/agent_home.dart';
import 'package:dragnet/screens/common/login_screen.dart';
import 'package:dragnet/screens/user/home_screen.dart';
import 'package:dragnet/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthService appAuth = new AuthService();
bool result;
int roleID;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  result = await appAuth.checkAlreadyLogin();
//  final prefs = await SharedPreferences.getInstance();
//   roleID = prefs.getInt('RoleId') ?? '';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eDragnet',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/home': (BuildContext context) => HomePage(),
        '/adminhome': (BuildContext context) => AdminHome(),
        '/agenthome': (BuildContext context) => AgentHome()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: result ? AgentHome() : AgentHome(),
    );
  }

  Widget navPage()
  {

    if(roleID==1)
    {
      return AdminHome();
    }
    else if(roleID==2)
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
  }



}
