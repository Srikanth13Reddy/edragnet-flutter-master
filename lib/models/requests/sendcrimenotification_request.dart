class SendCrimeNotificationModel {
  int userId;
  String latitude;
  String longitude;

  SendCrimeNotificationModel({this.userId, this.latitude, this.longitude});

  factory SendCrimeNotificationModel.fromJson(Map<String, dynamic> parsedJson) {
    return SendCrimeNotificationModel(
      userId: parsedJson['userId'],
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    return map;
  }
}
