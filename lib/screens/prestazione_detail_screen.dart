import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/tab_bar_sliver_persistent_header_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:expandable_text/expandable_text.dart';


class PrestazioneDetailScreen extends StatefulWidget {
  // final Business bookingBusiness;
  // final User user;
  final Prestazione? prestazione;

  const PrestazioneDetailScreen({super.key, /*this.bookingBusiness,*/ /*this.user,*/ this.prestazione});

  @override
  _PrestazioneDetailScreenState createState() => _PrestazioneDetailScreenState();
}

class _PrestazioneDetailScreenState extends State<PrestazioneDetailScreen> {
  // List prestazioneBuyers = [];
  // List businessPostLikes = [];
  bool isLikedPost = false;
  Future? a, b, /*c,*/ d, e;
  late UserProvider userProvider;
  // CartProvider cartProvider;
  // FavoriteProvider favoriteProvider;
  // GeolocationProvider geolocationProvider;


  // Future getAllPrestazioneBuyers() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione/buyers");
  //
  //   Map<String, dynamic> body = {
  //     "prestazione_id": widget.prestazione.id
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
  //         // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
  //       }
  //   );
  //
  //   //print("singleEventReservationBuyers response.statusCode");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       prestazioneBuyers = jsonData;
  //     });
  //     //print("singleEventReservationBuyers:");
  //     //print(prestazioneBuyers);
  //
  //     return jsonData;
  //   }
  // }


  Future getPrestazioneLike({String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/prestazione/${widget.prestazione!.id}");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
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

    // if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
    //   await logout();
    // }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // businessPostLikes = jsonData;
      // //print("likes???");
      // //print(posts);
      // //print(jsonData);

      if(jsonData == 1){
        setState(() {
          isLikedPost = true;
        });

      }
      else if(jsonData == 0){
        setState(() {
          isLikedPost = false;
        });
      }
      // notifyListeners();
      return jsonData;
    }
  }

  Future likePrestazione({String? postId, String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/like");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/${widget.prestazione!.id}/like");

    Map<String, dynamic> body = {
      // "user_id": widget.user.id,
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
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
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      await getPrestazioneLike(/*userId*/);

      return response.statusCode;
    }
  }

  Future unlikePrestazione({String? postId, String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/unlike");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/${widget.prestazione!.id}/like");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
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

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      await getPrestazioneLike(/*userId*/);

      return response.statusCode;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    // //print('widget.prestazione.toJson()');
    // //print(widget.prestazione.toJson());
    // //print('widget.prestazione.business.toJson()');
    // //print(widget.prestazione.business.toJson());

    userProvider = Provider.of<UserProvider>(context, listen: false);
    // cartProvider = Provider.of<CartProvider>(context, listen: false);
    // favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    // geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);

    // e = geolocationProvider.getGeolocationPermission().then((value) {
    //   // if(UserPreferences.getIsLogged() && (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
    //   //print('geolocationProvider.position.longitude');
    //   //print(geolocationProvider.position.longitude);
    //   //print('geolocationProvider.position.latitude');
    //   //print(geolocationProvider.position.latitude);
    //   //print('widget.prestazione.business.longitude');
    //   //print(widget.prestazione.business.longitude);
    //   //print('widget.prestazione.business.latitude');
    //   //print(widget.prestazione.business.latitude);
    //   // //print('getDistance');
    //   // //print((getDistance()/1000).toString());
    //   // }
    // });

    // if(UserPreferences.getIsLogged()){
    //   d = getPrestazioneLike();
    // }

    // Future.wait([
    //   // b = getAllPrestazioneBuyers(),
    // ]);

    // //print('widget.prestazione.description');
    // //print(widget.prestazione.description);
  }

  @override
  Widget build(BuildContext context) {
    // cartProvider = Provider.of<CartProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    // favoriteProvider = Provider.of<FavoriteProvider>(context, listen: true);
    // geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 85,
          backgroundColor: Colors.white,
          // title: Text(
          //   widget.prestazione.title,
          //   style: TextStyle(
          //     color: Colors.blue,
          //     fontSize: 21,
          //     fontWeight: FontWeight.w700
          //   ),
          // ),
          // centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              // await favoriteProvider.getUserPrestazioneLiked(userProvider.user);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.grey[500],
              size: 27,
            ),
            color: Colors.black,
          ),
          // centerTitle: true,
          title: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            // onTap: (){
            // Navigator.push(
            //   context,
            //   PageTransition(
            //       duration: const Duration(milliseconds: 500),
            //       alignment: Alignment.center,
            //       type: PageTransitionType.fade,
            //       child: DateBusinessProfile(
            //         user: widget.user,
            //         bookingBusiness: widget.bookingBusiness,
            //       )
            //   ),
            // );
            // Navigator.of(context).pop();
            // },
            child: Padding(
              padding: const EdgeInsets.only(left: 0, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    // tag: 0,
                    tag: widget.prestazione!.image != null && widget.prestazione!.image != ''? widget.prestazione! : widget.prestazione!.business!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // child: FutureImage(
                      //   imageUrl: widget.prestazione!.image != null && widget.prestazione!.image != ''
                      //       ? widget.prestazione!.image! : widget.prestazione!.business!.profile_image!,
                      //   cacheBusiness: CacheBusiness(
                      //     Config(
                      //       'customCacheKey',
                      //       stalePeriod: const Duration(days: 7)
                      //     )
                      //   ),
                      //   fit: BoxFit.cover,
                      //   height: 40,
                      //   width: 40,
                      //   // colorBlendMode: BlendMode.hardLight,
                      //   // width: MediaQuery.of(context).size.width,
                      //   // filterQuality: FilterQuality.high,
                      //   // placeholder: (context, url) => Center(
                      //   //     child: CircularProgressIndicator()
                      //   // ),
                      //   errorWidget: (context, url, error) => SizedBox(),
                      // ),
                      child: FutureImage(
                        widget.prestazione!.image != null && widget.prestazione!.image != ''
                        ? widget.prestazione!.image! : widget.prestazione!.business!.profile_image!,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  // Text(
                  //   widget.bookingBusiness.name,
                  //   style: TextStyle(
                  //       fontWeight:
                  //       FontWeight.w700,
                  //       fontSize: 14,
                  //       color: Colors.grey[600]
                  //   ),
                  // ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 0),
                      physics: const NeverScrollableScrollPhysics(),
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text(
                              //   // widget.bookingBusiness.name,
                              //   widget.prestazione.business.name,
                              //   // widget.prestazione.title,
                              //   style: TextStyle(
                              //     // color: Colors.grey[600],
                              //       color: Colors.green[500],
                              //       // color: Colors.blue[500],
                              //       fontWeight: FontWeight.w700,
                              //       fontSize: 12
                              //   ),
                              // )
                              GradientText(
                                // widget.bookingBusiness.name,
                                widget.prestazione!.business!.name!,
                                gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Color(0xff8921aa),
                                      Color(0xffDA44bb),
                                      // Colors.blue[500]!,
                                      // Colors.blue[500]!,
                                      // Colors.green[500],
                                      // Colors.green[500],
                                    ]
                                ),
                                style: TextStyle(
                                  // color: Colors.grey[600],
                                  // color: Colors.green[500],
                                    color: Colors.blue[500],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14
                                ),
                              )
                            ],
                          ),
                        ),
                        // SizedBox(height: 2.5,),
                        Marquee(
                          child: Row(
                            children: [
                              GradientText(
                                // widget.bookingBusiness.name,
                                widget.prestazione!.title!,
                                gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Color(0xff8921aa),
                                      Color(0xffDA44bb),

                                      // Color(0xffFFA818),
                                      // Color(0xffFFB75E),

                                      // Colors.blue,
                                      // Colors.blue,
                                    ]
                                ),
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: 4,),
                        // Marquee(
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Card(
                        //         semanticContainer: true,
                        //         // color: Colors.grey[100],
                        //         color: Colors.green[100],
                        //         margin: EdgeInsets.all(0),
                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(50.0),
                        //         ),
                        //         elevation: 0,
                        //         // margin: EdgeInsets.all(0),
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //             top: 5,
                        //             bottom: 5,
                        //             left: 6,
                        //             right: 6,
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               Padding(
                        //                 padding: const EdgeInsets.only(bottom: 0.0),
                        //                 child: Icon(
                        //                   Icons.price_change,
                        //                   // Icons.price_change_outlined,
                        //                   // color: Colors.grey[600],
                        //                   color: Colors.green[800],
                        //                   size: 14,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 3),
                        //               RichText(
                        //                 text: TextSpan(
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                         //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                        //                         //   text: prestazione.duration.toString() + ' minuti',
                        //                           text: '€ ' + NumberFormat.currency(
                        //                             // customPattern: '#,##',
                        //                             locale: 'IT_it',
                        //                             decimalDigits: 2,
                        //                             symbol: '',
                        //                             // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                        //                           ).format(widget.prestazione.price?.toDouble()),
                        //                           style: GoogleFonts.roboto(
                        //                               fontWeight: FontWeight.w700,
                        //                               // color: Colors.grey[600],
                        //                               color: Colors.green[800],
                        //                               // color: Colors.blue[500],
                        //                               fontSize: 12
                        //                           )
                        //                       ),
                        //                     ]
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //       SizedBox(width: 10,),
                        //       Card(
                        //         semanticContainer: true,
                        //         color: Colors.grey[100],
                        //         margin: EdgeInsets.all(0),
                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(50.0),
                        //         ),
                        //         elevation: 0,
                        //         // margin: EdgeInsets.all(0),
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //             top: 5,
                        //             bottom: 5,
                        //             left: 8,
                        //             right: 8,
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               Padding(
                        //                 padding: const EdgeInsets.only(bottom: 1.0),
                        //                 child: Icon(
                        //                   Icons.access_time_outlined,
                        //                   // Icons.price_change,
                        //                   // Icons.price_change_outlined,
                        //                   color: Colors.grey[600],
                        //                   size: 14,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 3),
                        //               RichText(
                        //                 text: TextSpan(
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                         //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                        //                           text: widget.prestazione.duration.toString() + ' minuti'/*' "'*/,
                        //                           // text: '€ ' + NumberFormat.currency(
                        //                           //   // customPattern: '#,##',
                        //                           //   locale: 'IT_it',
                        //                           //   decimalDigits: 2,
                        //                           //   symbol: '',
                        //                           // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                        //                           // ).format(prestazione.price?.toDouble()),
                        //                           style: GoogleFonts.roboto(
                        //                               fontWeight: FontWeight.w700,
                        //                               color: Colors.grey[600],
                        //                               // color: Colors.green[600],
                        //                               fontSize: 12
                        //                           )
                        //                       ),
                        //                     ]
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //       // /* UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)
                        //       //     ? SizedBox(width: 10,) : SizedBox(width: 0,),
                        //       /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder<Object>(
                        //           future: e,
                        //           builder: (context, snapshot) {
                        //             if(snapshot.connectionState == ConnectionState.done){
                        //               return Card(
                        //                 semanticContainer: true,
                        //                 color: Colors.grey[100],
                        //                 margin: EdgeInsets.only(left: 10),
                        //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.circular(50.0),
                        //                 ),
                        //                 elevation: 0,
                        //                 // margin: EdgeInsets.all(0),
                        //                 child: Padding(
                        //                   padding: EdgeInsets.only(
                        //                     top: 5,
                        //                     bottom: 5,
                        //                     left: 6,
                        //                     right: 6,
                        //                   ),
                        //                   child: Row(
                        //                     children: [
                        //                       Padding(
                        //                         padding: const EdgeInsets.only(bottom: 0.0),
                        //                         child: Icon(
                        //                           Icons.pin_drop_outlined,
                        //                           // Icons.price_change_outlined,
                        //                           color: Colors.grey[600],
                        //                           size: 15,
                        //                         ),
                        //                       ),
                        //                       SizedBox(width: 3),
                        //                       RichText(
                        //                         text: TextSpan(
                        //                             children: <TextSpan>[
                        //                               TextSpan(
                        //                                 //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                        //                                 //   text: prestazione.duration.toString() + ' minuti',
                        //                                   text: NumberFormat.currency(
                        //                                     // customPattern: '#,##',
                        //                                       decimalDigits: 2,
                        //                                       symbol: '',
                        //                                       locale: 'IT_it'
                        //                                   ).format(Geolocator.distanceBetween(
                        //                                     // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                        //                                     // 45.4281857, 9.1531147, 45.44131, 9.14952
                        //                                     // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                        //                                       geolocationProvider.position.latitude, geolocationProvider.position.longitude,
                        //                                       widget.prestazione.business.latitude, widget.prestazione.business.longitude
                        //                                   )/1000) + 'km',
                        //                                   style: GoogleFonts.roboto(
                        //                                       fontWeight: FontWeight.w700,
                        //                                       color: Colors.grey[600],
                        //                                       // color: Colors.green[600],
                        //                                       // color: Colors.blue[500],
                        //                                       fontSize: 12
                        //                                   )
                        //                               ),
                        //                             ]
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               );
                        //             }
                        //             else return SizedBox();
                        //           }
                        //       ) : SizedBox(),
                        //       SizedBox(width: 10,),
                        //       Card(
                        //         semanticContainer: true,
                        //         color: Colors.grey[100],
                        //         margin: EdgeInsets.all(0),
                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(50.0),
                        //         ),
                        //         elevation: 0,
                        //         // margin: EdgeInsets.all(0),
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //             top: 3,
                        //             bottom: 3,
                        //             left: 5,
                        //             right: 8,
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               ClipRRect(
                        //                 borderRadius: BorderRadius.circular(50),
                        //                 child: Image(
                        //                   image: CachedNetworkImageProvider(
                        //                     // widget.bookingBusiness.profile_image,
                        //                     // widget.prestazione.business.profile_image,
                        //                     widget.prestazione.business.category.image,
                        //                     errorListener: () => SizedBox(),
                        //                     // "https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                        //                   ),
                        //                   width: 20,
                        //                   height: 20,
                        //                   fit: BoxFit.cover,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 5),
                        //               RichText(
                        //                 text: TextSpan(
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                         // text: 'Estetista'/*' "'*/,
                        //                           text: widget.prestazione.business.category.name/*' "'*/,
                        //                           // text: '€ ' + NumberFormat.currency(
                        //                           //   // customPattern: '#,##',
                        //                           //   locale: 'IT_it',
                        //                           //   decimalDigits: 2,
                        //                           //   symbol: '',
                        //                           // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                        //                           // ).format(prestazione.price?.toDouble()),
                        //                           style: GoogleFonts.roboto(
                        //                               fontWeight: FontWeight.w700,
                        //                               color: Colors.grey[600],
                        //                               // color: Colors.green[600],
                        //                               fontSize: 12
                        //                           )
                        //                       ),
                        //                     ]
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // actions: [
          //   FutureBuilder<Object>(
          //     // future: Future.wait([d]),
          //       future: d,
          //       builder: (context, snapshot) {
          //         if(snapshot.connectionState != ConnectionState.done){
          //           return SizedBox();
          //         }
          //         else return InkWell(
          //           highlightColor: Colors.transparent,
          //           splashColor: Colors.transparent,
          //           onTap: () async {
          //             if(UserPreferences.getIsLogged()){
          //               if (isLikedPost){
          //                 // setState(() {
          //                 await /*postProvider.*/unlikePrestazione(
          //                   // postProvider.businessPostList[i].id,
          //                   // widget.user.id
          //                 ).then((value) {
          //                   if(value >= 200 && response.statusCode < 400){
          //                     //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
          //                     favoriteProvider.getUserPrestazioneLiked(userProvider.user);
          //
          //                     Fluttertoast.showToast(
          //                       msg: 'Prestazione rimossa dai Preferiti',
          //                       backgroundColor: Colors.grey[700],
          //                     );
          //                   }
          //                 });
          //                 // });
          //               }
          //               else{
          //                 // setState(() {
          //                 await /*postProvider.*/likePrestazione(
          //                   // postProvider.businessPostList[i].id,
          //                   // widget.user.id
          //                 ).then((value) {
          //                   if(value >= 200 && response.statusCode < 400){
          //                     //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
          //                     favoriteProvider.getUserPrestazioneLiked(userProvider.user);
          //                     Fluttertoast.showToast(
          //                       msg: 'Prestazione aggiunta ai Preferiti',
          //                       backgroundColor: Colors.grey[700],
          //                     );
          //                   }
          //                 });
          //                 // });
          //               }
          //             }
          //             else{
          //               Fluttertoast.showToast(
          //                 msg: 'Accedi per aggiungere ai preferiti',
          //                 backgroundColor: Colors.grey[700],
          //               );
          //             }
          //
          //           },
          //           child: Padding(
          //             padding: const EdgeInsets.only(right: 15, left: 0),
          //             child: Icon(
          //               isLikedPost == true
          //                   ? Icons.favorite
          //                   : Icons.favorite_border_outlined,
          //               // color: Colors.grey[600],
          //               color: Colors.red[600],
          //               // color: Colors.blue[500],
          //               size: 28,
          //             ),
          //           ),
          //         );
          //       }
          //   ),
          // ],
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            children: [
              SizedBox(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                    'Descrizione',
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 8,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        // color: Colors.green[600],
                        // color: Colors.blue[500],
                        fontSize: 14
                    )
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                      // widget.prestazione!.description ?? '',
                      widget.prestazione!.description!.isEmpty ||
                          widget.prestazione!.description != '' ||
                          widget.prestazione!.description != null
                          ? widget.prestazione!.description!
                          : '',
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 8,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          // color: Colors.green[600],
                          // color: Colors.blue[500],
                          fontSize: 18
                      )
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

}
