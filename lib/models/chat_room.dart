import 'package:nurebo/models/chat_room_message.dart';
import 'package:nurebo/models/event.dart';

class ChatRoom {
  Event? event;
  List<ChatRoomMessage>? chatRoomMessages = [];
  late int? unread_messages;

  ChatRoom({
    this.event,
    this.chatRoomMessages,
    this.unread_messages,
  });
}