class AgentChatRequest {
  int senderId;
  int receiverId;
  String comment;
  int parentId;

  AgentChatRequest(
      {this.senderId, this.receiverId, this.comment, this.parentId});

  factory AgentChatRequest.fromJson(Map<String, dynamic> parsedJson) {
    return AgentChatRequest(
      senderId: parsedJson['senderId'] as int,
      receiverId: parsedJson['receiverId'] as int,
      comment: parsedJson['comment'] as String,
      parentId: parsedJson['parentId'] as int,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["senderId"] = senderId;
    map["receiverId"] = receiverId;
    map["comment"] = comment;
    map["parentId"] = parentId;
    return map;
  }
}
