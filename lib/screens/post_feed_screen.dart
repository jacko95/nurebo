import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:nurebo/models/booking_post.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/post_full_screen.dart';
import 'package:nurebo/screens/post_comments_screen.dart';
import 'package:nurebo/screens/post_experience_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:nurebo/widgets/page_transformer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;

import '../models/user.dart';
import '../provider/socket_provider.dart';


class PostFeedScreen extends StatefulWidget {

  const PostFeedScreen({super.key,});

  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> with SingleTickerProviderStateMixin {
  var padding = 26.0;
  var verticalInset = 42.0;
  // var postProvider.postList = [];
  var singleEventpostList = [];
  var storyList = [];
  late var cardAspectRatio;
  var widgetAspectRatio;
  var gradientStartColor;
  var gradientEndColor;
  late PageController controller;
  late PageController storyController;
  // var i;
  var currentPage;
  var currentStoryPage;
  bool isStoryFilterVisible = true;
  bool isContainerVisible = true;
  bool isPostFilterVisible = true;
  // var storyProvider;
  // var postProvider;
  late UserProvider userProvider;
  late SocketProvider socketProvider;
  late GeolocationProvider geolocationProvider;
  TabController? _tabController;
  // Future? a;
  final List<Tab> tabs = <Tab>[
    const Tab(text: "Post"),
  ];
  var ord;
  // List? postComments = [];
  // List postLikes = [];
  // List businessPostLikes = [];
  // List businessPostComments = [];
  // bool isLikedPost = false;
  Future bac = Future(() {},);
  Future cab = Future(() {},);
  Future rab = Future(() {},);
  Future dab = Future(() {},);
  Future eab = Future(() {},);
  Future nab = Future(() {},);
  Future all = Future(() {},);
  TargetPlatform? _platform;
  CarouselSliderController carouselController0 = CarouselSliderController();
  late PostProvider postProvider;
  ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();


  Widget _applyTextEffects({required double translationFactor, required Widget child, required var pageVisibility}) {
    final double xTranslation = pageVisibility.pagePosition * translationFactor;

    return Opacity(
      opacity: pageVisibility.visibleFraction,
      child: Transform(
        alignment: FractionalOffset.topLeft,
        transformHitTests: false,
        transform: Matrix4.translationValues(
          0,
          xTranslation,
          0.0,
        ),
        child: child,
      ),
    );
  }

  // _buildSidebarBookingPost(BuildContext context, var item, var pageVisibility, int i) {
  //   // storyProvider = Provider.of<StoryProvider>(context, listen: false);
  //   // storyProvider.getAllUserFollowImageStories(this.widget.user.id);
  //   // storyProvider.getAllUserFollowVideoStories(this.widget.user.id);
  //   // int bookingPostCommentNumber = 0;
  //
  //   var usernameText = _applyTextEffects(
  //     // translationFactor: 300.0,
  //       translationFactor: 400.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         // child: GradientText(
  //         //   item['user_username'],
  //         //   shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
  //         //   gradient: isThemeCurrentlyDark(context)
  //         //       ? Gradients.coldLinear
  //         //       : Gradients.backToFuture,
  //         //   style: SubHeadingStylesGradient.white,
  //         //   textAlign: TextAlign.center,
  //         // ),
  //         child: Text(
  //           '@' + item['user_username'],
  //           style: TextStyle(
  //               color: Colors.blue,
  //               fontWeight: FontWeight.w900,
  //               fontSize: 11
  //           ),
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var titleText = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: GradientText(
  //           item['post_title'] ?? ' ',
  //           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //           gradient: Gradients.haze,
  //           // style: HeadingStylesGradient.white,
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var commentText = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: /*Gradient*/Text(
  //           item['post_description'] ?? ' ',
  //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //           // gradient: Gradients.haze,
  //           style: TextStyle(
  //               color: Colors.grey[300],
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var imageProfile = _applyTextEffects(
  //     // translationFactor: -500.0,
  //       translationFactor: 500.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: Image(
  //             // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
  //             image: CachedNetworkImageProvider(
  //                 item['profile_image'],
  //                 errorListener: () => SizedBox()
  //             ),
  //             width: 41,
  //             height: 41,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   // User followedUser = new User(
  //   //   // id: int.parse(postProvider.posts[i]['user_id']),
  //   //   id: item['user_id'].toInt(),
  //   //   description: item['user_description'],
  //   //   profile_image: item['profile_image'],
  //   //   first_name: item['first_name'],
  //   //   name: item['name'],
  //   //   // last_name: postProvider.posts[i]['last_name'],
  //   //   // city: postProvider.posts[i]['city'],
  //   //   // nation: postProvider.posts[i]['nation'],
  //   //   username: item['user_username'],
  //   //   email: item['email'],
  //   // );
  //   // User followedUser = new User(
  //   //   // id: int.parse(postProvider.posts[i]['user_id']),
  //   //   id: storyProvider.stories[i]['user_id'],
  //   //   description: storyProvider.stories[i]['user_description'],
  //   //   profile_image: storyProvider.stories[i]['profile_image'],
  //   //   first_name: storyProvider.stories[i]['first_name'],
  //   //   name: storyProvider.stories[i]['name'],
  //   //   // last_name: postProvider.posts[i]['last_name'],
  //   //   // city: postProvider.posts[i]['city'],
  //   //   // nation: postProvider.posts[i]['nation'],
  //   //   username: storyProvider.stories[i]['user_username'],
  //   //   email: storyProvider.stories[i]['email'],
  //   // );
  //
  //   // for (var comment in bookingPostComments) {
  //   //   // //print(comment['post_id']);
  //   //   // if (like['post_id'] == singleEventPost.id) {
  //   //   if(comment['booking_post_id'] == postProvider.postList[i]['post_id']) {
  //   //     bookingPostCommentNumber++;
  //   //   }
  //   // }
  //   // isLikedPost = false;
  //   // for (var like in bookingPostLikes) {
  //   //   // //print('like gggyg');
  //   //   // //print(like);
  //   //   // //print(like['user_id'] == userProvider.user.id);
  //   //   // if (like['post_id'] == singleEventPost.id) {
  //   //   if (like['user_id'] == userProvider.user.id) {
  //   //     // setState(() {
  //   //       isLikedPost = true;
  //   //     // });
  //   //   }
  //   // }
  //   // //print(isLikedPost);
  //
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // InkWell(
  //       //   onTap: (){
  //       //     Navigator.push(
  //       //       context,
  //       //       PageTransition(
  //       //         duration: const Duration(milliseconds: 1),
  //       //         // alignment: Alignment.topRight,
  //       //         // type: PageTransitionType.scale,
  //       //
  //       //         // post[index]['title']
  //       //         child: UserProfileScreen(
  //       //           // myUser: widget.user,
  //       //             user: followedUser/*imagePosts[i].user*/
  //       //         ),
  //       //         // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
  //       //         type: null,
  //       //       ),
  //       //       // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
  //       //     );
  //       //   },
  //       //   child: Column(
  //       //     mainAxisAlignment: MainAxisAlignment.center,
  //       //     crossAxisAlignment: CrossAxisAlignment.center,
  //       //     children: [
  //       //       // titleText,
  //       //       // commentText,
  //       //       imageProfile,
  //       //
  //       //       SizedBox(height: 10,),
  //       //       usernameText,
  //       //
  //       //       // Row(
  //       //       //   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       //       //   children: <Widget>[
  //       //       //     Container(
  //       //       //       child: Row(
  //       //       //         children: <Widget>[
  //       //       //           Icon(
  //       //       //             Icons.reply,
  //       //       //             color: Colors.grey[400],
  //       //       //           ),
  //       //       //           Padding(
  //       //       //             padding:
  //       //       //             EdgeInsets.symmetric(horizontal: 5.0),
  //       //       //           ),
  //       //       //           Text(
  //       //       //             Random().nextInt(50).toString(),
  //       //       //             style: TextStyle(
  //       //       //               color: Colors.grey[400],
  //       //       //             ),
  //       //       //           )
  //       //       //         ],
  //       //       //       ),
  //       //       //     ),
  //       //       //     Container(
  //       //       //       child: Row(
  //       //       //         children: <Widget>[
  //       //       //           Icon(
  //       //       //             Icons.repeat,
  //       //       //             color: Colors.grey[400],
  //       //       //           ),
  //       //       //           Padding(
  //       //       //             padding:
  //       //       //             EdgeInsets.symmetric(horizontal: 5.0),
  //       //       //           ),
  //       //       //           Text(
  //       //       //             Random().nextInt(50).toString(),
  //       //       //             style: TextStyle(
  //       //       //               color: Colors.grey[400],
  //       //       //             ),
  //       //       //           )
  //       //       //         ],
  //       //       //       ),
  //       //       //     ),
  //       //       //     Container(
  //       //       //       child: Row(
  //       //       //         children: <Widget>[
  //       //       //           Icon(
  //       //       //             Icons.favorite_border,
  //       //       //             color: Colors.grey[400],
  //       //       //           ),
  //       //       //           Padding(
  //       //       //             padding:
  //       //       //             EdgeInsets.symmetric(horizontal: 5.0),
  //       //       //           ),
  //       //       //           Text(
  //       //       //             Random().nextInt(50).toString(),
  //       //       //             style: TextStyle(
  //       //       //               color: Colors.grey[400],
  //       //       //             ),
  //       //       //           )
  //       //       //         ],
  //       //       //       ),
  //       //       //     ),
  //       //       //     Container(
  //       //       //       child: Row(
  //       //       //         children: <Widget>[
  //       //       //           Icon(
  //       //       //             Icons.share,
  //       //       //             color: Colors.grey[400],
  //       //       //           ),
  //       //       //           Padding(
  //       //       //             padding:
  //       //       //             EdgeInsets.symmetric(horizontal: 5.0),
  //       //       //           ),
  //       //       //         ],
  //       //       //       ),
  //       //       //     ),
  //       //       //   ],
  //       //       // ),
  //       //     ],
  //       //   ),
  //       // ),
  //       Padding(
  //         padding: const EdgeInsets.only(top: 80.0),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(5),
  //           child: BackdropFilter(
  //             filter: ImageFilter.blur(
  //                 sigmaY: 30,
  //                 sigmaX: 30
  //             ),
  //             child: Padding(
  //               padding: EdgeInsets.only(top: 15, bottom: 15),
  //               child: Container(
  //                 width: 50,
  //                 height: 190,
  //                 child: Column(
  //                   children: [
  //                     InkWell(
  //                       onTap: () {
  //                         //print('review');
  //                         //print('andare in una listview in cui ci sono tutte le recensioni di quella prestazione');
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(bottom: 11.0, top: 6, left: 6, right: 6),
  //                         child: Column(
  //                           children: [
  //                             Icon(
  //                               Icons.star,
  //                               // color: Colors.grey[50],
  //                               color: Colors.yellow[500],
  //                               size: 25,
  //                             ),
  //                             SizedBox(height: 5,),
  //                             Text(
  //                                 item['vote']?.toDouble().toString(),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: GoogleFonts.lato(
  //                                   fontWeight: FontWeight.w700,
  //                                   // color: Colors.grey[50],
  //                                   color: Colors.yellow[500],
  //                                   fontSize: 12,
  //                                 )
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         //print('isLikedPost');
  //                         //print(isLikedPost);
  //                         //print(item['post_id']);
  //                         //print(userProvider.user.id);
  //                         if (isLikedPost){
  //                           setState(() {
  //                             unlikeBookingPost(
  //                               // singleEventPost.id,
  //                                 item['post_id'],
  //                                 userProvider.user.id
  //                             );
  //                           });
  //                         }
  //                         else{
  //                           setState(() {
  //                             unlikeBookingPost(
  //                               // singleEventPost.id,
  //                                 item['post_id'],
  //                                 userProvider.user.id
  //                             );
  //                           });
  //                         }
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
  //                         child: Column(
  //                           children: [
  //                             Icon(
  //                               // Icons.reply,
  //                               isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
  //                               color: isLikedPost ? Colors.red : Colors.grey[50],
  //                               // color: Colors.red[500],
  //                               // color: Colors.pink[300],
  //                               size: 25,
  //                             ),
  //                             SizedBox(height: 5,),
  //                             Text(
  //                                 // '27',
  //                                 bookingPostLikes.length.toString() ?? '0',
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: GoogleFonts.lato(
  //                                   fontWeight: FontWeight.w700,
  //                                   color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
  //                                   // color: Colors.red[500],
  //                                   // color: Colors.pink[300],
  //                                   fontSize: 12,
  //                                 )
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         //print('comments');
  //                         Navigator.push(
  //                             context,
  //                             PageTransition(
  //                               duration: const Duration(
  //                                   milliseconds: 500
  //                               ),
  //                               alignment: Alignment.center,
  //                               type: PageTransitionType.fade,
  //                               child: PostCommentsScreen(
  //                                 isSingleEventPost: false,
  //                                 myUser: userProvider.user,
  //                                 post: Post(
  //                                   id: item['post_id'],
  //                                 ),
  //                               ),
  //                             )
  //                         );
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
  //                         child: Column(
  //                           children: [
  //                             Icon(
  //                               // Icons.mode_comment_outlined,
  //                               Icons.sms_outlined,
  //                               color: Colors.grey[50],
  //                               // color: Colors.blue[400],
  //                               size: 25,
  //                             ),
  //                             SizedBox(height: 5,),
  //                             Text(
  //                                 // '320',
  //                                 // bookingPostCommentNumber.toString(),
  //                                 bookingPostComments.length.toString() ?? '0',
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: GoogleFonts.lato(
  //                                   fontWeight: FontWeight.w700,
  //                                   color: Colors.white,
  //                                   fontSize: 12,
  //                                 )
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // child: Text(
  //               //   // categories[i].name,
  //               //   'category.name',
  //               //   overflow: TextOverflow.ellipsis,
  //               //   style: GoogleFonts.lato(
  //               //     fontWeight: FontWeight.w700,
  //               //     color: Colors.white,
  //               //     fontSize: 15,
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 15,)
  //     ],
  //   );
  // }

  // _buildTextStoryContainer(BuildContext context, var item, var pageVisibility, int i) {
  //   storyProvider = Provider.of<StoryProvider>(context, listen: false);
  //   // storyProvider.getAllUserFollowImageStories(this.widget.user.id);
  //   storyProvider.getAllUserFollowVideoStories(this.widget.user.id);
  //
  //   var usernameText = _applyTextEffects(
  //     // translationFactor: 300.0,
  //     translationFactor: 400.0,
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 5.0),
  //       // child: GradientText(
  //       //   item['user_username'],
  //       //   shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
  //       //   gradient: isThemeCurrentlyDark(context)
  //       //       ? Gradients.coldLinear
  //       //       : Gradients.backToFuture,
  //       //   style: SubHeadingStylesGradient.white,
  //       //   textAlign: TextAlign.center,
  //       // ),
  //       child: Text(
  //         '@' + item['user_username'],
  //         style: TextStyle(
  //           color: Colors.blue,
  //           fontWeight: FontWeight.w900,
  //           fontSize: 11
  //         ),
  //       ),
  //     ),
  //     pageVisibility: pageVisibility
  //   );
  //
  //   var titleText = _applyTextEffects(
  //     translationFactor: 200.0,
  //     child: Padding(
  //       padding: EdgeInsets.all(5.0),
  //       child: GradientText(
  //         item['post_title'] ?? ' ',
  //         shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //         gradient: Gradients.haze,
  //         style: HeadingStylesGradient.white,
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //     pageVisibility: pageVisibility
  //   );
  //
  //   var commentText = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: /*Gradient*/Text(
  //           item['post_description'] ?? ' ',
  //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //           // gradient: Gradients.haze,
  //           style: TextStyle(
  //             color: Colors.grey[300],
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var imageProfile = _applyTextEffects(
  //       // translationFactor: -500.0,
  //       translationFactor: 500.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: Image(
  //             // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
  //             image: CachedNetworkImageProvider(
  //               item['profile_image'],
  //             ),
  //             width: 41,
  //             height: 41,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   // User followedUser = new User(
  //   //   // id: int.parse(postProvider.posts[i]['user_id']),
  //   //   id: item['user_id'].toInt(),
  //   //   description: item['user_description'],
  //   //   profile_image: item['profile_image'],
  //   //   first_name: item['first_name'],
  //   //   name: item['name'],
  //   //   // last_name: postProvider.posts[i]['last_name'],
  //   //   // city: postProvider.posts[i]['city'],
  //   //   // nation: postProvider.posts[i]['nation'],
  //   //   username: item['user_username'],
  //   //   email: item['email'],
  //   // );
  //   User followedUser = new User(
  //     // id: int.parse(postProvider.posts[i]['user_id']),
  //     id: storyProvider.stories[i]['user_id'],
  //     description: storyProvider.stories[i]['user_description'],
  //     profile_image: storyProvider.stories[i]['profile_image'],
  //     first_name: storyProvider.stories[i]['first_name'],
  //     name: storyProvider.stories[i]['name'],
  //     // last_name: postProvider.posts[i]['last_name'],
  //     // city: postProvider.posts[i]['city'],
  //     // nation: postProvider.posts[i]['nation'],
  //     username: storyProvider.stories[i]['user_username'],
  //     email: storyProvider.stories[i]['email'],
  //   );
  //
  //   return Positioned(
  //     bottom: 20.0,
  //     left: 10.0,
  //     right: 10.0,
  //     child: InkWell(
  //       onTap: (){
  //         Navigator.push(
  //           context,
  //           PageTransition(
  //             duration: const Duration(milliseconds: 1),
  //             // alignment: Alignment.topRight,
  //             // type: PageTransitionType.scale,
  //
  //             // post[index]['title']
  //             child: UserProfileScreen(
  //               // myUser: widget.user,
  //               user: followedUser/*imagePosts[i].user*/
  //             ),
  //             // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
  //             type: null,
  //           ),
  //           // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
  //         );
  //       },
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           // titleText,
  //           // commentText,
  //           imageProfile,
  //
  //           SizedBox(height: 10,),
  //           usernameText,
  //
  //           // Row(
  //           //   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           //   children: <Widget>[
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.reply,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.repeat,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.favorite_border,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.share,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //         ],
  //           //       ),
  //           //     ),
  //           //   ],
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  _buildBottomTextBookingPost(BuildContext context, var item, var pageVisibility, int i) {
    // storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // storyProvider.getAllUserFollowImageStories(this.widget.user.id);
    // storyProvider.getAllUserFollowVideoStories(this.widget.user.id);

    var usernameText = _applyTextEffects(
      // translationFactor: 300.0,
      translationFactor: 400.0,
      child: Text(
        '@' + (item['user_username'] ?? ''),
        maxLines: 1,
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.w700,
          fontSize: 11
        ),
      ),
      pageVisibility: pageVisibility
    );

    var description = _applyTextEffects(
      translationFactor: 180.0,
      // translationFactor: 400.0,
      child: ExpandableText(
        // "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
        // "Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
        // '',
        item['review'] ?? '',
        maxLines: 8,
        textAlign: TextAlign.start,
        collapseText: 'nascondi',
        expandText: 'mostra',
        onExpandedChanged: (change) {
          //print(change);
          setState(() {
            isContainerVisible = !change;
          });
        },

        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13.5
        ),
      ),
      pageVisibility: pageVisibility
    );

    var titleText = _applyTextEffects(
      translationFactor: 200.0,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: GradientText(
          item['post_title'] ?? ' ',
          shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
          gradient: Gradients.haze,
          // style: HeadingStylesGradient.white,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
      ),
      pageVisibility: pageVisibility
    );

    var commentText = _applyTextEffects(
        translationFactor: 200.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: /*Gradient*/Text(
            item['post_description'] ?? ' ',
            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
            // gradient: Gradients.haze,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),
        ),
        pageVisibility: pageVisibility
    );

    var imageProfile = _applyTextEffects(
        // translationFactor: -500.0,
        translationFactor: 500.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: FutureImage(
              // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
              item['profile_image'] ?? "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
              width: 41,
              height: 41,
            ),
          ),
        ),
        pageVisibility: pageVisibility
    );

    // User followedUser = new User(
    //   // id: int.parse(postProvider.posts[i]['user_id']),
    //   id: item['user_id'].toInt(),
    //   description: item['user_description'],
    //   profile_image: item['profile_image'],
    //   first_name: item['first_name'],
    //   name: item['name'],
    //   // last_name: postProvider.posts[i]['last_name'],
    //   // city: postProvider.posts[i]['city'],
    //   // nation: postProvider.posts[i]['nation'],
    //   username: item['user_username'],
    //   email: item['email'],
    // );
    // User followedUser = User(
    //   // id: int.parse(postProvider.posts[i]['user_id']),
    //   id: storyProvider.stories[i]['user_id'],
    //   description: storyProvider.stories[i]['user_description'],
    //   profile_image: storyProvider.stories[i]['profile_image'],
    //   first_name: storyProvider.stories[i]['first_name'],
    //   name: storyProvider.stories[i]['name'],
    //   // last_name: postProvider.posts[i]['last_name'],
    //   // city: postProvider.posts[i]['city'],
    //   // nation: postProvider.posts[i]['nation'],
    //   username: storyProvider.stories[i]['user_username'],
    //   email: storyProvider.stories[i]['email'],
    // );

    return Positioned(
      bottom: 20.0,
      left: 15.0,
      // right: 10.0,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: (){
          // Navigator.push(
          //   context,
          //   PageTransition(
          //     duration: const Duration(milliseconds: 1),
          //     // alignment: Alignment.topRight,
          //     // type: PageTransitionType.scale,
          //
          //     // post[index]['title']
          //     child: UserProfileScreen(
          //       // myUser: widget.user,
          //       user: followedUser/*imagePosts[i].user*/
          //     ),
          //     // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
          //     type: null,
          //   ),
          //   // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: (){
                //print('oooooo');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // titleText,
                  // commentText,
                  // imageProfile,

                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: FutureImage(
                            // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                            item['user_profile_image'] ?? '',
                            width: 41,
                            height: 41,
                          ),
                        ),
                      ),
                      // SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // usernameText,
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Text(
                                '@' + (item['user_username'] ?? ''),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Text(
                                item['user_name'],
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                    ],
                  ),

                  RotationTransition(
                    turns: AlwaysStoppedAnimation(15 / 360),
                    child: Container(
                      width: 1,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),

                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: (){
                      //print('inkkkk');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureImage(
                            // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                              // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                              item['prestazione_image'] != null && item['prestazione_image'] != '' && item['prestazione_id'] != null
                                  ? item['prestazione_image'] : item['prestazione_image'] != null ? item['business_profile_image'] : 'https://images.pexels.com/photos/12052041/pexels-photo-12052041.jpeg?auto=compress&cs=tinysrgb&w=1600',
                            width: 35,
                            height: 35,
                          ),
                        ),
                        SizedBox(width: 7,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              margin: EdgeInsets.only(left: 1),
                              child: Text(
                                item['business_name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: GradientText(
                                item['prestazione_title'] ?? '',
                                maxLines: 1,
                                shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                overflow: TextOverflow.ellipsis,
                                // gradient: Gradients.haze,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.77,
              margin: EdgeInsets.only(top: 10, left: 5),
              // child: Text(
              //   "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.w500,
              //       fontSize: 13.5
              //   ),
              // ),
              child: description,
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.77,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Spacer(),
                    Text(
                      DateFormat.yMMMMd('it_IT').format(DateTime.parse(item['post_created_at'])).toString()
                          + ' alle ' + item['post_created_at'].substring(11, 16),
                      style: TextStyle(
                          color: Colors.grey[200],
                          fontWeight: FontWeight.w500,
                          fontSize: 10
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBottomTextBusinessPost(BuildContext context, /*BookingPost*/BusinessPost item, var pageVisibility, int i) {
    // storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // storyProvider.getAllUserFollowImageStories(this.widget.user.id);
    // storyProvider.getAllUserFollowVideoStories(this.widget.user.id);

    // var usernameText = _applyTextEffects(
    //   // translationFactor: 300.0,
    //   translationFactor: 400.0,
    //   child: Text(
    //     item['business_name'],
    //     maxLines: 1,
    //     style: TextStyle(
    //       color: Colors.yellow,
    //       fontWeight: FontWeight.w700,
    //       fontSize: 11
    //     ),
    //   ),
    //   pageVisibility: pageVisibility
    // );

    // print('item5ggg6g6b6b8nn');
    // print(item['user_id']);

    var description = /*_applyTextEffects(
      translationFactor: 180.0,
      // translationFactor: 400.0,
      child:*/ /*Expandable*/Text(
        // "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
        // "Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
        // '',
        // item['post_description'] ?? '',
        item.description ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 10,
        textAlign: TextAlign.center,
        // collapseText: 'nascondi',
        // expandText: 'mostra',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13.5
        ),
      /*),
      pageVisibility: pageVisibility*/
    );

    // var titleText = _applyTextEffects(
    //   translationFactor: 200.0,
    //   child: Padding(
    //     padding: EdgeInsets.all(5.0),
    //     child: GradientText(
    //       item['post_title'] ?? ' ',
    //       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
    //       gradient: Gradients.haze,
    //       // style: HeadingStylesGradient.white,
    //       textAlign: TextAlign.center,
    //     ),
    //   ),
    //   pageVisibility: pageVisibility
    // );

    // var commentText = _applyTextEffects(
    //     translationFactor: 200.0,
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 5.0),
    //       child: /*Gradient*/Text(
    //         item['post_description'] ?? ' ',
    //         // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
    //         // gradient: Gradients.haze,
    //         style: TextStyle(
    //           color: Colors.grey[300],
    //           fontSize: 12,
    //           fontWeight: FontWeight.w500
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //     pageVisibility: pageVisibility
    // );
    //
    // var imageProfile = _applyTextEffects(
    //     // translationFactor: -500.0,
    //     translationFactor: 500.0,
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 5.0),
    //       child: ClipRRect(
    //         borderRadius: BorderRadius.circular(50),
    //         child: Image(
    //           // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
    //           image: CachedNetworkImageProvider(
    //             item['business_profile_image'],
    //             errorListener: () => SizedBox()
    //           ),
    //           width: 41,
    //           height: 41,
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //     ),
    //     pageVisibility: pageVisibility
    // );

    // User followedUser = new User(
    //   // id: int.parse(postProvider.posts[i]['user_id']),
    //   id: item['user_id'].toInt(),
    //   description: item['user_description'],
    //   profile_image: item['profile_image'],
    //   first_name: item['first_name'],
    //   name: item['name'],
    //   // last_name: postProvider.posts[i]['last_name'],
    //   // city: postProvider.posts[i]['city'],
    //   // nation: postProvider.posts[i]['nation'],
    //   username: item['user_username'],
    //   email: item['email'],
    // );
    // User followedUser = User(
    //   // id: int.parse(postProvider.posts[i]['user_id']),
    //   id: storyProvider.stories[i]['user_id'],
    //   description: storyProvider.stories[i]['user_description'],
    //   profile_image: storyProvider.stories[i]['profile_image'],
    //   first_name: storyProvider.stories[i]['first_name'],
    //   name: storyProvider.stories[i]['name'],
    //   // last_name: postProvider.posts[i]['last_name'],
    //   // city: postProvider.posts[i]['city'],
    //   // nation: postProvider.posts[i]['nation'],
    //   username: storyProvider.stories[i]['user_username'],
    //   email: storyProvider.stories[i]['email'],
    // );

    return Positioned(
      bottom: 20.0,
      left: 15.0,
      // right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.77,
            child: Marquee(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    // visible: item['prestazione_id'] != null,
                    visible: item.prestazione!.id != null,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: PrestazioneSlotsScreen(
                                // prestazione: Prestazione(
                                //   id: item['prestazione_id'],
                                //   duration: item['prestazione_duration'],
                                //   image: item['prestazione_image'],
                                //   price: item['prestazione_price']?.toDouble(),
                                //   title: item['prestazione_title'],
                                //   description: item['prestazione_description'] ?? '',
                                //   // business_id: item['business_id'],
                                //   business: Business(
                                //     id: item['business_id'],
                                //     name: item['business_name'],
                                //     longitude: item['business_longitude'],
                                //     latitude: item['business_latitude'],
                                //     type_id: item['business_type_id'],
                                //     // profile_image: e['business_image'],
                                //     profile_image: item['business_profile_image'],
                                //     description: item['business_description'],
                                //     room_id: item['business_room_id'],
                                //     address: item['business_address'],
                                //     phone_number: item['business_phone_number'],
                                //     max_contemporary_appointments: item['max_contemporary_appointments'],
                                //     category: Category(
                                //       id: item['category_id'],
                                //       image: item['category_image'],
                                //       name: item['category_name'],
                                //     )
                                //   ),
                                // ),
                                prestazione: item.prestazione,
                              )
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // // titleText,
                          // // commentText,
                          // // imageProfile,
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 5.0),
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(50),
                          //     child: Image(
                          //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                          //       image: CachedNetworkImageProvider(
                          //         item['business_profile_image'],
                          //         errorListener: () => SizedBox(),
                          //       ),
                          //       width: 41,
                          //       height: 41,
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // ),
                          // // SizedBox(height: 10,),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 2.0),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       // usernameText,
                          //       Container(
                          //         width: MediaQuery.of(context).size.width * 0.23,
                          //         child: Text(
                          //           item['business_name'] ?? '',
                          //           maxLines: 1,
                          //           style: TextStyle(
                          //               color: Colors.yellow,
                          //               fontWeight: FontWeight.w700,
                          //               fontSize: 11
                          //           ),
                          //         ),
                          //       ),
                          //       Container(
                          //         width: MediaQuery.of(context).size.width * 0.23,
                          //         child: Text(
                          //           item['prestazione_title'] ?? '',
                          //           // item['business_address'] ?? '',
                          //           maxLines: 1,
                          //           style: TextStyle(
                          //               color: Colors.white,
                          //               fontWeight: FontWeight.w500,
                          //               fontSize: 12
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // SizedBox(width: 10,),

                          // RotationTransition(
                          //   turns: AlwaysStoppedAnimation(15 / 360),
                          //   child: Container(
                          //     width: 1,
                          //     height: 30,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          //
                          // SizedBox(width: 15,),

                          SizedBox(width: 5,),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FutureImage(
                              // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                                // item['prestazione_image'] != null && item['prestazione_image'] != ''
                                //   ? item['prestazione_image']
                                //   : item['business_profile_image'],
                              item.prestazione!.image != null && item.prestazione!.image != ''
                                  ? item.prestazione!.image!
                                  : item.business!.profile_image!,
                              width: 35,
                              height: 35,
                            ),
                          ),
                          SizedBox(width: 5,),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // width: MediaQuery.of(context).size.width * 0.23,
                                  constraints: BoxConstraints(
                                    /*minWidth: 100,*/
                                    // maxWidth: MediaQuery.of(context).size.width * 0.23
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: .0, bottom: 2),
                                    child: GradientText(
                                      // item['prestazione_title'] ?? item['category_name'],
                                      item.prestazione!.title ?? item.business!.category!.name!,
                                      shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      // gradient: Gradients.haze,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text(
                                    // item['business_name'] ?? '',
                                    // item['prestazione_price']?.toDouble().toString() != null ? "€ " : '',
                                    // "${int.tryParse(item['prestazione_duration'].toString()).toString()} min",
                                    // "${int.tryParse(item.prestazione!.duration.toString()).toString()} min",
                                    item.business!.name ?? '',
                                        // ? "${item['prestazione_duration'].toInt().toString()} min"
                                        // : '',
                                    // item['prestazione_title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        // color: Colors.white,
                                        color: Colors.yellow[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Visibility(
                    // visible: item['user_id'] != null,
                    visible: item.user!.id != null,
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(15 / 360),
                      child: Container(
                        width: 1,
                        height: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Visibility(
                    // visible: item['user_id'] != null,
                    visible: item.user!.id != null,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: UserProfileScreen(
                                // user: User(
                                //   id: item['user_id'],
                                //   email: item['user_email'],
                                //   username: item['user_username'],
                                //   name: item['user_name'],
                                //   phone_number: item['user_phone_number'],
                                //   profile_image: item['user_profile_image'],
                                //   description: item['user_description'],
                                // ),
                                // userId: item.user!.id!,
                                user: item.user!,
                                isTab: false,
                              )
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: item.user!.profile_image != null && item.user!.profile_image != '' ? FutureImage(
                                // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                // item['user_profile_image'] ?? '',
                                item.user!.profile_image ?? '',
                                width: 37,
                                height: 37,
                              ) : Icon(
                                Icons.account_circle_rounded,
                                color: Colors.grey[300],
                                size: 42,
                              ),
                            ),
                          ),
                          // SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // usernameText,
                                // Container(
                                //   // width: MediaQuery.of(context).size.width * 0.23,
                                //   constraints: BoxConstraints(
                                //     /*minWidth: 100,*/
                                //       // maxWidth: MediaQuery.of(context).size.width * 0.2
                                //   ),
                                //   child: Text(
                                //     // item['user_username'] != null ? "@${item['user_username']}" : '',
                                //     item.user!.username != null ? "@${item.user!.username}" : '',
                                //     maxLines: 1,
                                //     overflow: TextOverflow.ellipsis,
                                //     style: TextStyle(
                                //         color: Colors.yellow,
                                //         fontWeight: FontWeight.w700,
                                //         fontSize: 11
                                //     ),
                                //   ),
                                // ),
                                // SizedBox(height: 2,),
                                Container(
                                  // width: MediaQuery.of(context).size.width * 0.23,
                                  constraints: BoxConstraints(
                                    /*minWidth: 100,*/
                                      // maxWidth: MediaQuery.of(context).size.width * 0.22
                                  ),
                                  child: Text(
                                    // item['user_name'] ?? '',
                                    item.user!.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.77,
            margin: EdgeInsets.only(top: 10, left: 5),
            // child: Text(
            //   "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
            //   style: TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.w500,
            //       fontSize: 13.5
            //   ),
            // ),
            child: description,
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.77,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer(),
                  Text(
                    // '15:32 15 Settembre 2022',
                  // DateFormat.yMMMMd('it_IT').format(DateTime.parse(item['post_created_at'])).toString()
                  //     + ' alle ' + item['post_created_at'].substring(11, 16),
                  DateFormat.yMMMMd('it_IT').format(item.created_at!).toString()
                      + ' alle ' + item.created_at!.toString().substring(11, 16),
                    style: TextStyle(
                        color: Colors.grey[200],
                        fontWeight: FontWeight.w500,
                        fontSize: 10
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTextThoughtContainer({BuildContext? context, required var item, required var pageVisibility}) {

    var usernameText = _applyTextEffects(
      translationFactor: 300.0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        // child: GradientText(
        //   item['user_username'],
        //   shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
        //   gradient: isThemeCurrentlyDark(context)
        //       ? Gradients.coldLinear
        //       : Gradients.backToFuture,
        //   style: SubHeadingStylesGradient.white,
        //   textAlign: TextAlign.center,
        // ),
        child: Text(
          '@' + item['user_username'],
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w700,
            fontSize: 10
          ),
        ),
      ),
      pageVisibility: pageVisibility
    );

    var titleText = _applyTextEffects(
      translationFactor: 200.0,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: GradientText(
          item['post_title'] ?? ' ',
          shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
          gradient: Gradients.haze,
          // style: HeadingStylesGradient.white,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
      ),
      pageVisibility: pageVisibility
    );

    var commentText = _applyTextEffects(
        translationFactor: 200.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: /*Gradient*/Text(
            item['post_description'] ?? ' ',
            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
            // gradient: Gradients.haze,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontWeight: FontWeight.w700
            ),
            textAlign: TextAlign.center,
          ),
        ),
        pageVisibility: pageVisibility
    );

    var imageProfile = _applyTextEffects(
        translationFactor: 200.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureImage(
              // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                item['profile_image'],
              width: 41,
              height: 41,
            ),
          ),
        ),
        pageVisibility: pageVisibility
    );

    return Positioned(
      bottom: 20.0,
      left: 10.0,
      right: 10.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // titleText,
          commentText,
          SizedBox(height: 5,),
          usernameText,
          // imageProfile,
        ],
      ),
    );
  }

  _buildTextActivitiesContainer({BuildContext? context, var item, var pageVisibility}) {
    // var usernameText = _applyTextEffects(
    //   translationFactor: 300.0,
    //   child: Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 5.0),
    //     // child: GradientText(
    //     //   item['user_username'],
    //     //   shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
    //     //   gradient: isThemeCurrentlyDark(context)
    //     //       ? Gradients.coldLinear
    //     //       : Gradients.backToFuture,
    //     //   style: SubHeadingStylesGradient.white,
    //     //   textAlign: TextAlign.center,
    //     // ),
    //     child: Text(
    //       '@' + item['user_username'],
    //       style: TextStyle(
    //         color: Colors.blue,
    //         fontWeight: FontWeight.w700,
    //         fontSize: 10
    //       ),
    //     ),
    //   ),
    //   // pageVisibility: pageVisibility
    // );
    //
    // var titleText = _applyTextEffects(
    //   translationFactor: 200.0,
    //   child: Padding(
    //     padding: EdgeInsets.all(5.0),
    //     child: GradientText(
    //       item['post_title'] ?? ' ',
    //       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
    //       gradient: Gradients.haze,
    //       style: HeadingStylesGradient.white,
    //       textAlign: TextAlign.center,
    //     ),
    //   ),
    //   // pageVisibility: pageVisibility
    // );
    //
    // var commentText = _applyTextEffects(
    //     translationFactor: 200.0,
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 5.0),
    //       child: /*Gradient*/Text(
    //         item['post_description'] ?? ' ',
    //         // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
    //         // gradient: Gradients.haze,
    //         style: TextStyle(
    //           color: Colors.grey[300],
    //           fontSize: 12,
    //           fontWeight: FontWeight.w700
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //     // pageVisibility: pageVisibility
    // );
    //
    // var imageProfile = _applyTextEffects(
    //     translationFactor: 200.0,
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 5.0),
    //       child: ClipRRect(
    //         borderRadius: BorderRadius.circular(8),
    //         child: Image(
    //           // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
    //           image: CachedNetworkImageProvider(
    //             item['profile_image'],
    //           ),
    //           width: 41,
    //           height: 41,
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //     ),
    //     // pageVisibility: pageVisibility
    // );

    return Positioned(
      bottom: 20.0,
      left: 10.0,
      right: 10.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // titleText,

          // commentText,
          SizedBox(height: 5,),
          // usernameText,

          // imageProfile,
        ],
      ),
    );
  }

  // _buildTextPostContainer(BuildContext context, var item, var pageVisibility, int i) {
  //   // postProvider = Provider.of<PostProvider>(context, listen: false);
  //   // postProvider.getAllUserFollowPost(this.widget.user.id);
  //
  //   var categoryText = _applyTextEffects(
  //       translationFactor: 300.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         // child: GradientText(
  //         //   item['user_username'],
  //         //   shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
  //         //   gradient: isThemeCurrentlyDark(context)
  //         //       ? Gradients.coldLinear
  //         //       : Gradients.backToFuture,
  //         //   style: SubHeadingStylesGradient.white,
  //         //   textAlign: TextAlign.center,
  //         // ),
  //         child: Text(
  //           '@' + item['user_username'],
  //           style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.w700,
  //               fontSize: 16
  //           ),
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var titleText = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: GradientText(
  //           item['post_title'] ?? ' ',
  //           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //           gradient: Gradients.haze,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 13,
  //             fontWeight: FontWeight.w700
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var commentText = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: /*Gradient*/Text(
  //           item['post_description'] ?? ' ',
  //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
  //           // gradient: Gradients.haze,
  //           style: TextStyle(
  //               color: Colors.grey[300],
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   var imageProfile = _applyTextEffects(
  //       translationFactor: 200.0,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 5.0),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: Image(
  //             // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
  //             image: CachedNetworkImageProvider(
  //               item['profile_image'],
  //             ),
  //             width: 41,
  //             height: 41,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       pageVisibility: pageVisibility
  //   );
  //
  //   User followedUser = new User(
  //     // id: int.parse(postProvider.posts[i]['user_id']),
  //     id: postProvider.singleEventpostProvider.postList[i]['user_id'].toInt(),
  //     description: postProvider.singleEventpostProvider.postList[i]['user_description'],
  //     profile_image: postProvider.singleEventpostProvider.postList[i]['profile_image'],
  //     first_name: postProvider.singleEventpostProvider.postList[i]['first_name'],
  //     name: postProvider.singleEventpostProvider.postList[i]['name'],
  //     // last_name: postProvider.posts[i]['last_name'],
  //     // city: postProvider.posts[i]['city'],
  //     // nation: postProvider.posts[i]['nation'],
  //     username: postProvider.singleEventpostProvider.postList[i]['user_username'],
  //     email: postProvider.singleEventpostProvider.postList[i]['email'],
  //   );
  //
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           SizedBox(height: 14,),
  //           // titleText,
  //           // commentText,
  //           // Row(
  //           //   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           //   children: <Widget>[
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.reply,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.repeat,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.favorite_border,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //           Text(
  //           //             Random().nextInt(50).toString(),
  //           //             style: TextStyle(
  //           //               color: Colors.grey[400],
  //           //             ),
  //           //           )
  //           //         ],
  //           //       ),
  //           //     ),
  //           //     Container(
  //           //       child: Row(
  //           //         children: <Widget>[
  //           //           Icon(
  //           //             Icons.share,
  //           //             color: Colors.grey[400],
  //           //           ),
  //           //           Padding(
  //           //             padding:
  //           //             EdgeInsets.symmetric(horizontal: 5.0),
  //           //           ),
  //           //         ],
  //           //       ),
  //           //     ),
  //           //   ],
  //           // ),
  //           InkWell(
  //             child: imageProfile,
  //             onTap: (){
  //               Navigator.push(
  //                 context,
  //                 PageTransition(
  //                   duration: const Duration(milliseconds: 1),
  //                   // alignment: Alignment.topRight,
  //                   // type: PageTransitionType.scale,
  //
  //                   // post[index]['title']
  //                   child: UserProfile(
  //                       user: followedUser/*imagePosts[i].user*/
  //                   ),
  //                   // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
  //                   type: null,
  //                 ),
  //                 // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
  //               );
  //             },
  //           ),
  //           SizedBox(height: 10,),
  //           titleText,
  //           // categoryText,
  //         ],
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             // titleText,
  //             commentText,
  //             // imageProfile,
  //             // SizedBox(height: 10,),
  //             // titleText,
  //             // categoryText,
  //
  //             Padding(
  //               padding: const EdgeInsets.only(top: 20.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: <Widget>[
  //                   Container(
  //                     child: Row(
  //                       children: <Widget>[
  //                         Icon(
  //                           Icons.reply,
  //                           color: Colors.grey[400],
  //                         ),
  //                         Padding(
  //                           padding:
  //                           EdgeInsets.symmetric(horizontal: 5.0),
  //                         ),
  //                         Text(
  //                           // Random().nextInt(50).toString(),
  //                           '256',
  //                           style: TextStyle(
  //                             color: Colors.grey[400],
  //                             fontWeight: FontWeight.w700
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     child: Row(
  //                       children: <Widget>[
  //                         Icon(
  //                           Icons.favorite_border,
  //                           color: Colors.grey[400],
  //                         ),
  //                         Padding(
  //                           padding:
  //                           EdgeInsets.symmetric(horizontal: 5.0),
  //                         ),
  //                         Text(
  //                           // Random().nextInt(50).toString(),
  //                           '96',
  //                           style: TextStyle(
  //                             color: Colors.grey[400],
  //                             fontWeight: FontWeight.w700
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     child: Row(
  //                       children: <Widget>[
  //                         Icon(
  //                           Icons.bookmark_border_outlined,
  //                           color: Colors.grey[400],
  //                         ),
  //                         // Padding(
  //                         //   padding:
  //                         //   EdgeInsets.symmetric(horizontal: 5.0),
  //                         // ),
  //                         // Text(
  //                         //   // Random().nextInt(50).toString(),
  //                         //   '25',
  //                         //   style: TextStyle(
  //                         //     color: Colors.grey[400],
  //                         //   ),
  //                         // )
  //                       ],
  //                     ),
  //                   ),
  //                   // Container(
  //                   //   child: Row(
  //                   //     children: <Widget>[
  //                   //       Icon(
  //                   //         Icons.share,
  //                   //         color: Colors.grey[400],
  //                   //       ),
  //                   //       Padding(
  //                   //         padding:
  //                   //         EdgeInsets.symmetric(horizontal: 5.0),
  //                   //       ),
  //                   //     ],
  //                   //   ),
  //                   // ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // List<Widget> _createChildren() {
  //   return List<Widget>.generate(postProvider.postList.length, (int index) {
  //     final item = postProvider.postList[index];
  //     // final pageVisibility = visibilityResolver.resolvePageVisibility(index);
  //
  //     var image = Image.network(
  //       // item.imagePath,
  //       // postProvider.postList[i]['image_video'],
  //       item['profile_image'],
  //       fit: BoxFit.cover,
  //       // alignment: FractionalOffset(
  //       //   0.5 + (pageVisibility.pagePosition / 3),
  //       //   0.5,
  //       // ),
  //     );
  //
  //     var imageOverlayGradient = DecoratedBox(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [
  //             Colors.transparent,
  //             Colors.black,
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     return ClipRRect(
  //       borderRadius: BorderRadius.circular(10.0),
  //       child: Material(
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             image,
  //             imageOverlayGradient,
  //             _buildTextActivitiesContainer(
  //                 context: context,
  //                 item: postProvider.postList[index],
  //                 // pageVisibility: pageVisibility
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }

  Future? order(){
    postProvider.postList.sort((b, a) {
      return a.created_at!.compareTo(b.created_at!);
    });
    return null;
  }

  Future builderaaa () async {
    if(/*Utils.isBusiness*/true) {
      // await geolocationProvider.getGeolocationPermission(context);
      /*(*/await Future.wait([
        // dab = getAllUserPosts(),
        eab = postProvider.getAllBusinessesPosts(context),
      ]);
    // ).then((value) async {
        // print('postProvider.postList.length63333333333333');
        // print(postProvider.postList.length);
        // rab = postProvider.getBusinessPostLikes(postProvider.postList[0]['post_id']);

      if(postProvider.postList.isNotEmpty) {
        await Future.wait([
          rab = postProvider.getBusinessPostLikes(
              postProvider.postList.isNotEmpty ? postProvider.postList[0].id : '',
              postProvider.postList.isNotEmpty ? postProvider.postList[0].business!.id! : ''
          ),
          // bac = postProvider.getAllBusinessPostComments(postProvider.postList[0]['post_id']);
          bac = postProvider.getBusinessPostComments(
            postProvider.postList.isNotEmpty ? postProvider.postList[0].id! : '',
            postProvider.postList.isNotEmpty ? postProvider.postList[0].business!.id! : '',
          ),
          // cab = postProvider.getBusinessPostLikes(postProvider.postList[1]['post_id']);
          // dab = postProvider.getAllBusinessPostComments(postProvider.postList[1]['post_id']);
        ]);
      }
      // postProvider.insertHomeBusinessPosts();
        // postProvider.postList.sort((b, a) {
        //   return a['post_created_at'].compareTo(b['post_created_at']);
        // });

        // print('postProvider.postList6gg6g6g6g6gg63');
        // print(postProvider.postList);
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _tabController = TabController(vsync: this, length: tabs.length);

    // timeago.setLocaleMessages('it', timeago.ItMessages());
    // timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
    // GetTimeAgo.setDefaultLocale('it'); // Sets the default locale to French
    timeAgo.setLocale('it', timeAgo.Italian());
    // timeAgo.setLocale('de_short', timeAgo.Italian(shortForm: true));

    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);

    // userProvider.user = this.widget.user;

    // storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // storyProvider.getAllUserFollowImageStories(this.widget.user.id);
    // a = storyProvider.getAllUserFollowVideoStories(this.widget.user.id);
    // postProvider = Provider.of<PostProvider>(context, listen: false);
    // postProvider.getAllUserFollowPost(this.widget.user.id);
    // postProvider = Provider.of<PostProvider>(context, listen: false);
    // postProvider.getAllFollowSingleEventPost(this.widget.user.id);

    // postProvider.getAllMyDateExperienceReactionEmoji(this.widget.user.id);
    // postProvider.getAllMySingleEventExperienceReactionEmoji(this.widget.user.id);
    // bac = postProvider.getAllFollowSingleEventExperience(this.widget.user.id);

    // postProvider.getAllFollowDatePost(this.widget.user.id);
    // cab = postProvider.getAllFollowDateExperience(this.widget.user.id);
    // rab = postProvider.getAllSubscribedBusinessPosts(this.widget.user.id);
    //
    // postProvider.getAllSubscribedBusinessPost(this.widget.user.id);

    // postProvider.getAllUserPostLikes(this.widget.user.id);
    // postProvider.getAllUserPostFavorites(this.widget.user.id);
    // postProvider.getAllUserSingleEventPostLikes(this.widget.user.id);
    // postProvider.getAllUserDatePostLikes(this.widget.user.id);
    // postProvider.getAllUserPostBusinessLikes(this.widget.user.id);
    // postProvider.getAllReactionEmoji(this.widget.user.id);

    // postProvider.getAllSubscribedBusinessPostComments(this.widget.user.id.toString());

    // chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // socketProvider = Provider.of<SocketProvider>(context, listen: false);

    // var notificationProvider = Provider.of<NotificationProvider>(this.context, listen: false);
    //
    // notificationProvider.initialize();

    // chatProvider.getAllChats(this.widget.user.id);

    // //print("e['post_id']");
    // for(var e in chatProvider.chatList){
    //   //print(e['post_id']);
    //   socketProvider.socket.emit("join-chat", e['post_id']);
    // }

    // postProvider.postProvider.postList.addAll(postProvider.userpostProvider.postList);
    // postProvider.postProvider.postList.addAll(postProvider.businesspostProvider.postList);

    // singleEventPostProvider.getAllUserSingleEventPostFavorites(this.widget.user.id);

    // initializePlayer(
    //   'https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-woman-in-a-pool-1259-large.mp4'
    // );
    cardAspectRatio = 12.0 / 16.0;
    widgetAspectRatio = cardAspectRatio * 1.2;
    // getAllFollowPost();
    // getAllFollowSingleEventPost();

    // getAllFollowImageStory();
    // getAllFollowVideoStory();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   // getAllFollowImageStory().then((value) =>
    //   getAllFollowImageStory().then((value) =>
    //       initializePlayer(
    //         // 'https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-woman-in-a-pool-1259-large.mp4'
    //           value[0]['image_video']
    //       ),
    //   );
    // });

    // ord = order();

    // getAllFollowStory().then((value) =>
    // _videoPlayerController = VideoPlayerController.network('https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-woman-in-a-pool-1259-large.mp4')
    //   ..initialize().then((_) {
    //     setState(() {
    //       _videoPlayerController.play();
    //       _videoPlayerController.setLooping(true);
    //     });
    //   }
    // );
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await getAllFollowPost();
    //   await getAllFollowStory();
    //   await getAllFollowStory().then((value) =>
    //       initializePlayer(
    //         // 'https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-woman-in-a-pool-1259-large.mp4'
    //           value[0]['image_video']
    //       ),
    //   );
    // });
    // initializePlayer0();
    // initializePlayer(
    //   'https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-woman-in-a-pool-1259-large.mp4'
    //     // postProvider.postList[0]
    // );
    controller = PageController(
      //   initialPage: postProvider.postList.length - 1,
        initialPage: 0,
        viewportFraction: 0.85
    );

    storyController = PageController(
        // initialPage: storyList.length - 1,
        initialPage: 0,
        viewportFraction: 0.95,
    );
    // i = postProvider.postList.length - 1;
    currentPage = postProvider.postList.length - 1.0;
    currentStoryPage = storyList.length - 1.0;

    // Future.wait([
      all = builderaaa();
    // ]);

    // //print("e['post_id']33333");
    // for(var e in chatProvider.chatList){
    //   //print(e['post_id']);
    //   chatProvider.socket.emit("join-chat", e['post_id']);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // _tabController.dispose();
    // storyController.dispose();
    // controller.dispose();
    // carouselController0.stopAutoPlay();

    // _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // storyProvider.getAllUserFollowStories(this.widget.user.id);
    // postProvider = Provider.of<PostProvider>(context, listen: false);
    // postProvider = Provider.of<PostProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    // PageController controller = PageController(
    //   initialPage: postProvider.postList.length - 1,
    // );
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      },);
    },);
    //
    // PageController storyController = PageController(
    //   initialPage: storyList.length - 1,
    // );
    storyController.addListener(() {
      setState(() {
        currentStoryPage = storyController.page;
      },);
    },);

    return Scaffold(
      // backgroundColor: Colors.black,
      // backgroundColor: Colors.purple[700],
      // backgroundColor: Colors.transparent,
      // backgroundColor: Colors.grey[100],
      // backgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: NureboAppBar(),
      ),
      // drawer: NureboDrawer(),
      /*appBar: AppBar(
        // floating: true,
        //   backgroundColor: Colors.grey[100],
          backgroundColor: Colors.white,
          // backgroundColor: Colors.transparent,
          // forceElevated: false,
          elevation: 0,
          // snap: true,
          centerTitle: true,
          titleSpacing: 0,
          // shape: ContinuousRectangleBorder(
          //   borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(20),
          //     bottomRight: Radius.circular(20),
          //   ),
          // ),
          leading: GestureDetector(
            child: Container(
              margin: EdgeInsets.only(top: 3, bottom: 3, left: 5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    // color: Colors.red,
                    // child: CircleAvatar(
                    child: Image.network(
                      widget.user.profile_image,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Positioned(
                      top: -1.5,
                      left: 39,
                      child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: Colors.black
                              color: Colors.grey[100]
                          ),
                          child: Center(
                              child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.greenAccent
                                  )
                              )
                          )
                      )
                  ),
                ],
              ),
            ),
            onTap: (){
              Navigator.push(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  type: PageTransitionType.fade,
                  child: MyProfileScreen(
                    user: widget.user,
                  ),
                )
              );
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(*/
      /*left: 10.0*//*),
            child: Text(
              'SocialNetwork',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontSize: 20
                ),
              ),
            ),
          ),
          actions: [
            // IconButton(
            //     onPressed: (){
            //       Navigator.push(
            //           context,
            //           PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: EventRoomScreen(
            //               // user: widget.user,
            //               user: widget.user,
            //             ),
            //           )
            //       );
            //     },
            //     icon: Icon(
            //       // FontAwesome5Brands.telegram_plane,
            //       Icons.people_outline_outlined,
            //       color: Colors.grey[700],
            //       size: 30,
            //     )
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 0, right: 5, bottom: 5),
            //   child: IconButton(
            //       onPressed: (){
            //         Navigator.push(
            //             context,
            //             PageTransition(
            //                 duration: const Duration(milliseconds: 500),
            //                 alignment: Alignment.center,
            //                 type: PageTransitionType.fade,
            //                 // child: SearchScreen()
            //                 child: NotificationScreen()
            //             )
            //         );
            //         // showSearch(
            //         //   context: context,
            //         //   delegate: Search(list: searchList),
            //         // );
            //       },
            //       icon: Icon(
            //         Icons.notifications_none,
            //         // FontAwesome.search,
            //         color: Colors.grey[700],
            //         size: 32,
            //
            //       )
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 5, bottom: 5),
              child: IconButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            child: SearchScreen()
                        )
                    );
                    // showSearch(
                    //   context: context,
                    //   delegate: Search(list: searchList),
                    // );
                  },
                  icon: Icon(
                    // Icons.search_rounded,
                    FontAwesome.search,
                    color: Colors.grey[700],
                    size: 26,

                  )
              ),
            ),
          ]
      ),*/
      // extendBodyBehindAppBar: true,
      // appBar: const PreferredSize(
      //   // preferredSize: Size.fromHeight(100),
      //   preferredSize: Size.fromHeight(55),
      //   // child: AppBar2(user: widget.user,),
      //   // child: AppBar2(
      //   //   user: userProvider.user,
      //   //   // bottomAppbar: TabBar(
      //   //   //   isScrollable: true,
      //   //   //   unselectedLabelColor: Colors.grey[400],
      //   //   //   labelColor: Colors.blue,
      //   //   //   padding: EdgeInsets.all(0),
      //   //   //   indicatorPadding: EdgeInsets.all(0),
      //   //   //   // labelPadding: EdgeInsets.all(0),
      //   //   //   // indicatorSize: TabBarIndicatorSize.tab,
      //   //   //   indicatorSize: TabBarIndicatorSize.label,
      //   //   //   // indicator: BubbleTabIndicator(
      //   //   //   //   indicatorHeight: 30.0,
      //   //   //   //   indicatorColor: Colors.blueAccent,
      //   //   //   //   tabBarIndicatorSize: TabBarIndicatorSize.label,
      //   //   //   //   indicatorRadius: 30,
      //   //   //   //   // insets: EdgeInsets.all(30)
      //   //   //   //   padding: EdgeInsets.all(0),
      //   //   //   //   // Other flags
      //   //   //   //   // indicatorRadius: 1,
      //   //   //   //   // insets: EdgeInsets.all(1),
      //   //   //   //   // padding: EdgeInsets.all(10)
      //   //   //   // ),
      //   //   //   // indicator: DotIndicator(
      //   //   //   //   color: Theme.of(context).primaryColor,
      //   //   //   //   distanceFromCenter: 20,
      //   //   //   //   radius: 3,
      //   //   //   //   paintingStyle: PaintingStyle.fill,
      //   //   //   // ),
      //   //   //   indicator: BoxDecoration(
      //   //   //     borderRadius: BorderRadius.circular(50),
      //   //   //     color: Colors.white,
      //   //   //   ),
      //   //   //   // unselectedLabelColor: kFontColorPallets[1],
      //   //   //   // labelColor: Theme.of(context).primaryColor,
      //   //   //   // isScrollable: true,
      //   //   //   tabs: tabs,
      //   //   //   controller: _tabController,
      //   //   // ),
      //   // ),
      // ),
      // drawer: MyDrawer(),
      // onDrawerChanged: (value){
      //   // if(Utils.isSocial){
      //     //todo: false per nascondere bottombar
      //     //print(value);
      //     socketProvider.setBottomBarVisibility(!value);
      //   // }
      // },
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Visibility(
                    // visible: !Utils.isBusiness,
                    visible: Utils.isSocial,
                    child: Padding(
                      padding: const EdgeInsets.only(top: /*16*/5.0, left: 35, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Text(
                          //   // 'Racconti',
                          //   'Pensieri',
                          //   style: TextStyle(
                          //     color: Colors.blue[500],
                          //     // color: Colors.grey[600],
                          //     fontWeight: FontWeight.w800,
                          //     fontSize: 20,
                          //   ),
                          // ),
                          OutlinedButton(
                            style: ButtonStyle(
                              // backgroundColor: MaterialStateProperty.all(Colors.blue),

                              // elevation:,
                            ),
                            // OutlineButton(
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.all(Radius.circular(4))
                            // ),
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: PostExperienceScreen()
                                  )
                              );
                            },
                            child: Text(
                              'Crea un Esperienza',
                              // 'Crea un Post',
                              style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  FutureBuilder(
                    // future: Future.wait([/*cab,*/ rab, bac, /*dab,*/ eab]),
                    // future: Future.wait([all]),
                    future: all,
                    builder: (context, snapshot) {
                      if(/*snapshot.connectionState == ConnectionState.done &&*/ postProvider.postList.length > 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: SizedBox.fromSize(
                            size: Size.fromHeight(
                                // 500.0
                                //   MediaQuery.of(context).size.height * 0.735
                                MediaQuery.of(context).size.height * 0.75),
                            child: PageTransformer(
                              pageViewBuilder: (context, visibilityResolver) {
                                // bool isLikedPost = false;

                                return PageView.builder(
                                  scrollDirection: Axis.vertical,
                                  onPageChanged: (index) async {
                                    // print(postProvider.postList[index]['post_id']);
                                    // print(postProvider.postList[index].id);
                                    //print(index);
                                    setState(() {
                                      isContainerVisible = true;
                                      isStoryFilterVisible = true;
                                      postProvider.isLikedPost = false;
                                    });

                                    // if(postProvider.postList[index].is_admin == 0) {
                                    //   await Future.wait([
                                    //     // postProvider.getBookingPostComments(postProvider.postList[index]['post_id']),
                                    //     postProvider.getBookingPostComments(postProvider.postList[index].id),
                                    //     postProvider.getBookingPostLikes(postProvider.postList[index].id),
                                    //   ]);
                                    //
                                    //   // setState(() {
                                    //   //   isLikedPost = false;
                                    //   // });
                                    //   // for (var like in bookingPostLikes) {
                                    //   //   // //print('like gggyg');
                                    //   //   //print(like);
                                    //   //   //print(like['user_id'] == userProvider.user.id);
                                    //   //   if (like['post_id'] == singleEventPost.id) {
                                    //   //   if (like['user_id'] == userProvider.user.id) {
                                    //   //     setState(() {
                                    //   //       isLikedPost = true;
                                    //   //     });
                                    //   //   }
                                    //   // }
                                    //   //print('isLikedPost2222');
                                    //   //print(isLikedPost);
                                    //
                                    // }
                                    // else if(postProvider.postList[index].is_admin == 1) {
                                    await Future.wait([
                                      // postProvider.getAllBusinessPostComments(postProvider.postList[index]['post_id']),
                                      postProvider.getBusinessPostComments(postProvider.postList[index].id!, postProvider.postList[index].business!.id!),
                                      postProvider.getBusinessPostLikes(postProvider.postList[index].id, postProvider.postList[index].business!.id!),
                                    ]);

                                    // if(index + 1 < postProvider.postList.length){
                                    //   postProvider.getBusinessPostLikes(postProvider.postList[index+1]['post_id']);
                                    //   postProvider.getAllBusinessPostComments(postProvider.postList[index+1]['post_id']);
                                    // }

                                    // postComments!.clear();
                                    // businessPostLikes.clear();
                                    // }
                                    // await getPostBookingPostComments(postProvider.postList[index]['post_id']);
                                    // await getPostBookingPostLikes(postProvider.postList[index]['post_id']);
                                  },
                                  // controller: PageController(
                                  //     viewportFraction: 0.85,
                                  // ),
                                  // itemCount: storyList.length,
                                  // itemCount: storyProvider.stories.length,
                                  itemCount: postProvider.postList.length,
                                  itemBuilder: (context, index) {
                                    // final item = storyList[index];
                                    // final item = storyProvider.stories[index];
                                    final item = postProvider.postList[index];
                                    final pageVisibility = visibilityResolver.resolvePageVisibility(index);
                                    // int bookingPostCommentNumber = 0;

                                    // print("6bh5h5h5hhh6");
                                    // print(item['post_image_url']);

                                    // if(item.is_admin == 0){
                                    //   // var image = Image.asset(
                                    //   var image = Image.network(
                                    //     // var image = FutureImage(
                                    //     // item.imagePath,
                                    //     // postProvider.postList[index]['image_video'],
                                    //     item.image_url!,
                                    //     // "https://images.pexels.com/photos/3998404/pexels-photo-3998404.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                    //     fit: BoxFit.cover,
                                    //     alignment: FractionalOffset(
                                    //       0.5 + (pageVisibility.pagePosition / 3),
                                    //       0.5,
                                    //     ),
                                    //     // width: MediaQuery.of(context).size.width,
                                    //   );
                                    //
                                    //   var imageOverlayGradient = DecoratedBox(
                                    //     decoration: BoxDecoration(
                                    //       gradient: LinearGradient(
                                    //         begin: Alignment.topCenter,
                                    //         end: Alignment.bottomCenter,
                                    //         colors: [
                                    //           // MyColors.black,
                                    //           // Colors.transparent,
                                    //           Colors.transparent,
                                    //           Colors.black,
                                    //           // MyColors.black,
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   );
                                    //
                                    //   // Container(
                                    //   //   padding: EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                                    //   //   child: Row(
                                    //   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   //     children: <Widget>[
                                    //   //       Row(
                                    //   //         children: <Widget>[
                                    //   //           ClipRRect(
                                    //   //             borderRadius: BorderRadius.circular(8),
                                    //   //             child: Image(
                                    //   //               // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                    //   //               image: CachedNetworkImageProvider(
                                    //   //                 postProvider.postList[index]['profile_image'],
                                    //   //               ),
                                    //   //               width: 41,
                                    //   //               height: 41,
                                    //   //               fit: BoxFit.cover,
                                    //   //             ),
                                    //   //           ),
                                    //   //           SizedBox(
                                    //   //             width: 10,
                                    //   //           ),
                                    //   //           Text(
                                    //   //             '@' + postProvider.postList[index]['user_username'],
                                    //   //             style: TextStyle(
                                    //   //               fontWeight: FontWeight.w700,
                                    //   //               fontSize: 18,
                                    //   //               // color: Colors.white
                                    //   //
                                    //   //             ),
                                    //   //           ),
                                    //   //         ],
                                    //   //       ),
                                    //   //       IconButton(
                                    //   //         icon: Icon(
                                    //   //           SimpleLineIcons.options,
                                    //   //           size: 17,
                                    //   //           // color: Colors.white,
                                    //   //         ),
                                    //   //         onPressed: () {
                                    //   //           // _bottomSheetOptions(context);
                                    //   //         },
                                    //   //       ),
                                    //   //     ],
                                    //   //   ),
                                    //   // ),
                                    //   return Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //       vertical: 5.0,
                                    //       horizontal: 25.0,
                                    //     ),
                                    //     child: ClipRRect(
                                    //       borderRadius: BorderRadius.circular(10.0),
                                    //       child: Material(
                                    //         child: Stack(
                                    //           fit: StackFit.expand,
                                    //           children: [
                                    //             image,
                                    //             Visibility(
                                    //               visible: isStoryFilterVisible,
                                    //               child: imageOverlayGradient,
                                    //             ),
                                    //             GestureDetector(
                                    //               onTap: (){
                                    //                 setState(() {
                                    //                   isStoryFilterVisible = !isStoryFilterVisible;
                                    //                 });
                                    //               },
                                    //               // onLongPress: (){
                                    //               //   setState(() {
                                    //               //     isStoryFilterVisible = !isStoryFilterVisible;
                                    //               //   });
                                    //               // },
                                    //               // onForcePressStart: (forcePressDetails){
                                    //               //   // forcePressDetails.pressure
                                    //               //   setState(() {
                                    //               //     isStoryFilterVisible = !isStoryFilterVisible;
                                    //               //   });
                                    //               // },
                                    //               // onForcePressEnd: (forcePressDetails){
                                    //               //   setState(() {
                                    //               //     isStoryFilterVisible = !isStoryFilterVisible;
                                    //               //   });
                                    //               // },
                                    //               onDoubleTap: (){
                                    //                 //TODO: VAI ALLO SCREEN DEL POST
                                    //               },
                                    //             ),
                                    //             Visibility(
                                    //               child: _buildBottomTextBookingPost(
                                    //                   context,
                                    //                   // storyList[index],
                                    //                   // storyProvider.stories[index],
                                    //                   postProvider.postList[index],
                                    //                   pageVisibility,
                                    //                   index
                                    //               ),
                                    //               visible: isStoryFilterVisible,
                                    //             ),
                                    //             Visibility(
                                    //               visible: isStoryFilterVisible && isContainerVisible,
                                    //               // child: _buildSidebarBookingPost(
                                    //               //     context,
                                    //               //     // storyList[index],
                                    //               //     // storyProvider.stories[index],
                                    //               //     postProvider.postList[index],                                                    pageVisibility,
                                    //               //     index
                                    //               // ),
                                    //               child: Row(
                                    //                 mainAxisAlignment: MainAxisAlignment.end,
                                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                                    //                 children: [
                                    //                   // InkWell(
                                    //                   //   onTap: (){
                                    //                   //     Navigator.push(
                                    //                   //       context,
                                    //                   //       PageTransition(
                                    //                   //         duration: const Duration(milliseconds: 1),
                                    //                   //         // alignment: Alignment.topRight,
                                    //                   //         // type: PageTransitionType.scale,
                                    //                   //
                                    //                   //         // post[index]['title']
                                    //                   //         child: UserProfileScreen(
                                    //                   //           // myUser: widget.user,
                                    //                   //             user: followedUser/*imagePosts[i].user*/
                                    //                   //         ),
                                    //                   //         // child: UserProfile(user: /*imagePosts[i].user*/post[i]['post_id']),
                                    //                   //         type: null,
                                    //                   //       ),
                                    //                   //       // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
                                    //                   //     );
                                    //                   //   },
                                    //                   //   child: Column(
                                    //                   //     mainAxisAlignment: MainAxisAlignment.center,
                                    //                   //     crossAxisAlignment: CrossAxisAlignment.center,
                                    //                   //     children: [
                                    //                   //       // titleText,
                                    //                   //       // commentText,
                                    //                   //       imageProfile,
                                    //                   //
                                    //                   //       SizedBox(height: 10,),
                                    //                   //       usernameText,
                                    //                   //
                                    //                   //       // Row(
                                    //                   //       //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    //                   //       //   children: <Widget>[
                                    //                   //       //     Container(
                                    //                   //       //       child: Row(
                                    //                   //       //         children: <Widget>[
                                    //                   //       //           Icon(
                                    //                   //       //             Icons.reply,
                                    //                   //       //             color: Colors.grey[400],
                                    //                   //       //           ),
                                    //                   //       //           Padding(
                                    //                   //       //             padding:
                                    //                   //       //             EdgeInsets.symmetric(horizontal: 5.0),
                                    //                   //       //           ),
                                    //                   //       //           Text(
                                    //                   //       //             Random().nextInt(50).toString(),
                                    //                   //       //             style: TextStyle(
                                    //                   //       //               color: Colors.grey[400],
                                    //                   //       //             ),
                                    //                   //       //           )
                                    //                   //       //         ],
                                    //                   //       //       ),
                                    //                   //       //     ),
                                    //                   //       //     Container(
                                    //                   //       //       child: Row(
                                    //                   //       //         children: <Widget>[
                                    //                   //       //           Icon(
                                    //                   //       //             Icons.repeat,
                                    //                   //       //             color: Colors.grey[400],
                                    //                   //       //           ),
                                    //                   //       //           Padding(
                                    //                   //       //             padding:
                                    //                   //       //             EdgeInsets.symmetric(horizontal: 5.0),
                                    //                   //       //           ),
                                    //                   //       //           Text(
                                    //                   //       //             Random().nextInt(50).toString(),
                                    //                   //       //             style: TextStyle(
                                    //                   //       //               color: Colors.grey[400],
                                    //                   //       //             ),
                                    //                   //       //           )
                                    //                   //       //         ],
                                    //                   //       //       ),
                                    //                   //       //     ),
                                    //                   //       //     Container(
                                    //                   //       //       child: Row(
                                    //                   //       //         children: <Widget>[
                                    //                   //       //           Icon(
                                    //                   //       //             Icons.favorite_border,
                                    //                   //       //             color: Colors.grey[400],
                                    //                   //       //           ),
                                    //                   //       //           Padding(
                                    //                   //       //             padding:
                                    //                   //       //             EdgeInsets.symmetric(horizontal: 5.0),
                                    //                   //       //           ),
                                    //                   //       //           Text(
                                    //                   //       //             Random().nextInt(50).toString(),
                                    //                   //       //             style: TextStyle(
                                    //                   //       //               color: Colors.grey[400],
                                    //                   //       //             ),
                                    //                   //       //           )
                                    //                   //       //         ],
                                    //                   //       //       ),
                                    //                   //       //     ),
                                    //                   //       //     Container(
                                    //                   //       //       child: Row(
                                    //                   //       //         children: <Widget>[
                                    //                   //       //           Icon(
                                    //                   //       //             Icons.share,
                                    //                   //       //             color: Colors.grey[400],
                                    //                   //       //           ),
                                    //                   //       //           Padding(
                                    //                   //       //             padding:
                                    //                   //       //             EdgeInsets.symmetric(horizontal: 5.0),
                                    //                   //       //           ),
                                    //                   //       //         ],
                                    //                   //       //       ),
                                    //                   //       //     ),
                                    //                   //       //   ],
                                    //                   //       // ),
                                    //                   //     ],
                                    //                   //   ),
                                    //                   // ),
                                    //                   Padding(
                                    //                     padding: const EdgeInsets.only(top: 80.0),
                                    //                     child: ClipRRect(
                                    //                       borderRadius: BorderRadius.circular(5),
                                    //                       child: BackdropFilter(
                                    //                         filter: ImageFilter.blur(
                                    //                             sigmaY: 30,
                                    //                             sigmaX: 30
                                    //                         ),
                                    //                         child: Padding(
                                    //                           padding: EdgeInsets.only(top: 15, bottom: 15),
                                    //                           child: Container(
                                    //                             width: 50,
                                    //                             height: 190,
                                    //                             child: Column(
                                    //                               children: [
                                    //                                 InkWell(
                                    //                                   onTap: () {
                                    //                                     //print('isLikedPost');
                                    //                                     //print(isLikedPost);
                                    //                                     //print('review');
                                    //                                     //print('andare in una listview in cui ci sono tutte le recensioni di quella prestazione');
                                    //                                   },
                                    //                                   child: Padding(
                                    //                                     padding: const EdgeInsets.only(bottom: 11.0, top: 6, left: 6, right: 6),
                                    //                                     child: Column(
                                    //                                       children: [
                                    //                                         Icon(
                                    //                                           Icons.star,
                                    //                                           // color: Colors.grey[50],
                                    //                                           color: Colors.yellow[500],
                                    //                                           size: 25,
                                    //                                         ),
                                    //                                         SizedBox(height: 5,),
                                    //                                         Text(
                                    //                                             // (item['vote'] ?? 0)?.toDouble().toString(),
                                    //                                             (item.vote ?? 0)?.toDouble().toString(),
                                    //                                             overflow: TextOverflow.ellipsis,
                                    //                                             style: GoogleFonts.lato(
                                    //                                               fontWeight: FontWeight.w700,
                                    //                                               // color: Colors.grey[50],
                                    //                                               color: Colors.yellow[500],
                                    //                                               fontSize: 12,
                                    //                                             )
                                    //                                         )
                                    //                                       ],
                                    //                                     ),
                                    //                                   ),
                                    //                                 ),
                                    //                                 InkWell(
                                    //                                   onTap: () async {
                                    //                                     //print('isLikedPost 55555');
                                    //                                     //print(isLikedPost);
                                    //                                     //print(item['post_id']);
                                    //                                     //print(userProvider.user!.id);
                                    //                                     if (postProvider.isLikedPost){
                                    //                                       setState(() {
                                    //                                         /*await*/ postProvider.unlikeBookingPost(
                                    //                                           // singleEventPost.id,
                                    //                                           //   item['post_id'],
                                    //                                             item,
                                    //                                             userProvider.user!
                                    //                                         );
                                    //                                       });
                                    //                                     }
                                    //                                     else{
                                    //                                       setState(() {
                                    //                                         /*await*/ postProvider.likeBookingPost(
                                    //                                           // singleEventPost.id,
                                    //                                           //   item['post_id'],
                                    //                                             item,
                                    //                                             userProvider.user!
                                    //                                         );
                                    //                                       });
                                    //                                     }
                                    //                                   },
                                    //                                   child: Padding(
                                    //                                     padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
                                    //                                     child: Column(
                                    //                                       children: [
                                    //                                         Icon(
                                    //                                           // Icons.reply,
                                    //                                           postProvider.isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                    //                                           color: postProvider.isLikedPost ? Colors.red : Colors.grey[50],
                                    //                                           // color: Colors.red[500],
                                    //                                           // color: Colors.pink[300],
                                    //                                           size: 25,
                                    //                                         ),
                                    //                                         SizedBox(height: 5,),
                                    //                                         Text(
                                    //                                           // '27',
                                    //                                             postProvider.postLikes.length.toString(),
                                    //                                             overflow: TextOverflow.ellipsis,
                                    //                                             style: GoogleFonts.lato(
                                    //                                               fontWeight: FontWeight.w700,
                                    //                                               color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                    //                                               // color: Colors.red[500],
                                    //                                               // color: Colors.pink[300],
                                    //                                               fontSize: 12,
                                    //                                             )
                                    //                                         )
                                    //                                       ],
                                    //                                     ),
                                    //                                   ),
                                    //                                 ),
                                    //                                 InkWell(
                                    //                                   onTap: () {
                                    //                                     //print('comments');
                                    //                                     Navigator.push(
                                    //                                         context,
                                    //                                         PageTransition(
                                    //                                           duration: const Duration(
                                    //                                               milliseconds: 500
                                    //                                           ),
                                    //                                           alignment: Alignment.center,
                                    //                                           type: PageTransitionType.fade,
                                    //                                           child: PostCommentsScreen(
                                    //                                             isSingleEventPost: false,
                                    //                                             myUser: userProvider.user,
                                    //                                             post: Post(
                                    //                                               // id: item['post_id'],
                                    //                                               id: item.id,
                                    //                                             ),
                                    //                                           ),
                                    //                                         )
                                    //                                     );
                                    //                                   },
                                    //                                   child: Padding(
                                    //                                     padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
                                    //                                     child: Column(
                                    //                                       children: [
                                    //                                         Icon(
                                    //                                           // Icons.mode_comment_outlined,
                                    //                                           Icons.sms_outlined,
                                    //                                           color: Colors.grey[50],
                                    //                                           // color: Colors.blue[400],
                                    //                                           size: 25,
                                    //                                         ),
                                    //                                         SizedBox(height: 5,),
                                    //                                         Text(
                                    //                                           // '320',
                                    //                                           // bookingPostCommentNumber.toString(),
                                    //                                             postProvider.postComments!.length.toString(),
                                    //                                             overflow: TextOverflow.ellipsis,
                                    //                                             style: GoogleFonts.lato(
                                    //                                               fontWeight: FontWeight.w700,
                                    //                                               color: Colors.white,
                                    //                                               fontSize: 12,
                                    //                                             )
                                    //                                         )
                                    //                                       ],
                                    //                                     ),
                                    //                                   ),
                                    //                                 ),
                                    //                               ],
                                    //                             ),
                                    //                           ),
                                    //                           // child: Text(
                                    //                           //   // categories[i].name,
                                    //                           //   'category.name',
                                    //                           //   overflow: TextOverflow.ellipsis,
                                    //                           //   style: GoogleFonts.lato(
                                    //                           //     fontWeight: FontWeight.w700,
                                    //                           //     color: Colors.white,
                                    //                           //     fontSize: 15,
                                    //                         ),
                                    //                       ),
                                    //                     ),
                                    //                   ),
                                    //                   SizedBox(width: 15,)
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   );
                                    // }
                                    // else if(item.is_admin == 1) {
                                    // var image = Image.asset(
                                    // var image = Image.network(

                                    var image = FutureImage(
                                      // item.imagePath,
                                      // postProvider.postList[index]['image_video'],
                                      // item['post_image_url'],
                                      item.image_url!,
                                      // "https://images.pexels.com/photos/3998404/pexels-photo-3998404.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                      // fit: BoxFit.cover,
                                      // alignment: FractionalOffset(
                                      //   0.5 + (pageVisibility.pagePosition / 3),
                                      //   0.5,
                                      // ),
                                      width: MediaQuery.of(context).size.width,
                                    );

                                    // var image = Image.memory(
                                    //   imageCacheBusiness.imageCache[item.image_url!]!,
                                    //   fit: BoxFit.cover,
                                    //   errorBuilder: (context, url, error) => Container(
                                    //     width: MediaQuery.of(context).size.width,
                                    //     height: MediaQuery.of(context).size.height,
                                    //     color: Colors.transparent,
                                    //   ),
                                    //   gaplessPlayback: true,
                                    //   isAntiAlias: true,
                                    // );

                                    var imageOverlayGradient = DecoratedBox(
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
                                    );

                                    // Container(
                                    //   padding: EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //     children: <Widget>[
                                    //       Row(
                                    //         children: <Widget>[
                                    //           ClipRRect(
                                    //             borderRadius: BorderRadius.circular(8),
                                    //             child: Image(
                                    //               // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                    //               image: CachedNetworkImageProvider(
                                    //                 postProvider.postList[index]['profile_image'],
                                    //               ),
                                    //               width: 41,
                                    //               height: 41,
                                    //               fit: BoxFit.cover,
                                    //             ),
                                    //           ),
                                    //           SizedBox(
                                    //             width: 10,
                                    //           ),
                                    //           Text(
                                    //             '@' + postProvider.postList[index]['user_username'],
                                    //             style: TextStyle(
                                    //               fontWeight: FontWeight.w700,
                                    //               fontSize: 18,
                                    //               // color: Colors.white
                                    //
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //       IconButton(
                                    //         icon: Icon(
                                    //           SimpleLineIcons.options,
                                    //           size: 17,
                                    //           // color: Colors.white,
                                    //         ),
                                    //         onPressed: () {
                                    //           // _bottomSheetOptions(context);
                                    //         },
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        horizontal: 25.0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Material(
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              image,
                                              Visibility(
                                                visible:
                                                    isStoryFilterVisible,
                                                child: imageOverlayGradient,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  // setState(() {
                                                  //   isStoryFilterVisible = !isStoryFilterVisible;
                                                  // });
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          alignment:
                                                              Alignment
                                                                  .center,
                                                          type:
                                                              PageTransitionType
                                                                  .fade,
                                                          child:
                                                              PostFullScreen(
                                                            // memoryImage: imageCacheBusiness.getImageFromCache(item.image_url!)!,
                                                            businessPost:
                                                                item,
                                                            isNetworkLoaded:
                                                                false,
                                                          )));
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
                                              // Visibility(
                                              //   child: _buildTextStoryContainer(
                                              //       context,
                                              //       // storyList[index],
                                              //       // storyProvider.stories[index],
                                              //       postProvider.postList[index],
                                              //       pageVisibility,
                                              //       index
                                              //   ),
                                              //   visible: isStoryFilterVisible,
                                              // ),
                                              Visibility(
                                                visible:
                                                    isStoryFilterVisible &&
                                                        isContainerVisible,
                                                // child: _buildSidebarBookingPost(
                                                //     context,
                                                //     // storyList[index],
                                                //     // storyProvider.stories[index],
                                                //     postProvider.postList[index],
                                                //     pageVisibility,
                                                //     index
                                                // ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
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
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 80.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    5),
                                                        child:
                                                            BackdropFilter(
                                                          filter: ImageFilter
                                                              .blur(
                                                                  sigmaY:
                                                                      30,
                                                                  sigmaX:
                                                                      30),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .only(
                                                                    top: 15,
                                                                    bottom:
                                                                        15),
                                                            child:
                                                                Container(
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
                                                                    highlightColor: Colors.transparent,
                                                                    splashColor: Colors.transparent,
                                                                    onTap: () async {
                                                                      // print(
                                                                      //     "bb7bn7npostProvider.postList[index]['post_id']");
                                                                      // print(postProvider
                                                                      //     .postList[index]
                                                                      //     .id);
                                                                      if (postProvider
                                                                          .isLikedPost) {
                                                                        setState(() {
                                                                          /*await*/ postProvider.unlikeBusinessPost(
                                                                              // singleEventPost.id,
                                                                              //   item['post_id'],
                                                                              //   postProvider.postList[index]['post_id'],
                                                                              postProvider.postList[index],
                                                                              userProvider.user!
                                                                          );
                                                                        });
                                                                      } else {
                                                                        setState(() {
                                                                          /*await*/ postProvider.likeBusinessPost(
                                                                              // singleEventPost.id,
                                                                              //   item['post_id'],
                                                                              //   postProvider.postList[index]['post_id'],
                                                                              postProvider.postList[index],
                                                                              userProvider.user!);
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom: 11.0,
                                                                          top: 11,
                                                                          left: 6,
                                                                          right: 6),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Icon(
                                                                            // Icons.reply,
                                                                            postProvider.isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                                                            color: postProvider.isLikedPost ? Colors.red : Colors.grey[50],
                                                                            // color: Colors.red[500],
                                                                            // color: Colors.pink[300],
                                                                            size: 25,
                                                                          ),
                                                                          SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          Text(
                                                                              // '27',
                                                                              /*postLikes*/
                                                                              postProvider.postLikes.length.toString(),
                                                                              // item.likes?.length.toString() ?? '0',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: GoogleFonts.lato(
                                                                                fontWeight: FontWeight.w700,
                                                                                color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                                                                // color: Colors.red[500],
                                                                                // color: Colors.pink[300],
                                                                                fontSize: 12,
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    highlightColor: Colors.transparent,
                                                                    splashColor: Colors.transparent,
                                                                    onTap: () {
                                                                      //print('comments');
                                                                      Navigator.push(
                                                                          context,
                                                                          PageTransition(
                                                                            duration: const Duration(milliseconds: 500),
                                                                            alignment: Alignment.center,
                                                                            type: PageTransitionType.fade,
                                                                            child: PostCommentsScreen(
                                                                              isSingleEventPost: false,
                                                                              myUser: userProvider.user,
                                                                              businessPost: BusinessPost(
                                                                                id: item.id,
                                                                                comments: postProvider.postComments,
                                                                                business: postProvider.postList[index].business,
                                                                                description: postProvider.postList[index].description,
                                                                                prestazione: postProvider.postList[index].prestazione,
                                                                                image_url: postProvider.postList[index].image_url,
                                                                                user: postProvider.postList[index].user,
                                                                                created_at: postProvider.postList[index].created_at,
                                                                                likes: postProvider.postLikes
                                                                              ),
                                                                            ),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom: 6,
                                                                          top: 11,
                                                                          left: 6,
                                                                          right: 6),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Icon(
                                                                            // Icons.mode_comment_outlined,
                                                                            Icons.sms_outlined,
                                                                            color: Colors.grey[50],
                                                                            // color: Colors.blue[400],
                                                                            size: 25,
                                                                          ),
                                                                          SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          Text(
                                                                              // '320',
                                                                              // bookingPostCommentNumber.toString(),
                                                                              postProvider.postComments.length.toString(),
                                                                              // item.comments?.length.toString() ?? '0',
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
                                                    SizedBox(
                                                      width: 15,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: isStoryFilterVisible,
                                                child: _buildBottomTextBusinessPost(
                                                    context,
                                                    // storyList[index],
                                                    // storyProvider.stories[index],
                                                    // List.from(postProvider.postList)[index],
                                                    postProvider.postList[index],
                                                    pageVisibility,
                                                    index
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    // }
                                    // else {
                                    //   return SizedBox();
                                    // }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      }
                      if(/*snapshot.connectionState == ConnectionState.done &&*/ postProvider.postList.length == 0){
                        return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * .1,),
                            Center(
                              child: Image.asset(
                                'assets/png/Saly-42.png',
                                height: MediaQuery.of(context).size.height * .35,
                                // width: MediaQuery.of(context).size.width * .4,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * .05,),
                            Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * .8,
                                child: Text(
                                  'Aggiungi degli amici o segui dei locali per vedere i post',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    // color: Colors.blue,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      else {
                        return SizedBox();
                      }
                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  getImageWidthHeight(String imageUrl) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    // final String url = imageUrl;
    Image image = Image.network(imageUrl);
    int? heightImage;
    int? widthImage;

    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      // //print(info.image.width);
      // //print(info.image.height);
      // setState(() {
      heightImage = info.image.height;
      widthImage = info.image.width;
      // });
      completer.complete(info.image);
    }));

    return heightImage; widthImage;
  }

  // bottomSheetOptions(BuildContext context, Experience experience) {
  //   showModalBottomSheet<int>(
  //     backgroundColor: Colors.transparent,
  //     context: context,
  //     builder: (context) {
  //       return Popover(
  //         child: Column(
  //           children: [
  //             // SettingsTile.switchTile(
  //             //   title: 'Lock app in background',
  //             //   leading: Icon(Icons.phonelink_lock),
  //             //   switchValue: lockInBackground,
  //             //   onToggle: (bool value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       notificationsEnabled = value;
  //             //     });
  //             //   },
  //             // ),
  //             // SwitchListTile(
  //             //   // contentPadding: EdgeInsets.all(15),
  //             //   title: Text("Gluten Free",style: TextStyle(
  //             //       color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,
  //             //       fontSize: 20
  //             //   ),
  //             //   ),
  //             //   subtitle: Text("Includes Only Gluten Free Dishes"),
  //             //   value: filterValues["gluten"], onChanged: (value) {
  //             //   setState(() {
  //             //     filterValues["gluten"]=value;
  //             //   });
  //             // },),
  //             GestureDetector(
  //               onTap: (){
  //                 //print("Copia link");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Copia link"),
  //                   leading: Icon(Icons.attach_file_outlined),
  //                 ),
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: (){
  //                 //print("Condividi");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Condividi"),
  //                   leading: Icon(Icons.send_outlined),
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               onTap: (){
  //                 //print("Elimina reazione");
  //                 Navigator.of(context).pop();
  //                 // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
  //                 // btn2(context);
  //                 if(!experience.isDateExperience){
  //                   postProvider.deleteSingleEventExperienceReaction(
  //                     experience.reaction_emoji_experience,
  //                     userProvider.user.id
  //                   );
  //                 }
  //                 else if(experience.isDateExperience){
  //                   postProvider.deleteDateExperienceReaction(
  //                     experience.reaction_emoji_experience,
  //                     userProvider.user.id
  //                   );
  //                 }
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Elimina reazione"),
  //                   leading: Icon(Icons.circle_outlined),
  //                 ),
  //               ),
  //             ),
  //             // btn1(context),
  //             GestureDetector(
  //               onTap: (){
  //                 //print("Segnala");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Segnala"),
  //                   leading: Icon(Icons.warning_amber_outlined),
  //                 ),
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: (){
  //                 //print("Non seguire più");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Non seguire più"),
  //                   leading: Icon(Icons.person_remove_alt_1_outlined),
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               onTap: (){
  //                 //print("Blocca utente");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Blocca utente"),
  //                   leading: Icon(Icons.block),
  //                 ),
  //               ),
  //             ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Silenzia',
  //             //   enabled: true,
  //             //
  //             //   leading: Icon(Icons.airline_seat_individual_suite_outlined),
  //             //   switchValue: false,
  //             //   onToggle: (value) {
  //             //     setState(() {
  //             //       // lockInBackground = value;
  //             //       // notificationsEnabled = value;
  //             //     });
  //             //     value = true;
  //             //   },
  //             // ),
  //
  //             // GestureDetector(
  //             //   onTap: (){
  //             //
  //             //   },
  //             //   child: Container(
  //             //     child: ListTile(
  //             //       title: Text("Limita"),
  //             //       leading: Icon(Icons.account_box_outlined),
  //             //     ),
  //             //   ),
  //             // ),
  //             // GestureDetector(
  //             //   onTap: (){
  //             //
  //             //   },
  //             //   child: Container(
  //             //     child: ListTile(
  //             //       title: Text("Blocca"),
  //             //       leading: Icon(Icons.admin_panel_settings_outlined),
  //             //     ),
  //             //   ),
  //             // ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Notifiche',
  //             //   enabled: true,
  //             //
  //             //   leading: Icon(Icons.notifications_active_outlined),
  //             //   switchValue: false,
  //             //   onToggle: (value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       notificationsEnabled = value;
  //             //     });
  //             //     value = true;
  //             //   },
  //             //
  //             // ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Post',
  //             //   leading: Icon(Icons.panorama_outlined),
  //             //   switchValue: lockInBackground,
  //             //   onToggle: (bool value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       // notificationsEnabled = value;
  //             //     });
  //             //   },
  //             // ),
  //             // SettingsTile.switchTile(
  //             //     title: 'Storie',
  //             //     // subtitle: 'Allow application to access stored fingerprint IDs.',
  //             //     leading: Icon(Icons.all_inclusive_outlined),
  //             //     onToggle: (bool value) {},
  //             //     switchValue: false
  //             // ),
  //             // SwitchListTile(
  //             //   value: true,
  //             //   // value: context.watch<PostCreateViewModel>().isShareFacebook,
  //             //   onChanged: (value) {
  //             //     if(value == true)
  //             //       value = false;
  //             //     else value = true;
  //             //     // context.read<PostCreateViewModel>().enableSocialShare(SocialShare.FACEBOOK, value);
  //             //   },
  //             //   title: Text('Facebook'),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Total Task'),
  //             //   leading: Icon(
  //             //     Icons.check_circle_outline,
  //             //     color: Colors.black,
  //             //   ),
  //             //   trailing: Switch(
  //             //     value: true,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Due Soon'),
  //             //   leading: Icon(Icons.inbox),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Completed'),
  //             //   leading: Icon(Icons.check_circle),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Working On'),
  //             //   leading: Icon(Icons.flag),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
