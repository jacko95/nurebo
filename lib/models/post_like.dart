import 'package:nurebo/models/booking_post.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/user.dart';

class PostLike {
  // String? id;
  User? user;
  Post? post;
  BookingPost? bookingPost;
  BusinessPost? businessPost;
  DateTime? created_at;

  PostLike({
    this.user,
    // this.id,
    this.created_at,
    this.post,
    this.businessPost,
    this.bookingPost,
  });
}