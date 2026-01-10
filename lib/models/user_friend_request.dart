import 'package:nurebo/models/user.dart';


class UserFriendRequest {
  DateTime? created_at;
  User? user;

  UserFriendRequest({
    this.created_at,
    this.user,
  });
}
