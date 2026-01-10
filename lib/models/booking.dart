import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';

class Booking {
  // String id;
  int? type;//0 = disonibile, 1 = occupato, 2 = prenotato da un utente
  // String business_id;
  DateTime? begin_at;
  DateTime? end_at;
  int? isCanceled;
  double? price;

  Prestazione? prestazione;
  Business? business;
  DateTime? created_at;
  // String user_id;
  // String username;
  // String user_image;
  String? note;
  // double price;
  int? is_paid;
  bool? is_shared;
  // User user;
  String? id;

  User? user;
  String? user_id;
  // Prestazione prestazione;
  // bool isPaid;

  Booking({
    this.id,
    this.user_id,
    // // this.title,
    this.type,
    this.isCanceled,
    this.is_paid,
    this.price,
    // // this.price,
    // this.prestazione,
    // // this.username,
    // this.user,
    // this.business_id,
    this.created_at,
    this.is_shared,
    // // this.duration,
    this.note,
    this.prestazione,
    this.business,
    // // this.user_image,
    this.begin_at,
    this.end_at,
    this.user,
  });

}