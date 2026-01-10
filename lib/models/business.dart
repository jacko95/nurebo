import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/timetable.dart';

class Business {
  late String? id;
  late String? name;
  late String? profile_image;
  late String? address;
  late String? description;
  late String? fcm_token;
  late String? room_id;
  late String? email;
  late String? phone;
  late Category? category;
  late int? type_id;
  late int? isVisible;
  late int? email_notification;
  late int? max_contemporary_appointments;
  late double? latitude;
  late double? longitude;
  late double? distance;
  late Timetable? timetable;

  Business({
    /*required*/ this.id,
    /*required*/ this.name,
    /*required*/ this.profile_image,
    /*required*/ this.address,
    /*required*/ this.description,
    /*required*/ this.email,
    /*required*/ this.phone,
    /*required*/ this.fcm_token,
    /*required*/ this.max_contemporary_appointments,
    /*required*/ this.isVisible,
    /*required*/ this.type_id,
    /*required*/ this.longitude,
    /*required*/ this.latitude,
    /*required*/ this.distance,
    /*required*/ this.category,
    /*required*/ this.email_notification,
    /*required*/ this.room_id,
    /*required*/ this.timetable,
  });

  Business.fromJson(Map<String, dynamic> json) {
  //   id = json['prestazione_id'];
  //   name = json['prestazione_duration'];
  //   profile_image = json['prestazione_title'];
  //   address = json['prestazione_image'];
  //   email = json['prestazione_price'];
  //   phone_number = json['business_phone_number'];
  //   description = json['prestazione_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_id'] = id;
    data['business_name'] = name;
    data['max_contemporary_appointments'] = max_contemporary_appointments;
    data['business_address'] = address;
    data['business_email'] = email;
    data['business_profile_image'] = profile_image;
    data['business_phone'] = phone;
    data['business_type_id'] = type_id;
    data['business_description'] = description;
    return data;
  }
}

