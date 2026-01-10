import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
// import 'package:nurebo/models/event.dart';

class Recommended {
  // String id;
  int? id;
  DateTime? created_at;
  // SingleEvent single_event;
  // List<SingleEvent> single_event_list;
  Prestazione prestazione;
  // bool is_single_event;

  Recommended({
    required this.id,
    required this.prestazione,
    // this.is_single_event,
    /*required*/ this.created_at,
    // this.single_event,
    // this.single_event_list,
  });


  // factory Recommended.fromJson(Map<String, dynamic> json) => Recommended(
  //   title: json['title'],
  //   performer_name: json['performer_name'],
  //   image: json['image'],
  //   // event_business_id: int.parse(json['event_business_id']),
  //   description: json['description'],
  //   // performer_profile_id: int.parse(json['performer_profile_id']),
  //   id: int.parse(json['id']),
  // );
  //
  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'image': image,
  //   'title': title,
  //   'performer_name': performer_name,
  //   'description': description,
  //   // 'event_business_id': event_business_id,
  //   // 'performer_profile_id': performer_profile_id,
  // };

}