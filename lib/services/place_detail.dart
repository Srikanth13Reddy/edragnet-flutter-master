class predictions {
  String description;
  double distance_meters;
  String id;
  String matched_substrings;
  String place_id;
  String reference;
  String terms;
  String types;
  //AccessToken accessToken;

  predictions({
    this.description,
    this.distance_meters,
    this.id,
    this.matched_substrings,
    this.place_id,
    this.reference,
    this.terms,
    this.types,
  });

  factory predictions.fromJson(Map<String, dynamic> parsedJson) {
    return predictions(
      description: parsedJson['description'] as String,
      distance_meters: parsedJson['distance_meters'] as double,
      id: parsedJson['id'] as String,
      matched_substrings: parsedJson['matched_substrings'] as String,
      place_id: parsedJson['place_id'] as String,
      reference: parsedJson['reference'] as String,
      terms: parsedJson['terms'] as String,
      types: parsedJson['types'] as String,
      //accessToken: parsedJson['accessToken'] as AccessToken,
    );
  }

//  Map toMap() {
//    var map = new Map<String, dynamic>();
//    map["userId"] = userId;
//    map["name"] = name;
//    map["phoneNumber"] = phoneNumber;
//    map["email"] = email;
//    map["profileImage"] = profileImage;
//    map["address"] = address;
//    map["latitude"] = latitude;
//    map["longitude"] = longitude;
//    map["role"] = role;
//    map["accessToken"] = accessToken;
//    return map;
//  }
}
