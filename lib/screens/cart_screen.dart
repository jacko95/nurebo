import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/notification_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/purchasing_screen.dart';
import 'package:nurebo/screens/register_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:get/get_utils/get_utils.dart';


class CartScreen extends StatefulWidget {
  final User? user;

  const CartScreen({super.key, this.user});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List tickets = [];
  UserProvider? userProvider;
  late CartProvider cartProvider;
  NotificationProvider? notificationProvider;
  late SocketProvider socketProvider;
  double totalCartOrder = 0;
  List<CartItem> subtotalBusiness = [];
  bool? isShared;
  List<int> resStatusItems = [];


  Future createTicket({int? quantity, String? singleEventTicketId}) async {
    var url = Uri.parse(Utils.httpServerUrl + "event_reservation/new_ticket");

    Map<String, dynamic> body = {
      'user_id': widget.user!.id,
      'event_ticket_id': singleEventTicketId,
      'quantity': quantity,
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
        }
    );

    // //print("abfgdg response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   singleEventList = jsonData;
      // });
      // //print(jsonData);
      return jsonData;
    }
  }

  Future notificationFollowers(Map<String, dynamic> socketBody/*String userId*/) async {
    var url = Uri.parse(Utils.httpServerUrl + "booking_notification/followers");

    var response = await http.post(
        url,
        body: jsonEncode(socketBody),
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

    // //print("hhhuhuh response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print(jsonData);

    }

    return response.statusCode;
  }

  // Future getAllSingleEvent() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "single_event");
  //
  //   var response = await http.get(
  //       url,
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       // tickets = jsonData;
  //       for(var i = 0; i < jsonData.length; i++){
  //         // tickets.add(jsonData[i]['id']);
  //         tickets.add(jsonData[i]);
  //       }
  //     });
  //     //print("tickets: ");
  //     //print(tickets);
  //     // //print("post.length: " + postList.length.toString());
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    isShared = true;
  }


  @override
  Widget build(BuildContext context) {
    cartProvider = Provider.of<CartProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    bool isNewBusinessItem = false;
    for(int i = 0; i < cartProvider.items.length; i++){
      // //print(cartProvider.items[i].business.id);
      for(var e in subtotalBusiness){
        if(cartProvider.items[i].business!.id != e.business!.id){
          isNewBusinessItem = true;
          subtotalBusiness.add(cartProvider.items[i]);
        }
      }
    }

    // //print('e.business.id');
    for(var e in subtotalBusiness){
      // //print(e.business.id.toString());
    }
    // //print(subtotalBusiness.length.toString());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartProvider.items.length >= 3 ? Container(
        margin: EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue[500])
          ),
          child: Text(
            // 'Paga',
            'Prenota',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            if(UserPreferences.getIsLogged()!){
              if(cartProvider.items.isNotEmpty) {
                Navigator.push(
                  context,
                  PageTransition(
                    duration: const Duration(
                        milliseconds: 500
                    ),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    child: PurchasingScreen()
                  )
                );
              }
              else{
                Fluttertoast.showToast(
                  msg: "Il carrello è vuoto!",
                  backgroundColor: Colors.grey[700],
                );
              }
            }
            else{
              // Navigator.push(
              //     context,
              //     PageTransition(
              //       duration: const Duration(milliseconds: 500),
              //       alignment: Alignment.center,
              //       type: PageTransitionType.fade,
              //       child: LoginScreen(),
              //     )
              // );
              Fluttertoast.showToast(
                // msg: 'Bisogna essere loggati per prenotare',
                msg: 'Accedi per prenotare',
                backgroundColor: Colors.grey[700],
              )/*.then((value) => */;
            }
            // await buy();
          },
        ),
      ) : SizedBox(height: 0,),
      // backgroundColor: Colors.white,

      appBar: /*(!Utils.isSocial && !Utils.isBusiness)*/false ? PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // SizedBox(height: 5,),
              Icon(
                // Icons.shopping_bag_outlined,
                Icons.shopping_cart_outlined,
                color: Colors.blue[500],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 4,
                  left: 4,
                  right: 4,
                ),
              ),
              Text(
                "Il tuo carrello",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 15
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.1,)
            ],
          ),
          // title: Text(
          //   // 'Carrello',
          //   'Il tuo carrello',
          //   style: TextStyle(
          //       color: Colors.blue,
          //       // color: Colors.grey[800],
          //       fontSize: 19,
          //       fontWeight: FontWeight.w700
          //   ),
          // ),
          // title: Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Text(
          //     // 'Admin',
          //     'nurebo',
          //     // 'kalixira',
          //     style: TextStyle(
          //         color: Colors.blue,
          //         fontWeight: FontWeight.w500,
          //         // fontSize: 27,
          //         fontSize: 34,
          //         // letterSpacing: -2,
          //         letterSpacing: -3,
          //         fontFamily: 'Panton'
          //       // fontFamily: 'UniNeue'
          //     ),
          //   ),
          // ),
          centerTitle: true,
          leading: Visibility(
            // visible: (!Utils.isBusiness || Utils.isSocial),
            visible: Utils.isSocial,
            child: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(
                // Icons.arrow_back_outlined,
                Icons.arrow_back_ios_new_rounded,
                color: Colors.grey[500],
                // size: 27,
                size: 22,
              ),
              color: Colors.black,
            ),
          ),
          actions: [
            // Padding(
            //   padding: const EdgeInsets.only(right: 15),
            //   child: Icon(
            //     Icons.textsms_outlined,
            //     color: Colors.grey[600],
            //     // color: Colors.blue[500],
            //     size: 28,
            //   ),
            // )
          ],
        ),
      ) : const PreferredSize(
        // preferredSize: Size.fromHeight(100),
        preferredSize: Size.fromHeight(55),
        // child: AppBar2(user: widget.user,),
        child: NureboAppBar(
          // user: userProvider.user,
          // user: widget.user,
        ),
      ),
      drawer: NureboDrawer(),
      onDrawerChanged: (value){
        // if(Utils.isSocial || Utils.isBusiness){
          //todo: false per nascondere bottombar
          //print(value);
          socketProvider.setBottomBarVisibility(!value);
        // }
      },
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            // physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Divider(height: 1, ),

              // Container(
              //   padding: EdgeInsets.only(
              //     top: 24,
              //     bottom: 16,
              //     left: 16,
              //     right: 16,
              //   ),
              //   color: Colors.white,
              //   width: double.infinity,
              //   child: Column(
              //     children: <Widget>[
              //       // SizedBox(height: 5,),
              //       Icon(
              //         // Icons.shopping_bag_outlined,
              //         Icons.shopping_cart_outlined,
              //         color: Colors.blue[500],
              //       ),
              //       Padding(
              //         padding: EdgeInsets.only(
              //           top: 0,
              //           bottom: 4,
              //           left: 4,
              //           right: 4,
              //         ),
              //       ),
              //       Text(
              //         "Il tuo carrello",
              //         style: GoogleFonts.poppins(
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // SizedBox(
              //   height: 10,
              //   child: Container(
              //     color: Colors.white,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12.0,
                  bottom: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      // 'Il tuo ordine',
                      'Le tue Prenotazioni',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        // color: Colors.blue,
                        color: Colors.grey[800],
                      ),
                    ),
                    // GestureDetector(
                    //   child: Text(
                    //     'Aggiungi evento',
                    //     style: TextStyle(
                    //         color: Colors.blue[500],
                    //         fontWeight: FontWeight.w700
                    //     ),
                    //   ),
                    //   onTap: () {
                    //
                    //   },
                    // ),
                  ],
                ),
              ),

              cartProvider.items.length > 0 ? Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                color: Colors.white,

                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => const Divider(
                      indent: 15,
                      endIndent: 15,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // itemCount: tickets.length,
                    // itemCount: cartData.orders.length,
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: ListTile(
                          leading: Container(
                            width: 80,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(0),
                              child: FutureImage(
                                cartProvider.items[i].image != null && cartProvider.items[i].image != ''
                                  ? cartProvider.items[i].image! : cartProvider.items[i].business!.profile_image!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          title: Padding(
                            padding: EdgeInsets.only(
                              top: 0.0,
                              bottom: 0,
                              left: 0,
                              right: 0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0,
                                          left: 3,
                                          right: 0
                                      ),
                                      width: MediaQuery.of(context).size.width * 0.55,
                                      child: Marquee(
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            SizedBox(width: cartProvider.items[i].isEvent! ? 2.5 : 1.5,),
                                            GradientText(
                                              cartProvider.items[i].business!.name ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              gradient: !cartProvider.items[i].isEvent!
                                                  // ? Gradients.backToFuture
                                                  ? LinearGradient(
                                                    begin: Alignment.bottomLeft,
                                                    end: Alignment.topRight,
                                                    colors: [
                                                      Color(0xff8921aa),
                                                      Color(0xffDA44bb),
                                                      // Color(0xffDA44bb)
                                                    ]
                                                  ) : LinearGradient(
                                                    begin: Alignment.bottomLeft,
                                                    end: Alignment.topRight,
                                                    colors: [
                                                      Color(0xff8921aa),
                                                      Colors.blue,
                                                      // Color(0xffDA44bb)
                                                    ]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: cartProvider.items[i].isEvent!,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 3,),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.53,
                                            child: Marquee(
                                              child: Row(
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  SizedBox(width: 1,),
                                                  /*Gradient*/Text(
                                                    cartProvider.items[i].isEvent! ? cartProvider.items[i].event!.title ?? '' : '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.grey[900]
                                                    ),
                                                    // gradient: LinearGradient(
                                                    //     begin: Alignment.bottomLeft,
                                                    //     end: Alignment.topRight,
                                                    //     colors: [
                                                    //       Color(0xff8921aa),
                                                    //       Color(0xffDA44bb),
                                                    //       // Color(0xffDA44bb)
                                                    //     ]
                                                    // ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 3,),
                                          // Container(
                                          //   width: MediaQuery.of(context).size.width * .5,
                                          //   padding: const EdgeInsets.all(0),
                                          //   margin: const EdgeInsets.all(0),
                                          //   child: Marquee(
                                          //     child: Row(
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       mainAxisAlignment: MainAxisAlignment.start,
                                          //       children: <Widget>[
                                          //         Text(
                                          //           cartProvider.items[i].isEvent ? DateFormat./*yMd*/yMMMMd('it_IT').format(cartProvider.items[i].event.begin_at).toString()
                                          //               + /*' dalle'*/'\n' + cartProvider.items[i].event.begin_at.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16)
                                          //               + ' - ' + cartProvider.items[i].event.end_at.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16) : '',
                                          //           style: TextStyle(
                                          //               fontSize: 12,
                                          //               fontWeight: FontWeight.w700
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.53,
                                            child: Marquee(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.event,
                                                    color: Colors.grey[600],
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 2,),
                                                  GradientText(
                                                    cartProvider.items[i].isEvent! ? DateFormat./*yMd*/yMMMMd('it_IT').format(cartProvider.items[i].event!.begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/).toString().toLowerCase()/*.capitalize!*/ : '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    gradient: LinearGradient(
                                                        begin: Alignment.bottomLeft,
                                                        end: Alignment.topRight,
                                                        colors: [
                                                          // Color(0xff8921aa),
                                                          // Color(0xffDA44bb),
                                                          Colors.grey[600]!,
                                                          Colors.grey[600]!,
                                                        ]
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.53,
                                            child: Marquee(
                                              child: Row(
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.grey[600],
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 2,),
                                                  GradientText(
                                                    cartProvider.items[i].isEvent! ? cartProvider.items[i].event!.begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                                        + ' - ' + cartProvider.items[i].event!.end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) : '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    gradient: LinearGradient(
                                                        begin: Alignment.bottomLeft,
                                                        end: Alignment.topRight,
                                                        colors: [
                                                          // Color(0xff8921aa),
                                                          // Color(0xffDA44bb),
                                                          Colors.grey[600]!,
                                                          Colors.grey[600]!,
                                                        ]
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3,),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.53,
                                      child: Marquee(
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              cartProvider.items[i].isEvent! ? cartProvider.items[i].eventTicket!.title!.toLowerCase()/*.capitalize!*/
                                                : cartProvider.items[i].title ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !cartProvider.items[i].isEvent!,
                                      child: Column(
                                        children: [
                                          SizedBox(height: 3,),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.53,
                                            child: Marquee(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.event,
                                                    color: Colors.grey[600],
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 2,),
                                                  /*Gradient*/Text(
                                                    !cartProvider.items[i].isEvent! ? DateFormat./*yMd*/yMMMMd('it_IT').format(cartProvider.items[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/).toString().toLowerCase()/*.capitalize!*/ : '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                    // gradient: LinearGradient(
                                                    //     begin: Alignment.bottomLeft,
                                                    //     end: Alignment.topRight,
                                                    //     colors: [
                                                    //       // Color(0xff8921aa),
                                                    //       // Color(0xffDA44bb),
                                                    //       Colors.grey[600]!,
                                                    //       Colors.grey[600]!,
                                                    //     ]
                                                    // ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.53,
                                            child: Marquee(
                                              child: Row(
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.grey[600],
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 2,),
                                                  GradientText(
                                                    !cartProvider.items[i].isEvent! ? cartProvider.items[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                                        + ' - ' + cartProvider.items[i].begin_at!.add(Duration(minutes: cartProvider.items[i].prestazione!.duration!))/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) : '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    gradient: LinearGradient(
                                                        begin: Alignment.bottomLeft,
                                                        end: Alignment.topRight,
                                                        colors: [
                                                          // Color(0xff8921aa),
                                                          // Color(0xffDA44bb),
                                                          Colors.grey[600]!,
                                                          Colors.grey[600]!,
                                                        ]
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3,),
                                  ],
                                ),
                                Container(
                                  width: 32,
                                  height: 37.5,
                                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.06),
                                  child: OutlinedButton(
                                    // style: ButtonStyle(
                                    //   padding: EdgeInsets.all(0),
                                    // ),
                                      style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          // minimumSize: Size(50, 30),
                                          alignment: Alignment.center
                                      ),
                                      onPressed: (){
                                        cartProvider.removeOrder(cartProvider.items[i]);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        // color: Colors.grey[600],
                                        color: Colors.red[800],
                                        size: 16,
                                      )
                                  ),
                                )
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
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 0.0,
                                                bottom: 0,
                                                left: 4,
                                                right: 0
                                            ),
                                            width: MediaQuery.of(context).size.width * .495,
                                            // padding: EdgeInsets.only(left: 3),
                                            child: Marquee(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  cartProvider.items[i].isEvent! && cartProvider.items[i].eventTicket!.additional != null ? Container(
                                                    width: MediaQuery.of(context).size.width * .4,
                                                    child: Marquee(
                                                      child: Text(
                                                        // cartProvider.items[i].isEvent ? cartProvider.items[i].ticketCategoryTitle
                                                       cartProvider.items[i].eventTicket!.additional!.toUpperCase(),
                                                        // : order.items[i].duration.toString() + ' minuti',
                                                      // : '',
                                                      //     : DateFormat./*yMd*/yMMMMd('it_IT').format(cartProvider.items[i].begin_at).toString()
                                                      //     + /*' dalle'*/'\n' + cartProvider.items[i].begin_at.toString().substring(11, 16)
                                                      //     + ' - ' + cartProvider.items[i].begin_at.add(Duration(minutes: cartProvider.items[i].duration.toInt())).toString().substring(11, 16),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700
                                                        ),
                                                      ),
                                                    ),
                                                  ) : SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: !cartProvider.items[i].isEvent! ? 6.0 : 0, top: cartProvider.items[i].isEvent! ? 4.0 : 0),
                                            child: Text(
                                              cartProvider.items[i].isEvent! ? ' € ' + NumberFormat.currency(
                                                // customPattern: '#,##',
                                                  decimalDigits: 2,
                                                  symbol: '',
                                                  locale: 'IT_it'
                                              ).format(
                                                // (cartProvider.items[i].ticketCategoryPrice * cartProvider.items[i].quantity)?.toDouble())
                                                  (cartProvider.items[i].eventTicket!.price! * cartProvider.items[i].quantity!)?.toDouble())
                                                  : '€ ' + NumberFormat.currency(
                                                // customPattern: '#,##',
                                                  decimalDigits: 2,
                                                  symbol: '',
                                                  locale: 'IT_it'
                                              ).format(
                                                  cartProvider.items[i].presale_price!?.toDouble()),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 70,
                                        height: 33,
                                        margin: EdgeInsets.only(right: 0),
                                        child: OutlinedButton(
                                          // style: ButtonStyle(
                                          //   padding: EdgeInsets.all(0),
                                          // ),
                                            style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                // minimumSize: Size(50, 30),
                                                alignment: Alignment.center
                                            ),
                                            onPressed: (){
                                              // cartProvider.removeOrder(cartProvider.items[i]);
                                              setState(() {
                                                cartProvider.items[i].is_shared = !cartProvider.items[i].is_shared;
                                              });
                                            },
                                            child: Text(
                                              cartProvider.items[i].is_shared ? "Pubblico" : "Privato",
                                              style: TextStyle(
                                                color: cartProvider.items[i].is_shared ? Colors.blue : Colors.red[600],
                                                fontSize: 12
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: cartProvider.items[i].isEvent! ? 3 : 3,),
                                  // Row(
                                  //   children: [
                                  //     Padding(
                                  //       padding: EdgeInsets.only(left: !cartProvider.items[i].isEvent! ? 6.0 : 0),
                                  //       child: Text(
                                  //         cartProvider.items[i].isEvent! ? ' € ' + NumberFormat.currency(
                                  //           // customPattern: '#,##',
                                  //             decimalDigits: 2,
                                  //             symbol: '',
                                  //             locale: 'IT_it'
                                  //         ).format(
                                  //             // (cartProvider.items[i].ticketCategoryPrice * cartProvider.items[i].quantity)?.toDouble())
                                  //             (cartProvider.items[i].eventTicket!.price! * cartProvider.items[i].quantity!)?.toDouble())
                                  //             : '€ ' + NumberFormat.currency(
                                  //           // customPattern: '#,##',
                                  //             decimalDigits: 2,
                                  //             symbol: '',
                                  //             locale: 'IT_it'
                                  //         ).format(
                                  //           cartProvider.items[i].presale_price!?.toDouble()),
                                  //           style: TextStyle(
                                  //             fontSize: 14,
                                  //             color: Colors.blue,
                                  //             fontWeight: FontWeight.w800
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     // SizedBox(width: 100,),
                                  //     // Container(
                                  //     //   width: 80,
                                  //     //   height: 37.5,
                                  //     //   child: OutlinedButton(
                                  //     //     // style: ButtonStyle(
                                  //     //     //   padding: EdgeInsets.all(0),
                                  //     //     // ),
                                  //     //       style: OutlinedButton.styleFrom(
                                  //     //           padding: EdgeInsets.zero,
                                  //     //           // minimumSize: Size(50, 30),
                                  //     //           alignment: Alignment.center
                                  //     //       ),
                                  //     //       onPressed: (){
                                  //     //         // cartProvider.removeOrder(cartProvider.items[i]);
                                  //     //       },
                                  //     //       child: Text(
                                  //     //         "Pubblico",
                                  //     //         style: TextStyle(
                                  //     //             color: Colors.blue
                                  //     //         ),
                                  //     //       )
                                  //     //   ),
                                  //     // ),
                                  //   ],
                                  // ),
                                  SizedBox(height: 5),
                                ],
                              ),
                              // Column(
                              //   children: [
                              //     SizedBox(height: 40,),
                              //     cartProvider.items[i].isEvent ? Row(
                              //       // mainAxisAlignment: MainAxisAlignment.end,
                              //       // crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: <Widget>[
                              //         ButtonTheme(
                              //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              //           height: 28,
                              //           minWidth: 28,
                              //           child: OutlinedButton(
                              //             style: OutlinedButton.styleFrom(
                              //               // borderSide: BorderSide(
                              //               //   color: Colors.black38,
                              //               // ),
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.circular(100),
                              //               ),
                              //               padding: EdgeInsets.all(4),
                              //             ),
                              //             child: Icon(
                              //               Icons.remove,
                              //               size: 12,
                              //             ),
                              //             onPressed: cartProvider.items[i].quantity <= 1
                              //                 ? null
                              //                 : () {
                              //               setState(() {
                              //                 // cartProvider.items[i].quantity--;
                              //                 cartProvider.subtractQuantity(i);
                              //               });
                              //             },
                              //           ),
                              //         ),
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 12.0
                              //           ),
                              //           child: Text(
                              //             // "${order.quantity}",
                              //             cartProvider.items[i].quantity.toString(),
                              //             style: TextStyle(
                              //                 color: Colors.blue[500],
                              //                 fontSize: 15,
                              //                 fontWeight: FontWeight.w600
                              //             ),
                              //           ),
                              //         ),
                              //         ButtonTheme(
                              //           height: 28,
                              //           minWidth: 28,
                              //           materialTapTargetSize:
                              //           MaterialTapTargetSize.shrinkWrap,
                              //           child: OutlinedButton(
                              //             style: OutlinedButton.styleFrom(
                              //               // borderSide: BorderSide(
                              //               //   color: Colors.black38,
                              //               // ),
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.circular(100),
                              //               ),
                              //               padding: EdgeInsets.only(
                              //                 right: 4,
                              //                 left: 4,
                              //                 bottom: 4,
                              //                 top: 4,
                              //               ),
                              //             ),
                              //             child: Icon(
                              //               Icons.add,
                              //               size: 12,
                              //             ),
                              //             onPressed: () {
                              //               setState(() {
                              //                 // cartProvider.items[i].quantity++;
                              //                 cartProvider.addQuantity(i);
                              //               });
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //     ) : Text(''),
                              //   ],
                              // ),
                            ],
                          ),
                          isThreeLine: /*!cartProvider.items[i].isEvent ? true : */false,

                        ),
                      );
                    }
                ),
              ) : Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                    // Lottie.asset(
                    //   'assets/animations/85849-shopping.json',
                    //   // 'assets/animations/69177-cart.json',
                    //   height: MediaQuery.of(context).size.height * 0.2,
                    //   width: MediaQuery.of(context).size.height * 0.2,
                    //
                    // ),
                    Image.asset(
                      'assets/png/Saly-2.png',
                      height: MediaQuery.of(context).size.height * .2,
                      // width: MediaQuery.of(context).size.width * .7,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * .008,),
                    Center(
                      child: Text(
                        // 'Non ci sono ancora notifiche...',
                        "Il carrello è vuoto",
                        // 'Le mie prestazioni',
                        style: TextStyle(
                          // color: Colors.blue,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w700,
                            fontSize: 16
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                  ],
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(
              //     left: 16,
              //     right: 16,
              //     top: 20.0,
              //     bottom: 8,
              //   ),
              //   child: Text(
              //     'Maybe you would like these?',
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // Container(
              //   height: 80,
              //   width: double.infinity,
              //   padding: EdgeInsets.symmetric(horizontal: 8),
              //   child: ListView(
              //     shrinkWrap: true,
              //     scrollDirection: Axis.horizontal,
              //     children: cartData.recommendedOrders.map((order) {
              //       return Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.circular(16),
              //           ),
              //           padding: EdgeInsets.symmetric(
              //             vertical: 12,
              //             horizontal: 16,
              //           ),
              //           child: Row(
              //             children: <Widget>[
              //               SizedBox(
              //                 width: 80,
              //                 child: Column(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: <Widget>[
              //                     Text(
              //                       order.name,
              //                       style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 11,
              //                       ),
              //                     ),
              //                     Text(
              //                       "\$${order.price.toStringAsFixed(2)}",
              //                       style: TextStyle(
              //                         fontSize: 11,
              //                       ),
              //                     )
              //                   ],
              //                 ),
              //               ),
              //               Image.network(order.imageUrl)
              //             ],
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),

              // Padding(
              //   padding: const EdgeInsets.only(
              //     left: 16,
              //     right: 16,
              //     top: 12.0,
              //     bottom: 12,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: <Widget>[
              //       Text(
              //         'Opzioni',
              //         style: GoogleFonts.roboto(
              //           fontWeight: FontWeight.w700,
              //           // color: Colors.blue,
              //           color: Colors.grey[800],
              //
              //         ),
              //       ),
              //       // GestureDetector(
              //       //   child: Text(
              //       //     'Aggiungi evento',
              //       //     style: TextStyle(
              //       //         color: Colors.blue[500],
              //       //         fontWeight: FontWeight.w700
              //       //     ),
              //       //   ),
              //       //   onTap: () {
              //       //
              //       //   },
              //       // ),
              //       // Text(
              //       //   // totalCartOrder.toString(),
              //       //   '€ ' + NumberFormat.currency(
              //       //     // customPattern: '#,##',
              //       //       decimalDigits: 2,
              //       //       symbol: '',
              //       //       locale: 'IT_it'
              //       //   // ).format(cartProvider.getTotalOrder()?.toDouble()),
              //       //   ).format(cartProvider.totalCartOrder?.toDouble()),
              //       //   style: GoogleFonts.roboto(
              //       //     fontWeight: FontWeight.w700,
              //       //     // color: Colors.blue,
              //       //     color: Colors.grey[800],
              //       //
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // InkWell(
              //   onTap: (){
              //     // if(isShared){
              //     //   setState(() {
              //     //     isShared = !isShared;
              //     //   });
              //     // }
              //     // else if(!isShared){
              //     //
              //     // }
              //     setState(() {
              //       isShared = !isShared;
              //     });
              //   },
              //   child: Container(
              //     padding: EdgeInsets.only(
              //       top: 8,
              //       bottom: 8,
              //       left: 15,
              //       right: 15
              //     ),
              //     width: double.infinity,
              //     color: Colors.white,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             SizedBox(width: 5,),
              //             Icon(
              //               Icons.public,
              //               color: Colors.grey[600],
              //               size: 20,
              //             ),
              //             SizedBox(width: 30,),
              //             Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Padding(
              //                   padding: EdgeInsets.only(bottom: .0),
              //                   child: Text(
              //                     'Condividi',
              //                     style: GoogleFonts.roboto(
              //                         fontWeight: FontWeight.w600,
              //                         // color: Colors.blue,
              //                         color: Colors.grey[800],
              //                         fontSize: 15
              //                     ),
              //                   ),
              //                 ),
              //                 SizedBox(height: 2,),
              //                 Container(
              //                   width: MediaQuery.of(context).size.width * 0.6,
              //                   child: Text(
              //                     'Notifica la partecipazione ai tuoi followers!',
              //                     style: GoogleFonts.roboto(
              //                         fontWeight: FontWeight.w500,
              //                         // color: Colors.blue,
              //                         color: Colors.grey[600],
              //                         fontSize: 13
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //         Container(
              //           padding: EdgeInsets.only(right: 15),
              //           width: 24,
              //           // height: 24,
              //           // padding: EdgeInsets.only(left: 50),
              //           // margin: EdgeInsets.only(left: 50),
              //           child: Checkbox(
              //             value: isShared,
              //             // splashRadius: 20,
              //             onChanged: (value) {
              //               setState(() {
              //                 isShared = value;
              //               });
              //             },
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12.0,
                  bottom: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      // 'Metodo di Pagamento',
                      'Modalità di Pagamento',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        // color: Colors.blue,
                        color: Colors.grey[800],

                      ),
                    ),
                    // GestureDetector(
                    //   child: Text(
                    //     'Aggiungi evento',
                    //     style: TextStyle(
                    //         color: Colors.blue[500],
                    //         fontWeight: FontWeight.w700
                    //     ),
                    //   ),
                    //   onTap: () {
                    //
                    //   },
                    // ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 8,
                  horizontal: 15
                ),
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(width: 5,),
                    Icon(
                      Icons.payment_outlined,
                      size: 22,
                      // color: Colors.blue,
                      // color: Colors.red,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 25,),
                    Text(
                      'Il pagamento sarà effettuato\nnel locale in cui si è prenotato',
                      maxLines: 3,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        // color: Colors.blue,
                        // color: Colors.red,
                        color: Colors.grey[800],
                        decoration: TextDecoration.underline,
                        fontSize: 14.5,
                        // letterSpacing: .3,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(
              //     left: 16,
              //     right: 16,
              //     top: 12.0,
              //     bottom: 12,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: <Widget>[
              //       Text(
              //         'Subtotale',
              //         style: GoogleFonts.roboto(
              //           fontWeight: FontWeight.w700,
              //           // color: Colors.blue,
              //           color: Colors.grey[800],
              //
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //       vertical: 8,
              //       horizontal: 15
              //   ),
              //   width: double.infinity,
              //   color: Colors.white,
              //   child: Row(
              //     children: [
              //       // Text(
              //       //   '•',
              //       //   style: GoogleFonts.roboto(
              //       //     fontWeight: FontWeight.w600,
              //       //     // color: Colors.blue,
              //       //     color: Colors.grey[600],
              //       //     height: 1.3,
              //       //     fontSize: 20
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12.0,
                  bottom: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Totale',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        // color: Colors.blue,
                        color: Colors.grey[800],
                        // color: Color(0xff8921aa),
                      ),
                    ),
                    // GestureDetector(
                    //   child: Text(
                    //     'Aggiungi evento',
                    //     style: TextStyle(
                    //         color: Colors.blue[500],
                    //         fontWeight: FontWeight.w700
                    //     ),
                    //   ),
                    //   onTap: () {
                    //
                    //   },
                    // ),
                    Text(
                      // totalCartOrder.toString(),
                      '€ ' + NumberFormat.currency(
                        // customPattern: '#,##',
                          decimalDigits: 2,
                          symbol: '',
                          locale: 'IT_it'
                        // ).format(cartProvider.getTotalOrder()?.toDouble()),
                      ).format(cartProvider.totalCartOrder?.toDouble()),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w900,
                        color: Colors.blue[600],
                        // color: Colors.grey[900],
                        // color: Color(0xff8921aa),
                        fontSize: 22

                      ),
                    ),
                  ],
                ),
              ),
              cartProvider.items.length < 3 ? Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.blue[500])

                          ),
                          child: Text(
                            // 'Paga',
                            'Prenota',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          onPressed: () async {
                            if(UserPreferences.getIsLogged()!){
                              if(cartProvider.items.isNotEmpty) {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        duration: const Duration(
                                            milliseconds: 500
                                        ),
                                        alignment: Alignment.center,
                                        type: PageTransitionType.fade,
                                        child: PurchasingScreen()
                                    )
                                );
                              }
                              else{
                                Fluttertoast.showToast(
                                  msg: "Il carrello è vuoto!",
                                  backgroundColor: Colors.grey[700],
                                );
                              }
                            }
                            else{
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //       duration: const Duration(milliseconds: 1000),
                              //       alignment: Alignment.center,
                              //       reverseDuration: const Duration(milliseconds: 700),
                              //       // type: PageTransitionType.fade,
                              //       type: PageTransitionType.bottomToTop,
                              //       child: RegisterScreen(),
                              //     )
                              // );
                              Fluttertoast.showToast(
                                // msg: 'Bisogna essere loggati per prenotare',
                                msg: 'Accedi per prenotare',
                                backgroundColor: Colors.grey[700],
                              )/*.then((value) => */;
                            }
                            // await buy();
                          },
                        ),
                      )
                    ),
                    SizedBox(height: 15,),
                  ],
                ),
              ) : SizedBox(height: 0,),
              cartProvider.items.length >= 2 ? Container(height: 100, color: Colors.white,) : SizedBox(height: 0,),
            ],
          ),
        )
      ),
    );
  }
}
