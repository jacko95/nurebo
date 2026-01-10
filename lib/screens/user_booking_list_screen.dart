import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/user_booking_detail_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;

import '../main.dart';


class UserBookingListScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  final User? user;

  const UserBookingListScreen({super.key, this.user});

  @override
  _UserBookingListScreenState createState() => _UserBookingListScreenState();
}

class _UserBookingListScreenState extends State<UserBookingListScreen> {
  // List myAppointments = [];
  // var results;
  late SocketProvider socketProvider;
  // Future a;
  late UserProvider userProvider;

  // Future getUserAppointments() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking/user");
  //
  //   Map<String, dynamic> body = {
  //     'user_id': widget.user.id,
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
  //   //print("ticketUsers response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       myAppointments = jsonData;
  //       // results.addAll(jsonData);
  //       // results.shuffle();
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     //print(jsonData);
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    // getUserAppointments();
    // a = socketProvider.getUserAppointments(widget.user);

    // streamController.stream.listen(
    broadcastStream.listen(
      (event) {
        // //print('event urkalllww');
        // //print(event);
        setState(() {
          socketProvider.setIsCanceledBooking(event);
        });

      },
      cancelOnError: false,
    );

    // Future.wait([
    //   socketProvider.getUserAppointments(userProvider.user!),
    // ]);
    //todo: da levare quando riuscirò ad aggiornare "myappointmentlist" (e i tutti i campi) in provider quando arriva una cancellazione o un appuntamento al background service socket.io
    // socketProvider.getUserAppointments(userProvider.user!);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    // //print('socketProvider.myAppointments.length');
    // //print(socketProvider.myAppointmentsList.length);

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   titleSpacing: 0,
      //   // leadingWidth: 40,
      //   leading: IconButton(
      //     icon: Icon(
      //       // Icons.arrow_back,
      //       Icons.arrow_back_ios_new,
      //       size: 16,
      //       color: Colors.grey[500],
      //     ),
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //   ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   elevation: 0,
      //   title: Text(
      //     // 'I miei appuntamenti',
      //     'Le mie prenotazioni',
      //     style: TextStyle(
      //       color: Colors.blue,
      //       // color: Colors.grey[800],
      //       fontWeight: FontWeight.w600,
      //       fontSize: 15
      //     ),
      //   ),
      // ),
      appBar: const PreferredSize(
        // preferredSize: Size.fromHeight(100),
        preferredSize: Size.fromHeight(55),
        // child: AppBar2(user: widget.user,),
        child: NureboAppBar(
          // user: userProvider.user,
          // user: widget.user,
        ),
      ),
      // body: StreamProvider(
      // // body: StreamProvider.value(
      // //   initialData: streamController.stream,
      //   initialData: broadcastStream,
      //   // value: streamController.stream,
      //   // create: (_) => streamController.stream,
      //   create: (_) => broadcastStream,
      //   updateShouldNotify: (dynamic previous, dynamic next) => true,
      //   builder: (context, snapshot) {
      //     // //print('ortolanoooooo');
      //   }
      // ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: socketProvider.myAppointmentsList.isNotEmpty ? ListView.separated(
            separatorBuilder: (context, i){
              return Divider(indent: 15, endIndent: 20,);
            },
            padding: EdgeInsets.only(top: 10, bottom: 12),
            // itemCount: myAppointments.length,
            itemCount: socketProvider.myAppointmentsList.length,
            itemBuilder: (context, index){
              //todo: da rifare i nomi dei campi anche in nodejs
              //     Date booking = new Date(
              //       id: myAppointments[index]['booking_id'],
              //       isCanceled: myAppointments[index]['is_canceled'],
              //       note: myAppointments[index]['note'],
              //       user_id: myAppointments[index]['user_id'].toString(),
              //       prestazione: new Prestazione(
              //         duration: myAppointments[index]['prestazione_duration'],
              //         image: myAppointments[index]['prestazione_image'],
              //         price: myAppointments[index]['prestazione_price'],
              //         title: myAppointments[index]['prestazione_title'],
              //         description: myAppointments[index]['prestazione_description'],
              //         business_id: myAppointments[index]['business_id'],
              //       ),
              //       business: new Business(
              //         profile_image: myAppointments[index]['business_profile_image'],
              //         id: myAppointments[index]['business_id'],
              //         is_booking_business: 1,
              //         name: myAppointments[index]['business_name'],
              //         description: myAppointments[index]['business_description'],
              //         category_id: myAppointments[index]['category_id'],
              //         address: myAppointments[index]['business_address'],
              //         phone_number: myAppointments[index]['business_phone_number'],
              //         max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
              //
              //       ),
              //       // is_paid: myAppointments[index]['is_paid'],
              //       begin_at: DateTime.parse(myAppointments[index]['begin_at']),
              //       end_at: DateTime.parse(myAppointments[index]['begin_at']).add(Duration(minutes: myAppointments[index]['prestazione_duration'].toInt())),
              //       created_at: DateTime.parse(myAppointments[index]['created_at']),
              //     );
              // Date booking = new Date(
              //   id: socketProvider.myAppointments[index]['booking_id'],
              //   isCanceled: socketProvider.myAppointments[index]['is_canceled'],
              //   note: socketProvider.myAppointments[index]['note'],
              //   user_id: socketProvider.myAppointments[index]['user_id'].toString(),
              //   prestazione: new Prestazione(
              //     duration: socketProvider.myAppointments[index]['prestazione_duration'],
              //     image: socketProvider.myAppointments[index]['prestazione_image'],
              //     price: socketProvider.myAppointments[index]['prestazione_price'],
              //     title: socketProvider.myAppointments[index]['prestazione_title'],
              //     description: socketProvider.myAppointments[index]['prestazione_description'],
              //     business_id: socketProvider.myAppointments[index]['business_id'],
              //   ),
              //   business: new Business(
              //     profile_image: socketProvider.myAppointments[index]['business_profile_image'],
              //     id: socketProvider.myAppointments[index]['business_id'],
              //     is_booking_business: 1,
              //     name: socketProvider.myAppointments[index]['business_name'],
              //     description: socketProvider.myAppointments[index]['business_description'],
              //     category_id: socketProvider.myAppointments[index]['category_id'],
              //     address: socketProvider.myAppointments[index]['business_address'],
              //     phone_number: socketProvider.myAppointments[index]['business_phone_number'],
              //     max_contemporary_appointments: socketProvider.myAppointments[index]['max_contemporary_appointments'],
              //
              //   ),
              //   // is_paid: myAppointments[index]['is_paid'],
              //   begin_at: DateTime.parse(socketProvider.myAppointments[index]['begin_at']).toLocal(),
              //   end_at: DateTime.parse(socketProvider.myAppointments[index]['begin_at']).toLocal().add(Duration(minutes: socketProvider.myAppointments[index]['prestazione_duration'].toInt())),
              //   created_at: DateTime.parse(socketProvider.myAppointments[index]['created_at']).toLocal(),
              // );

              return GestureDetector(
                onTap: (){
                  // //print(myAppointments[index]['single_event_title']);
                  // print(socketProvider.myAppointmentsList[index].begin_at!.toString());

                  if(!Utils.isBusiness ||
                      (Utils.isBusiness && socketProvider.myAppointmentsList[index].business!.id == Utils.business_id)){
                    Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: BookingDetailScreen(
                            booking: socketProvider.myAppointmentsList[index],
                            // user: widget.user,

                            // singleEventReservation: singleEventReservation,
                          ),
                        )
                    );
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: 'Scarica Nurebo!',
                      backgroundColor: Colors.grey[700],

                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 20.0, bottom: 0, top: 5),
                    //   child: Text(
                    //     timeAgo.format(
                    //       DateTime.parse(
                    //         socketProvider.myAppointmentsList[index].created_at!.toString()
                    //       ),
                    //       locale: 'it'
                    //     ),
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.w700,
                    //         fontSize: 11.0,
                    //         // color: Colors.white
                    //         color: Colors.grey[500]
                    //     ),
                    //   ),
                    // ),
                    ListTile(
                      leading: Container(
                        width: 80,
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
                        child: Hero(
                          tag: socketProvider.myAppointmentsList[index].prestazione!.image != null && socketProvider.myAppointmentsList[index].prestazione!.image != '' ? socketProvider.myAppointmentsList[index].prestazione! : socketProvider.myAppointmentsList[index].prestazione!.business!,
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(0),
                            child: socketProvider.myAppointmentsList[index].prestazione!.image != null && socketProvider.myAppointmentsList[index].prestazione!.image != '' ? FutureImage(
                              // cartData.orders[i].singleEventImage,
                              // booking.prestazione.image,
                              socketProvider.myAppointmentsList[index].prestazione!.image!,
                              width: MediaQuery.of(context).size.width,
                            ) : FutureImage(
                              // cartData.orders[i].singleEventImage,
                              // booking.prestazione.image,
                              socketProvider.myAppointmentsList[index].prestazione!.business!.profile_image!,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                      ),
                      title: Padding(
                        padding: EdgeInsets.only(
                            top: 0.0,
                            bottom: 0
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: Marquee(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GradientText(
                                      // booking.business.name,
                                        socketProvider.myAppointmentsList[index].business!.name ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        gradient: LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.topRight,
                                            colors: [
                                              Color(0xff8921aa),
                                              Color(0xffDA44bb),
                                              // Color(0xffDA44bb)
                                            ]
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3,),
                            Container(
                              // width: MediaQuery.of(context).size.width * 0.55,
                              child: Marquee(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      // booking.prestazione.title,
                                      socketProvider.myAppointmentsList[index].prestazione!.title!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          // color: Colors.grey[700]
                                          color: Colors.blueGrey[700]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3,),
                          ],
                        ),
                      ),
                      // minVerticalPadding: 0,
                      // contentPadding: EdgeInsets.all(0),
                      // dense: true,
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    // DateFormat./*yMd*/yMMMMd('it_IT').format(booking.begin_at).toString()
                                    //     + /*' dalle'*/'\n' + booking.begin_at.toString().substring(11, 16)
                                    //     + ' - ' + booking.begin_at.add(Duration(minutes: booking.prestazione.duration.toInt())).toString().substring(11, 16),
                                    '${DateFormat./*yMd*/yMMMMd('it_IT').format(socketProvider.myAppointmentsList[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))}\n${socketProvider.myAppointmentsList[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16)} - ${socketProvider.myAppointmentsList[index].begin_at!.add(Duration(minutes: socketProvider.myAppointmentsList[index].prestazione!.duration!.toInt())).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16)}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:  3,),
                              socketProvider.myAppointmentsList[index].end_at!.isAfter(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 && !socketProvider.myAppointmentsList[index].prestazione!.is_price_range ? Text(
                                '€ ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price?.toDouble())}',
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.blue,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w700
                                ),
                              ) : socketProvider.myAppointmentsList[index].end_at!.isBefore(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 && !socketProvider.myAppointmentsList[index].prestazione!.is_price_range ? Text(
                                '€ ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price?.toDouble())}',
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.blue,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w700
                                ),
                              ) : socketProvider.myAppointmentsList[index].end_at!.isAfter(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 && socketProvider.myAppointmentsList[index].prestazione!.is_price_range ? Text(
                                'Da € ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price_min?.toDouble())} a € ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price_max?.toDouble())}',
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.blue,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w700
                                ),
                              ) : socketProvider.myAppointmentsList[index].end_at!.isBefore(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 && socketProvider.myAppointmentsList[index].prestazione!.is_price_range ? Text(
                                'Da € ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price_min?.toDouble())} a € ${NumberFormat.currency(
                                  // customPattern: '#,##',
                                    decimalDigits: 2,
                                    symbol: '',
                                    locale: 'IT_it'
                                  // ).format((booking.prestazione.price)?.toDouble()),
                                ).format(socketProvider.myAppointmentsList[index].prestazione!.price_max?.toDouble())}',
                                style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.blue,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w700
                                ),
                              ) : Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(
                                  // booking.prestazione.title,
                                  'Annullato',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.red[600],
                                    // color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: /*!cartProvider.items[i].isEvent ? true : */false,
                      contentPadding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 0
                      ),

                      trailing: Container(
                        padding: EdgeInsets.only(top: 25),
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: Marquee(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // booking.end_at.isAfter(DateTime.now()) && booking.isCanceled == 0 ? Text(
                              // booking.end_at.isAfter(DateTime.now()) && socketProvider.myAppointments[index]['is_canceled'] == 0 ? Text(
                              Text(
                                timeAgo.format(
                                    DateTime.parse(
                                        socketProvider.myAppointmentsList[index].created_at!.toString()
                                    ),
                                    locale: 'it'
                                ),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.0,
                                    // color: Colors.white
                                    color: Colors.grey[500]
                                ),
                              ),
                              // socketProvider.myAppointmentsList[index].end_at!.isAfter(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 ? Text(
                              //   // booking.prestazione.title,
                              //   'Prenotato',
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 11,
                              //     color: Colors.green[600],
                              //   ),
                              // // ) : booking.end_at.isBefore(DateTime.now()) && booking.isCanceled == 0 ? Text(
                              // // ) : booking.end_at.isBefore(DateTime.now()) && socketProvider.myAppointments[index]['is_canceled'] == 0 ? Text(
                              // ) : socketProvider.myAppointmentsList[index].end_at!.isBefore(DateTime.now()) && socketProvider.myAppointmentsList[index].isCanceled == 0 ? Text(
                              //   // booking.prestazione.title,
                              //   'Effettuato',
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 11,
                              //     // color: Colors.grey[500],
                              //     color: Colors.blue[500],
                              //   ),
                              // ) : Text(
                              //   // booking.prestazione.title,
                              //   'Annullato',
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 11,
                              //     color: Colors.red[600],
                              //     // color: Colors.grey[500],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,)
                  ],
                ),
              );

            }
        ) : ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .07,),
            Center(
              child: Image.asset(
                'assets/png/Saly-9.png',
                height: MediaQuery.of(context).size.height * .4,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                // 'Non ci sono ancora notifiche...',
                "Non ci sono prenotazioni",
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
        // );
        // }
        // else return null;
        // }
      ),

    );
  }
}
