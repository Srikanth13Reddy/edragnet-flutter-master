class UpdateUserNotificationModel {
  int notificationId;

  UpdateUserNotificationModel({this.notificationId});

  factory UpdateUserNotificationModel.fromJson(
      Map<String, dynamic> parsedJson) {
    return UpdateUserNotificationModel(
      notificationId: parsedJson['notificationId'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["notificationId"] = notificationId;
    return map;
  }
}
