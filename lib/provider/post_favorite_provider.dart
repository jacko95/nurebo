// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:nurebo/models/business.dart';
// import 'package:nurebo/models/business_post.dart';
// import 'package:nurebo/models/category.dart';
// import 'package:nurebo/models/prestazione.dart';
// import 'package:nurebo/models/user.dart';
// import 'package:http/http.dart' as http;
// import 'package:nurebo/utils/user_preferences.dart';
// import 'package:nurebo/utils/utils.dart';
//
// class PostFavoriteProvider extends ChangeNotifier {
//   List<BusinessPost> postFavoritesList = [];
//
//
//   Future getBusinessPostFavorites(User user) async {
//     // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
//     // var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/${Utils.business_id}/post/like");
//     var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/post/like");
//
//     Map<String, dynamic> body = {
//       'user_id': user.id,
//     };
//
//     // var response = await http.post(
//     var response = await http.get(
//         url,
//         // body: jsonEncode(body),
//         headers: {
//           'Accept': '*/*',
//           'Content-Type': 'application/json',
//           'Accept-encoding': 'gzip, deflate',
//           'connection': 'keep-alive',
//           'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
//           'X-App-Version-Name': Utils.version_name,
//           'X-App-Version-Number': Utils.version_id.toString(),
//           'X-Client-Type': 'User-Mobile-App',
//           HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
//         }
//     );
//
//     // //print("ticketUsers response.statusCode:");
//     // //print(response.statusCode);
//     if(response.statusCode >= 200 && response.statusCode < 400) {
//       var jsonData = json.decode(response.body);
//
//       removeAllPostFavorite();
//
//       // postFavoritesList.addAll(jsonData);
//
//       for(var e in jsonData){
//         postFavoritesList.add(
//           BusinessPost(
//             id: e['post_id'],
//             description: e['post_description'],
//             image_url: e['post_image_url'],
//             // is_admin: e['post_is_admin'],
//             // is_visible: e['post_is_visible'],
//             created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
//             // booking: Booking(
//             //   id: e['booking_id'],
//             //   isCanceled: e['is_canceled'],
//             //   // note: myAppointments[index]['note'],
//             //   // user_id: myAppointments[index]['user_id'].toString(),
//             prestazione: Prestazione(
//               id: e['prestazione_id'],
//               duration: e['prestazione_duration'],
//               image: e['prestazione_image'] ?? '',
//               is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
//                 price: e['prestazione_price']?.toDouble(),
//                 price_min: e['prestazione_price_min']?.toDouble(),
//                 price_max: e['prestazione_price_max']?.toDouble(),
//               title: e['prestazione_title'],
//               description: e['prestazione_description'] ?? '',
//               // business_id: e['prestazione_business_id'],
//               business: Business(
//                   id: e['business_id'],
//                   email: e['business_email'],
//                   name: e['business_name'],
//                   longitude: e['business_longitude'],
//                   latitude: e['business_latitude'],
//                   phone_number: e['business_phone_number'],
//                   room_id: e['business_room_id'],
//                   profile_image: e['business_profile_image'],
//                   address: e['business_address'],
//                   description: e['business_description'],
//                   type_id: e['business_type_id'],
//                   max_contemporary_appointments: e['max_contemporary_appointments'],
//                   category: Category(
//                     id: e['category_id'],
//                     image: e['category_image'],
//                     name: e['category_name'],
//                   )
//               ),
//             ),
//             business: Business(
//                 id: e['business_id'],
//                 email: e['business_email'],
//                 name: e['business_name'],
//                 longitude: e['business_longitude'],
//                 latitude: e['business_latitude'],
//                 phone_number: e['business_phone_number'],
//                 profile_image: e['business_profile_image'],
//                 address: e['business_address'],
//                 description: e['business_description'],
//                 type_id: e['business_type_id'],
//                 room_id: e['business_room_id'],
//                 max_contemporary_appointments: e['max_contemporary_appointments'],
//                 category: Category(
//                   id: e['category_id'],
//                   image: e['category_image'],
//                   name: e['category_name'],
//                 )
//             ),
//             user: User(
//               id: e['user_id'],
//               email: e['user_email'],
//               username: e['user_username'],
//               name: e['user_name'],
//               profile_image: e['user_profile_image'],
//               description: e['user_description'],
//             ),
//             comments: [],
//             likes: [],
//           )
//         );
//       }
//
//       // postFavoritesList.sort((b, a) {
//       //   return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
//       // });
//
//       // print('jsonData666666666666666');
//       // print(jsonData.length);
//
//       notifyListeners();
//       return jsonData;
//     }
//   }
//
//   // Future getUserEventFavorites(User user) async {
//   //   // var url = Uri.parse(Utils.httpServerUrl + "event_favorite/user_id");
//   //   var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/event/like");
//   //
//   //   Map<String, dynamic> body = {
//   //     'user_id': user.id,
//   //   };
//   //
//   //   // var response = await http.post(
//   //   var response = await http.get(
//   //       url,
//   //       // body: jsonEncode(body),
//   //       headers: {
//   //         'Accept': '*/*',
//   //         'Content-Type': 'application/json',
//   //         'Accept-encoding': 'gzip, deflate',
//   //         'connection': 'keep-alive',
//   //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
//   //         'X-App-Version-Name': Utils.version_name,
//   //         'X-App-Version-Number': Utils.version_id.toString(),
//   //         'X-Client-Type': 'User-Mobile-App',
//   //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
//   //       }
//   //   );
//   //
//   //   // //print("ticketUsers response.statusCode:");
//   //   // //print(response.statusCode);
//   //   if(response.statusCode >= 200 && response.statusCode < 400) {
//   //     var jsonData = json.decode(response.body);
//   //
//   //     // for(var e in favoritesList){
//   //     //   if(e['event_id'] != null){
//   //     //     favoritesList.remove(e);
//   //     //   }
//   //     // }
//   //     removeAllEventFavorite();
//   //     // myFavoritesList = jsonData;
//   //     // List.from(myFavoritesList).add(jsonData);
//   //     // favoritesList.add(jsonData);
//   //     postFavoritesList.addAll(jsonData);
//   //
//   //     postFavoritesList.sort((b, a) {
//   //       return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
//   //     });
//   //
//   //     // //print('jsonData allaahh');
//   //     // //print(jsonData);
//   //
//   //     notifyListeners();
//   //     return jsonData;
//   //   }
//   // }
//
//   removeAllEventFavorite(){
//     for(var e in List.from(postFavoritesList)){
//       if(e['event_id'] != null){
//         postFavoritesList.remove(e);
//       }
//     }
//     notifyListeners();
//   }
//
//   removeAllPostFavorite(){
//     for(BusinessPost e in List.from(postFavoritesList)){
//       if(e.prestazione!.id != null){
//         postFavoritesList.remove(e);
//       }
//     }
//     notifyListeners();
//   }
//
//   // removeEventFavorite(String id){
//   //   for(var e in postFavoritesList){
//   //     if(e['event_id'] != null && e['event_id'] == id) {
//   //       postFavoritesList.remove(e);
//   //     }
//   //   }
//   //   notifyListeners();
//   // }
//
//   removePrestazioneFavorite(String id){
//     for(var e in postFavoritesList){
//       if(e.prestazione!.id != null && e.prestazione!.id == id){
//         postFavoritesList.remove(e);
//       }
//     }
//     notifyListeners();
//   }
//
//   emptyFavorites(){
//     postFavoritesList.clear();
//     notifyListeners();
//   }
// }
