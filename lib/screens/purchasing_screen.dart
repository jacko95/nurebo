import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/notification_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/tab_navigator.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class PurchasingScreen extends StatefulWidget {

  const PurchasingScreen({Key? key});

  @override
  _PurchasingScreenState createState() => _PurchasingScreenState();
}

class _PurchasingScreenState extends State<PurchasingScreen> with SingleTickerProviderStateMixin {
  int result = 0; //0 = is loading, 1 = success, 2 = failed
  late CartProvider cartProvider;
  late UserProvider userProvider;
  late SocketProvider socketProvider;
  late NotificationProvider notificationProvider;
  List<int?> resStatusItems = [];
  AnimationController? animationController;
  int okRequests = 0;
  int notOkRequests = 0;
  DateTime? currentBackPressTime;
  List<Map> orderList = [];


  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Premere due volte per uscire',
        backgroundColor: Colors.grey[700]
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future createTicket(String eventId, /*{int quantity, */String eventTicketId/*}*/, String? userOrderId, int isShared) async {
    // //print('eventTicketId');
    // //print(eventTicketId);
    // var url = Uri.parse(Utils.httpServerUrl + "event_reservation");
    var url = Uri.parse("${Utils.httpServerUrl}event/$eventId/ticket/$eventTicketId/reservation");

    Map<String, dynamic> body = {
      'user_id': userProvider.user!.id,
      'event_ticket_id': eventTicketId,
      "user_order_id": userOrderId,
      "is_shared": isShared,
      // 'quantity': quantity,
      //bookingtime.now()
    };

    // //print(body);

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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("abfgdg response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   singleEventList = jsonData;
      // });
      // //print('jsonDatappppppppp');
      // //print(jsonData);
      return 200;
    }
    return;
  }

  Future createDate(CartItem e, /*SocketProvider socketProvider*/) async {
    // var url = Uri.parse("${Utils.httpServerUrl}booking");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/booking");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${e.business!.id}/bookings");

    // final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    // final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Map<String, dynamic> body = {
    //   // 'user_id': widget.user.id,
    //   'user_id': userProvider.user.id,
    //   'business_id': e.prestazione.business.id,
    //   'prestazione_id': e.prestazione_id,
    //   'begin_at': e.begin_at./*toUtc().*/toString(),
    //   'note': e.note,
    //   //bookingtime.now()
    // };

    // //print('e.begin_at.toIso8601String() hhhh');
    // //print(e.begin_at.toIso8601String());
    // //print('e.begin_at.toUtc().toString() uuuuu');
    // //print(e.begin_at.toUtc().toString());

    Map<String, dynamic> body = {
      // "booking_id": jsonData,
      "user_order_id": e.userOrderId,
      "prestazione_id": e.prestazione!.id,
      "note": e.note,
      "begin_at": e.begin_at!.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
      // "begin_at": e.begin_at!.toUtc().toString(),
      // "begin_at": e.begin_at!.toIso8601String(),
      'prestazione_duration': e.prestazione!.duration,
      'prestazione_image': e.prestazione!.image,
      'prestazione_description': e.prestazione!.description,
      'prestazione_title': e.title,
      'presale_price': e.presale_price,
      'prestazione_price': e.prestazione!.price,
      'prestazione_price_min': e.prestazione!.price_min,
      'prestazione_price_max': e.prestazione!.price_max,
      'prestazione_is_price_range': e.prestazione!.is_price_range ? 1 : 0,
      // 'user_id': e.userId,
      'user_id': userProvider.user!.id,
      'user_username': userProvider.user!.username,
      'user_phone': userProvider.user!.phone,
      'user_email': userProvider.user!.email,
      'user_name': userProvider.user!.name,
      'user_profile_image': userProvider.user!.profile_image,
      // 'first_name': widget.user.first_name,
      // 'last_name': widget.user.last_name,
      // 'business_id': e.prestazione.business_id,
      'business_id': e.business!.id,
      'business_name': e.business!.name,
      'business_type_id': e.business!.type_id,
      'business_profile_image': e.business!.profile_image,
      'business_description': e.business!.description,
      'business_address': e.business!.address,
      'business_phone': e.business!.phone,
      'max_contemporary_appointments': e.business!.max_contemporary_appointments,
      'created_at': DateTime.now()/*.toIso8601String()*/.toString(),
      'is_canceled': 0,
      'is_shared': e.is_shared ? 1 : 0,
    };

    // //print('body');
    // //print(body);

    // notificationProvider.showFlushbar(context);

    // Fluttertoast.showToast(
    //   msg: "Appuntamento prenotato correttamente",
    //   backgroundColor: Colors.grey[700],
    // );

    var response = await http.post(
        url,
        // body: jsonEncode(body),
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

    // //print("jjjj l response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode == 419 && UserPreferences.getIsLogged() == true) {
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print('jsonData create booking');
      // //print(jsonData);

      // print('e.begin_at.toString()gg6gg6g6g6');
      // print(e.begin_at.toString());
      // print(e.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString());

      Map<String, dynamic> socketBody = {
        "booking_id": jsonData,
        "user_order_id": e.userOrderId,
        "prestazione_id": e.prestazione!.id,
        "note": e.note,
        "begin_at": e.begin_at!/*.add(Duration(hours: 2))*/.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString()/*.toIso8601String()*/,
        'prestazione_duration': e.prestazione!.duration,
        'prestazione_image': e.prestazione!.image,
        'prestazione_description': e.prestazione!.description,
        'prestazione_title': e.title,
        'presale_price': e.presale_price,
        'prestazione_price': e.prestazione!.price,
        'prestazione_price_min': e.prestazione!.price_min,
        'prestazione_price_max': e.prestazione!.price_max,
        'prestazione_is_price_range': e.prestazione!.is_price_range ? 1 : 0,
        // 'user_id': e.userId,
        'user_id': userProvider.user!.id,
        'user_username': userProvider.user!.username,
        'user_phone': userProvider.user!.phone,
        'user_email': userProvider.user!.email,
        'user_name': userProvider.user!.name,
        'user_profile_image': userProvider.user!.profile_image,
        // 'first_name': widget.user.first_name,
        // 'last_name': widget.user.last_name,
        // 'business_id': e.prestazione.business_id,
        'business_id': e.business!.id,
        'business_name': e.business!.name,
        'business_type_id': e.business!.type_id,
        'business_profile_image': e.business!.profile_image,
        'business_description': e.business!.description,
        'business_address': e.business!.address,
        'business_phone': e.business!.phone,
        'max_contemporary_appointments': e.business!.max_contemporary_appointments,
        'created_at': DateTime.now()/*.toIso8601String()*/.toString(),
        'is_canceled': 0,
      };

      // socketProvider.socket.emit(
      //     'booking_business_appointments',
      //     socketBody
      // );

      //todo: farlo direttamente nella query nel server
      // socketProvider.sendAppointment(
      //     socketBody
      // );
      socketProvider.addAppointment(
        socketBody
      );

      // if(isShared){
      //   /*await*/ notificationFollowers(socketBody);
      // }

      Map<String, dynamic> values = {
        "booking_id": jsonData,
        'booking_price': e.prestazione!.price,
        "booking_begin_at": e.begin_at.toString()/*.toIso8601String()*/,
        "prestazione_id": e.prestazione!.id,
        'prestazione_image': e.prestazione!.image != null && e.prestazione!.image != '' ?  e.prestazione!.image : e.business!.profile_image,
        'prestazione_title': e.title,
        'is_canceled': 0,
        'user_id': userProvider.user!.id,
        'business_id': e.business!.id,
        'business_name': e.business!.name,
        'sent_at': DateTime.now()/*.toIso8601String()*/.toString(),
      };

      await socketProvider.insertLocalNotification(
        'appointment_notification',
        values
      );

      // //print('socketProvider.notificationList.length');
      // //print(socketProvider.notificationList.length);

      // notificationProvider.showDateNotification(
      //   beginAt: e.begin_at.toString(),
      //   prestazioneTitle: e.prestazione.title,
      //   imagePrestazione: e.prestazione.image,
      // );
      // showNotification(
      //   title: e.prestazione.title,
      //   body: e.begin_at.toString(),
      //   largeIconPath: e.prestazione.image,
      // );
      // return response.statusCode;
    }
    return response.statusCode;
  }

  // Future addOrderItems() async {
  //   for(var e in List.from(cartProvider.items)){
  //     Map cartItem = {
  //       "prestazione_id": e.prestazione.id,
  //       "note": e.note,
  //       "begin_at": e.begin_at.toString(),
  //       'prestazione_duration': e.prestazione.duration,
  //       'prestazione_image': e.prestazione.image,
  //       'prestazione_description': e.prestazione.description,
  //       'prestazione_title': e.title,
  //       'presale_price': e.presale_price,
  //       'prestazione_price': e.prestazione.price,
  //       // 'user_id': e.userId,
  //       'user_id': userProvider.user.id,
  //       'user_username': userProvider.user.username,
  //       'user_phone_number': userProvider.user.phone_number,
  //       'user_email': userProvider.user.email,
  //       'user_name': userProvider.user.name,
  //       'user_profile_image': userProvider.user.profile_image,
  //       // 'first_name': widget.user.first_name,
  //       // 'last_name': widget.user.last_name,
  //       // 'business_id': e.prestazione.business_id,
  //       'business_id': e.business.id,
  //       'business_name': e.business.name,
  //       'is_booking_business': e.business.is_booking_business,
  //       'business_profile_image': e.business.profile_image,
  //       'business_description': e.business.description,
  //       'business_address': e.business.address,
  //       'business_phone_number': e.business.phone_number,
  //       'max_contemporary_appointments': e.business.max_contemporary_appointments,
  //       'created_at': DateTime.now().toIso8601String(),
  //       'is_canceled': 0,
  //     };
  //     orderList.add(cartItem);
  //   }
  //
  //   if(orderList.length == List.from(cartProvider.items).length) {
  //     var url = Uri.parse(Utils.httpServerUrl + "user_order/booking");
  //
  //     var response = await http.post(
  //         url,
  //         body: jsonEncode(orderList),
  //         headers: {
  //           'Accept': '*/*',
  //           'Content-Type': 'application/json',
  //           'Accept-encoding': 'gzip, deflate',
  //           'connection': 'keep-alive',
  //           HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
  //         }
  //     );
  //
  //     //print("orderList response.statusCode:");
  //     //print(response.statusCode);
  //
  //     // if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
  //     //   await userProvider.logout(context);
  //     // }
  //     if(response.statusCode >= 200 && response.statusCode < 400) {
  //       var jsonData = json.decode(response.body);
  //       //print('orderList jsonData');
  //       //print(jsonData);
  //
  //       for(var e in List.from(cartProvider.items)){
  //         Map<String, dynamic> cartItem1 = {
  //           "booking_id": jsonData,
  //           "prestazione_id": e.prestazione.id,
  //           "note": e.note,
  //           "begin_at": DateTime.tryParse(e.begin_at).toIso8601String()/*.toString()*/,
  //           'prestazione_duration': e.prestazione.duration,
  //           'prestazione_image': e.prestazione.image,
  //           'prestazione_description': e.prestazione.description,
  //           'prestazione_title': e.title,
  //           'presale_price': e.presale_price,
  //           'prestazione_price': e.prestazione.price,
  //           // 'user_id': e.userId,
  //           'user_id': userProvider.user.id,
  //           'user_username': userProvider.user.username,
  //           'user_phone_number': userProvider.user.phone_number,
  //           'user_email': userProvider.user.email,
  //           'user_name': userProvider.user.name,
  //           'user_profile_image': userProvider.user.profile_image,
  //           // 'first_name': widget.user.first_name,
  //           // 'last_name': widget.user.last_name,
  //           // 'business_id': e.prestazione.business_id,
  //           'business_id': e.business.id,
  //           'business_name': e.business.name,
  //           'is_booking_business': e.business.is_booking_business,
  //           'business_profile_image': e.business.profile_image,
  //           'business_description': e.business.description,
  //           'business_address': e.business.address,
  //           'business_phone_number': e.business.phone_number,
  //           'max_contemporary_appointments': e.business.max_contemporary_appointments,
  //           'created_at': DateTime.now().toIso8601String(),
  //           'is_canceled': 0,
  //         };
  //
  //         socketProvider.addAppointment(cartItem1);
  //
  //         Map<String, dynamic> values = {
  //           "booking_id": jsonData,
  //           'booking_price': e.prestazione.price,
  //           "booking_begin_at": e.begin_at.toString(),
  //           "prestazione_id": e.prestazione.id,
  //           'prestazione_image': e.prestazione.image != null && e.prestazione.image != '' ?  e.prestazione.image : e.business.profile_image,
  //           'prestazione_title': e.title,
  //           'is_canceled': 0,
  //           'user_id': userProvider.user.id,
  //           'business_id': e.business.id,
  //           'business_name': e.business.name,
  //           'sent_at': DateTime.now().toIso8601String(),
  //         };
  //
  //         await socketProvider.insertLocalNotification(
  //             'appointment_notification',
  //             values
  //         );
  //
  //         //print('socketProvider.notificationList.length');
  //         //print(socketProvider.notificationList.length);
  //       }
  //     }
  //   }
  // }

  Future buy() async {
    // setState(() {
    //   result = 0;
    // });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => CheckoutScreen()),
    // );
    // await UserPreferences.init();
    // //print('UserPreferences.get');
    // //print(UserPreferences.getIsLogged());
    // //print(UserPreferences.getUserId());
    // //print(UserPreferences.getUserToken());

    // var url = Uri.parse(Utils.httpServerUrl + "user_order");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/order");

    Map<String, dynamic> body = {
      'user_id': UserPreferences.getUserId(),
      'user_session_id': UserPreferences.getSessionId(),
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400){
      dynamic jsonData = json.decode(response.body);
      // //print('jsonData purcha');
      // //print(jsonData['id']);

      resStatusItems.clear();
      for(CartItem e in List.from(cartProvider.items)){
        // //print('cartProvider.begin_at');
        // //print(e.begin_at);
        // //print('cartProvider.item');
        // //print(e.prestazione.business.max_contemporary_appointments);
        // //print('cartProvider..business.id');
        // //print(e.prestazione.business.id);
        e.userOrderId = jsonData['id'];

        // //print('e.userOrderId');
        // //print(e.userOrderId);
        // //print('e.id');
        // //print(e.id);

        if(e.isEvent!) {
          await createTicket(
            e.event!.id!,
            // quantity: e.quantity,
            /*eventTicketId: */e.ticketCategoryId.toString(),
            jsonData['id'],
            e.is_shared ? 1 : 0
          ).then((value) {
            resStatusItems.add(value);
            // //print('e.ticketCategoryId.toString()');
            // //print(e.ticketCategoryId.toString());
            cartProvider.removeEventByDate(e.ticketCategoryId.toString());
          });
        }
        else if(!e.isEvent!) {
          // //print(e.toString());
          // var dbInserted = await createDate(
          //     e, socketProvider
          // );
          // //print('dbInserted');
          // //print(dbInserted);

          // socketProvider.emptyAppointments();

          await createDate(e/*, socketProvider*/).then((value) async {
            resStatusItems.add(value);
            if(value >= 200 && response.statusCode < 400) {
              // Fluttertoast.showToast(
              //   // msg: 'La prenotazione "${e.prestazione.title.toString()}" da "${e.prestazione.business.name.toString()}" del ${DateFormat.yMMMMd('it_IT').format(DateTime.parse(e.begin_at.toString())).toString()} delle ore ${e.begin_at.toString().substring(11, 16)} è stata effettuata con successo!',
              //   msg: 'La prenotazione è stata effettuata con successo!',
              //   backgroundColor: Colors.grey[700],
              // );

              // resStatusItems.add(200);
              cartProvider.removeBookingByDate(e.begin_at.toString());
              // resStatusItems.removeLast();
            }
            // else{
            //   Fluttertoast.showToast(
            //     // msg: 'Non è stato possibile effettuare "${e.prestazione.title.toString()}" da "${e.prestazione.business.name.toString()}" del ${DateFormat.yMMMMd('it_IT').format(DateTime.parse(e.begin_at.toString())).toString()} delle ore ${e.begin_at.toString().substring(11, 16)}',
            //     msg: 'Non è stato possibile effettuare la prenotazione',
            //     backgroundColor: Colors.grey[700],
            //   );
            // }
          });
          // if(dbInserted >= 200 && response.statusCode < 400){
          //   cartProvider.removeAll();

        }
      }
      return 200;
    }
    else if(response.statusCode == 401){
      await userProvider.logout(context);
    }
    if(mounted){
      // Fluttertoast.showToast(
      //   msg: 'Errore',
      //   backgroundColor: Colors.grey[700],
      // );
      Navigator.pop(context);
    }
    return response.statusCode;
    // await Future.delayed(
    //   const Duration(milliseconds: 2000),
    //   (){
    //     setState(() {
    //       result = 2;
    //     });
    //   }
    // );
  }
  // Future buy() async {
  //   await addOrderItems();
  // }

  @override
  void dispose() {
    super.dispose();
    // animationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700),);

    Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        int status = await buy();
        if(status != 200){
          // Fluttertoast.showToast(
          //   msg: 'Errore',
          //   backgroundColor: Colors.grey[700],
          // );
          // Navigator.pop(context);
        }
      }
    ).then(((value) => Future.delayed(
      const Duration(milliseconds: 2000),
      // (){ }
    ).then((value) async {
      if(mounted) {
        animationController!.repeat();
      }
      for(var e in resStatusItems){
        if(e! >= 200 && e < 400){
          okRequests++;
        }
        else if(e != 200) {
          notOkRequests++;
        }
      }

      // //print('resStatusItems');
      // //print(resStatusItems);
      // //print('notOkRequests');
      // //print(notOkRequests);
      // //print('okRequests');
      // //print(okRequests);
      // //print('resStatusItems.length');
      // //print(resStatusItems.length);

      // if(cartProvider.items.isEmpty){
      if(okRequests == resStatusItems.length && mounted){
        // await Future.delayed(
        //     Duration(seconds: 4),
        //     (){
              setState(() {
                result = 1;
              });
        //     }
        // );

        if(UserPreferences.getEnableNotifications()! && mounted){
          //todo: da attivare e trasformare in v13.0.0
          /*await notificationProvider.purchaseNotification(
            body: okRequests == 1 ? "Hai effettuato una prenotazione!" : "Hai effettuato ${okRequests.toString()} prenotazioni!",
            title: "Congratulazioni!",
            // imagePrestazione: e.prestazione.image,
          );*/
        }
      }
      else if(notOkRequests == resStatusItems.length && mounted){
        // await Future.delayed(
        //     Duration(seconds: 2),
        //     (){
              setState(() {
                result = 2;
              });
        //     }
        // );
        if(UserPreferences.getEnableNotifications()! && mounted){
          //todo: da attivare e trasformare in v13.0.0
          // await notificationProvider.purchaseNotification(
          //   // body: okRequests == 1 ? "Hai effettuato una prenotazione!" : "Hai effettuato ${okRequests.toString()} prenotazioni!",
          //   body: okRequests == 1 ? "Hai effettuato una prenotazione!" : "Non ci è stato possibile effettuare alcuna prenotazione",
          //   title: "Ci dispiace...",
          //   // imagePrestazione: e.prestazione.image,
          // );
        }

      }
      else {
        if(mounted)
        // await Future.delayed(
        //     Duration(seconds: 2),
        //     (){
              setState(() {
                result = 3;
              });
        //     }
        // );

        // Fluttertoast.showToast(
        //   // msg: 'La prenotazione "${e.prestazione.title.toString()}" da "${e.prestazione.business.name.toString()}" del ${DateFormat.yMMMMd('it_IT').format(DateTime.parse(e.begin_at.toString())).toString()} delle ore ${e.begin_at.toString().substring(11, 16)} è stata effettuata con successo!',
        //   msg: 'Non è stato possibile effettuare tutte le prenotazioni',
        //   backgroundColor: Colors.grey[700],
        // );
        if(UserPreferences.getEnableNotifications()! && mounted){
          //todo: da attivare e trasformare in v13.0.0
          // await notificationProvider.purchaseNotification(
          //   title: okRequests == 1 ? "Hai effettuato una prenotazione!" : "Hai effettuato solo ${okRequests.toString()} prenotazioni",
          //   body: "Siamo riusciti ad effettuare solo alcune prenotazioni",
          //   // imagePrestazione: e.prestazione.image,
          // );
        }
      }

      await Future.delayed(
        const Duration(milliseconds: 2500),
        () async {
          if(mounted) {
            animationController!.dispose();

            // //print('resStatusItems.toString()');
            // //print(resStatusItems.toString());

            //print('Utils.tabItem');
            //print(Utils.tabItem);

            // if(Utils.isSocial || Utils.isBusiness){
            //   await Navigator.pushAndRemoveUntil(
            //     context,
            //     PageTransition(
            //       child: CartScreen(
            //         user: userProvider.user,
            //       ),
            //       duration: const Duration(milliseconds: 500),
            //       type: PageTransitionType.fade,
            //     ),
            //     (route) => false
            //   );
            // }
            // else {
            //   // Navigator.pop(context);
            //   await Navigator.pushAndRemoveUntil(
            //     context,
            //     PageTransition(
            //       child: const HomeScreen(),
            //       duration: const Duration(milliseconds: 500),
            //       type: PageTransitionType.fade,
            //     ),
            //     (route) => false
            //   );
            // }

            // Get.to(() => CartScreen(user: userProvider.user,));

            Navigator.pop(context);
          }
        }
      );

    })));
  }

  @override
  Widget build(BuildContext context) {
    cartProvider = Provider.of<CartProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            // child: ListView(
            child: Center(
              child: result == 0 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20,),
                  Lottie.asset(
                    'assets/animations/48945-launch.json',
                    // controller: animationController,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.5,
                    // repeat: true
                  ),
                  // SizedBox(height: 20,),
                  Text(
                    'Stiamo effettuando le prenotazioni...',
                    style: TextStyle(
                      // color: Colors.blue,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
                  Text(
                    "Non chiudere l'app!",
                    style: TextStyle(
                      // color: Colors.blue,
                      color: Colors.red[600],
                        // color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    ),
                  ),
                ],
              ) : result == 1 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20,),
                  Lottie.asset(
                    'assets/animations/75779-check.json',
                    // controller: animationController,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.5,
                    controller: animationController,
                    // repeat: true
                  ),
                  // SizedBox(height: 20,),
                  Text(
                    'Prenotazioni effettuate!',
                    style: TextStyle(
                      // color: Colors.blue,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
                ],
              ) : result == 2 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20,),
                  // SizedBox(height: 20,),
                  Lottie.asset(
                    'assets/animations/94303-failed.json',
                    // controller: animationController,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.5,
                    controller: animationController,
                    // repeat: true
                  ),
                  // SizedBox(height: 20,),
                  Text(
                    'Prenotazioni non effettuate!',
                    style: TextStyle(
                      // color: Colors.blue,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
                ],
              ) : result == 3 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20,),
                  Lottie.asset(
                    'assets/animations/58796-warning.json',
                    // controller: animationController,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.5,
                    controller: animationController,
                    // repeat: true
                  ),
                  // SizedBox(height: 20,),
                  Text(
                    'Prenotazioni effettuate!',
                    style: TextStyle(
                      // color: Colors.blue,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
                ],
              ): SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

}
