import 'dart:convert';
import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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


class UserProfileFriendsListScreen extends StatefulWidget {
  final List<User> userFriends;
  // final User user;

  const UserProfileFriendsListScreen({super.key, /*required this.user,*/ required this.userFriends,});

  @override
  _UserProfileFriendsListScreenState createState() => _UserProfileFriendsListScreenState();
}

class _UserProfileFriendsListScreenState extends State<UserProfileFriendsListScreen> {
  // List friendshipRequests = [];
  Future all = Future(() {}), a = Future(() {}), b = Future(() {});
  late SocketProvider socketProvider;
  late UserProvider userProvider;


  // Future callFutureBuilderMethods() async {
  //   await Future.wait([
  //     a = widget.user.id == Utils.user!.id ? socketProvider.getUserFriendshipRequests() : Future(() {}),
  //     b = widget.user.id == Utils.user!.id ? socketProvider.getUserFriends() : Future(() {}),
  //   ]);
  // }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // print('widget.userFriends.length');
    // print(socketProvider.userFriends.length);
    // print(userProvider.userFriendsList.length);
    // Future.wait([
    //   all = callFutureBuilderMethods(),
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

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
        // callFutureBuilderMethods();
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
              // future: Future.wait([/*a, b, */all]),
              future: all,
              builder: (context, snapshot) {
                return ListView(
                  // shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: [
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
                        itemCount: widget.userFriends.length,
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
                                    // userId: widget.userFriends[i].id!,
                                    user: widget.userFriends[i],
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
                                    borderRadius: BorderRadius.circular(4),
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
                                    child: widget.userFriends[i].profile_image != null && widget.userFriends[i].profile_image != '' ? FutureImage(
                                      widget.userFriends[i].profile_image!,
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
                                              widget.userFriends[i].name! ?? '',
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
                                          //   "@${widget.userFriends[i].username}",
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
