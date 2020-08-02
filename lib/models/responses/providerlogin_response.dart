class GoogleLoginResponse {
  int userId;
  String name;
  String phoneNumber;
  String email;
  String profileImage;
  String address;
  String latitude;
  String longitude;
  String role;
  bool isNewEntry;
  int roleId;
  String token;

  GoogleLoginResponse({
    this.userId,
    this.name,
    this.phoneNumber,
    this.email,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
    this.role,
    this.isNewEntry,
    this.roleId,
    this.token,
  });

  factory GoogleLoginResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GoogleLoginResponse(
      userId: parsedJson['userId'],
      name: parsedJson['name'] as String,
      phoneNumber: parsedJson['phoneNumber'] as String,
      email: parsedJson['email'] as String,
      profileImage: parsedJson['profileImage'] as String,
      address: parsedJson['address'] as String,
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      role: parsedJson['role'] as String,
      isNewEntry: parsedJson['isNewEntry'] as bool,
      roleId: parsedJson['roleId'] as int,
      token: parsedJson['token'] as String,
    );
  }
}

class AccessToken {
  String refreshToken;
  String token;
  String expireIn;

  AccessToken({this.refreshToken, this.token, this.expireIn});

  factory AccessToken.fromJson(Map<String, dynamic> parsedJson) {
    return AccessToken(
      refreshToken: parsedJson['refreshToken'] as String,
      token: parsedJson['token'] as String,
      expireIn: parsedJson['expireIn'] as String,
    );
  }
}
