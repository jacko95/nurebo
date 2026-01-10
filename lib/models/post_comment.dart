import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/user.dart';

class PostComment {
  String? id;
  String? text;
  User? user;
  // Post? post;
  BusinessPost? businessPost;
  DateTime? created_at;
  int? is_admin;
  // bool isLiked;

  PostComment({
    this.user,
    this.id,
    this.created_at,
    this.text,
    this.is_admin,
    this.businessPost,
  });
}