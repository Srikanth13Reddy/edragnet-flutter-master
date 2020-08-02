class ActiveCrimes {
  List<Data> data;
  int count;

  ActiveCrimes({
    this.data,
    this.count,
  });

  factory ActiveCrimes.fromJson(Map<String, dynamic> parsedJson) {
    var tagObjsJson = parsedJson['data'] as List;
    List<Data> _tags =
        tagObjsJson.map((tagJson) => Data.fromJson(tagJson)).toList();
    return ActiveCrimes(
      data: _tags,
      count: parsedJson['count'],
    );
  }
}

class Data {
  int crimeId;
  String crimeName;
  String crimeDescription;
  String filePath;
  String occurrenceAddress;
  String occurrencelatitude;
  String occurrencelongitude;
  String timeOfOccurrence;
  String crimeRequesterInformation;
  String severity;
  int crimeRequestedBy;
  int createdBy;
  String createdByName;
  String createdDateTime;
  bool isStatus;

  Data({
    this.crimeId,
    this.crimeName,
    this.crimeDescription,
    this.filePath,
    this.occurrenceAddress,
    this.occurrencelatitude,
    this.occurrencelongitude,
    this.timeOfOccurrence,
    this.crimeRequesterInformation,
    this.severity,
    this.crimeRequestedBy,
    this.createdBy,
    this.createdByName,
    this.createdDateTime,
    this.isStatus,
  });

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    return Data(
      crimeId: parsedJson['crimeId'],
      crimeName: parsedJson['crimeName'] as String,
      crimeDescription: parsedJson['crimeDescription'] as String,
      filePath: parsedJson['filePath'] as String,
      occurrenceAddress: parsedJson['occurrenceAddress'] as String,
      occurrencelatitude: parsedJson['occurrencelatitude'] as String,
      occurrencelongitude: parsedJson['occurrencelongitude'] as String,
      timeOfOccurrence: parsedJson['timeOfOccurrence'] as String,
      crimeRequesterInformation:
          parsedJson['crimeRequesterInformation'] as String,
      severity: parsedJson['severity'] as String,
      crimeRequestedBy: parsedJson['crimeRequestedBy'],
      createdBy: parsedJson['createdBy'],
      createdByName: parsedJson['createdByName'] as String,
      createdDateTime: parsedJson['createdDateTime'] as String,
      isStatus: parsedJson['isStatus'] as bool,
    );
  }
}
