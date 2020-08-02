class ListAgentChatResponse {
  int agentChatId;
  int crimeId;
  int senderId;
  String name;
  String profileImage;
  String comment;
  int parentId;
  String search;
  String commentDate;

  ListAgentChatResponse({
    this.agentChatId,
    this.crimeId,
    this.senderId,
    this.name,
    this.profileImage,
    this.comment,
    this.parentId,
    this.search,
    this.commentDate,
  });

  factory ListAgentChatResponse.fromJson(Map<String, dynamic> parsedJson) {
    return ListAgentChatResponse(
      agentChatId: parsedJson['agentChatId'],
      crimeId: parsedJson['crimeId'] as int,
      senderId: parsedJson['senderId'] as int,
      name: parsedJson['name'] as String,
      profileImage: parsedJson['profileImage'] as String,
      comment: parsedJson['comment'] as String,
      parentId: parsedJson['parentId'] as int,
      search: parsedJson['search'] as String,
      commentDate: parsedJson['commentDate'] as String,
    );
  }
}
