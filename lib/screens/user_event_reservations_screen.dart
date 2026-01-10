import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/user_booking_detail_screen.dart';
import 'package:nurebo/screens/user_ticket_detail_screen.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;

import '../main.dart';


class UserEventReservationsScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  final User? user;

  const UserEventReservationsScreen({Key? key, this.user});

  @override
  _UserEventReservationsScreenState createState() => _UserEventReservationsScreenState();
}

class _UserEventReservationsScreenState extends State<UserEventReservationsScreen> {
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

    //todo: da levare quando riuscirò ad aggiornare "myappointmentlist" (e i tutti i campi) in provider quando arriva una cancellazione o un appuntamento al background service socket.io
    socketProvider.getUserEventReservations(userProvider.user!);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    // //print('socketProvider.myAppointments.length');
    // //print(socketProvider.eventTicketsList.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
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
          'I miei biglietti',
          // 'Le mie prenotazioni',
          style: TextStyle(
              color: Colors.blue,
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
      ),
      body: StreamProvider(
      // body: StreamProvider.value(
      //   initialData: streamController.stream,
        initialData: broadcastStream,
        // value: streamController.stream,
        // create: (_) => streamController.stream,
        create: (_) => broadcastStream,
        updateShouldNotify: (dynamic previous, dynamic next) => true,
        builder: (context, snapshot) {
          // //print('ortolanoooooo');
          return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: socketProvider.eventTicketsList.isNotEmpty ? ListView.separated(
                      separatorBuilder: (context, i){
                        return Divider(indent: 15, endIndent: 20,);
                      },
                      padding: EdgeInsets.only(top: 10, bottom: 12),
                      // itemCount: myAppointments.length,
                      itemCount: socketProvider.eventTicketsList.length,
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

                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: UserTicketDetailScreen(
                                    eventTicket: socketProvider.eventTicketsList[index],
                                    user: widget.user,
                                    // singleEventReservation: singleEventReservation,
                                  ),
                                )
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0, bottom: 0, top: 5),
                                child: Text(
                                  timeAgo.format(
                                      DateTime.parse(
                                          socketProvider.eventTicketsList[index].created_at.toString()
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
                              ),
                              ListTile(
                                leading: Container(
                                  width: 80,
                                  margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(0),
                                  child: Hero(
                                    tag: socketProvider.eventTicketsList[index].eventTicket!.event!.image != null && socketProvider.eventTicketsList[index].eventTicket!.event!.image != '' ? socketProvider.eventTicketsList[index].eventTicket!.event! : socketProvider.eventTicketsList[index].eventTicket!.event!.business!,
                                    child: Card(
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3.0),
                                      ),
                                      elevation: 5,
                                      margin: EdgeInsets.all(0),
                                      child: socketProvider.eventTicketsList[index].eventTicket!.event!.image != null && socketProvider.eventTicketsList[index].eventTicket!.event!.image != '' ? FutureImage(
                                        // cartData.orders[i].singleEventImage,
                                        // booking.prestazione.image,
                                        width: MediaQuery.of(context).size.width,
                                        socketProvider.eventTicketsList[index].eventTicket!.event!.image!,
                                      ) : FutureImage(
                                        // cartData.orders[i].singleEventImage,
                                        // booking.prestazione.image,
                                        socketProvider.eventTicketsList[index].eventTicket!.event!.business!.profile_image!,
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
                                                  socketProvider.eventTicketsList[index].eventTicket!.event!.business!.name ?? '',
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
                                                socketProvider.eventTicketsList[index].eventTicket!.event!.title ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
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
                                              DateFormat./*yMd*/yMMMMd('it_IT').format(socketProvider.eventTicketsList[index].eventTicket!.event!.begin_at!).toString()
                                                  + /*' dalle'*/'\n' + socketProvider.eventTicketsList[index].eventTicket!.event!.begin_at!.toString().substring(11, 16)
                                                  + ' - ' + socketProvider.eventTicketsList[index].eventTicket!.event!.end_at!/*.add(Duration(minutes: ))*/.toString().substring(11, 16),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1,),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.48,
                                          child: Marquee(
                                            child: Text(
                                              socketProvider.eventTicketsList[index].eventTicket!.title!.toLowerCase().capitalize!,
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.48,
                                          child: Marquee(
                                            child: Text(
                                              socketProvider.eventTicketsList[index].eventTicket!.additional!.toLowerCase().capitalize!,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height:  3,),
                                        Text(
                                          '€ ' + NumberFormat.currency(
                                            // customPattern: '#,##',
                                              decimalDigits: 2,
                                              symbol: '',
                                              locale: 'IT_it'
                                          // ).format((booking.prestazione.price)?.toDouble()),
                                          ).format(socketProvider.eventTicketsList[index].eventTicket!.price!?.toDouble()),
                                          style: TextStyle(
                                              fontSize: 14,
                                              // color: Colors.blue,
                                              color: Colors.green[600],
                                              fontWeight: FontWeight.w700
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
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.055),
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  child: Marquee(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // booking.end_at.isAfter(DateTime.now()) && booking.isCanceled == 0 ? Text(
                                        // booking.end_at.isAfter(DateTime.now()) && socketProvider.myAppointments[index]['is_canceled'] == 0 ? Text(
                                        socketProvider.eventTicketsList[index].eventTicket!.event!.end_at!.isAfter(DateTime.now()) && socketProvider.eventTicketsList[index].is_canceled == 0 && socketProvider.eventTicketsList[index].is_validated == 0 ? Text(
                                          // booking.prestazione.title,
                                          'Prenotato',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Colors.green[600],
                                          ),
                                        // ) : booking.end_at.isBefore(DateTime.now()) && booking.isCanceled == 0 ? Text(
                                        // ) : booking.end_at.isBefore(DateTime.now()) && socketProvider.myAppointments[index]['is_canceled'] == 0 ? Text(
                                        ) : socketProvider.eventTicketsList[index].eventTicket!.event!.end_at!.isAfter(DateTime.now()) && socketProvider.eventTicketsList[index].is_canceled == 0 && socketProvider.eventTicketsList[index].is_validated == 1 ? Text(
                                          // booking.prestazione.title,
                                          'Convalidato',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Colors.purple[500],
                                          ),
                                        // ) : booking.end_at.isBefore(DateTime.now()) && booking.isCanceled == 0 ? Text(
                                        // ) : booking.end_at.isBefore(DateTime.now()) && socketProvider.myAppointments[index]['is_canceled'] == 0 ? Text(
                                        ) : socketProvider.eventTicketsList[index].eventTicket!.event!.end_at!.isBefore(DateTime.now()) && socketProvider.eventTicketsList[index].is_canceled == 0 ? Text(
                                          // booking.prestazione.title,
                                          'Effettuato',
                                          // 'Convalidato',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            // color: Colors.grey[500],
                                            color: Colors.blue[500],
                                          ),
                                        ) : Text(
                                          // booking.prestazione.title,
                                          'Annullato',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: Colors.red[600],
                                            // color: Colors.grey[500],
                                          ),
                                        ),
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
                          "Non ci sono biglietti",
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
          );
        }
      ),

    );
  }
}
