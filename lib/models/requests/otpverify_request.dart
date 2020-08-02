class OTPVerify {
  String otpValue;
  String email;

  OTPVerify({this.otpValue, this.email});

  factory OTPVerify.fromJson(Map<String, dynamic> parsedJson) {
    return OTPVerify(
      otpValue: parsedJson['otpValue'] as String,
      email: parsedJson['email'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["otpValue"] = otpValue;
    map["email"] = email;
    return map;
  }
}
