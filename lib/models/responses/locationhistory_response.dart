class GetLocationHistoryResponse {
  int locationLogId;
  int userId;
  String latitude;
  String longitude;
  int locationType;
  String address;
  String lastLocationUpdated;
  bool nextUpdate;

  GetLocationHistoryResponse({
    this.locationLogId,
    this.userId,
    this.latitude,
    this.longitude,
    this.locationType,
    this.address,
    this.lastLocationUpdated,
    this.nextUpdate,
  });

  factory GetLocationHistoryResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetLocationHistoryResponse(
      locationLogId: parsedJson['locationLogId'],
      userId: parsedJson['userId'] as int,
      latitude: parsedJson['latitude'] as String,
      longitude: parsedJson['longitude'] as String,
      locationType: parsedJson['locationType'] as int,
      address: parsedJson['address'] as String,
      lastLocationUpdated: parsedJson['lastLocationUpdated'] as String,
      nextUpdate: parsedJson['nextUpdate'] as bool,
    );
  }
}
