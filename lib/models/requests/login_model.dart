class LoginModel {
  String email;
  String password;
  String timeZone;

  LoginModel({
    this.email,
    this.password,
    this.timeZone,
  });

  factory LoginModel.fromJson(Map<String, dynamic> parsedJson) {
    return LoginModel(
      email: parsedJson['email'] as String,
      password: parsedJson['password'] as String,
      timeZone: parsedJson['timeZone'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;
    map["timeZone"] = timeZone;
    return map;
  }
}
