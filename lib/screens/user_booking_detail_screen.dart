import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/widgets/custom_dialog.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:provider/provider.dart';
import 'package:nurebo/main.dart';

import '../utils/user_preferences.dart';
import '../utils/utils.dart';

class BookingDetailScreen extends StatefulWidget {
  // final Ticket ticket;

  // final User? user;
  // final SingleEventReservation singleEventReservation;
  final Booking? booking;

  const BookingDetailScreen({super.key, /*this.user,*/ this.booking /*this.ticket*/});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  Booking? appointment;


  // Future cancelAppointment() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking/cancel");
  //
  //   Map<String, dynamic> body = {
  //     'booking_id': widget.appointment.id,
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
  //   // //print('getAppointmentsByDate.statusCode');
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   appointments = jsonData;
  //     // });
  //
  //     //todo: invio cancellazione notifica con socketio e settare annullato in socketprovider
  //
  //     Fluttertoast.showToast(
  //       msg: 'Appuntamento cancellato',
  //       backgroundColor: Colors.grey[700],
  //
  //     )..then((value) => Navigator.pop(context));
  //     // //print('Appuntamento cancellato');
  //
  //
  //     // //print(jsonData);
  //     // //print('appointments');
  //     // //print(appointments.toString());
  //     return jsonData;
  //   }
  // }

  Future<int> updateSharedBookingState(bool value) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/email_notification");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/booking/${widget.booking!.id}/is_shared");

    Map<String, dynamic> body = {
      'is_shared': /*widget.booking!.is_shared*/value == true ? 1 : 0,
      'user_id': userProvider.user!.id,
    };

    var response = await http.patch(
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      socketProvider.setIsSharedBooking(widget.booking!, value);

      // Fluttertoast.showToast(
      //   msg: 'Notifica Email aggiornata',
      //   backgroundColor: Colors.grey[700],
      // );
      // Navigator.pop(context);

      // return jsonData;
    }
    return response.statusCode;
  }

  Future<void> _showDeletingDialog(String module) async {
    showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Cancellare appuntamento',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              // cancelAppointment();
              // int res = await socketProvider.cancelAppointment(widget.appointment, widget.user);
              int res = await socketProvider.cancelBooking(widget.booking!, userProvider.user!, context);

              // //print('res');
              // //print(res);

              if(res == 1){
                setState(() {
                  appointment!.isCanceled = 1;
                });
                // Fluttertoast.showToast(
                //   msg: 'Appuntamento cancellato',
                //   backgroundColor: Colors.grey[700],
                // )..then((value) => Navigator.pop(context));
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    'Appuntamento cancellato',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red,
                );
                snackbarKey.currentState?.showSnackBar(snackBar);
                Navigator.pop(context);

              }
              else if(res == 0){
                Fluttertoast.showToast(
                  msg: 'Errore',
                  backgroundColor: Colors.grey[700],

                );
              }
              // //print('Appuntamento cancellato');
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );

          // return CupertinoAlertDialog(
          //   title: Text('Cancellare appuntamento'),
          //
          //   content: Text(module),
          //   actions: [
          //     CupertinoDialogAction(
          //       child: Text('Indietro'),
          //       isDefaultAction: true,
          //       isDestructiveAction: false,
          //       onPressed: (){
          //         Navigator.pop(context);
          //       },
          //     ),
          //     CupertinoDialogAction(
          //       child: Text('Cancella'),
          //       isDefaultAction: true,
          //       isDestructiveAction: true,
          //       onPressed: () async {
          //         int res = await socketProvider.cancelAppointment(widget.appointment, userProvider.user);
          //
          //         if(res == 1){
          //           setState(() {
          //             appointment.isCanceled = 1;
          //           });
          //           Fluttertoast.showToast(
          //             msg: 'Appuntamento cancellato',
          //             backgroundColor: Colors.grey[700],
          //
          //           ).then((value) => Navigator.pop(context));
          //         }
          //         else if(res == 0){
          //           Fluttertoast.showToast(
          //             msg: 'Errore',
          //             backgroundColor: Colors.grey[700],
          //
          //           );
          //         }
          //       },
          //     )
          //   ],
          // );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    appointment = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color(0xFFF6F7F9),
        // statusBarColor: MaterialColors.blue,
        // systemNavigationBarColor: MaterialColors.blue
      ),
      child: Scaffold(
        // backgroundColor: MaterialColors.red,
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(
        //     77
        //   ),
        //   child: MyAppBar1(
        //     user: widget.user,
        //   ),
        // ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
              children: [
                Container(
                  color: Color(0xFFF6F7F9),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            // color: Colors.grey[300],
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.all(0),

                              icon: Icon(
                                // Icons.arrow_back,
                                Icons.clear,
                                size: 24,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Pubblico',
                                style: TextStyle(
                                    // color: Colors.blue,
                                    color: !widget.booking!.is_shared! ? Colors.grey[600] : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15
                                ),
                              ),
                              SizedBox(width: 6,),
                              // Switch(
                              //   // value: true,
                              //   value: false,
                              //   onChanged: (value) {
                              //
                              //   },
                              // ),
                              Switch(
                                // value: isEmailNotification!,
                                value: widget.booking!.is_shared!,
                                onChanged: (value) async {
                                  // await UserPreferences.setSilentNotifications(value);
                                  // isEmailNotification = value;
                                  widget.booking!.is_shared = value;
                                  int status = await updateSharedBookingState(value);
                                  if(status >= 200 && status < 400){
                                    // if(value){
                                      setState(() {
                                        // userProvider.user!.email_notification = 1;
                                        widget.booking!.is_shared = value;
                                        // isEmailNotification = value;
                                      });
                                    // }
                                    // else {
                                    //   setState(() {
                                    //     userProvider.user!.email_notification = 0;
                                    //     isEmailNotification = value;
                                    //   });
                                    // }
                                  }
                                  //print('userProvider.user.email_notification');
                                  //print(userProvider.user!.email_notification);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  color: Color(0xFFF6F7F9),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Hero(
                              tag: widget.booking!.prestazione!.image != null && widget.booking!.prestazione!.image != '' ? widget.booking!.prestazione! : widget.booking!.prestazione!.business!,
                              child: Container(
                                margin: EdgeInsets.only(top: 20),
                                height: 170,
                                // decoration: BoxDecoration(
                                //   color: Colors.blueGrey[100],
                                //   borderRadius: const BorderRadius.only(
                                //     topLeft: Radius.circular(12),
                                //     topRight: Radius.circular(12),
                                //   ),
                                // ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: FutureImage(
                                    widget.booking!.prestazione!.image != null && widget.booking!.prestazione!.image != '' ? widget.booking!.prestazione!.image! : widget.booking!.prestazione!.business!.profile_image!,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                              ),
                            ),
                            ClipPath(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              clipper: TicketTopClipper(),
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GradientText(
                                      widget.booking!.prestazione!.title ?? '',
                                      // widget.appointment.business.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: Colors.grey[800]
                                      ),
                                    ),
                                    SizedBox(height: 4,),
                                    Text(
                                      // widget.appointment.prestazione.title,
                                      widget.booking!.business!.name ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Colors.grey[700]
                                      ),
                                    ),
                                    SizedBox(height: 6,),
                                    Text(
                                      widget.booking!.business!.address ?? ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          color: Colors.grey[500]
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.yMMMMEEEEd('it_IT').format(widget.booking!.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toUpperCase(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[900]
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.grey[900],
                                              size: 18,
                                            ),
                                            SizedBox(width: 3,),
                                            Text(
                                              widget.booking!.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                  color: Colors.grey[900]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 25,
                                    ),

                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Categoria:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     GradientText(
                                    //       // widget.booking!.business!.category!.name!,
                                    //       widget.booking!.prestazione!.business!.category!.name!,
                                    //       gradient: const LinearGradient(
                                    //           begin: Alignment.bottomLeft,
                                    //           end: Alignment.topRight,
                                    //           colors: [
                                    //             Color(0xff8921aa),
                                    //             Color(0xffDA44bb),
                                    //             // Color(0xffDA44bb)
                                    //           ]
                                    //       ),
                                    //       style: TextStyle(
                                    //         fontWeight: FontWeight.w800,
                                    //         fontSize: 14,
                                    //         // color: Colors.grey[800]
                                    //         // color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'ID:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Marquee(
                                            child: Row(
                                              children: [
                                                Text(
                                                  widget.booking!.id!,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Colors.grey[800]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    //TODO: INSERIRE ANCHE LE INFORMAZIONI SUL PAGAMENTO
                                    //TIPO IL METODO E QUANDO è STATO EFFETTUATO
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Username:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       // '@' + widget.user.username,
                                    //       '@${userProvider.user!.username!}',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           // color: Colors.grey[800]
                                    //           color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Utente:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          // '@' + widget.user.username,
                                          '${userProvider.user!.name!}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              // color: Colors.grey[800]
                                              color: Colors.blue[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Prezzo:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          !widget.booking!.prestazione!.is_price_range ? '€ ${NumberFormat.currency(
                                            // customPattern: '#,##',
                                              decimalDigits: 2,
                                              symbol: '',
                                              locale: 'IT_it'
                                          ).format(widget.booking!.prestazione!.price)}' : 'Da € ${NumberFormat.currency(
                                            // customPattern: '#,##',
                                              decimalDigits: 2,
                                              symbol: '',
                                              locale: 'IT_it'
                                          ).format(widget.booking!.prestazione!.price_min)} a € ${NumberFormat.currency(
                                            // customPattern: '#,##',
                                              decimalDigits: 2,
                                              symbol: '',
                                              locale: 'IT_it'
                                          ).format(widget.booking!.prestazione!.price_max)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              // color: Colors.grey[800]
                                              color: Colors.green[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Durata:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          widget.booking!.prestazione!.duration.toString() + ' minuti',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              // color: Colors.grey[800]
                                              color: Colors.grey[600]
                                              // color: Colors.blue[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Acquistato il:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMMd('it_IT').format(widget.booking!.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                          + ' alle ' + widget.booking!.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Valido fino al:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMMd('it_IT').format(widget.booking!.end_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                              + ' alle ' + widget.booking!.end_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Convalidato il:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //         widget.appointment.is_paid != null ? DateFormat.yMMMMd('it_IT').format(widget.singleEventReservation.is_valibookingd_at)
                                    //           + ' alle ' + widget.singleEventReservation.toString().substring(11, 16)
                                    //       : '-',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[800]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),

                                    SizedBox(
                                      height: 30,
                                    ),


                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   children: [
                                    //     Text(
                                    //       'Stato: ',
                                    //       style: TextStyle(
                                    //           color: Colors.grey[700],
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 15
                                    //       ),
                                    //     ),
                                    //     SizedBox(
                                    //       width: 10,
                                    //     ),
                                    //     widget.singleEventReservation.is_expired == 0 && widget.singleEventReservation.is_valibookingd == 0
                                    //         ? Text(
                                    //       // "25 posti disponibili",
                                    //       "Valido",
                                    //       style: TextStyle(
                                    //         color: Colors.greenAccent[700],
                                    //         fontWeight: FontWeight.w800,
                                    //       ),
                                    //     )
                                    //         : widget.singleEventReservation.is_expired == 1
                                    //         ? Text(
                                    //       // "25 posti disponibili",
                                    //       "Scaduto",
                                    //       style: TextStyle(
                                    //         color: Colors.redAccent[700],
                                    //         fontWeight: FontWeight.w800,
                                    //       ),
                                    //     )
                                    //         : widget.singleEventReservation.is_valibookingd == 1
                                    //         ? Text(
                                    //       // "25 posti disponibili",
                                    //       "Convalidato",
                                    //       style: TextStyle(
                                    //         color: Colors.indigoAccent[700],
                                    //         fontWeight: FontWeight.w800,
                                    //       ),
                                    //     ) : Text("",)
                                    //   ],
                                    // ),

                                    SizedBox(
                                      height: 30,
                                    ),
                                    Center(
                                      child: generateDashedDivider(
                                          MediaQuery.of(context).size.width * 0.68
                                      ),
                                    )
                                    // Image.network(
                                    //     widget.singleEventReservation.qr_code
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            ClipPath(
                              clipper: TicketBottomClipper(),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                color: Colors.white,
                                // child: Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: <Widget>[
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children: <Widget>[
                                //         Text(
                                //           "Name: ",
                                //           style: TextStyle(
                                //               fontSize: 16, fontWeight: FontWeight.w400),
                                //         ),
                                //         Text(
                                //           'ticket.name',
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w400
                                //           ),
                                //         ),
                                //         SizedBox(
                                //           height: 8,
                                //         ),
                                //         Text(
                                //           "Paid: ",
                                //           style: TextStyle(
                                //               fontSize: 16, fontWeight: FontWeight.w400),
                                //         ),
                                //         Text(
                                //           NumberFormat.currency(
                                //                   locale: "id_ID",
                                //                   decimalDigits: 0,
                                //                   symbol: "IDR ")
                                //               .format(40),
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w400),
                                //         ),
                                //       ],
                                //     ),
                                //     // QrImage(
                                //     //   version: 6,
                                //     //   foregroundColor: Colors.black,
                                //     //   errorCorrectionLevel: QrErrorCorrectLevel.M,
                                //     //   padding: EdgeInsets.all(0),
                                //     //   size: 100,
                                //     //   data: ticket.bookingCode,
                                //     // )
                                //   ],
                                // ),


                                // child: Image.network(
                                //     widget.singleEventReservation.qr_code
                                // ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                widget.booking!.isCanceled == 1 ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Questa prenotazione è stata cancellata',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // color: Colors.blue[500],
                        color: Colors.red[500],
                        // color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ) : DateTime.now().isBefore(widget.booking!.begin_at!) ? Container(
                  // height: MediaQuery.of(context).size.width * 0.1,
                  // width: MediaQuery.of(context).size.width * 0.4,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.2,
                      right: MediaQuery.of(context).size.width * 0.2,
                      top: 5,
                      bottom: 5
                  ),
                  child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.red[500],
                          // backgroundColor: Colors.white,
                          // minimumSize: Size(50, 30),
                          alignment: Alignment.center
                      ),
                      onPressed: (){
                        _showDeletingDialog(
                            "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento"
                        );
                      },
                      child: Text(
                        'Cancella',
                        style: TextStyle(
                          // color: Colors.blue[500],
                          // color: Colors.red[500],
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      )
                  ),
                ) : DateTime.now().isAfter(widget.booking!.begin_at!) ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Questa prenotazione è già stata effettuata',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[500],
                        // color: Colors.red[500],
                        // color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ) : SizedBox(),
                SizedBox(height: 35,)
              ],
            ),
          ),
        )
    );
  }
}

class TicketTopClipper extends CustomClipper<Path> {
  double radius = 15;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(radius, size.height - radius, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width - radius, size.height - radius,
        size.width, size.height - radius);
    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget generateDashedDivider(double width) {
  int n = width ~/ 5;
  return Row(
    children: List.generate(
        n,
            (index) => (index % 2 == 0)
            ? Container(
          height: 2,
          width: width / n,
          color: Color(0xFFE4E4E4),
        )
            : SizedBox(
          width: width / n,
        )),
  );
}

class TicketBottomClipper extends CustomClipper<Path> {
  double radius = 15;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, radius);
    path.quadraticBezierTo(size.width - radius, radius, size.width - radius, 0);
    path.lineTo(radius, 0);
    path.quadraticBezierTo(radius, radius, 0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
