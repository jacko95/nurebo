import 'dart:convert';
import 'dart:math';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/post_favorite_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/event_screen.dart';
import 'package:nurebo/screens/post_full_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class PostLikedScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  final User? user;

  const PostLikedScreen({super.key, this.user});

  @override
  _PostLikedScreenState createState() => _PostLikedScreenState();
}

class _PostLikedScreenState extends State<PostLikedScreen> {
  // List myPrestazione = [];
  // var results;
  UserProvider? userProvider;
  late PostProvider postProvider;
  // late PostFavoriteProvider postFavoriteProvider;
  Future a = Future((){}), h = Future((){}), l = Future((){}), m = Future((){}), all = Future((){});


  // Future getUserPostFavoriteComments() async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/comment");
  //
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/like/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/user/like/comment");
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
  //     postProvider.userPostFavoriteComments.clear();
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
  //       postProvider.userPostFavoriteComments.add(postComment);
  //       for(BusinessPost e in postProvider.postFavoritesList){
  //         if(e.id == postComment.businessPost?.id){
  //           e.comments.add(postComment);
  //         }
  //       }
  //     }
  //
  //     // notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }
  //
  // Future getUserPostFavoriteLikes() async {
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
  //   // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${Utils.user!.id}/like");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/post/user/like");
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
  //     postProvider.userPostFavoriteLikes.clear();
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
  //       postProvider.userPostFavoriteLikes.add(postlike);
  //       for(BusinessPost e in postProvider.postFavoritesList){
  //         if(e.id == postlike.businessPost!.id){
  //           e.likes.add(postlike);
  //         }
  //       }
  //     }
  //
  //     // notifyListeners();
  //     return jsonData;
  //   }
  //   return;
  // }

  Future callFutureBuilderMethods() async {
    // await postProvider.getUserBusinessPostFavorites(Utils.user!);
    postProvider.getUserBusinessPostFavorites(Utils.user!).then((v) async {
      await Future.wait([
        // a = postProvider.getUserBusinessPostFavorites(Utils.user!),
        // a = getAllSingleEvent(),
        // b = getUserAppointments(),
        // c = UserPreferences.getIsLogged()! ? socketProvider.getFriendshipRequest(widget.user!) : Future((){}),
        // d = getUserPosts(),
        // e = getUserFollows(),
        // f = getUserFavorites(),
        // g = /*widget.user!.id == Utils.user!.id ? socketProvider.getUserFriends() :*/ getUserFriends(),
        h = postProvider.getUserPostFavoriteComments(/*widget.user!*/),
        l = postProvider.getUserPostFavoriteLikes(/*widget.user!*/),
        // m = postProvider.getMyLikesToUserPosts(),
      ]);
    });

    // print('dgffg54gf545454d54d554545');
    // print(postProvider.userPostFavoriteLikes);
    // print(postProvider.userPostFavoriteComments);
    // print(postProvider.postFavoritesList);

    for(BusinessPost e in postProvider.postFavoritesList){
      // print(e.created_at);
      // print(e.likes.length);
      // print(e.comments.length);
      // print('');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    // postFavoriteProvider = Provider.of<PostFavoriteProvider>(context, listen: false);


    // Future.wait([
      // a = postProvider.getUserBusinessPostFavorites(userProvider!.user!),
      all = callFutureBuilderMethods()/*,
    ])*/;
    // getUserPrestazioneLiked();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);
    // postFavoriteProvider = Provider.of<PostFavoriteProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
            // size: 22,
            size: 16,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          // 'Salvati',
          'Piaciuti',
          // 'Le mie prestazioni',
          style: TextStyle(
              color: Colors.blue,
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
      ),
      body: FutureBuilder(
        future: all,
        // future: Future.wait([all]),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: StaggeredGridView.countBuilder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 5,
                        left: 10,
                        right: 10,
                        bottom: 10
                    ),
                    crossAxisCount: 2,
                    staggeredTileBuilder: (i) => StaggeredTile.count(1, 2),
                    //shrinkWrap: true,
                    mainAxisSpacing: 0,
                    // physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 0,
                    itemCount: postProvider.postFavoritesList.length,
                    itemBuilder: (context, i) {
                      // //print('favoriteProvider.myFavoritesList');
                      // for(var e in favoriteProvider.favoritesList){
                      // //print(e);
                      // }
                      // //print('favoriteProvider.myFavoritesList.length');
                      // //print(favoriteProvider.favoritesList.length);
                      BusinessPost post = postProvider.postFavoritesList[i];

                      bool isLiked = false;
                      for(PostLike e in postProvider.myPostLikesList) {
                        // print(userPostList[i].id);
                        // print(e.businessPost!.id);
                        if(post.id == e.businessPost?.id){
                          isLiked = true;
                        }
                      }

                      // int postLikesCount = 0;
                      // for(PostLike e in postProvider.userPostFavoriteLikes) {
                      //   // print(userPostList[i].id);
                      //   // print(e.businessPost!.id);
                      //   if(post.id == e.businessPost?.id){
                      //     postLikesCount++;
                      //   }
                      // }
                      //
                      // int postCommentsCount = 0;
                      // for(PostComment e in postProvider.userPostFavoriteComments) {
                      //   // print(userPostList[i].id);
                      //   // print(e.businessPost!.id);
                      //   if(post.id == e.businessPost?.id){
                      //     postCommentsCount++;
                      //   }
                      // }
                      //
                      // print(post.id);
                      // print(postLikesCount);
                      // print(postCommentsCount);

                      return InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: (){
                          Navigator.push(
                              context,
                              PageTransition(
                                duration: const Duration(milliseconds: 500),
                                alignment: Alignment.center,
                                type: PageTransitionType.fade,
                                child: PostFullScreen(
                                  businessPost: post,
                                  isNetworkLoaded: true,
                                  // bookingBusiness: prestazione.business,
                                  // user: widget.user,
                                ),
                              )
                          );
                        },
                        child: Hero(
                          // tag: i,
                          tag: post.image_url != null && post.image_url != '' ? post : post.business!,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 8,
                            child: Stack(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              fit: StackFit.expand,
                              children: [
                                FutureImage(
                                  post.image_url != null && post.image_url != '' ? post.image_url! : post.business!.profile_image!,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    // backgroundBlendMode: BlendMode.darken,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Colors.black,
                                        // Colors.transparent,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   bottom: 20.0,
                                //   left: 15.0,
                                //   // right: 10.0,
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Container(
                                //         width: MediaQuery.of(context).size.width * 0.37,
                                //         child: Marquee(
                                //           child: Row(
                                //             mainAxisAlignment: MainAxisAlignment.start,
                                //             children: [
                                //               Visibility(
                                //                 // visible: item['prestazione_id'] != null,
                                //                 visible: post.prestazione!.id != null,
                                //                 child: InkWell(
                                //                   highlightColor: Colors.transparent,
                                //                   splashColor: Colors.transparent,
                                //                   onTap: (){
                                //                     Navigator.push(
                                //                       context,
                                //                       PageTransition(
                                //                           duration: const Duration(milliseconds: 500),
                                //                           alignment: Alignment.center,
                                //                           type: PageTransitionType.fade,
                                //                           child: PrestazioneScreen(
                                //                             // prestazione: Prestazione(
                                //                             //   id: item['prestazione_id'],
                                //                             //   duration: item['prestazione_duration'],
                                //                             //   image: item['prestazione_image'],
                                //                             //   price: item['prestazione_price']?.toDouble(),
                                //                             //   title: item['prestazione_title'],
                                //                             //   description: item['prestazione_description'] ?? '',
                                //                             //   // business_id: item['business_id'],
                                //                             //   business: Business(
                                //                             //     id: item['business_id'],
                                //                             //     name: item['business_name'],
                                //                             //     longitude: item['business_longitude'],
                                //                             //     latitude: item['business_latitude'],
                                //                             //     type_id: item['business_type_id'],
                                //                             //     // profile_image: e['business_image'],
                                //                             //     profile_image: item['business_profile_image'],
                                //                             //     description: item['business_description'],
                                //                             //     room_id: item['business_room_id'],
                                //                             //     address: item['business_address'],
                                //                             //     phone_number: item['business_phone_number'],
                                //                             //     max_contemporary_appointments: item['max_contemporary_appointments'],
                                //                             //     category: Category(
                                //                             //       id: item['category_id'],
                                //                             //       image: item['category_image'],
                                //                             //       name: item['category_name'],
                                //                             //     )
                                //                             //   ),
                                //                             // ),
                                //                             prestazione: post.prestazione,
                                //                           )
                                //                       ),
                                //                     );
                                //                   },
                                //                   child: Row(
                                //                     mainAxisAlignment: MainAxisAlignment.start,
                                //                     crossAxisAlignment: CrossAxisAlignment.center,
                                //                     children: [
                                //                       // // titleText,
                                //                       // // commentText,
                                //                       // // imageProfile,
                                //                       // Padding(
                                //                       //   padding: EdgeInsets.symmetric(horizontal: 5.0),
                                //                       //   child: ClipRRect(
                                //                       //     borderRadius: BorderRadius.circular(50),
                                //                       //     child: Image(
                                //                       //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                //                       //       image: CachedNetworkImageProvider(
                                //                       //         item['business_profile_image'],
                                //                       //         errorListener: () => SizedBox(),
                                //                       //       ),
                                //                       //       width: 41,
                                //                       //       height: 41,
                                //                       //       fit: BoxFit.cover,
                                //                       //     ),
                                //                       //   ),
                                //                       // ),
                                //                       // // SizedBox(height: 10,),
                                //                       // Padding(
                                //                       //   padding: const EdgeInsets.only(left: 2.0),
                                //                       //   child: Column(
                                //                       //     crossAxisAlignment: CrossAxisAlignment.start,
                                //                       //     children: [
                                //                       //       // usernameText,
                                //                       //       Container(
                                //                       //         width: MediaQuery.of(context).size.width * 0.23,
                                //                       //         child: Text(
                                //                       //           item['business_name'] ?? '',
                                //                       //           maxLines: 1,
                                //                       //           style: TextStyle(
                                //                       //               color: Colors.yellow,
                                //                       //               fontWeight: FontWeight.w700,
                                //                       //               fontSize: 11
                                //                       //           ),
                                //                       //         ),
                                //                       //       ),
                                //                       //       Container(
                                //                       //         width: MediaQuery.of(context).size.width * 0.23,
                                //                       //         child: Text(
                                //                       //           item['prestazione_title'] ?? '',
                                //                       //           // item['business_address'] ?? '',
                                //                       //           maxLines: 1,
                                //                       //           style: TextStyle(
                                //                       //               color: Colors.white,
                                //                       //               fontWeight: FontWeight.w500,
                                //                       //               fontSize: 12
                                //                       //           ),
                                //                       //         ),
                                //                       //       ),
                                //                       //     ],
                                //                       //   ),
                                //                       // ),
                                //
                                //                       // SizedBox(width: 10,),
                                //
                                //                       // RotationTransition(
                                //                       //   turns: AlwaysStoppedAnimation(15 / 360),
                                //                       //   child: Container(
                                //                       //     width: 1,
                                //                       //     height: 30,
                                //                       //     color: Colors.white,
                                //                       //   ),
                                //                       // ),
                                //                       //
                                //                       // SizedBox(width: 15,),
                                //
                                //                       SizedBox(width: 5,),
                                //                       ClipRRect(
                                //                         borderRadius: BorderRadius.circular(8),
                                //                         child: FutureImage(
                                //                           // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                //                           // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                                //                           // item['prestazione_image'] != null && item['prestazione_image'] != ''
                                //                           //   ? item['prestazione_image']
                                //                           //   : item['business_profile_image'],
                                //                           post.prestazione!.image != null && post.prestazione!.image != ''
                                //                               ? post.prestazione!.image!
                                //                               : post.business!.profile_image!,
                                //                           width: 35,
                                //                           height: 35,
                                //                         ),
                                //                       ),
                                //                       SizedBox(width: 5,),
                                //                       Padding(
                                //                         padding: const EdgeInsets.only(left: 2.0),
                                //                         child: Column(
                                //                           crossAxisAlignment: CrossAxisAlignment.start,
                                //                           children: [
                                //                             Container(
                                //                               // width: MediaQuery.of(context).size.width * 0.23,
                                //                               constraints: BoxConstraints(
                                //                                 /*minWidth: 100,*/
                                //                                   // maxWidth: MediaQuery.of(context).size.width * 0.23
                                //                               ),
                                //                               child: Padding(
                                //                                 padding: const EdgeInsets.only(left: .0, bottom: 2),
                                //                                 child: GradientText(
                                //                                   // item['prestazione_title'] ?? item['category_name'],
                                //                                   post.prestazione!.title ?? post.business!.category!.name!,
                                //                                   shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                   overflow: TextOverflow.ellipsis,
                                //                                   maxLines: 1,
                                //                                   // gradient: Gradients.haze,
                                //                                   style: TextStyle(
                                //                                       fontSize: 13,
                                //                                       fontWeight: FontWeight.w600
                                //                                   ),
                                //                                   textAlign: TextAlign.center,
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             Padding(
                                //                               padding: const EdgeInsets.only(left: 2),
                                //                               child: Text(
                                //                                 // item['business_name'] ?? '',
                                //                                 // item['prestazione_price']?.toDouble().toString() != null ? "€ " : '',
                                //                                 // "${int.tryParse(item['prestazione_duration'].toString()).toString()} min",
                                //                                 // "${int.tryParse(item.prestazione!.duration.toString()).toString()} min",
                                //                                 post.business!.name ?? '',
                                //                                 // ? "${item['prestazione_duration'].toInt().toString()} min"
                                //                                 // : '',
                                //                                 // item['prestazione_title'] ?? '',
                                //                                 maxLines: 1,
                                //                                 overflow: TextOverflow.ellipsis,
                                //                                 style: TextStyle(
                                //                                   // color: Colors.white,
                                //                                     color: Colors.yellow[700],
                                //                                     fontWeight: FontWeight.w500,
                                //                                     fontSize: 12
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               ),
                                //               SizedBox(width: 15,),
                                //               Visibility(
                                //                 // visible: item['user_id'] != null,
                                //                 visible: post.user!.id != null,
                                //                 child: RotationTransition(
                                //                   turns: AlwaysStoppedAnimation(15 / 360),
                                //                   child: Container(
                                //                     width: 1,
                                //                     height: 30,
                                //                     color: Colors.white,
                                //                   ),
                                //                 ),
                                //               ),
                                //               SizedBox(width: 15,),
                                //               Visibility(
                                //                 // visible: item['user_id'] != null,
                                //                 visible: post.user!.id != null,
                                //                 child: InkWell(
                                //                   highlightColor: Colors.transparent,
                                //                   splashColor: Colors.transparent,
                                //                   onTap: (){
                                //                     Navigator.push(
                                //                       context,
                                //                       PageTransition(
                                //                           duration: const Duration(milliseconds: 500),
                                //                           alignment: Alignment.center,
                                //                           type: PageTransitionType.fade,
                                //                           child: UserProfileScreen(
                                //                             // user: User(
                                //                             //   id: item['user_id'],
                                //                             //   email: item['user_email'],
                                //                             //   username: item['user_username'],
                                //                             //   name: item['user_name'],
                                //                             //   phone_number: item['user_phone_number'],
                                //                             //   profile_image: item['user_profile_image'],
                                //                             //   description: item['user_description'],
                                //                             // ),
                                //                             // userId: item.user!.id!,
                                //                             user: post.user!,
                                //                             isTab: false,
                                //                           )
                                //                       ),
                                //                     );
                                //                   },
                                //                   child: Row(
                                //                     mainAxisAlignment: MainAxisAlignment.start,
                                //                     children: [
                                //                       Padding(
                                //                         padding: EdgeInsets.symmetric(horizontal: 5.0),
                                //                         child: ClipRRect(
                                //                           borderRadius: BorderRadius.circular(50),
                                //                           child: FutureImage(
                                //                             // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                //                             // item['user_profile_image'] ?? '',
                                //                             post.user!.profile_image ?? '',
                                //                             width: 37,
                                //                             height: 37,
                                //                           ),
                                //                         ),
                                //                       ),
                                //                       // SizedBox(height: 10,),
                                //                       Padding(
                                //                         padding: const EdgeInsets.only(left: 2.0),
                                //                         child: Column(
                                //                           crossAxisAlignment: CrossAxisAlignment.start,
                                //                           children: [
                                //                             // usernameText,
                                //                             Container(
                                //                               // width: MediaQuery.of(context).size.width * 0.23,
                                //                               constraints: BoxConstraints(
                                //                                 /*minWidth: 100,*/
                                //                                   // maxWidth: MediaQuery.of(context).size.width * 0.2
                                //                               ),
                                //                               child: Text(
                                //                                 // item['user_username'] != null ? "@${item['user_username']}" : '',
                                //                                 post.user!.username != null ? "@${post.user!.username}" : '',
                                //                                 maxLines: 1,
                                //                                 overflow: TextOverflow.ellipsis,
                                //                                 style: TextStyle(
                                //                                     color: Colors.yellow,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 11
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             SizedBox(height: 2,),
                                //                             Container(
                                //                               // width: MediaQuery.of(context).size.width * 0.23,
                                //                               constraints: BoxConstraints(
                                //                                 /*minWidth: 100,*/
                                //                                   // maxWidth: MediaQuery.of(context).size.width * 0.22
                                //                               ),
                                //                               child: Text(
                                //                                 // item['user_name'] ?? '',
                                //                                 post.user!.name ?? '',
                                //                                 maxLines: 1,
                                //                                 overflow: TextOverflow.ellipsis,
                                //                                 style: TextStyle(
                                //                                     color: Colors.white,
                                //                                     fontWeight: FontWeight.w500,
                                //                                     fontSize: 12
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       ),
                                //                       SizedBox(width: 10,),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //       Container(
                                //         width: MediaQuery.of(context).size.width * 0.37,
                                //         margin: EdgeInsets.only(top: 10, left: 5),
                                //         // child: Text(
                                //         //   "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                //         //   style: TextStyle(
                                //         //       color: Colors.white,
                                //         //       fontWeight: FontWeight.w500,
                                //         //       fontSize: 13.5
                                //         //   ),
                                //         // ),
                                //         child: Text(
                                //           // "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                //           // "Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                //           // '',
                                //           // item['post_description'] ?? '',
                                //           post.description ?? '',
                                //           overflow: TextOverflow.ellipsis,
                                //           maxLines: 3,
                                //           textAlign: TextAlign.start,
                                //           // collapseText: 'nascondi',
                                //           // expandText: 'mostra',
                                //           style: TextStyle(
                                //               color: Colors.white,
                                //               fontWeight: FontWeight.w500,
                                //               fontSize: 11.5
                                //           ),
                                //         ),
                                //       ),
                                //       SizedBox(height: 10,),
                                //       Padding(
                                //         padding: const EdgeInsets.only(left: 5.0),
                                //         child: Container(
                                //           width: MediaQuery.of(context).size.width * 0.77,
                                //           child: Row(
                                //             // mainAxisAlignment: MainAxisAlignment.end,
                                //             children: [
                                //               // Spacer(),
                                //               Text(
                                //                 // '15:32 15 Settembre 2022',
                                //                 // DateFormat.yMMMMd('it_IT').format(DateTime.parse(item['post_created_at'])).toString()
                                //                 //     + ' alle ' + item['post_created_at'].substring(11, 16),
                                //                 DateFormat.yMMMMd('it_IT').format(post.created_at!).toString()
                                //                     + ' alle ' + post.created_at!.toString().substring(11, 16),
                                //                 style: TextStyle(
                                //                     color: Colors.grey[200],
                                //                     fontWeight: FontWeight.w500,
                                //                     fontSize: 10
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Positioned(
                                  bottom: 15,
                                  left: 0,
                                  right: 0,
                                  // width: MediaQuery.of(context).size.width * 0.34,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Marquee(
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                  child: FutureImage(
                                                    post.user!.profile_image ?? '',
                                                    // post.booking!.user.profile_image ?? '',
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                GradientText(
                                                  // post.business!.name ?? '',
                                                  // '@' + post.user!.username! ?? '',
                                                  post.user!.name ?? '',
                                                  // post.booking!.user.name ?? '',
                                                  // 'A partire da € 60,00',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.bottomLeft,
                                                      end: Alignment.topRight,
                                                      colors: [
                                                        // Color(0xff8921aa),
                                                        // Color(0xffDA44bb),
                                                        // Colors.pinkAccent
                                                        Colors.white,
                                                        Colors.white,
                                                        // Color(0xffDA44bb)
                                                        // Color(0xfffd746c),
                                                        // Color(0xffff9068),
                                                      ]
                                                  ),
                                                  // gradient: LinearGradient(
                                                  //     begin: Alignment.bottomLeft,
                                                  //     end: Alignment.topRight,
                                                  //     colors: [
                                                  //       Colors.blue[500],
                                                  //       Color(0xffDA44bb),
                                                  //
                                                  //       Color(0xff8921aa),
                                                  //     ]
                                                  // ),
                                                  style: TextStyle(
                                                      color: Colors.blue[500],
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 13
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Marquee(
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                  child: FutureImage(
                                                    // post.prestazione!.image ?? '',
                                                    post.prestazione!.image != null && post.prestazione!.image != ''
                                                        ? post.prestazione!.image!
                                                        : post.business!.profile_image!,
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                                SizedBox(width: 8,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    GradientText(
                                                      // post.business!.name ?? '',
                                                      // post.booking!.prestazione!.title ?? '',
                                                      post.prestazione!.title ?? '',
                                                      // 'A partire da € 60,00',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                      // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                      gradient: LinearGradient(
                                                          begin: Alignment.bottomLeft,
                                                          end: Alignment.topRight,
                                                          colors: [
                                                            // Color(0xff8921aa),
                                                            // Color(0xffDA44bb),
                                                            // Color(0xffDA44bb)
                                                            // Color(0xfffd746c),
                                                            // Color(0xffff9068),
                                                            // Colors.yellow,
                                                            Colors.yellow[600]!,
                                                            Color(0xffFFA818),
                                                            // Color(0xffF68A3D),
                                                          ]
                                                      ),
                                                      // gradient: LinearGradient(
                                                      //     begin: Alignment.bottomLeft,
                                                      //     end: Alignment.topRight,
                                                      //     colors: [
                                                      //       Colors.blue[500],
                                                      //       Color(0xffDA44bb),
                                                      //
                                                      //       Color(0xff8921aa),
                                                      //     ]
                                                      // ),
                                                      style: TextStyle(
                                                          color: Colors.blue[500],
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 13
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    SizedBox(height: 2,),
                                                    GradientText(
                                                      // post.business!.name ?? '',
                                                      // post.booking!.prestazione!.title ?? '',
                                                      post.business!.name ?? '',
                                                      // 'A partire da € 60,00',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                      // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                      gradient: Gradients. hotLinear,
                                                      // gradient: LinearGradient(
                                                      //     begin: Alignment.bottomLeft,
                                                      //     end: Alignment.topRight,
                                                      //     colors: [
                                                      //       // Color(0xff8921aa),
                                                      //       // Color(0xffDA44bb),
                                                      //       // Color(0xffDA44bb)
                                                      //       // Color(0xfffd746c),
                                                      //       // Color(0xffff9068),
                                                      //       Colors.yellow,
                                                      //       Colors.yellow,
                                                      //     ]
                                                      // ),
                                                      // gradient: LinearGradient(
                                                      //     begin: Alignment.bottomLeft,
                                                      //     end: Alignment.topRight,
                                                      //     colors: [
                                                      //       Colors.blue[500],
                                                      //       Color(0xffDA44bb),
                                                      //
                                                      //       Color(0xff8921aa),
                                                      //     ]
                                                      // ),
                                                      style: TextStyle(
                                                          color: Colors.blue[500],
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 13
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                          Visibility(
                                            visible: post.description != null,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * .4,
                                              child: GradientText(
                                                post.description ?? '',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                gradient: Gradients.haze,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                          Container(
                                            // width: MediaQuery.of(context).size.width * .3,
                                            child: Marquee(
                                              child: Text(
                                                // post.created_at!,
                                                DateFormat.yMMMd('it_IT').format(post.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                    + ' alle ' + post.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.grey[200],
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                          // item.is_single_event && item.single_event.begin_at != null
                                          //     ? GradientText(
                                          //   DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                          //   maxLines: 2,
                                          //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //   // gradient: Gradients.backToFuture,
                                          //   gradient: Gradients.blush,
                                          //   // gradient: LinearGradient(
                                          //   //     begin: Alignment.bottomLeft,
                                          //   //     end: Alignment.topRight,
                                          //   //     colors: [
                                          //   //       Color(0xff8921aa),
                                          //   //       Color(0xffDA44bb),
                                          //   //       // Color(0xffDA44bb)
                                          //   //     ]
                                          //   // ),
                                          //   // gradient: LinearGradient(
                                          //   //     begin: Alignment.bottomLeft,
                                          //   //     end: Alignment.topRight,
                                          //   //     colors: [
                                          //   //       Color(0xff8921aa),
                                          //   //       Color(0xffDA44bb),
                                          //   //       // Color(0xffDA44bb)
                                          //   //     ]
                                          //   // ),
                                          //
                                          //   style: TextStyle(
                                          //       color: Colors.blue,
                                          //       fontWeight: FontWeight.w800,
                                          //       fontSize: 16
                                          //   ),
                                          //   textAlign: TextAlign.left,
                                          // )
                                          //     : SizedBox(height: 0, width: 0,),
                                          // SizedBox(height: 1,),
                                          // GradientText(
                                          //   // item.is_single_event && item.single_event.title != null
                                          //   //     ? item.single_event.title
                                          //   //     : item.prestazione.title != null
                                          //   //     ? item.prestazione.title : '',
                                          //   item.is_single_event
                                          //       ? 'A partire da € 15,00'/* + NumberFormat.currency(
                                          //                         // customPattern: '#,##',
                                          //                           decimalDigits: 2,
                                          //                           symbol: '',
                                          //                           locale: 'IT_it'
                                          //                       ).format(item.single_event.)*/
                                          //       : 'Al prezzo di € ' + NumberFormat.currency(
                                          //     // customPattern: '#,##',
                                          //       decimalDigits: 2,
                                          //       symbol: '',
                                          //       locale: 'IT_it'
                                          //   ).format(item.prestazione.price),
                                          //   maxLines: 2,
                                          //
                                          //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //   // gradient: Gradients.backToFuture,
                                          //   gradient: !item.is_single_event
                                          //       ? Gradients.blush
                                          //       : LinearGradient(
                                          //       begin: Alignment.bottomLeft,
                                          //       end: Alignment.topRight,
                                          //       colors: [
                                          //         Color(0xff8921aa),
                                          //         Color(0xffDA44bb),
                                          //         // Color(0xffDA44bb)
                                          //       ]
                                          //   ),
                                          //   style: TextStyle(
                                          //       color: Colors.blue,
                                          //       fontWeight: FontWeight.w800,
                                          //       fontSize: 15
                                          //   ),
                                          //   textAlign: TextAlign.left,
                                          // ),
                                          // Text(
                                          //   'A partire da € 60,00',
                                          //   style: new TextStyle(
                                          //       fontWeight: FontWeight.w800,
                                          //       fontSize: 15,
                                          //
                                          //       foreground: Paint()..shader = LinearGradient(
                                          //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                          //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                          // )
                                          // LinearGradient(
                                          //   begin: Alignment.topLeft,
                                          //   end: Alignment.bottomRight,
                                          //   colors: gradientColors,
                                          // ).createShader(
                                          //     Rect.fromCircle(
                                          //       center: Offset(fontSize, -200),
                                          //       radius: fontSize / 3,
                                          //     )
                                          // );
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  // top: 50,
                                  child: InkWell(
                                    // onTap: (){
                                    //   Navigator.push(
                                    //       context,
                                    //       PageTransition(
                                    //         duration: const Duration(
                                    //             milliseconds: 500
                                    //         ),
                                    //         alignment: Alignment.center,
                                    //         type: PageTransitionType.fade,
                                    //         child: PostFullScreen(
                                    //           businessPost: homeBusinessPostList[i],
                                    //           isNetworkLoaded: false,
                                    //         ),
                                    //       )
                                    //   );
                                    // },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.height * .05,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaY: 30,
                                              sigmaX: 30
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 15),
                                            child: Container(
                                              width: 45,
                                              height: 120,
                                              child: Column(
                                                children: [
                                                  // InkWell(
                                                  //   onTap: () {
                                                  //     //print('isLikedPost');
                                                  //     //print(isLikedPost);
                                                  //     //print('review');
                                                  //     //print('andare in una listview in cui ci sono tutte le recensioni di quella prestazione');
                                                  //   },
                                                  //   child: Padding(
                                                  //     padding: const EdgeInsets.only(bottom: 11.0, top: 6, left: 6, right: 6),
                                                  //     child: Column(
                                                  //       children: [
                                                  //         // Icon(
                                                  //         //   Icons.star,
                                                  //         //   // color: Colors.grey[50],
                                                  //         //   color: Colors.yellow[500],
                                                  //         //   size: 25,
                                                  //         // ),
                                                  //         // SizedBox(height: 5,),
                                                  //         // Text(
                                                  //         //     '€\n25,50',
                                                  //         //     textAlign: TextAlign.center,
                                                  //         //     // overflow: TextOverflow.ellipsis,
                                                  //         //     style: GoogleFonts.roboto(
                                                  //         //       fontWeight: FontWeight.w800,
                                                  //         //       // color: Colors.grey[50],
                                                  //         //       color: Colors.white,
                                                  //         //       fontSize: 13,
                                                  //         //     )
                                                  //         // )
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  InkWell(
                                                    // onTap: () async {
                                                    // if (postProvider.isLikedPost){
                                                    //   setState(() {
                                                    //     /*await*/ postProvider.unlikeBusinessPost(
                                                    //         homeBusinessPostList[i],
                                                    //         userProvider!.user!
                                                    //     );
                                                    //   });
                                                    // }
                                                    // else{
                                                    //   setState(() {
                                                    //     /*await*/ postProvider.likeBusinessPost(
                                                    //       // postProvider.postList[index].id,
                                                    //         homeBusinessPostList[i],
                                                    //         userProvider!.user!
                                                    //     );
                                                    //   });
                                                    // }
                                                    // },
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            // Icons.reply,
                                                            isLiked ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                                            color: isLiked ? Colors.red : Colors.grey[50],
                                                            // color: Colors.red[500],
                                                            // color: Colors.pink[300],
                                                            size: 20,
                                                          ),
                                                          SizedBox(height: 5,),
                                                          Text(
                                                            // '27',
                                                            //   userPostList[i].likes.length.toString(),
                                                            //   postLikesCount.toString(),
                                                              post.likes.length.toString(),
                                                              overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.lato(
                                                                fontWeight: FontWeight.w700,
                                                                color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                                                // color: Colors.red[500],
                                                                // color: Colors.pink[300],
                                                                fontSize: 12,
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    // onTap: () {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     PageTransition(
                                                    //       duration: const Duration(
                                                    //           milliseconds: 500
                                                    //       ),
                                                    //       alignment: Alignment.center,
                                                    //       type: PageTransitionType.fade,
                                                    //       child: PostCommentsScreen(
                                                    //           isSingleEventPost: false,
                                                    //           myUser: userProvider!.user!,
                                                    //           businessPost: homeBusinessPostList[i]
                                                    //       ),
                                                    //     )
                                                    // );
                                                    // },
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            // Icons.mode_comment_outlined,
                                                            Icons.sms_outlined,
                                                            color: Colors.grey[50],
                                                            // color: Colors.blue[400],
                                                            size: 20,
                                                          ),
                                                          SizedBox(height: 5,),
                                                          Text(
                                                            // '320',
                                                            // bookingPostCommentNumber.toString(),
                                                            //   postProvider.comments!.length.toString(),
                                                            //   userPostList[i].comments.length.toString(),
                                                            //   postCommentsCount.toString(),
                                                            post.comments.length.toString(),
                                                              overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.lato(
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // child: Text(
                                            //   // categories[i].name,
                                            //   'category.name',
                                            //   overflow: TextOverflow.ellipsis,
                                            //   style: GoogleFonts.lato(
                                            //     fontWeight: FontWeight.w700,
                                            //     color: Colors.white,
                                            //     fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   top: 15,
                                //   left: 0,
                                //   right: 0,
                                //   child: Align(
                                //     alignment: Alignment.topCenter,
                                //     child: Marquee(
                                //         child: Row(
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             FutureImage(
                                //               // post.prestazione!.image ?? '',
                                //               post.business!.profile_image! ?? '',
                                //               width: 15,
                                //               height: 15,
                                //             ),
                                //             SizedBox(width: 5,),
                                //             GradientText(
                                //               // post.business!.name ?? '',
                                //               // post.booking!.prestazione!.title ?? '',
                                //               post.business!.name ?? '',
                                //               // 'A partire da € 60,00',
                                //               maxLines: 1,
                                //               overflow: TextOverflow.ellipsis,
                                //               // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //               // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //               gradient: LinearGradient(
                                //                   begin: Alignment.bottomLeft,
                                //                   end: Alignment.topRight,
                                //                   colors: [
                                //                     // Color(0xff8921aa),
                                //                     // Color(0xffDA44bb),
                                //                     // Color(0xffDA44bb)
                                //                     // Color(0xfffd746c),
                                //                     // Color(0xffff9068),
                                //                     // Colors.yellow,
                                //                     // Colors.yellow,
                                //                     Colors.white,
                                //                     Colors.white,
                                //                   ]
                                //               ),
                                //               // gradient: LinearGradient(
                                //               //     begin: Alignment.bottomLeft,
                                //               //     end: Alignment.topRight,
                                //               //     colors: [
                                //               //       Colors.blue[500],
                                //               //       Color(0xffDA44bb),
                                //               //
                                //               //       Color(0xff8921aa),
                                //               //     ]
                                //               // ),
                                //               style: TextStyle(
                                //                   color: Colors.blue[500],
                                //                   fontWeight: FontWeight.w700,
                                //                   fontSize: 13
                                //               ),
                                //               textAlign: TextAlign.left,
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //   ),
                                // ),
                                // Positioned(
                                //   bottom: 15,
                                //   left: 0,
                                //   right: 0,
                                //   // width: MediaQuery.of(context).size.width * 0.34,
                                //   child: Align(
                                //     alignment: Alignment.bottomCenter,
                                //     child: Column(
                                //       crossAxisAlignment: CrossAxisAlignment.center,
                                //       children: [
                                //         Marquee(
                                //           child: Row(
                                //             children: [
                                //               FutureImage(
                                //                 post.user!.profile_image ?? '',
                                //                 // post.booking!.user.profile_image ?? '',
                                //                 width: 15,
                                //                 height: 15,
                                //               ),
                                //               SizedBox(width: 5,),
                                //               GradientText(
                                //                 // post.business!.name ?? '',
                                //                 // '@' + post.user!.username! ?? '',
                                //                 post.user!.name ?? '',
                                //                 // post.booking!.user.name ?? '',
                                //                 // 'A partire da € 60,00',
                                //                 maxLines: 1,
                                //                 overflow: TextOverflow.ellipsis,
                                //                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                 gradient: LinearGradient(
                                //                     begin: Alignment.bottomLeft,
                                //                     end: Alignment.topRight,
                                //                     colors: [
                                //                       // Color(0xff8921aa),
                                //                       // Color(0xffDA44bb),
                                //                       // Colors.pinkAccent
                                //                       Colors.white,
                                //                       Colors.white,
                                //                       // Color(0xffDA44bb)
                                //                       // Color(0xfffd746c),
                                //                       // Color(0xffff9068),
                                //                     ]
                                //                 ),
                                //                 // gradient: LinearGradient(
                                //                 //     begin: Alignment.bottomLeft,
                                //                 //     end: Alignment.topRight,
                                //                 //     colors: [
                                //                 //       Colors.blue[500],
                                //                 //       Color(0xffDA44bb),
                                //                 //
                                //                 //       Color(0xff8921aa),
                                //                 //     ]
                                //                 // ),
                                //                 style: TextStyle(
                                //                     color: Colors.blue[500],
                                //                     fontWeight: FontWeight.w700,
                                //                     fontSize: 13
                                //                 ),
                                //                 textAlign: TextAlign.left,
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //         SizedBox(height: 10,),
                                //         Marquee(
                                //           child: Row(
                                //             children: [
                                //               FutureImage(
                                //                 // post.prestazione!.image ?? '',
                                //                 post.prestazione!.image != null && post.prestazione!.image != ''
                                //                     ? post.prestazione!.image!
                                //                     : post.business!.profile_image!,
                                //                 width: 15,
                                //                 height: 15,
                                //               ),
                                //               SizedBox(width: 5,),
                                //               GradientText(
                                //                 // post.business!.name ?? '',
                                //                 // post.booking!.prestazione!.title ?? '',
                                //                 post.prestazione!.title ?? '',
                                //                 // 'A partire da € 60,00',
                                //                 maxLines: 1,
                                //                 overflow: TextOverflow.ellipsis,
                                //                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                 gradient: LinearGradient(
                                //                     begin: Alignment.bottomLeft,
                                //                     end: Alignment.topRight,
                                //                     colors: [
                                //                       // Color(0xff8921aa),
                                //                       // Color(0xffDA44bb),
                                //                       // Color(0xffDA44bb)
                                //                       // Color(0xfffd746c),
                                //                       // Color(0xffff9068),
                                //                       Colors.yellow,
                                //                       Colors.yellow,
                                //                     ]
                                //                 ),
                                //                 // gradient: LinearGradient(
                                //                 //     begin: Alignment.bottomLeft,
                                //                 //     end: Alignment.topRight,
                                //                 //     colors: [
                                //                 //       Colors.blue[500],
                                //                 //       Color(0xffDA44bb),
                                //                 //
                                //                 //       Color(0xff8921aa),
                                //                 //     ]
                                //                 // ),
                                //                 style: TextStyle(
                                //                     color: Colors.blue[500],
                                //                     fontWeight: FontWeight.w700,
                                //                     fontSize: 13
                                //                 ),
                                //                 textAlign: TextAlign.left,
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //         SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                //         Visibility(
                                //           visible: post.description != null,
                                //           child: Container(
                                //             width: MediaQuery.of(context).size.width * .35,
                                //             child: GradientText(
                                //               post.description ?? '',
                                //               maxLines: 3,
                                //               overflow: TextOverflow.ellipsis,
                                //               shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //               gradient: Gradients.haze,
                                //               style: TextStyle(
                                //                   color: Colors.white,
                                //                   fontWeight: FontWeight.w700,
                                //                   fontSize: 11
                                //               ),
                                //               textAlign: TextAlign.left,
                                //             ),
                                //           ),
                                //         ),
                                //         SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                //         Container(
                                //           // width: MediaQuery.of(context).size.width * .3,
                                //           child: Marquee(
                                //             child: Text(
                                //               // post.created_at!,
                                //               DateFormat.yMMMd('it_IT').format(post.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                //                   + ' alle ' + post.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                //               maxLines: 1,
                                //               overflow: TextOverflow.ellipsis,
                                //               style: TextStyle(
                                //                   color: Colors.grey[200],
                                //                   fontWeight: FontWeight.w600,
                                //                   fontSize: 11
                                //               ),
                                //               textAlign: TextAlign.left,
                                //             ),
                                //           ),
                                //         ),
                                //         // item.is_single_event && item.single_event.begin_at != null
                                //         //     ? GradientText(
                                //         //   DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                //         //   maxLines: 2,
                                //         //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //         //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //         //   // gradient: Gradients.backToFuture,
                                //         //   gradient: Gradients.blush,
                                //         //   // gradient: LinearGradient(
                                //         //   //     begin: Alignment.bottomLeft,
                                //         //   //     end: Alignment.topRight,
                                //         //   //     colors: [
                                //         //   //       Color(0xff8921aa),
                                //         //   //       Color(0xffDA44bb),
                                //         //   //       // Color(0xffDA44bb)
                                //         //   //     ]
                                //         //   // ),
                                //         //   // gradient: LinearGradient(
                                //         //   //     begin: Alignment.bottomLeft,
                                //         //   //     end: Alignment.topRight,
                                //         //   //     colors: [
                                //         //   //       Color(0xff8921aa),
                                //         //   //       Color(0xffDA44bb),
                                //         //   //       // Color(0xffDA44bb)
                                //         //   //     ]
                                //         //   // ),
                                //         //
                                //         //   style: TextStyle(
                                //         //       color: Colors.blue,
                                //         //       fontWeight: FontWeight.w800,
                                //         //       fontSize: 16
                                //         //   ),
                                //         //   textAlign: TextAlign.left,
                                //         // )
                                //         //     : SizedBox(height: 0, width: 0,),
                                //         // SizedBox(height: 1,),
                                //         // GradientText(
                                //         //   // item.is_single_event && item.single_event.title != null
                                //         //   //     ? item.single_event.title
                                //         //   //     : item.prestazione.title != null
                                //         //   //     ? item.prestazione.title : '',
                                //         //   item.is_single_event
                                //         //       ? 'A partire da € 15,00'/* + NumberFormat.currency(
                                //         //                         // customPattern: '#,##',
                                //         //                           decimalDigits: 2,
                                //         //                           symbol: '',
                                //         //                           locale: 'IT_it'
                                //         //                       ).format(item.single_event.)*/
                                //         //       : 'Al prezzo di € ' + NumberFormat.currency(
                                //         //     // customPattern: '#,##',
                                //         //       decimalDigits: 2,
                                //         //       symbol: '',
                                //         //       locale: 'IT_it'
                                //         //   ).format(item.prestazione.price),
                                //         //   maxLines: 2,
                                //         //
                                //         //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //         //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //         //   // gradient: Gradients.backToFuture,
                                //         //   gradient: !item.is_single_event
                                //         //       ? Gradients.blush
                                //         //       : LinearGradient(
                                //         //       begin: Alignment.bottomLeft,
                                //         //       end: Alignment.topRight,
                                //         //       colors: [
                                //         //         Color(0xff8921aa),
                                //         //         Color(0xffDA44bb),
                                //         //         // Color(0xffDA44bb)
                                //         //       ]
                                //         //   ),
                                //         //   style: TextStyle(
                                //         //       color: Colors.blue,
                                //         //       fontWeight: FontWeight.w800,
                                //         //       fontSize: 15
                                //         //   ),
                                //         //   textAlign: TextAlign.left,
                                //         // ),
                                //         // Text(
                                //         //   'A partire da € 60,00',
                                //         //   style: new TextStyle(
                                //         //       fontWeight: FontWeight.w800,
                                //         //       fontSize: 15,
                                //         //
                                //         //       foreground: Paint()..shader = LinearGradient(
                                //         //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                //         //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                //         // )
                                //         // LinearGradient(
                                //         //   begin: Alignment.topLeft,
                                //         //   end: Alignment.bottomRight,
                                //         //   colors: gradientColors,
                                //         // ).createShader(
                                //         //     Rect.fromCircle(
                                //         //       center: Offset(fontSize, -200),
                                //         //       radius: fontSize / 3,
                                //         //     )
                                //         // );
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  // ImageCard(
                  //   imageData: imageList[index],
                  // ),
                )
            );
          }
          else {
            return SizedBox();
          }
        }
      ),

    );
  }
}
