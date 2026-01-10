import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:badges/badges.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/comment_card.dart';
import 'package:nurebo/widgets/extensions.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
// import 'package:settings_ui/settings_ui.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';


class PostCommentsScreen extends StatefulWidget {
  // final email;
  // final username;
  // final id;
  // final User user;
  final User? myUser;
  final Post? post;
  final BusinessPost? businessPost;
  final bool? isSingleEventPost;
  // VideoPlayerController _controller;
  // Future<void> _initializeVideoPlayerFuture;
  // TabController _tabController;
  // ScrollController _scrollController;
  // List postList = [];
  // final int height;
  // final int width;
  // final bool isLikedPost;
  // final bool isFavoritedPost;

  const PostCommentsScreen({super.key,this.post, this.myUser, this.isSingleEventPost, this.businessPost});

  @override
  _PostCommentsScreenState createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  TextEditingController commentController = TextEditingController();
  Future cab = Future(() {},), rebb = Future(() {},);
  // List? postProvider.comments = [];
  late PostProvider postProvider;
  bool isOptionsVisible = false;


  @override
  void initState() {
    super.initState();
    postProvider = Provider.of<PostProvider>(context, listen: false);
    // print("widget.businessPost!.id998989");
    // print(widget.businessPost!.id);

    // if(widget.businessPost != null){
    //   cab = postProvider.getBusinessPostComments(widget.businessPost!.id!);
    // }
    // else{
    //   if(widget.isSingleEventPost!) {
    //     postProvider.getAllSingleEventPostComments(widget.post!.id!);
    //   } else {
    //     postProvider.getAllBookingPostComments(widget.post!.id!);
    //   }
    //   // getAllPostComments();
    // }

  }

  @override
  Widget build(BuildContext context) {
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        // backgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.blue,
          // size: 36,
        ),
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
            size: 16,
            // size: 20,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        // foregroundColor: Colors.blue,
        // title: Text(
        //   widget.businessPost != null
        //     ? widget.businessPost!.title!
        //     : widget.post!.title ?? '',
        //   style: TextStyle(
        //     color: Colors.blue
        //   ),
        // ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Row(
            //   children: [
            //     Text(
            //       'Descrizione',
            //       style: TextStyle(
            //           color: Colors.blue,
            //           fontWeight: FontWeight.w600
            //       ),
            //     ),
            //     SizedBox(
            //       width: 15,
            //     ),
            //     CupertinoTextField(
            //       // suffix: Icon(
            //       //     Icons.keyboard_arrow_right
            //       // ),
            //       obscureText: false,
            //       controller: commentController,
            //       clearButtonMode: commentController.text != ''
            //           ? OverlayVisibilityMode.always
            //           : OverlayVisibilityMode.never,
            //       enabled: true,
            //
            //       decoration: BoxDecoration(color: Colors.white),
            //       textAlign: /*row.textAlign ??*/ TextAlign.left,
            //       placeholder: /*row.placeholder ??*/ "Inserire la descrizione dell'evento",
            //       placeholderStyle: TextStyle(
            //           fontSize: 15,
            //           color: CupertinoColors.placeholderText
            //       ),
            //       keyboardType: TextInputType.text,
            //       minLines: 1,
            //       maxLines: 8,
            //       // expands: true,
            //       style: TextStyle(
            //         fontSize: 15,
            //         color: Colors.grey[700],
            //       ),
            //       readOnly: false,
            //       onChanged: (value) {
            //         // if(_descriptionController.text == ''){
            //         //   setState(() {
            //         //     editableDescription = false;
            //         //   });
            //         // }
            //         // else{
            //         //   setState(() {
            //         //     editableDescription = true;
            //         //   });
            //         // }
            //       },
            //     ),
            //   ],
            // ),
            Column(
              children: [
                // Divider(
                //   color: Colors.grey[400],
                //   height: 1,
                //   // endIndent: 20,
                //   // indent: 20,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 5,
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      margin: EdgeInsets.all(0),
                      // height: 58.0,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text(
                            'Commento',
                            style: TextStyle(
                              // color: Colors.blue,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: CupertinoTextField(
                              // suffix: Icon(
                              //     Icons.keyboard_arrow_right
                              // ),
                              obscureText: false,
                              controller: commentController,
                              clearButtonMode: commentController.text != ''
                                  ? OverlayVisibilityMode.always
                                  : OverlayVisibilityMode.never,
                              enabled: true,
                              decoration: BoxDecoration(color: Colors.white),
                              textAlign: /*row.textAlign ??*/ TextAlign.left,
                              placeholder: /*row.placeholder ??*/ "Scrivere il commento",
                              placeholderStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: CupertinoColors.placeholderText
                              ),
                              keyboardType: TextInputType.text,
                              minLines: 1,
                              maxLines: 8,
                              // expands: true,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                              readOnly: false,
                              onChanged: (value) {
                                // if(commentController.text == ''){
                                //   setState(() {
                                //     editableDescription = false;
                                //   });
                                // }
                                // else{
                                //   setState(() {
                                //     editableDescription = true;
                                //   });
                                // }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Divider(
                //   color: Colors.grey[400],
                //   height: 1,
                //   // endIndent: 20,
                //   // indent: 20,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        // left: MediaQuery.of(context).size.width * 0.4,
                        // right: MediaQuery.of(context).size.width * 0.4,
                          right: 15,
                          left: 15,
                          top: 0,
                          bottom: 10
                      ),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            // fixedSize: MaterialStateProperty.all(Size.fromWidth(40)),
                            // minimumSize: MaterialStateProperty.all(Size.fromHeight(30)),

                            // maximumSize: MaterialStateProperty.all(Size.fromHeight(30)),
                            // padding: MaterialStateProperty.all(
                            //     EdgeInsets.only(
                            //         left: 40,
                            //         right: 40
                            //  )
                            // ),
                          ),
                          onPressed: () async {
                            if(UserPreferences.getIsLogged()! && commentController.text.isNotEmpty){
                              if(widget.businessPost != null){
                                await postProvider.createBusinessPostComment(widget.businessPost!, commentController.text);
                                setState(() {
                                  /*cab =*/ postProvider.getBusinessPostComments(widget.businessPost!.id!, widget.businessPost!.business!.id!);
                                });
                                // postProvider.getAllSubscribedBusinessPostComments(widget.myUser.id.toString());
                                // print(widget.businessPost!.id);

                              }
                              else{
                                // if(widget.isSingleEventPost) {
                                //   await createSingleEventPostComment();
                                //   setState(() {
                                //     getAllSingleEventPostComments();
                                //   });
                                // } else{
                                // if(widget.post != null){
                                //   await createBookingPostComment();
                                //   setState(() async {
                                //     await getAllBookingPostComments();
                                //   });
                                // }
                              }
                            }
                            //   }
                            // }

                            // createPostComment();
                            // setState(() {
                            //   getAllPostComments();
                            // });
                            commentController.clear();
                          },
                          child: Text(
                            'Invia',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700
                            ),
                          )
                        // child: Icon(
                        //   Icons.add,
                        //   color: Colors.blue,
                        // ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 10, left: 15),
              child: Text(
                // 'Commenti: ${postProvider.comments!.length}',
                'Commenti: ${postProvider.postComments.length}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    // color: Colors.white
                    color: Colors.grey[700]
                  // color: Colors.blue[500]
                ),
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              // itemCount: postProvider.comments!.length,
              itemCount: postProvider.postComments.length,
              // itemCount: widget.businessPost!.comments!.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                //TODO: DISCERNERE TRA SINGLE EVENT POST COMMENT E DATE COMMENT
                // PostComment postComment = PostComment(
                //   id: postProvider.comments![i]['id'],
                //   created_at: DateTime.parse(postProvider.comments![i]['created_at']),
                //   text: postProvider.comments![i]['text'],
                //   user: User(
                //     id: postProvider.comments![i]['user_id'],
                //     description: postProvider.comments![i]['user_description'],
                //     profile_image: postProvider.comments![i]['user_profile_image'],
                //     // first_name: postProvider.comments[i]['first_name'],
                //     name: postProvider.comments![i]['user_name'],
                //     // last_name: postProvider.comments[i]['last_name'],
                //     // city: postProvider.posts[i]['city'],
                //     // nation: postProvider.posts[i]['nation'],
                //     username: postProvider.comments![i]['user_username'],
                //     email: postProvider.comments![i]['user_email'],
                //   ),
                //
                // );

                // print('postProvider.postComments.length6666');
                // print(postProvider.postComments.length);
                // print(postProvider.postComments[i].is_admin);

                // return partecipationNotification(context, i);
                return CommentCard(
                  businessPost: widget.businessPost,
                  comment: postProvider.postComments[i],
                  // comment: widget.businessPost!.comments?[i],
                );

                // return Column(
                //   children: [
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           Container(
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               shape: BoxShape.circle,
                //               // backgroundBlendMode: ,
                //               boxShadow: [
                //                 BoxShadow(blurRadius: 0, color: Colors.black, spreadRadius: 1)
                //               ],
                //             ),
                //             child: CircleAvatar(
                //               radius: 20,
                //               backgroundImage: CachedNetworkImageProvider(
                //                   postProvider.comments[i]['profile_image'],
                //                 // 'https://images.pexels.com/photos/2346754/pexels-photo-2346754.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
                //               ),
                //             ),
                //           ),
                //           Text(
                //             postProvider.comments[i]['text'],
                //           ),
                //         ],
                //       ),
                //     ),
                //     Divider(
                //       height: 0,
                //       thickness: 2,
                //       endIndent: 15,
                //       indent: 15,
                //     ),
                //   ],
                // );
              },
            ),
            SizedBox(
              height: 20,
            )
          ],
        )
      ),
    );
  }

  getImageWidthHeight(String imageUrl) async {
    File image = File(imageUrl); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    //print(decodedImage.width);
    //print(decodedImage.height);
  }

  Widget partecipationNotification(context, i) {
    return Container(
      color: Colors.grey[100],
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
            // child: Container(
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: NetworkImage(convs[i].profilePicture),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            // child: CircleAvatar(
            //   radius: 30,
            //   backgroundImage: NetworkImage(
            //     convs[i].profilePicture
            //   )
            // ),
            // child: Container(
            //   width: 70,
            //   height: 50,
            //   child: ImageCard(
            //     imageData: imageList[i],
            //   ),
            // ),
            child: Container(
              width: 55,
              height: 55,
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.network(
                  // postProvider.comments![i]['profile_image'],
                  postProvider.postComments[i].user!.profile_image!,
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 10,
                //margin: EdgeInsets.all(10),
              ),
            ),
          ),
          Expanded(
            //alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      // postProvider.comments![i]['username'],
                      postProvider.postComments[i].user!.username!,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18.0,
                          // color: Colors.white
                          color: Colors.grey[700]
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, right: 17),
                    child: Text(
                      postProvider.comments![i]['text'],
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                          // color: Colors.white
                          color: Colors.black
                      ),
                    ),
                  ),
                  // SizedBox(height: 4),
                  // Row(
                  //   children: [
                  //     Container(
                  //       child: Expanded(
                  //         child: RichText(
                  //           text: TextSpan(
                  //             // Note: Styles for TextSpans must be explicitly defined.
                  //             // Child text spans will inherit styles from parent
                  //             style: TextStyle(
                  //                 fontSize: 14.0,
                  //                 color: Colors.black
                  //               // color: Colors.white,
                  //             ),
                  //             children: <TextSpan>[
                  //               TextSpan(text: "Parteciperà all'evento "),
                  //               TextSpan(text: events[i].title,
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.w800
                  //                 ),
                  //               ),
                  //               TextSpan(text: " il " + events[i].data + " alle ore " +
                  //                   events[i].hour
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         // child: Text(
                  //         //   //"Feed me right now or else ... ",
                  //         //   "Parteciperà all'evento " + notifications[i].title +
                  //         //       " il " + notifications[i].date + " alle ore " +
                  //         //       notifications[i].hour + " al " + notifications[i].place
                  //         //   /*+ " organizzato da " + notifications[i].eventOrganizer*/,
                  //         //   maxLines: 2,
                  //         //   overflow: TextOverflow.ellipsis,
                  //         //   // softWrap: true,
                  //         //   style: TextStyle(
                  //         //     color: Colors.grey[600],
                  //         //   ),
                  //         // ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Column(
                  //   // mainAxisAlignment: MainAxisAlignment.end,
                  //   // crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.only(top: 5),
                  //       child: Text(
                  //         "Rimangono solo " + notifications[i].availablePlaces.toString() + " posti disponibili",
                  //         style: TextStyle(
                  //             color: Colors.blue[300],
                  //             fontWeight: FontWeight.w700
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //       vertical: 10.0, horizontal: 0.0),
                  //   child: LinearPercentIndicator(
                  //     padding: EdgeInsets.only(left: 4),
                  //     // alignment: MainAxisAlignment.center,
                  //     width: 210.0,
                  //     lineHeight: 5.0,
                  //     percent: notifications[i].availablePlaces/60,
                  //     progressColor: Colors.blue[300],
                  //     // backgroundColor: CupertinoColors.black,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(right: 15),
          //   // mainAxisAlignment: MainAxisAlignment.center,
          //   child:
          //     Text(
          //         "5:35 pm"
          //     )
          // ),
          // Padding(
          //   padding: EdgeInsets.only(right: 15, left: 20, ),
          //   child: Container(
          //     width: 12,
          //     height: 12,
          //     decoration: BoxDecoration(
          //       color: Colors.blue[300],
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          // Divider(height: 5, thickness: 5,),
        ],
      ),
    );
  }
}

