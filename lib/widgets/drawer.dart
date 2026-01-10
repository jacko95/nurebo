import 'dart:convert';
import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/post_feed_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/business_favorite_screen.dart';
import 'package:nurebo/screens/user_booking_list_screen.dart';
import 'package:nurebo/screens/favorites_screen.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/screens/notifications_screen.dart';
import 'package:nurebo/screens/user_event_reservations_screen.dart';
import 'package:nurebo/screens/user_orders_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/screens/settings_screen.dart';
import 'package:nurebo/tab_navigator.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../screens/post_liked_screen.dart';

class NureboDrawer extends StatefulWidget {
  @override
  _NureboDrawerState createState() => _NureboDrawerState();
}

class _NureboDrawerState extends State<NureboDrawer> {
  TextEditingController searchController = TextEditingController();
  late UserProvider userProvider;
  late CartProvider cartProvider;
  late SocketProvider socketProvider;
  late PrestazioneFavoriteProvider favoriteProvider;
  late BusinessFavoriteProvider businessFavoriteProvider;


  Future logOut() async {
    // //print('UserPreferences.getUserToken()');
    // //print(UserPreferences.getUserToken());

    var splitToken = UserPreferences.getUserToken()!.split('.');
    // //print(splitToken);
    String decodedHeader = utf8.fuse(base64).decode(base64.normalize(splitToken[0]));
    String decodedPayload = utf8.fuse(base64).decode(base64.normalize(splitToken[1]));
    // String decodedSignature = utf8.fuse(base64).decode(splitToken[2]);
    // //print(decodedHeader);
    // //print(decodedPayload);
    // //print(decodedSignature);
    Map authId = jsonDecode(utf8.fuse(base64).decode(base64.normalize(splitToken[1])));
    // //print(authId['id']);

    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/authentication/${authId['id']}/logout");

    Map body = {
      "auth_id": authId['id'],
      "user_id": userProvider.user!.id,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!,
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode <= 401) {
      Scaffold.of(context).openEndDrawer();
      // if(socketProvider.socket != null){
      //   if(socketProvider.socket.connected){
      //     // socketProvider.socket.disconnect();
      //     // socketProvider.socket.close();
      //     socketProvider.socket.destroy();
      //   }
      // }

      // //print('socketProvider.socket.id');
      // //print(socketProvider.socket.id);
      // //print('userProvider.user.id');
      // //print(userProvider.user.id);

      // socketProvider.removeUserSocket(
      //     userProvider.user.id,
      //     socketProvider.socket.id
      // );

      // await UserPreferences.init();
      await UserPreferences.setIsLogged(false);
      await UserPreferences.setUserId('');
      await UserPreferences.setUserToken('');
      await UserPreferences.setDeviceId('');

      // userProvider.setUser(null);
      userProvider.emptyUser();
      Utils.user = User();
      favoriteProvider.emptyFavorites();
      businessFavoriteProvider.emptySavedBusiness();
      socketProvider.emptyAppointments();
      socketProvider.emptyDateNotifications();
      cartProvider.removeAll();

      socketProvider.setBottomBarVisibility(false);

      // // FlutterBackgroundService().sendData({"action": "stopService"},);
      // if((await FlutterBackgroundService().isServiceRunning()) == true){
      // if((await FlutterBackgroundService().isRunning()) == true){
      //   // FlutterBackgroundService().sendData({"action": "stopService"},);
      //   FlutterBackgroundService().invoke("stopService");
      // }

      await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginScreen(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 500),
          ),
          (route) => false
        // (route) => true
      );

      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop')/*.then((value) => Phoenix.rebirth(context))*/;
      // Phoenix.rebirth(context);
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    cartProvider = Provider.of<CartProvider>(context, listen: false);

    // /*await */UserPreferences.init();
    //todo: da levare quando riuscirò ad aggiornare "myappointmentlist" (e i tutti i campi) in provider quando arriva una cancellazione o un appuntamento al background service socket.io
    // socketProvider.getLocalAppointmentNotifications(userProvider.user);

    // if(UserPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(userProvider.user);
    //   } ();
    // }

    // //print('userProvider.user.name');
    // //print(userProvider.user.name.length);

  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);
    cartProvider = Provider.of<CartProvider>(context, listen: true);

    // if(socketProvider.bookingNotificationList.isNotEmpty){
    //   //print("socketProvider.bookingNotificationList.last['sent_at']");
    //   //print(socketProvider.bookingNotificationList.last['sent_at']);
    //   //print("UserPreferences.getUserLastUpbookingNotification()");
    //   //print(UserPreferences.getUserLastUpbookingNotification());
    // }

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
              padding: EdgeInsets.all(0.0),
              children: <Widget>[
                // UserAccountsDrawerHeader(
                //
                //   accountName: Text(
                //     // widget.user.username,
                //     userProvider.user == null ? '' : userProvider.user.username,
                //     style: TextStyle(
                //       fontWeight: FontWeight.w600,
                //       fontSize: 15,
                //       color: Colors.grey[600]
                //     ),
                //   ),
                //   margin: EdgeInsets.all(0),
                //   accountEmail:
                //   // Text(widget.user.phone_number),
                //   Text(
                //     // userProvider.user.phone_number.toString().substring(0, 7) + ' ' +
                //     // userProvider.user.phone_number.toString().substring(7, 10) + ' ' +
                //     // userProvider.user.phone_number.toString().substring(10, userProvider.user.phone_number.toString().length),
                //     userProvider.user == null ? '' : userProvider.user.name,
                //     style: TextStyle(
                //       color: Colors.grey[600]
                //     ),
                //   ),
                //   // Text(widget.user.email),
                //   // Text(widget.user.name ?? ''),
                //   currentAccountPicture: CircleAvatar(
                //     // currentAccountPicture: Card(
                //     //   clipBehavior: Clip.antiAliasWithSaveLayer,
                //     // child: Center(child: Text('M')),
                //     // backgroundImage: ExactAssetImage('assets/aleydon.jpg'),
                //     // radius: 20.0,
                //     // fit: BoxFit.cover,
                //     maxRadius: 30,
                //     // radius: 30,
                //     minRadius: 30,
                //     backgroundImage: NetworkImage(
                //       // widget.user.profile_image,
                //       // userProvider.user.profile_image,
                //       userProvider.user == null ? '' : userProvider.user.profile_image,
                //     ),
                //   ),
                //   // otherAccountsPictures: <Widget>[
                //   //   CircleAvatar(
                //   //     child: Text('A'),
                //   //     backgroundColor: Colors.white60,
                //   //     ),
                //   //   CircleAvatar(
                //   //       child: Text('R'),
                //   //   ),
                //   // ],
                //   // onDetailsPressed: (){},
                //   decoration: BoxDecoration(
                //     // color: Colors.blue[500],
                //     color: Colors.grey[200],
                //     // image: DecorationImage(
                //     //   // image: AssetImage("assets/images/fundo.jpg"),
                //     //   // image: AssetImage("assets/images/abstract-luxury-gradient-2.jpg"),
                //     //   // image: AssetImage("assets/images/abstract-grunge-1.jpg"),
                //     //   // image: AssetImage("assets/images/blue-paperboard-texture.jpg"),
                //     //     image: AssetImage("assets/images/blue_diagonal_square.jpg"),
                //     //     // image: AssetImage("assets/images/blue_grunge_pattern.jpg"),
                //     //     fit: BoxFit.cover
                //     // )
                //   ),
                // ),
                InkWell(
                  onTap: () {
                    if(UserPreferences.getIsLogged()!){
                      Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(
                              milliseconds: 500
                          ),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: UserProfileScreen(
                            // userId: userProvider.user!.id!,
                            user: userProvider.user!,
                            isTab: false,
                          ),
                        )
                      );

                      Future.delayed(
                          const Duration(milliseconds: 500),
                          () => Scaffold.of(context).openEndDrawer()
                      );
                      // Scaffold.of(context).openEndDrawer();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 30, bottom: 20, left: 15),
                    child: Marquee(
                      direction: Axis.horizontal,
                      animationDuration: Duration(milliseconds: 5000),
                      backDuration: Duration(milliseconds: 5000),
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: ClipOval(
                              child: userProvider.user != null && userProvider.user!.profile_image != null ? FutureImage(
                                userProvider.user!.profile_image!,
                                // width: MediaQuery.of(context).size.width,
                                width: 55,
                                height: 55,
                              ) : /*Image.asset(
                                'assets/png/guest_profile_image.png',
                                width: 55,
                                height: 55,
                              ),*/userProvider.user != null && UserPreferences.getIsLogged()! ? Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                              ) : SizedBox(
                                width: 55,
                                height: 55,
                              )
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 5.0),
                          //   child: CircleAvatar(
                          //     radius: 30,
                          //     // backgroundColor: Colors.grey[300],
                          //     backgroundColor: Colors.white,
                          //     // backgroundImage: NetworkImage(
                          //     //   // 'https://images.pexels.com/photos/1816606/pexels-photo-1816606.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
                          //     //   userProvider.user != null && userProvider.user.profile_image != null ? userProvider.user.profile_image : 'immagine profilo drawer'
                          //     // )
                          //     // backgroundImage: FutureImage(
                          //     //   imageUrl: widget.bookingBusiness.profile_image != null && widget.bookingBusiness.profile_image != ''
                          //     //       ? widget.bookingBusiness.profile_image : widget.bookingBusiness.profile_image,
                          //     //   fit: BoxFit.cover,
                          //     //   // colorBlendMode: BlendMode.darken,
                          //     //   // colorBlendMode: BlendMode.hardLight,
                          //     //   width: MediaQuery.of(context).size.width,
                          //     //   // filterQuality: FilterQuality.high,
                          //     //   // placeholder: (context, url) => Center(
                          //     //   //     child: CircularProgressIndicator()
                          //     //   // ),
                          //     //   errorWidget: (context, url, error) => Icon(Icons.error),
                          //     // ),
                          //     // backgroundImage: CachedNetworkImageProvider(
                          //     //   // userProvider.user ?? 'profile_image',
                          //     //   userProvider.user != null && userProvider.user.profile_image != null
                          //     //       ? userProvider.user.profile_image
                          //     //   // : 'https://w7.pngwing.com/pngs/340/956/png-transparent-profile-user-icon-computer-icons-user-profile-head-ico-miscellaneous-black-desktop-wallpaper.png',
                          //     //       : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcZsL6PVn0SNiabAKz7js0QknS2ilJam19QQ&usqp=CAU',
                          //     //   // scale: 1
                          //     //   errorListener: () => SizedBox(),
                          //     // ),
                          // ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Marquee(
                              //   direction: Axis.horizontal,
                              //   animationDuration: Duration(milliseconds: 5000),
                              //   backDuration: Duration(milliseconds: 5000),
                              //   textDirection: TextDirection.ltr,
                              //   child: Row(
                              //     children: [
                              //       Text(
                              //         // /*name ??*/ '@username',
                              //         /*name ??*/ 'Username',
                              //         style: TextStyle(
                              //             fontSize: 20,
                              //             // color: Colors.white
                              //             color: Colors.blue,
                              //             // color: Colors.grey[600],
                              //             fontWeight: FontWeight.w600
                              //         ),
                              //       ),
                              //       SizedBox(width: 10,)
                              //     ],
                              //   ),
                              // ),
                              // MarqueeText(
                              //   text: name,
                              //   style: TextStyle(
                              //       fontSize: 20,
                              //       color: Colors.white
                              //   ),
                              // ),
                              // Marquee(
                              //   direction: Axis.horizontal,
                              //   animationDuration: Duration(milliseconds: 5000),
                              //   backDuration: Duration(milliseconds: 5000),
                              //   textDirection: TextDirection.ltr,
                              //   child: Text(
                              //     name,
                              //     style: TextStyle(fontSize: 20, color: Colors.white),
                              //   ),
                              // ),
                              const SizedBox(height: 4),

                              //todo: controllare se userpreferences.islogged() == true
                              /*userProvider.user.name == null ? Text(
                                // 'Nome Cognome',
                                // userProvider.user != null && userProvider.user.name != null ? userProvider.user.name : 'Ospite',
                                'Ospite',
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.white
                                    color: Colors.blue,
                                    // color: Colors.grey[700],
                                    fontWeight: FontWeight.w600
                                ),
                              ) :*/ /*userProvider.user != null && *//*(*//*userProvider.user.name.isNotEmpty *//*userProvider.user.name != null*//* ? Text(
                                // 'Nome Cognome',
                                // userProvider.user != null && userProvider.user.name != null ? userProvider.user.name : 'Ospite',
                                userProvider.user.name,
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.white
                                    color: Colors.blue,
                                    // color: Colors.grey[700],
                                    fontWeight: FontWeight.w600
                                ),
                              )*/ /*: *//*userProvider.user != null && *//**//*(*//**//*userProvider.user.name.isEmpty*//**//*&& (userProvider.user.name == '' || userProvider.user.name == null)*//**//* ?*/ Tooltip(
                                message: userProvider.user?.id != null && (userProvider.user!.name == null || userProvider.user!.name == '') ? "Impostazioni  >  Nome" : '',
                                triggerMode: TooltipTriggerMode.tap,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[200]
                                ),
                                // verticalOffset: 0,
                                margin: EdgeInsets.only(left: 100),
                                child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.45,
                                      child: Text(
                                      // 'Nome Cognome',
                                      // userProvider.user != null && userProvider.user.name != null ? userProvider.user.name : 'Ospite',
                                        userProvider.user?.id != null && userProvider.user!.name != null && userProvider.user!.name != '' ? userProvider.user!.name! : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            // color: Colors.white
                                            color: Colors.blue,
                                            // color: Colors.grey[700],
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    // Image.asset(
                                    //   'assets/png/warning_circle.png',
                                    //   height: 12,
                                    //   // width: MediaQuery.of(context).size.width * .7,
                                    //   fit: BoxFit.cover,
                                    // ),
                                    Visibility(
                                      // visible: userProvider.user != null && (userProvider.user!.name == null || userProvider.user!.name == ''),
                                      visible: false,
                                      // visible: userProvider.user?.id != null && userProvider.user!.name != null && userProvider.user!.name != '' ? true : false,
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.orangeAccent,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2.5),
                              // userProvider.user != null && userProvider.user.phone_number != null && userProvider.user.phone_number != '' ? Text(
                              //   /*userProvider.user != null && userProvider.user.phone_number != null ? */userProvider.user.phone_number/* : '+39 347 261 6594'*/,
                              //   style: TextStyle(
                              //       fontSize: 12,
                              //       // color: Colors.white
                              //       // color: Colors.blue,
                              //       color: Colors.grey[500],
                              //       fontWeight: FontWeight.w600
                              //   ),
                              // ) : SizedBox(),
                              userProvider.user != null && userProvider.user!.username != null && userProvider.user!.username != '' ? Text(
                                /*userProvider.user != null && userProvider.user.phone_number != null ? */'@' + userProvider.user!.username!/* : '+39 347 261 6594'*/,
                                style: TextStyle(
                                    fontSize: 12,
                                    // color: Colors.white
                                    // color: Colors.blue,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500
                                ),
                              ) : SizedBox(),
                              userProvider.user != null && userProvider.user!.phone != null && userProvider.user!.phone != '' ? const SizedBox(height: 4) : SizedBox(),
                              Text(
                                // 'username@nurebo.com',
                                userProvider.user != null && userProvider.user!.email != null ? userProvider.user!.email! : '',
                                style: TextStyle(
                                    fontSize: 12,
                                    // color: Colors.white
                                    // color: Colors.blue,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 10,)
                            ],
                          ),
                          // Spacer(),
                          // CircleAvatar(
                          //   radius: 24,
                          //   backgroundColor: Color.fromRGBO(30, 60, 168, 1),
                          //   child: Icon(Icons.add_comment_outlined, color: Colors.white),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(/*color: Colors.grey[500],*/ indent: 15, endIndent: 20, height: 0),
                const SizedBox(height: 5),

                // ListTile(
                //   title: Text('Cerca'),
                //   leading: Icon(Icons.search_rounded),
                //   onTap: (){
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //           duration: const Duration(milliseconds: 500),
                //           alignment: Alignment.center,
                //           type: PageTransitionType.fade,
                //           // child: SearchScreen()
                //       ),
                //     );
                //   },
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 10.0, bottom: 7, top: 10),
                //   // child: Text(
                //   //   'Cerca',
                //   //   style: TextStyle(
                //   //     color: Colors.grey[900],
                //   //     fontWeight: FontWeight.w600,
                //   //
                //   //   ),
                //   // ),
                // ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //   child: Row(
                //     // mainAxisAlignment: MainAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: MediaQuery.of(context).size.width * 0.7,
                //         child: TextField(
                //           style: TextStyle(color: Colors.grey[800]),
                //           controller: searchController,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.symmetric(
                //                 horizontal: 20,
                //                 vertical: 15
                //             ),
                //             // hintText: 'Cerca utenti, eventi o appuntamenti',
                //             hintText: 'Cerca...',
                //             hintStyle: TextStyle(color: Colors.grey),
                //             prefixIcon: Icon(Icons.search, color: Colors.grey),
                //             suffixIcon: InkWell(
                //               onTap: (){
                //                 // Navigator.push(
                //                 //   context,
                //                 //   PageTransition(
                //                 //       duration: const Duration(milliseconds: 500),
                //                 //       alignment: Alignment.center,
                //                 //       type: PageTransitionType.fade,
                //                 //       child: SearchScreen(
                //                 //         text: searchController.text,
                //                 //       )
                //                 //   ),
                //                 // );
                //               },
                //               child: Icon(
                //                 Icons.arrow_forward,
                //                 color: Colors.blue
                //                 // color: Colors.grey,
                //
                //               ),
                //             ),
                //             // suffixIcon: Padding(
                //             //   padding: const EdgeInsets.all(8.0),
                //             //   child: ElevatedButton(
                //             //     style: ButtonStyle(
                //             //       backgroundColor: MaterialStateProperty.all(Colors.blue),
                //             //
                //             //     ),
                //             //     child: Icon(
                //             //         Icons.arrow_forward,
                //             //         // color: Colors.blue
                //             //         color: Colors.white
                //             //     ),
                //             //     onPressed: (){
                //             //
                //             //     },
                //             //   ),
                //             // ),
                //             filled: true,
                //             fillColor: Colors.white12,
                //             enabledBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5),
                //               borderSide: BorderSide(color: Colors.grey.withOpacity(0.7)),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5),
                //               borderSide: BorderSide(color: Colors.grey.withOpacity(0.7)),
                //             ),
                //           ),
                //         ),
                //       ),
                //       // SizedBox(width: 10,),
                //       // Container(
                //       //   width: 60,
                //       //   height: 40,
                //       //   child: /*ElevatedButton(
                //       //       child: Text(
                //       //           "Cerca"
                //       //       ),
                //       //       onPressed: (){
                //       //
                //       //       }
                //       //   ),*/
                //       //   ElevatedButton(
                //       //     style: ButtonStyle(
                //       //       backgroundColor: MaterialStateProperty.all(Colors.blue),
                //       //
                //       //     ),
                //       //     child: Icon(
                //       //         Icons.arrow_forward,
                //       //         // color: Colors.blue
                //       //         color: Colors.white
                //       //     ),
                //       //     onPressed: (){
                //       //
                //       //     },
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // ),

                !UserPreferences.getIsLogged()! /*&& TabNavigator().tabItem == "Page1"*/ || userProvider.user == null ? ListTile(
                  title: Text(
                    // 'Accedi o Registrati',
                    // 'Accedi/Registrati',
                    'Accedi o Registrati',
                    // 'Accedi',
                    style: TextStyle(
                      // color: Colors.grey[800]
                        color: Colors.blue[500]
                    ),
                  ),
                  leading: Icon(
                      // Icons.person,
                      Icons.login_outlined,
                      color: Colors.blue[400]
                    // color: Colors.grey[600],
                  ),
                  // leading: SizedBox(),
                  // leading: Container(
                  //   width: 10,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: Colors.blue[300],
                  //   ),
                  // ),
                  // trailing: Padding(
                  //     padding: EdgeInsets.only(
                  //       // right: MediaQuery.of(context).size.width * 0.05
                  //         right: 10
                  //     ),
                  //     // child: Container(
                  //     //     width: 10,
                  //     //     height: 10,
                  //     //     decoration: BoxDecoration(
                  //     //         shape: BoxShape.circle,
                  //     //         // color: Colors.greenAccent
                  //     //         color: Colors.blue[400]
                  //     //     )
                  //     // ),
                  //     child: Icon(
                  //       Icons.login_outlined,
                  //       // color: Colors.blue[500]
                  //       // Icons.warning_amber_rounded,
                  //       color: Colors.blue[400],
                  //     )
                  // )/* : SizedBox()*/,
                  onTap: () async {
                    // Navigator.push(
                    //   context,
                    //   PageTransition(
                    //       duration: const Duration(milliseconds: 500),
                    //       alignment: Alignment.center,
                    //       type: PageTransitionType.fade,
                    //       // child: NotificationScreen()
                    //       child: NotificationsScreen()
                    //   ),
                    // ).then((value) => Navigator.pop(context));
                    await Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                          child: LoginScreen(),
                          duration: const Duration(milliseconds: 800),
                          type: PageTransitionType.fade,
                        ),
                            (route) => false
                    );
                  },
                ) : const SizedBox(height: 0, width: 0,),
                !UserPreferences.getIsLogged()! ? Divider(indent: 15, endIndent: 20,): SizedBox(height: 0, width: 0,),

                // Divider(indent: 15, endIndent: 20,),
                // SizedBox(height: 15,),
                // !Utils.isSocial && !Utils.isBusiness ? ListTile(
                //   title: Text(
                //     'Notifiche',
                //     style: TextStyle(
                //         color: Colors.grey[800]
                //     ),
                //   ),
                //   leading: Icon(
                //       Icons.notifications_outlined,
                //     // color: Colors.grey[600],
                //   ),
                //   // trailing: Provider.of<SocketProvider>(context, listen: true).bookingNotificationList.length > 0 ? Padding(
                //   // trailing: DateTime.parse(socketProvider.bookingNotificationList.first['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastUpbookingNotification() ?? DateTime.now().toIso8601String())) ? Padding(
                //   trailing: DateTime.parse(socketProvider.notificationList.isNotEmpty ? socketProvider.notificationList.first['sent_at'] : DateTime.now().subtract(Duration(days: 2)).toIso8601String()).isAfter(DateTime.parse(UserPreferences.getUserLastUpdateNotification() ?? DateTime.now().subtract(Duration(hours: 1)).toIso8601String())) ? Padding(
                //     padding: EdgeInsets.only(
                //       // right: MediaQuery.of(context).size.width * 0.05
                //         right: UserPreferences.getIsLogged()! == true ? 10 : 0,
                //     ),
                //     child: UserPreferences.getIsLogged()! == true ? Container(
                //         width: 10,
                //         height: 10,
                //         decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             // color: Colors.greenAccent
                //             color: Colors.blue[500]
                //         )
                //     ) : SizedBox(),
                //   ) : SizedBox(),
                //   onTap: () {
                //     if(UserPreferences.getIsLogged()!){
                //       Navigator.push(
                //         context,
                //         PageTransition(
                //             duration: const Duration(milliseconds: 500),
                //             alignment: Alignment.center,
                //             type: PageTransitionType.fade,
                //             // child: NotificationScreen()
                //             child: NotificationsScreen()
                //         ),
                //         // ).then((value) => Navigator.pop(context));
                //       );
                //
                //       Future.delayed(
                //         const Duration(milliseconds: 500),
                //         () => Scaffold.of(context).openEndDrawer()
                //       );
                //       // Scaffold.of(context).openEndDrawer();
                //     }
                //   },
                // ) : SizedBox(),

                Visibility(
                  visible: false,
                  child: ListTile(
                    title: Text(
                      'Novità',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    leading: Icon(
                      Icons.newspaper_outlined,
                      // color: Colors.grey[600],
                    ),
                    // trailing: Provider.of<SocketProvider>(context, listen: true).bookingNotificationList.length > 0 ? Padding(
                    // trailing: DateTime.parse(socketProvider.bookingNotificationList.first['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastUpbookingNotification() ?? DateTime.now().toIso8601String())) ? Padding(
                    // trailing: DateTime.parse(socketProvider.notificationList.isNotEmpty ? socketProvider.notificationList.first['sent_at'] : DateTime.now().subtract(Duration(days: 2)).toIso8601String()).isAfter(DateTime.parse(UserPreferences.getUserLastUpdateNotification() ?? DateTime.now().subtract(Duration(hours: 1)).toIso8601String())) ? Padding(
                    //   padding: EdgeInsets.only(
                    //     // right: MediaQuery.of(context).size.width * 0.05
                    //       right: 10
                    //   ),
                    //   child: Container(
                    //       width: 10,
                    //       height: 10,
                    //       decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           // color: Colors.greenAccent
                    //           color: Colors.blue[500]
                    //       )
                    //   ),
                    // ) : SizedBox(),
                    onTap: () {
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: const NewsScreen()
                          ),
                          // ).then((value) => Navigator.pop(context));
                        );

                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                  ),
                ),
                // Divider(indent: 15, endIndent: 20,),

                Visibility(
                  visible: Utils.isEventsEnabled,
                  child: ListTile(
                    title: Text(
                      'Biglietti',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    leading: Icon(
                      Icons.airplane_ticket_outlined,
                      // Istos.plane_ticket,
                      size: 26,
                    ),
                    onTap: () {
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: UserEventReservationsScreen(
                                user: userProvider.user,
                              )
                          ),
                        );

                        Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Scaffold.of(context).openEndDrawer()
                        );
                      }
                    },
                  ),
                ),

                Visibility(
                  visible: !Utils.isBusiness && !Utils.isSocial,
                  child: ListTile(
                    title: Text(
                      'Prenotazioni',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    leading: Icon(
                        // Icons.book_outlined
                        Icons.event
                    ),
                    onTap: () {
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            child: UserBookingListScreen(
                              user: userProvider.user,
                            )
                          ),
                        );

                        // Navigator.pop(context);
                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                  ),
                ),
                // ListTile(
                //   title: Text(
                //       'Pagamenti',
                //     style: TextStyle(
                //         color: Colors.grey[800]
                //     ),
                //   ),
                //   leading: Icon(Icons.credit_card_outlined),
                //   // leading: Icon(Icons.payment_outlined),
                //   onTap: (){},
                // ),

                //todo: da attivare ed implementare lo screen degli ordini
                // ListTile(
                //   title: Text(
                //     'Ordini',
                //     style: TextStyle(
                //         color: Colors.grey[800]
                //     ),
                //   ),
                //   leading: Icon(
                //       Icons.shopping_bag_outlined
                //       // Icons.bookmark_border_rounded
                //   ),
                //   onTap: (){
                //     if(UserPreferences.getIsLogged()!){
                //       Navigator.push(
                //         context,
                //         PageTransition(
                //             duration: const Duration(milliseconds: 500),
                //             alignment: Alignment.center,
                //             type: PageTransitionType.fade,
                //             child: UserOrdersScreen(
                //
                //             )
                //         ),
                //       );
                //       Future.delayed(
                //           const Duration(milliseconds: 500),
                //               () => Scaffold.of(context).openEndDrawer()
                //       );
                //       // Scaffold.of(context).openEndDrawer();
                //     }
                //   },
                //   hoverColor: Colors.transparent,
                //   focusColor: Colors.transparent,
                // ),

                Visibility(
                  // visible: !Utils.isBusiness && !Utils.isSocial,
                  visible: false,
                  child: ListTile(
                    title: Text(
                      'Post',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    leading: Icon(
                        Icons.image_outlined
                        // Icons.bookmark_border_rounded
                    ),
                    onTap: (){
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: PostFeedScreen(

                              )
                          ),
                        );
                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),

                Visibility(
                  visible: !Utils.isBusiness,
                  child: ListTile(
                    title: Text(
                      'Seguiti',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    leading: Icon(
                        Icons.bookmark_outline
                        // Icons.bookmark_border_rounded
                    ),
                    onTap: (){
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: SavedBusinessScreen(

                              )
                          ),
                        );
                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),

                // Divider(indent: 20, endIndent: 20,),
                Visibility(
                  visible: !Utils.isBusiness && !Utils.isSocial,
                  child: ListTile(
                    title: Text(
                      // 'Salvati',
                      'Preferiti',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    // leading: Icon(Icons.favorite_border_outlined),
                    leading: Icon(Icons.star_outline),
                    onTap: (){
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: FavoritesScreen(
                                // user: userProvider.user,
                              )
                          ),
                        );
                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),

                Visibility(
                  visible: !Utils.isBusiness && !Utils.isSocial,
                  child: ListTile(
                    title: Text(
                      // 'Salvati',
                      'Piaciuti',
                      style: TextStyle(
                          color: Colors.grey[800]
                      ),
                    ),
                    // leading: Icon(Icons.favorite_border_outlined),
                    leading: Icon(Icons.favorite_border_rounded),
                    onTap: (){
                      if(UserPreferences.getIsLogged()!){
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: PostLikedScreen(
                                // user: widget.user,
                                user: userProvider.user,
                              )
                          ),
                        );
                        Future.delayed(
                            const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                        );
                        // Scaffold.of(context).openEndDrawer();
                      }
                    },
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),

                // ListTile(
                //   title: Text('Appuntamenti'),
                //   leading: Icon(Icons.event_note_outlined),
                //   onLongPress: (){},
                // ),
                Divider(indent: 15, endIndent: 20,),
                // ListTile(
                //   title: Text(
                //       'Statistiche',
                //     style: TextStyle(
                //         color: Colors.grey[800]
                //     ),
                //   ),
                //   leading: Icon(Icons.insert_chart_outlined),
                //   onTap: (){},
                // ),
                ListTile(
                  title: Text(
                      'Impostazioni',
                    style: TextStyle(
                        color: Colors.grey[800]
                    ),
                  ),
                  leading: Icon(Icons.settings_outlined),
                  onTap: () {
                    if(UserPreferences.getIsLogged()!){
                      Navigator.push(
                        context,
                        PageTransition(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            child: SettingsScreen()
                        ),
                      );
                      Future.delayed(
                          const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                      );
                      // Scaffold.of(context).openEndDrawer();
                    }
                  },
                ),
                // Divider(indent: 20, endIndent: 20,),

                // ListTile(
                //   title: Text(
                //       'Contattaci',
                //     style: TextStyle(
                //         color: Colors.grey[800]
                //     ),
                //   ),
                //   // leading: Icon(Icons.help_center_outlined),
                //   leading: Icon(Icons.help_outline_outlined),
                //   onTap: () async {
                //     if(UserPreferences.getIsLogged()){
                //       // Future.delayed(
                //       //     const Duration(milliseconds: 500),
                //       //     () => Scaffold.of(context).openEndDrawer()
                //       // );
                //       Scaffold.of(context).openEndDrawer();
                //     }
                //   },
                // ),
                // ListTile(
                //   // title: Text('Segnala un bug'),
                //   title: Text(
                //     'Segnala un bug',
                //     style: TextStyle(
                //       color: Colors.grey[800]
                //     ),
                //   ),
                //   // leading: Icon(Icons.help_center_outlined),
                //   leading: Icon(Icons.bug_report_outlined),
                //   onTap: () async {
                //     if(UserPreferences.getIsLogged()){
                //       // Future.delayed(
                //       //     const Duration(milliseconds: 500),
                //       //     () => Scaffold.of(context).openEndDrawer()
                //       // );
                //       Scaffold.of(context).openEndDrawer();
                //     }
                //   },
                // ),

                // UserPreferences.getIsLogged()! ? Column(
                //   children: [
                //     Divider(indent: 15, endIndent: 20,),
                //     ListTile(
                //       title: Text(
                //         'Esci',
                //         style: TextStyle(
                //             color: Colors.grey[800]
                //         ),
                //       ),
                //       leading: Icon(Icons.logout),
                //       onTap: () async {
                //         await logOut();
                //       },
                //     ),
                //   ],
                // ) : SizedBox(height: 0, width: 0,),

                SizedBox(height: 15,),
                // ListTile(
                //     title: Text('Close'),
                //     leading: Icon(Icons.close),
                //     onTap: (){
                //       Navigator.of(context).pop();}
                // ),
              ]
          ),
        ),
      ),
    );
  }
}
