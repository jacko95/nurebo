import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/screens/prestazione_detail_screen.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/booking_post.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/post_comments_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


import '../widgets/future_image.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class PostFullScreen extends StatefulWidget {
  // final Uint8List memoryImage;
  // final BookingPost bookingPost;
  final BusinessPost businessPost;
  final bool isNetworkLoaded;

  const PostFullScreen({super.key, /*required this.memoryImage,*/ required this.businessPost, required this.isNetworkLoaded});

  @override
  State<PostFullScreen> createState() => _PostFullScreenState();
}

class _PostFullScreenState extends State<PostFullScreen> {
  late SocketProvider socketProvider;
  late PostProvider postProvider;
  late UserProvider userProvider;
  ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  bool isFilterVisible = true;
  bool isContainerVisible = true;
  Future a = Future(() {},), b = Future(() {},);
  List<PostComment> postComments = [];
  List<PostLike> postLikes = [];
  bool isLikedPost = false;


  // Future getBusinessPostComments(String postId) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/post_id");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${Utils.business_id}/post/${postId}/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post/${postId}/comment");
  //   // var userProvider = Provider.of<UserProvider>(context);
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
  //   //print("postcomment getall response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     for(var e in jsonData){
  //       PostComment postcomment = PostComment(
  //         id: e['id'],
  //         text: e['text'],
  //         is_admin: e['is_admin'],
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
  //
  //       postComments.add(
  //           postcomment
  //       );
  //     }
  //
  //     print('json656565g5g5');
  //     print(postId);
  //     print(postComments.length);
  //
  //     return jsonData;
  //   }
  // }
  //
  // Future getBusinessPostLikes(String? postId) async {
  //   isLikedPost = false;
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/post_id");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post/$postId/like");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   Map/*<String, String>*/ body = {
  //     // 'user_id': userProvider.user.id,
  //     'post_id': postId,
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
  //       }
  //   );
  //
  //   // //print("likessss getall response.statusCode:");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // setState(() {
  //     // /*postLikes*/businessPostLikes.addAll(jsonData);
  //     // bookingPostLikes = jsonData;
  //     // });
  //     postLikes.clear();
  //     for(var e in jsonData){
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
  //
  //       postLikes.add(
  //           postlike
  //       );
  //
  //       // for(BusinessPost post in postList) {
  //       //   if(post.id == postlike.businessPost!.id){
  //       //     post.likes?.add(postlike);
  //       //   }
  //       // }
  //     }
  //
  //     // for (PostLike like in List.from(/*postLikes*/businessPostLikes)) {
  //     for (PostLike like in postLikes) {
  //       // //print('like gggyg');
  //       // //print(like);
  //       //print(like['user_id'] == userProvider.user!.id);
  //       // if (like['id'] == singleEventPost.id) {
  //       // if (like['user_id'] == userProvider.user!.id) {
  //       if(Utils.user != null) {
  //         if (like.user!.id == Utils.user!.id) {
  //           // setState(() {
  //           isLikedPost = true;
  //           // });
  //         }
  //       }
  //     }
  //
  //     // print('businessPostLikes.length');
  //     // print(businessPostLikes.length);
  //     // print('isLikedPost');
  //     // print(isLikedPost);
  //
  //     // setState(() {
  //     // isLikedPost = true;
  //     // });
  //
  //     //print('jsonData.length');
  //     //print(jsonData.length);
  //     // print('businessPostLikes.lef5f5ff6ngthhui');
  //     // print(businessPostLikes.length);
  //
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    // socketProvider.setBottomBarVisibility(true);
    initializeDateFormatting();

    if(widget.isNetworkLoaded == true) {
      /*await*/ Future.wait([
        a = postProvider.getBusinessPostLikes(widget.businessPost.id, widget.businessPost.business!.id!),
        b = postProvider.getBusinessPostComments(widget.businessPost.id!, widget.businessPost.business!.id!),
      ]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // socketProvider.setBottomBarVisibility(false);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureImage(
            widget.businessPost.image_url!,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Visibility(
            visible: isFilterVisible,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // MyColors.black,
                    // Colors.transparent,
                    Colors.transparent,
                    Colors.black,
                    // MyColors.black,
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                isFilterVisible = !isFilterVisible;
              });
              if(!isContainerVisible){
                setState(() {
                  isContainerVisible = true;
                });
              }
            },
            // onLongPress: (){
            //   setState(() {
            //     isStoryFilterVisible = !isStoryFilterVisible;
            //   });
            // },
            // onForcePressStart: (forcePressDetails){
            //   // forcePressDetails.pressure
            //   setState(() {
            //     isStoryFilterVisible = !isStoryFilterVisible;
            //   });
            // },
            // onForcePressEnd: (forcePressDetails){
            //   setState(() {
            //     isStoryFilterVisible = !isStoryFilterVisible;
            //   });
            // },
            // onDoubleTap: (){
            //   //TODO: VAI ALLO SCREEN DEL POST
            // },
          ),
          Visibility(
            visible: isFilterVisible,
            child: Positioned(
              top: MediaQuery.of(context).size.height * .06,
              left: MediaQuery.of(context).size.width * .05,
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                  child: Center(
                    child: Icon(
                      // Icons.star_rounded,
                      // Icons.star_half_rounded,
                      // Icons.star_border_rounded,
                      Icons.arrow_back_outlined,
                      // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                      // color: _theme,
                      color: Colors.grey[700],
                      // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                      size: 23.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isFilterVisible && isContainerVisible,
            // child: _buildSidebarBookingPost(
            //     context,
            //     // storyList[index],
            //     // storyProvider.stories[index],
            //     postProvider.postList[index],
            //     pageVisibility,
            //     index
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // InkWell(
                //   onTap: (){
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //         duration: const Duration(milliseconds: 1),
                //         // alignment: Alignment.topRight,
                //         // type: PageTransitionType.scale,
                //
                //         // post[index]['title']
                //         child: UserProfileScreen(
                //           // myUser: widget.user,
                //             user: followedUser/*imagePosts[i].user*/
                //         ),
                //         // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
                //         type: null,
                //       ),
                //       // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
                //     );
                //   },
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       // titleText,
                //       // commentText,
                //       imageProfile,
                //
                //       SizedBox(height: 10,),
                //       usernameText,
                //
                //       // Row(
                //       //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       //   children: <Widget>[
                //       //     Container(
                //       //       child: Row(
                //       //         children: <Widget>[
                //       //           Icon(
                //       //             Icons.reply,
                //       //             color: Colors.grey[400],
                //       //           ),
                //       //           Padding(
                //       //             padding:
                //       //             EdgeInsets.symmetric(horizontal: 5.0),
                //       //           ),
                //       //           Text(
                //       //             Random().nextInt(50).toString(),
                //       //             style: TextStyle(
                //       //               color: Colors.grey[400],
                //       //             ),
                //       //           )
                //       //         ],
                //       //       ),
                //       //     ),
                //       //     Container(
                //       //       child: Row(
                //       //         children: <Widget>[
                //       //           Icon(
                //       //             Icons.repeat,
                //       //             color: Colors.grey[400],
                //       //           ),
                //       //           Padding(
                //       //             padding:
                //       //             EdgeInsets.symmetric(horizontal: 5.0),
                //       //           ),
                //       //           Text(
                //       //             Random().nextInt(50).toString(),
                //       //             style: TextStyle(
                //       //               color: Colors.grey[400],
                //       //             ),
                //       //           )
                //       //         ],
                //       //       ),
                //       //     ),
                //       //     Container(
                //       //       child: Row(
                //       //         children: <Widget>[
                //       //           Icon(
                //       //             Icons.favorite_border,
                //       //             color: Colors.grey[400],
                //       //           ),
                //       //           Padding(
                //       //             padding:
                //       //             EdgeInsets.symmetric(horizontal: 5.0),
                //       //           ),
                //       //           Text(
                //       //             Random().nextInt(50).toString(),
                //       //             style: TextStyle(
                //       //               color: Colors.grey[400],
                //       //             ),
                //       //           )
                //       //         ],
                //       //       ),
                //       //     ),
                //       //     Container(
                //       //       child: Row(
                //       //         children: <Widget>[
                //       //           Icon(
                //       //             Icons.share,
                //       //             color: Colors.grey[400],
                //       //           ),
                //       //           Padding(
                //       //             padding:
                //       //             EdgeInsets.symmetric(horizontal: 5.0),
                //       //           ),
                //       //         ],
                //       //       ),
                //       //     ),
                //       //   ],
                //       // ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .2,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaY: 30,
                          sigmaX: 30
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        child: Container(
                          width: 50,
                          height: 130,
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
                                onTap: () async {
                                  // print("bb7bn7npostProvider.postList[index]['post_id']");
                                  // print(postProvider.postList[index].id);
                                  if (postProvider.isLikedPost){
                                    setState(() {
                                      /*await*/ postProvider.unlikeBusinessPost(
                                        // singleEventPost.id,
                                        //   item['post_id'],
                                        //   postProvider.postList[index]['post_id'],
                                        //   postProvider.postList[index].id,
                                          widget.businessPost,
                                          userProvider.user!
                                      );
                                    });
                                  }
                                  else{
                                    setState(() {
                                      /*await*/ postProvider.likeBusinessPost(
                                          // postProvider.postList[index].id,
                                          widget.businessPost,
                                          userProvider.user!
                                      );
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
                                  child: Column(
                                    children: [
                                      Icon(
                                        // Icons.reply,
                                        postProvider.isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                        color: postProvider.isLikedPost ? Colors.red : Colors.grey[50],
                                        // color: Colors.red[500],
                                        // color: Colors.pink[300],
                                        size: 25,
                                      ),
                                      SizedBox(height: 5,),
                                      Text(
                                        // '27',
                                        /*postLikes*/postProvider.postLikes.length.toString(),
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
                                onTap: () {
                                  //print('comments');
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        duration: const Duration(
                                            milliseconds: 500
                                        ),
                                        alignment: Alignment.center,
                                        type: PageTransitionType.fade,
                                        child: PostCommentsScreen(
                                          isSingleEventPost: false,
                                          myUser: userProvider.user,
                                          businessPost: widget.businessPost
                                        ),
                                      )
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
                                  child: Column(
                                    children: [
                                      Icon(
                                        // Icons.mode_comment_outlined,
                                        Icons.sms_outlined,
                                        color: Colors.grey[50],
                                        // color: Colors.blue[400],
                                        size: 25,
                                      ),
                                      SizedBox(height: 5,),
                                      Text(
                                        // '320',
                                        // bookingPostCommentNumber.toString(),
                                        //   postProvider.comments!.length.toString(),
                                          postProvider.postComments!.length.toString(),
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
                SizedBox(width: 15,)
              ],
            ),
          ),
          Visibility(
            visible: isFilterVisible,
            child: Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              // width: MediaQuery.of(context).size.width * 0.34,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: Center(
                          child: Marquee(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(milliseconds: 500),
                                            alignment: Alignment.center,
                                            type: PageTransitionType.fade,
                                            child: PrestazioneSlotsScreen(
                                              prestazione: widget.businessPost.prestazione,
                                            )
                                        )
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                      right: 20,
                                      left: 5,
                                      bottom: widget.businessPost.description != null && widget.businessPost.description != '' ? 20 : 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          child: FutureImage(
                                            // post.prestazione!.image ?? '',
                                            widget.businessPost.prestazione!.image != null && widget.businessPost.prestazione!.image != ''
                                                ? widget.businessPost.prestazione!.image!
                                                : widget.businessPost.business!.profile_image!,
                                            width: 40,
                                            height: 40,
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GradientText(
                                              // post.business!.name ?? '',
                                              // post.booking!.prestazione!.title ?? '',
                                              widget.businessPost.prestazione!.title ?? '',
                                              // 'A partire da € 60,00',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
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
                                                  fontSize: 15
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 2,),
                                            GradientText(
                                              // post.business!.name ?? '',
                                              // post.booking!.prestazione!.title ?? '',
                                              widget.businessPost.prestazione!.business!.name ?? '',
                                              // 'A partire da € 60,00',
                                              maxLines: 1,
                                              // overflow: TextOverflow.ellipsis,
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

                                                    Color(0xffFFA818),
                                                    Color(0xffF68A3D),

                                                    // Colors.white,
                                                    // Colors.white,
                                                    // Colors.yellow,
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
                                                  fontSize: 14
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // SizedBox(width: 15,),
                                Visibility(
                                  // visible: item['user_id'] != null,
                                  visible: widget.businessPost.user!.id != null && widget.businessPost.prestazione != null,
                                  child: RotationTransition(
                                    turns: AlwaysStoppedAnimation(15 / 360),
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: 1,
                                      height: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(milliseconds: 500),
                                            alignment: Alignment.center,
                                            type: PageTransitionType.fade,
                                            child: UserProfileScreen(
                                              user: widget.businessPost.user!,
                                              isTab: false,
                                            )
                                        )
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                      left: 20,
                                      right: 5,
                                      bottom: widget.businessPost.description != null && widget.businessPost.description != '' ? 20 : 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          child: widget.businessPost.user!.profile_image != null && widget.businessPost.user!.profile_image != null ? FutureImage(
                                            widget.businessPost.user!.profile_image ?? '',
                                            // post.booking!.user.profile_image ?? '',
                                            width: 40,
                                            height: 40,
                                          ) : Icon(
                                            Icons.account_circle_rounded,
                                            color: Colors.grey[300],
                                            size: 45,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GradientText(
                                              // post.business!.name ?? '',
                                              // '@' + post.user!.username! ?? '',
                                              widget.businessPost.user!.name ?? '',
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
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Marquee(
                      //   child: Row(
                      //     children: [
                      //       ClipRRect(
                      //         borderRadius: BorderRadius.circular(4),
                      //         clipBehavior: Clip.antiAliasWithSaveLayer,
                      //         child: FutureImage(
                      //           widget.businessPost.user!.profile_image ?? '',
                      //           // post.booking!.user.profile_image ?? '',
                      //           width: 30,
                      //           height: 30,
                      //         ),
                      //       ),
                      //       SizedBox(width: 5,),
                      //       GradientText(
                      //         // post.business!.name ?? '',
                      //         // '@' + post.user!.username! ?? '',
                      //         widget.businessPost.user!.name ?? '',
                      //         // post.booking!.user.name ?? '',
                      //         // 'A partire da € 60,00',
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //         // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                      //         gradient: LinearGradient(
                      //             begin: Alignment.bottomLeft,
                      //             end: Alignment.topRight,
                      //             colors: [
                      //               // Color(0xff8921aa),
                      //               // Color(0xffDA44bb),
                      //               // Colors.pinkAccent
                      //               Colors.white,
                      //               Colors.white,
                      //               // Color(0xffDA44bb)
                      //               // Color(0xfffd746c),
                      //               // Color(0xffff9068),
                      //             ]
                      //         ),
                      //         // gradient: LinearGradient(
                      //         //     begin: Alignment.bottomLeft,
                      //         //     end: Alignment.topRight,
                      //         //     colors: [
                      //         //       Colors.blue[500],
                      //         //       Color(0xffDA44bb),
                      //         //
                      //         //       Color(0xff8921aa),
                      //         //     ]
                      //         // ),
                      //         style: TextStyle(
                      //             color: Colors.blue[500],
                      //             fontWeight: FontWeight.w700,
                      //             fontSize: 16
                      //         ),
                      //         textAlign: TextAlign.left,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(height: 10,),
                      // Marquee(
                      //   child: Row(
                      //     children: [
                      //       ClipRRect(
                      //         borderRadius: BorderRadius.circular(4),
                      //         clipBehavior: Clip.antiAliasWithSaveLayer,
                      //         child: FutureImage(
                      //           // post.prestazione!.image ?? '',
                      //           widget.businessPost.prestazione!.image != null && widget.businessPost.prestazione!.image != ''
                      //               ? widget.businessPost.prestazione!.image!
                      //               : businessProvider.business!.profile_image!,
                      //           width: 30,
                      //           height: 30,
                      //         ),
                      //       ),
                      //       SizedBox(width: 5,),
                      //       GradientText(
                      //         // post.business!.name ?? '',
                      //         // post.booking!.prestazione!.title ?? '',
                      //         widget.businessPost.prestazione!.title ?? '',
                      //         // 'A partire da € 60,00',
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //         // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                      //         gradient: LinearGradient(
                      //             begin: Alignment.bottomLeft,
                      //             end: Alignment.topRight,
                      //             colors: [
                      //               // Color(0xff8921aa),
                      //               // Color(0xffDA44bb),
                      //               // Color(0xffDA44bb)
                      //               // Color(0xfffd746c),
                      //               // Color(0xffff9068),
                      //               Colors.yellow,
                      //               Colors.yellow,
                      //             ]
                      //         ),
                      //         // gradient: LinearGradient(
                      //         //     begin: Alignment.bottomLeft,
                      //         //     end: Alignment.topRight,
                      //         //     colors: [
                      //         //       Colors.blue[500],
                      //         //       Color(0xffDA44bb),
                      //         //
                      //         //       Color(0xff8921aa),
                      //         //     ]
                      //         // ),
                      //         style: TextStyle(
                      //             color: Colors.blue[500],
                      //             fontWeight: FontWeight.w700,
                      //             fontSize: 16
                      //         ),
                      //         textAlign: TextAlign.left,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      /*SizedBox(height: widget.businessPost.description != null && widget.businessPost.description != '' ? 20 : 0,),*/
                      // Visibility(
                      //   visible: widget.businessPost.description != null,
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width * .9,
                      //     child: /*Gradient*/Text(
                      //       widget.businessPost.description ?? '',
                      //       maxLines: 10,
                      //       overflow: TextOverflow.ellipsis,
                      //       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //       // gradient: Gradients.haze,
                      //       style: TextStyle(
                      //           // color: Colors.white,
                      //           color: Colors.grey[100],
                      //           fontWeight: FontWeight.w500,
                      //           fontSize: 14
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      Visibility(
                        visible: widget.businessPost.description != null,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          // margin: EdgeInsets.only(top: 10, left: 10),
                          child: ExpandableText(
                            widget.businessPost.description ?? '',
                            onExpandedChanged: (change) {
                              //print(change);
                              setState(() {
                                isContainerVisible = !change;
                              });
                            },
                            maxLines: 10,
                            textAlign: TextAlign.center,
                            collapseText: 'nascondi',
                            expandText: 'mostra',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: widget.businessPost.description != null && widget.businessPost.description != '' ? 20 : 0,),
                      Container(
                        // width: MediaQuery.of(context).size.width * .3,
                        child: Marquee(
                          child: Text(
                            // post.created_at!,
                            DateFormat.yMMMd('it_IT').format(widget.businessPost.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                + ' alle ' + widget.businessPost.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[200],
                                fontWeight: FontWeight.w500,
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
          ),
          // Visibility(
          //   visible: isFilterVisible,
          //   child: Positioned(
          //     bottom: 20.0,
          //     left: 15.0,
          //     // right: 10.0,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             Visibility(
          //               // visible: widget.businessPost['prestazione_id'] != null,
          //               visible: widget.businessPost.prestazione!.id != null,
          //               child: InkWell(
          //                 onTap: (){
          //                   Navigator.push(
          //                     context,
          //                     PageTransition(
          //                         duration: const Duration(milliseconds: 500),
          //                         alignment: Alignment.center,
          //                         type: PageTransitionType.fade,
          //                         child: PrestazioneScreen(
          //                           // prestazione: Prestazione(
          //                           //   id: widget.businessPost['prestazione_id'],
          //                           //   duration: widget.businessPost['prestazione_duration'],
          //                           //   image: widget.businessPost['prestazione_image'],
          //                           //   price: widget.businessPost['prestazione_price']?.toDouble(),
          //                           //   title: widget.businessPost['prestazione_title'],
          //                           //   description: widget.businessPost['prestazione_description'] ?? '',
          //                           //   // business_id: widget.businessPost['business_id'],
          //                           //   business: Business(
          //                           //     id: widget.businessPost['business_id'],
          //                           //     name: widget.businessPost['business_name'],
          //                           //     longitude: widget.businessPost['business_longitude'],
          //                           //     latitude: widget.businessPost['business_latitude'],
          //                           //     type_id: widget.businessPost['business_type_id'],
          //                           //     // profile_image: e['business_image'],
          //                           //     profile_image: widget.businessPost['business_profile_image'],
          //                           //     description: widget.businessPost['business_description'],
          //                           //     room_id: widget.businessPost['business_room_id'],
          //                           //     address: widget.businessPost['business_address'],
          //                           //     phone_number: widget.businessPost['business_phone_number'],
          //                           //     max_contemporary_appointments: widget.businessPost['max_contemporary_appointments'],
          //                           //     category: Category(
          //                           //       id: widget.businessPost['category_id'],
          //                           //       image: widget.businessPost['category_image'],
          //                           //       name: widget.businessPost['category_name'],
          //                           //     )
          //                           //   ),
          //                           // ),
          //                           prestazione: widget.businessPost.prestazione,
          //                         )
          //                     ),
          //                   );
          //                 },
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.start,
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     // // titleText,
          //                     // // commentText,
          //                     // // imageProfile,
          //                     // Padding(
          //                     //   padding: EdgeInsets.symmetric(horizontal: 5.0),
          //                     //   child: ClipRRect(
          //                     //     borderRadius: BorderRadius.circular(50),
          //                     //     child: Image(
          //                     //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
          //                     //       image: CachedNetworkImageProvider(
          //                     //         widget.businessPost['business_profile_image'],
          //                     //         errorListener: () => SizedBox(),
          //                     //       ),
          //                     //       width: 41,
          //                     //       height: 41,
          //                     //       fit: BoxFit.cover,
          //                     //     ),
          //                     //   ),
          //                     // ),
          //                     // // SizedBox(height: 10,),
          //                     // Padding(
          //                     //   padding: const EdgeInsets.only(left: 2.0),
          //                     //   child: Column(
          //                     //     crossAxisAlignment: CrossAxisAlignment.start,
          //                     //     children: [
          //                     //       // usernameText,
          //                     //       Container(
          //                     //         width: MediaQuery.of(context).size.width * 0.23,
          //                     //         child: Text(
          //                     //           widget.businessPost['business_name'] ?? '',
          //                     //           maxLines: 1,
          //                     //           style: TextStyle(
          //                     //               color: Colors.yellow,
          //                     //               fontWeight: FontWeight.w700,
          //                     //               fontSize: 11
          //                     //           ),
          //                     //         ),
          //                     //       ),
          //                     //       Container(
          //                     //         width: MediaQuery.of(context).size.width * 0.23,
          //                     //         child: Text(
          //                     //           widget.businessPost['prestazione_title'] ?? '',
          //                     //           // widget.businessPost['business_address'] ?? '',
          //                     //           maxLines: 1,
          //                     //           style: TextStyle(
          //                     //               color: Colors.white,
          //                     //               fontWeight: FontWeight.w500,
          //                     //               fontSize: 12
          //                     //           ),
          //                     //         ),
          //                     //       ),
          //                     //     ],
          //                     //   ),
          //                     // ),
          //
          //                     // SizedBox(width: 10,),
          //
          //                     // RotationTransition(
          //                     //   turns: AlwaysStoppedAnimation(15 / 360),
          //                     //   child: Container(
          //                     //     width: 1,
          //                     //     height: 30,
          //                     //     color: Colors.white,
          //                     //   ),
          //                     // ),
          //                     //
          //                     // SizedBox(width: 15,),
          //
          //                     SizedBox(width: 5,),
          //                     ClipRRect(
          //                       borderRadius: BorderRadius.circular(8),
          //                       child: FutureImage(
          //                         // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
          //                         // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
          //                         // widget.businessPost['prestazione_image'] != null && widget.businessPost['prestazione_image'] != ''
          //                         //   ? widget.businessPost['prestazione_image']
          //                         //   : widget.businessPost['business_profile_image'],
          //                         widget.businessPost.prestazione!.image != null && widget.businessPost.prestazione!.image != ''
          //                             ? widget.businessPost.prestazione!.image!
          //                             : widget.businessPost.business!.profile_image!,
          //                         width: 35,
          //                         height: 35,
          //                       ),
          //                     ),
          //                     SizedBox(width: 5,),
          //                     Padding(
          //                       padding: const EdgeInsets.only(left: 2.0),
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Container(
          //                             // width: MediaQuery.of(context).size.width * 0.23,
          //                             constraints: BoxConstraints(
          //                               /*minWidth: 100,*/
          //                                 maxWidth: MediaQuery.of(context).size.width * 0.3
          //                             ),
          //                             child: Marquee(
          //                               child: Padding(
          //                                 padding: const EdgeInsets.only(left: .0, bottom: 2),
          //                                 child: GradientText(
          //                                   // widget.businessPost['prestazione_title'] ?? widget.businessPost['category_name'],
          //                                   widget.businessPost.prestazione!.title ?? widget.businessPost.business!.category!.name!,
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
          //                           ),
          //                           Padding(
          //                             padding: const EdgeInsets.only(left: 2.1),
          //                             child: Text(
          //                               // widget.businessPost['business_name'] ?? '',
          //                               // widget.businessPost['prestazione_price']?.toDouble().toString() != null ? "€ " : '',
          //                               // "${int.tryParse(widget.businessPost['prestazione_duration'].toString()).toString()} min",
          //                               "${int.tryParse(widget.businessPost.prestazione!.duration.toString()).toString()} min",
          //                               // ? "${widget.businessPost['prestazione_duration'].toInt().toString()} min"
          //                               // : '',
          //                               // widget.businessPost['prestazione_title'] ?? '',
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                               style: TextStyle(
          //                                 // color: Colors.white,
          //                                   color: Colors.yellow[700],
          //                                   fontWeight: FontWeight.w500,
          //                                   fontSize: 12
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //             SizedBox(width: 15,),
          //             Visibility(
          //               // visible: widget.businessPost['user_id'] != null,
          //               visible: widget.businessPost.user!.id != null,
          //               child: RotationTransition(
          //                 turns: AlwaysStoppedAnimation(15 / 360),
          //                 child: Container(
          //                   width: 1,
          //                   height: 30,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //             ),
          //             SizedBox(width: 15,),
          //             Visibility(
          //               // visible: widget.businessPost['user_id'] != null,
          //               visible: widget.businessPost.user!.id != null,
          //               child: InkWell(
          //                 onTap: (){
          //                   Navigator.push(
          //                     context,
          //                     PageTransition(
          //                         duration: const Duration(milliseconds: 500),
          //                         alignment: Alignment.center,
          //                         type: PageTransitionType.fade,
          //                         child: UserProfileScreen(
          //                           // user: User(
          //                           //   id: widget.businessPost['user_id'],
          //                           //   email: widget.businessPost['user_email'],
          //                           //   username: widget.businessPost['user_username'],
          //                           //   name: widget.businessPost['user_name'],
          //                           //   phone_number: widget.businessPost['user_phone_number'],
          //                           //   profile_image: widget.businessPost['user_profile_image'],
          //                           //   description: widget.businessPost['user_description'],
          //                           // ),
          //                           // userId: widget.businessPost.user!.id!,
          //                           user: widget.businessPost.user!,
          //                           isTab: false,
          //                         )
          //                     ),
          //                   );
          //                 },
          //                 child: Row(
          //                   children: [
          //                     Padding(
          //                       padding: EdgeInsets.symmetric(horizontal: 5.0),
          //                       child: ClipRRect(
          //                         borderRadius: BorderRadius.circular(50),
          //                         child: FutureImage(
          //                           // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
          //                           // widget.businessPost['user_profile_image'] ?? '',
          //                           widget.businessPost.user!.profile_image ?? '',
          //                           width: 37,
          //                           height: 37,
          //                         ),
          //                       ),
          //                     ),
          //                     // SizedBox(height: 10,),
          //                     Padding(
          //                       padding: const EdgeInsets.only(left: 2.0),
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           // usernameText,
          //                           Container(
          //                             // width: MediaQuery.of(context).size.width * 0.23,
          //                             constraints: BoxConstraints(
          //                               /*minWidth: 100,*/
          //                                 maxWidth: MediaQuery.of(context).size.width * 0.2
          //                             ),
          //                             child: Text(
          //                               // widget.businessPost['user_username'] != null ? "@${widget.businessPost['user_username']}" : '',
          //                               widget.businessPost.user!.username != null ? "@${widget.businessPost.user!.username}" : '',
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                               style: TextStyle(
          //                                   color: Colors.yellow,
          //                                   fontWeight: FontWeight.w700,
          //                                   fontSize: 11
          //                               ),
          //                             ),
          //                           ),
          //                           SizedBox(height: 2,),
          //                           Container(
          //                             // width: MediaQuery.of(context).size.width * 0.23,
          //                             constraints: BoxConstraints(
          //                               /*minWidth: 100,*/
          //                                 maxWidth: MediaQuery.of(context).size.width * 0.3
          //                             ),
          //                             child: Marquee(
          //                               child: Text(
          //                                 // widget.businessPost['user_name'] ?? '',
          //                                 widget.businessPost.user!.name ?? '',
          //                                 maxLines: 1,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 style: TextStyle(
          //                                     color: Colors.white,
          //                                     fontWeight: FontWeight.w500,
          //                                     fontSize: 12
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                     SizedBox(width: 10,),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //         Container(
          //           width: MediaQuery.of(context).size.width * 0.85,
          //           margin: EdgeInsets.only(top: 10, left: 10),
          //           child: ExpandableText(
          //             widget.businessPost.description ?? '',
          //             onExpandedChanged: (change) {
          //               //print(change);
          //               setState(() {
          //                 isContainerVisible = !change;
          //               });
          //             },
          //             maxLines: 10,
          //             textAlign: TextAlign.start,
          //             collapseText: 'nascondi',
          //             expandText: 'mostra',
          //             style: TextStyle(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 13.5
          //             ),
          //           ),
          //         ),
          //         SizedBox(height: 10,),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 5.0),
          //           child: Container(
          //             width: MediaQuery.of(context).size.width * 0.77,
          //             child: Row(
          //               // mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 // Spacer(),
          //                 Text(
          //                   // '15:32 15 Settembre 2022',
          //                   // DateFormat.yMMMMd('it_IT').format(DateTime.parse(item['post_created_at'])).toString()
          //                   //     + ' alle ' + item['post_created_at'].substring(11, 16),
          //                   DateFormat.yMMMMd('it_IT').format(widget.businessPost.created_at!).toString()
          //                       + ' alle ' + widget.businessPost.created_at!.toString().substring(11, 16),
          //                   style: TextStyle(
          //                       color: Colors.grey[200],
          //                       fontWeight: FontWeight.w500,
          //                       fontSize: 11.5
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     )
          //   ),
          // ),
        ],
      ),
    );
  }
}
