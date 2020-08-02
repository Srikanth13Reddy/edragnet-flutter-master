class SuccessResponse {
  String message;

  SuccessResponse({
    this.message,
  });

  factory SuccessResponse.fromJson(Map<String, dynamic> parsedJson) {
    return SuccessResponse(
      message: parsedJson['message'] as String,
    );
  }

//  Map toMap() {
//    var map = new Map<String, dynamic>();
//    map["message"] = message;
//    return map;
//  }
}
