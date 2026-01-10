import 'dart:convert';
import 'dart:io';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/screens/user_booking_detail_screen.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class NotificationsScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  // final User user;

  NotificationsScreen({Key? key, /*this.user*/});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // List notificationList = [];
  // var sqfliteProvider;
  late SocketProvider socketProvider;
  late UserProvider userProvider;

  // Future getDateNotifications() async {
  //   List localDateNotificationList = await sqfliteProvider.query(
  //       'booking_notification',
  //       orderBy: 'sent_at DESC'
  //       // where: 'id = ? AND title = ?',
  //       // whereArgs: [2, 'Bob']
  //   );
  //   //print(localDateNotificationList);
  //   // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
  //   //
  //   // Map<String, dynamic> body = {
  //   //   'user_id': widget.user.id,
  //   // };
  //   //
  //   // var response = await http.post(
  //   //     url,
  //   //     body: jsonEncode(body),
  //   //     headers: {
  //   //       'Accept': '*/*',
  //   //       'Content-Type': 'application/json',
  //   //       'Accept-encoding': 'gzip, deflate',
  //   //       'connection': 'keep-alive',
  //   //     }
  //   // );
  //   //
  //   // //print("ticketUsers response.statusCode:");
  //   // //print(response.statusCode);
  //   // if(response.statusCode >= 200 && response.statusCode < 400) {
  //   //   var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       notificationList = localDateNotificationList;
  //       // results.addAll(jsonData);
  //       // results.shuffle();
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //   //   //print(jsonData);
  //   //   return jsonData;
  //   // }
  // }

  @override
  void initState() {
    super.initState();
    // /*await */UserPreferences.init();
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // sqfliteProvider = Provider.of<SqfliteProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    UserPreferences.setUserLastUpdateNotification(DateTime.now());
    UserPreferences.setUserLastOpenNotification();
    // //print("init UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());

    //todo: da levare quando riuscirò ad aggiornare "myappointmentlist" (e i tutti i campi) in provider quando arriva una cancellazione o un appuntamento al background service socket.io
    // socketProvider.getLocalAppointmentNotifications(userProvider.user);
    // Create anonymous function:
    // if(UserPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(userProvider.user);
    //   } ();
    // }

    // //print('sg448sg4sgsocketProvider.socket.id');
    // //print(socketProvider.socket.id);
  }

  @override
  void dispose() {
    super.dispose();
    UserPreferences.setUserLastUpdateNotification(DateTime.now());
    UserPreferences.setUserLastClosedNotification();
    // //print("dispose UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());
  }

  @override
  Widget build(BuildContext context) {
    // sqfliteProvider = Provider.of<SqfliteProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
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
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Notifiche',
          // 'Le mie prestazioni',
          style: TextStyle(
              color: Colors.blue,
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
      ),
      // appBar: PreferredSize(
      //   // preferredSize: Size.fromHeight(100),
      //   preferredSize: Size.fromHeight(55),
      //   // child: AppBar2(user: widget.user,),
      //   child: nureboAppBar(
      //     // user: userProvider.user,
      //     // user: widget.user,
      //   ),
      // ),
      // drawer: nureboDrawer(),
      // onDrawerChanged: (value){
      //   if(Utils.isSocial){
      //     //todo: false per nascondere bottombar
      //     //print(value);
      //     socketProvider.setBottomBarVisibility(!value);
      //   }
      // },
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: socketProvider.notificationList.isNotEmpty ? Container(
          // child: ListView.builder(
          child: ListView.separated(
              separatorBuilder: (context, i){
                return Divider(indent: 15, endIndent: 15,);
              },
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 0,
                bottom: 10
                // left: 10,
                // right: 10
              ),
              itemCount: socketProvider.notificationList.length,
              itemBuilder: (context, i) {
                //todo: passare tutto questo da booking_notification con socket.io
                // Prestazione prestazione = new Prestazione(
                //   id: socketProvider.notificationList[i]['prestazione_id'],
                //   duration: socketProvider.notificationList[i]['prestazione_duration'],
                //   image: socketProvider.notificationList[i]['prestazione_image'],
                //   price: socketProvider.notificationList[i]['prestazione_price'],
                //   title: socketProvider.notificationList[i]['prestazione_title'],
                //   description: socketProvider.notificationList[i]['prestazione_description'],
                //   business: new Business(
                //     profile_image: socketProvider.notificationList[i]['business_profile_image'],
                //     id: socketProvider.notificationList[i]['business_id'],
                //     is_booking_business: 1,
                //     name: socketProvider.notificationList[i]['business_name'],
                //     description: socketProvider.notificationList[i]['business_description'],
                //     category_id: socketProvider.notificationList[i]['category_id'],
                //     address: socketProvider.notificationList[i]['business_address'],
                //     phone_number: socketProvider.notificationList[i]['business_phone_number'],
                //     email: socketProvider.notificationList[i]['business_email'],
                //     max_contemporary_appointments: socketProvider.notificationList[i]['max_contemporary_appointments'],
                //   ),
                // );

                if(socketProvider.notificationList[i]['is_canceled'] != null) {
                  Map<String, dynamic> bookingNotification = {
                    "id": socketProvider.notificationList[i]['id'],
                    "booking_id": socketProvider.notificationList[i]['booking_id'],
                    'booking_price': socketProvider.notificationList[i]['booking_price'],
                    "booking_begin_at": socketProvider.notificationList[i]['booking_begin_at'],
                    "prestazione_id": socketProvider.notificationList[i]['prestazione_id'],
                    'prestazione_image': socketProvider.notificationList[i]['prestazione_image'],
                    'prestazione_title': socketProvider.notificationList[i]['prestazione_title'],
                    'is_canceled': socketProvider.notificationList[i]['is_canceled'],
                    'business_id': socketProvider.notificationList[i]['business_id'],
                    'business_name': socketProvider.notificationList[i]['business_name'],
                    'sent_at': socketProvider.notificationList[i]['sent_at'],
                  };

                  Booking? appun;
                  for(Booking e in socketProvider.myAppointmentsList){
                    if(e.id == socketProvider.notificationList[i]['booking_id']){
                      appun = e;
                    }
                  }

                  return /*Dismissible(
                    // key: ObjectKey(socketProvider.notificationList[i]),
                    key: ObjectKey(socketProvider.notificationList[i]['id']),
                    // key: Key(socketProvider.notificationList[i]['id']),
                    // key: UniqueKey(),
                    // behavior: HitTestBehavior.translucent,
                    direction: DismissDirection.endToStart,
                    // dragStartBehavior: DragStartBehavior.start,
                    // crossAxisEndOffset: 22,
                    // confirmDismiss: (direction){
                    //
                    // },
                    onDismissed: (direction) async {
                      setState(() async {
                        // items.removeAt(index);
                        await socketProvider.deleteLocalNotification(
                          'appointment_notification',
                          // notification['booking_id'],
                          bookingNotification['id'].toString(),
                          i
                        );
                      });
                    },
                    child: */InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: (){
                        Navigator.push(
                            context,
                            PageTransition(
                                duration: const Duration(milliseconds: 500),
                                alignment: Alignment.center,
                                type: PageTransitionType.fade,
                                child: BookingDetailScreen(
                                  booking: appun,
                                )
                              // child: TicketDetailScreen(
                              //   user: widget.user,
                              //   singleEventTicket: singleEventTicket,
                              // ),
                            )
                        );
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
                              padding: EdgeInsets.only(left: 10, /*top: 10, bottom: 10*/),
                              child: Container(
                                width: 90,
                                height: 80,
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: bookingNotification['prestazione_image'] != null /*&& notification['prestazione_image'] != ''*/ ? FutureImage(
                                    // prestazione.image,
                                    bookingNotification['prestazione_image'],
                                    width: MediaQuery.of(context).size.width,
                                  ) :/* Image.network(
                                  // prestazione.image,
                                  notification['business_profile_image'],
                                  fit: BoxFit.cover,
                                )*/SizedBox(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                  //margin: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                            bookingNotification['is_canceled'] == 1 ? Expanded(
                              //alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
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
                                        /*'@' + */bookingNotification['business_name'],
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
                                                    text: "La prenotazione di ",
                                                    // style: TextStyle(
                                                    //   color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: prestazione.title,
                                                    text: bookingNotification['prestazione_title'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      // color: Colors.blue[500]
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: " da ",
                                                    // style: TextStyle(
                                                    //     color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: prestazione.business.name,
                                                    text: bookingNotification['business_name'],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    // text: "Parteciperà a ",
                                                    text: " per il ",
                                                    // style: TextStyle(
                                                    //   color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: DateFormat.yMMMMd('it_IT').format(DateTime.parse(bookingNotification['booking_begin_at']).add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: ' alle ',
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: DateTime.tryParse(bookingNotification['booking_begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: ' è stata ',

                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: 'annullata',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.red[600]
                                                    ),
                                                  ),
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
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        timeAgo.format(
                                          // DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            locale: 'it'
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.0,
                                            // color: Colors.white
                                            color: Colors.grey[500]
                                        ),
                                      ),
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
                            ) : Expanded(
                              //alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
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
                                        /*'@' + */bookingNotification['business_name'],
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
                                                    text: "La prenotazione di ",
                                                    // style: TextStyle(
                                                    //   color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: prestazione.title,
                                                    text: bookingNotification['prestazione_title'].toString().trim(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      // color: Colors.blue[500]
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: " da ",
                                                    // style: TextStyle(
                                                    //     color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: prestazione.business.name,
                                                    text: bookingNotification['business_name'],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    // text: "Parteciperà a ",
                                                    text: " per il ",
                                                    // style: TextStyle(
                                                    //   color: Colors.grey[900]
                                                    // )
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: DateFormat.yMMMMd('it_IT').format(DateTime.parse(bookingNotification['booking_begin_at'])).toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: ' alle ',
                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: DateTime.parse(bookingNotification['booking_begin_at']).toString().substring(11, 16),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                  // TextSpan(
                                                  //   // text: socketProvider.notificationList[i]['created_at'],
                                                  //   text: ' è stata effettuata',
                                                  // ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: ' è stata ',

                                                  ),
                                                  TextSpan(
                                                    // text: socketProvider.notificationList[i]['created_at'],
                                                    text: 'effettuata',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.green[600]
                                                    ),
                                                  ),
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
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        timeAgo.format(
                                          // DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            locale: 'it'
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.0,
                                            // color: Colors.white
                                            color: Colors.grey[500]
                                        ),
                                      ),
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
                            Visibility(
                              // Opacity(
                              // visible: DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              visible: DateTime.parse(bookingNotification['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 15, left: 20, ),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              // Opacity(
                              // visible: !DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              visible: !DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 15, left: 20, ),
                              ),
                            ),
                            // Divider(height: 5, thickness: 5,),
                          ],
                        ),
                      ),
                    // ),
                  );
                }
                else if(socketProvider.notificationList[i]['status'] != null) {
                  Map<String, dynamic> friendshipNotification = {
                    "id": socketProvider.notificationList[i]['id'],
                    "status": socketProvider.notificationList[i]['status'],
                    "user_id": socketProvider.notificationList[i]['user_id'],
                    "recipient_id": socketProvider.notificationList[i]['recipient_id'],
                    'user_image': socketProvider.notificationList[i]['user_image'],
                    'user_username': socketProvider.notificationList[i]['user_username'],
                    'user_name': socketProvider.notificationList[i]['user_name'],
                    'sent_at': socketProvider.notificationList[i]['sent_at'],
                  };

                  return Dismissible(
                    // key: ObjectKey(socketProvider.notificationList[i]),
                    key: ObjectKey(socketProvider.notificationList[i]['id']),
                    // key: UniqueKey(),
                    // behavior: HitTestBehavior.translucent,
                    direction: DismissDirection.endToStart,
                    // dragStartBehavior: DragStartBehavior.start,
                    // crossAxisEndOffset: 22,
                    // confirmDismiss: (direction){
                    //
                    // },
                    onDismissed: (direction) async {
                      // setState(() {
                      // items.removeAt(index);
                      await socketProvider.deleteLocalNotification(
                          'friendship_notification',
                          // notification['booking_id'],
                          friendshipNotification['id'].toString(),
                          i
                      );
                      // });
                    },
                    child: InkWell(
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
                              padding: EdgeInsets.only(
                                left: 10, /*top: 10, bottom: 10*/),
                              child: Container(
                                width: 90,
                                height: 80,
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                  child: FutureImage(
                                    // prestazione.image,
                                    friendshipNotification['user_image'],
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  //margin: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                            Expanded(
                              //alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, bottom: 10, top: 10),
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
                                        friendshipNotification['user_name'],
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
                                                    text: '@' + friendshipNotification['user_username'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w700,
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
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 30,
                                          // width: MediaQuery.of(context).size.width * 0.2,
                                          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
                                                // backgroundColor: MaterialStateProperty.all(Colors.red[500]),
                                              ),
                                              onPressed: () {
                                                socketProvider.declineFriendshipRequest(
                                                  friendshipNotification['user_id'],
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Rifiuta",
                                                    style: TextStyle(
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        Container(
                                          height: 30,
                                          // width: MediaQuery.of(context).size.width * 0.2,
                                          margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.blue[400]),
                                                // padding: MaterialStateProperty.all(),
                                              ),
                                              onPressed: () {
                                                socketProvider.acceptFriendshipRequest(
                                                    friendshipNotification['user_id'],
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Accetta",
                                                    style: TextStyle(
                                                      fontSize: 12
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        timeAgo.format(
                                          // DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            DateTime.parse(socketProvider.notificationList[i]['sent_at']),
                                            locale: 'it'
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.0,
                                            // color: Colors.white
                                            color: Colors.grey[500]
                                        ),
                                      ),
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
                            Visibility(
                              // Opacity(
                              // visible: DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              visible: DateTime.parse(
                                  friendshipNotification['sent_at']).isAfter(
                                  DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 15, left: 20,),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              // Opacity(
                              // visible: !DateTime.parse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                              visible: !DateTime.parse(
                                  socketProvider.notificationList[i]['sent_at'])
                                  .isAfter(DateTime.parse(UserPreferences
                                  .getUserLastClosedNotification() ??
                                  DateTime.now().toIso8601String())),
                              // opacity: DateTime.parse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.parse(UserPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 15, left: 20,),
                              ),
                            ),
                            // Divider(height: 5, thickness: 5,),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                else {
                  return SizedBox();
                }
              }
            // ImageCard(
            //   imageData: imageList[index],
            // ),
          ),
        ) : ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .1,),
            Center(
              child: Image.asset(
                'assets/png/Saly-14.png',
                height: MediaQuery.of(context).size.height * .4,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                'Non ci sono notifiche',
                // "Non c'è' nessuna notifica...",
                // 'Le mie prestazioni',
                style: TextStyle(
                  // color: Colors.blue,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                    fontSize: 20
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
