import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:badges/badges.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/comment_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
// import 'package:settings_ui/settings_ui.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;


class UserOrdersScreen extends StatefulWidget {

  UserOrdersScreen({Key? key});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  TextEditingController commentController = TextEditingController();
  List? comments = [];


  // Future getAllBookingPostComments() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   Map/*<String, String>*/ body = {
  //     // 'user_id': userProvider.user.id,
  //     'post_id': widget.post!.id,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var postProvider = Provider.of<PostProvider>(context, listen: false);

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
            size: 22,
            // size: 20,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        // foregroundColor: Colors.blue,
        title: Text(
          'Ordini',
          style: TextStyle(
            color: Colors.blue
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            shrinkWrap: true,
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 10, left: 15),
                child: Text(
                  'Commenti: ${comments!.length}',
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
                itemCount: comments!.length,
                shrinkWrap: true,
                itemBuilder: (context, i){
                  //TODO: DISCERNERE TRA SINGLE EVENT POST COMMENT E DATE COMMENT
                  PostComment postComment = PostComment(
                    id: comments![i]['id'],
                    is_admin: comments![i]['is_admin'],
                    created_at: DateTime.parse(comments![i]['created_at']),
                    text: comments![i]['text'],
                    user: User(
                      id: comments![i]['user_id'],
                      description: comments![i]['user_description'],
                      profile_image: comments![i]['user_profile_image'] ?? '',
                      // first_name: comments[i]['first_name'],
                      name: comments![i]['user_name'],
                      // last_name: comments[i]['last_name'],
                      // city: postProvider.posts[i]['city'],
                      // nation: postProvider.posts[i]['nation'],
                      username: comments![i]['username'],
                      email: comments![i]['user_email'],
                    ),

                  );

                  // return partecipationNotification(context, i);
                  return CommentCard(
                    comment: postComment,
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
                  //                   comments[i]['profile_image'],
                  //                 // 'https://images.pexels.com/photos/2346754/pexels-photo-2346754.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
                  //               ),
                  //             ),
                  //           ),
                  //           Text(
                  //             comments[i]['text'],
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
          ),
        ),
      ),
    );
  }

  getImageWidthHeight(String imageUrl) async {
    File image = new File(imageUrl); // Or any other way to get a File instance.
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
                  comments![i]['profile_image'],
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
                      comments![i]['username'],
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
                      comments![i]['text'],
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

