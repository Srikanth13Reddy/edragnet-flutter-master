class SaveDeviceIdRequest {
  int userId;
  String deviceId;

  SaveDeviceIdRequest({this.userId, this.deviceId});

  factory SaveDeviceIdRequest.fromJson(Map<String, dynamic> parsedJson) {
    return SaveDeviceIdRequest(
      userId: parsedJson['userId'],
      deviceId: parsedJson['deviceId'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["deviceId"] = deviceId;
    return map;
  }
}
