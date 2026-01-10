import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
// import 'package:maps_launcher/maps_launcher.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/business_room_screen.dart';
import 'package:nurebo/screens/business_detail_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/maps_launcher/maps_launcher.dart';
import 'package:nurebo/widgets/maps_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';


class BookingBusinessProfileScreen extends StatefulWidget {
  final Business? business;
  // final User user;

  const BookingBusinessProfileScreen({super.key, this.business, /*this.user*/});

  @override
  _BookingBusinessProfileScreenState createState() => _BookingBusinessProfileScreenState();
}

class _BookingBusinessProfileScreenState extends State<BookingBusinessProfileScreen> /*with SingleTickerProviderStateMixin*/ {
  List? bookingBusinessPrestazioni = [];
  DateTime selectedDate = DateTime.parse(DateTime.now().toString());
  List? timetableDay = [];
  List? bookingBusinessTimetable = [];
  DateTime? timeOfTheDate;
  bool? isSubscribed/* = false*/;
  List/*<DateTime>*/ dates = [];
  List<String?> eventBusinessImages = [];
  late BusinessFavoriteProvider businessFavoriteProvider;
  late UserProvider userProvider;
  late GeolocationProvider geolocationProvider;
  String businessAddress = '';
  double? distanceInMeters;
  bool isDateTableVisible = false;
  Future? a, d;
  // Future ab;
  late NumberFormat formatter;
  ScrollController? _scrollController;
  Color? _theme ;
  List<Prestazione> bestsellersList = [];
  bool isSavedBusiness = false;
  late AnimationController prenotaAnimationController;
  late Animation<Alignment> topAnimationAlignment;
  late Animation<Alignment> bottomAnimationAlignment;


  Future getUserSavedBusiness() async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_business");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/save/business/${widget.business!.id}");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      'business_id': widget.business!.id
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
          isSavedBusiness = true;
        });

      }
      else if(jsonData == 0){
        setState(() {
          isSavedBusiness = false;
        });
      }
      // notifyListeners();
      return jsonData;
    }
    else if(response.statusCode == 401){
      userProvider.logout(context);
    }
  }

  Future saveBusiness(User user, Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/save");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/save/business/${business.id}");

    Map<String, dynamic> body = {
      // "user_id": widget.user.id,
      "user_id": user.id,
      'business_id': business.id
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
      await getUserSavedBusiness();

      return response.statusCode;
    }
    else if(response.statusCode == 401){
      userProvider.logout(context);
    }
  }

  Future unsaveBusiness(User user, Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/unsave");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/save/business/${business.id}");

    Map<String, dynamic> body = {
      "user_id": user.id,
      'business_id': business.id
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
      await getUserSavedBusiness();


      return response.statusCode;
    }
  }

  Future getBestsellers() async {
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/bestsellers");

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
              max_contemporary_appointments: e['max_contemporary_appointments'],
              email: e['business_email'],
              // category_id: e['category_id'],
              category: Category(
                id: e['business_category_id'],
                name: e['category_name'],
                image: e['category_image'],
              )
          ),
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
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/timetable");

    Map<String, dynamic> body = {
      'business_id': widget.business!.id,
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

  Future getDateBusinessPrestazioni() async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/prestazione/is_valid");

    Map<String, String> body = {
      'business_id': widget.business!.id.toString(),
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
        bookingBusinessPrestazioni = jsonData;
      });
      //print('jsonData businesss');
      //print(jsonData);
      return jsonData;

    }
  }

  Future getTimetableDay(int weekday) async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/weekday");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/timetable/weekday/${weekday.toString()}");

    Map<String, dynamic> body = {
      'weekday': weekday.toString(),
      'business_id': widget.business!.id,
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
  //     'id': widget.bookingBusiness!.id,
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
          widget.business!.latitude!, widget.business!.longitude!
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
        widget.business!.latitude!, widget.business!.longitude!
    );
    return distanceInMeters;
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height * .32 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    // prenotaAnimationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 8000),
    //   reverseDuration: Duration(milliseconds: 8000),
    // );
    // topAnimationAlignment = TweenSequence<Alignment>(
    //   [
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //         weight: 1
    //     ),
    //   ]
    // ).animate(prenotaAnimationController);
    // bottomAnimationAlignment = TweenSequence<Alignment>(
    //   [
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
    //         weight: 1
    //     ),
    //     TweenSequenceItem<Alignment>(
    //         tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
    //         weight: 1
    //     ),
    //   ]
    // ).animate(prenotaAnimationController);
    // prenotaAnimationController.repeat();

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

    if(UserPreferences.getIsLogged()!){
      d = getUserSavedBusiness();
    }

    if(/*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
      getDistance();
      // setState(() {
      //
      // });
    }

    a = geolocationProvider.checkGeolocationPermission(context).then((value) async {
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
        await geolocationProvider.putUserLocation(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude, context);
      }

      // //print('value.longitude');
      // //print(value.longitude);
      // //print('value.latitude');
      // //print(value.latitude);
    });

    Future.wait([
      // getBusinessImages(),
      getDateBusinessPrestazioni(),
      getTimetableDay(selectedDate.weekday),
      getDateBusinessTimetable(),
      getAddressFromLatLng(),
      // ab = getBestsellers(),
    ]);

    // //print('widget.bookingBusiness.description');
    // //print(widget.bookingBusiness.description);

    // //print('widget.bookingBusiness.longitude');
    // //print(widget.bookingBusiness.longitude);
    // //print('widget.bookingBusiness.latitude');
    // //print(widget.bookingBusiness.latitude);


    // //print('geolocationProvider.locationPermission');
    // //print(geolocationProvider.locationPermission);
  }

  @override
  Widget build(BuildContext context) {
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

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

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: AnimatedBuilder(
      //   animation: prenotaAnimationController,
      //   builder: (context, _) {
      //     return Container(
      //       margin: EdgeInsets.only(bottom: 10),
      //       width: MediaQuery.of(context).size.width * 0.9,
      //       height: 50,
      //       padding: EdgeInsets.all(0),
      //       decoration: BoxDecoration(
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.grey[700]!,
      //             offset: Offset(0.0, 1.0), //(x,y)
      //             blurRadius: 10.0,
      //           ),
      //         ],
      //         gradient: LinearGradient(
      //             colors: [
      //               // Colors.orange,
      //               // Colors.orange.shade300,
      //               // Color(0xff8921aa),
      //               // Color(0xffDA44bb),
      //               // Color(0xff002d82),
      //               Color(0xff3e77b6),
      //               // Color(0xff6c85db),
      //               Color(0xff6c85bd),
      //               // Colors.blueGrey,
      //               // Colors.blueGrey,
      //             ],
      //             begin: Alignment.topLeft,
      //             // begin: topAnimationAlignment.value,
      //             end: Alignment.bottomRight
      //             // end: bottomAnimationAlignment.value,
      //         ),
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //       child: ElevatedButton(
      //         // style: ButtonStyle(
      //         // backgroundColor: MaterialStateProperty.all(Colors.blue[500])
      //         // backgroundColor: MaterialStateProperty.all(Colors.)
      //         // ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.transparent,
      //           shadowColor: Colors.transparent,
      //           // elevation: 20
      //         ),
      //         child: Text(
      //           // 'Paga',
      //           'Prenota',
      //           style: TextStyle(
      //               fontSize: 16,
      //               fontWeight: FontWeight.w700
      //           ),
      //         ),
      //         onPressed: () async {
      //           if(UserPreferences.getIsLogged()!){
      //             // if(cartProvider.items.isNotEmpty) {
      //             //   Navigator.push(
      //             //       context,
      //             //       PageTransition(
      //             //           duration: const Duration(
      //             //               milliseconds: 500
      //             //           ),
      //             //           alignment: Alignment.center,
      //             //           type: PageTransitionType.fade,
      //             //           child: PurchasingScreen()
      //             //       )
      //             //   );
      //             // }
      //             // else{
      //             //   Fluttertoast.showToast(
      //             //     msg: "Il carrello è vuoto!",
      //             //     backgroundColor: Colors.grey[700],
      //             //   );
      //             // }
      //           }
      //           else{
      //             // Navigator.push(
      //             //     context,
      //             //     PageTransition(
      //             //       duration: const Duration(milliseconds: 500),
      //             //       alignment: Alignment.center,
      //             //       type: PageTransitionType.fade,
      //             //       child: LoginScreen(),
      //             //     )
      //             // );
      //             Fluttertoast.showToast(
      //               // msg: 'Bisogna essere loggati per prenotare',
      //               msg: 'Accedi per prenotare',
      //               backgroundColor: Colors.grey[700],
      //             )/*.then((value) => */;
      //           }
      //           // await buy();
      //         },
      //       ),
      //     );
      //   },
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
                      borderRadius: BorderRadius.circular(8),
                      child: FutureImage(
                        widget.business!.profile_image!,
                        width: 35,
                        height: 35,
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
                                // Text(
                                //   widget.bookingBusiness.name ?? '',
                                //   style: TextStyle(
                                //       color:  !_isAppBarExpanded ? Colors.white : Colors.blue,
                                //       fontSize: 15,
                                //       fontWeight: FontWeight.w600
                                //   ),
                                // ),
                                Text(
                                  widget.business!.name ?? '',
                                  style: TextStyle(
                                      color: !_isAppBarExpanded ? Colors.white : Colors.green[600],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                )
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
                                  widget.business!.address ?? '',
                                  style: TextStyle(
                                      color: !_isAppBarExpanded ? Colors.white : Colors.grey[500],
                                      // color: !_isAppBarExpanded ? Colors.white : Colors.grey[800],
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
              leading: /*!Utils.isBusiness ?*/ IconButton(
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
              ) /*: SizedBox()*/,
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

                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: (){
                    // setState(() {
                    //   // !isDateTableVisible ? isDateTableVisible = true : isDateTableVisible = false;
                    //   isDateTableVisible = !isDateTableVisible;
                    // });
                    if(bookingBusinessTimetable!.length > 0)
                      showDialog(
                        barrierLabel: "Label",
                        barrierDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.5),
                        // transitionDuration: Duration(milliseconds: 700),
                        context: context,

                        // pageBuilder: (context, anim1, anim2) {
                        builder: (context) {
                          return Align(
                            // alignment: Alignment.topCenter,
                            alignment: Alignment.topRight,
                            // child: Container(
                            //   height: 300,
                            //   child: SizedBox.expand(child: FlutterLogo()),
                            //   margin: EdgeInsets.only(top: 50, left: 12, right: 12),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(40),
                            //   ),
                            // ),
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 4,
                              margin: EdgeInsets.only(top: 58, right: 0),
                              // padding: EdgeInsets.all(10),
                              // decoration: BoxDecoration(
                              //     border: Border.all(color: Colors.grey[500])
                              //     // border: Border.all(color: Colors.blue[500]),
                              //     // borderRadius: BorderRadius.all(Radius.circular(5))
                              // ),
                              // width: MediaQuery.of(context).size.width * .5,
                              child: Container(
                                width: MediaQuery.of(context).size.width * .6,
                                height: (bookingBusinessTimetable!.length * 20 + (20))?.toDouble(),
                                padding: EdgeInsets.only(
                                    right: 15,
                                    left: 15
                                ),
                                // color: Colors.red,
                                // clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListView.separated(
                                        separatorBuilder: (context, i){
                                          return SizedBox(height: 4,);
                                        },
                                        shrinkWrap: true,
                                        itemCount: bookingBusinessTimetable!.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i){
                                          if(bookingBusinessTimetable![i]['weekday_id'] == 1){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Lunedì ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 2){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Martedì ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 3){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Mercoledì ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 4){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Giovedì ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 5){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Venerdì ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 6){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Sabato ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else if(bookingBusinessTimetable![i]['weekday_id'] == 7){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Domenica ',
                                                  style: TextStyle(
                                                    // color: Colors.blue[500],
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Text(
                                                  formatter.format((int.tryParse(bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                                      formatter.format(int.tryParse(bookingBusinessTimetable![i]['open_at_minute']))
                                                      + ' - '
                                                      + formatter.format((int.tryParse(bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                                      + formatter.format(int.tryParse(bookingBusinessTimetable![i]['close_at_minute'])),
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          else return null;
                                        }
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        // transitionBuilder: (context, anim1, anim2, child) {
                        //   return SlideTransition(
                        //     position: Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(anim1),
                        //     child: child,
                        //   );
                        // },
                      );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, left: 5),
                    child: Icon(
                      Icons.event,
                      // color: Colors.grey[500],
                      // color: Colors.white,
                      color: _theme,
                      // color: Colors.blue,
                      // color: Colors.red[600],
                      // color: Colors.blue[500],
                      size: 28,
                    ),
                  ),
                ),

                // /*!Utils.isBusiness ?*/ InkWell(
                //
                //   onTap: (){
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //         duration: const Duration(milliseconds: 500),
                //         alignment: Alignment.center,
                //         type: PageTransitionType.fade,
                //         child: BusinessRoomScreen(
                //           business: widget.business,
                //         )
                //       )
                //     );
                //   },
                //   highlightColor: Colors.transparent,
                //   splashColor: Colors.transparent,
                //   child: Container(
                //     // width: MediaQuery.of(context).size.width * 0.3,
                //     // color: Colors.grey[50],
                //     padding: EdgeInsets.only(right: 5, left: 10,),
                //     margin: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       // color: Colors.blue[300],
                //       // color: Colors.white,
                //       color: Colors.transparent,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Center(
                //         child: Icon(
                //           // Icons.chat_bubble_outline,
                //           !_isAppBarExpanded ? Icons.chat : Icons.chat_outlined,
                //           // Icons.chat_outlined,
                //           color: _isAppBarExpanded ? Colors.blue : Colors.white,
                //           // color: Colors.blue[400],
                //           size: 30,
                //         )
                //     ),
                //   ),
                // ) /*: SizedBox()*/,
              ],

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 500,
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    fit: StackFit.expand,
                    children: [
                      // FutureImage(
                      //   imageUrl: widget.bookingBusiness!.profile_image != null && widget.bookingBusiness!.profile_image != ''
                      //       ? widget.bookingBusiness!.profile_image! : widget.bookingBusiness!.profile_image!,
                      //   cacheBusiness: CacheBusiness(
                      //     Config(
                      //       'customCacheKey',
                      //       stalePeriod: const Duration(days: 7)
                      //     )
                      //   ),
                      //   fit: BoxFit.cover,
                      //   // colorBlendMode: BlendMode.darken,
                      //   // colorBlendMode: BlendMode.hardLight,
                      //   width: MediaQuery.of(context).size.width,
                      //   // filterQuality: FilterQuality.high,
                      //   // placeholder: (context, url) => Center(
                      //   //     child: CircularProgressIndicator()
                      //   // ),
                      //   errorWidget: (context, url, error) => SizedBox(),
                      // ),
                      FutureImage(
                        widget.business!.profile_image != null && widget.business!.profile_image != ''
                        ? widget.business!.profile_image! : widget.business!.profile_image!,
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
                                        widget.business!.category!.image!,
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
                                                text: widget.business!.category!.name,
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
                                  else return SizedBox();
                                }
                            ) : SizedBox(),
                          ],
                        ),
                      ),

                      Visibility(
                        // visible: !Utils.isBusiness,
                        visible: false,
                        child: Positioned(
                          bottom: 20,
                          right: 15,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: (){
                                  // LaunchReview.launch(
                                  //   androidAppId: "com.nurebo.nurebo",
                                  //   // iOSAppId: "585027354",
                                  //   writeReview: false,
                                  // );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15, left: 5),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                    ),
                                    child: Icon(
                                      Icons.download,
                                      color: Colors.grey[700],
                                      // color: Colors.green[700],
                                      // color: Colors.white,
                                      // color: _theme,
                                      // color: Colors.blue,
                                      // color: Colors.red[600],
                                      // color: Colors.blue[500],
                                      size: 23,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * .8,
                                  // width: MediaQuery.of(context).size.width * .4,
                                  height: 40,
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                        // backgroundColor: MaterialStateProperty.all(Colors.white)
                                        backgroundColor: MaterialStateProperty.all(Colors.blue[400])
                                      // elevation:,
                                    ),
                                    // OutlineButton(
                                    // shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.all(Radius.circular(4))
                                    // ),
                                    onPressed: () async {
                                      // if(status == -1) {
                                      //   await sendFriendshipRequest();
                                      // }
                                    },
                                    child: Text(
                                      'Segui',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          // color: Colors.grey[800]
                                          color: Colors.grey[50]
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
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
                                    business: widget.business,
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
                                              // 'Visualizza dettagli e orari',
                                              'Visualizza dettagli',
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    // Color(0xff8921aa),
                                                    // Color(0xffDA44bb),
                                                    // Colors.blue,
                                                    // Colors.blue,
                                                    Colors.blueGrey[600]!,
                                                    Colors.blueGrey[600]!,
                                                    // Colors.blueGrey,
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
                                            widget.business!.description ?? '\n\n\n\n',
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
                                      child: FutureBuilder(
                                          // future: a!.then((value) => value as Object),
                                          future: a,
                                          builder: (context, snapshot) {
                                            if(snapshot.connectionState == ConnectionState.done){
                                              return FlutterMap(
                                                options: MapOptions(
                                                  // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                                                  // center: LatLng(45.4281857,9.1531147),
                                                  // center: LatLng(45.44145125443612, 9.140500655351495),
                                                  // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                                                  center: /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)
                                                      ? LatLng((geolocationProvider.position!.latitude + widget.business!.latitude!)/2, (geolocationProvider.position!.longitude + widget.business!.longitude!)/2)
                                                      : LatLng(widget.business!.latitude!, widget.business!.longitude!),
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
                                                          destination: map_launcher.Coords(widget.business!.latitude!, widget.business!.longitude!),
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
                                                          widget.business!.address! + ', ' + widget.business!.name!
                                                      );
                                                    }

                                                  },
                                                ),
                                                children: [
                                                // layers: [
                                                  TileLayer(
                                                  // TileLayerOptions(
                                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                      tileProvider: NetworkTileProvider(),
                                                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                                                    ),
                                                    // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                    // tileProvider: NetworkTileProvider(),
                                                    // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                                                  //todo: da risolvere per la versione 3.0.0 di fluttermap package
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
                                                                      destination: map_launcher.Coords(widget.business!.latitude!, widget.business!.longitude!),
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
                                                                      widget.business!.address! + ', ' + widget.business!.name!
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
                                                          point: LatLng(widget.business!.latitude!, widget.business!.longitude!),
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
                                                                      destination: map_launcher.Coords(widget.business!.latitude!, widget.business!.longitude!),
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
                                                                      widget.business!.address! + ', ' + widget.business!.name!
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
                                                  center: LatLng(widget.business!.latitude!, widget.business!.longitude!),
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
                                                        widget.business!.address! + ', ' + widget.business!.name!
                                                    );
                                                  },
                                                ),
                                                // layers: [
                                                children: [
                                                  TileLayer(
                                                  // TileLayerOptions(
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
                                                          point: LatLng(widget.business!.latitude!, widget.business!.longitude!),
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
                                                                    destination: map_launcher.Coords(widget.business!.latitude!, widget.business!.longitude!),
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
                                                          point: LatLng(widget.business!.latitude!, widget.business!.longitude!),
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

                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FutureBuilder<Object?>(
                              future: d,
                              builder: (context, snapshot) {
                                if(snapshot.connectionState != ConnectionState.done){
                                  return Container(
                                    width: /*Utils.isEventsEnabled
                                                    ?*/ MediaQuery.of(context).size.width * .4,
                                    // : MediaQuery.of(context).size.width * .8,
                                    height: 40,
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(isSavedBusiness ? Colors.blue : Colors.white),
                                        // elevation:,
                                      ),
                                      // OutlineButton(
                                      // shape: RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.all(Radius.circular(4))
                                      // ),
                                      onPressed: () async {
                                        // Route route = MaterialPageRoute(builder: (context) => Activities());
                                        // Navigator.push(context, route);
                                        // Navigator.push(
                                        //     context,
                                        //     PageTransition(
                                        //         duration: const Duration(milliseconds: 500),
                                        //         alignment: Alignment.center,
                                        //         type: PageTransitionType.fade,
                                        //         child: UserBookingsScreen()
                                        //     )
                                        // );
                                        if(UserPreferences.getIsLogged()!){
                                          if (isSavedBusiness){
                                            // setState(() {
                                            await /*businessFavoriteProvider.*/unsaveBusiness(
                                              // postProvider.businessPostList[i].id,
                                              // widget.user.id
                                                userProvider.user!,
                                                widget.business!
                                            ).then((value) {
                                              if(value >= 200 && value < 400){
                                                //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
                                                businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);

                                                // Fluttertoast.showToast(
                                                //   msg: 'Rimosso dai Salvati',
                                                //   backgroundColor: Colors.grey[700],
                                                // );
                                                final SnackBar snackBar = SnackBar(
                                                  content: Text(
                                                    'Rimosso dai Seguiti',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                snackbarKey.currentState?.showSnackBar(snackBar);
                                              }
                                            });
                                            // });
                                          }
                                          else{
                                            // setState(() {
                                            await /*businessFavoriteProvider.*/saveBusiness(
                                                userProvider.user!,
                                                widget.business!
                                            ).then((value) {
                                              if(value >= 200 && value < 400){
                                                //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
                                                businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);
                                                // Fluttertoast.showToast(
                                                //   msg: 'Aggiunto ai Salvati',
                                                //   backgroundColor: Colors.grey[700],
                                                // );
                                                final SnackBar snackBar = SnackBar(
                                                  content: Text(
                                                    'Aggiunto ai Seguiti',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.green,
                                                );
                                                snackbarKey.currentState?.showSnackBar(snackBar);
                                              }
                                            });
                                            // });
                                          }
                                        }
                                        else{
                                          Fluttertoast.showToast(
                                            msg: 'Accedi per aggiungere ai Seguiti',
                                            backgroundColor: Colors.grey[700],
                                          );
                                        }
                                      },
                                      child: Text(
                                        isSavedBusiness ? 'Seguito' : 'Segui',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            // color: Colors.grey[800]
                                            color: isSavedBusiness ? Colors.white : Colors.blue
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                else {
                                  return Container(
                                    width: /*Utils.isEventsEnabled
                                                    ?*/ MediaQuery.of(context).size.width * .4,
                                    // : MediaQuery.of(context).size.width * .8,
                                    height: 40,
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(isSavedBusiness ? Colors.blue : Colors.white),
                                        // elevation:,
                                      ),
                                      // OutlineButton(
                                      // shape: RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.all(Radius.circular(4))
                                      // ),
                                      onPressed: () async {
                                        // Route route = MaterialPageRoute(builder: (context) => Activities());
                                        // Navigator.push(context, route);
                                        // Navigator.push(
                                        //     context,
                                        //     PageTransition(
                                        //         duration: const Duration(milliseconds: 500),
                                        //         alignment: Alignment.center,
                                        //         type: PageTransitionType.fade,
                                        //         child: UserBookingsScreen()
                                        //     )
                                        // );
                                        if(UserPreferences.getIsLogged()!){
                                          if (isSavedBusiness){
                                            // setState(() {
                                            await /*businessFavoriteProvider.*/unsaveBusiness(
                                            // postProvider.businessPostList[i].id,
                                            // widget.user.id
                                            userProvider.user!,
                                            widget.business!
                                            ).then((value) {
                                              if(value >= 200 && value < 400){
                                                //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
                                                businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);

                                                // Fluttertoast.showToast(
                                                //   msg: 'Rimosso dai Salvati',
                                                //   backgroundColor: Colors.grey[700],
                                                // );
                                                final SnackBar snackBar = SnackBar(
                                                  content: Text(
                                                    'Rimosso dai Seguiti',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                snackbarKey.currentState?.showSnackBar(snackBar);
                                              }
                                            });
                                            // });
                                          }
                                          else{
                                            // setState(() {
                                            await /*businessFavoriteProvider.*/saveBusiness(
                                            userProvider.user!,
                                            widget.business!
                                            ).then((value) {
                                              if(value >= 200 && value < 400){
                                                //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
                                                businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);
                                                // Fluttertoast.showToast(
                                                //   msg: 'Aggiunto ai Salvati',
                                                //   backgroundColor: Colors.grey[700],
                                                // );
                                                final SnackBar snackBar = SnackBar(
                                                  content: Text(
                                                    'Aggiunto ai Seguiti',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.green,
                                                );
                                                snackbarKey.currentState?.showSnackBar(snackBar);
                                              }
                                            });
                                            // });
                                          }
                                        }
                                        else{
                                          Fluttertoast.showToast(
                                            msg: 'Accedi per aggiungere ai Seguiti',
                                            backgroundColor: Colors.grey[700],
                                          );
                                        }
                                      },
                                      child: Text(
                                        isSavedBusiness ? 'Seguito' : 'Segui',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            // color: Colors.grey[800]
                                            color: isSavedBusiness ? Colors.white : Colors.blue
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                          ),
                          Container(
                            width: /*Utils.isEventsEnabled
                                                  ?*/ MediaQuery.of(context).size.width * .4,
                            // : MediaQuery.of(context).size.width * .8,
                            height: 40,
                            child: OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.blue),
                                // elevation:,
                              ),
                              // OutlineButton(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.all(Radius.circular(4))
                              // ),
                              onPressed: (){
                                // Route route = MaterialPageRoute(builder: (context) => Activities());
                                // Navigator.push(context, route);
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        duration: const Duration(milliseconds: 500),
                                        alignment: Alignment.center,
                                        type: PageTransitionType.fade,
                                        child: BusinessRoomScreen(
                                          business: widget.business,
                                        )
                                    )
                                );
                              },
                              child: Text(
                                'Chatta',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    // color: Colors.grey[800]
                                    // color: Colors.blue[500]
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),

                      Divider(indent: 15, endIndent: 15,),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.only(top: 0, bottom: MediaQuery.of(context).size.height * 0.105),
                        child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(bottom: 15),
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, i){
                              return Divider(indent: 15, endIndent: 15,);
                            },
                            // padding: EdgeInsets.symmetric(vertical: 10),
                            itemCount: bookingBusinessPrestazioni!.length,
                            itemBuilder: (context, index) {
                              Prestazione prestazione = Prestazione(
                                  id: bookingBusinessPrestazioni![index]['id'],
                                  image: bookingBusinessPrestazioni![index]['image'],
                                  duration: bookingBusinessPrestazioni![index]['duration'],
                                  title: bookingBusinessPrestazioni![index]['title'],
                                  description: bookingBusinessPrestazioni![index]['description'] ?? '',
                                  isValid: bookingBusinessPrestazioni![index]['prestazione_is_valid'],
                                  price: bookingBusinessPrestazioni![index]['price']?.toDouble(),
                                  is_price_range: (bookingBusinessPrestazioni![index]['is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                                  price_min: bookingBusinessPrestazioni![index]['price_min']?.toDouble(),
                                  price_max: bookingBusinessPrestazioni![index]['price_max']?.toDouble(),
                                  created_at: DateTime.tryParse(bookingBusinessPrestazioni![index]['created_at']),
                                  // business_id: bookingBusinessPrestazioni[index]['business_id'],
                                  business: widget.business
                              );

                              return InkWell(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          duration: const Duration(milliseconds: 500),
                                          alignment: Alignment.center,
                                          type: PageTransitionType.fade,
                                          // child: NotificationScreen(),
                                          child: PrestazioneSlotsScreen(
                                            // user: widget.user,
                                            // bookingBusiness: widget.bookingBusiness,
                                            prestazione: prestazione,
                                          )
                                      )
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                                              child: Container(
                                                width: 95,
                                                height: 70,
                                                child: Card(
                                                  margin: EdgeInsets.all(0),
                                                  semanticContainer: true,
                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  elevation: 5,
                                                  child: FutureImage(
                                                    prestazione.image != null && prestazione.image != '' ? prestazione.image! : prestazione.business!.profile_image!,
                                                    width: MediaQuery.of(context).size.width,
                                                  ),
                                                  //margin: EdgeInsets.all(10),
                                                ),
                                              ),
                                            ),
                                          ),
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
                                                      prestazione.title!,
                                                      gradient: LinearGradient(
                                                          begin: Alignment.bottomLeft,
                                                          end: Alignment.topRight,
                                                          colors: [
                                                            // Color(0xff8921aa),
                                                            // Color(0xffDA44bb),

                                                            // Color(0xffFFA818),
                                                            // Color(0xffF9A516),
                                                            // Color(0xffED9B15),
                                                            // Color(0xffF4A117),

                                                            Colors.blueGrey,
                                                            Colors.blueGrey,
                                                          ]
                                                      ),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 14,
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
                                                SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                          //   text: prestazione.duration.toString() + ' minuti',
                                                            text: '€ ' + NumberFormat.currency(
                                                              // customPattern: '#,##',
                                                              locale: 'IT_it',
                                                              decimalDigits: 2,
                                                              symbol: '',
                                                              // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                            ).format(prestazione.price?.toDouble()),
                                                            style: GoogleFonts.roboto(
                                                                fontWeight: FontWeight.w700,
                                                                // color: Colors.grey[800],
                                                                // color: Colors.green[600],
                                                                color: Colors.blue[500],
                                                                fontSize: 13
                                                            )
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                // SizedBox(height: 20,),
                                                SizedBox(height: 15,),
                                                Row(
                                                  children: [
                                                    // Card(
                                                    //   semanticContainer: true,
                                                    //   color: Colors.grey[100],
                                                    //   margin: EdgeInsets.all(0),
                                                    //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    //   shape: RoundedRectangleBorder(
                                                    //     borderRadius: BorderRadius.circular(50.0),
                                                    //   ),
                                                    //   elevation: 0,
                                                    //   // margin: EdgeInsets.all(0),
                                                    //   child: Padding(
                                                    //     padding: EdgeInsets.only(
                                                    //       top: 5,
                                                    //       bottom: 5,
                                                    //       left: 6,
                                                    //       right: 6,
                                                    //     ),
                                                    //     child: Row(
                                                    //       children: [
                                                    //         Padding(
                                                    //           padding: const EdgeInsets.only(bottom: 0.0),
                                                    //           child: Icon(
                                                    //             Icons.pin_drop_outlined,
                                                    //             // Icons.price_change_outlined,
                                                    //             color: Colors.grey[600],
                                                    //             size: 13,
                                                    //           ),
                                                    //         ),
                                                    //         SizedBox(width: 3),
                                                    //         RichText(
                                                    //           text: TextSpan(
                                                    //               children: <TextSpan>[
                                                    //                 TextSpan(
                                                    //                   //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                    //                   //   text: prestazione.duration.toString() + ' minuti',
                                                    //                     text: NumberFormat.currency(
                                                    //                       // customPattern: '#,##',
                                                    //                         decimalDigits: 2,
                                                    //                         symbol: '',
                                                    //                         locale: 'IT_it'
                                                    //                     ).format(Geolocator.distanceBetween(
                                                    //                       // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                                                    //                       // 45.4281857, 9.1531147, 45.44131, 9.14952
                                                    //                       // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                                                    //                         45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                                                    //                     )/1000) + 'km',
                                                    //                     style: GoogleFonts.roboto(
                                                    //                         fontWeight: FontWeight.w700,
                                                    //                         color: Colors.grey[600],
                                                    //                         // color: Colors.green[600],
                                                    //                         // color: Colors.blue[500],
                                                    //                         fontSize: 11
                                                    //                     )
                                                    //                 ),
                                                    //               ]
                                                    //           ),
                                                    //         ),
                                                    //       ],
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    // SizedBox(width: 10,),
                                                    // Card(
                                                    //   semanticContainer: true,
                                                    //   color: Colors.grey[100],
                                                    //   margin: EdgeInsets.all(0),
                                                    //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    //   shape: RoundedRectangleBorder(
                                                    //     borderRadius: BorderRadius.circular(50.0),
                                                    //   ),
                                                    //   elevation: 0,
                                                    //   // margin: EdgeInsets.all(0),
                                                    //   child: Padding(
                                                    //     padding: EdgeInsets.only(
                                                    //       top: 5,
                                                    //       bottom: 5,
                                                    //       left: 6,
                                                    //       right: 3,
                                                    //     ),
                                                    //     child: Row(
                                                    //       children: [
                                                    //         Padding(
                                                    //           padding: const EdgeInsets.only(bottom: 0.0),
                                                    //           child: Icon(
                                                    //             Icons.price_change,
                                                    //             // Icons.price_change_outlined,
                                                    //             color: Colors.grey[600],
                                                    //             size: 13,
                                                    //           ),
                                                    //         ),
                                                    //         SizedBox(width: 3),
                                                    //         RichText(
                                                    //           text: TextSpan(
                                                    //             children: <TextSpan>[
                                                    //               TextSpan(
                                                    //                 //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                    //                 //   text: prestazione.duration.toString() + ' minuti',
                                                    //                   text: '€ ' + NumberFormat.currency(
                                                    //                     // customPattern: '#,##',
                                                    //                     locale: 'IT_it',
                                                    //                     decimalDigits: 2,
                                                    //                     symbol: '',
                                                    //                     // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                    //                   ).format(prestazione.price?.toDouble()),
                                                    //                   style: GoogleFonts.roboto(
                                                    //                       fontWeight: FontWeight.w700,
                                                    //                       color: Colors.grey[600],
                                                    //                       // color: Colors.green[600],
                                                    //                       // color: Colors.blue[500],
                                                    //                       fontSize: 11
                                                    //                   )
                                                    //               ),
                                                    //             ]
                                                    //           ),
                                                    //         ),
                                                    //       ],
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    // SizedBox(width: 10,),
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
                                                          top: 5,
                                                          bottom: 5,
                                                          left: 8,
                                                          right: 8,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                              child: Icon(
                                                                Icons.access_time_outlined,
                                                                // Icons.price_change,
                                                                // Icons.price_change_outlined,
                                                                color: Colors.grey[600],
                                                                size: 13,
                                                              ),
                                                            ),
                                                            SizedBox(width: 3),
                                                            RichText(
                                                              text: TextSpan(
                                                                  children: <TextSpan>[
                                                                    TextSpan(
                                                                      //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                                        text: prestazione.duration.toString() + ' minuti'/*' "'*/,
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
                                                                            fontSize: 10
                                                                        )
                                                                    ),
                                                                  ]
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 25,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(width: 15,)
                                        ],
                                      ),
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
