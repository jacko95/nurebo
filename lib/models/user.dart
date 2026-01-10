
class User {
  late /*final*/ String? id;
  late String? username;
  late String? name;
  late String? phone;
  late String? email;
  late String? password;
  String? fcm_token;
  String? profile_image;
  String? description;
  String? first_name;
  String? last_name;
  // String fiscal_code;
  // DateTime registration_booking;
  // int cap;
  double? latitude;
  double? longitude;
  int? visible;
  int? email_notification;
  DateTime? created_at;

  User({
    /*required*/ this.id,
    /*required*/ this.username,
    /*required*/ this.email,
    /*required*/ this.description,
    /*required*/ this.password,
    /*required*/ this.visible,
    // /*required*/ this.cap,
    // /*required*/ this.fiscal_code,
    /*required*/ this.name,
    /*required*/ this.first_name,
    /*required*/ this.last_name,
    /*required*/ this.phone,
    /*required*/ this.fcm_token,
    /*required*/ this.profile_image,
    /*required*/ this.email_notification,
    /*required*/ this.latitude,
    /*required*/ this.longitude,
    /*required*/ this.created_at,
    // /*required*/ this.registration_booking,
  });


  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'],
    email: json['email'],
    profile_image: json['profile_image'],
    password: json['password'],
    description: json['description'],
    visible: json['visible'],
    first_name: json['first_name'],
    name: json['name'],
    last_name: json['last_name'],
    phone: json['phone'],
    id: json['id'],
    longitude: json['longitude'],
    latitude: json['latitude'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'user_profile_image': profile_image,
    'user_username': username,
    'user_name': name,
    'user_description': description,
    'user_email': email,
    'user_phone': phone,
    'user_latitude': latitude,
    'user_longitude': longitude,
  };
}
