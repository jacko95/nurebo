
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/event_reservation.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/event_ticket.dart';
import 'package:nurebo/models/prestazione.dart';

class CartItem {
  String? id;
  String? userId;
  int? exhibition_id;
  String? singleEventId;
  int? seat_id;
  bool is_shared = true;
  double? ticketCategoryPrice;
  double? presale_price;
  double? presale_price_min;
  double? presale_price_max;
  double? commission_price;
  DateTime? added_in_cart_at;
  String? userOrderId;
  /*late*/ int? quantity;
  String? image;
  String? title;
  String? option;
  String? ticketCategoryAdditional;
  String? ticketCategoryTitle;
  String? ticketCategoryId;

  Event? event;
  EventTicket? eventTicket;

  bool? isEvent;

  String? prestazione_id;
  String? note;
  DateTime? created_at;
  DateTime? begin_at;
  int? duration;
  Prestazione? prestazione;

  Business? business;


  CartItem({
    this.id,
    this.userId,
    this.exhibition_id,
    this.added_in_cart_at,
    this.commission_price,
    this.ticketCategoryPrice,
    this.presale_price,
    this.presale_price_max,
    this.presale_price_min,
    this.seat_id,
    this.singleEventId,
    /*required*/ this.quantity,
    this.business,
    this.userOrderId,
    this.image,
    this.prestazione,
    this.title,
    this.ticketCategoryAdditional,
    this.option,
    this.event,
    this.ticketCategoryTitle,
    this.ticketCategoryId,
    this.eventTicket,
    this.begin_at,
    this.created_at,
    this.isEvent,
    this.note,
    this.prestazione_id,
    this.duration,
  });

}