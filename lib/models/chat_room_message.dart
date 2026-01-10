import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/user.dart';

class ChatRoomMessage {
  String? id;
  User? sender;
  // String senderId;
  Business? business;
  Event? event;
  // String singleEventId;
  String? text;
  int? is_visible;
  int? is_business_sender;
  DateTime? sent_at;
  DateTime? delete_at;

  ChatRoomMessage({
    this.id,
    this.text,
    this.event,
    // this.singleEventId,
    this.sent_at,
    this.sender,
    // this.senderId,
    this.delete_at,
    this.is_visible,
    this.is_business_sender,
    this.business,
  });

  factory ChatRoomMessage.fromJson(Map<String, dynamic> json) => ChatRoomMessage(
    id: json['title'],
    text: json['performer_name'],
    business: json['image'],
    is_business_sender: int.parse(json['event_business_id']),
    sent_at: json['description'],
    is_visible: int.parse(json['performer_profile_id']),
    sender: json['id'],
    // single_event: json['id'],
  );

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'image': image,
  //   'title': title,
  //   'performer_name': performer_name,
  //   'description': description,
  //   // 'event_business_id': event_business_id,
  //   // 'performer_profile_id': performer_profile_id,
  // };

}