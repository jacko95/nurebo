import 'package:nurebo/models/user.dart';

import 'post_comment.dart';

class Post {
  String? id;
  String? user_id;
  String? single_event_experience_id;
  String? date_experience_id;
  // int exhibition_id;
  String? image_video;
  // DateTime dateTime;
  DateTime? created_at;
  String? description;
  String? title;
  // SingleEvent singleEvent;
  User? user;
  // Date date;
  // bool isDatePost;

  Post({
    this.description,
    this.date_experience_id,
    this.id,
    this.single_event_experience_id,
    this.image_video,
    this.user_id,
    this.title,
    this.created_at,
    this.user,
  });
}
