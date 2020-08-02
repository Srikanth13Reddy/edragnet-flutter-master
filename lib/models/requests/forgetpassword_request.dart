class ForgetPassword {
  String email;
  String password;

  ForgetPassword({this.email, this.password});

  factory ForgetPassword.fromJson(Map<String, dynamic> parsedJson) {
    return ForgetPassword(
      email: parsedJson['email'] as String,
      password: parsedJson['password'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;
    return map;
  }
}
