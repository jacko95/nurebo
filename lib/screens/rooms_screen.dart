import 'dart:convert';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/screens/group_chat_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'package:marquee_widget/marquee_widget.dart';


class RoomScreen extends StatefulWidget {
  final User? user;

  const RoomScreen({Key? key, this.user});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {

  late PageController _pageController;
  double? _pageOffset = 0;
  late SocketProvider socketProvider;

  @override
  void initState() {
    super.initState();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // setState(() {
    //   socketProvider.getAllChatRooms(userId: this.widget.user.id);
    // });
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   var roomProvider = Provider.of<RoomProvider>(context, listen: false);
    //   roomProvider.getAllRooms(userId: this.widget.user.id);
    // });

    // socketProvider.getAllChatRooms(userId: widget.user.id);

    _pageController = PageController(viewportFraction: .8, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var roomProvider = Provider.of<RoomProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    // roomProvider.getAllRooms(userId: this.widget.user.id);

    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: MyDrawer(),
      onDrawerChanged: (value){
        if(Utils.isSocial){
          //todo: false per nascondere bottombar
          //print(value);
          socketProvider.setBottomBarVisibility(!value);
        }
      },
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(55),
      //     child: AppBar2()
      // ),
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text(
      //     "Rooms",
      //     style: TextStyle(
      //       color: Colors.blue,
      //       fontWeight: FontWeight.w800
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      // ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 5),
        //   child: ListView.builder(
        //     physics: NeverScrollableScrollPhysics(),
        //     shrinkWrap: true,
        //     itemCount: categoryList.length,
        //     itemBuilder: (BuildContext context, int i){
        //       return Container(
        //         height: MediaQuery.of(context).size.height * 0.2,
        //         width: MediaQuery.of(context).size.width,
        //         child: GestureDetector(
        //           onTap: () async {
        //             // List notifications = await LocalDB.instance.query(
        //             //   'notification',
        //             // );
        //             //
        //             // //print('notifications');
        //             // for(var e in notifications){
        //             //   //print(e['id'].toString());
        //             //   //print(e['type'].toString());
        //             //   //print(e['user_id'].toString());
        //             //   //print(e['single_event_begin_at'].toString());
        //             // }
        //
        //             Navigator.push(
        //               context,
        //               PageTransition(
        //                 duration: const Duration(milliseconds: 500),
        //                 alignment: Alignment.center,
        //                 type: PageTransitionType.fade,
        //                 child: BusinessScreen(
        //                   user: widget.user,
        //                   categoryId: categoryList[i]['id'].toString(),
        //                 )
        //               )
        //             );
        //           },
        //           // child: Card(
        //           //   semanticContainer: true,
        //           //   clipBehavior: Clip.antiAliasWithSaveLayer,
        //           //   child: Image.network(
        //           //     convs[i].profilePicture,
        //           //     fit: BoxFit.cover,
        //           //   ),
        //           //   // shape: RoundedRectangleBorder(
        //           //   //   borderRadius: BorderRadius.circular(12.0),
        //           //   // ),
        //           //   elevation: 8,
        //           //   //margin: EdgeInsets.all(10),
        //           // ),
        //           child: Card(
        //             clipBehavior: Clip.antiAliasWithSaveLayer,
        //             // shape: RoundedRectangleBorder(
        //             //   borderRadius: BorderRadius.circular(18.0),
        //             // ),
        //             elevation: 8,
        //             child: Container(
        //               // shape: RoundedRectangleBorder(
        //               //   borderRadius: BorderRadius.circular(8.0),
        //               // ),
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 children: <Widget>[
        //                   // SvgPicture.asset("assets/svg/icon_location.svg"),
        //                   // SizedBox(width: 7,),
        //                   ClipRRect(
        //                     borderRadius: BorderRadius.all(Radius.circular(5)),
        //                     // borderRadius: BorderRadius.circular(20),
        //                     child: BackdropFilter(
        //                       filter: ImageFilter.blur(
        //                           sigmaY: 30,
        //                           sigmaX: 30
        //                       ),
        //                       child: Padding(
        //                         padding: EdgeInsets.all(5),
        //                         child: Text(
        //                           // categories[i].name,
        //                           // category.name,
        //                           categoryList[i]['name'],
        //                           overflow: TextOverflow.ellipsis,
        //                           style: GoogleFonts.lato(
        //                             fontWeight: FontWeight.w700,
        //                             color: Colors.white,
        //                             fontSize: 18,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //               //margin: EdgeInsets.all(2),
        //               // width: MediaQuery.of(context).size.width,
        //               // height: MediaQuery.of(context).size.width,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5),
        //                 // color: Colors.white.withOpacity(1)),
        //                 image: DecorationImage(
        //                   fit: BoxFit.cover,
        //                   colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
        //                   image: NetworkImage(
        //                     // categories[i].image,
        //                       categoryList[i]['image']
        //                   ),
        //                 ),
        //                 boxShadow: [
        //                   // BoxShadow(
        //                   //   color: Colors.grey[400].withOpacity(0.3),
        //                   //   spreadRadius: 0.5,
        //                   //   blurRadius: 1,
        //                   //   offset: Offset(5, 5), // changes position of shadow
        //                   // ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       );
        //     }
        //   ),
        // ),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 10, top: 8),
          // padding: EdgeInsets.all(0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, i){
            // return Divider(indent: 20, endIndent: 20, height: 40, thickness: 2,);
            // return Divider(height: 0, thickness: 0, color: Colors.transparent,);
            return SizedBox(height: 20,);
          },
          // itemCount: roomProvider.chatRooms.length,
          itemCount: socketProvider.chatRooms.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 3),
                      child: Text(
                        // categories[i].name,
                        // category.name,
                        // categoryList[i]['name'],
                        socketProvider.chatRooms[i].event!.business!.name!,
                        // overflow: TextOverflow.ellipsis,
                        // style: GoogleFonts.lato(
                        style: GoogleFonts.roboto(
                        // style: TextStyle(
                          fontWeight: FontWeight.w700,
                          // color: Colors.blue,
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        // maxLines: 2,
                      ),
                    ),
                    Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(18.0),
                      // ),
                      elevation: 5,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        // width: MediaQuery.of(context).size.width * 0.7,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(8.0),
                        // ),

                        child: Center(
                          child: Marquee(
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // SvgPicture.asset("assets/svg/icon_location.svg"),
                                // SizedBox(width: 7,),
                                Container(

                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  // width: MediaQuery.of(context).size.width * 0.9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    // borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaY: 30,
                                          sigmaX: 30
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(7),
                                        child: Text(
                                          // categories[i].name,
                                          // category.name,
                                          // categoryList[i]['name'],
                                          socketProvider.chatRooms[i].event!.title!,
                                          // overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          // maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //margin: EdgeInsets.all(2),
                        // width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          // color: Colors.white.withOpacity(1)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(
                                Colors.black.withOpacity(0.32),
                                BlendMode.darken
                            ),
                            image: NetworkImage(
                              // categories[i].image,
                              //   categoryList[i]['image']
                              socketProvider.chatRooms[i].event!.image!,
                            ),
                          ),
                          boxShadow: [
                            // BoxShadow(
                            //   color: Colors.grey[400].withOpacity(0.3),
                            //   spreadRadius: 0.5,
                            //   blurRadius: 1,
                            //   offset: Offset(5, 5), // changes position of shadow
                            // ),
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
      )
    );
  }

  Widget element(context, i){
    // var roomProvider = Provider.of<RoomProvider>(context, listen: false);

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {

      },
      child: Card(
        elevation: 8,
        child: Container(
            // height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              // color: Colors.white.withOpacity(1)),
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                image: NetworkImage(
                  // events[i].eventImage,
                  // socketProvider.chatRooms[i]['image'],
                  socketProvider.chatRooms[i].event!.image!,
                ),
              ),
              boxShadow: [
                // BoxShadow(
                //   color: Colors.grey[400].withOpacity(0.3),
                //   spreadRadius: 0.5,
                //   blurRadius: 1,
                //   offset: Offset(5, 5), // changes position of shadow
                // ),
              ],
            ),
            // height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
              child: Marquee(
                // direction: Axis.vertical,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 0.735,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 2, top: 5, bottom: 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaY: 30,
                                    sigmaX: 30
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Text(
                                      // events[i].title,
                                      // socketProvider.chatRooms[i]['title'],
                                      socketProvider.chatRooms[i].event!.image!,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
