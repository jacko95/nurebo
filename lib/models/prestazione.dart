import 'package:nurebo/models/business.dart';

class Prestazione {
  late String? id;
  // String business_id;
  String? title;
  String? image;
  double? price;
  double? price_min;
  double? price_max;
  bool is_price_range;
  int? duration;
  int? isValid;
  String? description = '';
  DateTime? created_at;
  Business? business;

  Prestazione({
    required this.description,
    required this.duration,
    /*required*/ this.id,
    required this.price,
    required this.is_price_range,
    this.price_min,
    this.price_max,
    this.isValid,
    /*required*/ this.created_at,
    required this.title,
    // /*required*/ this.business_id,
    required this.image,
    required this.business,
  });

  // Prestazione.fromJson(Map<String, dynamic> json) {
  //   id = json['prestazione_id'];
  //   duration = json['prestazione_duration'];
  //   title = json['prestazione_title'];
  //   image = json['prestazione_image'];
  //   price = json['prestazione_price'];
  //   price_min = json['prestazione_price_min'];
  //   price_max = json['prestazione_price_max'];
  //   is_price_range = (json['prestazione_is_price_range'] ?? 0) == 1 ? true : false;
  //   description = json['prestazione_description'];
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['prestazione_id'] = this.id;
    data['prestazione_duration'] = this.duration;
    data['prestazione_title'] = this.title;
    data['prestazione_image'] = this.image;
    data['prestazione_price'] = this.price;
    data['prestazione_description'] = this.description;
    return data;
  }
}
