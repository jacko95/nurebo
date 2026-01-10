import 'dart:convert';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee_widget/marquee_widget.dart';
// import 'package:nurebo/data/conversations.dart';
// import 'package:nurebo/models/ChatModel.dart';
import 'package:nurebo/models/chat.dart';
import 'package:nurebo/models/chat_message.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/chat_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/group_chat_screen.dart';
// import 'package:nurebo/screens/IndividualPage.dart';
// import 'package:nurebo/screens/home_screen3.dart';
// import 'package:nurebo/screens/profile_my_screen.dart';
// import 'package:nurebo/screens/rooms_screen.dart';
import 'package:nurebo/screens/search_screen.dart';
import 'package:nurebo/utils/utils.dart';
// import 'package:nurebo/utils/colors.dart';
import 'package:nurebo/widgets/app_bar.dart';
// import 'package:nurebo/widgets/app_bar2.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


// import 'chat_screen4.dart';
// import 'chat_screen7.dart';
import 'chat_screen.dart';
// import 'notification_screen.dart';

class MessagesScreen extends StatefulWidget {
  // final User user;
  final Chat? chat;
  final ChatMessage? chatMessage;

  MessagesScreen({Key? key, /*this.user, */this.chat, this.chatMessage});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List chatList = [];
  // List chatMessageList = [];
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  List<Chat> messageList = [];
  Future? a;

  // Future getAllUserChat() async {
  //   var url = Uri.parse(Constants.serverUrl + "chat/user");
  //   Map/*<String, String>*/ body = {
  //     "user_id": this.widget.user.id,
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
  //   // //print('response.statusCode9999996');
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //       chatList = jsonData;
  //
  //     //print('e e e');
  //
  //     for(var e in chatList){
  //       //print(e);
  //       if(e['a_id'] == ''){
  //         getUsersLastMessage(
  //             widget.user.id,
  //             e['b_id']
  //         );
  //       }
  //       else if(e['b_id'] == ''){
  //         getUsersLastMessage(
  //             e['a_id'],
  //             widget.user.id
  //         );
  //       }
  //     }
  //     // });
  //     // //print("chatList: ");
  //     // //print(chatList);
  //     // //print("chatList.length: " + chatList.length.toString());
  //
  //
  //     return jsonData;
  //   }
  // }
  //
  // Future getUsersLastMessage(String userA, String userB) async {
  //   // //print('userA0');
  //   // //print(userA);
  //   // //print('userB0');
  //   // //print(userB);
  //   var url = Uri.parse(Constants.serverUrl + "chat_message/last");
  //
  //   Map/*<String, String>*/ body = {
  //     "user_a": userA,
  //     "user_b": userB,
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
  //   // //print("response.statusCode lastm:");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // chatProvider.chatList = jsonData;
  //     // setState(() {
  //     //   chatList = jsonData;
  //     // });
  //     //print('r r r');
  //
  //     for(var e in jsonData){
  //       //print(e);
  //       // if(e['a_id'] == ''){
  //       //   getUsersLastMessage(
  //       //     widget.user.id,
  //       //     e['b_id']
  //       //   );
  //       // }
  //       // else if(e['b_id'] == ''){
  //       //   getUsersLastMessage(
  //       //     e['a_id'],
  //       //     widget.user.id
  //       //   );
  //       // }
  //       setState(() {
  //         messageList.add(
  //             new Chat(
  //               chat_id: jsonData[0]['chat_id'],
  //               receiver_id: jsonData[0]['receiver_id'],
  //               sender_id: jsonData[0]['sender_id'],
  //               receiver_username: jsonData[0]['receiver_username'],
  //               sender_username: jsonData[0]['sender_username'],
  //               sent_at: DateTime.parse(jsonData[0]['sent_at']).toLocal(),
  //               text: jsonData[0]['text'],
  //               receiver_profile_image: jsonData[0]['receiver_profile_image'],
  //               sender_profile_image: jsonData[0]['sender_profile_image'],
  //
  //             )
  //         );
  //         messageList.sort((b, a) {
  //           return a.sent_at.compareTo(b.sent_at);
  //         });
  //       });
  //
  //     }
  //
  //     for(var e in messageList){
  //       //print('e.id');
  //       //print(e.chat_id);
  //     }
  //     // //print("jsonData last");
  //     // //print(jsonData);
  //     // connect();
  //     // //print(chatList);
  //     // //print("chatList:");
  //     // //print(chatList);
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    timeAgo.setLocale('it', timeAgo.Italian());

    // a = getAllUserChat().then((value) {
    //   //print('messageList.length00');
    //   //print(messageList.length);
    // });

    // // a = socketProvider.getAllUserChat(widget.user.id).then((value) {
    // a = socketProvider.getAllUserChat(userProvider.user.id).then((value) {
    //   // //print('socketProvider.messageList.length05566');
    //   // //print(socketProvider.messageList.length);
    //   //print('widget.chat.chat_id');
    //   //print(widget.chat.chat_id);
    // });
    //

    // Future.wait([
    //   a = socketProvider.getAllUserChat(userProvider.user.id),
    // ]);
    // //print('widget.chat.chat_id');
    // //print(widget.chat.chat_id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    // //print('tttttt');
    // for(var e in socketProvider.messageList){
    //   // e.chat_message_list.sort((b, a) {
    //   //   return a.sent_at.compareTo(b.sent_at);
    //   // });
    //   e.sort((b, a) {
    //     return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
    //   });
    //   // //print(e.chat_message_list.last.text);
    //   // //print(e.chat_message_list.last.sent_at.toString());
    // }

    // socketProvider.messageList.sort((b, a) {
    //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
    // });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        // preferredSize: Size.fromHeight(100),
        preferredSize: Size.fromHeight(55),
        // child: AppBar2(user: widget.user,),
        child: NureboAppBar(
          // user: userProvider.user,
          // user: widget.user,
        ),
      ),
      drawer: NureboDrawer(),
      onDrawerChanged: (value){
        if(Utils.isSocial){
          //todo: false per nascondere bottombar
          //print(value);
          socketProvider.setBottomBarVisibility(!value);
        }
      },
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 0),
                child: Text(
                  // "Scopri",
                  "Stanze",
                  // "Eventi",
                  style: TextStyle(
                    fontSize: 15,
                    //fontFamily: GoogleFonts.abhayaLibre(),
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                padding: EdgeInsets.only(left: 5),

                // width: 80,
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: 10, top: 8),
                  // padding: EdgeInsets.all(0),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  separatorBuilder: (context, i){
                    // return Divider(indent: 20, endIndent: 20, height: 40, thickness: 2,);
                    // return Divider(height: 0, thickness: 0, color: Colors.transparent,);
                    return const SizedBox(height: 20,);
                  },
                  // itemCount: roomProvider.chatRooms.length,
                  itemCount: socketProvider.chatRooms.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(
                                milliseconds: 500,
                              ),
                              child: GroupChatScreen(
                                singleEvent: socketProvider.chatRooms[i].event,
                              ),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              // child: FullPostScreen(
                              //   // post: singleEventPost,
                              //   post: postProvider.userPostList[i],
                              //   user: followedUser,
                              //   isFavoritedPost:
                              //   isFavoritedPost,
                              //   isLikedPost: isLikedPost,
                              //   height: heightImage,
                              //   width: widthImage,
                              //   myUser: widget.user,
                              // ),
                              // child: UnseenNotificationPage(),
                            )
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          //   left: 5,
                          // right: 5
                        ),
                        // child: Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Card(
                        //       elevation: 0,
                        //       child: Container(
                        //         padding: EdgeInsets.only(right: 0),
                        //         width: MediaQuery.of(context).size.width * 0.3,
                        //         height: MediaQuery.of(context).size.width * 0.25,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(5),
                        //           // color: Colors.white.withOpacity(1)),
                        //           image: DecorationImage(
                        //             fit: BoxFit.cover,
                        //             //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                        //             image: CachedNetworkImageProvider(
                        //               socketProvider.chatRooms[i].single_event.image,                                              ),
                        //           ),
                        //           boxShadow: [
                        //             // BoxShadow(
                        //             //   color: Colors.grey[400].withOpacity(0.3),
                        //             //   spreadRadius: 0.5,
                        //             //   blurRadius: 1,
                        //             //   offset: Offset(5, 5), // changes position of shadow
                        //             // ),
                        //           ],
                        //         ),
                        //         // child: Marquee(
                        //         //   // direction: Axis.vertical,
                        //         //   child: Row(
                        //         //     // mainAxisAlignment: MainAxisAlignment.end,
                        //         //     // crossAxisAlignment: CrossAxisAlignment.start,
                        //         //     children: <Widget>[
                        //         //       Padding(
                        //         //         padding: EdgeInsets.only(left: 10, bottom: 25),
                        //         //         child: Column(
                        //         //           mainAxisAlignment: MainAxisAlignment.end,
                        //         //           crossAxisAlignment: CrossAxisAlignment.start,
                        //         //           children: [
                        //         //             Padding(
                        //         //               padding: EdgeInsets.only(left: 2, top: 5, bottom: 0),
                        //         //               child: ClipRRect(
                        //         //                 borderRadius: BorderRadius.circular(5),
                        //         //                 child: BackdropFilter(
                        //         //                   filter: ImageFilter.blur(
                        //         //                       sigmaY: 30,
                        //         //                       sigmaX: 30
                        //         //                   ),
                        //         //                   child: Padding(
                        //         //                     padding: EdgeInsets.all(3),
                        //         //                     child: Text(
                        //         //                       // events[i].title,
                        //         //                       roomProvider.rooms[i]['title'],
                        //         //                       overflow: TextOverflow.ellipsis,
                        //         //                       style: GoogleFonts.lato(
                        //         //                         fontWeight: FontWeight.w900,
                        //         //                         color: Colors.white,
                        //         //                         letterSpacing: -0.5,
                        //         //                         fontSize: 15,
                        //         //                       ),
                        //         //                     ),
                        //         //                   ),
                        //         //                 ),
                        //         //               ),
                        //         //             ),
                        //         //           ],
                        //         //         ),
                        //         //       ),
                        //         //     ],
                        //         //   ),
                        //         // ),
                        //       ),
                        //     ),
                        //     // Marquee(
                        //     //   // direction: Axis.vertical,
                        //     //   child: Row(
                        //     //     // mainAxisAlignment: MainAxisAlignment.end,
                        //     //     // crossAxisAlignment: CrossAxisAlignment.start,
                        //     //     children: <Widget>[
                        //     //       Padding(
                        //     //         padding: EdgeInsets.only(left: 10, bottom: 25),
                        //     //         child: Column(
                        //     //           mainAxisAlignment: MainAxisAlignment.end,
                        //     //           crossAxisAlignment: CrossAxisAlignment.start,
                        //     //           children: [
                        //     //             Padding(
                        //     //               padding: EdgeInsets.only(left: 2, top: 5, bottom: 0),
                        //     //               child: ClipRRect(
                        //     //                 borderRadius: BorderRadius.circular(5),
                        //     //                 child: BackdropFilter(
                        //     //                   filter: ImageFilter.blur(
                        //     //                       sigmaY: 30,
                        //     //                       sigmaX: 30
                        //     //                   ),
                        //     //                   child: Padding(
                        //     //                     padding: EdgeInsets.all(6),
                        //     //                     child: Text(
                        //     //                       // events[i].title,
                        //     //                       roomProvider.singleEventRooms[i]['title'],
                        //     //                       overflow: TextOverflow.ellipsis,
                        //     //                       style: GoogleFonts.lato(
                        //     //                         fontWeight: FontWeight.w900,
                        //     //                         color: Colors.black,
                        //     //                         letterSpacing: -0.5,
                        //     //                         fontSize: 15,
                        //     //                       ),
                        //     //                     ),
                        //     //                   ),
                        //     //                 ),
                        //     //               ),
                        //     //             ),
                        //     //           ],
                        //     //         ),
                        //     //       ),
                        //     //     ],
                        //     //   ),
                        //     // ),
                        //     Card(
                        //         elevation: 0,
                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                        //         child: Container(
                        //           // clipBehavior: Clip.antiAliasWithSaveLayer,
                        //           // color: Colors.grey[50],
                        //           color: Colors.white,
                        //           // color: Colors.blue[300],
                        //           padding: EdgeInsets.only(right: 0),
                        //           width: MediaQuery.of(context).size.width * 0.65 - 5,
                        //           height: MediaQuery.of(context).size.width * 0.28,
                        //           child: Column(
                        //             children: [
                        //               ListTile(
                        //                 dense: true,
                        //                 minVerticalPadding: 0,
                        //                 title: GradientText(
                        //                   socketProvider.chatRooms[i].single_event.title,
                        //                   gradient: LinearGradient(
                        //                       begin: Alignment.bottomLeft,
                        //                       end: Alignment.topRight,
                        //                       colors: [
                        //                         Color(0xff8921aa),
                        //                         // Color(0xffDA44bb),
                        //                         Colors.pink
                        //                       ]
                        //                   ),
                        //                   style: TextStyle(
                        //                       fontSize: 15,
                        //                       fontWeight: FontWeight.w700,
                        //                       color: Colors.grey[800]
                        //                   ),
                        //                 ),
                        //                 subtitle: Text(
                        //                   socketProvider.chatRooms[i].single_event.business.name,
                        //                   maxLines: 1,
                        //                   style: TextStyle(
                        //                     fontSize: 13,
                        //                     fontWeight: FontWeight.w700,
                        //                     color: Colors.grey[700],
                        //
                        //                   ),
                        //                   // gradient: LinearGradient(
                        //                   //     begin: Alignment.bottomLeft,
                        //                   //     end: Alignment.topRight,
                        //                   //     colors: [
                        //                   //       Color(0xff8921aa),
                        //                   //       // Color(0xffDA44bb),
                        //                   //       Colors.pink
                        //                   //     ]
                        //                   // )
                        //                 ),
                        //               ),
                        //               Divider(
                        //                 indent: 15,
                        //                 endIndent: 15,
                        //                 color: Colors.grey[400],
                        //                 thickness: 0.7,
                        //                 height: 0,
                        //               ),
                        //               SizedBox(
                        //                 height: 10,
                        //               ),
                        //               Text(
                        //                 'Partecipanti: 47',
                        //                 style: TextStyle(
                        //                     fontSize: 14,
                        //                     fontWeight: FontWeight.w700,
                        //                     color: Colors.blue[500]
                        //                 ),
                        //               ),
                        //               // Expanded(
                        //               //   child: ListView.builder(
                        //               //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        //               //     itemCount: 20,
                        //               //     shrinkWrap: true,
                        //               //     scrollDirection: Axis.horizontal,
                        //               //     itemBuilder: (context, i){
                        //               //       return Padding(
                        //               //         padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                        //               //         child: CircleAvatar(
                        //               //           maxRadius: 25,
                        //               //           minRadius: 25,
                        //               //           backgroundImage: NetworkImage(
                        //               //             "https://images.pexels.com/photos/2777898/pexels-photo-2777898.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                        //               //           ),
                        //               //         ),
                        //               //       );
                        //               //     }
                        //               //   ),
                        //               // )
                        //             ],
                        //           ),
                        //         )
                        //     )
                        //   ],
                        // ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 8, bottom: 3),
                            //   child: Text(
                            //     // categories[i].name,
                            //     // category.name,
                            //     // categoryList[i]['name'],
                            //     socketProvider.chatRooms[i].event.business.name,
                            //     // overflow: TextOverflow.ellipsis,
                            //     // style: GoogleFonts.lato(
                            //     style: GoogleFonts.roboto(
                            //       // style: TextStyle(
                            //       fontWeight: FontWeight.w700,
                            //       // color: Colors.blue,
                            //       color: Colors.grey[500],
                            //       fontSize: 14,
                            //     ),
                            //     // maxLines: 2,
                            //   ),
                            // ),
                            Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(18.0),
                              // ),
                              elevation: 5,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.1,
                                // height: MediaQuery.of(context).size.height * 0.25,
                                //margin: EdgeInsets.all(2),
                                width: MediaQuery.of(context).size.width * 0.35,
                                // height: MediaQuery.of(context).size.width,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(5),
                                //   // color: Colors.white.withOpacity(1)),
                                //   image: DecorationImage(
                                //     fit: BoxFit.cover,
                                //     colorFilter: ColorFilter.mode(
                                //         Colors.black.withOpacity(0.32),
                                //         BlendMode.darken
                                //     ),
                                //     image: NetworkImage(
                                //       // categories[i].image,
                                //       //   categoryList[i]['image']
                                //       socketProvider.chatRooms[i].event!.image!,
                                //     ),
                                //   ),
                                //   boxShadow: [
                                //     // BoxShadow(
                                //     //   color: Colors.grey[400].withOpacity(0.3),
                                //     //   spreadRadius: 0.5,
                                //     //   blurRadius: 1,
                                //     //   offset: Offset(5, 5), // changes position of shadow
                                //     // ),
                                //   ],
                                // ),
                                // width: MediaQuery.of(context).size.width * 0.7,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(8.0),
                                // ),
                                child: Stack(
                                  children: [
                                    FutureImage(
                                      socketProvider.chatRooms[i].event!.image!,
                                      width: MediaQuery.of(context).size.width
                                    ),
                                    Center(
                                      // child: Marquee(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            // SvgPicture.asset("assets/svg/icon_location.svg"),
                                            // SizedBox(width: 7,),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 15),
                                              width: MediaQuery.of(context).size.width * 0.35,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                // borderRadius: BorderRadius.circular(20),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaY: 30,
                                                      sigmaX: 30
                                                  ),
                                                  child: Marquee(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(7),
                                                      child: Text(
                                                        // categories[i].name,
                                                        // category.name,
                                                        // categoryList[i]['name'],
                                                        socketProvider.chatRooms[i].event!.title!,
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white,
                                                          fontSize: 12.5,
                                                        ),
                                                        // maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // SizedBox(height: 20,)
                          ],
                        ),
                      ),
                    );
                    // return ParallaxCard(
                    //   image: roomProvider.rooms[i]['image'],
                    //   controller: _pageController,
                    //   offset: _pageOffset--,
                    //
                    // );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 0, bottom: 5),
                child: Text(
                  "Chat",
                  style: TextStyle(
                    fontSize: 15,
                    //fontFamily: GoogleFonts.abhayaLibre(),
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FutureBuilder(
                  future: a,
                  builder: (context, snapshot) {
                    return ListView.separated(
                        padding: EdgeInsets.only(top: 0),
                        separatorBuilder: (context, index) => Divider(
                              // color: Colors.black,
                              height: 10,
                              thickness: 1,
                              endIndent: 15,
                              indent: 15,
                            ),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        // physics: NeverScrollableScrollPhysics(),
                        // itemCount: chatList.length,
                        // itemCount: messageList.length,
                        itemCount: socketProvider.messageList.length,
                        itemBuilder: (context, i){
                          // int c = 0;
                          // for(int j = socketProvider.messageList[i].chat_message_list.length - 1; j > 0; j--){
                          //   if(socketProvider.messageList[i].user_a_id == widget.user.id){
                          //     if(socketProvider.messageList[i].chat_message_list[j].sent_at
                          //         .isBefore(socketProvider.messageList[i].user_a_last_opening_at)){
                          //       break;
                          //     }
                          //   }
                          //   else if(socketProvider.messageList[i].user_b_id == widget.user.id){
                          //     if(socketProvider.messageList[i].chat_message_list[j].sent_at
                          //         .isBefore(socketProvider.messageList[i].user_b_last_opening_at)){
                          //       break;
                          //     }
                          //   }
                          //   c++;
                          // }
                          //
                          // //print('c888888');
                          // //print(c);
                          // for(var e in socketProvider.messageList[i].chat_message_list){
                          //   if(){
                          //
                          //   }
                          // }

                          if(socketProvider.messageList[i].chat_message_list!.length > 0){
                            return InkWell(
                              onTap: (){
                                // //print("aId:" + chatList[i]['a_id']);
                                // //print("bId:" + chatList[i]['b_id']);
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    duration: const Duration(milliseconds: 1),
                                    // alignment: Alignment.topRight,
                                    // type: PageTransitionType.scale,
                                    // child: IndividualPage(
                                    //   chatModel: ,
                                    //   sourceChat: new ChatModel(
                                    //     id: widget.user.id,
                                    //     name: widget.user.username,
                                    //   ),
                                    // ),
                                    child: ChatScreen(
                                      // chatId: socketProvider.messageList[i].chat_id.toString(),
                                      aId: socketProvider.messageList[i].user_a_id,
                                      bId: socketProvider.messageList[i].user_b_id,
                                      // user: widget.user,
                                      user: userProvider.user,
                                      // receiverProfileImage: socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                      receiverProfileImage: socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                          ? socketProvider.messageList[i].sender_profile_image
                                          : socketProvider.messageList[i].receiver_profile_image,
                                      // receiverUsername: socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                      receiverUsername: socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                          ? socketProvider.messageList[i].sender_username
                                          : socketProvider.messageList[i].receiver_username,
                                      // receiverId: socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                      receiverId: socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                          ? socketProvider.messageList[i].sender_id
                                          : socketProvider.messageList[i].receiver_id,
                                      messages: socketProvider.messageList[i].chat_message_list,
                                      chatId: socketProvider.messageList[i].chat_id.toString(),
                                      //er chatscreen4 attualmente funzionante
                                      // recipientImage: socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                      //     ? socketProvider.messageList[i].sender_profile_image
                                      //     : socketProvider.messageList[i].receiver_profile_image,
                                    ),
                                    type: PageTransitionType.fade,
                                  ),
                                  // MaterialPageRoute(builder: (context) => UserProfile(user: imagePosts[i].user)),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 11, bottom: 11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsets.only(top: 3, right: 20),
                                    //   child: Text(
                                    //     // "3:35 pm",
                                    //     DateFormat.yMMMMd('it_IT').format(socketProvider.messageList[i].chat_message_list.last.sent_at) + ' alle '
                                    //         + socketProvider.messageList[i].chat_message_list.last.sent_at.toString().substring(11, 19),
                                    //     // timeAgo.format(
                                    //     //     socketProvider.messageList[i].chat_message_list.last.sent_at,
                                    //     //     locale: 'it'
                                    //     // ),
                                    //     style: TextStyle(
                                    //         color: Colors.grey[600],
                                    //         fontWeight: FontWeight.w600,
                                    //         fontSize: 9
                                    //     ),
                                    //   ),
                                    // ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
                                            child: Container(
                                              width: 70,
                                              height: 50,
                                              child: Card(
                                                semanticContainer: true,
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6.0),
                                                ),
                                                elevation: 15,
                                                // child: Image.network(
                                                //   // chatList[i]['a_id'] != /*widget.user.id*/"" ?
                                                //   // chatList[i]['a_profile_image'] : chatList[i]['b_profile_image'],
                                                //   // socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                                //   socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                                //       ? socketProvider.messageList[i].sender_profile_image!
                                                //       : socketProvider.messageList[i].receiver_profile_image!,
                                                //
                                                //   fit: BoxFit.cover,
                                                // ),
                                                child: FutureImage(
                                                    socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                                        ? socketProvider.messageList[i].sender_profile_image!
                                                        : socketProvider.messageList[i].receiver_profile_image!,
                                                  width: MediaQuery.of(context).size.width,
                                                ),
                                                //margin: EdgeInsets.all(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          //alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              //mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 0),
                                                      child: Text(
                                                        // chatList[i]['a_id'] != /*widget.user.id*/"" ?
                                                        // '@' + chatList[i]['a_username'] : '@' + chatList[i]['b_username'],
                                                        // socketProvider.messageList[i].sender_id != widget.user.id/*""*/
                                                        socketProvider.messageList[i].sender_id != userProvider.user!.id/*""*/
                                                            // ? '@' + socketProvider.messageList[i].sender_username
                                                            ? socketProvider.messageList[i].sender_name!
                                                            // : '@' + socketProvider.messageList[i].receiver_username,
                                                            : socketProvider.messageList[i].receiver_name!,
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 15,
                                                            color: Colors.blue
                                                        ),
                                                      ),
                                                    ),
                                                    // Padding(
                                                    //   padding: EdgeInsets.only(top: 0, right: 15),
                                                    //   child: Text(
                                                    //     // "3:35 pm",
                                                    //     // snapshot.data[0]['sent_at'] != null
                                                    //     //     ? snapshot.data[0]['sent_at'].toString().substring(11, 16)
                                                    //     //     : '',
                                                    //     // sentAt.toString() != '' && sentAt != null
                                                    //     //     ? sentAt.toString().substring(11, 16)
                                                    //     //     : snapshot.data[0]['sent_at'].toString().substring(11, 16),
                                                    //       DateFormat.MMMMd('it_IT').format(messageList[i].sent_at) + ' alle '
                                                    //         + messageList[i].sent_at.toString().substring(11, 19),
                                                    //     style: TextStyle(
                                                    //         color: Colors.grey[600],
                                                    //         fontWeight: FontWeight.w600,
                                                    //         fontSize: 11
                                                    //     ),
                                                    //   ),
                                                    // )
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        child: Expanded(
                                                          child: Text(
                                                            // "<ultimo messaggio>",

                                                            // lastMex != '' && lastMex != null
                                                            // // ? socketProvider.messages.last.text
                                                            //     ? lastMex
                                                            //     : snapshot.data[0]['text'],
                                                            // socketProvider.messageList[i].text,
                                                            socketProvider.messageList[i].chat_message_list!.last.text!,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            // softWrap: true,
                                                            style: TextStyle(
                                                                color: Colors.grey[800],
                                                                fontSize: 13

                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Row(
                                                //   mainAxisAlignment: MainAxisAlignment.end,
                                                //   // crossAxisAlignment: CrossAxisAlignment.center,
                                                //   children: [
                                                //     Padding(
                                                //       padding: EdgeInsets.only(top: 5, right: 15),
                                                //       child: Text(
                                                //         "3:35 pm",
                                                //         style: TextStyle(
                                                //           color: Colors.grey[900],
                                                //         ),
                                                //       ),
                                                //     )
                                                //   ],
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
                                        Column(
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 3, left: 10, right: 20),
                                              child: Text(
                                                // "3:35 pm",
                                                DateFormat./*y*/MMMMd('it_IT').format(socketProvider.messageList[i].chat_message_list!.last.sent_at!) + '\n'/*' alle '*/
                                                    + socketProvider.messageList[i].chat_message_list!.last.sent_at.toString().substring(11, /*16*/19),
                                                // timeAgo.format(
                                                //     socketProvider.messageList[i].chat_message_list.last.sent_at,
                                                //     locale: 'it'
                                                // ),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 9.5
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 10, left: 0, top: 10),
                                              child: Visibility(
                                                visible: socketProvider.messageList[i].unread_messages != 0,
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      // socketProvider.messageList[i].chat_message_list.length.toString(),
                                                      // c.toString(),
                                                      socketProvider.messageList[i].unread_messages.toString(),
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white

                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 5, thickness: 5,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return null;
                        }
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
