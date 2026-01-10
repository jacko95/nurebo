import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/custom_dialog.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';


class SettingsNotificationScreen extends StatefulWidget {

  const SettingsNotificationScreen({Key? key,});

  @override
  _SettingsNotificationScreenState createState() => _SettingsNotificationScreenState();
}

class _SettingsNotificationScreenState extends State<SettingsNotificationScreen> {
  // var userProvider;
  bool? isEnabled;
  bool? isBackground;
  bool? isVibrate;
  bool? isSilent;
  bool? isExperience;
  bool? isFollow;
  bool? isBooking;
  bool? isPost;
  bool? isEmailNotification;
  SocketProvider? socketProvider;
  late UserProvider userProvider;

  Future<int> updateEmailNotification() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/email_notification");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/email_notification");

    Map<String, dynamic> body = {
      'email_notification': isEmailNotification == true ? 1 : 0,
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

      userProvider.updateEmailNotification(isEmailNotification == true ? 1 : 0);

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
            title: 'Disattivare il Background',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Disattiva',
            confirmCallback: () async {
              await UserPreferences.setBackgroundNotifications(false);

              // FlutterBackgroundService().sendData({"action": "setAsBackground"});
              // FlutterBackgroundService().invoke("setAsBackground");

              setState(() {
                // isEnabled = value;
                isBackground = UserPreferences.getBackgroundNotifications()! && isEnabled!;
              });

              Fluttertoast.showToast(
                msg: 'Background disattivato',
                backgroundColor: Colors.grey[700],
              );
            },
            // dismissCallback: ,

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

  Future<void> _showDeletingDialog1(String module) async {
    showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Disattivare le notifiche in background',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Disattiva',
            confirmCallback: () async {
              // await UserPreferences.setBackgroundNotifications(false);
              //
              // // FlutterBackgroundService().sendData({"action": "setAsBackground"});
              // FlutterBackgroundService().invoke("setAsBackground");
              //
              // setState(() {
              //   // isEnabled = value;
              //   isBackground = UserPreferences.getBackgroundNotifications() && isEnabled;
              // });
              //
              // Fluttertoast.showToast(
              //   msg: 'Background disattivato',
              //   backgroundColor: Colors.grey[700],
              //
              // );

              await UserPreferences.setEnableNotifications(false);
              setState(() {
                // isEnabled = value;
                isEnabled = UserPreferences.getEnableNotifications();
              });
              // FlutterBackgroundService().invoke("stopService");
            },
            // dismissCallback: ,

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

    UserPreferences.init();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    isEnabled = UserPreferences.getEnableNotifications();
    isBackground = UserPreferences.getBackgroundNotifications();
    isVibrate = UserPreferences.getVibrateNotifications();
    isSilent = UserPreferences.getSilentNotifications();
    isExperience = UserPreferences.getFollowExperienceNotifications();
    isFollow = UserPreferences.getNewFollowNotifications();
    isBooking = UserPreferences.getFollowBookingNotifications();
    isPost = UserPreferences.getFollowPostNotifications();
    isEmailNotification = userProvider.user!.email_notification == 1 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(this.context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue, //change your color here
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
            // 'I miei dati',
            'Notifiche',
            style: TextStyle(
                color: Colors.blue,
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 15
            ),
          ),
          actions: [

          ],
        ),
      ),
      // body: buildSettingsList(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          // backgroundColor: Colors.white,
          shrinkWrap: true,
          children: [
            // SizedBox(height: 5,),
            //
            // Theme(
            //   data: ThemeData(
            //     splashColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //   ),
            //   child: SwitchListTile(
            //     // isThreeLine: true,
            //     hoverColor: Colors.transparent,
            //     focusNode: FocusNode(
            //
            //     ),
            //     // enableFeedback: false,
            //     selectedTileColor: Colors.transparent,
            //     // activeColor: Colors.transparent,
            //     // activeTrackColor: Colors.transparent,
            //     // tileColor: Colors.transparent,
            //     title: Container(
            //       width: MediaQuery.of(context).size.width * .5,
            //       child: Row(
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications_none,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .53,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     // 'Abilitate',
            //                     'Locali',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   // 'Ricevi notifiche di chat, esperienze e molto altro dai tuoi amici!',
            //                   // 'Ricevi notifiche di chat, prenotazioni, esperienze e molto altro dai tuoi clienti!',
            //                   // 'Ricevi notifiche di post, esperienze, prenotazioni e molto altro dagli utenti che segui!',
            //                   'Ricevi notifiche di prenotazioni, cancellazioni e molto altro!',
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //
            //         ],
            //       ),
            //     ),
            //     // subtitle: Text(
            //     //   "Attiva la vibrazione per le notifiche",
            //     //   // style: GoogleFonts.roboto(
            //     //   style: TextStyle(
            //     //     // fontWeight: FontWeight.w500,
            //     //     // color: Colors.blue,
            //     //       color: Colors.grey[600],
            //     //       fontSize: 13
            //     //   ),
            //     // ),
            //     value: isEnabled && UserPreferences.getIsLogged(),
            //     // splashRadius: 20,
            //     onChanged: (value) async {
            //       // await UserPreferences.setEnableNotifications(value);
            //       // setState(() {
            //       //   // isEnabled = value;
            //       //   isEnabled = UserPreferences.getEnableNotifications();
            //       // });
            //       if(value && isBackground){
            //         await UserPreferences.setEnableNotifications(value);
            //         setState(() {
            //           // isEnabled = value;
            //           isEnabled = UserPreferences.getEnableNotifications();
            //         });
            //         // var c = BackgroundServiceProvider.instance.registerFunction(socketProvider.connect(widget.business.id));
            //         // var b = registerFunction();
            //
            //         // // var a = BackgroundServiceProvider.instance.registerFunction(backgroundFunction);
            //         // // await FlutterBackgroundService().start();
            //         // await FlutterBackgroundService().startService();
            //       }
            //       if(value && !isBackground){
            //         await UserPreferences.setEnableNotifications(value);
            //         setState(() {
            //           // isEnabled = value;
            //           isEnabled = UserPreferences.getEnableNotifications();
            //         });
            //         // var c = BackgroundServiceProvider.instance.registerFunction(socketProvider.connect(widget.business.id));
            //         // var b = registerFunction();
            //
            //         // // var a = BackgroundServiceProvider.instance.registerFunction(backgroundFunction);
            //         // // await FlutterBackgroundService().start();
            //         // await FlutterBackgroundService().startService();
            //       }
            //       else if(!value){
            //         // var a = BackgroundServiceProvider.instance.stopFunction();
            //         // FlutterBackgroundService().stopBackgroundService();
            //         // FlutterBackgroundService().sendData({"action": "stopService"},);
            //
            //         // FlutterBackgroundService().invoke("stopService");
            //
            //         await _showDeletingDialog1(
            //             "Disattivando questa opzione non potrai ricevere notifiche"
            //         );
            //       }
            //     },
            //   ),
            // ),

            // SizedBox(height: 5,),
            //
            // Theme(
            //   data: ThemeData(
            //     splashColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //   ),
            //   child: SwitchListTile(
            //     // isThreeLine: true,
            //     // selected: !isEnabled,
            //     // selectedTileColor: Colors.grey[200],
            //
            //     title: Container(
            //       width: MediaQuery.of(context).size.width * .5,
            //       child: Row(
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.mark_email_read_outlined,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .53,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Email',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Ricevi notifiche mail riguardanti le tue prenotazioni",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //
            //         ],
            //       ),
            //     ),
            //     // value: userProvider.user.email_notification == 1 ? true : false,
            //     value: isEmailNotification!,
            //     onChanged: (value) async {
            //       // await UserPreferences.setSilentNotifications(value);
            //       isEmailNotification = value;
            //       int status = await updateEmailNotification();
            //       if(status >= 200 && status < 400){
            //         if(value){
            //           setState(() {
            //             userProvider.user!.email_notification = 1;
            //             isEmailNotification = value;
            //           });
            //         }
            //         else {
            //           setState(() {
            //             userProvider.user!.email_notification = 0;
            //             isEmailNotification = value;
            //           });
            //         }
            //       }
            //       //print('userProvider.user.email_notification');
            //       //print(userProvider.user!.email_notification);
            //     },
            //   ),
            // ),
            //
            // SizedBox(height: 5,),
            //
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(left: 15.0, top: 20, bottom: 5),
            //       child: Text(
            //         'Generale',
            //         style: GoogleFonts.roboto(
            //           color: Colors.blue,
            //           fontWeight: FontWeight.w800,
            //           //color: Color.fromRGBO(245, 93, 62, 1),
            //           // background:
            //           // letterSpacing: -3,
            //           fontSize: 15,
            //           //fontWeight: FontWeight.w200,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            //
            // SizedBox(height: 10,),

            // Container(
            //   padding: EdgeInsets.only(
            //     top: 8,
            //     bottom: 8,
            //     left: 15,
            //     right: 15
            //   ),
            //   width: double.infinity,
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             // Icons.notifications_active_outlined,
            //             Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .6,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Background',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Ricevi notifiche anche quando l'app è chiusa!",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       Container(
            //         padding: EdgeInsets.only(right: 25,),
            //         // margin: EdgeInsets.only(left: 55,),
            //         width: 24,
            //         // height: 24,
            //         // padding: EdgeInsets.only(left: 50),
            //         // margin: EdgeInsets.only(left: 50),
            //         child: Switch(
            //           value: isBackground,
            //           // splashRadius: 20,
            //           onChanged: (value) {
            //             setState(() {
            //               isBackground = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Theme(
            //   data: ThemeData(
            //     splashColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //   ),
            //   child: SwitchListTile(
            //     // isThreeLine: true,
            //     hoverColor: Colors.transparent,
            //     selected: false,
            //     focusNode: FocusNode(
            //
            //     ),
            //     // enableFeedback: false,
            //     selectedTileColor: Colors.transparent,
            //     // activeColor: Colors.transparent,
            //     // activeTrackColor: Colors.transparent,
            //     // tileColor: Colors.transparent,
            //     title: Container(
            //       width: MediaQuery.of(context).size.width * .5,
            //       child: Row(
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .53,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Background',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "L'app rimane attiva in background, così puoi ricevere notifiche anche quando l'app è chiusa!",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //
            //         ],
            //       ),
            //     ),
            //
            //     value: isBackground && isEnabled && UserPreferences.getIsLogged(),
            //     // splashRadius: 20,
            //     onChanged: (value) async {
            //       // //print(await FlutterBackgroundService().isServiceRunning());
            //       // //print(await FlutterBackgroundService().isRunning());
            //
            //       if(value && isEnabled){
            //         // // FlutterBackgroundService().sendData({"action": "setAsForeground"});
            //         // FlutterBackgroundService().invoke("setAsForeground");
            //
            //         await UserPreferences.setBackgroundNotifications(value);
            //         setState(() {
            //           // isEnabled = value;
            //           isBackground = UserPreferences.getBackgroundNotifications() && isEnabled;
            //         });
            //       }
            //       else if(!value){
            //         // FlutterBackgroundService().stopBackgroundService();
            //         // FlutterBackgroundService().sendData({"action": "stopService"},);
            //         // FlutterBackgroundService().sendData({"action": "setAsBackground"});
            //
            //         await _showDeletingDialog(
            //             "Disattivando il Background non si potranno ricevere notifiche quando l'app è chiusa"
            //         );
            //       }
            //     },
            //   ),
            // ),
            //
            // SizedBox(height: 10,),

            // Container(
            //   padding: EdgeInsets.only(
            //       top: 8,
            //       bottom: 8,
            //       left: 15,
            //       right: 15
            //   ),
            //   width: double.infinity,
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications_active_outlined,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .6,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Vibrazione',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Attiva la vibrazione per le notifiche",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //
            //       InkWell(
            //         onTap: (){
            //           setState(() {
            //             isVibrate = !isVibrate;
            //           });
            //         },
            //         child: Container(
            //           padding: EdgeInsets.only(right: 25, left: 0, top: 0),
            //           // margin: EdgeInsets.only(left: 55,),
            //           width: 24,
            //           // height: 24,
            //           // padding: EdgeInsets.only(left: 50),
            //           // margin: EdgeInsets.only(left: 50),
            //           child: Switch(
            //             value: isVibrate,
            //             // autofocus: true,
            //
            //             // splashRadius: 20,
            //             onChanged: (value) {
            //               setState(() {
            //                 isVibrate = value;
            //               });
            //             },
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.notifications_active_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Vibrazione',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Attiva la vibrazione per le notifiche",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                value: isVibrate! && isEnabled! && UserPreferences.getIsLogged()!,
                onChanged: (value) async {
                  await UserPreferences.setVibrateNotifications(value);
                  setState(() {
                    // isEnabled = value;
                    isVibrate = UserPreferences.getVibrateNotifications()! && isEnabled!;
                  });
                },
              ),
            ),

            SizedBox(height: 10,),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.notifications_off_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Silenzioso',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Attiva la modalità silenziosa per le notifiche",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                value: isSilent! && isEnabled! && UserPreferences.getIsLogged()!,
                onChanged: (value) async {
                  await UserPreferences.setSilentNotifications(value);
                  setState(() {
                    // isEnabled = value;
                    isSilent = UserPreferences.getSilentNotifications()! && isEnabled!;
                  });
                },
              ),
            ),

            SizedBox(height: 5,),

          ],
        ),
      ),
    );
  }

}
