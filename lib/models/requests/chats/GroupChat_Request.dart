class GroupChatRequest {
  int crimeId;
  int commentBy;
  String comment;
  int parentId;

  GroupChatRequest({this.crimeId, this.commentBy, this.comment, this.parentId});

  factory GroupChatRequest.fromJson(Map<String, dynamic> parsedJson) {
    return GroupChatRequest(
      crimeId: parsedJson['crimeId'] as int,
      commentBy: parsedJson['commentBy'] as int,
      comment: parsedJson['comment'] as String,
      parentId: parsedJson['parentId'] as int,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["crimeId"] = crimeId;
    map["commentBy"] = commentBy;
    map["comment"] = comment;
    map["parentId"] = parentId;
    return map;
  }
}
