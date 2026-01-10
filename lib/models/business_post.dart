import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';

import 'post_comment.dart';

class BusinessPost {
  String? id;
  Business? business;
  Prestazione? prestazione;
  // Business business;
  String? image_url;
  // String? title;
  // int? is_video;
  List<PostComment> comments = [];
  List<PostLike> likes = [];
  DateTime? created_at;
  String? description;
  User? user;

  BusinessPost({
    this.description,
    this.business,
    this.prestazione,
    required this.comments,
    this.id,
    this.image_url,
    this.created_at,
    required this.likes,
    // this.title,
    this.user,
    // this.is_video,
  });
}
