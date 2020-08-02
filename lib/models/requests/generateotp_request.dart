class GenerateOTP {
  String email;

  GenerateOTP({this.email});

  factory GenerateOTP.fromJson(Map<String, dynamic> parsedJson) {
    return GenerateOTP(
      email: parsedJson['email'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    return map;
  }
}
