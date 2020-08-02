class AdminCrimeResponse {
  int crimeId;
  String crimeName;
  String crimeDescription;
  String filePath;
  String occurrenceAddress;
  String occurrencelatitude;
  String occurrencelongitude;
  String timeOfOccurence;
  String crimeRequesterInformation;
  String severity;
  int crimeRequestedBy;
  int createdBy;
  String createdByName;
  String createdDateTime;
  bool isStatus;
  String crimeStatus;


  AdminCrimeResponse({this.crimeId, this.crimeName, this.crimeDescription,
      this.filePath, this.occurrenceAddress, this.occurrencelatitude,
      this.occurrencelongitude, this.timeOfOccurence,
      this.crimeRequesterInformation, this.severity, this.crimeRequestedBy,
      this.createdBy, this.createdByName, this.createdDateTime, this.isStatus,this.crimeStatus});

  factory AdminCrimeResponse.fromJson(Map<String, dynamic> parsedJson)
  {
    return
      AdminCrimeResponse(
        crimeId: parsedJson['crimeId'] as int,
        crimeName: parsedJson['crimeName'] as String,
        crimeDescription: parsedJson['crimeDescription'] as String,
        filePath: parsedJson['filePath'] as String,
        occurrenceAddress: parsedJson['occurrenceAddress'] as String,
        occurrencelatitude: parsedJson['occurrencelatitude'] as String,
        occurrencelongitude: parsedJson['occurrencelongitude'] as String,
        timeOfOccurence: parsedJson['timeOfOccurence'] as String,
        crimeRequesterInformation: parsedJson['crimeRequesterInformation'] as String,
        severity: parsedJson['severity'] as String,
        crimeRequestedBy: parsedJson['crimeRequestedBy'] as int,
        createdBy: parsedJson['createdBy'] as int,
        createdByName: parsedJson['createdByName'] as String,
        createdDateTime: parsedJson['createdDateTime'] as String,
        isStatus: parsedJson['isStatus'] as bool,
        crimeStatus: parsedJson['crimeStatus'] as String,
      );
  }
}