import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/event_reservation.dart';
import 'package:nurebo/models/event_ticket.dart';
import 'package:nurebo/models/user.dart';

class EventReservation{
  String? user_id;
  String? qr_code;
  // int seat_id;
  DateTime? created_at;
  DateTime? is_validated_at;
  int? is_validated;
  String? id;
  int? is_canceled;
  EventTicket? eventTicket;
  // Event singleEvent;
  User? user;
  // Business business;


  EventReservation({
    // this.end_at,
    this.is_canceled,
    this.user,
    this.eventTicket,
    // this.singleEvent,
    // this.business,
    // this.price,
    // this.place,
    // this.esibizione,
    // this.placeC,
    // this.type,
    // this.codiceFiscale,
    // this.cognomeCliente,
    // this.nomeCliente,
    // this.begin_at,
    // this.description,
    // this.image,
    // this.is_expired,

    this.user_id,
    this.id,
    this.created_at,
    this.is_validated,
    this.is_validated_at,
    this.qr_code,
    // this.seat_id,
  });
}