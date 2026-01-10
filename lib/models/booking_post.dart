import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';

import 'post_comment.dart';

class BookingPost {
  String? id;
  Booking? booking;
  // Prestazione? prestazione;
  // Business business;
  String? image_url;
  // String? title;
  // int? is_video;
  double? vote;
  int? is_admin;
  int? is_visible;
  List<PostComment>? comments;
  List<PostLike>? likes;
  DateTime? created_at;
  String? description;
  // User? user;
  // Prestazione? prestazione;

  BookingPost({
    this.description,
    this.is_admin,
    this.image_url,
    this.id,
    this.created_at,
    this.booking,
    this.likes,
    // this.user,
    // this.prestazione,
    this.comments,
    this.is_visible,
    this.vote,
  });
}
