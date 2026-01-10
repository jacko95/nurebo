import 'package:nurebo/models/event.dart';

class EventTicket{
  String? id;
  double? price;
  String? title;
  String? additional;
  Event? event;
  int? total_seats;

  EventTicket({
    this.id,
    this.price,
    this.title,
    this.additional,
    this.total_seats,
    this.event
  });
}