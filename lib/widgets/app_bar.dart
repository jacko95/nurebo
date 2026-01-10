import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/notifications_screen.dart';
import 'package:nurebo/screens/search_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
// import 'package:nurebo/models/user.dart';
// import 'package:nurebo/provider/socket_provider.dart';
// import 'package:nurebo/provider/user_provider.dart';
// import 'package:nurebo/screens/guest_user_profile_screen.dart';
// import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;


class NureboAppBar extends StatefulWidget {
  // final User user;
  // final Widget bottomAppbar;

  const NureboAppBar({super.key, /*this.user, this.bottomAppbar*/});

  @override
  _NureboAppBarState createState() => _NureboAppBarState();
}

class _NureboAppBarState extends State<NureboAppBar> {
  late UserProvider userProvider;
  late SocketProvider socketProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // UserPreferences.init();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    // return /*Sliver*/AppBar(
    //   elevation: 0,
    //     // bottom: widget.bottomAppbar ?? null,
    //
    //     // floating: true,
    //     // backgroundColor: Colors.grey[100],
    //     backgroundColor: Colors.white,
    //     // backgroundColor: Colors.transparent,
    //     // forceElevated: true,
    //     // snap: true,
    //     centerTitle: true,
    //
    //     // title: Padding(
    //     //   padding: const EdgeInsets.only(/*left: 10.0*/),
    //     //   child: /*Gradient*/Text(
    //     //     'SocialNetwork',
    //     //     // 'nurebo',
    //     //     // gradient: LinearGradient(
    //     //     //     begin: Alignment.bottomLeft,
    //     //     //     end: Alignment.topRight,
    //     //     //     colors: [
    //     //     //       Color(0xff8921aa),
    //     //     //       Color(0xffDA44bb),
    //     //     //
    //     //     //       // Color(0xff8921aa),
    //     //     //       // Colors.blue,
    //     //     //     ]
    //     //     // ),
    //     //     style: GoogleFonts.lato(
    //     //     // style: TextStyle(
    //     //       color: Colors.blue,
    //     //       // color: Colors.pink[600],
    //     //       fontWeight: FontWeight.w900,
    //     //       letterSpacing: -1,
    //     //       fontSize: 20,
    //     //       // fontFamily: 'Panton',
    //     //       // fontFamily: 'Ballet',
    //     //     ),
    //     //   ),
    //     // ),
    //     title: Padding(
    //       padding: const EdgeInsets.only(bottom: 8.0),
    //       child: Text(
    //         // 'Admin',
    //         'nurebo',
    //         // 'kalixira',
    //         style: TextStyle(
    //             color: Colors.blue,
    //             fontWeight: FontWeight.w500,
    //             // fontSize: 27,
    //             fontSize: 34,
    //             // letterSpacing: -2,
    //             letterSpacing: -3,
    //             fontFamily: 'Panton'
    //             // fontFamily: 'UniNeue'
    //         ),
    //       ),
    //     ),
    //     // title: Lottie.asset(
    //     //   'assets/animations/chat-typing-indicator.json',
    //     //   width: 40,
    //     //   height: 40,
    //     //   alignment: Alignment.bottomLeft,
    //     // ),
    //     // title: widget.bottomAppbar ?? null,
    //     titleSpacing: 0,
    //     // shape: ContinuousRectangleBorder(
    //     //   borderRadius: BorderRadius.only(
    //     //     bottomLeft: Radius.circular(10),
    //     //     bottomRight: Radius.circular(10),
    //     //   ),
    //     // ),
    //     leading: Padding(
    //       padding: const EdgeInsets.only(top: .0, left: 2),
    //       child: Stack(
    //         children: [
    //           IconButton(
    //             icon: Icon(
    //               Icons.menu_rounded,
    //               // Icons.view_headline_rounded,
    //               // Icons.view_headline_outlined,
    //               // Icons.apps_rounded,
    //               // Icons.apps_outlined,
    //               color: Colors.grey[600],
    //               size: 28,
    //             ),
    //             // onPressed: () => Navigator.of(context).pop(),
    //             onPressed: () {
    //               Scaffold.of(context).openDrawer();
    //               // //print(UserPreferences.getIsLogged());
    //               // //print(UserPreferences.getUserId());
    //               // //print(UserPreferences.getUserToken());
    //             },
    //           ),
    //           // DateTime.parse(socketProvider.bookingNotificationList.first['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastUpbookingNotification() ?? DateTime.now().toIso8601String())) ? Positioned(
    //           !UserPreferences.getIsLogged() ? Positioned(
    //             top: 11,
    //             left: 28,
    //             // top: -1.5,
    //             // left: 39,
    //               child: Container(
    //                   width: 11,
    //                   height: 11,
    //                   // width: 13,
    //                   // height: 13,
    //                   decoration: BoxDecoration(
    //                       shape: BoxShape.circle,
    //                       // color: Colors.black
    //                       // color: Colors.grey[100]
    //                       color: Colors.white
    //                   ),
    //                   child: Center(
    //                       child: Container(
    //                           width: 7,
    //                           height: 7,
    //                           // width: 5,
    //                           // height: 5,
    //                           decoration: BoxDecoration(
    //                               shape: BoxShape.circle,
    //                               color: Colors.blue
    //                           )
    //                       )
    //                   )
    //               )
    //           ) : SizedBox(),
    //         ],
    //       ),
    //     ),
    //     iconTheme: IconThemeData(
    //       color: Colors.blue,
    //     ),
    //     actions: [
    //       InkWell(
    //         highlightColor: Colors.transparent,
    //         splashColor: Colors.transparent,
    //         onTap: () async {
    //           // //print(UserPreferences.getIsLogged().toString());
    //           // //print(UserPreferences.getUserId().toString());
    //           // //print(UserPreferences.getUserToken().toString());
    //           await Navigator.push(
    //               context,
    //               PageTransition(
    //                   duration: const Duration(milliseconds: 500),
    //                   alignment: Alignment.center,
    //                   type: PageTransitionType.fade,
    //                   // child: NotificationScreen(),
    //                   child: CartScreen()
    //               )
    //           );
    //         },
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //           // padding: const EdgeInsets.only(right: 16.0),
    //           // child: Icon(
    //           //   Icons.shopping_cart_outlined,
    //           //   // Icons.shopping_cart_outlined,
    //           //   size: 28,
    //           //   color: Colors.grey[600],
    //           // ),
    //           child: Provider.of<CartProvider>(context).items.length == 0 ? Icon(
    //             // Icons.shopping_cart,
    //             Icons.shopping_cart_outlined,
    //             size: 30,
    //             color: Colors.grey[600],
    //           ) : Badge(
    //               toAnimate: false,
    //               padding: EdgeInsets.all(6.5),
    //               shape: BadgeShape.circle,
    //               position: BadgePosition.topEnd(top: -.5, end: -7),
    //               animationDuration: Duration(milliseconds: 300),
    //               animationType: BadgeAnimationType.fade,
    //               // borderRadius: ,
    //               // badgeColor: Colors.grey[50],
    //               badgeColor: Colors.blue[500],
    //               // badgeColor: Colors.purpleAccent,
    //               elevation: 0,
    //               badgeContent: Text(
    //                 Provider.of<CartProvider>(context).items.length.toString(),
    //                 style: GoogleFonts.poppins(
    //                   // color: Colors.blue,
    //                     color: Colors.white,
    //                     fontWeight: FontWeight.w700,
    //                     fontSize: 11.5
    //                 ),
    //               ),
    //               child: Icon(
    //                 // Icons.shopping_cart,
    //                 Icons.shopping_cart_outlined,
    //                 // Icons.shopping_bag_outlined,
    //                 size: 30,
    //                 color: Colors.grey[600],
    //               )
    //           ),
    //         ),
    //       )
    //       // GestureDetector(
    //       //   child: Container(
    //       //     width: 50,
    //       //     margin: EdgeInsets.only(top: 3, bottom: 3, right: 10),
    //       //     child: Stack(
    //       //       fit: StackFit.expand,
    //       //       children: [
    //       //         Card(
    //       //           semanticContainer: true,
    //       //           clipBehavior: Clip.antiAliasWithSaveLayer,
    //       //           elevation: 0,
    //       //           shape: RoundedRectangleBorder(
    //       //               borderRadius: BorderRadius.all(Radius.circular(6))
    //       //           ),
    //       //           // color: Colors.red,
    //       //           // child: CircleAvatar(
    //       //           child: Image.network(
    //       //             // widget.user.profile_image,
    //       //             userProvider.user.profile_image,
    //       //             fit: BoxFit.fitWidth,
    //       //           ),
    //       //         ),
    //       //         Positioned(
    //       //             top: -1,
    //       //             left: 39,
    //       //             child: Container(
    //       //                 width: 13,
    //       //                 height: 13,
    //       //                 decoration: BoxDecoration(
    //       //                     shape: BoxShape.circle,
    //       //                     // color: Colors.black
    //       //                     // color: Colors.grey[100]
    //       //                     color: Colors.white
    //       //                 ),
    //       //                 child: Center(
    //       //                     child: Container(
    //       //                         width: 9.5,
    //       //                         height: 9.5,
    //       //                         decoration: BoxDecoration(
    //       //                             shape: BoxShape.circle,
    //       //                             color: Colors.greenAccent
    //       //                         )
    //       //                     )
    //       //                 )
    //       //             )
    //       //         ),
    //       //       ],
    //       //     ),
    //       //   ),
    //       //   onTap: (){
    //       //     // Navigator.push(
    //       //     //     context,
    //       //     //     PageTransition(
    //       //     //       child: MyProfileScreen(
    //       //     //         // user: widget.user,
    //       //     //         user: userProvider.user,
    //       //     //       ),
    //       //     //       duration: const Duration(milliseconds: 1000),
    //       //     //       type: PageTransitionType.fade,
    //       //     //     ),
    //       //     // );
    //       //
    //       //   },
    //       // ),
    //     ]
    // );

    // return Container(
    //   padding: EdgeInsets.only(right: 8),
    //   alignment: Alignment.topCenter,
    //   decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2.0)], borderRadius: BorderRadius.circular(8)),
    //   width: MediaQuery.of(context).size.width,
    //   margin: EdgeInsets.only(top: 50, left: 16, right: 16),
    //   child: Row(
    //     children: [
    //       IconButton(
    //         icon: Icon(Icons.menu),
    //         onPressed: () {
    //           Scaffold.of(context).openDrawer();
    //         },
    //       ),
    //       // 8.width,
    //       // TextFormField(
    //       //   showCursor: false,
    //       //   decoration: InputDecoration(focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, hintText: 'Search for apps & games'),
    //       // )/*.expand()*/,
    //       // 8.width,
    //       IconButton(
    //         icon: Icon(Icons.keyboard_voice_outlined),
    //         onPressed: () {},
    //       ),
    //       InkWell(
    //         onTap: () {
    //           // accountDialogBox(context);
    //         },
    //         child: CircleAvatar(maxRadius: 17, child: Text('J'), backgroundColor: Colors.purple),
    //       ),
    //     ],
    //   ),
    // );
    return AppBar(
      backgroundColor: Colors.white,
      // backgroundColor: Colors.transparent,
      // forceElevated: true,
      // snap: true,
      elevation: 0,
      // centerTitle: true,
      title: Utils.isBusiness ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(width: MediaQuery.of(context).size.width * 0.15,),
          Image.asset(
            // 'assets/launcher_icons/14162885.png',
            'assets/launcher_icon/nJYfhTRcsnmzg0ewGEYo.png',
            height: 34,
          ),
          SizedBox(width: 5,),
          Text(
            // 'Admin',
            'nurebo',
            style: TextStyle(
              color: Colors.orange,
              // fontWeight: FontWeight.w600,
              fontSize: 27,
              letterSpacing: -2.3,
              fontFamily: 'Panton',
              fontWeight: FontWeight.w700
            ),
          ),
          SizedBox(width: 30,),
        ],
      ) : Padding(
        padding: const EdgeInsets.only(top: .0),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () async {
            Navigator.push(
                context,
                PageTransition(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    // child: NotificationScreen(),
                    child: const SearchScreen(text: '',)
                )
            );
          },
          child: Container(
            // padding: EdgeInsets.only(right: 8),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2.0
                  )
                ],
                borderRadius: BorderRadius.circular(8)
            ),
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 2, left: 16, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 23,
                  ),
                ),
                // SizedBox(width: 50),
                // SizedBox(width: MediaQuery.of(context).size.width * 0.1375),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: GradientText(
                    // 'nurebo',
                    'nurebo',
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          // Color(0xff8921aa),
                          // Color(0xffDA44bb),
                          // Color(0xffDA44bb)

                          Color(0xffFFA818),

                          // Color(0xffED9B15),

                          Color(0xffF68A3D),
                        ]
                    ),
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                        // fontSize: 34,
                        letterSpacing: -2.4,
                        // letterSpacing: -3,
                        fontFamily: 'Panton'
                        // fontFamily: 'UniNeue'
                    ),
                  ),
                ),
                SizedBox(width: 20,)
              ],
            ),
          ),
        ),
      ),
      leading: !Utils.isBusiness ? Padding(
        padding: const EdgeInsets.only(top: 4, left: 7),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.menu_rounded,
                // Icons.view_headline_rounded,
                // Icons.view_headline_outlined,
                // Icons.apps_rounded,
                // Icons.apps_outlined,
                color: Colors.grey[600],
                size: 32,
              ),
              // onPressed: () => Navigator.of(context).pop(),
              onPressed: () {
                // Scaffold.of(context).openDrawer();
                if(UserPreferences.getIsLogged() == true) {
                  bottomSheetOptions(context);
                }
                else if(UserPreferences.getIsLogged() == false) {
                  bottomSheetNotLogged(context);
                }

                // //print(UserPreferences.getIsLogged());
                // //print(UserPreferences.getUserId());
                // //print(UserPreferences.getUserToken());
              },
            ),
            // DateTime.parse(socketProvider.bookingNotificationList.first['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastUpbookingNotification() ?? DateTime.now().toIso8601String())) ? Positioned(
            !UserPreferences.getIsLogged()!/*socketProvider.isNotificationBadge*/ ? Positioned(
            // userProvider!.isLogged ? Positioned(
              top: 10.5,
              left: 29,
              // top: -1.5,
              // left: 39,
                child: Container(
                    width: 11,
                    height: 11,
                    // width: 13,
                    // height: 13,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Colors.black
                        // color: Colors.grey[100]
                        color: Colors.white
                    ),
                    child: Center(
                        child: Container(
                            width: 7,
                            height: 7,
                            // width: 5,
                            // height: 5,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue
                            )
                        )
                    )
                )
            ) : SizedBox(),
          ],
        ),
      ) : SizedBox()/*Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 12, bottom: 12),
        child: Card(
          semanticContainer: true,
          margin: const EdgeInsets.all(0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          elevation: 5,
          // child: Image.network(
          child: FutureImage(
            // Utils.business!.profile_image!,
            // userProvider.user!.profile_image!,
            // Utils.user != null ? Utils.user!.profile_image! : '',
            // UserPreferences.getIsLogged() == true ? Utils.user!.profile_image! : userProvider.user!.profile_image!,
            userProvider.user != null ? userProvider.user!.profile_image! : '',
            width: MediaQuery.of(context).size.width * 0.07,
            height: MediaQuery.of(context).size.width * 0.07,
          ),
          //margin: EdgeInsets.all(10),
        ),
      )*/,
      // actions: <Widget>[
      //   IconButton(
      //     icon: Icon(
      //       Icons.search,
      //       color: Colors.grey[600],
      //     ),
      //     onPressed: (){
      //       // showSearch( context: context, delegate: GooglePlaySearch() );
      //     },
      //   ),
      //   Icon(
      //     Icons.keyboard_voice,
      //     color: Colors.grey[600],
      //   ),
      //   Padding(
      //     padding: EdgeInsets.only(right: 20.0),
      //   ),
      // ],
      actions: [
        Visibility(
          visible: !Utils.isBusiness,
          child: InkWell(
          // Utils.isSocial ? InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              // //print(UserPreferences.getIsLogged().toString());
              // //print(UserPreferences.getUserId().toString());
              // //print(UserPreferences.getUserToken().toString());
              await Navigator.push(
                  context,
                  PageTransition(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.center,
                      type: PageTransitionType.fade,
                      child: NotificationsScreen(),
                      // child: CartScreen()
                  )
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 12),
              // padding: const EdgeInsets.only(right: 16.0),
              // child: Icon(
              //   Icons.shopping_cart_outlined,
              //   // Icons.shopping_cart_outlined,
              //   size: 28,
              //   color: Colors.grey[600],
              // ),
              // child: Provider.of<CartProvider>(context).items.length == 0 ? Padding(
              // child: DateTime.parse(socketProvider.notificationList.isNotEmpty ? socketProvider.notificationList.first['sent_at'] : DateTime.now().subtract(Duration(days: 2)).toIso8601String()).isAfter(DateTime.parse(UserPreferences.getUserLastUpdateNotification() ?? DateTime.now().subtract(Duration(hours: 1)).toIso8601String())) ? badges.Badge(
              child: badges.Badge(
                // badgeAnimation: badges.BadgeAnimation.rotation(
                //   animationDuration: Duration(seconds: 1),
                //   colorChangeAnimationDuration: Duration(seconds: 1),
                //   loopAnimation: false,
                //   curve: Curves.fastOutSlowIn,
                //   colorChangeAnimationCurve: Curves.easeInCubic,
                // ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                  child: Icon(
                    // Icons.shopping_cart,
                    Icons.notifications_none_rounded,
                    // Icons.shopping_bag_outlined,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                ),
                // showBadge: true,
                showBadge: DateTime.parse(socketProvider.notificationList.isNotEmpty ? socketProvider.notificationList.first['sent_at'] : DateTime.now().subtract(const Duration(days: 2)).toIso8601String()).isAfter(DateTime.parse(UserPreferences.getUserLastUpdateNotification() ?? DateTime.now().subtract(const Duration(hours: 1)).toIso8601String())) && socketProvider.isNotificationBadge,
                // showBadge: socketProvider.isNotificationBadge,
                // showBadge: socketProvider.getNotificationBadge(),
                badgeStyle: badges.BadgeStyle(
                  // toAnimate: false,
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  shape: badges.BadgeShape.circle,
                  // animationDuration: Duration(milliseconds: 300),
                  // animationType: BadgeAnimationType.fade,
                  // borderRadius: ,
                  // badgeColor: Colors.grey[50],
                  badgeColor: Colors.blue[500]!,
                  // badgeColor: Colors.purpleAccent,
                  elevation: 0,
                ),
                position: badges.BadgePosition.topEnd(top: -4, end: -2),
                // badgeContent: Text(
                // Provider.of<CartProvider>(context).items.length.toString(),
                // style: GoogleFonts.poppins(
                //   // color: Colors.blue,
                //   color: Colors.white,
                //   fontWeight: FontWeight.w700,
                //   fontSize: 11.5
                // ),
                badgeContent: Container()
              )
            )
          ),
        ),
        // GestureDetector(
        //   child: Container(
        //     width: 50,
        //     margin: EdgeInsets.only(top: 3, bottom: 3, right: 10),
        //     child: Stack(
        //       fit: StackFit.expand,
        //       children: [
        //         Card(
        //           semanticContainer: true,
        //           clipBehavior: Clip.antiAliasWithSaveLayer,
        //           elevation: 0,
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.all(Radius.circular(6))
        //           ),
        //           // color: Colors.red,
        //           // child: CircleAvatar(
        //           child: Image.network(
        //             // widget.user.profile_image,
        //             userProvider.user.profile_image,
        //             fit: BoxFit.fitWidth,
        //           ),
        //         ),
        //         Positioned(
        //             top: -1,
        //             left: 39,
        //             child: Container(
        //                 width: 13,
        //                 height: 13,
        //                 decoration: BoxDecoration(
        //                     shape: BoxShape.circle,
        //                     // color: Colors.black
        //                     // color: Colors.grey[100]
        //                     color: Colors.white
        //                 ),
        //                 child: Center(
        //                     child: Container(
        //                         width: 9.5,
        //                         height: 9.5,
        //                         decoration: BoxDecoration(
        //                             shape: BoxShape.circle,
        //                             color: Colors.greenAccent
        //                         )
        //                     )
        //                 )
        //             )
        //         ),
        //       ],
        //     ),
        //   ),
        //   onTap: (){
        //     // Navigator.push(
        //     //     context,
        //     //     PageTransition(
        //     //       child: MyProfileScreen(
        //     //         // user: widget.user,
        //     //         user: userProvider.user,
        //     //       ),
        //     //       duration: const Duration(milliseconds: 1000),
        //     //       type: PageTransitionType.fade,
        //     //     ),
        //     // );
        //
        //   },
        // ),
      ]
    );
  }
}
