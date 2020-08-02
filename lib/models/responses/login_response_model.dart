class LoginResponse {
  int userId;
  String name;
  String phoneNumber;
  String email;
  String profileImage;
  String address;
  String latitude;
  String longitude;
  String role;
  int roleId;
  String token;

  LoginResponse({
    this.userId,
    this.name,
    this.phoneNumber,
    this.email,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
    this.role,
    this.roleId,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> parsedJson) {
    return LoginResponse(
      userId: parsedJson['userId'],
      name: parsedJson['name'] as String,
      phoneNumber: parsedJson['phoneNumber'] as String,
      email: parsedJson['email'] as String,
      profileImage: parsedJson['profileImage'] as String,
      address: parsedJson['address'] as String,
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      role: parsedJson['role'] as String,
      roleId: parsedJson['roleId'] as int,
      token: parsedJson['token'] as String,
    );
  }
}
