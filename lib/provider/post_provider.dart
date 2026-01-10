import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/booking_post.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:provider/provider.dart';

class PostProvider extends ChangeNotifier {
  // List<BookingPost> postList = [];
  List<BusinessPost> postList = [];
  List<BusinessPost> businessProfilePostList = [];
  List<User> businessProfileUsersList = [];
  List<PostComment> postComments = [];
  List<PostLike> postLikes = [];
  bool isLikedPost = false;
  List<BusinessPost> homePostList = [];
  List<PostComment> homePostComments = [];
  List<PostLike> homePostLikes = [];
  bool isLikedHomePost = false;
  // List<PostLike> businessPostLikes = [];
  // List businessPostComments = [];
  List comments = [];
  List<PostLike> myPostLikesList = [];
  List<PostLike> userProfilePostLikes = [];
  List<PostComment> userProfilePostComments = [];
  List<PostLike> businessProfilePostLikes = [];
  List<PostComment> businessProfilePostComments = [];
  List<BusinessPost> postFavoritesList = [];
  List<PostLike> userPostFavoriteLikes = [];
  List<PostComment> userPostFavoriteComments = [];
  // List<BusinessPost> userPostList = [];
  List? savedBusinessList = [];

  clearPost(){
    postList.clear();
    notifyListeners();
  }

  Future getUserSavedBusiness(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/save");

    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      savedBusinessList = jsonData;

      // //print('jsonData22222222');
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  // Future saveBusiness(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/save");
  //
  //   Map<String, dynamic> body = {
  //     // "user_id": widget.user.id,
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     await getUserSavedBusiness(user/*userId*/);
  //
  //     notifyListeners();
  //     return response.statusCode;
  //   }
  // }
  //
  // Future unsaveBusiness(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/unsave");
  //
  //   Map<String, dynamic> body = {
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     await getUserSavedBusiness(user/*userId*/);
  //
  //     notifyListeners();
  //
  //     return response.statusCode;
  //   }
  // }

  // Future getPrestazioneLike(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_business");
  //
  //   Map<String, dynamic> body = {
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
  //       }
  //   );
  //
  //   // if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
  //   //   await logout();
  //   // }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // businessPostLikes = jsonData;
  //     //print("likes???");
  //     // //print(posts);
  //     //print(jsonData);
  //
  //     if(jsonData == 1){
  //       setState(() {
  //         isLikedPost = true;
  //       });
  //
  //     }
  //     else if(jsonData == 0){
  //       setState(() {
  //         isLikedPost = false;
  //       });
  //     }
  //     // notifyListeners();
  //     return jsonData;
  //   }
  // }

  emptySavedBusiness(){
    savedBusinessList!.clear();
    notifyListeners();
  }

  // Future getUserPostComments(User user) async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${user.id}/comment");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   // print("postcomment getall response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('userBusinessPostCommentsList');
  //     print(jsonData.length);
  //
  //     userProfilePostComments.clear();
  //
  //     for(var e in jsonData) {
  //       for (BusinessPost post in userPostList) {
  //         if(e['post_id'] == post.id){
  //           PostComment postComment = PostComment(
  //             id: e['id'],
  //             is_admin: e['is_admin'],
  //             created_at: DateTime.parse(e['created_at']),
  //             text: e['text'],
  //             businessPost: post,
  //             user: User(
  //               id: e['user_id'],
  //               description: e['user_description'],
  //               profile_image: e['user_profile_image'],
  //               // first_name: comments[i]['first_name'],
  //               name: e['user_name'],
  //               // last_name: comments[i]['last_name'],
  //               // city: postProvider.posts[i]['city'],
  //               // nation: postProvider.posts[i]['nation'],
  //               username: e['username'],
  //               email: e['user_email'],
  //             ),
  //           );
  //
  //           post.comments.add(postComment);
  //           userProfilePostComments.add(postComment);
  //         }
  //       }
  //     }
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }
  //
  // Future getUserPostLikes(User user) async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${user!.id}/like");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   // print("postcomment getall response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('userBusinessPostLikesList');
  //     print(jsonData.length);
  //
  //     userProfilePostLikes.clear();
  //     for(var e in jsonData) {
  //       for (BusinessPost post in userPostList) {
  //         if(e['post_id'] == post.id){
  //           PostLike postlike = PostLike(
  //             businessPost: BusinessPost(
  //               id: e['post_id'],
  //               description: e['post_description'],
  //               image_url: e['post_image_url'],
  //               // is_admin: e['post_is_admin'],
  //               // is_visible: e['post_is_visible'],
  //               created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //               // booking: Booking(
  //               //   id: e['booking_id'],
  //               //   isCanceled: e['is_canceled'],
  //               //   // note: myAppointments[index]['note'],
  //               //   // user_id: myAppointments[index]['user_id'].toString(),
  //               prestazione: Prestazione(
  //                 id: e['prestazione_id'],
  //                 duration: e['prestazione_duration'],
  //                 image: e['prestazione_image'] ?? '',
  //                 is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //                 title: e['prestazione_title'],
  //                 description: e['prestazione_description'] ?? '',
  //                 // business_id: e['prestazione_business_id'],
  //                 business: Business(
  //                     id: e['business_id'],
  //                     email: e['business_email'],
  //                     name: e['business_name'],
  //                     longitude: e['business_longitude'],
  //                     latitude: e['business_latitude'],
  //                     phone_number: e['business_phone_number'],
  //                     room_id: e['business_room_id'],
  //                     profile_image: e['business_profile_image'],
  //                     address: e['business_address'],
  //                     description: e['business_description'],
  //                     type_id: e['business_type_id'],
  //                     max_contemporary_appointments: e['max_contemporary_appointments'],
  //                     category: Category(
  //                       id: e['category_id'],
  //                       image: e['category_image'],
  //                       name: e['category_name'],
  //                     )
  //                 ),
  //               ),
  //               business: Business(
  //                   id: e['business_id'],
  //                   email: e['business_email'],
  //                   name: e['business_name'],
  //                   longitude: e['business_longitude'],
  //                   latitude: e['business_latitude'],
  //                   phone_number: e['business_phone_number'],
  //                   profile_image: e['business_profile_image'],
  //                   address: e['business_address'],
  //                   description: e['business_description'],
  //                   type_id: e['business_type_id'],
  //                   room_id: e['business_room_id'],
  //                   max_contemporary_appointments: e['max_contemporary_appointments'],
  //                   category: Category(
  //                     id: e['category_id'],
  //                     image: e['category_image'],
  //                     name: e['category_name'],
  //                   )
  //               ),
  //               user: User(
  //                 id: e['user_id'],
  //                 email: e['user_email'],
  //                 username: e['user_username'],
  //                 name: e['user_name'],
  //                 profile_image: e['user_profile_image'],
  //                 description: e['user_description'],
  //               ),
  //               comments: [],
  //               likes: [],
  //             ),
  //             user: User(
  //               id: e['user_id'],
  //               email: e['user_email'],
  //               username: e['user_username'],
  //               name: e['user_name'],
  //               profile_image: e['user_profile_image'],
  //               description: e['user_description'],
  //             ),
  //             created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //           );
  //
  //           post.likes.add(postlike);
  //           userProfilePostLikes.add(postlike);
  //         }
  //       }
  //     }
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }
  //
  // Future getMyLikesToUserPosts() async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/like");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/like/user");
  //
  //   Map<String, String?> queryParameters = {
  //     'user_id': Utils.user!.id,
  //   };
  //
  //   final uri = url.replace(
  //     queryParameters: queryParameters,
  //   );
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //     // url,
  //       uri,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   // print("postcomment getall response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('fg6565fhn65nv56vn65nnh5h5');
  //     print(jsonData.length);
  //     print(jsonData);
  //
  //     myPostLikesList.clear();
  //
  //     for(var e in jsonData){
  //       myPostLikesList.add(
  //           PostLike(
  //             businessPost: BusinessPost(
  //               id: e['post_id'],
  //               description: e['post_description'],
  //               image_url: e['post_image_url'],
  //               // is_admin: e['post_is_admin'],
  //               // is_visible: e['post_is_visible'],
  //               created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //               // booking: Booking(
  //               //   id: e['booking_id'],
  //               //   isCanceled: e['is_canceled'],
  //               //   // note: myAppointments[index]['note'],
  //               //   // user_id: myAppointments[index]['user_id'].toString(),
  //               prestazione: Prestazione(
  //                 id: e['prestazione_id'],
  //                 duration: e['prestazione_duration'],
  //                 image: e['prestazione_image'] ?? '',
  //                 is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
  //                 title: e['prestazione_title'],
  //                 description: e['prestazione_description'] ?? '',
  //                 // business_id: e['prestazione_business_id'],
  //                 business: Business(
  //                     id: e['business_id'],
  //                     email: e['business_email'],
  //                     name: e['business_name'],
  //                     longitude: e['business_longitude'],
  //                     latitude: e['business_latitude'],
  //                     phone_number: e['business_phone_number'],
  //                     room_id: e['business_room_id'],
  //                     profile_image: e['business_profile_image'],
  //                     address: e['business_address'],
  //                     description: e['business_description'],
  //                     type_id: e['business_type_id'],
  //                     max_contemporary_appointments: e['max_contemporary_appointments'],
  //                     category: Category(
  //                       id: e['category_id'],
  //                       image: e['category_image'],
  //                       name: e['category_name'],
  //                     )
  //                 ),
  //               ),
  //               business: Business(
  //                   id: e['business_id'],
  //                   email: e['business_email'],
  //                   name: e['business_name'],
  //                   longitude: e['business_longitude'],
  //                   latitude: e['business_latitude'],
  //                   phone_number: e['business_phone_number'],
  //                   profile_image: e['business_profile_image'],
  //                   address: e['business_address'],
  //                   description: e['business_description'],
  //                   type_id: e['business_type_id'],
  //                   room_id: e['business_room_id'],
  //                   max_contemporary_appointments: e['max_contemporary_appointments'],
  //                   category: Category(
  //                     id: e['category_id'],
  //                     image: e['category_image'],
  //                     name: e['category_name'],
  //                   )
  //               ),
  //               user: User(
  //                 id: e['user_id'],
  //                 email: e['user_email'],
  //                 username: e['user_username'],
  //                 name: e['user_name'],
  //                 profile_image: e['user_profile_image'],
  //                 description: e['user_description'],
  //               ),
  //               comments: [],
  //               likes: [],
  //             ),
  //             user: User(
  //               id: e['user_id'],
  //               email: e['user_email'],
  //               username: e['user_username'],
  //               name: e['user_name'],
  //               profile_image: e['user_profile_image'],
  //               description: e['user_description'],
  //             ),
  //             created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //           )
  //       );
  //     }
  //     // postProvider.myPostLikesList.addAll(jsonData);
  //
  //     print('postProvider.myPostLikesList.length');
  //     // print(postProvider.myPostLikesList);
  //     print(myPostLikesList.length);
  //     // for(var e in postProvider.myPostLikesList){
  //     //   print("e.post.id");
  //     //   print(e.businessPost!.id);
  //     // }
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }

  /**/

  Future getUserPostFavoriteComments() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/comment");

    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/like/comment");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/user/like/comment");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('userBusinessPostCommentsList');
      // print(jsonData.length);

      /*postProvider.*/userPostFavoriteComments.clear();

      // for(var e in jsonData) {
      //   bool elementoEsiste = postFavoritesList.any((element) => element.id == e['post_id']);
      //
      //   // Se l'elemento non esiste già, aggiungilo alla lista
      //   if (!elementoEsiste) {
      //     postFavoritesList.add(
      //         BusinessPost(
      //           id: e['post_id'],
      //           description: e['post_description'],
      //           image_url: e['post_image_url'],
      //           // is_admin: e['post_is_admin'],
      //           // is_visible: e['post_is_visible'],
      //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
      //           // booking: Booking(
      //           //   id: e['booking_id'],
      //           //   isCanceled: e['is_canceled'],
      //           //   // note: myAppointments[index]['note'],
      //           //   // user_id: myAppointments[index]['user_id'].toString(),
      //           prestazione: Prestazione(
      //             id: e['prestazione_id'],
      //             duration: e['prestazione_duration'],
      //             image: e['prestazione_image'] ?? '',
      //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
      //           price: e['prestazione_price']?.toDouble(),
      //           price_min: e['prestazione_price_min']?.toDouble(),
      //           price_max: e['prestazione_price_max']?.toDouble(),
                
      //             title: e['prestazione_title'],
      //             description: e['prestazione_description'] ?? '',
      //             // business_id: e['prestazione_business_id'],
      //             business: Business(
      //                 id: e['business_id'],
      //                 email: e['business_email'],
      //                 name: e['business_name'],
      //                 longitude: e['business_longitude'],
      //                 latitude: e['business_latitude'],
      //                 phone_number: e['business_phone_number'],
      //                 room_id: e['business_room_id'],
      //                 profile_image: e['business_profile_image'],
      //                 address: e['business_address'],
      //                 description: e['business_description'],
      //                 type_id: e['business_type_id'],
      //                 max_contemporary_appointments: e['max_contemporary_appointments'],
      //                 category: Category(
      //                   id: e['category_id'],
      //                   image: e['category_image'],
      //                   name: e['category_name'],
      //                 )
      //             ),
      //           ),
      //           business: Business(
      //               id: e['business_id'],
      //               email: e['business_email'],
      //               name: e['business_name'],
      //               longitude: e['business_longitude'],
      //               latitude: e['business_latitude'],
      //               phone_number: e['business_phone_number'],
      //               profile_image: e['business_profile_image'],
      //               address: e['business_address'],
      //               description: e['business_description'],
      //               type_id: e['business_type_id'],
      //               room_id: e['business_room_id'],
      //               max_contemporary_appointments: e['max_contemporary_appointments'],
      //               category: Category(
      //                 id: e['category_id'],
      //                 image: e['category_image'],
      //                 name: e['category_name'],
      //               )
      //           ),
      //           user: User(
      //             id: e['user_id'],
      //             email: e['user_email'],
      //             username: e['user_username'],
      //             name: e['user_name'],
      //             profile_image: e['user_profile_image'],
      //             description: e['user_description'],
      //           ),
      //           comments: [],
      //           likes: [],
      //         )
      //     );
      //   }
      //
      // }

      for(var e in jsonData) {
        PostComment postComment = PostComment(
          id: e['id'],
          is_admin: e['is_admin'],
          created_at: DateTime.parse(e['created_at']),
          text: e['text'],
          // businessPost: post,
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            comments: [],
            likes: [],
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
              price: e['prestazione_price']?.toDouble(),
              price_min: e['prestazione_price_min']?.toDouble(),
              price_max: e['prestazione_price_max']?.toDouble(),
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                ),
            ),
          ),
          user: User(
            id: e['user_id'],
            description: e['user_description'],
            profile_image: e['user_profile_image'] ?? '',
            // first_name: comments[i]['first_name'],
            name: e['user_name'],
            // last_name: comments[i]['last_name'],
            // city: postProvider.posts[i]['city'],
            // nation: postProvider.posts[i]['nation'],
            username: e['username'],
            email: e['user_email'],
          ),
        );
        /*postProvider.*/userPostFavoriteComments.add(postComment);
        for(BusinessPost e in /*postProvider.*/postFavoritesList){
          if(e.id == postComment.businessPost?.id){
            e.comments.add(postComment);
          }
        }
      }

      notifyListeners();
      return jsonData;
    }
    return;
  }

  Future getUserPostFavoriteLikes() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/like");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/user/like");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('gf5gf6g65g65gf65gf6');
      // print(jsonData.length);

      /*postProvider.*/userPostFavoriteLikes.clear();
      // for(var e in jsonData) {
      //   for (BusinessPost post in /*postProvider.*/postFavoritesList) {
      //     if(e['post_id'] == post.id){
      //       PostLike postlike = PostLike(
      //         businessPost: BusinessPost(
      //           id: e['post_id'],
      //           description: e['post_description'],
      //           image_url: e['post_image_url'],
      //           // is_admin: e['post_is_admin'],
      //           // is_visible: e['post_is_visible'],
      //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
      //           // booking: Booking(
      //           //   id: e['booking_id'],
      //           //   isCanceled: e['is_canceled'],
      //           //   // note: myAppointments[index]['note'],
      //           //   // user_id: myAppointments[index]['user_id'].toString(),
      //           prestazione: Prestazione(
      //             id: e['prestazione_id'],
      //             duration: e['prestazione_duration'],
      //             image: e['prestazione_image'] ?? '',
      //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
      //           price: e['prestazione_price']?.toDouble(),
      //           price_min: e['prestazione_price_min']?.toDouble(),
      //           price_max: e['prestazione_price_max']?.toDouble(),
                
      //             title: e['prestazione_title'],
      //             description: e['prestazione_description'] ?? '',
      //             // business_id: e['prestazione_business_id'],
      //             business: Business(
      //                 id: e['business_id'],
      //                 email: e['business_email'],
      //                 name: e['business_name'],
      //                 longitude: e['business_longitude'],
      //                 latitude: e['business_latitude'],
      //                 phone_number: e['business_phone_number'],
      //                 room_id: e['business_room_id'],
      //                 profile_image: e['business_profile_image'],
      //                 address: e['business_address'],
      //                 description: e['business_description'],
      //                 type_id: e['business_type_id'],
      //                 max_contemporary_appointments: e['max_contemporary_appointments'],
      //                 category: Category(
      //                   id: e['category_id'],
      //                   image: e['category_image'],
      //                   name: e['category_name'],
      //                 )
      //             ),
      //           ),
      //           business: Business(
      //               id: e['business_id'],
      //               email: e['business_email'],
      //               name: e['business_name'],
      //               longitude: e['business_longitude'],
      //               latitude: e['business_latitude'],
      //               phone_number: e['business_phone_number'],
      //               profile_image: e['business_profile_image'],
      //               address: e['business_address'],
      //               description: e['business_description'],
      //               type_id: e['business_type_id'],
      //               room_id: e['business_room_id'],
      //               max_contemporary_appointments: e['max_contemporary_appointments'],
      //               category: Category(
      //                 id: e['category_id'],
      //                 image: e['category_image'],
      //                 name: e['category_name'],
      //               )
      //           ),
      //           user: User(
      //             id: e['user_id'],
      //             email: e['user_email'],
      //             username: e['user_username'],
      //             name: e['user_name'],
      //             profile_image: e['user_profile_image'],
      //             description: e['user_description'],
      //           ),
      //           comments: [],
      //           likes: [],
      //         ),
      //         user: User(
      //           id: e['user_id'],
      //           email: e['user_email'],
      //           username: e['user_username'],
      //           name: e['user_name'],
      //           profile_image: e['user_profile_image'],
      //           description: e['user_description'],
      //         ),
      //         created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
      //       );
      //
      //       post.likes.add(postlike);
      //       /*postProvider.*/userPostFavoriteLikes.add(postlike);
      //     }
      //   }
      // }


      // for(var e in jsonData) {
      //   bool elementoEsiste = postFavoritesList.any((element) => element.id == e['post_id']);
      //
      //   if (!elementoEsiste) {
      //     postFavoritesList.add(
      //         BusinessPost(
      //           id: e['post_id'],
      //           description: e['post_description'],
      //           image_url: e['post_image_url'],
      //           // is_admin: e['post_is_admin'],
      //           // is_visible: e['post_is_visible'],
      //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
      //           // booking: Booking(
      //           //   id: e['booking_id'],
      //           //   isCanceled: e['is_canceled'],
      //           //   // note: myAppointments[index]['note'],
      //           //   // user_id: myAppointments[index]['user_id'].toString(),
      //           prestazione: Prestazione(
      //             id: e['prestazione_id'],
      //             duration: e['prestazione_duration'],
      //             image: e['prestazione_image'] ?? '',
      //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
      //           price: e['prestazione_price']?.toDouble(),
      //           price_min: e['prestazione_price_min']?.toDouble(),
      //           price_max: e['prestazione_price_max']?.toDouble(),
                
      //             title: e['prestazione_title'],
      //             description: e['prestazione_description'] ?? '',
      //             // business_id: e['prestazione_business_id'],
      //             business: Business(
      //                 id: e['business_id'],
      //                 email: e['business_email'],
      //                 name: e['business_name'],
      //                 longitude: e['business_longitude'],
      //                 latitude: e['business_latitude'],
      //                 phone_number: e['business_phone_number'],
      //                 room_id: e['business_room_id'],
      //                 profile_image: e['business_profile_image'],
      //                 address: e['business_address'],
      //                 description: e['business_description'],
      //                 type_id: e['business_type_id'],
      //                 max_contemporary_appointments: e['max_contemporary_appointments'],
      //                 category: Category(
      //                   id: e['category_id'],
      //                   image: e['category_image'],
      //                   name: e['category_name'],
      //                 )
      //             ),
      //           ),
      //           business: Business(
      //               id: e['business_id'],
      //               email: e['business_email'],
      //               name: e['business_name'],
      //               longitude: e['business_longitude'],
      //               latitude: e['business_latitude'],
      //               phone_number: e['business_phone_number'],
      //               profile_image: e['business_profile_image'],
      //               address: e['business_address'],
      //               description: e['business_description'],
      //               type_id: e['business_type_id'],
      //               room_id: e['business_room_id'],
      //               max_contemporary_appointments: e['max_contemporary_appointments'],
      //               category: Category(
      //                 id: e['category_id'],
      //                 image: e['category_image'],
      //                 name: e['category_name'],
      //               )
      //           ),
      //           user: User(
      //             id: e['user_id'],
      //             email: e['user_email'],
      //             username: e['user_username'],
      //             name: e['user_name'],
      //             profile_image: e['user_profile_image'],
      //             description: e['user_description'],
      //           ),
      //           comments: [],
      //           likes: [],
      //         )
      //     );
      //   }
      //
      // }

      for(var e in jsonData) {
        PostLike postlike = PostLike(
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          ),
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          ),
          created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        );
        /*postProvider.*/userPostFavoriteLikes.add(postlike);
        for(BusinessPost e in /*postProvider.*/postFavoritesList){
          if(e.id == postlike.businessPost!.id){
            e.likes.add(postlike);
          }
        }
      }

      notifyListeners();
      return jsonData;
    }
    return;
  }

  // Future getUserPostFavoriteComments() async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/like/comment");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   // print("postcomment getall response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('userBusinessPostCommentsList');
  //     print(jsonData.length);
  //
  //     userPostFavoriteComments.clear();
  //
  //     // for(var e in jsonData) {
  //     //   bool elementoEsiste = postFavoritesList.any((element) => element.id == e['post_id']);
  //     //
  //     //   // Se l'elemento non esiste già, aggiungilo alla lista
  //     //   if (!elementoEsiste) {
  //     //     postFavoritesList.add(
  //     //         BusinessPost(
  //     //           id: e['post_id'],
  //     //           description: e['post_description'],
  //     //           image_url: e['post_image_url'],
  //     //           // is_admin: e['post_is_admin'],
  //     //           // is_visible: e['post_is_visible'],
  //     //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //     //           // booking: Booking(
  //     //           //   id: e['booking_id'],
  //     //           //   isCanceled: e['is_canceled'],
  //     //           //   // note: myAppointments[index]['note'],
  //     //           //   // user_id: myAppointments[index]['user_id'].toString(),
  //     //           prestazione: Prestazione(
  //     //             id: e['prestazione_id'],
  //     //             duration: e['prestazione_duration'],
  //     //             image: e['prestazione_image'] ?? '',
  //     //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
  //     //             title: e['prestazione_title'],
  //     //             description: e['prestazione_description'] ?? '',
  //     //             // business_id: e['prestazione_business_id'],
  //     //             business: Business(
  //     //                 id: e['business_id'],
  //     //                 email: e['business_email'],
  //     //                 name: e['business_name'],
  //     //                 longitude: e['business_longitude'],
  //     //                 latitude: e['business_latitude'],
  //     //                 phone_number: e['business_phone_number'],
  //     //                 room_id: e['business_room_id'],
  //     //                 profile_image: e['business_profile_image'],
  //     //                 address: e['business_address'],
  //     //                 description: e['business_description'],
  //     //                 type_id: e['business_type_id'],
  //     //                 max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //                 category: Category(
  //     //                   id: e['category_id'],
  //     //                   image: e['category_image'],
  //     //                   name: e['category_name'],
  //     //                 )
  //     //             ),
  //     //           ),
  //     //           business: Business(
  //     //               id: e['business_id'],
  //     //               email: e['business_email'],
  //     //               name: e['business_name'],
  //     //               longitude: e['business_longitude'],
  //     //               latitude: e['business_latitude'],
  //     //               phone_number: e['business_phone_number'],
  //     //               profile_image: e['business_profile_image'],
  //     //               address: e['business_address'],
  //     //               description: e['business_description'],
  //     //               type_id: e['business_type_id'],
  //     //               room_id: e['business_room_id'],
  //     //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //               category: Category(
  //     //                 id: e['category_id'],
  //     //                 image: e['category_image'],
  //     //                 name: e['category_name'],
  //     //               )
  //     //           ),
  //     //           user: User(
  //     //             id: e['user_id'],
  //     //             email: e['user_email'],
  //     //             username: e['user_username'],
  //     //             name: e['user_name'],
  //     //             profile_image: e['user_profile_image'],
  //     //             description: e['user_description'],
  //     //           ),
  //     //           comments: [],
  //     //           likes: [],
  //     //         )
  //     //     );
  //     //   }
  //     //
  //     // }
  //
  //     for(var e in jsonData) {
  //       PostComment postComment = PostComment(
  //         id: e['id'],
  //         is_admin: e['is_admin'],
  //         created_at: DateTime.parse(e['created_at']),
  //         text: e['text'],
  //         // businessPost: post,
  //         user: User(
  //           id: e['user_id'],
  //           description: e['user_description'],
  //           profile_image: e['user_profile_image'],
  //           // first_name: comments[i]['first_name'],
  //           name: e['user_name'],
  //           // last_name: comments[i]['last_name'],
  //           // city: postProvider.posts[i]['city'],
  //           // nation: postProvider.posts[i]['nation'],
  //           username: e['username'],
  //           email: e['user_email'],
  //         ),
  //       );
  //       userPostFavoriteComments.add(postComment);
  //       for(BusinessPost e in postFavoritesList){
  //         if(e.id == postComment.businessPost!.id){
  //           e.comments.add(postComment);
  //         }
  //       }
  //     }
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }
  //
  // Future getUserPostFavoriteLikes() async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/like");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   // print("postcomment getall response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('gf5gf6g65g65gf65gf6');
  //     print(jsonData.length);
  //
  //     /*postProvider.*/userPostFavoriteLikes.clear();
  //     // for(var e in jsonData) {
  //     //   for (BusinessPost post in /*postProvider.*/postFavoritesList) {
  //     //     if(e['post_id'] == post.id){
  //     //       PostLike postlike = PostLike(
  //     //         businessPost: BusinessPost(
  //     //           id: e['post_id'],
  //     //           description: e['post_description'],
  //     //           image_url: e['post_image_url'],
  //     //           // is_admin: e['post_is_admin'],
  //     //           // is_visible: e['post_is_visible'],
  //     //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //     //           // booking: Booking(
  //     //           //   id: e['booking_id'],
  //     //           //   isCanceled: e['is_canceled'],
  //     //           //   // note: myAppointments[index]['note'],
  //     //           //   // user_id: myAppointments[index]['user_id'].toString(),
  //     //           prestazione: Prestazione(
  //     //             id: e['prestazione_id'],
  //     //             duration: e['prestazione_duration'],
  //     //             image: e['prestazione_image'] ?? '',
  //     //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //     //             title: e['prestazione_title'],
  //     //             description: e['prestazione_description'] ?? '',
  //     //             // business_id: e['prestazione_business_id'],
  //     //             business: Business(
  //     //                 id: e['business_id'],
  //     //                 email: e['business_email'],
  //     //                 name: e['business_name'],
  //     //                 longitude: e['business_longitude'],
  //     //                 latitude: e['business_latitude'],
  //     //                 phone_number: e['business_phone_number'],
  //     //                 room_id: e['business_room_id'],
  //     //                 profile_image: e['business_profile_image'],
  //     //                 address: e['business_address'],
  //     //                 description: e['business_description'],
  //     //                 type_id: e['business_type_id'],
  //     //                 max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //                 category: Category(
  //     //                   id: e['category_id'],
  //     //                   image: e['category_image'],
  //     //                   name: e['category_name'],
  //     //                 )
  //     //             ),
  //     //           ),
  //     //           business: Business(
  //     //               id: e['business_id'],
  //     //               email: e['business_email'],
  //     //               name: e['business_name'],
  //     //               longitude: e['business_longitude'],
  //     //               latitude: e['business_latitude'],
  //     //               phone_number: e['business_phone_number'],
  //     //               profile_image: e['business_profile_image'],
  //     //               address: e['business_address'],
  //     //               description: e['business_description'],
  //     //               type_id: e['business_type_id'],
  //     //               room_id: e['business_room_id'],
  //     //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //               category: Category(
  //     //                 id: e['category_id'],
  //     //                 image: e['category_image'],
  //     //                 name: e['category_name'],
  //     //               )
  //     //           ),
  //     //           user: User(
  //     //             id: e['user_id'],
  //     //             email: e['user_email'],
  //     //             username: e['user_username'],
  //     //             name: e['user_name'],
  //     //             profile_image: e['user_profile_image'],
  //     //             description: e['user_description'],
  //     //           ),
  //     //           comments: [],
  //     //           likes: [],
  //     //         ),
  //     //         user: User(
  //     //           id: e['user_id'],
  //     //           email: e['user_email'],
  //     //           username: e['user_username'],
  //     //           name: e['user_name'],
  //     //           profile_image: e['user_profile_image'],
  //     //           description: e['user_description'],
  //     //         ),
  //     //         created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //     //       );
  //     //
  //     //       post.likes.add(postlike);
  //     //       /*postProvider.*/userPostFavoriteLikes.add(postlike);
  //     //     }
  //     //   }
  //     // }
  //
  //
  //     // for(var e in jsonData) {
  //     //   bool elementoEsiste = postFavoritesList.any((element) => element.id == e['post_id']);
  //     //
  //     //   if (!elementoEsiste) {
  //     //     postFavoritesList.add(
  //     //         BusinessPost(
  //     //           id: e['post_id'],
  //     //           description: e['post_description'],
  //     //           image_url: e['post_image_url'],
  //     //           // is_admin: e['post_is_admin'],
  //     //           // is_visible: e['post_is_visible'],
  //     //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //     //           // booking: Booking(
  //     //           //   id: e['booking_id'],
  //     //           //   isCanceled: e['is_canceled'],
  //     //           //   // note: myAppointments[index]['note'],
  //     //           //   // user_id: myAppointments[index]['user_id'].toString(),
  //     //           prestazione: Prestazione(
  //     //             id: e['prestazione_id'],
  //     //             duration: e['prestazione_duration'],
  //     //             image: e['prestazione_image'] ?? '',
  //     //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
  //
  //     //             title: e['prestazione_title'],
  //     //             description: e['prestazione_description'] ?? '',
  //     //             // business_id: e['prestazione_business_id'],
  //     //             business: Business(
  //     //                 id: e['business_id'],
  //     //                 email: e['business_email'],
  //     //                 name: e['business_name'],
  //     //                 longitude: e['business_longitude'],
  //     //                 latitude: e['business_latitude'],
  //     //                 phone_number: e['business_phone_number'],
  //     //                 room_id: e['business_room_id'],
  //     //                 profile_image: e['business_profile_image'],
  //     //                 address: e['business_address'],
  //     //                 description: e['business_description'],
  //     //                 type_id: e['business_type_id'],
  //     //                 max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //                 category: Category(
  //     //                   id: e['category_id'],
  //     //                   image: e['category_image'],
  //     //                   name: e['category_name'],
  //     //                 )
  //     //             ),
  //     //           ),
  //     //           business: Business(
  //     //               id: e['business_id'],
  //     //               email: e['business_email'],
  //     //               name: e['business_name'],
  //     //               longitude: e['business_longitude'],
  //     //               latitude: e['business_latitude'],
  //     //               phone_number: e['business_phone_number'],
  //     //               profile_image: e['business_profile_image'],
  //     //               address: e['business_address'],
  //     //               description: e['business_description'],
  //     //               type_id: e['business_type_id'],
  //     //               room_id: e['business_room_id'],
  //     //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //     //               category: Category(
  //     //                 id: e['category_id'],
  //     //                 image: e['category_image'],
  //     //                 name: e['category_name'],
  //     //               )
  //     //           ),
  //     //           user: User(
  //     //             id: e['user_id'],
  //     //             email: e['user_email'],
  //     //             username: e['user_username'],
  //     //             name: e['user_name'],
  //     //             profile_image: e['user_profile_image'],
  //     //             description: e['user_description'],
  //     //           ),
  //     //           comments: [],
  //     //           likes: [],
  //     //         )
  //     //     );
  //     //   }
  //     //
  //     // }
  //
  //     for(var e in jsonData) {
  //       PostLike postlike = PostLike(
  //         businessPost: BusinessPost(
  //           id: e['post_id'],
  //           description: e['post_description'],
  //           image_url: e['post_image_url'],
  //           // is_admin: e['post_is_admin'],
  //           // is_visible: e['post_is_visible'],
  //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //           // booking: Booking(
  //           //   id: e['booking_id'],
  //           //   isCanceled: e['is_canceled'],
  //           //   // note: myAppointments[index]['note'],
  //           //   // user_id: myAppointments[index]['user_id'].toString(),
  //           prestazione: Prestazione(
  //             id: e['prestazione_id'],
  //             duration: e['prestazione_duration'],
  //             image: e['prestazione_image'] ?? '',
  //             is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //             title: e['prestazione_title'],
  //             description: e['prestazione_description'] ?? '',
  //             // business_id: e['prestazione_business_id'],
  //             business: Business(
  //                 id: e['business_id'],
  //                 email: e['business_email'],
  //                 name: e['business_name'],
  //                 longitude: e['business_longitude'],
  //                 latitude: e['business_latitude'],
  //                 phone_number: e['business_phone_number'],
  //                 room_id: e['business_room_id'],
  //                 profile_image: e['business_profile_image'],
  //                 address: e['business_address'],
  //                 description: e['business_description'],
  //                 type_id: e['business_type_id'],
  //                 max_contemporary_appointments: e['max_contemporary_appointments'],
  //                 category: Category(
  //                   id: e['category_id'],
  //                   image: e['category_image'],
  //                   name: e['category_name'],
  //                 )
  //             ),
  //           ),
  //           business: Business(
  //               id: e['business_id'],
  //               email: e['business_email'],
  //               name: e['business_name'],
  //               longitude: e['business_longitude'],
  //               latitude: e['business_latitude'],
  //               phone_number: e['business_phone_number'],
  //               profile_image: e['business_profile_image'],
  //               address: e['business_address'],
  //               description: e['business_description'],
  //               type_id: e['business_type_id'],
  //               room_id: e['business_room_id'],
  //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //               category: Category(
  //                 id: e['category_id'],
  //                 image: e['category_image'],
  //                 name: e['category_name'],
  //               )
  //           ),
  //           user: User(
  //             id: e['user_id'],
  //             email: e['user_email'],
  //             username: e['user_username'],
  //             name: e['user_name'],
  //             profile_image: e['user_profile_image'],
  //             description: e['user_description'],
  //           ),
  //           comments: [],
  //           likes: [],
  //         ),
  //         user: User(
  //           id: e['user_id'],
  //           email: e['user_email'],
  //           username: e['user_username'],
  //           name: e['user_name'],
  //           profile_image: e['user_profile_image'],
  //           description: e['user_description'],
  //         ),
  //         created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //       );
  //       userPostFavoriteLikes.add(postlike);
  //       for(BusinessPost e in postFavoritesList){
  //         if(e.id == postlike.businessPost!.id){
  //           e.likes.add(postlike);
  //         }
  //       }
  //     }
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }

  Future getAllPostLikes() async {
    // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/like");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/like");

    // Map<String, String?> queryParameters = {
    //   'user_id': Utils.user!.id,
    // };
    //
    // final uri = url.replace(
    //   queryParameters: queryParameters,
    // );

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
      url,
        // uri,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('fg6565fhn65nv56vn65nnh5h5');
      // print(jsonData.length);
      // print(jsonData);

      myPostLikesList.clear();

      for(var e in jsonData){
        myPostLikesList.add(
            PostLike(
              businessPost: BusinessPost(
                id: e['post_id'],
                description: e['post_description'],
                image_url: e['post_image_url'],
                // is_admin: e['post_is_admin'],
                // is_visible: e['post_is_visible'],
                created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                // booking: Booking(
                //   id: e['booking_id'],
                //   isCanceled: e['is_canceled'],
                //   // note: myAppointments[index]['note'],
                //   // user_id: myAppointments[index]['user_id'].toString(),
                prestazione: Prestazione(
                  id: e['prestazione_id'],
                  duration: e['prestazione_duration'],
                  image: e['prestazione_image'] ?? '',
                  is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
                  title: e['prestazione_title'],
                  description: e['prestazione_description'] ?? '',
                  isValid: e['prestazione_is_valid'],
                  // business_id: e['prestazione_business_id'],
                  business: Business(
                      id: e['business_id'],
                      email: e['business_email'],
                      name: e['business_name'],
                      longitude: e['business_longitude'],
                      latitude: e['business_latitude'],
                      phone: e['business_phone'],
                      room_id: e['business_room_id'],
                      profile_image: e['business_profile_image'],
                      address: e['business_address'],
                      description: e['business_description'],
                      type_id: e['business_type_id'],
                      max_contemporary_appointments: e['max_contemporary_appointments'],
                      category: Category(
                        id: e['category_id'],
                        image: e['category_image'],
                        name: e['category_name'],
                      )
                  ),
                ),
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    profile_image: e['business_profile_image'],
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    room_id: e['business_room_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
                user: User(
                  id: e['user_id'],
                  email: e['user_email'],
                  username: e['user_username'],
                  name: e['user_name'],
                  profile_image: e['user_profile_image'] ?? '',
                  description: e['user_description'],
                ),
                comments: [],
                likes: [],
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              created_at: DateTime.tryParse(e['created_at'] ?? '')?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            )
        );
      }
      // postProvider.myPostLikesList.addAll(jsonData);

      print('postProvider.myPostLikesList.length');
      // print(postProvider.myPostLikesList);
      print(myPostLikesList.length);
      // for(var e in postProvider.myPostLikesList){
      //   print("e.post.id");
      //   print(e.businessPost!.id);
      // }

      notifyListeners();
      return jsonData;
    }
    return;
  }

  Future getUserBusinessPostFavorites(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/${Utils.business_id}/post/like");

    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/post/like");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/post/user/like");

    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // removeAllPostFavorite();

      // postFavoritesList.addAll(jsonData);

      // print('f56f65fgf65ggf56gf6565');
      // print(jsonData.length);

      postFavoritesList.clear();
      for(var e in jsonData){
        postFavoritesList.add(
            BusinessPost(
              id: e['post_id'],
              description: e['post_description'],
              image_url: e['post_image_url'],
              // is_admin: e['post_is_admin'],
              // is_visible: e['post_is_visible'],
              created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              // booking: Booking(
              //   id: e['booking_id'],
              //   isCanceled: e['is_canceled'],
              //   // note: myAppointments[index]['note'],
              //   // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                id: e['prestazione_id'],
                duration: e['prestazione_duration'],
                image: e['prestazione_image'] ?? '',
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
                title: e['prestazione_title'],
                description: e['prestazione_description'] ?? '',
                isValid: e['prestazione_is_valid'],
                // business_id: e['prestazione_business_id'],
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    room_id: e['business_room_id'],
                    profile_image: e['business_profile_image'],
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
              ),
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  room_id: e['business_room_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              comments: [],
              likes: [],
            )
        );
      }

      // postFavoritesList.sort((b, a) {
      //   return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
      // });

      // print('jsonData666666666666666');
      // print(jsonData.length);

      notifyListeners();
      return jsonData;
    }
  }

  // Future getUserEventFavorites(User user) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "event_favorite/user_id");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/event/like");
  //
  //   Map<String, dynamic> body = {
  //     'user_id': user.id,
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       }
  //   );
  //
  //   // //print("ticketUsers response.statusCode:");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // for(var e in favoritesList){
  //     //   if(e['event_id'] != null){
  //     //     favoritesList.remove(e);
  //     //   }
  //     // }
  //     removeAllEventFavorite();
  //     // myFavoritesList = jsonData;
  //     // List.from(myFavoritesList).add(jsonData);
  //     // favoritesList.add(jsonData);
  //     postFavoritesList.addAll(jsonData);
  //
  //     postFavoritesList.sort((b, a) {
  //       return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
  //     });
  //
  //     // //print('jsonData allaahh');
  //     // //print(jsonData);
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }

  removeAllEventFavorite(){
    for(var e in List.from(postFavoritesList)){
      if(e['event_id'] != null){
        postFavoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  removeAllPostFavorite(){
    for(BusinessPost e in List.from(postFavoritesList)){
      if(e.prestazione!.id != null){
        postFavoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  // removeEventFavorite(String id){
  //   for(var e in postFavoritesList){
  //     if(e['event_id'] != null && e['event_id'] == id) {
  //       postFavoritesList.remove(e);
  //     }
  //   }
  //   notifyListeners();
  // }

  removePrestazioneFavorite(String id){
    for(var e in postFavoritesList){
      if(e.prestazione!.id != null && e.prestazione!.id == id){
        postFavoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  emptyFavorites(){
    postFavoritesList.clear();
    notifyListeners();
  }

  // Future getAllUserPosts() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking_post");
  //   var url = Uri.parse("${Utils.httpServerUrl}booking/post");
  //
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   categoryList.addAll(jsonData);
  //     // });
  //
  //     // postList = jsonData;
  //     postList.addAll(jsonData);
  //
  //     //print('postList');
  //     //print(postList);
  //
  //     return jsonData;
  //   }
  // }

  Future getAllBusinessesPosts(BuildContext context) async {
    GeolocationProvider geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "business_post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
    var url;
    if(/*Utils.isBusiness*/UserPreferences.getIsLogged()!) {
      // url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post/is_visible");
      url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/feed/business/post/is_visible");
      // url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/follow/business/post/is_visible");
    }
    else {
      url = Uri.parse("${Utils.httpServerUrl}business/post/is_visible");
    }

    Map<String, dynamic> body = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    // Map<String, String?> queryParameters = {
    //   'user_id': user.id,
    // };
    final uri = url.replace(
      queryParameters: /*queryParameters*/body,
    );

    var response = await http.get(
        // url,
        uri,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   categoryList.addAll(jsonData);
      // });

      // postList = jsonData;
      // postList.addAll(jsonData);

      postList.clear();
      for(var e in jsonData){
        postList.add(
          // BookingPost(
          //   id: e['post_id'],
          //   description: e['post_description'],
          //   image_url: e['post_image_url'],
          //   is_admin: e['post_is_admin'],
          //   is_visible: e['post_is_visible'],
          //   created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
          //   booking: Booking(
          //     id: e['booking_id'],
          //     isCanceled: e['is_canceled'],
          //     // note: myAppointments[index]['note'],
          //     // user_id: myAppointments[index]['user_id'].toString(),
          //     prestazione: Prestazione(
          //       id: e['prestazione_id'],
          //       duration: e['prestazione_duration'],
          //       image: e['prestazione_image'] ?? '',
          //       is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
          //       price: e['prestazione_price']?.toDouble(),
          //       price_min: e['prestazione_price_min']?.toDouble(),
          //       price_max: e['prestazione_price_max']?.toDouble(),
          //
          //       title: e['prestazione_title'],
          //       description: e['prestazione_description'] ?? '',
          //       // business_id: e['prestazione_business_id'],
          //       business: Business(
          //           id: e['business_id'],
          //           email: e['business_email'],
          //           name: e['business_name'],
          //           longitude: e['business_longitude'],
          //           latitude: e['business_latitude'],
          //           phone_number: e['business_phone_number'],
          //           room_id: e['business_room_id'],
          //           profile_image: e['business_profile_image'],
          //           address: e['business_address'],
          //           description: e['business_description'],
          //           type_id: e['business_type_id'],
          //           max_contemporary_appointments: e['max_contemporary_appointments'],
          //           category: Category(
          //             id: e['category_id'],
          //             image: e['category_image'],
          //             name: e['category_name'],
          //           )
          //       ),
          //     ),
          //     business: Business(
          //         id: e['business_id'],
          //         email: e['business_email'],
          //         name: e['business_name'],
          //         longitude: e['business_longitude'],
          //         latitude: e['business_latitude'],
          //         phone_number: e['business_phone_number'],
          //         profile_image: e['business_profile_image'],
          //         address: e['business_address'],
          //         description: e['business_description'],
          //         type_id: e['business_type_id'],
          //         room_id: e['business_room_id'],
          //         max_contemporary_appointments: e['max_contemporary_appointments'],
          //         category: Category(
          //           id: e['category_id'],
          //           image: e['category_image'],
          //           name: e['category_name'],
          //         )
          //     ),
          //     user: User(
          //       id: e['user_id'],
          //       email: e['user_email'],
          //       username: e['user_username'],
          //       name: e['user_name'],
          //       phone_number: e['user_phone_number'],
          //       profile_image: e['user_profile_image'],
          //       description: e['user_description'],
          //     ),
          //     begin_at: DateTime.tryParse(e['begin_at']),
          //     end_at: DateTime.parse(e['begin_at']).add(Duration(minutes: e['prestazione_duration'].toInt())),
          //     created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
          //   ),
          //   user: User(
          //     profile_image: e['user_profile_image'],
          //     id: e['user_id'],
          //     username: e['user_username'],
          //     email: e['user_email'],
          //     name: e['user_name'],
          //     description: e['user_description'],
          //   ),
          // )
          BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                id: e['prestazione_id'],
                duration: e['prestazione_duration'],
                image: e['prestazione_image'] ?? '',
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
                title: e['prestazione_title'],
                description: e['prestazione_description'] ?? '',
                isValid: e['prestazione_is_valid'],
                // business_id: e['prestazione_business_id'],
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    room_id: e['business_room_id'],
                    profile_image: e['business_profile_image'],
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
              ),
              business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          )
        );
      }

      // print('postList555663');
      // print(postList);
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  // Future getAllBusinessPosts(Business business) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_post");
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/post");
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/post/is_visible");
  //
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   categoryList.addAll(jsonData);
  //     // });
  //
  //     // postList = jsonData;
  //     // postList.addAll(jsonData);
  //
  //     businessProfilePostList.clear();
  //     for(var e in jsonData){
  //       businessProfilePostList.add(
  //         // BookingPost(
  //         //   id: e['post_id'],
  //         //   description: e['post_description'],
  //         //   image_url: e['post_image_url'],
  //         //   is_admin: e['post_is_admin'],
  //         //   is_visible: e['post_is_visible'],
  //         //   created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //         //   booking: Booking(
  //         //     id: e['booking_id'],
  //         //     isCanceled: e['is_canceled'],
  //         //     // note: myAppointments[index]['note'],
  //         //     // user_id: myAppointments[index]['user_id'].toString(),
  //         //     prestazione: Prestazione(
  //         //       id: e['prestazione_id'],
  //         //       duration: e['prestazione_duration'],
  //         //       image: e['prestazione_image'] ?? '',
  //         //       is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //         //       title: e['prestazione_title'],
  //         //       description: e['prestazione_description'] ?? '',
  //         //       // business_id: e['prestazione_business_id'],
  //         //       business: Business(
  //         //           id: e['business_id'],
  //         //           email: e['business_email'],
  //         //           name: e['business_name'],
  //         //           longitude: e['business_longitude'],
  //         //           latitude: e['business_latitude'],
  //         //           phone_number: e['business_phone_number'],
  //         //           room_id: e['business_room_id'],
  //         //           profile_image: e['business_profile_image'],
  //         //           address: e['business_address'],
  //         //           description: e['business_description'],
  //         //           type_id: e['business_type_id'],
  //         //           max_contemporary_appointments: e['max_contemporary_appointments'],
  //         //           category: Category(
  //         //             id: e['category_id'],
  //         //             image: e['category_image'],
  //         //             name: e['category_name'],
  //         //           )
  //         //       ),
  //         //     ),
  //         //     business: Business(
  //         //         id: e['business_id'],
  //         //         email: e['business_email'],
  //         //         name: e['business_name'],
  //         //         longitude: e['business_longitude'],
  //         //         latitude: e['business_latitude'],
  //         //         phone_number: e['business_phone_number'],
  //         //         profile_image: e['business_profile_image'],
  //         //         address: e['business_address'],
  //         //         description: e['business_description'],
  //         //         type_id: e['business_type_id'],
  //         //         room_id: e['business_room_id'],
  //         //         max_contemporary_appointments: e['max_contemporary_appointments'],
  //         //         category: Category(
  //         //           id: e['category_id'],
  //         //           image: e['category_image'],
  //         //           name: e['category_name'],
  //         //         )
  //         //     ),
  //         //     user: User(
  //         //       id: e['user_id'],
  //         //       email: e['user_email'],
  //         //       username: e['user_username'],
  //         //       name: e['user_name'],
  //         //       phone_number: e['user_phone_number'],
  //         //       profile_image: e['user_profile_image'],
  //         //       description: e['user_description'],
  //         //     ),
  //         //     begin_at: DateTime.tryParse(e['begin_at']),
  //         //     end_at: DateTime.parse(e['begin_at']).add(Duration(minutes: e['prestazione_duration'].toInt())),
  //         //     created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
  //         //   ),
  //         //   user: User(
  //         //     profile_image: e['user_profile_image'],
  //         //     id: e['user_id'],
  //         //     username: e['user_username'],
  //         //     email: e['user_email'],
  //         //     name: e['user_name'],
  //         //     description: e['user_description'],
  //         //   ),
  //         // )
  //         BusinessPost(
  //           id: e['post_id'],
  //           description: e['post_description'],
  //           image_url: e['post_image_url'],
  //           // is_admin: e['post_is_admin'],
  //           // is_visible: e['post_is_visible'],
  //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //           // booking: Booking(
  //           //   id: e['booking_id'],
  //           //   isCanceled: e['is_canceled'],
  //           //   // note: myAppointments[index]['note'],
  //           //   // user_id: myAppointments[index]['user_id'].toString(),
  //             prestazione: Prestazione(
  //               id: e['prestazione_id'],
  //               duration: e['prestazione_duration'],
  //               image: e['prestazione_image'] ?? '',
  //               is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
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
  //               id: e['business_id'],
  //               email: e['business_email'],
  //               name: e['business_name'],
  //               longitude: e['business_longitude'],
  //               latitude: e['business_latitude'],
  //               phone_number: e['business_phone_number'],
  //               profile_image: e['business_profile_image'],
  //               address: e['business_address'],
  //               description: e['business_description'],
  //               type_id: e['business_type_id'],
  //               room_id: e['business_room_id'],
  //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //               category: Category(
  //                 id: e['category_id'],
  //                 image: e['category_image'],
  //                 name: e['category_name'],
  //               )
  //           ),
  //           user: User(
  //             id: e['user_id'],
  //             email: e['user_email'],
  //             username: e['user_username'],
  //             name: e['user_name'],
  //             profile_image: e['user_profile_image'],
  //             description: e['user_description'],
  //           ),
  //           comments: [],
  //           likes: [],
  //         )
  //       );
  //     }
  //
  //     // print('postList555663');
  //     // print(postList);
  //     // print(postList.length);
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }

  Future getAllBusinessClients(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/booking/user");

    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   categoryList.addAll(jsonData);
      // });

      // postList = jsonData;
      // postList.addAll(jsonData);

      businessProfileUsersList.clear();
      for(var e in jsonData){
        businessProfileUsersList.add(
          User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          )
        );
      }

      // print('postList555663');
      // print(postList);
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getHomeBusinessPosts() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
    var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post?home=1");

    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   categoryList.addAll(jsonData);
      // });

      // postList = jsonData;
      // postList.addAll(jsonData);

      for(var e in jsonData){
        homePostList.add(
          BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                id: e['prestazione_id'],
                duration: e['prestazione_duration'],
                image: e['prestazione_image'] ?? '',
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
                title: e['prestazione_title'],
                description: e['prestazione_description'] ?? '',
                isValid: e['prestazione_is_valid'],
                // business_id: e['prestazione_business_id'],
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    room_id: e['business_room_id'],
                    profile_image: e['business_profile_image'],
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
              ),
              business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          )
        );
      }

      // print('postList555663');
      // print(postList);
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future insertHomeBusinessPosts() async {
    for(int i = 0; i < 5; i++) {
      if(!homePostList.contains(postList[Random().nextInt(postList.length)])) {
        homePostList.add(postList[Random().nextInt(postList.length)]);
      }
    }
    // print('homePostList.length');
    // print(homePostList.length);
    notifyListeners();
  }

  Future getBookingPostComments(String? postId) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/$postId/comment");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      'post_id': postId,
      // 'text': commentController.text,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // print("6vv6vv6bv6bb5b5bb5:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   bookingPostComments.addAll(jsonData);
      postComments = jsonData;

      // });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  // Future getAllBusinessPostComments(BookingPost post, Business business) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/post/comment");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   Map/*<String, String>*/ body = {
  //     // 'user_id': userProvider.user.id,
  //     'post_id': post.id,
  //     // 'text': commentController.text,
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       }
  //   );
  //
  //   // //print("postcomment getall response.statusCode:");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // setState(() {
  //     //   bookingPostComments.addAll(jsonData);
  //     postComments = jsonData;
  //
  //     for(PostComment comment in postComments) {
  //       for(BusinessPost post in postList) {
  //         if(comment.businessPost!.id == post.id && !post.comments!.contains(comment)) {
  //           post.comments!.add(comment);
  //         }
  //       }
  //     }
  //
  //     // });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     // //print(jsonData);
  //     return jsonData;
  //   }
  // }

  Future getBookingPostLikes(String? postId) async {
    postLikes.clear();
    isLikedPost = false;
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/post_id");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/$postId/like");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      'post_id': postId,
      // 'text': commentController.text,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("2v2b2b2bb2b2b2bb22:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      postLikes.addAll(jsonData);
      // bookingPostLikes = jsonData;
      // });
      for (var like in List.from(postLikes)) {
        // //print('like gggyg');
        // //print(like);
        //print(like['user_id'] == userProvider.user!.id);
        // if (like['id'] == singleEventPost.id) {
        // if (like['user_id'] == userProvider.user!.id) {
        if(Utils.user != null) {
          if (like['user_id'] == Utils.user!.id) {
            // setState(() {
            isLikedPost = true;
            // });
          }
        }
      }

      // setState(() {
      // isLikedPost = true;
      // });

      //print('jsonData.length');
      //print(jsonData.length);
      //print('bookingPostLikes.lengthhui');
      //print(bookingPostLikes.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessPostLikes(String? postId, String businessId) async {
    isLikedPost = false;
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/post_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessId}/post/$postId/like");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      'post_id': postId,
      // 'text': commentController.text,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("ff5f5ff5f8ff8fvbbf6b5nmm5j5:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // /*postLikes*/businessPostLikes.addAll(jsonData);
      // bookingPostLikes = jsonData;
      // });
      print('g5g6gg6g6g6g6g6g6');
      print(jsonData.length);

      postLikes.clear();
      for(var e in jsonData){
        PostLike postlike = PostLike(
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          ),
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          ),
          created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        );

        // print("vg5g5g5gh5hh5h5");
        // print(e['user_id']);
        // print(postlike.user!.id);
        // print(postlike.user!.id == Utils.user!.id);

        if(Utils.user != null) {
          if (postlike.user!.id == Utils.user!.id) {
            // setState(() {
            isLikedPost = true;
            // });
          }
        }
        // print(isLikedPost);

        postLikes.add(
          postlike
        );

        // for(BusinessPost post in postList) {
        //   if(post.id == postlike.businessPost!.id){
        //     post.likes?.add(postlike);
        //   }
        // }
      }

      // // for (PostLike like in List.from(/*postLikes*/businessPostLikes)) {
      // for (PostLike like in postLikes) {
      //   // //print('like gggyg');
      //   // //print(like);
      //   //print(like['user_id'] == userProvider.user!.id);
      //   // if (like['id'] == singleEventPost.id) {
      //   // if (like['user_id'] == userProvider.user!.id) {
      //   if(Utils.user != null) {
      //     if (like.user!.id == Utils.user!.id) {
      //       // setState(() {
      //       isLikedPost = true;
      //       // });
      //     }
      //   }
      // }

      // print('businessPostLikes.length');
      // print(businessPostLikes.length);
      // print('isLikedPost');
      // print(isLikedPost);

      // setState(() {
      // isLikedPost = true;
      // });

      //print('jsonData.length');
      //print(jsonData.length);
      // print('businessPostLikes.lef5f5ff6ngthhui');
      // print(businessPostLikes.length);

      notifyListeners();

      return jsonData;
    }
  }

  Future getBusinessHomePostLikes(String? postId, String businessId) async {
    isLikedHomePost = false;
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/post_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessId}/post/$postId/like");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      'post_id': postId,
      // 'text': commentController.text,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("likegd8gdgd4gd48gd48dge:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // /*postLikes*/businessPostLikes.addAll(jsonData);
      // bookingPostLikes = jsonData;
      // });
      homePostLikes.clear();
      for(var e in jsonData){
        PostLike postlike = PostLike(
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          ),
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          ),
          created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        );

        homePostLikes.add(
          postlike
        );

        // for(BusinessPost post in postList) {
        //   if(post.id == postlike.businessPost!.id){
        //     post.likes?.add(postlike);
        //   }
        // }
      }

      // for (PostLike like in List.from(/*postLikes*/businessPostLikes)) {
      for (PostLike like in homePostLikes) {
        // //print('like gggyg');
        // //print(like);
        //print(like['user_id'] == userProvider.user!.id);
        // if (like['id'] == singleEventPost.id) {
        // if (like['user_id'] == userProvider.user!.id) {
        if(Utils.user != null) {
          if (like.user!.id == Utils.user!.id) {
            // setState(() {
            isLikedHomePost = true;
            // });
          }
        }
      }

      // print('businessPostLikes.length');
      // print(businessPostLikes.length);
      // print('isLikedPost');
      // print(isLikedPost);

      // setState(() {
      // isLikedPost = true;
      // });

      //print('jsonData.length');
      //print(jsonData.length);
      // print('businessPostLikes.lef5f5ff6ngthhui');
      // print(businessPostLikes.length);

      notifyListeners();

      return jsonData;
    }
  }

  // Future getAllBusinessPostComments(String postId) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/user_id");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/$userId/business/post/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post/$postId/comment");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'user_id': userId,
  //   //   // 'text': commentController.text,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       }
  //   );
  //
  //   //print("postcomment getall response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     businessPostComments = jsonData;
  //
  //     //print('businessPostComments');
  //     //print(jsonData);
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     // //print(jsonData);
  //     // notifyListeners();
  //     return jsonData;
  //   }
  // }

  // Future getAllBookingPostLikes(String bookingPostId) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/booking_post_id");
  //
  //   Map/*<String, String>*/ body = {
  //     "booking_post_id": bookingPostId
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     businessPostLikes = jsonData;
  //     // //print("posts provider");
  //     // //print(posts);
  //     // //print(jsonData);
  //     // notifyListeners();
  //     return jsonData;
  //   }
  // }

  Future likeBookingPost(BookingPost post, User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/like");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/${post.id}/like");
    // var chatProvider = Provider.of<ChatProvider>(context);

    Map/*<String, String>*/ body = {
      "user_id": user.id,
      'post_id': post.id
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      await getBookingPostLikes(post.id);
      // setState(() {
        isLikedPost = true;
      // });
      //print('like post');

      notifyListeners();
      return jsonData;
      // return false;
    }
  }

  Future unlikeBookingPost(BookingPost post, User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/unlike");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/${post.id}/like");
    // var chatProvider = Provider.of<ChatProvider>(context);

    Map/*<String, String>*/ body = {
      "user_id": user.id,
      'post_id': post.id
    };

    // var response = await http.post(
    var response = await http.delete(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      await getBookingPostLikes(post.id);

      // setState(() {
        isLikedPost = false;
      // });

      //print('unlike post');
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future likeBusinessPost(BusinessPost post, User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/like");
    var url = Uri.parse("${Utils.httpServerUrl}business/${post.business!.id}/post/${post.id}/like");
    // var chatProvider = Provider.of<ChatProvider>(context);

    Map/*<String, String>*/ body = {
      "user_id": user.id,
      'post_id': post.id
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    print("fg6gg6g6g6g6g6gbbnn3:");
    print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // await getBusinessPostLikes(postId);
      // businessPostLikes.length = businessPostLikes.length + 1;
      print('jsonDatab5bg5g6');
      print(jsonData);
      // businessPostLikes.add({
      //   "business_post_id": postId,
      //   'user_id': Utils.user!.id,
      //   'created_at': DateTime.now().toString()
      // });
      postLikes.add(
        PostLike(
          businessPost: post,
          // bookingPost: post,
          user: user,
          created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        )
      );

      userProfilePostLikes.add/*If*/(
        // userProfilePostLikes.where(),
        PostLike(
          businessPost: post,
          // bookingPost: post,
          user: user,
          created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        )
      );

      businessProfilePostLikes.add/*If*/(
        // userProfilePostLikes.where(),
        PostLike(
          businessPost: post,
          // bookingPost: post,
          user: user,
          created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        )
      );

      for(BusinessPost e in postFavoritesList){
        if(e.id == post.id){
          e.likes.add(
            PostLike(
              businessPost: post,
              user: user,
              created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            )
          );
        }
      }

      // print(post.toString());
      myPostLikesList.add(
        PostLike(
          businessPost: post,
          user: user,
          created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        )
      );

      // setState(() {
        isLikedPost = true;
      // });
      //print('like post');

      homePostLikes.add(
          PostLike(
            businessPost: post,
            // bookingPost: post,
            user: user,
            created_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
          )
      );

      // setState(() {
      isLikedHomePost = true;

      notifyListeners();
      return jsonData;
      // return false;
    }
  }

  Future unlikeBusinessPost(BusinessPost post, User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/unlike");
    var url = Uri.parse("${Utils.httpServerUrl}business/${post.business!.id}/post/${post.id}/like");
    // var chatProvider = Provider.of<ChatProvider>(context);

    Map/*<String, String>*/ body = {
      "user_id": user.id,
      'post_id': post.id
    };

    // var response = await http.post(
    var response = await http.delete(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // print("6b6b6bhjhghjkkk:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // await getBusinessPostLikes(postId);
      // businessPostLikes.length = businessPostLikes.length - 1;
      postLikes.removeWhere((element) {
        return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
      });

      myPostLikesList.removeWhere((element) {
        return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
      });

      // print('userProfilePostLikes.length1');
      // print(userProfilePostLikes.length);
      userProfilePostLikes.removeWhere((element) {
        return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
      });
      // print(userProfilePostLikes.length);

      businessProfilePostLikes.removeWhere((element) {
        return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
      });

      for(BusinessPost e in postFavoritesList){
        if(e.id == post.id){
          e.likes.removeWhere((element) {
            return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
          });
        }
      }

      // setState(() {
        isLikedPost = false;
      // });

      homePostLikes.removeWhere((element) {
        return element.user!.id == Utils.user!.id && element.businessPost!.id == post.id;
      });

      // setState(() {
      isLikedHomePost = false;
      // });

      //print('unlike post');
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

// Future getAllFollowSingleEventPost() async {
//   // var url = Uri.parse("http://192.168.1.252/kadingira/everyFollowPost.php");
//   var url = Uri.parse(Utils.httpServerUrl + "single_event_post/follow/user_id");
//   Map/*<String, String>*/ body = {
//     'user_id': widget.user.id.toString(),
//   };
//
//   var response = await http.post(
//       url,
//       body: jsonEncode(body),
//       headers: {
//         'Accept': '*/*',
//         'Content-Type': 'application/json',
//         'Accept-encoding': 'gzip, deflate',
//         'connection': 'keep-alive',
//       }
//   );
//
//   if(response.statusCode >= 200 && response.statusCode < 400) {
//     var jsonData = json.decode(response.body);
//     setState(() {
//       singleEventPostList = jsonData;
//     });
//     // //print("post: ");
//     // //print(postList);
//     // //print("post.length: " + postList.length.toString());
//     return jsonData;
//   }
// }
//
// Future getAllFollowVideoStory() async {
//   // var url = Uri.parse("http://192.168.1.252/kadingira/everyFollowPost.php");
//   var url = Uri.parse(Utils.httpServerUrl + "story/follow/user_id/video");
//   Map/*<String, String>*/ body = {
//     'user_id': widget.user.id.toString(),
//   };
//
//   var response = await http.post(
//       url,
//       body: jsonEncode(body),
//       headers: {
//         'Accept': '*/*',
//         'Content-Type': 'application/json',
//         'Accept-encoding': 'gzip, deflate',
//         'connection': 'keep-alive',
//       }
//   );
//
//   if(response.statusCode >= 200 && response.statusCode < 400) {
//     var jsonData = json.decode(response.body);
//     setState(() {
//       storyList = jsonData;
//     });
//     // //print("post: ");
//     // //print(postList);
//     // //print("post.length: " + postList.length.toString());
//     return jsonData;
//   }
// }
//
// Future getAllFollowImageStory() async {
//   // var url = Uri.parse("http://192.168.1.252/kadingira/everyFollowPost.php");
//   var url = Uri.parse(Utils.httpServerUrl + "story/follow/user_id/image");
//   Map/*<String, String>*/ body = {
//     'user_id': widget.user.id.toString(),
//   };
//
//   var response = await http.post(
//       url,
//       body: jsonEncode(body),
//       headers: {
//         'Accept': '*/*',
//         'Content-Type': 'application/json',
//         'Accept-encoding': 'gzip, deflate',
//         'connection': 'keep-alive',
//       }
//   );
//
//   if(response.statusCode >= 200 && response.statusCode < 400) {
//     var jsonData = json.decode(response.body);
//     setState(() {
//       storyList = jsonData;
//     });
//     // //print("post: ");
//     // //print(postList);
//     // //print("post.length: " + postList.length.toString());
//     return jsonData;
//   }
// }

  Future getBusinessPostComments(String postId, String businessId) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${Utils.business_id}/post/${postId}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessId}/post/${postId}/comment");
    // var userProvider = Provider.of<UserProvider>(context);

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    print("g5gg55nm5m4k4mnh4n4m:");
    print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //   comments = jsonData;

      print('postComments.length5565665');
      print(postComments.length);

      postComments.clear();
      // userProfilePostComments.clear();

      List<PostComment> postCommentToAddList = [];
      BusinessPost? businessPostOpenedLikesTemp;
      for(var e in jsonData){
        PostComment postcomment = PostComment(
          id: e['id'],
          text: e['text'],
          is_admin: e['is_admin'],
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          ),
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          ),
          created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        );

        postComments.add(
          postcomment
        );

        // for(PostComment comm1 in userProfilePostComments) {
          // if(comm1.id == postcomment.businessPost!.id) {
            if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
              !(userProfilePostComments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
            // e1.comments.add(postcomment);
              userProfilePostComments.add(postcomment);
            }
          // }
        // }
        // userProfilePostComments.add(
        //   postcomment
        // );

        if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
          !(businessProfilePostComments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
          businessProfilePostComments.add(postcomment);
        }

        for(BusinessPost e1 in postFavoritesList) {
          if(e1.id == postcomment.businessPost!.id) {
            // e1.comments.clear();
            // e1.comments.remove(postcomment);
            // var seenIds = <PostComment>{};
            // seenIds.add(postcomment);
            // if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
            //   !(e1.comments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
            //   e1.comments.add(postcomment);
            // }
            // e1.comments.addAll(seenIds.toList());

            businessPostOpenedLikesTemp = e1;
          }
          // e1.comments.removeWhere((element) => element.id == postcomment.id);
          // e1.comments.toSet().toList();
        }

        for(BusinessPost e1 in postFavoritesList) {
          if(e1.id == postcomment.businessPost!.id) {
            // if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
            //   !(e1.comments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
              // e1.comments.add(postcomment);
              postCommentToAddList.add(postcomment);
            // }
          }
        }

      }

      for(BusinessPost e1 in postFavoritesList) {
        if(e1.id == businessPostOpenedLikesTemp?.id) {
          e1.comments.clear();
        }
      }

      for(BusinessPost e1 in postFavoritesList) {
        if(e1.id == businessPostOpenedLikesTemp?.id) {
          e1.comments.addAll(postCommentToAddList);
        }
      }

      for(BusinessPost post in postList) {
        if(postComments.length > 0) {
          // print('post.id');
          // print(post.id);
          // print('postComments[0].id');
          // print(postComments[0].id);
          if (post.id == postComments[0].businessPost!.id && post.comments.length == 0) {
            post.comments.addAll(postComments);
            // print('vv2b2bb2b2bn2');
            // print(post.comments.length);
          }
        }
      }

      print('json656565g5g5');
      print(postId);
      print(postComments.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessHomePostComments(String postId, String businessId) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${Utils.business_id}/post/${postId}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessId}/post/${postId}/comment");
    // var userProvider = Provider.of<UserProvider>(context);

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // print("5gbh5j5kjhjkmjhghjm5g6g:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //   comments = jsonData;

      // print('postComments.length5565665');
      // print(postComments.length);

      homePostComments.clear();
      for(var e in jsonData){
        PostComment postcomment = PostComment(
          id: e['id'],
          text: e['text'],
          is_admin: e['is_admin'],
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              duration: e['prestazione_duration'],
              image: e['prestazione_image'] ?? '',
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
              title: e['prestazione_title'],
              description: e['prestazione_description'] ?? '',
              isValid: e['prestazione_is_valid'],
              // business_id: e['prestazione_business_id'],
              business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              ),
            ),
            business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            comments: [],
            likes: [],
          ),
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          ),
          created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        );

        homePostComments.add(
          postcomment
        );
      }

      for(BusinessPost post in homePostList) {
        if(homePostComments.length > 0) {
          // print('post.id');
          // print(post.id);
          // print('postComments[0].id');
          // print(homePostComments[0].id);
          if (post.id == homePostComments[0].businessPost!.id && post.comments.length == 0) {
            post.comments.addAll(homePostComments);
            // print('vv2b2bb2b2bn2');
            // print(post.comments.length);
          }
        }
      }

      // print('json656565g5g5');
      // print(postId);
      // print(homePostComments.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future createBusinessPostComment(BusinessPost post, String text) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/create");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${post.business!.id}/post/${post.id}/comment");
    // var userProvider = Provider.of<UserProvider>(context, listen: false);

    Map/*<String, String>*/ body = {
      'user_id': Utils.user!.id,
      'post_id': post.id,
      'text': text,
      // 'text': commentController.text,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("postcomment create response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print(jsonData.toString());
      // //print(jsonData);
      // commentController.clear();
      // commentController.text = '';


      notifyListeners();
      return jsonData;
    }
  }

  Future deleteBusinessPostComment(BusinessPost post, PostComment comment) async {
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${post.business!.id}/post/${post.id}/comment/${comment.id}");

    // Map/*<String, String>*/ body = {
    //   "user_id": user.id,
    //   'post_id': post.id
    // };

    // var response = await http.post(
    var response = await http.delete(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //cancellare commento
      postComments.removeWhere((element) => element.id == comment.id);
      // for(PostComment e in postComments){
      //   if(e.id == comment.id){
      //     postComments.removeWhere((element) => e.id == comment.id);
      //   }
      // }

      //print('f6f6f65 post');
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  // Future getAllPostComments() async {
  //   var url = Uri.parse(Constants.serverUrl + "post_comment/post_id");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   Map/*<String, String>*/ body = {
  //     // 'user_id': userProvider.user.id,
  //     'post_id': widget.post.id,
  //     // 'text': commentController.text,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("postcomment getall response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       comments = jsonData;
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     // //print(jsonData);
  //     return jsonData;
  //   }
  // }
  //
  // Future createPostComment() async {
  //   var url = Uri.parse(Constants.serverUrl + "post_comment/create");
  //   // var userProvider = Provider.of<UserProvider>(context, listen: false);
  //
  //   Map/*<String, String>*/ body = {
  //     'user_id': widget.myUser.id,
  //     'post_id': widget.post.id,
  //     'text': commentController.text,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("postcomment create response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // //print(jsonData.toString());
  //     // //print(jsonData);
  //     // commentController.clear();
  //     // commentController.text = '';
  //
  //     return jsonData;
  //   }
  // }

  Future getAllSingleEventPostComments(String postId) async {
    var url = Uri.parse(Utils.httpServerUrl + "single_event_post_comment/post_id");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      // 'post_id': widget.post!.id,
      'post_id': postId,
      // 'text': commentController.text,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
        comments = jsonData;
      // });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future createSingleEventPostComment(String postId, String text) async {
    var url = Uri.parse(Utils.httpServerUrl + "single_event_post_comment/create");
    // var userProvider = Provider.of<UserProvider>(context, listen: false);

    Map/*<String, String>*/ body = {
      // 'user_id': widget.myUser!.id,
      'user_id': Utils.user!.id,
      // 'post_id': widget.post!.id,
      'post_id': postId,
      // 'text': commentController.text,
      'text': text,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("postcomment create response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print(jsonData.toString());
      // //print(jsonData);
      // commentController.clear();
      // commentController.text = '';

      notifyListeners();
      return jsonData;
    }
  }

  Future getAllBookingPostComments(String postId) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}booking/post/${widget.post!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/${postId}/comment");
    // var userProvider = Provider.of<UserProvider>(context);

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.post!.id,
    //   // 'text': commentController.text,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
        comments = jsonData;
      // });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future createBookingPostComment(String postId, String text) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/create");
    // var url = Uri.parse("${Utils.httpServerUrl}booking/post/${widget.post!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/${postId}/comment");
    // var userProvider = Provider.of<UserProvider>(context, listen: false);

    Map/*<String, String>*/ body = {
      // 'user_id': widget.myUser!.id,
      'user_id': Utils.user!.id,
      // 'post_id': widget.post!.id,
      'post_id': postId,
      // 'text': commentController.text,
      'text': text,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    //print("postcomment create response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print(jsonData.toString());
      // //print(jsonData);
      // commentController.clear();
      // commentController.text = '';

      notifyListeners();
      return jsonData;
    }
  }
}
