class CreateMarkerDetails {
  int userId;
  String lastSeenAddress;
  String latitude;
  String longitude;
  String timeOfSeeing;
  String comments;
  int notificationId;
  int crimeId;
  String notificationContent;
  CreateMarkerDetails({
    this.userId,
    this.latitude,
    this.longitude,
    this.lastSeenAddress,
    this.notificationId,
    this.comments,
    this.timeOfSeeing,
    this.crimeId,
    this.notificationContent,
  });

  factory CreateMarkerDetails.fromJson(Map<String, dynamic> parsedJson) {
    return CreateMarkerDetails(
      userId: parsedJson['userId'],
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      lastSeenAddress: parsedJson['lastSeenAddress'] as String,
      timeOfSeeing: parsedJson['timeOfSeeing'] as String,
      comments: parsedJson['comments'] as String,
      notificationId: parsedJson['notificationId'],
      crimeId: parsedJson['crimeId'],
      notificationContent: parsedJson['notificationContent'] as String,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["lastSeenAddress"] = lastSeenAddress;
    map["timeOfSeeing"] = timeOfSeeing;
    map["comments"] = comments;
    map["notificationId"] = notificationId;
    map["crimeId"] = crimeId;
    map["notificationContent"] = notificationContent;
    return map;
  }
}
