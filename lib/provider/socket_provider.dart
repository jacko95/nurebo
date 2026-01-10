import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
// import 'package:just_audio/just_audio.dart';
import 'package:nurebo/models/business_chat_room_message.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/chat.dart';
import 'package:nurebo/models/chat_message.dart';
import 'package:nurebo/models/chat_room.dart';
import 'package:nurebo/models/chat_room_message.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/event_reservation.dart';
import 'package:nurebo/models/event_reservation.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/event_ticket.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/models/user_friend_request.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/sqflite_db/sqflite_db.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../main.dart';
import 'package:nurebo/utils/notification_helper.dart';

// final player = AudioPlayer();

class SocketProvider extends ChangeNotifier {
  IO.Socket? socket;
  bool isBottomBarVisible = /*true*/false/*Utils.isSocial || Utils.isBusiness*/; //todo: false per nascondere bottombar
  List notificationList = [];
  List<Booking> myAppointmentsList = [];
  List<EventReservation> eventTicketsList = [];
  // BuildContext context;
  List? chatList = [];
  List? businessRooms = [];
  bool isBusinessRoomOpen = false;
  int? businessRoomTab;
  int currentTab = 0;
  bool isNotificationBadge = true;
  DateTime? lastOpenNotification = DateTime.tryParse(UserPreferences.getUserLastOpenNotification()!);
  bool? isTyping;
  String? testoRicevuto;
  List<ChatMessage> messages = [];
  var chatId;
  // AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  List<Chat> messageList = [];
  // bool isChatScreenOpen = false;
  String? chatScreenOpen = '';
  List<ChatRoom> chatRooms = [];
  String? chatRoomOpen = '';
  List<ChatRoomMessage> roomMessages = [];
  String? businessChatRoomOpen = '';
  // String? businessChatRoomId = '';
  List<BusinessChatRoomMessage> businessChatRoomMessages = [];
  List<UserFriendRequest> friendshipRequests = [];
  List<User> userFriendsList = [];
  bool isFriend = false;
  int? friendshipRequestStatus = -1;


  SocketProvider(){
    // streamController.stream.listen(
    broadcastStream.listen(
      (appointment) async {
        // //print('event lllllkkkkkeeeret');
        // //print(appointment);
        setIsCanceledBooking(appointment.toString());

        // //print("appointment['business_id']");
        // //print(appointment['business_id']);

        var/*Map<String, dynamic>*/ values = {
          // "booking_id": appointment[0]['appointment_id'],
          // "booking_id": appointment.appointment_id,
          // "booking_id": (appointment.toString())['appointment_id'],
          "booking_id": appointment['appointment_id'],
          'booking_price': appointment['prestazione_price'],
          "booking_begin_at": appointment['begin_at'],
          "prestazione_id": appointment['prestazione_id'],
          'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointment['business_profile_image'],
          'prestazione_title': appointment['prestazione_title'],
          'is_canceled': 1,
          'user_id': appointment['user_id'],
          'business_id': appointment['business_id'],
          'business_name': appointment['business_name'],
          'sent_at': DateTime.now()/*.toIso8601String()*/.toString(),
        };

        await insertLocalNotification(
            'appointment_notification',
            values
        );

        // Phoenix.rebirth(context);

        notifyListeners();
      },
      cancelOnError: false,
      // onDone: (){
      //   notifyListeners();
      // }
    );

    // //print('48486socket.id');
    // //print(socket.id);
  }

  // @override
  // void addListener(VoidCallback listener) {
  //
  // }

  Future getAllBusinessChatRoomMessages(/*String? userId,*/Business business/*, BuildContext context*/) async {
    // BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Constants.serverUrl + "single_event_room/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/room/${business!.room_id}/message");

    // Map/*<String, String>*/ body = {
    //   "event_id": event.id.toString()user.profile_image AS user_profile_image, user.id AS user_id, user.email AS user_email, user.username AS user_username,
    //                         user.phone_number AS user_phone_number, user.name AS user_name, user.description AS user_description,user.profile_image AS user_profile_image, user.id AS user_id, user.email AS user_email, user.username AS user_username,
    //                         user.phone_number AS user_phone_number, user.name AS user_name, user.description AS user_description,
    // };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('singlezccz5v4cv5');
      // print(jsonData.length);
      // print(jsonData);

      // for(var e in chatRooms){
      //   if(e.event!.id.toString() == event.id.toString()){
      //     // e.chatRoomMessages = [];
      //     for(var e1 in jsonData){
      //       e.chatRoomMessages!.add(
      //           ChatRoomMessage(
      //             id: e1['event_room_id'],
      //             text: e1['event_room_text'],
      //             sent_at: DateTime.parse(e1['event_room_sent_at']),
      //             is_visible: e1['event_room_is_visible'],
      //             sender: User(
      //               id: e1['user_id'],
      //               name: e1['user_name'],
      //               email: e1['user_email'],
      //               username: e1['username'],
      //               description: e1['user_description'],
      //               phone_number: e1['user_phone_number'],
      //               profile_image: e1['user_profile_image'],
      //             ),
      //             event: Event(
      //               id: e1['event_id'],
      //               image: e1['event_image'],
      //               title: e1['event_title'],
      //               begin_at: DateTime.parse(e1['event_begin_at']),
      //               end_at: DateTime.parse(e1['event_end_at']),
      //               description: e1['event_description'],
      //               is_visible: e1['event_is_visible'],
      //             ),
      //           )
      //       );
      //     }
      //   }
      // }

      for(var e1 in jsonData){
        businessChatRoomMessages.add(
          BusinessChatRoomMessage(
              id: e1['business_room_message_id'],
              text: e1['business_room_message_text'],
              sent_at: DateTime.tryParse(e1['business_room_message_sent_at'] ?? ''),
              is_deleted: e1['business_room_message_is_deleted'],
              user: User(
                id: e1['user_id'],
                name: e1['user_name'],
                email: e1['user_email'],
                username: e1['user_username'],
                description: e1['user_description'],
                phone: e1['user_phone'],
                profile_image: e1['user_profile_image'] ?? '',
              ),
              business: Business(
                  id: e1['business_id'],
                  description: e1['business_description'],
                  name: e1['business_name'],
                  email: e1['business_email'],
                  email_notification: e1['business_email_notification'],
                  max_contemporary_appointments: e1['max_contemporary_appointments'],
                  address: e1['business_address'],
                  phone: e1['business_phone'],
                  room_id: e1['business_room_id'],
                  // is_booking_business: e1['is_booking_business'],
                  profile_image: e1['business_profile_image'],
                  type_id: e1['business_type_id'],
                  latitude: e1['business_latitude'],
                  longitude: e1['business_longitude'],
                  category: Category(
                    id: e1['category_id'],
                    image: e1['category_image'],
                    name: e1['category_name'],
                  )
              ),
              // event: Event(
              //   id: e1['event_id'],
              //   image: e1['event_image'],
              //   title: e1['event_title'],
              //   begin_at: DateTime.parse(e1['event_begin_at']),
              //   end_at: DateTime.parse(e1['event_end_at']),
              //   description: e1['event_description'],
              //   is_visible: e1['event_is_visible'],
              // ),
            )
        );
      }

      // print('businessChatRoomMessages.length');
      // print(businessChatRoomMessages.length);

      // chatRooms = jsonData;
      notifyListeners();
      return jsonData;
    }
  }

  emptyEventReservations(){
    eventTicketsList.clear();
    notifyListeners();
  }

  emptyAppointments(){
    myAppointmentsList.clear();
    notifyListeners();
  }

  emptyDateNotifications(){
    notificationList.clear();
    notifyListeners();
  }

  void setIsBusinessRoomOpen(bool value){
    isBusinessRoomOpen = value;
    // notifyListeners();
  }

  void setBusinessRoomTab(int tab){
    businessRoomTab = tab;
    // notifyListeners();
  }

  void setCurrentTab(int tab){
    currentTab = tab;
    notifyListeners();
  }

  bool getIsBusinessRoomOnTop(){
    if(businessRoomTab == currentTab && isBusinessRoomOpen == true){
      return true;
    }
    return false;
    notifyListeners();
  }

  void getNotificationBadge(){
    if(DateTime.parse(notificationList.isNotEmpty ? notificationList.first['sent_at'] : DateTime.now().subtract(const Duration(days: 2)).toIso8601String()).isAfter(DateTime.parse(UserPreferences.getUserLastUpdateNotification() ?? DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()))){
      // notifyListeners();
      isNotificationBadge = true;
    }
    // notifyListeners();
    isNotificationBadge = false;
    notifyListeners();
  }

  void setNotificationBadge(bool value){
    isNotificationBadge = value;
    // notifyListeners();
  }

  Future getUserEventReservations(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "event_reservation/user");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/reservation");

    // //print('userId sockla');
    // //print(userId);
    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // await logout();
      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   myAppointments = jsonData;
      // results.addAll(jsonData);
      // results.shuffle();
      // });

      emptyEventReservations();

      for(var e in jsonData){
        // if(DateTime.parse(e['begin_at']).isBefore(now)){
        // setState(() {
        //   myAppointments.add(e);
        eventTicketsList.add(
            EventReservation(
              id: e['id'],
              is_canceled: e['is_canceled'],
              is_validated: e['is_validated'],
              is_validated_at: DateTime.tryParse(e['is_validated_at'] ?? ''),
              qr_code: e['qr_code'],
              // note: myAppointments[index]['note'],
              // user_id: myAppointments[index]['user_id'].toString(),
              eventTicket: EventTicket(
                id: e['event_ticket_id'],
                title: e['event_ticket_title'],
                price: e['event_ticket_price']?.toDouble(),
                additional: e['event_ticket_additional'],

                event: Event(
                  title: e['event_title'],
                  id: e['event_id'],
                  description: e['event_description'],
                  image: e['event_image'],
                  begin_at: DateTime.parse(e['begin_at']),
                  end_at: DateTime.parse(e['end_at'])/*.add(Duration(minutes: ))*/,
                  business: Business(
                      id: e['business_id'],
                      email: e['business_email'],
                      name: e['business_name'],
                      room_id: e['business_room_id'],
                      longitude: e['business_longitude'],
                      latitude: e['business_latitude'],
                      phone: e['business_phone'],
                      profile_image: e['business_profile_image'],
                      address: e['business_address'],
                      description: e['business_description'],
                      type_id: e['business_type_id'],
                      max_contemporary_appointments: e['max_contemporary_appointments'],
                      category: Category(
                        id: e['category_id'],
                        image: e['category_image'],
                        name: e['category_name'],
                      )
                  ),
                )
              ),
              user: user,
              created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
            )
        );
        // });
        // }
      }
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future getUnseenBusinessUserNotifications(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_user_notification/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/notification/business");

    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
    var response = await http.delete(
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //inserirli nel db locale
      // //print('jsonData business user notification');
      // //print(jsonData);

      for(var e in jsonData){
        //todo: in tabella booking notification ci dovrebbe essere tutto quello che
        // serve per passare a booking screen o business screen

    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
          // booking_id VARCHAR(36),
          // booking_price DOUBLE,
          // booking_begin_at TEXT,
          // is_canceled INTEGER,
          // user_id VARCHAR(36) NOT NULL,
          // business_id VARCHAR(36) NOT NULL,
          // business_name TEXT,
          // prestazione_id VARCHAR(36) NOT NULL,
          // prestazione_title TEXT,
          // prestazione_image TEXT,
          // created_at TEXT

        Map<String, dynamic> values = {
          // 'id': 'rem',
          'booking_id': e['booking_id'],
          'booking_begin_at': DateTime.tryParse(e['begin_at'])!.toString(),
          'prestazione_id': e['prestazione_id'],
          'user_id': e['user_id'],
          // 'sender_username': e['username'],
          // 'sender_name': e['user_name'],
          'is_canceled': int.tryParse(e['type']) == 2 ? 1 : 0,
          'business_id': e['business_id'],
          'business_name': e['business_name'],
          'prestazione_title': e['prestazione_title'],
          'prestazione_image': e['prestazione_image'] != null && e['prestazione_image'] != '' ? e['prestazione_image'] :/*??*/ e['business_profile_image'],
          'booking_price': e['prestazione_price'],
          'sent_at': DateTime.tryParse(e['sent_at'])/*.add(const Duration(hours: 2))*/.toString(),
        };

        // showNotification(
        //   subText: int.tryParse(e['type']) == 2 ? 'Cancellazione' : 'Prenotazione',
        //   body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(values['booking_begin_at'])).toString()
        //       + ' alle ' + values['booking_begin_at'].substring(11, 16),
        //   title: values['prestazione_title'],
        //   largeIconPath: values['prestazione_image'],
        // );

        await insertLocalNotification(
            'appointment_notification',
            values
        );

        // Map<String, dynamic> values = {
        //   // 'id': 'rem',
        //   'booking_id': e['booking_id'],
        //   'prestazione_id': e['prestazione_id'],
        //   'sender_id': e['sender_id'],
        //   'sender_username': e['username'],
        //   'sender_name': e['user_name'],
        //   'business_name': e['business_name'],
        //   'prestazione_title': e['prestazione_title'],
        //   'prestazione_image': e['prestazione_image'],
        //   'price': e['prestazione_price'],
        //   'sent_at': e['sent_at'],
        // };
        // await insertNotification(
        //   'booking_notification',
        //   values
        // );

        notificationList.sort((b, a) {
          // return a.sent_at.compareTo(b.sent_at);
          // return a['created_at'].compareTo(b['created_at']);
          return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
        });
      }

      return jsonData;
    }
  }

  // Future getUnseenUserFriendshipNotifications(User user) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "user_friendship/user_id/status");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/friend/waiting");
  //
  //   Map<String, String?> queryParameters = {
  //     'user_id': user.id,
  //   };
  //
  //   final uri = url.replace(
  //     queryParameters: queryParameters,
  //   );
  //
  //   var response = await http.get(
  //       uri,
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // var result = await SqfliteDB.instance.delete('friendship_notification',);
  //
  //     //print('jsonData48646486');
  //     //print(jsonData);
  //
  //     for(var e in jsonData){
  //       Map<String, dynamic> values = {
  //         'recipient_id': e['recipient_id'],
  //         'status': e['status'],
  //         'user_id': e['user_id'],
  //         'user_image': e['user_profile_image'],
  //         'user_name': e['user_name'],
  //         'user_username': e['user_username'],
  //         // 'status_at': DateTime.tryParse(e['status_at'])/*.add(const Duration(hours: 2))*/.toString(),
  //         'sent_at': DateTime.tryParse(e['created_at'])!/*.add(const Duration(hours: 2))*/.toString(),
  //       };
  //
  //       // showNotification(
  //       //   subText: int.tryParse(e['type']) == 2 ? 'Cancellazione' : 'Prenotazione',
  //       //   body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(values['booking_begin_at'])).toString()
  //       //       + ' alle ' + values['booking_begin_at'].substring(11, 16),
  //       //   title: values['prestazione_title'],
  //       //   largeIconPath: values['prestazione_image'],
  //       // );
  //
  //       await insertLocalNotification(
  //           'friendship_notification',
  //           values
  //       );
  //
  //       // Map<String, dynamic> values = {
  //       //   // 'id': 'rem',
  //       //   'booking_id': e['booking_id'],
  //       //   'prestazione_id': e['prestazione_id'],
  //       //   'sender_id': e['sender_id'],
  //       //   'sender_username': e['username'],
  //       //   'sender_name': e['user_name'],
  //       //   'business_name': e['business_name'],
  //       //   'prestazione_title': e['prestazione_title'],
  //       //   'prestazione_image': e['prestazione_image'],
  //       //   'price': e['prestazione_price'],
  //       //   'sent_at': e['sent_at'],
  //       // };
  //       // await insertNotification(
  //       //   'booking_notification',
  //       //   values
  //       // );
  //
  //       notificationList.sort((b, a) {
  //         // return a.sent_at.compareTo(b.sent_at);
  //         // return a['created_at'].compareTo(b['created_at']);
  //         return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
  //       });
  //
  //     }
  //
  //     return jsonData;
  //   }
  // }

  Future declineFriendshipRequest(/*String? userId*/User user/*, String notificationId, int index*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user_friendship/decline");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/decline");

    Map<String, String?> queryParameters = {
      'user_id': user.id,
    };
    final uri = url.replace(
      queryParameters: queryParameters,
    );

    // Map<String, dynamic> body = {
    //   'recipient_id': Utils.user!.id,
    //   'user_id': userId,
    // };

    var response = await http.post(
        // url,
        uri,
        // body: jsonEncode(body),
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

    //print("sdsdgsg response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   status = 0;
      // });

      // await deleteLocalNotification(
      //     'friendship_notification',
      //     notificationId,
      //     index
      // );

      friendshipRequests.removeWhere((element) => element.user!.id == user.id);

      notifyListeners();
      return jsonData;
    }
  }

  Future getUserFriendshipRequests() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user_friendship/user_id/status");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/waiting");

    // Map<String, String?> queryParameters = {
    //   'user_id': Utils.user!.id,
    // };
    //
    // final uri = url.replace(
    //   queryParameters: queryParameters,
    // );

    var response = await http.get(
        url,
        // uri,
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // var result = await SqfliteDB.instance.delete('friendship_notification',);

      // print('g8dgg68d8h68h68hhf');
      // print(jsonData);

      friendshipRequests.clear();
      // friendshipRequests.addAll(jsonData);

      for(var e in jsonData){
        // Map/*<String, dynamic>*/ values = {
        //   'recipient_id': e[0]['recipient_id'],
        //   'status': e[0]['status'],
        //   'user_id': e[0]['user_id'],
        //   'user_image': e[0]['user_profile_image'],
        //   'user_name': e[0]['user_name'],
        //   'user_username': e[0]['user_username'],
        //   // 'status_at': DateTime.tryParse(e['status_at'])/*.add(const Duration(hours: 2))*/.toString(),
        //   'sent_at': DateTime.tryParse(e[0]['created_at'])!/*.add(const Duration(hours: 2))*/.toString(),
        // };

        // notificationList.sort((b, a) {
        //   // return a.sent_at.compareTo(b.sent_at);
        //   // return a['created_at'].compareTo(b['created_at']);
        //   return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
        // });

        friendshipRequests.add(
          UserFriendRequest(
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              phone: e['user_phone'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            ),
            created_at: DateTime.tryParse(e['created_at']),
          )
        );

      }

      return jsonData;
    }
  }

  Future getFriendshipRequest(User user) async {
    // var url = Uri.parse("${Utils.httpServerUrl}user_friendship/status");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/${user!.id}");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request/${widget.user!.id}");

    Map<String, String?> queryParameters = {
      'user_id': Utils.user!.id,
      'recipient_id': user!.id,
    };

    final uri = url.replace(
      queryParameters: queryParameters,
    );

    // HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    // HttpHeaders.cacheControlHeader: 'no-cache',
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, deflate',
      HttpHeaders.connectionHeader: 'keep-alive',
      'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
      'X-App-Version-Name': Utils.version_name,
      'X-App-Version-Number': Utils.version_id.toString(),
      'X-Client-Type': 'User-Mobile-App',
      HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
    };

    var response = await http.get(
      uri,
      headers: headers,
    );

    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('jsonDataiiiii');
      // print(jsonData);
      if(jsonData.length > 0){
        // print(jsonData[0]['status']);
        // status = int.tryParse(jsonData[0]['status']);
        // setState(() {
          friendshipRequestStatus = jsonData[0]['status'];
        // });
      }

      //print('status');
      //print(status);

      notifyListeners();
      return jsonData;
    }
  }

  Future sendFriendshipRequest(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user_friendship");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request");

    Map<String, String?> queryParameters = {
      'user_id': user!.id,
      // 'recipient_id': widget.user!.id,
    };
    final uri = url.replace(
      queryParameters: queryParameters,
    );

    Map<String, dynamic> body = {
      'user_id': Utils.user!.id,
      'user_image': Utils.user!.profile_image,
      'user_name': Utils.user!.name,
      'user_username': Utils.user!.username,
      'recipient_id': user!.id,
    }/*
    ..addAll(widget.user!.toJson())*/;

    var response = await http.post(
        uri,
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

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
        friendshipRequestStatus = 0;
      // });

      notifyListeners();
      return jsonData;
    }
  }

  isUserAlreadyFriend(User user){
    isFriend = false;
    userFriendsList.forEach((element) {
      if(element.id == user.id){
        // setState(() {
          isFriend = true;
        // });
      }
    });
    // for(User e in socketProvider.userFriendsList){
    //   if(){
    //
    //   }
    // }

    // print('isFriend');
    // print(isFriend);
    // print('status');
    // print(status);

    notifyListeners();
  }

  Future deleteFriendship(User user, BuildContext context) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user_friendship");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/${user!.id}");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request");

    Map<String, dynamic> body = {
      'user_id': Utils.user!.id,
      'user_image': Utils.user!.profile_image,
      'user_name': Utils.user!.name,
      'user_username': Utils.user!.username,
      'recipient_id': user!.id,
    }/*
    ..addAll(widget.user!.toJson())*/;

    var response = await http.delete(
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

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // if(status == 0){
      //   setState(() {
      //     status = -1;
      //   });
      // }
      // else if(status == 1){
      // setState(() {
        userFriendsList.removeWhere((element) => /*element['recipient_id']*/element.id == user!.id);
        friendshipRequestStatus = -1;
      // });
      // }
      Navigator.of(context).pop();

      notifyListeners();
      return jsonData;
    }
  }

  Future getUserFriends() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user_friendship/status");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request/${widget.user!.id}");

    // Map<String, String?> queryParameters = {
    //   'user_id': Utils.user!.id,
    //   // 'recipient_id': widget.user!.id,
    // };
    //
    // final uri = url.replace(
    //   queryParameters: queryParameters,
    // );

    // HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    // HttpHeaders.cacheControlHeader: 'no-cache',
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, deflate',
      HttpHeaders.connectionHeader: 'keep-alive',
      'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
      'X-App-Version-Name': Utils.version_name,
      'X-App-Version-Number': Utils.version_id.toString(),
      'X-Client-Type': 'User-Mobile-App',
      HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
    };

    var response = await http.get(
      url,
      headers: headers,
    );

    userFriendsList.clear();
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData5g555gv5b54b');
      // print(jsonData);

      for(var e in jsonData){
        User user;
        // if(e['user_id'] != Utils.user!.id){
          user = User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          );
        // }
        // else {
        //   user = User(
        //     id: e['recipient_id'],
        //     email: e['recipient_email'],
        //     username: e['recipient_username'],
        //     name: e['recipient_name'],
        //     profile_image: e['recipient_profile_image'],
        //     description: e['recipient_description'],
        //   );
        // }
        // print("usegf5gg5g5bg4bb54");
        // print(user.id);
        userFriendsList.add(user);
      }

      // print('userFriendsengthgt6g6g6g6gbg6g6');
      // print(userFriendsList.length);
      // userFriendsList.addAll(jsonData);

      //print('status');
      //print(status);
      return jsonData;
    }
  }

  Future acceptFriendshipRequest(/*String? userId*/User user/*, String notificationId, int index*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user_friendship/accept");
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/accept");

    Map<String, String?> queryParameters = {
      'user_id': user.id,
    };
    final uri = url.replace(
      queryParameters: queryParameters,
    );

    // Map<String, dynamic> body = {
    //   'recipient_id': Utils.user!.id,
    //   'user_id': userId,
    // };

    var response = await http.post(
        uri,
        // body: jsonEncode(body),
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

    //print("sdsdgsg response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   status = 0;
      // });

      // await deleteLocalNotification(
      //     'friendship_notification',
      //     notificationId,
      //     index
      // );

      friendshipRequests.removeWhere((element) => element.user!.id == user.id);
      userFriendsList.insert(0, user);

      notifyListeners();
      return jsonData;
    }
  }

  Future updateFcmToken(User user) async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/fcm_token");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/fcm_token");

    Map<String, dynamic> body = {
      'user_id': user.id,
      'fcm_token': deviceToken,
    };

    // var response = await http.post(
    var response = await http.put(
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('fcm token');
      //print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future insertDevice(User user, Map<String, dynamic> deviceData) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/device");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/device");

    Map<String, dynamic> body = {
      'user_id': user.id,
      'fcm_token': deviceToken,
      'manufacturer': deviceData['manufacturer'],
      'model': deviceData['model'],
      'sdk_version': deviceData['version.sdkInt'],
      'release_version': deviceData['version.release'],
    };

    // var response = await http.post(
    var response = await http.put(
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
        },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('jsonDatauiiguhiguigu');
      //print(jsonData);

      await UserPreferences.setDeviceId(jsonData[0]['id']);

      //print('UserPreferences.getDeviceId()');
      //print(UserPreferences.getDeviceId());

      notifyListeners();
      return jsonData;
    }
  }

  // Future getDevice(User user, Map<String, dynamic> deviceData) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "user/device");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/device?manufacturer=${deviceData['manufacturer']}&model=${deviceData['model']}");
  //
  //   // Map<String, dynamic> body = {
  //   //   'user_id': user.id,
  //   //   'fcm_token': deviceToken,
  //   //   'manufacturer': deviceData['manufacturer'],
  //   //   'model': deviceData['model'],
  //   //   'sdk_version': deviceData['version.sdkInt'],
  //   //   'release_version': deviceData['version.release'],
  //   // };
  //
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       },
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     //print('vsbv45v4vs545dgbghh');
  //     //print(jsonData);
  //
  //     await UserPreferences.setDeviceId(jsonData[0]['id']);
  //
  //     //print('UserPreferences.getDeviceId()');
  //     //print(UserPreferences.getDeviceId());
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }
  //
  // Future putAuthDevice(User user, Map<String, dynamic> deviceData) async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "user/device");
  //   var url = Uri.parse("${Utils.httpServerUrl}authentication/${user.id}/device");
  //
  //   Map<String, dynamic> body = {
  //     // 'user_id': user.id,
  //     // 'fcm_token': deviceToken,
  //     'manufacturer': deviceData['manufacturer'],
  //     'model': deviceData['model'],
  //     // 'sdk_version': deviceData['version.sdkInt'],
  //     // 'release_version': deviceData['version.release'],
  //   };
  //
  //   var response = await http.put(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
  //       },
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     //print('vsbv45v4vs545dgbghh');
  //     //print(jsonData);
  //
  //     await UserPreferences.setDeviceId(jsonData[0]['id']);
  //
  //     //print('UserPreferences.getDeviceId()');
  //     //print(UserPreferences.getDeviceId());
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }

  Future startSession(User user, Map<String, dynamic> userSession) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/device");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/session");

    Map<String, dynamic> body = {
      'user_id': user.id,
      // 'authentication_id': UserPreferences.getUserToken()!,
      'ip_addr': userSession['query'],
      'city': userSession['city'],
      'zip': userSession['zip'],
      'latitude': userSession['lat'],
      'longitude': userSession['lon'],
      'begin_at': DateTime.now()/*.toIso8601String()*/.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
    };

    var response = await http.post(
    // var response = await http.put(
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
        },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('ujdujjfvjufvjfvju');
      //print(jsonData);

      await UserPreferences.setSessionId(jsonData.toString());

      notifyListeners();
      return jsonData;
    }
  }

  Future closeSession(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/device");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/session");

    Map<String, dynamic> body = {
      'session_id': UserPreferences.getSessionId()!,
      'end_at': DateTime.now()/*.toIso8601String()*/.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
    };

    var response = await http.delete(
      // var response = await http.put(
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
      },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print('jsonDatauiiguhiguigu');
      // //print(jsonData);

      await UserPreferences.setSessionId('');

      notifyListeners();
      return jsonData;
    }
  }

  Future getBookingNotifications() async {
    List localDateNotificationList = await query(
        'booking_notification',
        orderBy: 'sent_at DESC'
      // where: 'id = ? AND title = ?',
      // whereArgs: [2, 'Bob']
    );
    // //print(localDateNotificationList);
    // notificationList = localDateNotificationList;
    notificationList.addAll(localDateNotificationList);
  }

  Future getLocalNotifications(User user, String table) async {
    List localNotificationList = await query(
      table,
      orderBy: 'sent_at DESC',
      where: 'user_id = ?',
      whereArgs: [user.id]
    );
    // //print(localNotificationList);
    // notificationList = localNotificationList;
    notificationList.addAll(localNotificationList);

    notificationList.sort((b, a) {
      // return a.sent_at.compareTo(b.sent_at);
      // return a['created_at'].compareTo(b['created_at']);
      return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
    });
    notifyListeners();
  }

  Future insertLocalNotification(String table, Map values) async {
    var result = await SqfliteDB.instance.insert(table, values);

    // //print('result insert notification');
    // //print(result);
    var result1 = await SqfliteDB.instance.delete('friendship_notification',);

    // if(result == 1){
    // if(result > 0){
      notificationList.add(values);
      // bookingNotificationList.insert(bookingNotificationList.length, values);

      // if(values['is_cancel'] == 1){
      //   showNotification(
      //     subText: 'Cancellazione',
      //     body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(values['booking_begin_at'])).toString()
      //         + ' alle ' + values['booking_begin_at'].substring(11, 16),
      //     title: values['prestazione_title'],
      //     largeIconPath: values['prestazione_image'],
      //   );
      // }

      //order
      notificationList.sort((b, a) {
        // return a.sent_at.compareTo(b.sent_at);
        return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
      });

      // //print('notification list length');
      // //print(notificationList.length);
    // }

    notifyListeners();
  }

  Future deleteLocalNotification(String table, String id, int index) async {
    // //print('notification list length 0');
    // //print(notificationList.length);
    // List result = await SqfliteDB.instance.query(
    //   table,
    //   // orderBy: 'time DESC',
    // );
    // //print('idoossssss');
    // //print(id);
    // //print(result);

    var result = await SqfliteDB.instance.delete(
      table,
      // where: "booking_id = ?",
      where: "id = ?",
      whereArgs: [id],
    );

    // //print('result delete notification');
    // //print(result);

    notificationList.removeAt(index);

    // notificationList.sort((b, a) {
    //   return DateTime.parse(a['sent_at']).compareTo(DateTime.parse(b['sent_at']));
    // });

    // //print('notification list length 1');
    // //print(notificationList.length);

    notifyListeners();
  }

  Future query(String table, {String? where, List? whereArgs, String? orderBy}) async {
    var ff = await SqfliteDB.instance.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy
    );
    notifyListeners();
    return ff;
  }

  void setBottomBarVisibility(bool value){
    isBottomBarVisible = value;
    notifyListeners();
  }

  Future cancelBooking(Booking booking, User user, BuildContext context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/user");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/booking/${booking.id}");

    Map<String, dynamic> body = {
      'booking_id': booking.id,
      "begin_at": booking.begin_at.toString(),
      "user_id": user.id,
      "user_username": user.username,
      "user_name": user.name,
      "user_profile_image": user.profile_image,
      "prestazione_title": booking.prestazione!.title,
      "prestazione_image": booking.prestazione!.image,
      "prestazione_id": booking.prestazione!.id,
      "business_id": booking.business!.id,
      "business_name": booking.business!.name,
      "is_canceled": 1
    };

    var response = await http.delete(
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

    // //print('getAppointmentsByDate.statusCode');
    // //print(response.statusCode);

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   appointments = jsonData;
      // });

      // print('jsonDatag5gh6h6');
      // print(jsonData);

      for(var e in myAppointmentsList) {
        // if(e['booking_id'] == appointment.id){
        if(e.id == booking.id){
          // //print('appuntamento da cancellare:::::' + e['booking_id'].toString());
          // //print('appuntamento da cancellare:::::' + e.id.toString());
          // e['is_canceled'] = 1;
          e.isCanceled = 1;
        }
      }
      // //print('Appuntamento cancellato');

      Map<String, dynamic> values = {
        "booking_id": booking.id,
        'booking_price': booking.prestazione!.price,
        "booking_begin_at": booking.begin_at!.toString(),
        "prestazione_id": booking.prestazione!.id,
        'prestazione_image': booking.prestazione!.image != null && booking.prestazione!.image != '' ? booking.prestazione!.image : booking.business!.profile_image,
        'prestazione_title': booking.prestazione!.title,
        'is_canceled': 1,
        'user_id': user.id,
        'business_id': booking.business!.id,
        'business_name': booking.business!.name,
        'sent_at': DateTime.now()/*.toIso8601String()*/.toString(),
      };

      await insertLocalNotification(
          'appointment_notification',
          values
      );

      showNotification(
        subText: 'Cancellazione',
        body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(values['booking_begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toString()
          + ' alle ' + DateTime.tryParse(values['booking_begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
        title: values['prestazione_title'],
        largeIconPath: values['prestazione_image'],
      );

      //todo: invio cancellazione notifica con socketio e ordinare le mie prenotazioni per ordine di creazione
      // socket.emit(
      //   "cancel_user_appointment_notification",
      //   {
      //     "appointment_id": appointment.id,
      //     "begin_at": appointment.begin_at.toString(),
      //     "user_id": user.id,
      //     "username": user.username,
      //     "user_profile_image": user.profile_image,
      //     "prestazione_title": appointment.prestazione.title,
      //     "business_id": appointment.business.id,
      //   }
      // );

      // //print(jsonData);
      // //print('appointments');
      // //print(appointments.toString());
      // return jsonData;
      notifyListeners();
      return 1;
    }
    notifyListeners();
    return 0;
  }

  Future getUserAppointments(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/booking");

    // //print('userId sockla');
    // //print(userId);
    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // await logout();
      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   myAppointments = jsonData;
        // results.addAll(jsonData);
        // results.shuffle();
      // });

      emptyAppointments();

      for(var e in jsonData){
        // print("e['begin_at']fd5d5");
        // print(e['begin_at']);
        // if(DateTime.parse(e['begin_at']).isBefore(now)){
        // setState(() {
        //   myAppointments.add(e);
        myAppointmentsList.add(
            Booking(
              id: e['booking_id'],
              isCanceled: e['is_canceled'],
              is_shared: (e['is_shared']?.toInt() ?? 0) == 1 ? true : false,
              // note: myAppointments[index]['note'],
              // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                id: e['prestazione_id'],
                duration: e['prestazione_duration'],
                image: e['prestazione_image'] ?? '',
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
                title: e['prestazione_title'],
                description: e['prestazione_description'] ?? '',
                isValid: e['prestazione_is_valid'],
                // business_id: e['prestazione_business_id'],
                business: Business(
                  id: e['business_id'],
                  email: e['business_email'],
                  name: e['business_name'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  phone: e['business_phone'],
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  address: e['business_address'],
                  description: e['business_description'],
                  type_id: e['business_type_id'],
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
                ),
              ),
              business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'],
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                room_id: e['business_room_id'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                phone: e['user_phone'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              begin_at: DateTime.tryParse(e['begin_at']),
              end_at: DateTime.parse(e['begin_at']).add(Duration(minutes: e['prestazione_duration'].toInt())),
              created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
            )
        );
        // });
        // }
        // print("e['begin_at']");
        // print(e['begin_at']);
      }
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  setIsCanceledBooking(dynamic appointment) async {
    // print('pppppotaaaaaaa');
    // print(appointment);
    // myAppointmentsList.clear();
    // await getUserAppointments(User(id: '11'));
    // //print(myAppointmentsList.length);
    // print(appointment['appointment_id']);

    //todo:inserire la notifica local
    Map<String, dynamic> values = {
      // "booking_id": appointment['appointment_id'],
      "booking_id": appointment['booking_id'],
      'booking_price': appointment['prestazione_price'],
      "booking_begin_at": appointment['begin_at'],
      "prestazione_id": appointment['prestazione_id'],
      'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointment['business_profile_image'],
      'prestazione_title': appointment['prestazione_title'],
      'is_canceled': 1,
      'user_id': appointment['user_id'],
      'business_id': appointment['business_id'],
      'business_name': appointment['business_name'],
      // 'sent_at': DateTime.now()/*.toIso8601String()*/.toString(),
      'sent_at': DateTime.tryParse(appointment['created_at']).toString(),
    };

    // // bool diocristo = notificationList.contains(values);
    // // print('diocristo');
    // // print(diocristo);
    // // bool elementoEsiste = notificationList.any((element) => appointment['appointment_id'] == element['booking_id'] && element['is_canceled'] == 1);
    // // if (!/*elementoEsiste*/notificationList.contains(values)) {
      await insertLocalNotification(
          'appointment_notification',
          values
      );
    // //   print('Elemento inserito correttamente.');
    // // } else {
    // //   print('L\'elemento esiste già nella lista.');
    // // }

    // notificationList.forEach((e){
    //   print('diocane');
    //   print(appointment['appointment_id']);
    //   print(e['booking_id']);
    //   print(appointment['appointment_id'] == e['booking_id'] && e['is_canceled'] == 1);
    // });

    for(var e in myAppointmentsList){
      // if(e['id'].toString() == appointment['appointment_id'].toString()){
      // print(e.id.toString());
      // print(appointment['appointment_id']);
      // if(e.id.toString() == appointment['appointment_id']){
      if(e.id.toString() == appointment['booking_id']){
        // print('tyyyouilllo5666');
        e.isCanceled = 1;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  bool setIsSharedBooking(Booking booking, bool value) /*async*/ {

    for(var e in myAppointmentsList){
      if(e.id.toString() == booking.id){
        // print('tyyyouilllo5666');
        e.is_shared = value;
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  Future<void> tryConnectSocket(User? user, {int maxRetries = 50}) async {
    // /*late*/ Socket? sock;
    // do {
    //   sock = await connect(businessId, context);
    // } while(sock != null);
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // print(url);
      try {
        Socket? sock = await connectSocketProvider(user);
        if (sock != null) {
          return;
        }
      } catch (e) {
        // Gestisci l'errore, se necessario
      }
    }
  }

  Future<Socket?> connectSocketProvider(User? user) async {
    // socket = IO.io(Utils.httpServerUrl, <String, dynamic> {
    //   "transports": ["websocket", "polling"],
    //   "autoConnect": false,
    // });
    // //'forceNew': true,

    socket = IO.io(
        Utils.httpServerUrl,
        OptionBuilder()
            .setTransports(["websocket", "polling"])
            .enableForceNewConnection()
        // .disableForceNewConnection()
        // .enableAutoConnect()
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(20)
            .setReconnectionDelay(500)
        // .disableReconnection()
            .enableForceNew()
        // .disableForceNew()
            .enableMultiplex()
        // .disableMultiplex()
            .build()
    );

    // socket.on(
    //     "booking_booking_business_appointments",
    // (msg) {
    //   // var chatProvider = Provider.of<ChatProvider>(context, listen: false);
    //
    //   //print('msg');
    //   //print(msg);
    //   socketAppointments.add(msg);
    //   notifyListeners();
    //
    //   // Call the set Message function
    //   // setMessage("destination", msg["content"]);
    //
    // });
    // getAllChats();
    //
    // //print('chatList.length000');
    // //print(chatList.length);
    // chatList = await getAllUserChat(user.id);
    // //print('chatList.length111');
    // //print(chatList.length);


    // If it is connected
    /*await*/ socket!.onConnect((data) {
      //print('socket.connected provider');
      //print(socket!.connected);
      //print('socket.id');
      //print(socket!.id);

      //print('chatList');
      //print(chatList);
      for(var chat in chatList!){
        //print("chat['id']");
        //print(chat['id']);
        socket!.emit(
            "join-chat",
            {
              "id": chat['id']
            }
        );
      }

      for(var chat in chatRooms){
        // //print("chat.single_event.id");
        // //print(chat.event.id.toString());
        // socket.emit("join-chat", chat['id']);
        socket!.emit(
            "join-chat_room",
            {
              "id": chat.event!.id.toString()
            }
        );
      }

      for(var chat in businessRooms!){
        socket!.emit(
          "join-business_room",
          {
            "id": chat['business_room_id']
          }
        );
      }

      socket!.emit(
        "join-notification",
        {
          "user_id": user!.id
        }
      );
      // socket.on(
      //   "upbooking_booking_business_appointments",
      //   (msg) {
      //     // var chatProvider = Provider.of<ChatProvider>(context, listen: false);
      //
      //     //print('msg');
      //     //print(msg);
      //     socketAppointments.add(msg);
      //     notifyListeners();
      //   },
      // );
      socket!.on(
        "cancel_business_appointment_notification",
        (appointment) async {
          // print('canceled business appointment 525222');
          // //print(appointment);
          dev.log(
            'canceled business appointment',
            name: 'my.app.category',
            error: jsonEncode(appointment),
          );

          // setIsCanceledBooking(appointment['appointment_id'].toString());
          setIsCanceledBooking(appointment);

          notificationList.sort((b, a) {
            // //print(a);
            // //print(b);
            // //print('ab');
            // return a.sent_at.compareTo(b.sent_at);
            // return a['created_at'].compareTo(b['created_at']);
            // return DateTime.tryParse(a['created_at'])!.compareTo(DateTime.tryParse(b['created_at'])!);
            return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
          });

          if(!UserPreferences.getBackgroundNotifications()!){
            showNotification(
              subText: 'Cancellazione',
              body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(appointment['begin_at'])).toString()
                  + ' alle ' + appointment['begin_at'].substring(11, 16),
              title: appointment['prestazione_title'],
              largeIconPath: appointment['business_profile_image'],
            );
          }

          notifyListeners();
        },
      );

      socket!.on(
          "receive-booking_notification",
              (msg) /*async*/ async {
            // //print('booking_notification onnnaaaa');
            // //print(msg);

            Map<String, dynamic> values = {
              // 'id': 'rem',
              // 'booking_id': msg['booking_id'],
              'prestazione_id': msg['prestazione_id'],
              'sender_id': msg['user_id'],
              'sender_username': msg['username'],
              'sender_name': msg['name'],
              'business_name': msg['business_name'],
              'prestazione_title': msg['title'],
              'prestazione_image': msg['prestazione_image'],
              'price': msg['price'],
              'sent_at': msg['sent_at'],
            };

            // var result = await SqfliteDB.instance.insert(
            //     'booking_notification',
            //     values
            // );
            var result = await insertLocalNotification(
                'booking_notification',
                values
            );
            // //print('result');
            // //print(result);


            // List bookingNotifications = await SqfliteDB.instance.query(
            //   'booking_notification',
            //   orderBy: 'sent_at DESC',
            // );
            // //print(bookingNotifications);
            // showChatMessageNotification(
            showNotification(
              title: msg["username"],
              senderId: msg["user_id"],
              body: "Ho appena acquistato ${msg["title"]}",
              largeIconPath: msg['prestazione_image'],
            );

            notifyListeners();
          }
      );

      // socket.on(
      //   "receive-message",
      //   (msg) {
      //     //print('msg background 007');
      //     //print(msg);
      //     showNotification(
      //         title: msg['senderUsername'],
      //         largeIconPath: msg['senderProfileImage'],
      //         body: msg['content'],
      //         senderId: msg['senderId']
      //     );
      //   },
      // );

      socket!.on(
          "receive_remove_chat_message",
              (msg) /*async*/ {
            //print('msg00');
            //print(msg);
            for(var e in messageList){
              if(e.chat_message_list!.length > 0){
                // for(var e1 in e.chat_message_list){
                //   if(e1.sent_at.toString() == msg['sentAt'].toString() &&
                //       e1.text.toString() == msg['text'].toString() &&
                //       e1.sender_id.toString() == msg['senderId'].toString() &&
                //       e1.receiver_id.toString() == msg['receiverId'].toString()){
                //     //print('herioll');
                //     /*await*/ e.chat_message_list.remove(e1);
                //     // break;
                //     // notifyListeners();
                //   }
                // }
                List/*<Fly>*/.from(e.chat_message_list!).forEach((e5) {
                  if(e5.sent_at.toString() == msg['sentAt'].toString() &&
                      e5.text.toString() == msg['text'].toString() &&
                      e5.sender_id.toString() == msg['senderId'].toString() &&
                      e5.receiver_id.toString() == msg['receiverId'].toString()){
                    // //print('herioll');
                    /*await*/ e.chat_message_list!.remove(e5);
                    // break;
                    // notifyListeners();
                  }
                });
              }
              // for(var e1 in e.chat_message_list){
              //   if(e1.sent_at.toString() == msg['sentAt'].toString() &&
              //   e1.text.toString() == msg['text'].toString() &&
              //         e1.sender_id.toString() == msg['senderId'].toString() &&
              //         e1.receiver_id.toString() == msg['receiverId'].toString()){
              //     //print('herioll');
              //     /*await*/ e.chat_message_list.remove(e1);
              //     // break;
              //   }
              // }
              // if(e.chat_id.toString() == msg['chatId'].toString()){
              //   //print('herioll000');
              //   for(var e1 in e.chat_message_list){
              //     if(/*e1.sent_at.toString() == msg['sentAt'].toString() &&*/
              //         e1.text.toString() == msg['text'].toString() /*&&
              //         e1.sender_id.toString() == msg['senderId'].toString() &&
              //         e1.receiver_id.toString() == msg['receiverId'].toString()*/){
              //       //print('herioll');
              //       await e.chat_message_list.remove(e1);
              //       // break;
              //     }
              //   }
              // }
            }
            notifyListeners();
          }
      );

      socket!.on(
          "receive_edit_chat_message",
              (msg) /*async*/ {
            //print('msg01');
            //print(msg);
            for(var e in messageList){
              if(e.chat_message_list!.length > 0){
                List/*<Fly>*/.from(e.chat_message_list!).forEach((e5) {
                  if(e5.sent_at.toString() == msg['sentAt'].toString() &&
                      e5.text.toString() == msg['oldText'].toString() &&
                      e5.sender_id.toString() == msg['senderId'].toString() &&
                      e5.receiver_id.toString() == msg['receiverId'].toString()){
                    //print('redneck');
                    // /*await*/ e.chat_message_list.remove(e5);
                    /*await*/ e5.text = msg['newText'].toString();
                    // break;
                    // notifyListeners();
                  }
                });
              }
            }
            notifyListeners();
          }
      );

      socket!.on(
          "receive_opening_chat",
              (msg) /*async*/ {
            //print('msg02');
            //print(msg);
            for(var e in messageList){
              if(msg['chatId'].toString() == e.chat_id.toString()){
                if(msg['isUserA'] == 'true' && e.user_a_id == msg['userId']){
                  //print('e.user_a_last_opening_at');
                  //print(e.user_a_last_opening_at.toString());
                  e.user_a_last_opening_at = DateTime.parse(msg['lastOpeningAt']);
                  //print(e.user_a_last_opening_at.toString());
                  break;
                }
                else if(msg['isUserA'] == 'false' && e.user_b_id == msg['userId']){
                  //print('e.user_b_last_opening_at');
                  //print(e.user_b_last_opening_at.toString());
                  e.user_b_last_opening_at = DateTime.parse(msg['lastOpeningAt']);
                  //print(e.user_b_last_opening_at.toString());
                  break;
                }
              }
            }
            notifyListeners();
          }
      );

      socket!.on(
          "receive_closing_chat",
              (msg) /*async*/ {
            //print('msg02');
            //print(msg);
            for(var e in messageList){
              if(msg['chatId'].toString() == e.chat_id.toString()){
                if(msg['isUserA'] == 'true' && e.user_a_id == msg['userId']){
                  //print('e.user_a_last_closing_at');
                  //print(e.user_a_last_closing_at.toString());
                  e.user_a_last_closing_at = DateTime.parse(msg['lastClosingAt']);
                  //print(e.user_a_last_closing_at.toString());
                  break;
                }
                else if(msg['isUserA'] == 'false' && e.user_b_id == msg['userId']){
                  //print('e.user_b_last_closing_at');
                  //print(e.user_b_last_closing_at.toString());
                  e.user_b_last_closing_at = DateTime.parse(msg['lastClosingAt']);
                  //print(e.user_b_last_closing_at.toString());
                  break;
                }
              }
            }
            notifyListeners();
          }
      );

      socket!.on(
        "receive-message",
            (msg) {
          //print('msg');
          //print(msg);

          socket!.emitWithAck(
              "breadramp",
              'hola muchachoooo',
              ack: (data) {
                //print('ack 56 $data') ;
                if (data != null) {
                  //print('$data');
                }
                else {
                  //print("yuttterfiel") ;
                }
              }
          );

          /*if(user.id != msg['senderId']){
          addChatMessage(
              ChatMessage(
                text: msg["content"],
                receiver_id: msg["receiverId"],
                sender_id: msg['senderId'],
                chat_id: msg['chatId'].toString(),
                sent_at: DateTime.parse(msg['sentAt'].toString()),
                type: 'destination',
                is_visible_for_sender: 1,
                is_visible_for_receiver: 1,
              )
          );

          for(var e in messageList){
            if(e.chat_id == msg['chatId']){
              // messageList.remove(e);
              // messageList.add(
              //     new Chat(
              //       chat_id: msg['chatId'],
              //       receiver_id: msg['receiverId'],
              //       sender_id: msg['senderId'],
              //       receiver_username: user.username,
              //       sender_username: msg['senderUsername'],
              //       sent_at: DateTime.parse(msg['sentAt']).toLocal(),
              //       text: msg['content'],
              //       receiver_profile_image: user.profile_image,
              //       sender_profile_image: msg['senderProfileImage'],
              //       user_a_id: msg['user_a_id'],
              //       user_b_id: msg['user_b_id'],
              //       // user_a_last_opening_at: DateTime.parse(msg['user_a_last_opening_at']),
              //       // user_b_last_opening_at: DateTime.parse(msg['user_b_last_opening_at']),
              //
              //     )
              // );


              e.chat_message_list.add(
                  ChatMessage(
                    // id: msg['chatId'],
                    text: msg['content'],
                    receiver_id: msg['receiverId'],
                    chat_id: msg['chatId'].toString(),
                    sender_id: msg['senderId'],
                    sent_at: DateTime.parse(msg['sentAt']).toLocal(),
                    type: 'destination',
                    is_visible_for_sender: 1,
                    is_visible_for_receiver: 1,
                  )
              );

              if(e.chat_id.toString() != chatScreenOpen.toString()) {
                e.unread_messages++;
              }

              for(var e in messageList){
                e.chat_message_list.sort((a, b) {
                  // return a.sent_at.compareTo(b.sent_at);
                  return a.sent_at.compareTo(b.sent_at);
                });
                // //print(e.chat_message_list.last.text);
                // //print(e.chat_message_list.last.sent_at.toString());
              }
              // for(var e in messageList){
              //   e.chat_message_list.sort((b, a) {
              //     return a.sent_at.compareTo(b.sent_at);
              //   });
              //   // //print(e.chat_message_list.last.text);
              //   // //print(e.chat_message_list.last.sent_at.toString());
              // }
              messageList.sort((b, a) {
                return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
              });
              break;
            }
          }
        }*/

          // messageList.add(
          //     new Chat(
          //       chat_id: msg['chatId'],
          //       receiver_id: msg['receiverId'],
          //       sender_id: msg['senderId'],
          //       receiver_username: user.username,
          //       sender_username: msg['senderUsername'],
          //       sent_at: DateTime.parse(msg['sentAt']),
          //       text: msg['content'],
          //       receiver_profile_image: user.profile_image,
          //       sender_profile_image: msg['senderProfileImage'],
          //     )
          // );

          // messageList.sort((b, a) {
          //   return a.sent_at.compareTo(b.sent_at);
          // });
          // for(var e in messageList){
          //   // e.chat_message_list.sort((b, a) {
          //   //   return a.sent_at.compareTo(b.sent_at);
          //   // });
          //   // //print(e.chat_message_list.last.text);
          //   // //print(e.chat_message_list.last.sent_at.toString());
          // }
          // messageList.sort((b, a) {
          //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
          // });

          // if(isChatScreenOpen == false) {

          if(chatScreenOpen.toString() != msg['chatId'].toString()) {
            // showChatMessageNotification(
            showNotification(
              title: msg["senderUsername"],
              senderId: msg["receiverId"],
              body: msg["content"],
              largeIconPath: msg['senderProfileImage'],
            );
          }

          // //print('cindalloooo');

          // Scroll to Bottom
          // _scrollController.animateTo(
          //   _scrollController.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.easeOut,
          // );
          // notificationProvider.showChatMessageNotification(
          //     username: username,
          //     userId: userId,
          //     body: message,
          //     profileImage: profileImage
          //
          // );

          socket!.ack('arribatolooss 1');

          notifyListeners();
        },
      );

      socket!.on(
        // "receive_user-business_room_message",
        "receive-business_room_message",
            (msg) async {
          // await showNotification(title: 'allah', body: 'akbar');
          // print(msg);

          // addBusinessChatRoomMessage(
          //     BusinessChatRoomMessage(
          //       id: msg['business_room_message_id'],
          //       text: msg['business_room_message_text'],
          //       sent_at: DateTime.tryParse(msg['business_room_message_sent_at'] ?? ''),
          //       is_deleted: msg['business_room_message_is_deleted'],
          //       user: User(
          //         id: msg['user_id'],
          //         name: msg['user_name'],
          //         email: msg['user_email'],
          //         username: msg['user_username'],
          //         description: msg['user_description'],
          //         phone_number: msg['user_phone_number'],
          //         profile_image: msg['user_profile_image'] ?? '',
          //       ),
          //       business: Business(
          //           id: msg['business_id'],
          //           description: msg['business_description'],
          //           name: msg['business_name'],
          //           email: msg['business_email'],
          //           email_notification: msg['business_email_notification'],
          //           max_contemporary_appointments: msg['max_contemporary_appointments'],
          //           address: msg['business_address'],
          //           room_id: msg['business_room_id'],
          //           phone_number: msg['business_phone_number'],
          //           // is_booking_business: e1['is_booking_business'],
          //           profile_image: msg['business_profile_image'],
          //           type_id: msg['business_type_id'],
          //           latitude: msg['business_latitude'],
          //           longitude: msg['business_longitude'],
          //           category: Category(
          //             id: msg['category_id'],
          //             image: msg['category_image'],
          //             name: msg['category_name'],
          //           )
          //       ),
          //       // event: Event(
          //       //   id: e1['event_id'],
          //       //   image: e1['event_image'],
          //       //   title: e1['event_title'],
          //       //   begin_at: DateTime.parse(e1['event_begin_at']),
          //       //   end_at: DateTime.parse(e1['event_end_at']),
          //       //   description: e1['event_description'],
          //       //   is_visible: e1['event_is_visible'],
          //       // ),
          //     )
          // );

          print(msg);
          Business business01 = Business(
              id: msg['business_id'],
              description: msg['business_description'],
              name: msg['business_name'],
              email: msg['business_email'],
              email_notification: msg['business_email_notification'],
              max_contemporary_appointments: msg['max_contemporary_appointments'],
              address: msg['business_address'],
              room_id: msg['business_room_id'],
              phone: msg['business_phone'],
              // is_booking_business: e1['is_booking_business'],
              profile_image: msg['business_profile_image'],
              type_id: msg['business_type_id'],
              latitude: msg['business_latitude'],
              longitude: msg['business_longitude'],
              category: Category(
                id: msg['category_id'],
                image: msg['category_image'],
                name: msg['category_name'],
              )
          );
          businessChatRoomMessages.clear();
          await getAllBusinessChatRoomMessages(/*widget.business! ,*//*Utils.business!*/business01, /*context*/);

          // showNotification(
          //     title: title,
          //     body: body
          // );

          // businessRoomMessages.add(
          //     BusinessChatRoomMessage(
          //       text: msg["content"],
          //       event: Event(
          //         id: msg["singleEventId"],
          //       ),
          //       // singleEventId: msg["singleEventId"],
          //       // senderId: msg["senderId"],
          //       sender: User(
          //         id: msg["senderId"],
          //         profile_image: msg["senderProfileImage"],
          //         username: msg["senderUsername"],
          //       ),
          //       sent_at: DateTime.parse(msg['sentAt'].toString()),
          //       is_visible: 1,
          //       // id:
          //     )
          // );

          notifyListeners();
        },
      );

      socket!.on(
        "receive-room_message",
            (msg) {
          //print('msg arriva');
          //print(msg);

          addChatRoomMessage(
            // new ChatMessage(
            //   text: msg["content"],
            //   receiver_id: msg["receiverId"],
            //   sender_id: msg['senderId'],
            //   chat_id: msg['chatId'].toString(),
            //   sent_at: DateTime.parse(msg['sentAt'].toString()),
            //   type: 'destination',
            //   is_visible_for_sender: 1,
            //   is_visible_for_receiver: 1,
            // )
              ChatRoomMessage(
                text: msg["content"],
                event: Event(
                  id: msg["singleEventId"],
                ),
                // singleEventId: msg["singleEventId"],
                // senderId: msg["senderId"],
                sender: User(
                  id: msg["senderId"],
                  profile_image: msg["senderProfileImage"],
                  username: msg["senderUsername"],
                  name: msg["senderName"],
                  description: msg["senderDescription"],
                ),
                sent_at: DateTime.parse(msg['sentAt'].toString()),
                is_visible: 1,
                // id:
              )
          );

          for(var e in chatRooms){
            if(e.event!.id == msg["singleEventId"]){
              // messageList.remove(e);
              // messageList.add(
              //     new Chat(
              //       chat_id: msg['chatId'],
              //       receiver_id: msg['receiverId'],
              //       sender_id: msg['senderId'],
              //       receiver_username: user.username,
              //       sender_username: msg['senderUsername'],
              //       sent_at: DateTime.parse(msg['sentAt']).toLocal(),
              //       text: msg['content'],
              //       receiver_profile_image: user.profile_image,
              //       sender_profile_image: msg['senderProfileImage'],
              //       user_a_id: msg['user_a_id'],
              //       user_b_id: msg['user_b_id'],
              //       // user_a_last_opening_at: DateTime.parse(msg['user_a_last_opening_at']),
              //       // user_b_last_opening_at: DateTime.parse(msg['user_b_last_opening_at']),
              //
              //     )
              // );
              e.chatRoomMessages!.add(
                  ChatRoomMessage(
                    text: msg["content"],
                    event: Event(
                      id: msg["singleEventId"],
                    ),
                    // singleEventId: msg["singleEventId"],
                    // senderId: msg["senderId"],
                    sender: User(
                      id: msg["senderId"],
                      profile_image: msg["senderProfileImage"],
                      username: msg["senderUsername"],
                    ),
                    sent_at: DateTime.parse(msg['sentAt'].toString()),
                    is_visible: 1,
                    // id:
                  )
              );

              if(e.event!.id.toString() != chatRoomOpen.toString() /*&& e.unread_messages != null*/) {
                // e.unread_messages++;
                e.unread_messages = e.unread_messages! + 1;
              }

              //todo: da vedere se serve o meno
              // for(var e in messageList){
              //   e.chat_message_list.sort((a, b) {
              //     // return a.sent_at.compareTo(b.sent_at);
              //     return a.sent_at.compareTo(b.sent_at);
              //   });
              // }
              // messageList.sort((b, a) {
              //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
              // });
              break;
            }
          }

          // messageList.add(
          //     new Chat(
          //       chat_id: msg['chatId'],
          //       receiver_id: msg['receiverId'],
          //       sender_id: msg['senderId'],
          //       receiver_username: user.username,
          //       sender_username: msg['senderUsername'],
          //       sent_at: DateTime.parse(msg['sentAt']),
          //       text: msg['content'],
          //       receiver_profile_image: user.profile_image,
          //       sender_profile_image: msg['senderProfileImage'],
          //     )
          // );

          // messageList.sort((b, a) {
          //   return a.sent_at.compareTo(b.sent_at);
          // });
          // for(var e in messageList){
          //   // e.chat_message_list.sort((b, a) {
          //   //   return a.sent_at.compareTo(b.sent_at);
          //   // });
          //   // //print(e.chat_message_list.last.text);
          //   // //print(e.chat_message_list.last.sent_at.toString());
          // }
          // messageList.sort((b, a) {
          //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
          // });

          // if(isChatScreenOpen == false) {

          // if(chatScreenOpen.toString() != msg['chatId'].toString()) {
          //   showChatMessageNotification(
          //     username: msg["senderUsername"],
          //     userId: msg["receiverId"],
          //     body: msg["content"],
          //     profileImage: msg['senderProfileImage'],
          //   );
          // }

          // //print('cindalloooo');

          // Scroll to Bottom
          // _scrollController.animateTo(
          //   _scrollController.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.easeOut,
          // );
          // notificationProvider.showChatMessageNotification(
          //     username: username,
          //     userId: userId,
          //     body: message,
          //     profileImage: profileImage
          //
          // );
          notifyListeners();
        },
      );

      socket!.on(
        "typing",
            (msg) {
          //print(msg);
          // setState(() {
          isTyping = false;
          testoRicevuto = msg['text'];
          // widget.realTimeText = msg['text'];
          // });
          notifyListeners();
        },
      );

      socket!.on(
        "stop_typing",
        // chatId,
            (msg) {
          //print(msg);
          // setState(() {
          isTyping = false;
          testoRicevuto = msg['text'];
          // widget.realTimeText = msg['text'];
          // });
          notifyListeners();
        },
      );

      notifyListeners();
    });

    // Connect Socketio manually
    socket!.connect();
    Utils.socket = socket;

    return socket;
  }

  removeUserSocket(String userId, String socketId) {
    socket!.emit(
        "remove_user_socket",
        {
          "socketId": socketId,
          "userId": userId,
        }
    );
    // socket.destroy();
    notifyListeners();
  }

  sendAppointment(/*CartItem cartItem*/var socketBody){
    // socket.emit(
    //     'upbooking_booking_business_appointments',
    //     {
    //       "prestazione_id": cartItem.prestazione_id,
    //       "note": cartItem.note,
    //       "begin_at": cartItem.begin_at.toString(),
    //       'duration': cartItem.duration,
    //       'image': cartItem.image,
    //       'title': cartItem.title,
    //       'presale_price': cartItem.presale_price,
    //       'user_id': cartItem.userId
    //     }
    // );

    // //print('socketBody 555554');
    // //print(socketBody);

    socket!.emit(
        'booking_booking_business_appointments',
        socketBody
    );

    addAppointment(socketBody);

    // myAppointmentsList.add(
    //     new Date(
    //       id: socketBody['booking_id'],
    //       isCanceled: socketBody['is_canceled'],
    //       // note: myAppointments[index]['note'],
    //       // user_id: myAppointments[index]['user_id'].toString(),
    //       prestazione: new Prestazione(
    //         duration: socketBody['prestazione_duration'],
    //         image: socketBody['prestazione_image'],
    //         price: socketBody['prestazione_price'],
    //         title: socketBody['prestazione_title'],
    //         description: socketBody['prestazione_description'],
    //         // business_id: socketBody['business_id'],
    //         business: new Business(
    //           id: socketBody['business_id'],
    //           name: socketBody['business_name'],
    //           is_booking_business: socketBody['business_type_id'],
    //           // profile_image: e['business_image'],
    //           profile_image: socketBody['business_profile_image'],
    //           description: socketBody['business_description'],
    //           address: socketBody['business_address'],
    //           phone_number: socketBody['business_phone_number'],
    //           max_contemporary_appointments: socketBody['max_contemporary_appointments'],
    //         ),
    //       ),
    //       user: new User(
    //         id: socketBody['user_id'],
    //         email: socketBody['user_email'],
    //         username: socketBody['user_username'],
    //         name: socketBody['user_name'],
    //         phone_number: socketBody['user_phone_number'],
    //         profile_image: socketBody['user_profile_image'],
    //         description: socketBody['user_description'],
    //       ),
    //       business: new Business(
    //         id: socketBody['business_id'],
    //         name: socketBody['business_name'],
    //         is_booking_business: socketBody['business_type_id'],
    //         // profile_image: e['business_image'],
    //         profile_image: socketBody['business_profile_image'],
    //         description: socketBody['business_description'],
    //         address: socketBody['business_address'],
    //         phone_number: socketBody['business_phone_number'],
    //         max_contemporary_appointments: socketBody['max_contemporary_appointments'],
    //       ),
    //       begin_at: DateTime.parse(socketBody['begin_at']).toLocal(),
    //       end_at: DateTime.parse(socketBody['begin_at']).add(Duration(minutes: socketBody['prestazione_duration'].toInt())).toLocal(),
    //       created_at: DateTime.parse(socketBody['created_at']).toLocal(),
    //     )
    // );
    // // myAppointments.sort((b, a) => a['created_at'].compareTo(b['created_at']));
    // myAppointmentsList.sort((b, a) => a.created_at.compareTo(b.created_at));

    notifyListeners();
  }

  addAppointment(var socketBody){

    myAppointmentsList.add(
        Booking(
          id: socketBody['booking_id'],
          isCanceled: socketBody['is_canceled'],
          is_shared: (socketBody['is_shared']?.toInt() ?? 0) == 1 ? true : false,
          // note: myAppointments[index]['note'],
          // user_id: myAppointments[index]['user_id'].toString(),
          prestazione: Prestazione(
            id: socketBody['prestazione_id'],
            duration: socketBody['prestazione_duration'],
            image: socketBody['prestazione_image'],
            price: socketBody['prestazione_price'],
            is_price_range: (socketBody['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
            price_min: socketBody['prestazione_price_min']?.toDouble(),
            price_max: socketBody['prestazione_price_max']?.toDouble(),
            title: socketBody['prestazione_title'],
            description: socketBody['prestazione_description'] ?? '',
            isValid: socketBody['prestazione_is_valid'],
            // business_id: socketBody['business_id'],
            business: Business(
              id: socketBody['business_id'],
              name: socketBody['business_name'],
              longitude: socketBody['business_longitude'],
              latitude: socketBody['business_latitude'],
              type_id: socketBody['business_type_id'],
              // profile_image: e['business_image'],
              profile_image: socketBody['business_profile_image'],
              description: socketBody['business_description'],
              room_id: socketBody['business_room_id'],
              address: socketBody['business_address'],
              phone: socketBody['business_phone'],
              max_contemporary_appointments: socketBody['max_contemporary_appointments'],
            ),
          ),
          user: User(
            id: socketBody['user_id'],
            email: socketBody['user_email'],
            username: socketBody['user_username'],
            name: socketBody['user_name'],
            phone: socketBody['user_phone'],
            profile_image: socketBody['user_profile_image'] ?? '',
            description: socketBody['user_description'],
          ),
          business: Business(
            id: socketBody['business_id'],
            name: socketBody['business_name'],
            longitude: socketBody['business_longitude'],
            latitude: socketBody['business_latitude'],
            type_id: socketBody['business_type_id'],
            // profile_image: e['business_image'],
            profile_image: socketBody['business_profile_image'],
            description: socketBody['business_description'],
            address: socketBody['business_address'],
            room_id: socketBody['business_room_id'],
            phone: socketBody['business_phone'],
            max_contemporary_appointments: socketBody['max_contemporary_appointments'],
          ),
          begin_at: DateTime.parse(socketBody['begin_at']),
          end_at: DateTime.parse(socketBody['begin_at']).add(Duration(minutes: socketBody['prestazione_duration'].toInt())),
          created_at: DateTime.parse(socketBody['created_at']),
        )
    );
    // myAppointments.sort((b, a) => a['created_at'].compareTo(b['created_at']));
    myAppointmentsList.sort((b, a) => a.created_at!.compareTo(b.created_at!));
    notifyListeners();
  }

  // Future<void> showChatMessageNotification({String userId, String username, String profileImage, String body}) async {
  //   audioPlayer.open(
  //     // Audio('assets/audio/Life Could Be A Dream (Chill TRAP REMIX).mp3'),
  //     Audio('assets/audio/deduction-588.mp3'),
  //     autoStart: true,
  //     // showNotification: true
  //   );
  //   final Int64List vibrationPattern = Int64List(2);
  //   vibrationPattern[0] = 0;
  //   vibrationPattern[1] = 2000;
  //   // vibrationPattern[2] = 10000;
  //   // vibrationPattern[3] = 5000;
  //
  //   // final String largeIconPath = await _downloadAndSaveFile(
  //   //   // 'https://via.placeholder.com/48x48',
  //   //     imageProfile,
  //   //     'largeIcon'
  //   // );
  //
  //   final String bigPicturePath = await _downloadAndSaveFile(
  //       profileImage,
  //       'bigPicture'
  //   );
  //   // final BigPictureStyleInformation bigPictureStyleInformation =
  //   // BigPictureStyleInformation(
  //   //   // FilePathAndroidBitmap(largeIconPath),
  //   //     FilePathAndroidBitmap(bigPicturePath),
  //   //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
  //   //     hideExpandedLargeIcon: true,
  //   //     contentTitle: '$username' + 'ppp',
  //   //     htmlFormatContentTitle: true,
  //   //     // summaryText: "<p>@$username</p>",
  //   //     // summaryText: "<p>@username</p>",
  //   //     // summaryText: DateFormat.yMMMMd('it_IT').format(DateTime.parse(beginAt)).toString()
  //   //     //     + ' alle ' + beginAt.substring(11, 16),
  //   //     // htmlFormatSummaryText: true
  //   //     htmlFormatSummaryText: false
  //   // );
  //
  //   // final sound = 'slow_spring_board_longer_tail_571.ogg';
  //   // final sound = 'piece_of_cake_611.mp3';
  //   var android = AndroidNotificationDetails(
  //     // 'id 24dv45dsfc',
  //     DateTime.now().toIso8601String(),
  //     // 'channelName 27',
  //     DateTime.now().toIso8601String(),
  //     channelDescription: 'channelDescription',
  //     // playSound: true,
  //     playSound: true,
  //     importance: Importance.max,
  //     priority: Priority.max,
  //     enableVibration: true,
  //     enableLights: true,
  //     channelShowBadge: true,
  //
  //     // tag: 'Taggatolo',
  //     subText: "Messaggio",
  //     // fullScreenIntent: true,
  //     // groupKey: '1',
  //     groupAlertBehavior: GroupAlertBehavior.children,
  //     // setAsGroupSummary: true,
  //     icon: 'ic_launcher',
  //     // largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
  //     // largeIcon: const DrawableResourceAndroidBitmap('calendar'),
  //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
  //     ledOffMs: 300,
  //     ledOnMs: 300,
  //     ledColor: Colors.blue,
  //     // onlyAlertOnce: true,
  //
  //     // styleInformation: MediaStyleInformation(
  //     //   htmlFormatContent: true,
  //     //   htmlFormatTitle: false,
  //     // ),
  //     // styleInformation: bigPictureStyleInformation,
  //     groupKey: userId,
  //     setAsGroupSummary: true,
  //
  //
  //     // vibrationPattern: Int64List(20000),//vibrazione non va
  //     vibrationPattern: vibrationPattern,
  //     visibility: NotificationVisibility.public,
  //     // sound: RawResourceAndroidNotificationSound(sound.split('.').first)
  //   );
  //
  //   var ios = IOSNotificationDetails(
  //     // sound: sound,
  //     // presentSound: true,
  //
  //   );
  //
  //   var platform = new NotificationDetails(android: android, iOS: ios);
  //
  //   await _flutterLocalNotificationsPlugin.show(
  //     // 0,
  //     //   Random().nextInt(999999),
  //       userId.length,//da cambiare con un valore passato con socket io dall altro client
  //       // 'plain title',
  //       '@' + username,
  //       body,
  //       platform,
  //       payload: 'This is a demo app'
  //   );
  //   notifyListeners();
  // }

  Future getAllUserChat(String? userId) async {
    var url = Uri.parse(Utils.httpServerUrl + "chat/user");
    Map/*<String, String>*/ body = {
      "user_id": userId,
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
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      chatList = jsonData;

      for(var e in chatList!){
        //print(e);
        if(e['a_id'] == ''){
          /*await*/ getUsersLastMessage(
              userId,
              userId,
              e['b_id']
          );
        }
        else if(e['b_id'] == ''){
          /*await*/ getUsersLastMessage(
              userId,
              e['a_id'],
              userId
          );
        }
      }
      // });
      // //print("chatList: ");
      // //print(chatList);
      // //print("chatList.length: " + chatList.length.toString());

      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getAllBusinessChatRoom(/*String? userId*/) async {
    var url = Uri.parse("${Utils.httpServerUrl}business/room");
    // Map/*<String, String>*/ body = {
    //   "user_id": userId,
    // };

    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );
    // print('dd6df6ff6f6f6f6ff6');

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      businessRooms = jsonData;

      // print('businessRoomsdvv5ddf5df');
      // print(businessRooms);

      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getUsersLastMessage(String? userId, String? userAId, String? userBId) async {
    // //print('userA0');
    // //print(userA);
    // //print('userB0');
    // //print(userB);
    var url = Uri.parse(Utils.httpServerUrl + "chat_message/last");

    Map/*<String, String>*/ body = {
      "user_a": userAId,
      "user_b": userBId,
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
        }
    );

    // //print("response.statusCode lastm:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print('r r r');
      // //print(jsonData);
      // //print('r r r0');

      List<ChatMessage> lcm = (await (getAllChatMessages(userId, jsonData[0]['user_a_id'], jsonData[0]['user_b_id']))) as List<ChatMessage>;

      // //print('lcm.length.toString()');
      // //print((lcm.length-1).toString());
      // //print("jsonData[0]['user_a_last_opening_at']");
      // //print(jsonData[0]['user_a_last_opening_at']);
      // //print("jsonData[0]['user_b_last_opening_at']");
      // //print(jsonData[0]['user_b_last_opening_at']);
      // //print("userId.toString()");
      // //print(userId.toString());
      // //print("userAId.toString()");
      // //print(userAId.toString());
      // //print("userBId.toString()");
      // //print(userBId.toString());

      int c = 0;
      // // for(int j = lcm.length-1; j >= 0; j--){
      // for(var e in lcm){
      //   if(userId.toString() == userAId.toString()){
      //     if(/*lcm[j]*/e.sent_at.toUtc()
      //         .isAfter(DateTime.parse(jsonData[0]['user_a_last_opening_at']).toUtc())){
      //       // break;
      //       c++;
      //     }
      //   }
      //   else if(userId.toString() == userBId.toString()){
      //     if(/*lcm[j]*/e.sent_at.toUtc()
      //         .isAfter(DateTime.parse(jsonData[0]['user_b_last_opening_at']).toUtc())){
      //       // break;
      //       c++;
      //     }
      //   }
      // }
      for(int j = lcm.length-1; j >= 0; j--){
        if(userId.toString() == userAId.toString()){
          // if(lcm[j].sent_at.toUtc()
          //     .isAfter(DateTime.parse(jsonData[0]['user_a_last_closing_at']).toUtc())){
          //   // break;
          //   if(lcm[j].receiver_id == userId.toString()){
          //     c++;
          //   }
          // }
          if(DateTime.parse(jsonData[0]['user_a_last_closing_at'])
              .isAfter(DateTime.parse(jsonData[0]['user_a_last_opening_at']))){
            if(lcm[j].sent_at!
                .isAfter(DateTime.parse(jsonData[0]['user_a_last_closing_at']))){
              // break;
              if(lcm[j].receiver_id == userId.toString()){
                c++;
              }
              // c++;
            }
          }
          else if(DateTime.parse(jsonData[0]['user_a_last_closing_at'])
              .isBefore(DateTime.parse(jsonData[0]['user_a_last_opening_at']))){
            if(lcm[j].sent_at!
                .isAfter(DateTime.parse(jsonData[0]['user_a_last_opening_at']))){
              // break;
              // c++;
              if(lcm[j].receiver_id == userId.toString()){
                c++;
              }
            }
          }
        }
        else if(userId.toString() == userBId.toString()){
          // if(lcm[j].sent_at.toUtc()
          //     .isAfter(DateTime.parse(jsonData[0]['user_b_last_closing_at']).toUtc())){
          //   // break;
          //   if(lcm[j].receiver_id == userId.toString()){
          //     c++;
          //   }
          // }
          if(DateTime.parse(jsonData[0]['user_b_last_closing_at'])
              .isAfter(DateTime.parse(jsonData[0]['user_b_last_opening_at']))){
            if(lcm[j].sent_at!
                .isAfter(DateTime.parse(jsonData[0]['user_b_last_closing_at']))){
              // break;
              // c++;
              if(lcm[j].receiver_id == userId.toString()){
                c++;
              }
            }
          }
          else if(DateTime.parse(jsonData[0]['user_b_last_closing_at'])
              .isBefore(DateTime.parse(jsonData[0]['user_b_last_opening_at']))){
            if(lcm[j].sent_at!
                .isAfter(DateTime.parse(jsonData[0]['user_b_last_opening_at']))){
              // break;
              // c++;
              if(lcm[j].receiver_id == userId.toString()){
                c++;
              }
            }
          }
        }
        // c++;
      }

      //print('c0000000000000');
      //print(c);

      // setState(() {
      messageList.add(
          Chat(
            chat_id: jsonData[0]['chat_id'],
            receiver_id: jsonData[0]['receiver_id'],
            sender_id: jsonData[0]['sender_id'],
            receiver_username: jsonData[0]['receiver_username'],
            sender_username: jsonData[0]['sender_username'],
            receiver_name: jsonData[0]['receiver_name'],
            sender_name: jsonData[0]['sender_name'],
            sent_at: DateTime.parse(jsonData[0]['sent_at']),
            text: jsonData[0]['text'],
            receiver_profile_image: jsonData[0]['receiver_profile_image'],
            sender_profile_image: jsonData[0]['sender_profile_image'],
            user_a_id: userAId,
            user_b_id: userBId,
            user_a_last_opening_at: DateTime.parse(jsonData[0]['user_a_last_opening_at']),
            user_b_last_opening_at: DateTime.parse(jsonData[0]['user_b_last_opening_at']),
            // chat_message_list: await getAllChatMessages(userId, jsonData[0]['user_a_id'], jsonData[0]['user_b_id']),
            chat_message_list: lcm,
            // unread_messages: (lcm.length-1) - c
            unread_messages: c,
            user_a_last_closing_at: DateTime.parse(jsonData[0]['user_a_last_closing_at']),
            user_b_last_closing_at: DateTime.parse(jsonData[0]['user_b_last_closing_at']),

          )
      );

      // for(var e in messageList){
      //   if(e.chat_message_list.length == 0){
      //     /*await*/ messageList.remove(e);
      //   }
      // }
      List/*<Fly>*/.from(messageList).forEach((e4) {
        if(e4.chat_message_list.length == 0){
          messageList.remove(e4);
        }
      });

      // messageList.sort((b, a) {
      //   return a.sent_at.compareTo(b.sent_at);
      // });
      // });
      for(var e in messageList){
        e.chat_message_list!.sort((a, b) {
          // return a.sent_at.compareTo(b.sent_at);
          return a.sent_at!.compareTo(b.sent_at!);
        });
        // //print(e.chat_message_list.last.text);
        // //print(e.chat_message_list.last.sent_at.toString());
      }

      messageList.sort((b, a) {
        // if(a.chat_message_list.length > 0 && b.chat_message_list.length > 0){
        return a.chat_message_list!.last.sent_at!.compareTo(b.chat_message_list!.last.sent_at!);
        // }
      });

      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getAllChatMessages(String? userId, String? aId, String? bId) async {
    // //print("aId cchch:" + aId.toString());
    // //print("bId:" + bId.toString());
    var url = Uri.parse(Utils.httpServerUrl + "chat_message/chat/all");

    Map/*<String, String>*/ body = {
      "user_a_id": aId,
      "user_b_id": bId,
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
        }
    );

    // //print("response.statusCode pooooooo:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      DateTime? userALastOpeningAt;
      DateTime? userALastClosingAt;
      DateTime? userBLastOpeningAt;
      DateTime? userBLastClosingAt;

      // //print("jsonData[0]['chat_id'].toString()");
      // //print(jsonData[0]['chat_id'].toString());
      //print("genova");

      for(var w in messageList){
        //print(w.chat_id.toString());
        if(w.chat_id.toString() == jsonData[0]['chat_id'].toString()){
          // //print();
          userALastOpeningAt = w.user_a_last_opening_at;
          userALastClosingAt = w.user_a_last_closing_at;
          userBLastOpeningAt = w.user_b_last_opening_at;
          userBLastClosingAt = w.user_b_last_closing_at;
        }
      }

      // //print("jsonData pooooooo:");
      // //print(jsonData);
      List<ChatMessage> cm = [];

      for(var e in jsonData){
        // cm.add(
        //     new ChatMessage(
        //       text: e["text"],
        //       receiver_id: e["receiver_id"],
        //       sender_id: e['sender_id'],
        //       chat_id: e['chat_id'].toString(),
        //       sent_at: DateTime.parse(e['sent_at'].toString()).toLocal(),
        //       type: e['sender_id'] == userId
        //           ? 'source'
        //           : 'destination',
        //       id: e['id'].toString(),
        //       is_visible_for_sender: e['is_visible_for_sender'],
        //       is_visible_for_receiver: e['is_visible_for_receiver'],
        //
        //       // send_at: DateTime.now(),
        //       // send_at:
        //     )
        // );

        if(userId.toString() == e["receiver_id"]){
          if(e['is_visible_for_receiver'] == 1){
            cm.add(
                ChatMessage(
                  text: e["text"],
                  receiver_id: e["receiver_id"],
                  sender_id: e['sender_id'],
                  chat_id: e['chat_id'].toString(),
                  sent_at: DateTime.parse(e['sent_at'].toString()),
                  type: e['sender_id'] == userId
                      ? 'source'
                      : 'destination',
                  id: e['id'].toString(),
                  is_visible_for_sender: e['is_visible_for_sender'],
                  is_visible_for_receiver: e['is_visible_for_receiver'],
                  // is_visualized: /*DateTime.parse(e['sent_at'].toString()).isBefore(us)*/
                  // aId.toString() == e["receiver_id"].toString() && DateTime.parse(e['sent_at'].toString()).difference(userALastClosingAt) > Duration(seconds: 1)
                  //     ? true
                  //     : bId.toString() == e["receiver_id"].toString() && DateTime.parse(e['sent_at'].toString()).difference(userALastClosingAt) > Duration(seconds: 1)/*isBefore(userBLastClosingAt)*/
                  //     ? true
                  //     : false
                )
            );
          }
        }
        else if(userId.toString() == e["sender_id"]){
          if(e['is_visible_for_sender'] == 1){
            cm.add(
                ChatMessage(
                  text: e["text"],
                  receiver_id: e["receiver_id"],
                  sender_id: e['sender_id'],
                  chat_id: e['chat_id'].toString(),
                  sent_at: DateTime.parse(e['sent_at'].toString()),
                  type: e['sender_id'] == userId
                      ? 'source'
                      : 'destination',
                  id: e['id'].toString(),
                  is_visible_for_sender: e['is_visible_for_sender'],
                  is_visible_for_receiver: e['is_visible_for_receiver'],
                  // is_visualized: /*DateTime.parse(e['sent_at'].toString()).isBefore(us)*/
                  // aId.toString() == e["sender_id"].toString() && DateTime.parse(e['sent_at'].toString()).difference(userALastClosingAt) > Duration(seconds: 1)
                  //     ? true
                  //     : bId.toString() == e["sender_id"].toString() && DateTime.parse(e['sent_at'].toString()).difference(userALastClosingAt) > Duration(seconds: 1)/*isBefore(userBLastClosingAt)*/
                  //     ? true
                  //     : false

                  // send_at: DateTime.now(),
                  // send_at:
                )
            );
          }
        }

      }

      notifyListeners();
      // return jsonData;
      return cm;
    }
    notifyListeners();
  }

  void addChatMessage(ChatMessage message) {
    // for(var e in messages) {
    //   if (e. == message.ticketCategoryId) {
    //     // e.quantity += ticket.quantity;
    //     notifyListeners();
    //     return;
    //   }
    // }
    //print('messages.length1');
    //print(messages.length);
    // List.from(messages).add(message);
    messages.add(message);
    // for(var e in items) {
    //   //print(e.toString());
    // }

    for(var e in messageList){
      // if(e.chat_id.toString() == chatId.toString()){
      if(e.chat_id.toString() == chatId.toString()){
        // socketProvider.messageList.remove(e);
        // socketProvider.messageList.add(
        //     new Chat(
        //       // chat_id: chatId,
        //       chat_id: int.tryParse(widget.chatId),
        //       receiver_id: receiverId,
        //       sender_id: widget.user.id,
        //       receiver_username: widget.receiverUsername,
        //       sender_username: widget.user.username,
        //       sent_at: DateTime.now().toLocal(),
        //       text: message,
        //       receiver_profile_image: widget.receiverProfileImage,
        //       sender_profile_image: widget.user.profile_image,
        //       user_a_id: widget.aId,
        //       user_b_id: widget.bId,
        //       // user_a_last_opening_at: user_a_last_opening_at,
        //       // user_b_last_opening_at: user_b_last_opening_at,
        //     )
        // );

        e.chat_message_list!.add(message);
        // e.unread_messages++;

        // //print('tttttt');
        for(var e in messageList){
          e.chat_message_list!.sort((a, b) {
            // return a.sent_at.compareTo(b.sent_at);
            return a.sent_at!.compareTo(b.sent_at!);
          });
          // //print(e.chat_message_list.last.text);
          // //print(e.chat_message_list.last.sent_at.toString());
        }
        //
        messageList.sort((b, a) {
          return a.chat_message_list!.last.sent_at!.compareTo(b.chat_message_list!.last.sent_at!);
        });
        break;
      }
    }

    //print('messages.length2');
    //print(messages.length);

    notifyListeners();
  }

  void addChatRoomMessage(ChatRoomMessage message) {
    // for(var e in messages) {
    //   if (e. == message.ticketCategoryId) {
    //     // e.quantity += ticket.quantity;
    //     notifyListeners();
    //     return;
    //   }
    // }
    roomMessages.add(message);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    notifyListeners();
  }

  void addBusinessChatRoomMessage(BusinessChatRoomMessage message) {
    // for(var e in messages) {
    //   if (e. == message.ticketCategoryId) {
    //     // e.quantity += ticket.quantity;
    //     notifyListeners();
    //     return;
    //   }
    // }

    //todo: qui devo impedire di mostrare piu messaggi contmporaneamente

    businessChatRoomMessages.add(message);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    notifyListeners();
  }

  deleteChatMessageInClient(String? text, String? senderId, String? receiverId, DateTime? sentAt) /*async*/ {
    for(var e in messageList){
      if(e.chat_id.toString() == chatId.toString()){
        for(var e1 in e.chat_message_list!){
          if(e1.sender_id == senderId && e1.receiver_id == receiverId
              && e1.sent_at!.isAtSameMomentAs(sentAt!) && e1.text == text){
            e.chat_message_list!.remove(e1);
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  editChatMessageInClient(String? oldText, String? senderId, String? receiverId, DateTime? sentAt, String newText) /*async*/ {
    for(var e in messageList){
      if(e.chat_id.toString() == chatId.toString()){
        for(var e1 in e.chat_message_list!){
          if(e1.sender_id == senderId && e1.receiver_id == receiverId
              && e1.sent_at!.isAtSameMomentAs(sentAt!) && e1.text == oldText){
            e1.text = newText;
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  updateOpeningChat(String chatId, bool isUserA, DateTime openingAt) {
    for(var e in messageList){
      if(e.chat_id.toString() == chatId.toString()){
        if(isUserA){
          e.user_a_last_opening_at = openingAt;
        }
        else if(!isUserA){
          e.user_b_last_opening_at = openingAt;
        }
      }
    }
    notifyListeners();
  }

  updateClosingChat(String chatId, bool isUserA, DateTime closingAt) {
    for(var e in messageList){
      if(e.chat_id.toString() == chatId.toString()){
        if(isUserA){
          e.user_a_last_closing_at = closingAt;
        }
        else if(!isUserA){
          e.user_b_last_closing_at = closingAt;
        }
      }
    }
    notifyListeners();
  }

  Future getChatId(String? userId, String? aId, String? bId) async {
    //print("aId:" + aId.toString());
    //print("bId:" + bId.toString());
    // var url = Uri.parse("http://192.168.1.252/kadingira/getChat.php");
    //
    // var response = await http.post(
    //     url,
    //     body: {
    //       "a_id": this.widget.aId,
    //       "b_id": this.widget.bId,
    //     });
    var url = Uri.parse(Utils.httpServerUrl + "chat/users");

    Map/*<String, String>*/ body = {
      "a_id": aId,
      "b_id": bId,
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
        }
    );

    //print("response.statusCode cccccc:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   chat = jsonData;
      // });
      // //print("chat: ");
      // //print(chat.toString());
      //print("jsonData[0]['id']");
      //print(jsonData[0]['id'].toString());

      // chatId = chat[0]['id'];
      chatId = jsonData[0]['id'];
      //print("chatId: ");
      //print(chatId);
      getAllChats(userId);
      notifyListeners();
      return jsonData;
    }
  }

  Future getAllChatRoomMessages(String? userId, Event event) async {
    // var url = Uri.parse(Constants.serverUrl + "single_event_room/user_id");
    var url = Uri.parse(Utils.httpServerUrl + "event_room/event");

    Map/*<String, String>*/ body = {
      "event_id": event.id.toString()
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
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('event1/user.length');
      //print(jsonData.length);
      // //print('single_event1/user');
      // //print(jsonData);
      for(var e in chatRooms){
        if(e.event!.id.toString() == event.id.toString()){
          // e.chatRoomMessages = [];
          for(var e1 in jsonData){
            e.chatRoomMessages!.add(
                ChatRoomMessage(
                  id: e1['event_room_id'],
                  text: e1['event_room_text'],
                  sent_at: DateTime.parse(e1['event_room_sent_at']),
                  is_visible: e1['event_room_is_visible'],
                  sender: User(
                    id: e1['user_id'],
                    name: e1['user_name'],
                    email: e1['user_email'],
                    username: e1['username'],
                    description: e1['user_description'],
                    phone: e1['user_phone'],
                    profile_image: e1['user_profile_image'] ?? '',
                  ),
                  event: Event(
                    id: e1['event_id'],
                    image: e1['event_image'],
                    title: e1['event_title'],
                    begin_at: DateTime.parse(e1['event_begin_at']),
                    end_at: DateTime.parse(e1['event_end_at']),
                    description: e1['event_description'],
                    is_visible: e1['event_is_visible'],
                  ),
                )
            );
          }
        }
      }
      // chatRooms = jsonData;
      notifyListeners();
      return jsonData;
    }
  }

  Future getAllChatRooms({String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "event/user");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userId}/event");

    Map/*<String, String>*/ body = {
      "id": userId
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('event/user.length');
      //print(jsonData.length);
      for(var e in jsonData){
        chatRooms.add(
            ChatRoom(
                event: Event(
                    id: e['event_id'],
                    image: e['event_image'],
                    title: e['event_title'],
                    begin_at: DateTime.parse(e['event_begin_at']),
                    end_at: DateTime.parse(e['event_end_at']),
                    description: e['event_description'],
                    // is_visible: int.tryParse(e['single_event_is_visible']),
                    // is_visible: e['single_event_is_visible'],
                    business: Business(
                      id: e['business_id'],
                      name: e['business_name'],
                      profile_image: e['business_profile_image'],
                      description: e['business_description'],
                      room_id: e['business_room_id'],
                      phone: e['business_phone'],
                      // is_date_business: e['is_date_business'],
                      address: e['business_address'],
                    )
                ),
                chatRoomMessages: []
            )
        );
      }
      // chatRooms = jsonData;
      // //print("posts provider");
      // //print(posts);
      notifyListeners();

      return jsonData;
    }
  }

  Future getAllChats(String? userId) async {
    var url = Uri.parse(Utils.httpServerUrl + "chat/user");

    Map/*<String, String>*/ body = {
      'user_id': userId,
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
        }
    );

    //print("response.statusCode8888:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   chat = jsonData;
      // });
      // //print("chat: ");
      // //print(chat.toString());
      // //print("jsonDataaaaaa");
      // //print(jsonData.toString());

      // //print("jsonData[0]['id']: ");
      // //print(jsonData[0]['id'].toString());

      // chatId = chat[0]['id'];
      // chatId = jsonData[0]['id'];
      // setState(() {
      chatList = jsonData;
      // });
      // //print("chatList: ");
      // //print(chatList);
      //print("chatList.length: " + chatList!.length.toString());
      notifyListeners();
      return jsonData;
    }
  }

}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

//todo: funzionante, da
/*Future<void> showNotification({
  // String senderUsername,
  String? body,
  String? senderUsername,
  String? senderName,
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String prestazioneImage = 'https://via.placeholder.com/48x48',
  String? text,
  String? title,
  String? senderId = '0',
  String subText = '',
  BuildContext? context,
}) async {
  await UserPreferences.init();
  final player = AudioPlayer();
  var sound;

  if(subText == 'Cancellazione'){
    sound = 'my_work_is_done_message_tone.ogg';
    await player.setAsset('assets/audio/my_work_is_done_message_tone.ogg');
  }
  else {
    sound = 'piece_of_cake_611.mp3';
    await player.setAsset('assets/audio/piece_of_cake_611.ogg');
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: null
      onSelectNotification: (notificationResponse) async {
        // if (notificationResponse.payload == 'sticky note.') {
        //   Get.to(() => const Screen1View());
        // } else {
        //   Get.to(() => const Screen2View());
        // }
        Navigator.push(
            context!,
            PageTransition(
                duration: const Duration(milliseconds: 500),
                alignment: Alignment.center,
                type: PageTransitionType.fade,
                child: NewsScreen()
            )
        );
      }
  );

  final Int64List vibrationPattern = Int64List(2);

  if(UserPreferences.getSilentNotifications() == false
      && UserPreferences.getEnableNotifications() == true) {
    // audioPlayer.play();
    player.play();
  }

  if(UserPreferences.getVibrateNotifications() == true
      && UserPreferences.getEnableNotifications() == true){
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
  }

  // final String bigPicturePath = await _downloadAndSaveFile(
  //   // 'https://via.placeholder.com/400x800',
  //     prestazioneImage,
  //     'bigPicture'
  // );
  // final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
  //     FilePathAndroidBitmap(largeIconPath),
  //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
  //     contentTitle: '$prestazioneTitle',
  //     htmlFormatContentTitle: true,
  //     summaryText: "<p>@$username</p>",
  //     htmlFormatSummaryText: true
  // );

  final String largeIcon = await _downloadAndSaveFile(
    // 'https://via.placeholder.com/48x48',
    //   imageProfile,
      largeIconPath,
      'largeIcon'
  );

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'fcm_nurebo_channel', 'fcm_nurebo_channel', //'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: UserPreferences.getSilentNotifications() == true ? true : false,
    // sound: RawResourceAndroidNotificationSound(sound.split('.').first),
    ticker: 'ticker',
    subText: subText,
    icon: 'calendar',
    largeIcon: FilePathAndroidBitmap(largeIcon),

    ledOffMs: 300,
    ledOnMs: 300,
    ledColor: Colors.blue,

    // fullScreenIntent: false,
    // groupKey: '1',
    // groupAlertBehavior: GroupAlertBehavior.children,
    // setAsGroupSummary: true,
    // enableVibration: BusinessPreferences.getVibrateNotifications() == true && BusinessPreferences.getEnableNotifications() == true ? true : false,
    enableVibration: false,
    enableLights: true,
    channelShowBadge: true,
    // tag: 'Taggatolo',
    // styleInformation: MediaStyleInformation(
    //   htmlFormatContent: true,
    //   htmlFormatTitle: false,
    // ),
    // styleInformation: bigPictureStyleInformation,
    // vibrationPattern: Int64List(20000),//vibrazione non va
    vibrationPattern: vibrationPattern,
    visibility: NotificationVisibility.public,
  );

  var ios = IOSNotificationDetails(
    sound: sound,
    presentSound: true,
    // presentSound: false,
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: ios
  );

  // await audioPlayer.setVolume(1.0);
  // await audioPlayer.play();

  await flutterLocalNotificationsPlugin.show(
    // 0,
      Random().nextInt(88887),
      title,
      // '@' + username,
      // beginAt,
      body,
      platformChannelSpecifics,
      payload: 'This is a demo app'
  );
}*/
