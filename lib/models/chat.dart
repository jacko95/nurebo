import 'package:nurebo/models/chat_message.dart';

class Chat{
  String? chat_id;
  // int user_a_id;
  // int user_b_id;
  DateTime? create_at;
  String? receiver_id;
  String? sender_id;
  String? user_a_id;
  String? user_b_id;
  DateTime? user_a_last_opening_at;
  DateTime? user_b_last_opening_at;
  DateTime? user_a_last_closing_at;
  DateTime? user_b_last_closing_at;
  String? receiver_username;
  String? receiver_name;
  String? sender_username;
  String? sender_name;
  String? receiver_profile_image;
  String? sender_profile_image;
  DateTime? sent_at;
  String? text;
  List<ChatMessage>? chat_message_list;
  int? unread_messages;
  int? is_visible_for_user_a;
  int? is_visible_for_user_b;

  Chat({
    this.chat_id,
    this.create_at,
    // this.user_a_id,
    // this.user_b_id,
    this.receiver_id,
    this.receiver_name,
    this.sender_name,
    this.sender_id,
    this.sent_at,
    this.text,
    this.receiver_profile_image,
    this.receiver_username,
    this.sender_username,
    this.sender_profile_image,
    this.user_a_id,
    this.user_b_id,
    this.user_a_last_opening_at,
    this.user_b_last_opening_at,
    this.user_a_last_closing_at,
    this.user_b_last_closing_at,
    this.chat_message_list,
    this.unread_messages,
    this.is_visible_for_user_a,
    this.is_visible_for_user_b,
  });
}