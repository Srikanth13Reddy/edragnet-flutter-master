class GetAgentsResponse {
  int userId;
  String latitude;
  String longitude;
  String name;
  String profileImage;
  String email;
  String roleName;
  int roleId;

  GetAgentsResponse({
    this.userId,
    this.latitude,
    this.longitude,
    this.name,
    this.profileImage,
    this.email,
    this.roleName,
    this.roleId,
  });

  factory GetAgentsResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetAgentsResponse(
      userId: parsedJson['userId'],
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      name: parsedJson['name'] as String,
      profileImage: parsedJson['profileImage'] as String,
      email: parsedJson['email'] as String,
      roleName: parsedJson['roleName'] as String,
      roleId: parsedJson['roleId'] as int,
    );
  }
}
