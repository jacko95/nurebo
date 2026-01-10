import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class NewsScreen extends StatefulWidget {
  final User? user;

  const NewsScreen({Key? key, this.user});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

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

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // UserPreferences.setUserLastUpdateNotification(DateTime.now());
    // UserPreferences.setUserLastOpenNotification();
    // //print("init UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());
    //
    // if(UserPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(userProvider.user);
    //   } ();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // UserPreferences.setUserLastUpdateNotification(DateTime.now());
    // UserPreferences.setUserLastClosedNotification();
    // //print("dispose UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());
  }

  @override
  Widget build(BuildContext context) {

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
          'Novità',
          // 'Le mie prestazioni',
          style: TextStyle(
              color: Colors.blue,
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .1,),
            Center(
              child: Image.asset(
                'assets/png/Saly-42.png',
                height: MediaQuery.of(context).size.height * .35,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                'Attualmente non ci sono novità',
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
