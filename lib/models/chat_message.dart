
class ChatMessage{
  String? id;
  String? chat_id;
  String? sender_id;
  String? receiver_id;
  String? text;
  String? file;
  String? type;
  DateTime? sent_at;
  DateTime? received_at;
  DateTime? read_at;
  bool? received;
  bool? is_visualized;
  int? is_visible_for_sender;
  int? is_visible_for_receiver;

  ChatMessage({
    this.id,
    this.chat_id,
    this.file,
    this.text,
    this.read_at,
    this.type,
    this.received,
    this.receiver_id,
    this.sent_at,
    this.sender_id,
    this.is_visualized,
    this.received_at,
    this.is_visible_for_receiver,
    this.is_visible_for_sender,

  });
}