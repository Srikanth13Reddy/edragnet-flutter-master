class ErrorResponse {
  String errorMessage;

  ErrorResponse({
    this.errorMessage,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> parsedJson) {
    return ErrorResponse(
      errorMessage: parsedJson['errorMessage'] as String,
    );
  }

//  Map toMap() {
//    var map = new Map<String, dynamic>();
//    map["errorMessage"] = errorMessage;
//    return map;
//  }
}
