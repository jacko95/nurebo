import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
// import 'package:maps_launcher/maps_launcher.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/screens/business_room_screen.dart';
import 'package:nurebo/screens/business_detail_screen.dart';
import 'package:nurebo/screens/event_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/maps_launcher/maps_launcher.dart';
import 'package:nurebo/widgets/maps_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get_utils/get_utils.dart';


class EventBusinessProfileScreen extends StatefulWidget {
  final Business? eventBusiness;
  // final User user;

  const EventBusinessProfileScreen({Key? key, this.eventBusiness, /*this.user*/});

  @override
  _EventBusinessProfileScreenState createState() => _EventBusinessProfileScreenState();
}

class _EventBusinessProfileScreenState extends State<EventBusinessProfileScreen> {
  List? timetableDay = [];
  List? bookingBusinessTimetable = [];
  DateTime? timeOfTheDate;
  bool? isSubscribed/* = false*/;
  List/*<DateTime>*/ dates = [];
  List<String?> eventBusinessImages = [];
  late GeolocationProvider geolocationProvider;
  String businessAddress = '';
  double? distanceInMeters;
  bool isDateTableVisible = false;
  Future? a;
  // Future ab;
  late NumberFormat formatter;
  ScrollController? _scrollController;
  Color? _theme ;
  List<Prestazione> bestsellersList = [];
  List? eventList = [];


  Future getBusinessEvents() async {
    // var url = Uri.parse(Utils.httpServerUrl + "event/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.eventBusiness!.id}/event/is_visible");

    Map<String, String> body = {
      'business_id': widget.eventBusiness!.id.toString(),
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
        }
    );

    // //print("response.statusCode85966:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        eventList = jsonData;
      });
      // //print(jsonData);
      return jsonData;

    }
  }

  Future getBestsellers() async {
    var url = Uri.parse(Utils.httpServerUrl + "prestazione/bestsellers");

    var response = await http.get(
        url,
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

    // //print("response.statusCode");
    // //print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      for(var e in /*recommendedPrestazioneList*/jsonData){
        Prestazione bestseller =  Prestazione(
          id: e['prestazione_id'],
          isValid: e['prestazione_is_valid'],
          business: Business(
              id: e['business_id'],
              name: e['business_name'],
              latitude: e['business_latitude'],
              longitude: e['business_longitude'],
              type_id: 1,
              profile_image: e['business_profile_image'],
              description: e['business_description'] ?? '',
              address: e['business_address'],
              phone: e['business_phone'],
              room_id: e['business_room_id'],
              max_contemporary_appointments: e['max_contemporary_appointments'],
              email: e['business_email'],
              // category_id: e['category_id'],
              category: Category(
                id: e['category_id'],
                name: e['category_name'],
                image: e['category_image'],
              )
          ),
          is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                
          image: e['prestazione_image'],
          duration: e['prestazione_duration'],
          title: e['prestazione_title'],
          description: e['prestazione_description'],
          // last_modification_at: DateTime.parse(e['prestazione_last_modification_at']),
          created_at: DateTime.parse(e['prestazione_created_at']),
          // business_id: e['business_id'],
        );
        bestsellersList.add(bestseller);
      }

      // //print('bestsellers.length');
      // //print(bestsellersList.length);
      // setState(() {
      //   // tickets = jsonData;
      //   for(var i = 0; i < jsonData.length; i++){
      //     // tickets.add(jsonData[i]['id']);
      //     tickets.add(jsonData[i]);
      //   }
      // });

      return jsonData;
    }
  }

  Future getDateBusinessTimetable() async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.eventBusiness!.id}/timetable");

    Map<String, dynamic> body = {
      'business_id': widget.eventBusiness!.id,
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
        }
    );

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        bookingBusinessTimetable = jsonData;
      });

      bookingBusinessTimetable!.sort((a, b) {
        if(a['weekday_id'] == b['weekday_id']) {
          if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
            if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
              if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
                return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
              }
              return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
            }
            return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
          }
          return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
        }
        return a['weekday_id'].compareTo(b['weekday_id']);
      });


      // for(var e in bookingBusinessTimetable){
      //   for(var e1 in bookingBusinessTimetable){
      //   //   if(e['weekday_id'] < e1['weekday_id']){
      //   //     DateTime dt = new DateTime(
      //   //       DateTime.now().year,
      //   //       DateTime.now().month,
      //   //       e['weekday_id'],
      //   //       e['open_at_hour'],
      //   //       e['open_at_minute'],
      //   //     );
      //   //     bookings.add(dt);
      //   //     if(e['weekday_id'] == e1['weekday_id']){
      //   //
      //   //     }
      //   //   }
      //   // }
      //   // DateTime dt = new DateTime(
      //   //   // DateTime.now().year,
      //   //   e['weekday_id'],
      //   //   e['open_at_hour'],
      //   //   e['open_at_minute'],
      //   // );
      //   // DateFormat bookingFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      //
      //
      // }
      // // bookings.sort((a, b) {
      // //   if(a.weekday == b.weekday){
      // //     return a.hour.compareTo(b.hour);
      // //   }
      // //   return a.weekday.compareTo(b.weekday);
      // // });
      //
      // for(var i in bookings){
      //   //print(i.toString());
      // }
      // //print(jsonData);
      // //print('bookingBusinessTimetable.toString()');
      // //print(bookingBusinessTimetable.toString());
      return jsonData;
    }
  }

  Future getTimetableDay(int weekday) async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/weekday");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.eventBusiness!.id}/timetable/weekday/${weekday.toString()}");

    Map<String, dynamic> body = {
      'weekday': weekday.toString(),
      'business_id': widget.eventBusiness!.id,
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
        }
    );

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        timetableDay = jsonData;
      });

      // //print(jsonData);
      // //print('timetableDay.toString()');
      // //print(timetableDay.toString());
      return jsonData;
    }
  }

  // Future getBusinessImages() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "business/images");
  //
  //   Map<String, dynamic> body = {
  //     'id': widget.eventBusiness!.id,
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
  //   // //print("response.statusCode:");
  //   // //print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body).cast<Map<String, dynamic>>();
  //     // setState(() {
  //     //   chatMessageList = jsonData;
  //     // });
  //     // //print("jsonData");
  //     // //print(jsonData);
  //
  //     // jsonData.map((json) => Photo.fromJson(json)).toList();
  //
  //     for(var element in jsonData) {
  //       // //print(element['path']);
  //       eventBusinessImages.add(element['path']);
  //     }
  //
  //     return jsonData;
  //   }
  // }

  Future getAddressFromLatLng() async {
    try {
      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //     52.2165157, 6.9437819
      // );
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!
      );

      Placemark place = placemarks[0];

      setState(() {
        businessAddress = "${place.thoroughfare}, ${place.subThoroughfare}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      // //print(e);
    }
  }

  double? getDistance(){
    distanceInMeters = Geolocator.distanceBetween(
      // 52.2165957, 6.9437819, 52.3546274, 4.8285838
      // 45.4281857, 9.1531147, 45.44131, 9.14952
      // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
        geolocationProvider.position!.latitude, geolocationProvider.position!.longitude,
        widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!
    );
    return distanceInMeters;
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset > (MediaQuery.of(context).size.height * .32 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);

    initializeDateFormatting();
    formatter = NumberFormat("00");

    _theme = Colors.white;

    _scrollController = ScrollController()..addListener(
      () => _isAppBarExpanded ? _theme != Colors.grey[500] ?
      setState(() {
        _theme = Colors.grey[500];
        // //print('setState is called');
      },
      ):{}
          : _theme != Colors.white ?
      setState((){
        // //print('setState is called');
        _theme = Colors.white;
      }):{},
    );

    if(/*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
      getDistance();
      // setState(() {
      //
      // });
    }

    a = geolocationProvider.checkGeolocationPermission(context).then((value) {
      if(/*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
        // //print('geolocationProvider.position.longitude');
        // //print(geolocationProvider.position.longitude);
        // //print('geolocationProvider.position.latitude');
        // //print(geolocationProvider.position.latitude);
        // //print('getDistance');
        // //print((getDistance()/1000).toString());
        // setState(() {
        //
        // });
      }

      // //print('value.longitude');
      // //print(value.longitude);
      // //print('value.latitude');
      // //print(value.latitude);
    });

    Future.wait([
      // getBusinessImages(),
      getBusinessEvents(),
      getTimetableDay(DateTime.now().weekday),
      getDateBusinessTimetable(),
      getAddressFromLatLng(),
      // ab = getBestsellers(),
    ]);

    // //print('widget.bookingBusiness.description');
    // //print(widget.eventBusiness.description);

    // //print('widget.bookingBusiness.longitude');
    // //print(widget.eventBusiness.longitude);
    // //print('widget.bookingBusiness.latitude');
    // //print(widget.eventBusiness.latitude);


    // //print('geolocationProvider.locationPermission');
    // //print(geolocationProvider.locationPermission);
  }

  @override
  Widget build(BuildContext context) {
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: Visibility(
      //   visible: isDateTableVisible,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       Card(
      //         clipBehavior: Clip.antiAliasWithSaveLayer,
      //         elevation: 4,
      //         // padding: EdgeInsets.all(10),
      //         // decoration: BoxDecoration(
      //         //     border: Border.all(color: Colors.grey[500])
      //         //     // border: Border.all(color: Colors.blue[500]),
      //         //     // borderRadius: BorderRadius.all(Radius.circular(5))
      //         // ),
      //         // width: MediaQuery.of(context).size.width * .5,
      //         child: Container(
      //           width: MediaQuery.of(context).size.width * .6,
      //           padding: EdgeInsets.all(10),
      //           // color: Colors.red,
      //           // clipBehavior: Clip.antiAliasWithSaveLayer,
      //           child: Column(
      //             children: [
      //               ListView.separated(
      //                   separatorBuilder: (context, i){
      //                     return SizedBox(height: 4,);
      //                   },
      //                   shrinkWrap: true,
      //                   itemCount: bookingBusinessTimetable.length,
      //                   physics: NeverScrollableScrollPhysics(),
      //                   itemBuilder: (context, i){
      //                     if(bookingBusinessTimetable[i]['weekday_id'] == 1){
      //                       return Text(
      //                         'Lunedì ' +
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                         style: TextStyle(
      //                             color: Colors.blue[500],
      //                             fontWeight: FontWeight.w800,
      //                             fontSize: 12
      //                         ),
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 2){
      //                       return Text(
      //                         'Martedì ' +
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 3){
      //                       return Text(
      //                         'Mercoledì ' +
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 4){
      //                       return Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                         children: [
      //                           Text(
      //                             'Giovedì ',
      //                             style: TextStyle(
      //                                 color: Colors.blue[500],
      //                                 fontWeight: FontWeight.w800,
      //                                 fontSize: 13
      //                             ),
      //                           ),
      //                           Text(
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                                 bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                                 + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                                 + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                             style: TextStyle(
      //                                 color: Colors.blue[500],
      //                                 fontWeight: FontWeight.w800,
      //                                 fontSize: 13
      //                             ),
      //                           ),
      //                         ],
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 5){
      //                       return Text(
      //                         'Venerdì ' +
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 6){
      //                       return Text(
      //                         'Sabato ' +
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                       );
      //                     }
      //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 7){
      //                       return Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                         children: [
      //                           Text(
      //                             'Domenica ',
      //                             style: TextStyle(
      //                                 color: Colors.blue[500],
      //                                 fontWeight: FontWeight.w800,
      //                                 fontSize: 13
      //                             ),
      //                           ),
      //                           Text(
      //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
      //                                 bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
      //                                 + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
      //                                 + bookingBusinessTimetable[i]['close_at_minute'].toString(),
      //                             style: TextStyle(
      //                                 color: Colors.blue[500],
      //                                 fontWeight: FontWeight.w800,
      //                                 fontSize: 13
      //                             ),
      //                           ),
      //                         ],
      //                       );
      //                     }
      //                     else return null;
      //                   }
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      /**/

      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(55),
      //   child: Stack(
      //     children: [
      //       AppBar(
      //         elevation: 0,
      //         backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
      //         title: InkWell(
      //           highlightColor: Colors.transparent,
      //           splashColor: Colors.transparent,
      //           onTap: () async {
      //             if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
      //               bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
      //
      //               if (f != null) {
      //                 await map_launcher.MapLauncher.showDirections(
      //                   destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
      //                   // destinationTitle: destinationTitle,
      //                   origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
      //                   originTitle: 'originTitle',
      //                   // waypoints: waypoints,
      //                   directionsMode: map_launcher.DirectionsMode.driving,
      //                   mapType: map_launcher.MapType.google,
      //                 );
      //               }
      //             }
      //             else{
      //               await MapsLauncher.launchQuery(
      //                 // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
      //                 // 'via cascina bianca, 6, milano, 20142, italia'
      //                 // 'Via Privata Parenzo, 8, 20143 Milano MI'
      //                 // 'Via Privata Parenzo, 8, Estetica Elixir'
      //                 // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
      //                 // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
      //                 //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
      //                   widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
      //               );
      //             }
      //           },
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               // ClipRRect(
      //               //   borderRadius:
      //               //   BorderRadius.circular(8),
      //               //   child: Image(
      //               //     image: CachedNetworkImageProvider(
      //               //       widget.bookingBusiness.profile_image,
      //               //       errorListener: () => SizedBox(),
      //               //     ),
      //               //     width: 30,
      //               //     height: 30,
      //               //     fit: BoxFit.cover,
      //               //   ),
      //               // ),
      //               // SizedBox(
      //               //   width: 10,
      //               // ),
      //               SizedBox(
      //                 width: 15,
      //               ),
      //               Expanded(
      //                 child: ListView(
      //                   shrinkWrap: true,
      //                   padding: EdgeInsets.only(bottom: 0),
      //                   // crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Marquee(
      //                       child: Row(
      //                         children: [
      //                           Text(
      //                             widget.bookingBusiness.name,
      //                             style: TextStyle(
      //                                 color: Colors.blue,
      //                                 fontSize: 15,
      //                                 fontWeight: FontWeight.w600
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                     SizedBox(height: 2.5,),
      //                     // Text(
      //                     //   // 'Online',
      //                     //   '47 partecipanti',
      //                     //   style: TextStyle(
      //                     //     // color: Colors.grey[700],
      //                     //       color: Colors.green[500],
      //                     //       fontSize: 12,
      //                     //       fontWeight: FontWeight.w600
      //                     //   ),
      //                     // ),
      //                     Marquee(
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: [
      //                           // Icon(
      //                           //   Icons.location_on_outlined,
      //                           //   color: Colors.grey[600],
      //                           //   size: 15,
      //                           //   // color: Colors.blue[500],
      //                           //
      //                           // ),
      //                           Text(
      //                             widget.bookingBusiness.address,
      //                             style: TextStyle(
      //                                 // color: Colors.grey[600],
      //                                 color: Colors.green[500],
      //                                 // color: Colors.blue[500],
      //                                 fontWeight: FontWeight.w700,
      //                                 fontSize: 12
      //                             ),
      //                           )
      //                         ],
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         centerTitle: false,
      //         leading: IconButton(
      //           onPressed: (){
      //             Navigator.pop(context);
      //           },
      //           icon: Icon(
      //             Icons.arrow_back_outlined,
      //             color: Colors.grey[500],
      //             size: 27,
      //           ),
      //           color: Colors.black,
      //         ),
      //         actions: [
      //           // InkWell(
      //           //   onTap: () async {
      //           //     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
      //           //
      //           //     if (f != null) {
      //           //       await map_launcher.MapLauncher.showDirections(
      //           //         destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
      //           //         // destinationTitle: destinationTitle,
      //           //         origin: map_launcher.Coords(45.4281857, 9.1531147),
      //           //         originTitle: 'originTitle',
      //           //         // waypoints: waypoints,
      //           //         directionsMode: map_launcher.DirectionsMode.driving,
      //           //         mapType: map_launcher.MapType.google,
      //           //       );
      //           //     }
      //           //   },
      //           //   child: Container(
      //           //     margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
      //           //     width: 80,
      //           //     child: Card(
      //           //       color: Colors.blue,
      //           //       child: Padding(
      //           //         padding: const EdgeInsets.all(4.0),
      //           //         child: Row(
      //           //           children: [
      //           //             Icon(
      //           //               Icons.location_on,
      //           //               color: Colors.white,
      //           //               size: 15,
      //           //             ),
      //           //             SizedBox(width: 2,),
      //           //             Text(
      //           //               NumberFormat.currency(
      //           //                 // customPattern: '#,##',
      //           //                   decimalDigits: 2,
      //           //                   symbol: '',
      //           //                   locale: 'IT_it'
      //           //               ).format(Geolocator.distanceBetween(
      //           //                 // 52.2165957, 6.9437819, 52.3546274, 4.8285838
      //           //                 // 45.4281857, 9.1531147, 45.44131, 9.14952
      //           //                 // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
      //           //                   45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
      //           //               )/1000) + 'km',
      //           //               textAlign: TextAlign.center,
      //           //               // (Geolocator.distanceBetween(
      //           //               //   // 52.2165957, 6.9437819, 52.3546274, 4.8285838
      //           //               //   // 45.4281857, 9.1531147, 45.44131, 9.14952
      //           //               //   // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
      //           //               //     45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
      //           //               // )/1000).toString(),
      //           //               style: TextStyle(
      //           //                   color: Colors.white,
      //           //                   fontWeight: FontWeight.w800,
      //           //                   fontSize: 13
      //           //               ),
      //           //             ),
      //           //           ],
      //           //         ),
      //           //       ),
      //           //     ),
      //           //   ),
      //           // ),
      //           InkWell(
      //             highlightColor: Colors.transparent,
      //             splashColor: Colors.transparent,
      //             onTap: (){
      //               // setState(() {
      //               //   // !isDateTableVisible ? isDateTableVisible = true : isDateTableVisible = false;
      //               //   isDateTableVisible = !isDateTableVisible;
      //               // });
      //               if(bookingBusinessTimetable.length > 0)
      //               showDialog(
      //                 barrierLabel: "Label",
      //                 barrierDismissible: true,
      //                 barrierColor: Colors.black.withOpacity(0.5),
      //                 // transitionDuration: Duration(milliseconds: 700),
      //                 context: context,
      //
      //                 // pageBuilder: (context, anim1, anim2) {
      //                 builder: (context) {
      //                   return Align(
      //                     // alignment: Alignment.topCenter,
      //                     alignment: Alignment.topRight,
      //                     // child: Container(
      //                     //   height: 300,
      //                     //   child: SizedBox.expand(child: FlutterLogo()),
      //                     //   margin: EdgeInsets.only(top: 50, left: 12, right: 12),
      //                     //   decoration: BoxDecoration(
      //                     //     color: Colors.white,
      //                     //     borderRadius: BorderRadius.circular(40),
      //                     //   ),
      //                     // ),
      //                     child: Card(
      //                       clipBehavior: Clip.antiAliasWithSaveLayer,
      //                       elevation: 4,
      //                       margin: EdgeInsets.only(top: 58, right: 0),
      //                       // padding: EdgeInsets.all(10),
      //                       // decoration: BoxDecoration(
      //                       //     border: Border.all(color: Colors.grey[500])
      //                       //     // border: Border.all(color: Colors.blue[500]),
      //                       //     // borderRadius: BorderRadius.all(Radius.circular(5))
      //                       // ),
      //                       // width: MediaQuery.of(context).size.width * .5,
      //                       child: Container(
      //                         width: MediaQuery.of(context).size.width * .6,
      //                         height: (bookingBusinessTimetable.length * 20 + (20))?.toDouble(),
      //                         padding: EdgeInsets.only(
      //                             right: 15,
      //                             left: 15
      //                         ),
      //                         // color: Colors.red,
      //                         // clipBehavior: Clip.antiAliasWithSaveLayer,
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: [
      //                             ListView.separated(
      //                                 separatorBuilder: (context, i){
      //                                   return SizedBox(height: 4,);
      //                                 },
      //                                 shrinkWrap: true,
      //                                 itemCount: bookingBusinessTimetable.length,
      //                                 physics: NeverScrollableScrollPhysics(),
      //                                 itemBuilder: (context, i){
      //                                   if(bookingBusinessTimetable[i]['weekday_id'] == 1){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Lunedì ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 2){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Martedì ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 3){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Mercoledì ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 4){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Giovedì ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 5){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Venerdì ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 6){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Sabato ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else if(bookingBusinessTimetable[i]['weekday_id'] == 7){
      //                                     return Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(
      //                                           'Domenica ',
      //                                           style: TextStyle(
      //                                             // color: Colors.blue[500],
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                         Text(
      //                                           formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
      //                                               formatter.format(int.tryParse(bookingBusinessTimetable[i]['open_at_minute']))
      //                                               + ' - '
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
      //                                               + formatter.format(int.tryParse(bookingBusinessTimetable[i]['close_at_minute'])),
      //                                           style: TextStyle(
      //                                               color: Colors.grey[600],
      //                                               fontWeight: FontWeight.w600,
      //                                               fontSize: 13
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     );
      //                                   }
      //                                   else return null;
      //                                 }
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   );
      //                 },
      //                 // transitionBuilder: (context, anim1, anim2, child) {
      //                 //   return SlideTransition(
      //                 //     position: Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(anim1),
      //                 //     child: child,
      //                 //   );
      //                 // },
      //               );
      //             },
      //             child: Padding(
      //               padding: const EdgeInsets.only(right: 15, left: 5),
      //               child: Icon(
      //                 Icons.event,
      //                 color: Colors.grey[500],
      //                 // color: Colors.red[600],
      //                 // color: Colors.blue[500],
      //                 size: 28,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       Visibility(
      //         visible: isDateTableVisible,
      //         child: InkWell(
      //           splashColor: Colors.transparent,
      //           highlightColor: Colors.transparent,
      //           onTap: (){
      //             if(isDateTableVisible){
      //               setState(() {
      //                 isDateTableVisible = !isDateTableVisible;
      //               });
      //             }
      //           },
      //           child: Container(
      //             height: MediaQuery.of(context).size.height,
      //             width: MediaQuery.of(context).size.width,
      //             // decoration: BoxDecoration(
      //             //   borderRadius: BorderRadius.circular(5),
      //             //   backgroundBlendMode: BlendMode.darken,
      //             //   color: Colors.black.withOpacity(0.15),
      //             //   boxShadow: [
      //             //     BoxShadow(
      //             //       color: Colors.grey[400].withOpacity(0.2),
      //             //       spreadRadius: 0.5,
      //             //       blurRadius: 1,
      //             //       offset: Offset(5, 5), // changes position of shadow
      //             //     ),
      //             //   ],
      //             // ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      //   // child: AppBar(
      //   //   elevation: 0,
      //   //   backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
      //   //   title: Padding(
      //   //     padding: const EdgeInsets.only(right: 35.0),
      //   //     child: Row(
      //   //       mainAxisAlignment: MainAxisAlignment.center,
      //   //       children: [
      //   //         ClipRRect(
      //   //           borderRadius:
      //   //           BorderRadius.circular(8),
      //   //           child: Image(
      //   //             image: CachedNetworkImageProvider(
      //   //               'https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      //   //             ),
      //   //             width: 30,
      //   //             height: 30,
      //   //             fit: BoxFit.cover,
      //   //           ),
      //   //         ),
      //   //         SizedBox(
      //   //           width: 10,
      //   //         ),
      //   //         Column(
      //   //           // shrinkWrap: true,
      //   //           // padding: EdgeInsets.only(bottom: 0),
      //   //           crossAxisAlignment: CrossAxisAlignment.start,
      //   //           children: [
      //   //             Text(
      //   //               'Estetista',
      //   //               style: TextStyle(
      //   //                   color: Colors.blue,
      //   //                   fontSize: 15,
      //   //                   fontWeight: FontWeight.w600
      //   //               ),
      //   //             ),
      //   //             SizedBox(height: 1,),
      //   //             // Text(
      //   //             //   // 'Online',
      //   //             //   '47 partecipanti',
      //   //             //   style: TextStyle(
      //   //             //     // color: Colors.grey[700],
      //   //             //       color: Colors.green[500],
      //   //             //       fontSize: 12,
      //   //             //       fontWeight: FontWeight.w600
      //   //             //   ),
      //   //             // ),
      //   //             Row(
      //   //               mainAxisAlignment: MainAxisAlignment.center,
      //   //               children: [
      //   //                 // Icon(
      //   //                 //   Icons.location_on_outlined,
      //   //                 //   color: Colors.grey[600],
      //   //                 //   size: 15,
      //   //                 //   // color: Colors.blue[500],
      //   //                 //
      //   //                 // ),
      //   //                 Text(
      //   //                   'Aperto',
      //   //                   style: TextStyle(
      //   //                       // color: Colors.grey[600],
      //   //                       color: Colors.green[500],
      //   //                       // color: Colors.blue[500],
      //   //                       fontWeight: FontWeight.w700,
      //   //                       fontSize: 12
      //   //                   ),
      //   //                 )
      //   //               ],
      //   //             ),
      //   //           ],
      //   //         ),
      //   //       ],
      //   //     ),
      //   //   ),
      //   //   // centerTitle: false,
      //   //   leading: IconButton(
      //   //     onPressed: (){
      //   //       Navigator.pop(context);
      //   //     },
      //   //     icon: Icon(
      //   //       Icons.arrow_back_outlined,
      //   //       color: Colors.grey[500],
      //   //       size: 27,
      //   //     ),
      //   //     color: Colors.black,
      //   //   ),
      //   //   actions: [
      //   //     // Padding(
      //   //     //   padding: const EdgeInsets.only(right: 15),
      //   //     //   child: Icon(
      //   //     //     Icons.textsms_outlined,
      //   //     //     color: Colors.grey[600],
      //   //     //     // color: Colors.blue[500],
      //   //     //     size: 28,
      //   //     //   ),
      //   //     // )
      //   //   ],
      //   // ),
      //
      //   // child: AppBar(
      //   //   elevation: 0,
      //   //   backgroundColor: Colors.white,
      //   //   // title: Row(
      //   //   //   mainAxisAlignment: MainAxisAlignment.center,
      //   //   //   children: [
      //   //   //     ClipRRect(
      //   //   //       borderRadius:
      //   //   //       BorderRadius.circular(8),
      //   //   //       child: Image(
      //   //   //         image: CachedNetworkImageProvider(
      //   //   //           widget.bookingBusiness.profile_image,
      //   //   //         ),
      //   //   //         width: 30,
      //   //   //         height: 30,
      //   //   //         fit: BoxFit.cover,
      //   //   //       ),
      //   //   //     ),
      //   //   //     SizedBox(
      //   //   //       width: 10,
      //   //   //     ),
      //   //   //     // Text(
      //   //   //     //   widget.bookingBusiness.name,
      //   //   //     //   style: TextStyle(
      //   //   //     //     color: Colors.blue,
      //   //   //     //     fontSize: 19,
      //   //   //     //     fontWeight: FontWeight.w700
      //   //   //     //   ),
      //   //   //     // ),
      //   //   //     Expanded(
      //   //   //       child: ListView(
      //   //   //         shrinkWrap: true,
      //   //   //         padding: EdgeInsets.only(bottom: 0),
      //   //   //         // crossAxisAlignment: CrossAxisAlignment.start,
      //   //   //         children: [
      //   //   //           Marquee(
      //   //   //             child: Row(
      //   //   //               children: [
      //   //   //                 Text(
      //   //   //                   widget.bookingBusiness.name,
      //   //   //                   style: TextStyle(
      //   //   //                       color: Colors.blue,
      //   //   //                       fontSize: 15,
      //   //   //                       fontWeight: FontWeight.w600
      //   //   //                   ),
      //   //   //                 ),
      //   //   //               ],
      //   //   //             ),
      //   //   //           ),
      //   //   //           SizedBox(height: 2.5,),
      //   //   //           // Text(
      //   //   //           //   // 'Online',
      //   //   //           //   '47 partecipanti',
      //   //   //           //   style: TextStyle(
      //   //   //           //     // color: Colors.grey[700],
      //   //   //           //       color: Colors.green[500],
      //   //   //           //       fontSize: 12,
      //   //   //           //       fontWeight: FontWeight.w600
      //   //   //           //   ),
      //   //   //           // ),
      //   //   //           Marquee(
      //   //   //             child: Row(
      //   //   //               mainAxisAlignment: MainAxisAlignment.center,
      //   //   //               children: [
      //   //   //                 // Icon(
      //   //   //                 //   Icons.location_on_outlined,
      //   //   //                 //   color: Colors.grey[600],
      //   //   //                 //   size: 15,
      //   //   //                 //   // color: Colors.blue[500],
      //   //   //                 //
      //   //   //                 // ),
      //   //   //                 Text(
      //   //   //                   widget.bookingBusiness.address,
      //   //   //                   style: TextStyle(
      //   //   //                       // color: Colors.grey[600],
      //   //   //                       color: Colors.green[500],
      //   //   //                       // color: Colors.blue[500],
      //   //   //                       fontWeight: FontWeight.w700,
      //   //   //                       fontSize: 12
      //   //   //                   ),
      //   //   //                 )
      //   //   //               ],
      //   //   //             ),
      //   //   //           ),
      //   //   //         ],
      //   //   //       ),
      //   //   //     ),
      //   //   //   ],
      //   //   // ),
      //   //   // centerTitle: true,
      //   //   leading: IconButton(
      //   //     onPressed: (){
      //   //       Navigator.pop(context);
      //   //     },
      //   //     icon: Icon(
      //   //       Icons.arrow_back_outlined,
      //   //       color: Colors.grey[500],
      //   //       size: 27,
      //   //     ),
      //   //     color: Colors.black,
      //   //   ),
      //   //   actions: [
      //   //     // Padding(
      //   //     //   padding: const EdgeInsets.only(left: 15, right: 12),
      //   //     //   child: Icon(
      //   //     //     // Icons.pin_drop_outlined,
      //   //     //     Icons.location_pin,
      //   //     //     // Icons.location_on_outlined,
      //   //     //     // Icons.location_searching_outlined,
      //   //     //     // Icons.my_location_outlined,
      //   //     //     color: Colors.grey[600],
      //   //     //     // color: Colors.blue[500],
      //   //     //     size: 30,
      //   //     //   ),
      //   //     // ),
      //   //     // Padding(
      //   //     //   padding: const EdgeInsets.only(left: 12, right: 15),
      //   //     //   child: Icon(
      //   //     //     // Icons.pin_drop_outlined,
      //   //     //     // Icons.location_pin,
      //   //     //     // Icons.location_on_outlined,
      //   //     //     // Icons.location_searching_outlined,
      //   //     //     Icons.my_location_outlined,
      //   //     //     color: Colors.grey[600],
      //   //     //     // color: Colors.blue[500],
      //   //     //     size: 30,
      //   //     //   ),
      //   //     // ),
      //   //     // IconButton(
      //   //     //   icon: Icon(
      //   //     //     Icons.textsms_outlined,
      //   //     //     color: Colors.grey[600],
      //   //     //     // color: Colors.blue[500],
      //   //     //     size: 28,
      //   //     //   ),
      //   //     // )
      //   //     SizedBox(width: 5,)
      //   //   ],
      //   // ),
      // ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: CustomScrollView(
          // key: UniqueKey(),
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * .33,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
              title: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  // if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                  //   bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                  //
                  //   if (f != null) {
                  //     await map_launcher.MapLauncher.showDirections(
                  //       destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                  //       // destinationTitle: destinationTitle,
                  //       origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                  //       originTitle: 'originTitle',
                  //       // waypoints: waypoints,
                  //       directionsMode: map_launcher.DirectionsMode.driving,
                  //       mapType: map_launcher.MapType.google,
                  //     );
                  //   }
                  // }
                  // else{
                  //   await MapsLauncher.launchQuery(
                  //     // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                  //     // 'via cascina bianca, 6, milano, 20142, italia'
                  //     // 'Via Privata Parenzo, 8, 20143 Milano MI'
                  //     // 'Via Privata Parenzo, 8, Estetica Elixir'
                  //     // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                  //     // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                  //     //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                  //       widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                  //   );
                  // }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isAppBarExpanded ? ClipRRect(
                      borderRadius:
                      BorderRadius.circular(8),
                      child: FutureImage(
                        widget.eventBusiness!.profile_image!,
                        width: 30,
                        height: 30,
                      ),
                    ) : SizedBox(
                      width: 0,
                    ),
                    SizedBox(
                      width: /*_isAppBarExpanded ? 0 : */10,
                    ),
                    // SizedBox(
                    //   width: 15,
                    // ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 0),
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Marquee(
                            child: Row(
                              children: [
                                Text(
                                  widget.eventBusiness!.name!,
                                  style: TextStyle(
                                      color:  !_isAppBarExpanded ? Colors.white : Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.5,),
                          // Text(
                          //   // 'Online',
                          //   '47 partecipanti',
                          //   style: TextStyle(
                          //     // color: Colors.grey[700],
                          //       color: Colors.green[500],
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.w600
                          //   ),
                          // ),
                          Marquee(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.location_on_outlined,
                                //   color: Colors.grey[600],
                                //   size: 15,
                                //   // color: Colors.blue[500],
                                //
                                // ),
                                Text(
                                  widget.eventBusiness!.address!,
                                  style: TextStyle(
                                    // color: Colors.grey[600],
                                      color: !_isAppBarExpanded ? Colors.white : Colors.green[500],
                                      // color: Colors.blue[500],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(
                  // Icons.star_rounded,
                  // Icons.star_half_rounded,
                  // Icons.star_border_rounded,
                  Icons.arrow_back_outlined,
                  // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                  color: _theme,
                  // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                  size: 27,
                ),
                color: Colors.black,
              ),
              actions: [
                // InkWell(
                //   onTap: () async {
                //     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                //
                //     if (f != null) {
                //       await map_launcher.MapLauncher.showDirections(
                //         destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                //         // destinationTitle: destinationTitle,
                //         origin: map_launcher.Coords(45.4281857, 9.1531147),
                //         originTitle: 'originTitle',
                //         // waypoints: waypoints,
                //         directionsMode: map_launcher.DirectionsMode.driving,
                //         mapType: map_launcher.MapType.google,
                //       );
                //     }
                //   },
                //   child: Container(
                //     margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                //     width: 80,
                //     child: Card(
                //       color: Colors.blue,
                //       child: Padding(
                //         padding: const EdgeInsets.all(4.0),
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.location_on,
                //               color: Colors.white,
                //               size: 15,
                //             ),
                //             SizedBox(width: 2,),
                //             Text(
                //               NumberFormat.currency(
                //                 // customPattern: '#,##',
                //                   decimalDigits: 2,
                //                   symbol: '',
                //                   locale: 'IT_it'
                //               ).format(Geolocator.distanceBetween(
                //                 // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                //                 // 45.4281857, 9.1531147, 45.44131, 9.14952
                //                 // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                //                   45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                //               )/1000) + 'km',
                //               textAlign: TextAlign.center,
                //               // (Geolocator.distanceBetween(
                //               //   // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                //               //   // 45.4281857, 9.1531147, 45.44131, 9.14952
                //               //   // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                //               //     45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                //               // )/1000).toString(),
                //               style: TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.w800,
                //                   fontSize: 13
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                // InkWell(
                //   highlightColor: Colors.transparent,
                //   splashColor: Colors.transparent,
                //   onTap: (){
                //     // setState(() {
                //     //   // !isDateTableVisible ? isDateTableVisible = true : isDateTableVisible = false;
                //     //   isDateTableVisible = !isDateTableVisible;
                //     // });
                //     if(bookingBusinessTimetable!.length > 0)
                //       showDialog(
                //         barrierLabel: "Label",
                //         barrierDismissible: true,
                //         barrierColor: Colors.black.withOpacity(0.5),
                //         // transitionDuration: Duration(milliseconds: 700),
                //         context: context,
                //
                //         // pageBuilder: (context, anim1, anim2) {
                //         builder: (context) {
                //           return Align(
                //             // alignment: Alignment.topCenter,
                //             alignment: Alignment.topRight,
                //             // child: Container(
                //             //   height: 300,
                //             //   child: SizedBox.expand(child: FlutterLogo()),
                //             //   margin: EdgeInsets.only(top: 50, left: 12, right: 12),
                //             //   decoration: BoxDecoration(
                //             //     color: Colors.white,
                //             //     borderRadius: BorderRadius.circular(40),
                //             //   ),
                //             // ),
                //             child: Card(
                //               clipBehavior: Clip.antiAliasWithSaveLayer,
                //               elevation: 4,
                //               margin: EdgeInsets.only(top: 58, right: 0),
                //               // padding: EdgeInsets.all(10),
                //               // decoration: BoxDecoration(
                //               //     border: Border.all(color: Colors.grey[500])
                //               //     // border: Border.all(color: Colors.blue[500]),
                //               //     // borderRadius: BorderRadius.all(Radius.circular(5))
                //               // ),
                //               // width: MediaQuery.of(context).size.width * .5,
                //               child: Container(
                //                 width: MediaQuery.of(context).size.width * .6,
                //                 height: (bookingBusinessTimetable!.length * 20 + (20))?.toDouble(),
                //                 padding: EdgeInsets.only(
                //                     right: 15,
                //                     left: 15
                //                 ),
                //                 // color: Colors.red,
                //                 // clipBehavior: Clip.antiAliasWithSaveLayer,
                //                 child: Column(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     ListView.separated(
                //                         separatorBuilder: (context, i){
                //                           return SizedBox(height: 4,);
                //                         },
                //                         shrinkWrap: true,
                //                         itemCount: bookingBusinessTimetable!.length,
                //                         physics: NeverScrollableScrollPhysics(),
                //                         itemBuilder: (context, i){
                //                           if(bookingBusinessTimetable![i]['weekday_id'] == 1){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Lunedì ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 2){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Martedì ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 3){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Mercoledì ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 4){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Giovedì ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 5){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Venerdì ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 6){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Sabato ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else if(bookingBusinessTimetable![i]['weekday_id'] == 7){
                //                             return Row(
                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                               children: [
                //                                 Text(
                //                                   'Domenica ',
                //                                   style: TextStyle(
                //                                     // color: Colors.blue[500],
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                                 Text(
                //                                   formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':' +
                //                                       formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                //                                       + ' - '
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) + ':'
                //                                       + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                //                                   style: TextStyle(
                //                                       color: Colors.grey[600],
                //                                       fontWeight: FontWeight.w600,
                //                                       fontSize: 13
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           }
                //                           else return null;
                //                         }
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           );
                //         },
                //         // transitionBuilder: (context, anim1, anim2, child) {
                //         //   return SlideTransition(
                //         //     position: Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(anim1),
                //         //     child: child,
                //         //   );
                //         // },
                //       );
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 15, left: 5),
                //     child: Icon(
                //       Icons.event,
                //       // color: Colors.grey[500],
                //       // color: Colors.white,
                //       color: _theme,
                //       // color: Colors.blue,
                //       // color: Colors.red[600],
                //       // color: Colors.blue[500],
                //       size: 28,
                //     ),
                //   ),
                // ),
                InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            child: BusinessRoomScreen(
                              business: widget.eventBusiness,
                            )
                        )
                    );
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    // width: MediaQuery.of(context).size.width * 0.3,
                    // color: Colors.grey[50],
                    padding: EdgeInsets.only(right: 5, left: 10,),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // color: Colors.blue[300],
                      // color: Colors.white,
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Icon(
                          // Icons.chat_bubble_outline,
                          !_isAppBarExpanded ? Icons.chat : Icons.chat_outlined,
                          // Icons.chat_outlined,
                          color: _isAppBarExpanded ? Colors.blue : Colors.white,
                          // color: Colors.blue[400],
                          size: 30,
                        )
                    ),
                  ),
                ),
              ],

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 500,
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    fit: StackFit.expand,
                    children: [
                      FutureImage(
                        widget.eventBusiness!.profile_image != null && widget.eventBusiness!.profile_image != ''
                        ? widget.eventBusiness!.profile_image! : widget.eventBusiness!.profile_image!,
                        width: MediaQuery.of(context).size.width,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                          // backgroundBlendMode: BlendMode.darken,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.black,
                              // Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Positioned(
                      //   bottom: 20,
                      //   left: 20,
                      //   width: MediaQuery.of(context).size.width * 0.8,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Marquee(
                      //         child: GradientText(
                      //           widget.bookingBusiness.name != null
                      //               ? widget.bookingBusiness.name : '',
                      //           // 'A partire da € 60,00',
                      //           maxLines: 1,
                      //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                      //           gradient: LinearGradient(
                      //               begin: Alignment.bottomLeft,
                      //               end: Alignment.topRight,
                      //               colors: [
                      //                 Color(0xffDA44bb),
                      //                 Color(0xffDA44bb),
                      //                 // Color(0xff8921aa),
                      //                 // Colors.white,
                      //                 // Colors.white,
                      //                 // Colors.blue, Colors.blue,
                      //
                      //               ]
                      //           ),
                      //           // gradient: LinearGradient(
                      //           //     begin: Alignment.bottomLeft,
                      //           //     end: Alignment.topRight,
                      //           //     colors: [
                      //           //       Colors.blue[500],
                      //           //       Color(0xffDA44bb),
                      //           //
                      //           //       Color(0xff8921aa),
                      //           //     ]
                      //           // ),
                      //           style: TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.w800,
                      //               fontSize: 30
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       ),
                      //       Marquee(
                      //         child: GradientText(
                      //           widget.bookingBusiness.address != null
                      //               ? widget.bookingBusiness.address : '',
                      //           maxLines: 1,
                      //           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //           gradient: Gradients.haze,
                      //           style: TextStyle(
                      //               color: Colors.white,
                      //               fontWeight: FontWeight.w800,
                      //               fontSize: 15
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       ),
                      //       SizedBox(height: 1,),
                      //     ],
                      //   ),
                      // ),

                      Positioned(
                        bottom: 20,
                        left: 15,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          children: [
                            Card(
                              semanticContainer: true,
                              color: Colors.grey[100],
                              margin: EdgeInsets.all(0),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              elevation: 0,
                              // margin: EdgeInsets.all(0),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 3,
                                  bottom: 3,
                                  left: 5,
                                  right: 8,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: FutureImage(
                                        // widget.bookingBusiness.profile_image,
                                        // widget.prestazione.business.profile_image,
                                        widget.eventBusiness!.category!.image!,
                                        // "https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    RichText(
                                      text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                              // text: 'Estetista'/*' "'*/,
                                                text: widget.eventBusiness!.category!.name,
                                                // text: '€ ' + NumberFormat.currency(
                                                //   // customPattern: '#,##',
                                                //   locale: 'IT_it',
                                                //   decimalDigits: 2,
                                                //   symbol: '',
                                                // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                // ).format(prestazione.price?.toDouble()),
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey[600],
                                                    // color: Colors.green[600],
                                                    fontSize: 12
                                                )
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder<Object>(
                                future: a!.then((value) => value as Object),
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.done){
                                    return Card(
                                      semanticContainer: true,
                                      color: Colors.grey[100],
                                      margin: EdgeInsets.only(left: 10),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      elevation: 0,
                                      // margin: EdgeInsets.all(0),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 7,
                                          right: 7,
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 0.0),
                                              child: Icon(
                                                Icons.pin_drop_outlined,
                                                // Icons.price_change_outlined,
                                                color: Colors.grey[600],
                                                size: 15,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            RichText(
                                              text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                      //   text: prestazione.duration.toString() + ' minuti',
                                                        text: NumberFormat.currency(
                                                          // customPattern: '#,##',
                                                            decimalDigits: 2,
                                                            symbol: '',
                                                            locale: 'IT_it'
                                                          // ).format((distanceInMeters/1000)) + ' km',
                                                        ).format((getDistance()!/1000)) + ' km',
                                                        style: GoogleFonts.roboto(
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.grey[600],
                                                            // color: Colors.green[600],
                                                            // color: Colors.blue[500],
                                                            fontSize: 12
                                                        )
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  else return SizedBox();                                              }
                            ) : SizedBox(),
                          ],
                        ),
                      ),

                      // Positioned(
                      //   bottom: 10,
                      //   right: 10,
                      //   // width: MediaQuery.of(context).size.width * 0.8,
                      //   child: Stack(
                      //     children: [
                      //       Container(
                      //         height: MediaQuery.of(context).size.height * 0.1,
                      //         width: MediaQuery.of(context).size.width * 0.35,
                      //         child: Card(
                      //           elevation: 2,
                      //           clipBehavior: Clip.antiAliasWithSaveLayer,
                      //           child: FutureBuilder<Object>(
                      //               future: a,
                      //               builder: (context, snapshot) {
                      //                 if(snapshot.connectionState == ConnectionState.done){
                      //                   return FlutterMap(
                      //                     options: MapOptions(
                      //                       // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                       // center: LatLng(45.4281857,9.1531147),
                      //                       // center: LatLng(45.44145125443612, 9.140500655351495),
                      //                       // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                      //                       center: /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)
                      //                           ? LatLng((geolocationProvider.position.latitude + widget.bookingBusiness.latitude)/2, (geolocationProvider.position.longitude + widget.bookingBusiness.longitude)/2)
                      //                           : LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                       // zoom: 15.0,
                      //                       zoom: 8.8,
                      //                       // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                      //                       // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                      //                       // zoom: widget.bookingBusiness.longitude,
                      //                       // zoom: distanceInMeters / 1000 * 5,
                      //                       // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                      //                       onTap: (tapPosition, latLng) async {
                      //                         if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                      //                           bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //                           if (f != null) {
                      //                             await map_launcher.MapLauncher.showDirections(
                      //                               destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                               // destinationTitle: destinationTitle,
                      //                               origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //                               originTitle: 'originTitle',
                      //                               // waypoints: waypoints,
                      //                               directionsMode: map_launcher.DirectionsMode.driving,
                      //                               mapType: map_launcher.MapType.google,
                      //                             );
                      //                           }
                      //                         }
                      //                         else{
                      //                           await MapsLauncher.launchQuery(
                      //                             // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //                             // 'via cascina bianca, 6, milano, 20142, italia'
                      //                             // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //                             // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //                             // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //                             // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //                             //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //                               widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //                           );
                      //                         }
                      //
                      //                       },
                      //                     ),
                      //                     layers: [
                      //                       TileLayerOptions(
                      //                         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      //                         subdomains: ['a', 'b', 'c'],
                      //                       ),
                      //                       MarkerLayerOptions(
                      //                         markers: [
                      //                           // Marker(
                      //                           //   width: 60.0,
                      //                           //   height: 60.0,
                      //                           //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                           //   builder: (ctx) => Container(
                      //                           //     // child: FlutterLogo(),
                      //                           //     child: Image.asset("assets/user_location_pin.png"),
                      //                           //   ),
                      //                           // ),
                      //
                      //                           /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                      //                               width: 45.0,
                      //                               height: 45.0,
                      //                               // point: new LatLng(40.73, -74.00),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               // point: LatLng(45.44131,9.14952),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               point: LatLng(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                               builder: (context) => Material(
                      //                                 type: MaterialType.transparency,
                      //                                 child: IconButton(
                      //                                   icon: Icon(Icons.person),
                      //                                   color: Colors.black,
                      //                                   iconSize: 20.0,
                      //
                      //                                   onPressed: () async {
                      //                                     // //print('Marker tapped');
                      //
                      //                                     // MapsSheet.show(
                      //                                     //   context: context,
                      //                                     //   onMapTap: (map) async {
                      //                                     //     await map.showDirections(
                      //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                      //                                     //       // destinationTitle: destinationTitle,
                      //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                      //                                     //       originTitle: 'originTitle',
                      //                                     //       // waypoints: waypoints,
                      //                                     //       directionsMode: mmm.DirectionsMode.driving,
                      //                                     //     );
                      //                                     //   },
                      //                                     // );
                      //
                      //                                     if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                      //                                       bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //                                       if (f != null) {
                      //                                         await map_launcher.MapLauncher.showDirections(
                      //                                           destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                                           // destinationTitle: destinationTitle,
                      //                                           origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //                                           originTitle: 'originTitle',
                      //                                           // waypoints: waypoints,
                      //                                           directionsMode: map_launcher.DirectionsMode.driving,
                      //                                           mapType: map_launcher.MapType.google,
                      //                                         );
                      //                                       }
                      //                                     }
                      //                                     else{
                      //                                       await MapsLauncher.launchQuery(
                      //                                         // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //                                         // 'via cascina bianca, 6, milano, 20142, italia'
                      //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //                                         // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //                                         // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //                                         //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //                                           widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //                                       );
                      //                                     }
                      //                                   },
                      //                                 ),
                      //                               )
                      //                           ) : Marker(),
                      //                           Marker(
                      //                               width: 45.0,
                      //                               height: 45.0,
                      //                               // point: new LatLng(40.73, -74.00),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               // point: LatLng(45.44131,9.14952),
                      //                               // point: LatLng(45.44145125443612, 9.140500655351495),
                      //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                               builder: (context) => Material(
                      //                                 type: MaterialType.transparency,
                      //                                 child: IconButton(
                      //                                   icon: Icon(Icons.location_on),
                      //                                   color: Colors.red,
                      //                                   iconSize: 20.0,
                      //                                   onPressed: () async {
                      //                                     // //print('Marker tapped');
                      //
                      //                                     // MapsSheet.show(
                      //                                     //   context: context,
                      //                                     //   onMapTap: (map) async {
                      //                                     //     await map.showDirections(
                      //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                      //                                     //       // destinationTitle: destinationTitle,
                      //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                      //                                     //       originTitle: 'originTitle',
                      //                                     //       // waypoints: waypoints,
                      //                                     //       directionsMode: mmm.DirectionsMode.driving,
                      //                                     //     );
                      //                                     //   },
                      //                                     // );
                      //
                      //                                     if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                      //                                       bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //                                       if (f != null) {
                      //                                         await map_launcher.MapLauncher.showDirections(
                      //                                           destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                                           // destinationTitle: destinationTitle,
                      //                                           origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //                                           originTitle: 'originTitle',
                      //                                           // waypoints: waypoints,
                      //                                           directionsMode: map_launcher.DirectionsMode.driving,
                      //                                           mapType: map_launcher.MapType.google,
                      //                                         );
                      //                                       }
                      //                                     }
                      //                                     else{
                      //                                       await MapsLauncher.launchQuery(
                      //                                         // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //                                         // 'via cascina bianca, 6, milano, 20142, italia'
                      //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //                                         // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //                                         // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //                                         //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //                                           widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //                                       );
                      //                                     }
                      //                                   },
                      //                                 ),
                      //                               )
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ],
                      //                   );
                      //                 }
                      //                 else{
                      //                   return FlutterMap(
                      //                     options: MapOptions(
                      //                       // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                       // center: LatLng(45.4281857,9.1531147),
                      //                       // center: LatLng(45.44145125443612, 9.140500655351495),
                      //                       // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                      //                       center: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                       // zoom: 15.0,
                      //                       zoom: 8.8,
                      //                       // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                      //                       // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                      //                       // zoom: widget.bookingBusiness.longitude,
                      //                       // zoom: distanceInMeters / 1000 * 5,
                      //                       // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                      //                       onTap: (tapPosition, latLng) async {
                      //                         // //print('ciao');
                      //                         await MapsLauncher.launchQuery(
                      //                           // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //                           // 'via cascina bianca, 6, milano, 20142, italia'
                      //                           // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //                           // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //                           // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //                           // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //                           //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //                             widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //                         );
                      //                       },
                      //                     ),
                      //                     layers: [
                      //                       TileLayerOptions(
                      //                         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      //                         subdomains: ['a', 'b', 'c'],
                      //                       ),
                      //                       MarkerLayerOptions(
                      //                         markers: [
                      //                           // Marker(
                      //                           //   width: 60.0,
                      //                           //   height: 60.0,
                      //                           //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                           //   builder: (ctx) => Container(
                      //                           //     // child: FlutterLogo(),
                      //                           //     child: Image.asset("assets/user_location_pin.png"),
                      //                           //   ),
                      //                           // ),
                      //
                      //                           /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                      //                               width: 45.0,
                      //                               height: 45.0,
                      //                               // point: new LatLng(40.73, -74.00),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               // point: LatLng(45.44131,9.14952),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                               builder: (context) => Material(
                      //                                 type: MaterialType.transparency,
                      //                                 child: IconButton(
                      //                                   icon: Icon(Icons.person),
                      //                                   color: Colors.blue,
                      //                                   iconSize: 20.0,
                      //
                      //                                   onPressed: () async {
                      //                                     // //print('Marker tapped');
                      //
                      //                                     // MapsSheet.show(
                      //                                     //   context: context,
                      //                                     //   onMapTap: (map) async {
                      //                                     //     await map.showDirections(
                      //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                      //                                     //       // destinationTitle: destinationTitle,
                      //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                      //                                     //       originTitle: 'originTitle',
                      //                                     //       // waypoints: waypoints,
                      //                                     //       directionsMode: mmm.DirectionsMode.driving,
                      //                                     //     );
                      //                                     //   },
                      //                                     // );
                      //
                      //                                     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //                                     if (f != null) {
                      //                                       await map_launcher.MapLauncher.showDirections(
                      //                                         destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                                         // destinationTitle: destinationTitle,
                      //                                         origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //                                         originTitle: 'originTitle',
                      //                                         // waypoints: waypoints,
                      //                                         directionsMode: map_launcher.DirectionsMode.driving,
                      //                                         mapType: map_launcher.MapType.google,
                      //                                       );
                      //                                     }
                      //                                   },
                      //                                 ),
                      //                               )
                      //                           ) : Marker(),
                      //                           Marker(
                      //                               width: 45.0,
                      //                               height: 45.0,
                      //                               // point: new LatLng(40.73, -74.00),
                      //                               // point: LatLng(45.4281857,9.1531147),
                      //                               // point: LatLng(45.44131,9.14952),
                      //                               // point: LatLng(45.44145125443612, 9.140500655351495),
                      //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                      //                               builder: (context) => Material(
                      //                                 type: MaterialType.transparency,
                      //                                 child: IconButton(
                      //                                   icon: Icon(Icons.location_on),
                      //                                   color: Colors.red,
                      //                                   iconSize: 20.0,
                      //
                      //                                   onPressed: () async {
                      //                                     // //print('Marker tapped');
                      //
                      //                                     // MapsSheet.show(
                      //                                     //   context: context,
                      //                                     //   onMapTap: (map) async {
                      //                                     //     await map.showDirections(
                      //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                      //                                     //       // destinationTitle: destinationTitle,
                      //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                      //                                     //       originTitle: 'originTitle',
                      //                                     //       // waypoints: waypoints,
                      //                                     //       directionsMode: mmm.DirectionsMode.driving,
                      //                                     //     );
                      //                                     //   },
                      //                                     // );
                      //
                      //                                     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //                                     if (f != null) {
                      //                                       await map_launcher.MapLauncher.showDirections(
                      //                                         destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                      //                                         // destinationTitle: destinationTitle,
                      //                                         origin: map_launcher.Coords(45.4281857, 9.1531147),
                      //                                         originTitle: 'originTitle',
                      //                                         // waypoints: waypoints,
                      //                                         directionsMode: map_launcher.DirectionsMode.driving,
                      //                                         mapType: map_launcher.MapType.google,
                      //                                       );
                      //                                     }
                      //                                   },
                      //                                 ),
                      //                               )
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ],
                      //                   );
                      //                 }
                      //               }
                      //           ),
                      //         ),
                      //       ),
                      //
                      //       // InkWell(
                      //       //   onTap: () async {
                      //       //     await MapsLauncher.launchQuery(
                      //       //       // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //       //       // 'via cascina bianca, 6, milano, 20142, italia'
                      //       //       // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //       //       // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //       //       // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //       //       // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //       //       //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //       //         widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //       //     );
                      //       //   },
                      //       //   child: Container(
                      //       //     height: MediaQuery.of(context).size.height * 0.25,
                      //       //     width: MediaQuery.of(context).size.width * 0.75,
                      //       //     // color: Colors.blue,
                      //       //     color: Colors.transparent,
                      //       //   ),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // background: FutureBuilder<Object>(
                //   future: ab,
                //   builder: (context, snapshot) {
                //     if(snapshot.connectionState == ConnectionState.done) {
                //       return Stack(
                //         children: [
                //           CarouselSlider(
                //             carouselController: CarouselController(),
                //             items: bestsellersList.map((item) {
                //               // //print('item.prestazione.toJson()');
                //               // //print(item.prestazione.toJson());
                //               return Stack(
                //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                //                 fit: StackFit.expand,
                //                 children: [
                //                   FutureImage(
                //                     imageUrl: item.image != null &&
                //                         item.image != ''
                //                         ? item.image : item.business
                //                         .profile_image,
                //                     fit: BoxFit.cover,
                //                     // colorBlendMode: BlendMode.hardLight,
                //                     width: MediaQuery
                //                         .of(context)
                //                         .size
                //                         .width,
                //                     height: MediaQuery
                //                         .of(context)
                //                         .size
                //                         .height * 0.33,
                //                     // filterQuality: FilterQuality.high,
                //                     // placeholder: (context, url) => Center(
                //                     //     child: CircularProgressIndicator()
                //                     // ),
                //                     errorWidget: (context, url, error) =>
                //                         SizedBox(),
                //                   ),
                //                   DecoratedBox(
                //                     decoration: BoxDecoration(
                //                       // backgroundBlendMode: BlendMode.darken,
                //                       gradient: LinearGradient(
                //                         begin: Alignment.bottomLeft,
                //                         end: Alignment.topRight,
                //                         colors: [
                //                           Colors.black,
                //                           // Colors.transparent,
                //                           Colors.transparent,
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               );
                //             }).toList(),
                //             options: CarouselOptions(
                //                 enlargeCenterPage: false,
                //                 height: MediaQuery
                //                     .of(context)
                //                     .size
                //                     .height * 0.38,
                //                 viewportFraction: 1,
                //                 autoPlay: true,
                //                 // aspectRatio: 16/9,
                //                 autoPlayCurve: Curves.easeInOut,
                //                 onPageChanged: (i, bho) {
                //                   // setState(() {
                //                   //   // _current = bho.index;
                //                   //   _eventsPageController.jumpToPage(bho.index);
                //                   // });
                //                 }
                //             ),
                //           ),
                //           Positioned(
                //             bottom: 20,
                //             left: 15,
                //             width: MediaQuery
                //                 .of(context)
                //                 .size
                //                 .width * 0.8,
                //             child: Row(
                //               children: [
                //                 Card(
                //                   semanticContainer: true,
                //                   color: Colors.grey[100],
                //                   margin: EdgeInsets.all(0),
                //                   clipBehavior: Clip.antiAliasWithSaveLayer,
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(50.0),
                //                   ),
                //                   elevation: 0,
                //                   // margin: EdgeInsets.all(0),
                //                   child: Padding(
                //                     padding: EdgeInsets.only(
                //                       top: 3,
                //                       bottom: 3,
                //                       left: 5,
                //                       right: 8,
                //                     ),
                //                     child: Row(
                //                       children: [
                //                         ClipRRect(
                //                           borderRadius: BorderRadius.circular(
                //                               50),
                //                           child: Image(
                //                             image: CachedNetworkImageProvider(
                //                               // widget.bookingBusiness.profile_image,
                //                               // widget.prestazione.business.profile_image,
                //                               widget.bookingBusiness.category
                //                                   .image,
                //                               errorListener: () => SizedBox(),
                //                               // "https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                //                             ),
                //                             width: 20,
                //                             height: 20,
                //                             fit: BoxFit.cover,
                //                           ),
                //                         ),
                //                         SizedBox(width: 5),
                //                         RichText(
                //                           text: TextSpan(
                //                               children: <TextSpan>[
                //                                 TextSpan(
                //                                   // text: 'Estetista'/*' "'*/,
                //                                     text: widget.bookingBusiness
                //                                         .category.name,
                //                                     // text: '€ ' + NumberFormat.currency(
                //                                     //   // customPattern: '#,##',
                //                                     //   locale: 'IT_it',
                //                                     //   decimalDigits: 2,
                //                                     //   symbol: '',
                //                                     // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                //                                     // ).format(prestazione.price?.toDouble()),
                //                                     style: GoogleFonts.roboto(
                //                                         fontWeight: FontWeight
                //                                             .w700,
                //                                         color: Colors.grey[600],
                //                                         // color: Colors.green[600],
                //                                         fontSize: 12
                //                                     )
                //                                 ),
                //                               ]
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //                 /*UserPreferences.getIsLogged() &&*/
                //                 (geolocationProvider.locationPermission ==
                //                     LocationPermission.always ||
                //                     geolocationProvider.locationPermission ==
                //                         LocationPermission.whileInUse)
                //                     ? FutureBuilder<Object>(
                //                     future: a,
                //                     builder: (context, snapshot) {
                //                       if (snapshot.connectionState ==
                //                           ConnectionState.done) {
                //                         return Card(
                //                           semanticContainer: true,
                //                           color: Colors.grey[100],
                //                           margin: EdgeInsets.only(left: 10),
                //                           clipBehavior: Clip
                //                               .antiAliasWithSaveLayer,
                //                           shape: RoundedRectangleBorder(
                //                             borderRadius: BorderRadius.circular(
                //                                 50.0),
                //                           ),
                //                           elevation: 0,
                //                           // margin: EdgeInsets.all(0),
                //                           child: Padding(
                //                             padding: EdgeInsets.only(
                //                               top: 5,
                //                               bottom: 5,
                //                               left: 7,
                //                               right: 7,
                //                             ),
                //                             child: Row(
                //                               children: [
                //                                 Padding(
                //                                   padding: const EdgeInsets
                //                                       .only(bottom: 0.0),
                //                                   child: Icon(
                //                                     Icons.pin_drop_outlined,
                //                                     // Icons.price_change_outlined,
                //                                     color: Colors.grey[600],
                //                                     size: 15,
                //                                   ),
                //                                 ),
                //                                 SizedBox(width: 3),
                //                                 RichText(
                //                                   text: TextSpan(
                //                                       children: <TextSpan>[
                //                                         TextSpan(
                //                                           //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                //                                           //   text: prestazione.duration.toString() + ' minuti',
                //                                             text: NumberFormat
                //                                                 .currency(
                //                                               // customPattern: '#,##',
                //                                                 decimalDigits: 2,
                //                                                 symbol: '',
                //                                                 locale: 'IT_it'
                //                                               // ).format((distanceInMeters/1000)) + ' km',
                //                                             ).format(
                //                                                 (getDistance() /
                //                                                     1000)) +
                //                                                 ' km',
                //                                             style: GoogleFonts
                //                                                 .roboto(
                //                                                 fontWeight: FontWeight
                //                                                     .w700,
                //                                                 color: Colors
                //                                                     .grey[600],
                //                                                 // color: Colors.green[600],
                //                                                 // color: Colors.blue[500],
                //                                                 fontSize: 12
                //                                             )
                //                                         ),
                //                                       ]
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),
                //                         );
                //                       }
                //                       else
                //                         return SizedBox();
                //                     }
                //                 )
                //                     : SizedBox(),
                //               ],
                //             ),
                //           ),
                //         ],
                //       );
                //     }
                //     else return SizedBox();
                //   }
                // ),
              ),
            ),
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 13),
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  // child: NotificationScreen(),
                                  child: BusinessDetailScreen(
                                    business: widget.eventBusiness,
                                  )
                              )
                          );
                        },
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 0, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Container(
                                  //   child: Padding(
                                  //     padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                                  //     child: Container(
                                  //       width: 95,
                                  //       height: 70,
                                  //       child: Card(
                                  //         margin: EdgeInsets.all(0),
                                  //         semanticContainer: true,
                                  //         clipBehavior: Clip.antiAliasWithSaveLayer,
                                  //         child: FutureImage(
                                  //           // singleEvent.image,
                                  //           imageUrl: prestazione.image != null && prestazione.image != '' ? prestazione.image : prestazione.business.profile_image,
                                  //           fit: BoxFit.cover,
                                  //           errorWidget: (context, url, error) => SizedBox(),
                                  //         ),
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(5.0),
                                  //         ),
                                  //         elevation: 5,
                                  //         //margin: EdgeInsets.all(10),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 12, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      //mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // SizedBox(height: 7.5,),
                                        // RichText(
                                        //   maxLines: 2,
                                        //   overflow: TextOverflow.ellipsis,
                                        //   text: TextSpan(
                                        //     // Note: Styles for TextSpans must be explicitly defined.
                                        //     // Child text spans will inherit styles from parent
                                        //       style: TextStyle(
                                        //         fontSize: 15.0,
                                        //         color: Colors.black,
                                        //         // color: Colors.white,
                                        //       ),
                                        //       children: <TextSpan>[
                                        //         TextSpan(
                                        //           // text: singleEvent.title,
                                        //             text: prestazione.title,
                                        //             // text: exhibitions[i].tipo,
                                        //             style: TextStyle(
                                        //                 fontWeight: FontWeight.w700,
                                        //                 fontSize: 14,
                                        //                 // color: Colors.blue[500]
                                        //                 color: Colors.grey[800]
                                        //             )
                                        //         ),
                                        //       ]
                                        //   ),
                                        // ),
                                        SizedBox(height: 10,),
                                        Container(
                                          width: MediaQuery.of(context).size.width * .53,
                                          child: GradientText(
                                              'Visualizza dettagli e orari',
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    // Color(0xff8921aa),
                                                    // Color(0xffDA44bb),
                                                    Colors.blue,
                                                    Colors.blue,
                                                  ]
                                              ),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  // decoration: TextDecoration.underline,
                                                  // height: 1,
                                                  // color: Colors.blue[500]
                                                  color: Colors.grey[800]
                                              )
                                          ),
                                        ),
                                        // SizedBox(height: 4),
                                        // SizedBox(height: 0),
                                        // Padding(
                                        //   padding: EdgeInsets.only(top: 5,),
                                        //   child: Row(
                                        //     children: [
                                        //       // Padding(
                                        //       //   padding: const EdgeInsets.only(bottom: 1.0),
                                        //       //   child: Icon(
                                        //       //     Icons.access_time_outlined,
                                        //       //     color: Colors.grey[500],
                                        //       //     size: 18,
                                        //       //   ),
                                        //       // ),
                                        //       // SizedBox(width: 3),
                                        //       RichText(
                                        //         text: TextSpan(
                                        //             children: <TextSpan>[
                                        //               TextSpan(
                                        //                 //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                        //                   text: prestazione.duration.toString() + ' minuti'/*' "'*/,
                                        //                   // text: '€ ' + NumberFormat.currency(
                                        //                   //   // customPattern: '#,##',
                                        //                   //   locale: 'IT_it',
                                        //                   //   decimalDigits: 2,
                                        //                   //   symbol: '',
                                        //                   // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                        //                   // ).format(prestazione.price?.toDouble()),
                                        //                   style: GoogleFonts.roboto(
                                        //                       fontWeight: FontWeight.w700,
                                        //                       color: Colors.grey[500],
                                        //                       // color: Colors.green[600],
                                        //                       fontSize: 13
                                        //                   )
                                        //               ),
                                        //             ]
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Text(
                                            widget.eventBusiness!.description ?? '\n\n\n\n',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 5,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey[600],
                                              // color: Colors.green[600],
                                              // color: Colors.blue[500],
                                              fontSize: 13
                                            )
                                          ),
                                        ),
                                        // SizedBox(height: 20,),
                                        // SizedBox(height: 15,),
                                        // Row(
                                        //   children: [
                                        //     // Card(
                                        //     //   semanticContainer: true,
                                        //     //   color: Colors.grey[100],
                                        //     //   margin: EdgeInsets.all(0),
                                        //     //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                        //     //   shape: RoundedRectangleBorder(
                                        //     //     borderRadius: BorderRadius.circular(50.0),
                                        //     //   ),
                                        //     //   elevation: 0,
                                        //     //   // margin: EdgeInsets.all(0),
                                        //     //   child: Padding(
                                        //     //     padding: EdgeInsets.only(
                                        //     //       top: 5,
                                        //     //       bottom: 5,
                                        //     //       left: 6,
                                        //     //       right: 6,
                                        //     //     ),
                                        //     //     child: Row(
                                        //     //       children: [
                                        //     //         Padding(
                                        //     //           padding: const EdgeInsets.only(bottom: 0.0),
                                        //     //           child: Icon(
                                        //     //             Icons.pin_drop_outlined,
                                        //     //             // Icons.price_change_outlined,
                                        //     //             color: Colors.grey[600],
                                        //     //             size: 13,
                                        //     //           ),
                                        //     //         ),
                                        //     //         SizedBox(width: 3),
                                        //     //         RichText(
                                        //     //           text: TextSpan(
                                        //     //               children: <TextSpan>[
                                        //     //                 TextSpan(
                                        //     //                   //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                        //     //                   //   text: prestazione.duration.toString() + ' minuti',
                                        //     //                     text: NumberFormat.currency(
                                        //     //                       // customPattern: '#,##',
                                        //     //                         decimalDigits: 2,
                                        //     //                         symbol: '',
                                        //     //                         locale: 'IT_it'
                                        //     //                     ).format(Geolocator.distanceBetween(
                                        //     //                       // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                                        //     //                       // 45.4281857, 9.1531147, 45.44131, 9.14952
                                        //     //                       // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                                        //     //                         45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                                        //     //                     )/1000) + 'km',
                                        //     //                     style: GoogleFonts.roboto(
                                        //     //                         fontWeight: FontWeight.w700,
                                        //     //                         color: Colors.grey[600],
                                        //     //                         // color: Colors.green[600],
                                        //     //                         // color: Colors.blue[500],
                                        //     //                         fontSize: 11
                                        //     //                     )
                                        //     //                 ),
                                        //     //               ]
                                        //     //           ),
                                        //     //         ),
                                        //     //       ],
                                        //     //     ),
                                        //     //   ),
                                        //     // ),
                                        //     // SizedBox(width: 10,),
                                        //     // Card(
                                        //     //   semanticContainer: true,
                                        //     //   color: Colors.grey[100],
                                        //     //   margin: EdgeInsets.all(0),
                                        //     //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                        //     //   shape: RoundedRectangleBorder(
                                        //     //     borderRadius: BorderRadius.circular(50.0),
                                        //     //   ),
                                        //     //   elevation: 0,
                                        //     //   // margin: EdgeInsets.all(0),
                                        //     //   child: Padding(
                                        //     //     padding: EdgeInsets.only(
                                        //     //       top: 5,
                                        //     //       bottom: 5,
                                        //     //       left: 6,
                                        //     //       right: 3,
                                        //     //     ),
                                        //     //     child: Row(
                                        //     //       children: [
                                        //     //         Padding(
                                        //     //           padding: const EdgeInsets.only(bottom: 0.0),
                                        //     //           child: Icon(
                                        //     //             Icons.price_change,
                                        //     //             // Icons.price_change_outlined,
                                        //     //             color: Colors.grey[600],
                                        //     //             size: 13,
                                        //     //           ),
                                        //     //         ),
                                        //     //         SizedBox(width: 3),
                                        //     //         RichText(
                                        //     //           text: TextSpan(
                                        //     //             children: <TextSpan>[
                                        //     //               TextSpan(
                                        //     //                 //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                        //     //                 //   text: prestazione.duration.toString() + ' minuti',
                                        //     //                   text: '€ ' + NumberFormat.currency(
                                        //     //                     // customPattern: '#,##',
                                        //     //                     locale: 'IT_it',
                                        //     //                     decimalDigits: 2,
                                        //     //                     symbol: '',
                                        //     //                     // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                        //     //                   ).format(prestazione.price?.toDouble()),
                                        //     //                   style: GoogleFonts.roboto(
                                        //     //                       fontWeight: FontWeight.w700,
                                        //     //                       color: Colors.grey[600],
                                        //     //                       // color: Colors.green[600],
                                        //     //                       // color: Colors.blue[500],
                                        //     //                       fontSize: 11
                                        //     //                   )
                                        //     //               ),
                                        //     //             ]
                                        //     //           ),
                                        //     //         ),
                                        //     //       ],
                                        //     //     ),
                                        //     //   ),
                                        //     // ),
                                        //     // SizedBox(width: 10,),
                                        //     Card(
                                        //       semanticContainer: true,
                                        //       color: Colors.grey[100],
                                        //       margin: EdgeInsets.all(0),
                                        //       clipBehavior: Clip.antiAliasWithSaveLayer,
                                        //       shape: RoundedRectangleBorder(
                                        //         borderRadius: BorderRadius.circular(50.0),
                                        //       ),
                                        //       elevation: 0,
                                        //       // margin: EdgeInsets.all(0),
                                        //       child: Padding(
                                        //         padding: EdgeInsets.only(
                                        //           top: 5,
                                        //           bottom: 5,
                                        //           left: 8,
                                        //           right: 8,
                                        //         ),
                                        //         child: Row(
                                        //           children: [
                                        //             Padding(
                                        //               padding: const EdgeInsets.only(bottom: 2.0),
                                        //               child: Icon(
                                        //                 Icons.access_time_outlined,
                                        //                 // Icons.price_change,
                                        //                 // Icons.price_change_outlined,
                                        //                 color: Colors.grey[600],
                                        //                 size: 13,
                                        //               ),
                                        //             ),
                                        //             SizedBox(width: 3),
                                        //             RichText(
                                        //               text: TextSpan(
                                        //                   children: <TextSpan>[
                                        //                     TextSpan(
                                        //                       //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                        //                         text: /*prestazione.duration*/(34).toString() + ' minuti'/*' "'*/,
                                        //                         // text: '€ ' + NumberFormat.currency(
                                        //                         //   // customPattern: '#,##',
                                        //                         //   locale: 'IT_it',
                                        //                         //   decimalDigits: 2,
                                        //                         //   symbol: '',
                                        //                         // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                        //                         // ).format(prestazione.price?.toDouble()),
                                        //                         style: GoogleFonts.roboto(
                                        //                             fontWeight: FontWeight.w700,
                                        //                             color: Colors.grey[600],
                                        //                             // color: Colors.green[600],
                                        //                             fontSize: 10
                                        //                         )
                                        //                     ),
                                        //                   ]
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.1,
                                    width: MediaQuery.of(context).size.width * 0.35,
                                    child: Card(
                                      elevation: 2,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: FutureBuilder<Object>(
                                          future: a!.then((value) => value as Object),
                                          builder: (context, snapshot) {
                                            if(snapshot.connectionState == ConnectionState.done){
                                              return FlutterMap(
                                                options: MapOptions(
                                                  // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                  // center: LatLng(45.4281857,9.1531147),
                                                  // center: LatLng(45.44145125443612, 9.140500655351495),
                                                  // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                                                  center: /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)
                                                      ? LatLng((geolocationProvider.position!.latitude + widget.eventBusiness!.latitude!)/2, (geolocationProvider.position!.longitude + widget.eventBusiness!.longitude!)/2)
                                                      : LatLng(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                  // zoom: 15.0,
                                                  zoom: 8.8,
                                                  // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                                                  // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                                                  // zoom: widget.bookingBusiness.longitude,
                                                  // zoom: distanceInMeters / 1000 * 5,
                                                  // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                                                  onTap: (tapPosition, latLng) async {
                                                    if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                                                      bool? f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);

                                                      if (f != null) {
                                                        await map_launcher.MapLauncher.showDirections(
                                                          destination: map_launcher.Coords(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                          // destinationTitle: destinationTitle,
                                                          origin: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                                                          originTitle: 'originTitle',
                                                          // waypoints: waypoints,
                                                          directionsMode: map_launcher.DirectionsMode.driving,
                                                          mapType: map_launcher.MapType.google,
                                                        );
                                                      }
                                                    }
                                                    else{
                                                      await MapsLauncher.launchQuery(
                                                        // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                                                        // 'via cascina bianca, 6, milano, 20142, italia'
                                                        // 'Via Privata Parenzo, 8, 20143 Milano MI'
                                                        // 'Via Privata Parenzo, 8, Estetica Elixir'
                                                        // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                                                        // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                                                        //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                                                          widget.eventBusiness!.address! + ', ' + widget.eventBusiness!.name!
                                                      );
                                                    }

                                                  },
                                                ),
                                                // layers: [
                                                children: [
                                                  // TileLayerOptions(
                                                  TileLayer(
                                                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                    subdomains: ['a', 'b', 'c'],
                                                  ),
                                                  // MarkerLayerOptions(
                                                  MarkerLayer(
                                                    markers: [
                                                      // Marker(
                                                      //   width: 60.0,
                                                      //   height: 60.0,
                                                      //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                      //   builder: (ctx) => Container(
                                                      //     // child: FlutterLogo(),
                                                      //     child: Image.asset("assets/user_location_pin.png"),
                                                      //   ),
                                                      // ),

                                                      /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                                                          width: 45.0,
                                                          height: 45.0,
                                                          // point: new LatLng(40.73, -74.00),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          // point: LatLng(45.44131,9.14952),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          point: LatLng(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                                                          // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                          builder: (context) => Material(
                                                            type: MaterialType.transparency,
                                                            child: IconButton(
                                                              icon: Icon(Icons.person),
                                                              color: Colors.black,
                                                              iconSize: 20.0,

                                                              onPressed: () async {
                                                                // //print('Marker tapped');

                                                                // MapsSheet.show(
                                                                //   context: context,
                                                                //   onMapTap: (map) async {
                                                                //     await map.showDirections(
                                                                //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                                                                //       // destinationTitle: destinationTitle,
                                                                //       origin: mmm.Coords(45.4281857, 9.1531147),
                                                                //       originTitle: 'originTitle',
                                                                //       // waypoints: waypoints,
                                                                //       directionsMode: mmm.DirectionsMode.driving,
                                                                //     );
                                                                //   },
                                                                // );

                                                                if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                                                                  bool? f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);

                                                                  if (f != null) {
                                                                    await map_launcher.MapLauncher.showDirections(
                                                                      destination: map_launcher.Coords(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                                      // destinationTitle: destinationTitle,
                                                                      origin: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                                                                      originTitle: 'originTitle',
                                                                      // waypoints: waypoints,
                                                                      directionsMode: map_launcher.DirectionsMode.driving,
                                                                      mapType: map_launcher.MapType.google,
                                                                    );
                                                                  }
                                                                }
                                                                else{
                                                                  await MapsLauncher.launchQuery(
                                                                    // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                                                                    // 'via cascina bianca, 6, milano, 20142, italia'
                                                                    // 'Via Privata Parenzo, 8, 20143 Milano MI'
                                                                    // 'Via Privata Parenzo, 8, Estetica Elixir'
                                                                    // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                                                                    // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                                                                    //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                                                                      widget.eventBusiness!.address! + ', ' + widget.eventBusiness!.name!
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          )
                                                      ) : Marker(point: LatLng(1, 1), builder: (BuildContext context) { return this.widget; }),
                                                      Marker(
                                                          width: 45.0,
                                                          height: 45.0,
                                                          // point: new LatLng(40.73, -74.00),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          // point: LatLng(45.44131,9.14952),
                                                          // point: LatLng(45.44145125443612, 9.140500655351495),
                                                          point: LatLng(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                          // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                          builder: (context) => Material(
                                                            type: MaterialType.transparency,
                                                            child: IconButton(
                                                              icon: Icon(Icons.location_on),
                                                              color: Colors.red,
                                                              iconSize: 20.0,
                                                              onPressed: () async {
                                                                // //print('Marker tapped');

                                                                // MapsSheet.show(
                                                                //   context: context,
                                                                //   onMapTap: (map) async {
                                                                //     await map.showDirections(
                                                                //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                                                                //       // destinationTitle: destinationTitle,
                                                                //       origin: mmm.Coords(45.4281857, 9.1531147),
                                                                //       originTitle: 'originTitle',
                                                                //       // waypoints: waypoints,
                                                                //       directionsMode: mmm.DirectionsMode.driving,
                                                                //     );
                                                                //   },
                                                                // );

                                                                if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                                                                  bool? f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);

                                                                  if (f != null) {
                                                                    await map_launcher.MapLauncher.showDirections(
                                                                      destination: map_launcher.Coords(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                                      // destinationTitle: destinationTitle,
                                                                      origin: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                                                                      originTitle: 'originTitle',
                                                                      // waypoints: waypoints,
                                                                      directionsMode: map_launcher.DirectionsMode.driving,
                                                                      mapType: map_launcher.MapType.google,
                                                                    );
                                                                  }
                                                                }
                                                                else{
                                                                  await MapsLauncher.launchQuery(
                                                                    // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                                                                    // 'via cascina bianca, 6, milano, 20142, italia'
                                                                    // 'Via Privata Parenzo, 8, 20143 Milano MI'
                                                                    // 'Via Privata Parenzo, 8, Estetica Elixir'
                                                                    // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                                                                    // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                                                                    //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                                                                      widget.eventBusiness!.address! + ', ' + widget.eventBusiness!.name!
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                            else{
                                              return FlutterMap(
                                                options: MapOptions(
                                                  // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                  // center: LatLng(45.4281857,9.1531147),
                                                  // center: LatLng(45.44145125443612, 9.140500655351495),
                                                  // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                                                  center: LatLng(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                  // zoom: 15.0,
                                                  zoom: 8.8,
                                                  // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                                                  // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                                                  // zoom: widget.bookingBusiness.longitude,
                                                  // zoom: distanceInMeters / 1000 * 5,
                                                  // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                                                  onTap: (tapPosition, latLng) async {
                                                    // //print('ciao');
                                                    await MapsLauncher.launchQuery(
                                                      // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                                                      // 'via cascina bianca, 6, milano, 20142, italia'
                                                      // 'Via Privata Parenzo, 8, 20143 Milano MI'
                                                      // 'Via Privata Parenzo, 8, Estetica Elixir'
                                                      // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                                                      // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                                                      //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                                                        widget.eventBusiness!.address! + ', ' + widget.eventBusiness!.name!
                                                    );
                                                  },
                                                ),
                                                // layers: [
                                                children: [
                                                  // TileLayerOptions(
                                                  TileLayer(
                                                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                    subdomains: ['a', 'b', 'c'],
                                                  ),
                                                  // MarkerLayerOptions(
                                                  MarkerLayer(
                                                    markers: [
                                                      // Marker(
                                                      //   width: 60.0,
                                                      //   height: 60.0,
                                                      //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                      //   builder: (ctx) => Container(
                                                      //     // child: FlutterLogo(),
                                                      //     child: Image.asset("assets/user_location_pin.png"),
                                                      //   ),
                                                      // ),

                                                      /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                                                          width: 45.0,
                                                          height: 45.0,
                                                          // point: new LatLng(40.73, -74.00),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          // point: LatLng(45.44131,9.14952),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          point: LatLng(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                          // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                          builder: (context) => Material(
                                                            type: MaterialType.transparency,
                                                            child: IconButton(
                                                              icon: Icon(Icons.person),
                                                              color: Colors.blue,
                                                              iconSize: 20.0,

                                                              onPressed: () async {
                                                                // //print('Marker tapped');

                                                                // MapsSheet.show(
                                                                //   context: context,
                                                                //   onMapTap: (map) async {
                                                                //     await map.showDirections(
                                                                //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                                                                //       // destinationTitle: destinationTitle,
                                                                //       origin: mmm.Coords(45.4281857, 9.1531147),
                                                                //       originTitle: 'originTitle',
                                                                //       // waypoints: waypoints,
                                                                //       directionsMode: mmm.DirectionsMode.driving,
                                                                //     );
                                                                //   },
                                                                // );

                                                                bool? f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);

                                                                if (f != null) {
                                                                  await map_launcher.MapLauncher.showDirections(
                                                                    destination: map_launcher.Coords(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                                    // destinationTitle: destinationTitle,
                                                                    origin: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                                                                    originTitle: 'originTitle',
                                                                    // waypoints: waypoints,
                                                                    directionsMode: map_launcher.DirectionsMode.driving,
                                                                    mapType: map_launcher.MapType.google,
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          )
                                                      ) : Marker(point: LatLng(1, 1), builder: (BuildContext context) { return this.widget; }),
                                                      Marker(
                                                          width: 45.0,
                                                          height: 45.0,
                                                          // point: new LatLng(40.73, -74.00),
                                                          // point: LatLng(45.4281857,9.1531147),
                                                          // point: LatLng(45.44131,9.14952),
                                                          // point: LatLng(45.44145125443612, 9.140500655351495),
                                                          point: LatLng(widget.eventBusiness!.latitude!, widget.eventBusiness!.longitude!),
                                                          // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                          builder: (context) => Material(
                                                            type: MaterialType.transparency,
                                                            child: IconButton(
                                                              icon: Icon(Icons.location_on),
                                                              color: Colors.red,
                                                              iconSize: 20.0,

                                                              onPressed: () async {
                                                                // //print('Marker tapped');

                                                                // MapsSheet.show(
                                                                //   context: context,
                                                                //   onMapTap: (map) async {
                                                                //     await map.showDirections(
                                                                //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                                                                //       // destinationTitle: destinationTitle,
                                                                //       origin: mmm.Coords(45.4281857, 9.1531147),
                                                                //       originTitle: 'originTitle',
                                                                //       // waypoints: waypoints,
                                                                //       directionsMode: mmm.DirectionsMode.driving,
                                                                //     );
                                                                //   },
                                                                // );

                                                                bool? f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);

                                                                if (f != null) {
                                                                  await map_launcher.MapLauncher.showDirections(
                                                                    destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                                                                    // destinationTitle: destinationTitle,
                                                                    origin: map_launcher.Coords(45.4281857, 9.1531147),
                                                                    originTitle: 'originTitle',
                                                                    // waypoints: waypoints,
                                                                    directionsMode: map_launcher.DirectionsMode.driving,
                                                                    mapType: map_launcher.MapType.google,
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                          }
                                      ),
                                    ),
                                  ),

                                  // InkWell(
                                  //   onTap: () async {
                                  //     await MapsLauncher.launchQuery(
                                  //       // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                                  //       // 'via cascina bianca, 6, milano, 20142, italia'
                                  //       // 'Via Privata Parenzo, 8, 20143 Milano MI'
                                  //       // 'Via Privata Parenzo, 8, Estetica Elixir'
                                  //       // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                                  //       // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                                  //       //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                                  //         widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                                  //     );
                                  //   },
                                  //   child: Container(
                                  //     height: MediaQuery.of(context).size.height * 0.25,
                                  //     width: MediaQuery.of(context).size.width * 0.75,
                                  //     // color: Colors.blue,
                                  //     color: Colors.transparent,
                                  //   ),
                                  // ),
                                ],
                              )
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [
                              //     Icon(
                              //       Icons.arrow_forward_ios_rounded,
                              //       size: 25,
                              //       color: Colors.grey[400],
                              //     ),
                              //     SizedBox(width: 15,)
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(indent: 15, endIndent: 15,),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 0),
                        child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 15),
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, i){
                              return const Divider(indent: 15, endIndent: 15,);
                            },
                            // padding: EdgeInsets.symmetric(vertical: 10),
                            itemCount: eventList!.length,
                            itemBuilder: (context, i) {
                              Event event = Event(
                                  id: eventList![i]['id'],
                                  image: eventList![i]['image'],
                                  title: eventList![i]['title'],
                                  description: eventList![i]['description'],
                                  business_id: eventList![i]['business_id'],
                                  // event_cateogory_id: int.parse(singleEventList[i]['event_cateogry_id']),
                                  // performer_name: eventList[i]['performer_name'],
                                  begin_at: DateTime.parse(eventList![i]['begin_at']),
                                  end_at: DateTime.parse(eventList![i]['end_at']),
                                  business: widget.eventBusiness
                              );

                              return InkWell(
                                focusColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,

                                onTap: (){
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: EventScreen(
                                        // eventBusiness: widget.eventBusiness,
                                        event: event,
                                        // user: widget.user,
                                      ),
                                    )
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                                          child: Container(
                                            width: 95,
                                            height: 65,
                                            child: Card(
                                              semanticContainer: true,
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0),
                                              ),
                                              elevation: 5,
                                              child: FutureImage(
                                                event.image!,
                                                width: MediaQuery.of(context).size.width,
                                              ),
                                              //margin: EdgeInsets.all(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        //alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 15, bottom: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            //mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 7.5,),
                                              RichText(
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  // Note: Styles for TextSpans must be explicitly defined.
                                                  // Child text spans will inherit styles from parent
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      // color: Colors.white,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: event.title ?? '',
                                                          // text: exhibitions[i].tipo,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 16,
                                                              color: Colors.blue
                                                          )
                                                      ),
                                                      // TextSpan(text: " ",),
                                                      // TextSpan(
                                                      //   text: exhibitions[i].stage,
                                                      //     style: TextStyle(
                                                      //         fontWeight: FontWeight.w400,
                                                      //         color: Colors.grey[600]
                                                      //     )
                                                      // ),
                                                    ]
                                                ),
                                              ),
                                              // SizedBox(height: 4),
                                              Padding(
                                                padding: EdgeInsets.only(top: 5, right: 15),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.event,
                                                        color: Colors.grey[600],
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 2,),
                                                      Text(
                                                        "${event.begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.day} ${DateFormat.MMMM('it_IT').format(DateTime.parse(event.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString())).toString().toUpperCase()[0]}${DateFormat.MMMM('it_IT').format(DateTime.parse(event.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString())).toString().toLowerCase().substring(1)} ${event.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).year}",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.grey[700],
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 2, right: 15),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      color: Colors.grey[600],
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 2,),
                                                    Text(
                                                      '${formatter.format((event.begin_at!.hour + DateTime.now().timeZoneOffset.inHours)%24)}:${formatter.format(event.begin_at!.minute)} - ${formatter.format((event.end_at!.hour + DateTime.now().timeZoneOffset.inHours)%24)}:${formatter.format(event.end_at!.minute)}',
                                                      style: GoogleFonts.roboto(
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.grey[700],
                                                        fontSize: 12.5,
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5.5),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Expanded(
                                                        child: Text(
                                                          event.description ?? "",
                                                          // "21" + " posti disponibili",
                                                          // exhibitions[i].stage,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          // softWrap: true,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.grey[500],
                                                              fontSize: 12
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.only(right: 15),
                                      //   // mainAxisAlignment: MainAxisAlignment.center,
                                      //   child:
                                      //     Text(
                                      //         "5:35 pm"
                                      //     )
                                      // ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 0, left: 20, ),
                                          child: IconButton(
                                            onPressed: (){

                                            },
                                            // color: Colors.grey,
                                            icon: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey[500],
                                              // color: Colors.grey[600],
                                              size: 23,
                                            ),
                                          )
                                      ),
                                      // Divider(height: 5, thickness: 5,),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isDateTableVisible,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: (){
                        if(isDateTableVisible){
                          setState(() {
                            isDateTableVisible = !isDateTableVisible;
                          });
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(5),
                        //   backgroundBlendMode: BlendMode.darken,
                        //   color: Colors.black.withOpacity(0.15),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: Colors.grey[400].withOpacity(0.2),
                        //       spreadRadius: 0.5,
                        //       blurRadius: 1,
                        //       offset: Offset(5, 5), // changes position of shadow
                        //     ),
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                  // Visibility(
                  //   visible: isDateTableVisible,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Card(
                  //         clipBehavior: Clip.antiAliasWithSaveLayer,
                  //         elevation: 4,
                  //         // padding: EdgeInsets.all(10),
                  //         // decoration: BoxDecoration(
                  //         //     border: Border.all(color: Colors.grey[500])
                  //         //     // border: Border.all(color: Colors.blue[500]),
                  //         //     // borderRadius: BorderRadius.all(Radius.circular(5))
                  //         // ),
                  //         // width: MediaQuery.of(context).size.width * .5,
                  //         child: Container(
                  //           width: MediaQuery.of(context).size.width * .6,
                  //           padding: EdgeInsets.all(10),
                  //           // color: Colors.red,
                  //           // clipBehavior: Clip.antiAliasWithSaveLayer,
                  //           child: Column(
                  //             children: [
                  //               ListView.separated(
                  //                   separatorBuilder: (context, i){
                  //                     return SizedBox(height: 4,);
                  //                   },
                  //                   shrinkWrap: true,
                  //                   itemCount: bookingBusinessTimetable.length,
                  //                   physics: NeverScrollableScrollPhysics(),
                  //                   itemBuilder: (context, i){
                  //                     if(bookingBusinessTimetable[i]['weekday_id'] == 1){
                  //                       return Text(
                  //                         'Lunedì ' +
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                         style: TextStyle(
                  //                             color: Colors.blue[500],
                  //                             fontWeight: FontWeight.w800,
                  //                             fontSize: 12
                  //                         ),
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 2){
                  //                       return Text(
                  //                         'Martedì ' +
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 3){
                  //                       return Text(
                  //                         'Mercoledì ' +
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 4){
                  //                       return Row(
                  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Text(
                  //                             'Giovedì ',
                  //                             style: TextStyle(
                  //                                 color: Colors.blue[500],
                  //                                 fontWeight: FontWeight.w800,
                  //                                 fontSize: 13
                  //                             ),
                  //                           ),
                  //                           Text(
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                                 bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                                 + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                                 + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                             style: TextStyle(
                  //                                 color: Colors.blue[500],
                  //                                 fontWeight: FontWeight.w800,
                  //                                 fontSize: 13
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 5){
                  //                       return Text(
                  //                         'Venerdì ' +
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 6){
                  //                       return Text(
                  //                         'Sabato ' +
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                             bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                             + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                             + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                       );
                  //                     }
                  //                     else if(bookingBusinessTimetable[i]['weekday_id'] == 7){
                  //                       return Row(
                  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Text(
                  //                             'Domenica ',
                  //                             style: TextStyle(
                  //                                 color: Colors.blue[500],
                  //                                 fontWeight: FontWeight.w800,
                  //                                 fontSize: 13
                  //                             ),
                  //                           ),
                  //                           Text(
                  //                             bookingBusinessTimetable[i]['open_at_hour'].toString() + ':' +
                  //                                 bookingBusinessTimetable[i]['open_at_minute'].toString() + ' - '
                  //                                 + bookingBusinessTimetable[i]['close_at_hour'].toString() + ':'
                  //                                 + bookingBusinessTimetable[i]['close_at_minute'].toString(),
                  //                             style: TextStyle(
                  //                                 color: Colors.blue[500],
                  //                                 fontWeight: FontWeight.w800,
                  //                                 fontSize: 13
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       );
                  //                     }
                  //                     else return null;
                  //                   }
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
          ]
        ),
      )
    );
  }

}
