class ProviderLogin {
  String loginProvider;
  String loginProviderKey;
  String timeZone;

  ProviderLogin({
    this.loginProvider,
    this.loginProviderKey,
    this.timeZone,
  });

  factory ProviderLogin.fromJson(Map<String, dynamic> parsedJson) {
    return ProviderLogin(
      loginProvider: parsedJson['loginProvider'] as String,
      loginProviderKey: parsedJson['loginProviderKey'] as String,
      timeZone: parsedJson['timeZone'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["loginProvider"] = loginProvider;
    map["loginProviderKey"] = loginProviderKey;
    map["timeZone"] = timeZone;
    return map;
  }
}
