class SignUpModel {
  int userId;
  String name;
  String profileImage;
  String phoneNumber;
  String email;
  String password;
  String address;
  String latitude;
  String longitude;
  int roleId;

  SignUpModel({
    this.userId,
    this.name,
    this.profileImage,
    this.phoneNumber,
    this.email,
    this.password,
    this.address,
    this.latitude,
    this.longitude,
    this.roleId,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> parsedJson) {
    return SignUpModel(
      userId: parsedJson['userId'],
      name: parsedJson['name'] as String,
      profileImage: parsedJson['profileImage'] as String,
      phoneNumber: parsedJson['phoneNumber'] as String,
      email: parsedJson['email'] as String,
      password: parsedJson['password'] as String,
      address: parsedJson['address'] as String,
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      roleId: parsedJson['roleId'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["name"] = name;
    map["profileImage"] = profileImage;
    map["phoneNumber"] = phoneNumber;
    map["email"] = email;
    map["password"] = password;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["roleId"] = roleId;
    return map;
  }
}
