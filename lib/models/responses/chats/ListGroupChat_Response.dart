class ListGroupChatResponses {
  int chatId;
  int crimeId;
  int commentBy;
  String name;
  String profileImage;
  String comment;
  int parentId;
  String search;
  String commentDate;

  ListGroupChatResponses({
    this.chatId,
    this.crimeId,
    this.commentBy,
    this.name,
    this.profileImage,
    this.comment,
    this.parentId,
    this.search,
    this.commentDate,
  });

  factory ListGroupChatResponses.fromJson(Map<String, dynamic> parsedJson) {
    return ListGroupChatResponses(
      chatId: parsedJson['chatId'],
      crimeId: parsedJson['crimeId'] as int,
      commentBy: parsedJson['commentBy'] as int,
      name: parsedJson['name'] as String,
      profileImage: parsedJson['profileImage'] as String,
      comment: parsedJson['comment'] as String,
      parentId: parsedJson['parentId'] as int,
      search: parsedJson['search'] as String,
      commentDate: parsedJson['commentDate'] as String,
    );
  }
}
