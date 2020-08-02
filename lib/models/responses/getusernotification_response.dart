class GetUserNotification {
  int notificationId;
  String notificationSendDate;
  String notificationStatus;
  int userId;
  String notificationContent;
  int crimeId;
  String crimeName;
  String crimeDescription;
  String occurrenceAddress;
  String occurrencelatitude;
  String occurrencelongitude;
  String timeOfOccurence;
  String crimeRequesterInformation;
  String severity;
  String colour;

  GetUserNotification({
    this.notificationId,
    this.notificationSendDate,
    this.notificationStatus,
    this.userId,
    this.notificationContent,
    this.crimeId,
    this.crimeName,
    this.crimeDescription,
    this.occurrenceAddress,
    this.occurrencelatitude,
    this.occurrencelongitude,
    this.timeOfOccurence,
    this.crimeRequesterInformation,
    this.severity,
    this.colour,
  });

  factory GetUserNotification.fromJson(Map<String, dynamic> parsedJson) {
    return GetUserNotification(
      notificationId: parsedJson['notificationId'],
      notificationSendDate: parsedJson['notificationSendDate'] as String,
      notificationStatus: parsedJson['notificationStatus'] as String,
      userId: parsedJson['userId'],
      notificationContent: parsedJson['notificationContent'] as String,
      crimeId: parsedJson['crimeId'],
      crimeName: parsedJson['crimeName'] as String,
      crimeDescription: parsedJson['crimeDescription'] as String,
      occurrenceAddress: parsedJson['occurrenceAddress'] as String,
      occurrencelatitude: parsedJson['occurrencelatitude'] as String,
      occurrencelongitude: parsedJson['occurrencelongitude'] as String,
      timeOfOccurence: parsedJson['timeOfOccurence'] as String,
      crimeRequesterInformation: parsedJson['crimeRequesterInformation'],
      severity: parsedJson['severity'] as String,
      colour: parsedJson['colour'] as String,
    );
  }
}
