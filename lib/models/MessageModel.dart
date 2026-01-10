class MessageModel {
  String? type;
  String? message;
  String? time;
  String? senderId;
  String? senderUsername;
  String? senderProfileImage;

  MessageModel({
    this.message,
    this.type,
    this.time,
    this.senderId,
    this.senderProfileImage,
    this.senderUsername,
  });
}
