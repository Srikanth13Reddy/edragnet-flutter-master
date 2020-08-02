import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Login
  Future<bool> checkAlreadyLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    return status;
  }
}
