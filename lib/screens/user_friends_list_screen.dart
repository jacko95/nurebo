import 'dart:convert';
import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/provider/post_provider.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:intl/date_symbol_data_local.dart';


class UserFriendsListScreen extends StatefulWidget {
  // final List<User> userFriends;
  // final User user;

  const UserFriendsListScreen({super.key, /*required this.user, required this.userFriends,*/});

  @override
  _UserFriendsListScreenState createState() => _UserFriendsListScreenState();
}

class _UserFriendsListScreenState extends State<UserFriendsListScreen> {
  // List friendshipRequests = [];
  Future all = Future(() {}), a = Future(() {}), b = Future(() {});
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  late PostProvider postProvider;


  Future callFutureBuilderMethods() async {
    await Future.wait([
      a = socketProvider.getUserFriendshipRequests(),
      b = socketProvider.getUserFriends(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // print('widget.userFriends.length');
    // print(socketProvider.userFriends.length);
    // print(userProvider.userFriendsList.length);
    // Future.wait([
      all = callFutureBuilderMethods()/*,
    ])*/;
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return RefreshIndicator(
      edgeOffset: 60,
      // strokeWidth: 5,
      // displacement: 200,
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        // await Future.wait([
        //   a = socketProvider.getUserFriendshipRequests(),
        //   b = socketProvider.getUserFriends(),
        // ]);
        await callFutureBuilderMethods();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue[500], //change your color here
          ),
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
          centerTitle: true,
          elevation: 0,
          // foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          // centerTitle: true,
          title: Text(
            'Amici',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontSize: 16
            ),
          ),
          actions: [
          ],
        ),
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: FutureBuilder(
              future: Future.wait([/*a, b, */all]),
              // future: all,
              builder: (context, snapshot) {
                return ListView(
                  // shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: [
                    // SizedBox(height: 10,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.only(left: 15.0, top: 20, bottom: 5),
                    //       child: Text(
                    //         'Richieste di amicizia',
                    //         style: GoogleFonts.roboto(
                    //           color: Colors.blue,
                    //           fontWeight: FontWeight.w800,
                    //           //color: Color.fromRGBO(245, 93, 62, 1),
                    //           // background:
                    //           // letterSpacing: -3,
                    //           fontSize: 15,
                    //           //fontWeight: FontWeight.w200,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 10,),

                    ListView.separated(
                        padding: EdgeInsets.only(top: 0, bottom: 10),
                        separatorBuilder: (context, index) => Divider(
                          // color: Colors.black,
                          height: 10,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        shrinkWrap: true,
                        // physics: ClampingScrollPhysics(),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: socketProvider.friendshipRequests.length,
                        itemBuilder: (context, i){
                          // Map<String, dynamic> friendshipNotification = {
                          //   "id": socketProvider.notificationList[i]['id'],
                          //   "status": socketProvider.notificationList[i]['status'],
                          //   "user_id": socketProvider.notificationList[i]['user_id'],
                          //   "recipient_id": socketProvider.notificationList[i]['recipient_id'],
                          //   'user_image': socketProvider.notificationList[i]['user_image'],
                          //   'user_username': socketProvider.notificationList[i]['user_username'],
                          //   'user_name': socketProvider.notificationList[i]['user_name'],
                          //   'sent_at': socketProvider.notificationList[i]['sent_at'],
                          // };

                          return /*Dismissible(
                            // key: ObjectKey(socketProvider.notificationList[i]),
                            // key: ObjectKey(socketProvider.notificationList[i]['id']),
                            key: ObjectKey(socketProvider.friendshipRequests[i].user!.id),
                            // key: UniqueKey(),
                            // behavior: HitTestBehavior.translucent,
                            direction: DismissDirection.endToStart,
                            // dragStartBehavior: DragStartBehavior.start,
                            // crossAxisEndOffset: 22,
                            // confirmDismiss: (direction){
                            //
                            // },
                            onDismissed: (direction) async {
                              setState(() {
                              // items.removeAt(index);
                              // await socketProvider.deleteLocalNotification(
                              //     'friendship_notification',
                              //     // notification['booking_id'],
                              //     friendshipNotification['id'].toString(),
                              //     i
                              // );
                                socketProvider.friendshipRequests.removeWhere((element) => element.user!.id == socketProvider.friendshipRequests[i].user!.id);
                              });
                            },
                            child: */
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //       duration: const Duration(milliseconds: 500),
                                //       alignment: Alignment.center,
                                //       type: PageTransitionType.fade,
                                //       child: DateScreen(
                                //         prestazione: prestazione,
                                //         // bookingBusiness: prestazione.business,
                                //         // user: widget.user,
                                //       ),
                                //     )
                                // );
                              },
                              // child: Container(
                              //   height: MediaQuery.of(context).size.height * 0.15,
                              //   child: Card(
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     clipBehavior: Clip.antiAliasWithSaveLayer,
                              //     elevation: 8,
                              //     child: Stack(
                              //       clipBehavior: Clip.antiAliasWithSaveLayer,
                              //       fit: StackFit.expand,
                              //       children: [
                              //         FutureImage(
                              //           imageUrl: prestazione.image,
                              //           fit: BoxFit.cover,
                              //           // colorBlendMode: BlendMode.hardLight,
                              //           // width: MediaQuery.of(context).size.width,
                              //           // filterQuality: FilterQuality.high,
                              //           placeholder: (context, url) => Center(
                              //               child: CircularProgressIndicator()
                              //           ),
                              //           errorWidget: (context, url, error) => Icon(Icons.error),
                              //         ),
                              //         DecoratedBox(
                              //           decoration: BoxDecoration(
                              //             // backgroundBlendMode: BlendMode.darken,
                              //             gradient: LinearGradient(
                              //               begin: Alignment.bottomLeft,
                              //               end: Alignment.topRight,
                              //               colors: [
                              //                 Colors.black,
                              //                 // Colors.transparent,
                              //                 Colors.transparent,
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //         Positioned(
                              //           bottom: 20,
                              //           left: 20,
                              //           width: MediaQuery.of(context).size.width * 0.4,
                              //           child: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             children: [
                              //               GradientText(
                              //                 // prestazione.business.name,
                              //                 // notificationList[i]['sender_username'],
                              //                 socketProvider.bookingNotificationList[i]['sender_username'],
                              //                 // 'A partire da € 60,00',
                              //                 maxLines: 1,
                              //
                              //                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                 gradient: LinearGradient(
                              //                     begin: Alignment.bottomLeft,
                              //                     end: Alignment.topRight,
                              //                     colors: [
                              //                       Color(0xff8921aa),
                              //                       Color(0xffDA44bb),
                              //                       // Color(0xffDA44bb)
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
                              //                     color: Colors.blue,
                              //                     fontWeight: FontWeight.w800,
                              //                     fontSize: 13
                              //                 ),
                              //                 textAlign: TextAlign.left,
                              //               ),
                              //               GradientText(
                              //                 // prestazione.title,
                              //                 // notificationList[i]['sent_at'],
                              //                 socketProvider.bookingNotificationList[i]['sent_at'],
                              //                 maxLines: 2,
                              //                 shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                 gradient: Gradients.haze,
                              //                 style: TextStyle(
                              //                     color: Colors.white,
                              //                     fontWeight: FontWeight.w800,
                              //                     fontSize: 15
                              //                 ),
                              //                 textAlign: TextAlign.left,
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              child: Container(
                                padding: EdgeInsets.all(0),
                                margin: EdgeInsets.all(0),
                                color: Colors.white,
                                // color: Colors.grey[200],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 20, /*top: 10, bottom: 10*/),
                                      child: Container(
                                        width: 90,
                                        height: 140,
                                        child: Card(
                                          semanticContainer: true,
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          elevation: 5,
                                          child: socketProvider.friendshipRequests[i].user!.profile_image != null && socketProvider.friendshipRequests[i].user!.profile_image != '' ? FutureImage(
                                            // prestazione.image,
                                            // friendshipNotification['user_image'],
                                            // friendshipNotification['user_image'],
                                            socketProvider.friendshipRequests[i].user!.profile_image!,
                                            width: MediaQuery.of(context).size.width,
                                          ) : Icon(
                                            Icons.account_circle_rounded,
                                            color: Colors.grey[300],
                                            size: 45,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      //alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 15, bottom: 10, top: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          //mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: /*Gradient*/Text(
                                                // '@' + socketProvider.notificationList[i]['sender_username'],
                                                // '@' + socketProvider.notificationList[i]['business_name'],
                                                // '@' + prestazione.business.name,
                                                // friendshipNotification['user_name'],
                                                socketProvider.friendshipRequests[i].user!.name!,
                                                // gradient: LinearGradient(
                                                //     begin: Alignment.bottomLeft,
                                                //     end: Alignment.topRight,
                                                //     colors: [
                                                //       Color(0xff8921aa),
                                                //       Color(0xffDA44bb),
                                                //       // Color(0xffDA44bb)
                                                //     ]
                                                // ),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15.0,
                                                    // color: Colors.white
                                                    // color: Colors.black
                                                    color: Colors.blue
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Expanded(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: TextStyle(
                                                            fontSize: 13.0,
                                                            color: Colors.black
                                                          // color: Colors.white,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            // text: "Parteciperà a ",
                                                            text: "Hai ricevuto una richiesta di amicizia da ",
                                                            // style: TextStyle(
                                                            //   color: Colors.grey[900]
                                                            // )
                                                          ),
                                                          TextSpan(
                                                            // text: prestazione.title,
                                                            // text: '@' + friendshipNotification['user_username'],
                                                            text: '@${socketProvider.friendshipRequests[i].user!.username!}',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              // color: Colors.blue[500]
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            // text: "Parteciperà a ",
                                                            text: ".",
                                                            // style: TextStyle(
                                                            //   color: Colors.grey[900]
                                                            // )
                                                          ),
                                                          // TextSpan(
                                                          //   // text: socketProvider.notificationList[i]['created_at'],
                                                          //   text: 'annullata',
                                                          //   style: TextStyle(
                                                          //       fontWeight: FontWeight
                                                          //           .w700,
                                                          //       color: Colors.red[600]
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    // child: Text(
                                                    //   //"Feed me right now or else ... ",
                                                    //   "Parteciperà all'evento " + notifications[i].title +
                                                    //       " il " + notifications[i].booking + " alle ore " +
                                                    //       notifications[i].hour + " al " + notifications[i].place
                                                    //   /*+ " organizzato da " + notifications[i].eventOrganizer*/,
                                                    //   maxLines: 2,
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   // softWrap: true,
                                                    //   style: TextStyle(
                                                    //     color: Colors.grey[600],
                                                    //   ),
                                                    // ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 35,
                                                  // width: MediaQuery.of(context).size.width * 0.2,
                                                  margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                                                  child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(Colors.blue[400]),
                                                        // padding: MaterialStateProperty.all(),
                                                      ),
                                                      onPressed: () async {
                                                        await socketProvider.acceptFriendshipRequest(
                                                          socketProvider.friendshipRequests[i].user!,
                                                        );
                                                        postProvider.getAllBusinessesPosts(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Accetta",
                                                            style: TextStyle(
                                                                fontSize: 14
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: 30,),
                                                Container(
                                                  height: 35,
                                                  // width: MediaQuery.of(context).size.width * 0.2,
                                                  margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
                                                  child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
                                                        // backgroundColor: MaterialStateProperty.all(Colors.red[500]),
                                                      ),
                                                      onPressed: () {
                                                        // print("friendshipRequests[i]['user_id']");
                                                        // print(socketProvider.friendshipRequests[i].user!.id);

                                                        socketProvider.declineFriendshipRequest(
                                                          socketProvider.friendshipRequests[i].user!,
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Rifiuta",
                                                            style: TextStyle(
                                                                fontSize: 14
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8, right: 30),
                                                  child: Text(
                                                    timeAgo.format(
                                                      // DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                                      //   DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                                        socketProvider.friendshipRequests[i].created_at!,
                                                        locale: 'it'
                                                    ),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 12.0,
                                                        // color: Colors.white
                                                        color: Colors.grey[500]
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Column(
                                            //   // mainAxisAlignment: MainAxisAlignment.end,
                                            //   // crossAxisAlignment: CrossAxisAlignment.center,
                                            //   children: [
                                            //     Padding(
                                            //       padding: EdgeInsets.only(top: 5),
                                            //       child: Text(
                                            //         "Rimangono solo " + '3' + " posti disponibili",
                                            //         style: TextStyle(
                                            //             color: Colors.blue[300],
                                            //             fontSize: 13,
                                            //             fontWeight: FontWeight.w600
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            // Container(
                                            //   padding: EdgeInsets.symmetric(
                                            //       vertical: 10.0, horizontal: 0.0
                                            //   ),
                                            //   child: LinearPercentIndicator(
                                            //     padding: EdgeInsets.only(left: 4),
                                            //     // alignment: MainAxisAlignment.center,
                                            //     width: 210.0,
                                            //     lineHeight: 5.0,
                                            //     percent: (60/3)/100,
                                            //     progressColor: Colors.blue[300],
                                            //     // backgroundColor: CupertinoColors.black,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Visibility(
                                    //   // Opacity(
                                    //   // visible: DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                                    //   visible: false,
                                    //   // visible: DateTime.parse(/*friendshipNotification*/friendshipRequests[i]['created_at']).isAfter(
                                    //   //     DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                                    //   // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                                    //   child: Padding(
                                    //     padding: EdgeInsets.only(right: 15, left: 20,),
                                    //     child: Container(
                                    //       width: 12,
                                    //       height: 12,
                                    //       decoration: BoxDecoration(
                                    //         color: Colors.blue[300],
                                    //         shape: BoxShape.circle,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   // Opacity(
                                    //   // visible: !DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                                    //   visible: true/*!DateTime.parse(
                                    //       socketProvider.notificationList[i]['sent_at'])
                                    //       .isAfter(DateTime.parse(UserPreferences
                                    //       .getUserLastClosedNotification() ??
                                    //       DateTime.now().toIso8601String()))*/,
                                    //   // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                                    //   child: Padding(
                                    //     padding: EdgeInsets.only(right: 15, left: 20,),
                                    //   ),
                                    // ),
                                    // Divider(height: 5, thickness: 5,),
                                  ],
                                ),
                              ),
                            // ),
                          );
                        }
                      ),
                    socketProvider.friendshipRequests.isNotEmpty ? Divider(
                      // color: Colors.black,
                      height: 5,
                      thickness: 3,
                      indent: 15,
                      endIndent: 15,
                    ) : SizedBox(),
                    SizedBox(height: 10,),
                    ListView.separated(
                        padding: EdgeInsets.only(top: 0, bottom: 10),
                        separatorBuilder: (context, index) => Divider(
                          // color: Colors.black,
                          height: 10,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        shrinkWrap: true,
                        // physics: ClampingScrollPhysics(),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: socketProvider.userFriendsList.length,
                        itemBuilder: (context, i){
                          return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () async {
                              Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: UserProfileScreen(
                                    // userId: socketProvider.userFriendsList[i].id!,
                                    user: socketProvider.userFriendsList[i],
                                    isTab: false,
                                  )
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 20,
                                right: 15
                              ),
                              child: Row(
                                children: [
                                  // prestazioneProvider.prestazioneList[i]['image'] == '' || prestazioneProvider.prestazioneList[i]['image'] == null ? ClipRRect(
                                  ClipRRect(
                                    // borderRadius: BorderRadius.circular(40),
                                    borderRadius: BorderRadius.circular(20),
                                    // borderRadius: BorderRadius.circular(50),
                                    // child: Image.asset(
                                    // child: Image.network(
                                    //   businessProvider.business.profile_image,
                                    //   // height: 38,
                                    //   height: 45,
                                    //   // width: 38,
                                    //   width: 45,
                                    //   fit: BoxFit.cover,
                                    // ),
                                    child: socketProvider.userFriendsList[i].profile_image != null && socketProvider.userFriendsList[i].profile_image != '' ? FutureImage(
                                      socketProvider.userFriendsList[i].profile_image!,
                                      // colorBlendMode: BlendMode.darken,
                                      // colorBlendMode: BlendMode.hardLight,
                                      width: 45,
                                      height: 45,
                                      // filterQuality: FilterQuality.high,
                                      // placeholder: (context, url) => Center(
                                      //     child: CircularProgressIndicator()
                                      // ),
                                    ) : Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.grey[300],
                                      size: 45,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Marquee(
                                            child: GradientText(
                                              socketProvider.userFriendsList[i].name ?? '',
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    // Color(0xff8921aa),
                                                    // Color(0xffDA44bb)
                                                    Colors.blue[700]!,
                                                    Colors.blue[700]!,
                                                    // Colors.red[400]!,
                                                    // Colors.red[600]!,
                                                  ]
                                              ),
                                              style: TextStyle(
                                                //   color: Colors.black,
                                                color: Colors.green[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17
                                              ),
                                            ),
                                          ),
                                          // SizedBox(height: 2,),
                                          // Text(
                                          //   // discussionData[index].booking,
                                          //   // timeAgo.format(
                                          //   //     DateTime.tryParse(bookingList[index]['created_at']),
                                          //   //     locale: 'it'
                                          //   // ),
                                          //   // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                          //   //   + ' alle ' +
                                          //   //   bookingList[index]['created_at'].toString().substring(11, 16),
                                          //   "@${socketProvider.userFriendsList[i].username}",
                                          //   style: TextStyle(
                                          //       // color: Colors.black.withOpacity(0.8),
                                          //       color: Colors.grey[800],
                                          //       // color: Colors.blue[600],
                                          //       fontSize: 13.5,
                                          //       fontWeight: FontWeight.w500
                                          //   ),
                                          // ),
                                          SizedBox(height: 1,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Text(
                                  //   timeAgo.format(
                                  //     // widget.userFriends[i].created_at!,
                                  //     DateTime.now(),
                                  //     locale: 'it'
                                  //   ),
                                  //   style: TextStyle(
                                  //     // color: Colors.black.withOpacity(0.5),
                                  //       color: Colors.grey[600],
                                  //       fontSize: 13,
                                  //       fontWeight: FontWeight.w500
                                  //   ),
                                  // ),
                                  Divider(height: 5, thickness: 5,),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                    SizedBox(height: 90,)
                  ],
                );
              }
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
