import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

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
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/models/post_like.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/screens/business_followers_list_screen.dart';
import 'package:nurebo/screens/post_full_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
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
import 'package:nurebo/widgets/tab_bar_sliver_persistent_header_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'event_business_profile_screen.dart';


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
  late PostProvider postProvider;
  late UserProvider userProvider;
  late GeolocationProvider geolocationProvider;
  String businessAddress = '';
  double? distanceInMeters;
  bool isDateTableVisible = false;
  Future a = Future(() {}), d = Future(() {}), dfddfh = Future(() {}), hbbhbh5bh = Future(() {}), all = Future(() {}),
      ba = Future(() {}), bb = Future(() {}), bc = Future(() {}), bd = Future(() {}), be = Future(() {}),
      bf = Future(() {}), bg = Future(() {}), bh = Future(() {}), bi = Future(() {});
  // Future ab;
  late NumberFormat formatter;
  ScrollController? _scrollController;
  Color? _theme;
  List<Prestazione> bestsellersList = [];
  bool isSavedBusiness = false;
  late AnimationController prenotaAnimationController;
  late Animation<Alignment> topAnimationAlignment;
  late Animation<Alignment> bottomAnimationAlignment;
  List<BusinessPost> businessPostList = [];
  List<User> businessFollowersList = [];
  int businessBookingsCount = 0;
  int businessPrestazioneLikesCount = 0;


  Future getBusinessFollowers(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/save/user");

    // Map<String, dynamic> body = {
    //   'user_id': user.id,
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      for(var e in jsonData){
        businessFollowersList.add(
          User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          )
        );
      }

      // //print('jsonData22222222');
      // //print(jsonData);

      // notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessBookingCount(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/booking/is_visible/count");

    // Map<String, dynamic> body = {
    //   'user_id': user.id,
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('dffbbfdb56bdb65dbg5');
      // print(jsonData);

      businessBookingsCount = jsonData[0]['count'];

      // notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessPrestazioneLikesCount(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/prestazione/like/count");

    // Map<String, dynamic> body = {
    //   'user_id': user.id,
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('f5bv65bfbf65fb65bf');
      // print(jsonData);

      businessPrestazioneLikesCount = jsonData[0]['count'];

      // notifyListeners();
      return jsonData;
    }
  }

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

      postProvider.getAllBusinessesPosts(context);

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
      setState(() {
        businessFollowersList.insert(0, Utils.user!);
      });
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

      setState(() {
        businessFollowersList.removeWhere((e) => Utils.user!.id == e.id);
      });
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

  Future getAllBusinessPosts(/*Business business*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/post/is_visible");

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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   categoryList.addAll(jsonData);
      // });

      // postList = jsonData;
      // postList.addAll(jsonData);

      businessPostList.clear();
      for(var e in jsonData){
        businessPostList.add(
          // BookingPost(
          //   id: e['post_id'],
          //   description: e['post_description'],
          //   image_url: e['post_image_url'],
          //   is_admin: e['post_is_admin'],
          //   is_visible: e['post_is_visible'],
          //   created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
          //   booking: Booking(
          //     id: e['booking_id'],
          //     isCanceled: e['is_canceled'],
          //     // note: myAppointments[index]['note'],
          //     // user_id: myAppointments[index]['user_id'].toString(),
          //     prestazione: Prestazione(
          //       id: e['prestazione_id'],
          //       duration: e['prestazione_duration'],
          //       image: e['prestazione_image'] ?? '',
          //       is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
          //       price: e['prestazione_price']?.toDouble(),
          //       price_min: e['prestazione_price_min']?.toDouble(),
          //       price_max: e['prestazione_price_max']?.toDouble(),
          //
          //       title: e['prestazione_title'],
          //       description: e['prestazione_description'] ?? '',
          //       // business_id: e['prestazione_business_id'],
          //       business: Business(
          //           id: e['business_id'],
          //           email: e['business_email'],
          //           name: e['business_name'],
          //           longitude: e['business_longitude'],
          //           latitude: e['business_latitude'],
          //           phone_number: e['business_phone_number'],
          //           room_id: e['business_room_id'],
          //           profile_image: e['business_profile_image'],
          //           address: e['business_address'],
          //           description: e['business_description'],
          //           type_id: e['business_type_id'],
          //           max_contemporary_appointments: e['max_contemporary_appointments'],
          //           category: Category(
          //             id: e['category_id'],
          //             image: e['category_image'],
          //             name: e['category_name'],
          //           )
          //       ),
          //     ),
          //     business: Business(
          //         id: e['business_id'],
          //         email: e['business_email'],
          //         name: e['business_name'],
          //         longitude: e['business_longitude'],
          //         latitude: e['business_latitude'],
          //         phone_number: e['business_phone_number'],
          //         profile_image: e['business_profile_image'],
          //         address: e['business_address'],
          //         description: e['business_description'],
          //         type_id: e['business_type_id'],
          //         room_id: e['business_room_id'],
          //         max_contemporary_appointments: e['max_contemporary_appointments'],
          //         category: Category(
          //           id: e['category_id'],
          //           image: e['category_image'],
          //           name: e['category_name'],
          //         )
          //     ),
          //     user: User(
          //       id: e['user_id'],
          //       email: e['user_email'],
          //       username: e['user_username'],
          //       name: e['user_name'],
          //       phone_number: e['user_phone_number'],
          //       profile_image: e['user_profile_image'],
          //       description: e['user_description'],
          //     ),
          //     begin_at: DateTime.tryParse(e['begin_at']),
          //     end_at: DateTime.parse(e['begin_at']).add(Duration(minutes: e['prestazione_duration'].toInt())),
          //     created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
          //   ),
          //   user: User(
          //     profile_image: e['user_profile_image'],
          //     id: e['user_id'],
          //     username: e['user_username'],
          //     email: e['user_email'],
          //     name: e['user_name'],
          //     description: e['user_description'],
          //   ),
          // )
            BusinessPost(
              id: e['post_id'],
              description: e['post_description'],
              image_url: e['post_image_url'],
              // is_admin: e['post_is_admin'],
              // is_visible: e['post_is_visible'],
              created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              // booking: Booking(
              //   id: e['booking_id'],
              //   isCanceled: e['is_canceled'],
              //   // note: myAppointments[index]['note'],
              //   // user_id: myAppointments[index]['user_id'].toString(),
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
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              comments: [],
              likes: [],
            )
        );
      }

      // print('postList555663');
      // print(postList);
      // print(postList.length);

      // notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessPostComments() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/post/comment");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
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
        }
    );

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('userBusinessPostCommentsList');
      // print(jsonData.length);

      postProvider.businessProfilePostComments.clear();

      for(var e in jsonData) {
        for (BusinessPost post in /*postProvider.businessProfilePostList*/businessPostList) {
          if(e['post_id'] == post.id){
            PostComment postComment = PostComment(
              id: e['id'],
              is_admin: e['is_admin'],
              created_at: DateTime.parse(e['created_at']),
              text: e['text'],
              businessPost: post,
              user: User(
                id: e['user_id'],
                description: e['user_description'],
                profile_image: e['user_profile_image'] ?? '',
                // first_name: comments[i]['first_name'],
                name: e['user_name'],
                // last_name: comments[i]['last_name'],
                // city: postProvider.posts[i]['city'],
                // nation: postProvider.posts[i]['nation'],
                username: e['username'],
                email: e['user_email'],
              ),
            );

            post.comments.add(postComment);
            postProvider.businessProfilePostComments.add(postComment);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future getBusinessPostLikes() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/like");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id}/post/like");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
    //   // 'text': commentController.text,
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
        }
    );

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('f9f89f9f8gh8h8h8h8n');
      // print(jsonData.length);

      postProvider.businessProfilePostLikes.clear();
      for(var e in jsonData) {
        for (BusinessPost post in /*postProvider.businessProfilePostList*/businessPostList) {
          if(e['post_id'] == post.id){
            PostLike postlike = PostLike(
              businessPost: BusinessPost(
                id: e['post_id'],
                description: e['post_description'],
                image_url: e['post_image_url'],
                // is_admin: e['post_is_admin'],
                // is_visible: e['post_is_visible'],
                created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                // booking: Booking(
                //   id: e['booking_id'],
                //   isCanceled: e['is_canceled'],
                //   // note: myAppointments[index]['note'],
                //   // user_id: myAppointments[index]['user_id'].toString(),
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
                  profile_image: e['user_profile_image'] ?? '',
                  description: e['user_description'],
                ),
                comments: [],
                likes: [],
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            );

            post.likes.add(postlike);
            postProvider.businessProfilePostLikes.add(postlike);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height * .32 - kToolbarHeight);
  }

  Future callFutureBuilderMethods() async {
    await Future.wait([
      // getBusinessImages(),
      ba = getDateBusinessPrestazioni(),
      bb = getTimetableDay(selectedDate.weekday),
      bc = getDateBusinessTimetable(),
      bd = getAddressFromLatLng(),
      be = /*postProvider.*/getAllBusinessPosts(/*widget.business!*/),
      bf = postProvider.getAllBusinessClients(widget.business!),
      bg = getBusinessFollowers(widget.business!),
      bh = getBusinessBookingCount(widget.business!),
      bi = getBusinessPrestazioneLikesCount(widget.business!),
      // ab = getBestsellers(),
      dfddfh = getBusinessPostComments(),
      hbbhbh5bh = getBusinessPostLikes(),
    ]);

  }

  @override
  void initState() {
    super.initState();
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

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
      },):{} : _theme != Colors.white ?
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

    // Future.wait([
      all = callFutureBuilderMethods();/*,
    ]);*/

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
    postProvider = Provider.of<PostProvider>(context, listen: true);

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
      body: FutureBuilder(
        future: Future.wait([all]),
        // future: all,
        initialData: [],
        builder: (context, snapshot) {
          // if(snapshot.connectionState == ConnectionState.done){
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: CustomScrollView(
              // child: NestedScrollView(
              //   key: UniqueKey(),
                  controller: _scrollController,
                  // shrinkWrap: true,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.height * .33,
                      floating: true,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      // backgroundColor: Color.fromRGBO(245, 93, 62, 1),
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
                                        GradientText(
                                          widget.business!.name ?? '',
                                          style: TextStyle(
                                              color: !_isAppBarExpanded ? Colors.white : Colors.green[600],
                                              fontSize: 18,
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
                                        height: (bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
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
                                  // colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                                  backgroundBlendMode: BlendMode.darken,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   bottom: 60,
                              //   left: 20,
                              //   width: MediaQuery.of(context).size.width * 0.8,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Marquee(
                              //         child: GradientText(
                              //           widget.business!.name ?? '',
                              //           // 'A partire da € 60,00',
                              //           maxLines: 1,
                              //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //           gradient: Gradients.hotLinear,
                              //           // gradient: LinearGradient(
                              //           //     begin: Alignment.bottomLeft,
                              //           //     end: Alignment.topRight,
                              //           //     colors: [
                              //           //       // Color(0xffDA44bb),
                              //           //       // Color(0xffDA44bb),
                              //           //       // Color(0xff8921aa),
                              //           //       Colors.white,
                              //           //       Colors.white,
                              //           //       // Colors.blue, Colors.blue,
                              //           //
                              //           //     ]
                              //           // ),
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
                              //               fontWeight: FontWeight.w700,
                              //               fontSize: 20,
                              //           ),
                              //           textAlign: TextAlign.left,
                              //         ),
                              //       ),
                              //       Marquee(
                              //         child: GradientText(
                              //           widget.business!.address ?? '',
                              //           maxLines: 1,
                              //           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //           gradient: Gradients.haze,
                              //           style: TextStyle(
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w700,
                              //               fontSize: 14
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
                                    /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder/*<Object>*/(
                                        future: a/*!.then((value) => value as Object)*/,
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
                      child: DefaultTabController(
                        length: 3,
                        child: Container(
                          height: MediaQuery.of(context).size.height * .57,
                          child: NestedScrollView(
                            // floatHeaderSlivers: true,
                            headerSliverBuilder: (context, innerBoxIsScrolled){
                              return [
                                SliverToBoxAdapter(
                                  child: Container(
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                            child: FutureBuilder/*<Object>*/(
                                                                future: a/*!.then((value) => value as Object)*/,
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
                                                                                          // destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                                                                                          destination: map_launcher.Coords(widget.business!.latitude!, widget.business!.longitude!),
                                                                                          // destinationTitle: destinationTitle,
                                                                                          // origin: map_launcher.Coords(45.4281857, 9.1531147),
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
                                            /*Container*/SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.5,
                                              // constraints: BoxConstraints(
                                              //   minWidth: 20,
                                              //   maxWidth: MediaQuery.of(context).size.width * 0.2,
                                              // ),
                                              // width: 100,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  // Visibility(
                                                  //   visible: Utils.user!.id == widget.user!.id,
                                                  //   // maintainSize: false,
                                                  //   // maintainState: false,
                                                  //   // maintainSemantics: false,
                                                  //   // maintainInteractivity: false,
                                                  //   // maintainAnimation: false,
                                                  //   child: InkWell(
                                                  //     onTap: (){
                                                  //       //print(Utils.user!.id == widget.user!.id);
                                                  //       // Navigator.push(
                                                  //       //     context,
                                                  //       //     PageTransition(
                                                  //       //         duration: const Duration(milliseconds: 500),
                                                  //       //         alignment: Alignment.center,
                                                  //       //         type: PageTransitionType.fade,
                                                  //       //         child: FollowersScreen(
                                                  //       //           user: widget.user,
                                                  //       //           followers: followers,
                                                  //       //         )
                                                  //       //     )
                                                  //       // );
                                                  //     },
                                                  //     child: Column(
                                                  //       children: [
                                                  //         Text(
                                                  //           Utils.user!.id == widget.user!.id ? favoriteProvider.favoritesList.length.toString() : "",
                                                  //           // favoriteProvider.favoritesList.length.toString(),
                                                  //           style: GoogleFonts.montserrat(
                                                  //               fontSize: 18.0,
                                                  //               color: Colors.blue,
                                                  //               // color: Colors.grey[700],
                                                  //               fontWeight: FontWeight.w600
                                                  //           )
                                                  //         ),
                                                  //         Text(
                                                  //             // 'Followers',
                                                  //             'Preferiti',
                                                  //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                                  //         )
                                                  //       ],
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
                                                              child: BusinessFollowersListScreen(
                                                                businessFollowers: businessFollowersList,
                                                              )
                                                          )
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            // "52",
                                                              businessFollowersList.length.toString(),
                                                              //   userProvider.events1.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //   subscriptions.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                              //     : widget.user.numEventi.toString(),
                                                              // style: GoogleFonts.montserrat(
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 18.0,
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w600
                                                              )
                                                          ),
                                                          SizedBox(height: 2,),
                                                          Text(
                                                            // 'Iscrizioni',
                                                              'Iscritti',
                                                              // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                              style: TextStyle(fontSize: 12.0, color: Colors.grey)
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: (){
                                                      // Navigator.push(
                                                      //     context,
                                                      //     PageTransition(
                                                      //         duration: const Duration(milliseconds: 500),
                                                      //         alignment: Alignment.center,
                                                      //         type: PageTransitionType.fade,
                                                      //         child: widget.user!.id == Utils.user!.id ? UserFriendsListScreen(
                                                      //           // userFriends: socketProvider.userFriendsList,
                                                      //           // user: widget.user!,
                                                      //         ) : UserProfileFriendsListScreen(
                                                      //           userFriends: userFriendsList,
                                                      //           // user: widget.user!,
                                                      //         )
                                                      //     )
                                                      // );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            // "12",
                                                              businessPrestazioneLikesCount.toString(),
                                                              // widget.user!.id == Utils.user!.id
                                                              //     ? socketProvider.userFriendsList.length.toString()
                                                              //     : userFriendsList.length.toString(),
                                                              //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                                                              // businessBookingsCount.toString(),
                                                              //   userProvider.events1.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //   subscriptions.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                              //     : widget.user.numEventi.toString(),
                                                              // style: GoogleFonts.montserrat(
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 18.0,
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w600
                                                              )
                                                          ),
                                                          SizedBox(height: 2,),
                                                          Text(
                                                            // 'Iscrizioni',
                                                              'Preferenze',
                                                              // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                              style: TextStyle(fontSize: 12.0, color: Colors.grey)
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: (){
                                                      // Navigator.push(
                                                      //     context,
                                                      //     PageTransition(
                                                      //         duration: const Duration(milliseconds: 500),
                                                      //         alignment: Alignment.center,
                                                      //         type: PageTransitionType.fade,
                                                      //         child: SubscriptionsScreen(
                                                      //           user: widget.user,
                                                      //           subscriptions: subscriptions,
                                                      //         )
                                                      //     )
                                                      // );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            // "459",
                                                              businessBookingsCount.toString(),
                                                              //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                                                              //   userFollowedList.length.toString(),
                                                              //   userProvider.events1.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //   subscriptions.length.toString(),
                                                              // widget.user.numEventi >= 10000
                                                              //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                              //     : widget.user.numEventi.toString(),
                                                              // style: GoogleFonts.montserrat(
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 18.0,
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w600
                                                              )
                                                          ),
                                                          SizedBox(height: 2,),
                                                          Text(
                                                            // 'Iscrizioni',
                                                              'Prenotazioni',
                                                              // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                              style: TextStyle(fontSize: 12.0, color: Colors.grey)
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // Visibility(
                                                  //   visible: Utils.isEventsEnabled,
                                                  //   maintainSize: false,
                                                  //   maintainInteractivity: false,
                                                  //   maintainAnimation: false,
                                                  //   maintainSemantics: false,
                                                  //   maintainState: false,
                                                  //   replacement: SizedBox(),
                                                  //   child: InkWell(
                                                  //     onTap: (){
                                                  //       // Navigator.push(
                                                  //       //     context,
                                                  //       //     PageTransition(
                                                  //       //         duration: const Duration(milliseconds: 500),
                                                  //       //         alignment: Alignment.center,
                                                  //       //         type: PageTransitionType.fade,
                                                  //       //         child: SubscriptionsScreen(
                                                  //       //           user: widget.user,
                                                  //       //           subscriptions: subscriptions,
                                                  //       //         )
                                                  //       //     )
                                                  //       // );
                                                  //     },
                                                  //     child: Column(
                                                  //       children: [
                                                  //         Text(
                                                  //           // "52",
                                                  //           // socketProvider.eventTicketsList.length.toString(),
                                                  //             eventTicketList1.length.toString(),
                                                  //             //   userProvider.events1.length.toString(),                                    // widget.user.numEventi >= 10000
                                                  //             //   subscriptions.length.toString(),                                    // widget.user.numEventi >= 10000
                                                  //             //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                  //             //     : widget.user.numEventi.toString(),
                                                  //             // style: GoogleFonts.montserrat(
                                                  //             style: GoogleFonts.montserrat(
                                                  //                 fontSize: 18.0,
                                                  //                 color: Colors.blue,
                                                  //                 fontWeight: FontWeight.w600
                                                  //             )
                                                  //         ),
                                                  //         Text(
                                                  //           // 'Iscrizioni',
                                                  //             'Biglietti',
                                                  //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                                  //         )
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  // Visibility(
                                                  //   visible: Utils.user!.id == widget.user!.id,
                                                  //   child: InkWell(
                                                  //     onTap: (){
                                                  //       // Navigator.push(
                                                  //       //     context,
                                                  //       //     PageTransition(
                                                  //       //         duration: const Duration(milliseconds: 500),
                                                  //       //         alignment: Alignment.center,
                                                  //       //         type: PageTransitionType.fade,
                                                  //       //         child: FollowsScreen(
                                                  //       //           user: widget.user,
                                                  //       //           follows: follows,
                                                  //       //         )
                                                  //       //     )
                                                  //       // );
                                                  //     },
                                                  //     child: Column(
                                                  //       children: [
                                                  //         Text(
                                                  //           Utils.user!.id == widget.user!.id ? businessFavoriteProvider.savedBusinessList!.length.toString() : "",
                                                  //           // prestazioniList.length.toString(),
                                                  //           // businessFavoriteProvider.savedBusinessList.length.toString(),
                                                  //           // seguiti.toString(),
                                                  //
                                                  //           //   userProvider.seguiti.toString(),
                                                  //
                                                  //             // follows.length >= 10000
                                                  //             //     ? ((follows.length/1000)./*toInt().*/truncate()).toString() + "mila"
                                                  //             //     : follows.length.toString(),
                                                  //             style: GoogleFonts.montserrat(
                                                  //                 fontSize: 18.0, color: Colors.blue, fontWeight: FontWeight.w600
                                                  //             )
                                                  //         ),
                                                  //         Text(
                                                  //             // 'Seguiti',
                                                  //             // 'Locali',
                                                  //             'Salvati',
                                                  //             // style: GoogleFonts.montserrat(
                                                  //             style: TextStyle(
                                                  //                 fontSize: 11.0,
                                                  //                 color: Colors.grey
                                                  //             )
                                                  //         )
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                FutureBuilder/*<Object?>*/(
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
                                                                  ).then((value) async {
                                                                    if(value >= 200 && value < 400){
                                                                      //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
                                                                      /*await*/ businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);
                      
                                                                      // print('ffffffdiocann');
                      
                                                                      // postProvider.getAllBusinessesPosts();
                                                                      // postProvider.clearPost();
                      
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
                                                                  ).then((value) async {
                                                                    if(value >= 200 && value < 400){
                                                                      //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
                                                                      /*await*/ businessFavoriteProvider.getUserSavedBusiness(userProvider.user!);
                                                                      // Fluttertoast.showToast(
                                                                      //   msg: 'Aggiunto ai Salvati',
                                                                      //   backgroundColor: Colors.grey[700],
                                                                      // );
                                                                      // postProvider.getAllBusinessesPosts();
                                                                      // postProvider.clearPost();
                                                                      // print('diolamaneddo');
                      
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
                      
                                                                      // print('ggg5g5ttrreee');
                      
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
                      
                                                                      // print('diolaaaaaassmssd');
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
                                                      'Chat',
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
                                            SizedBox(height: 20,),
                                            Divider(indent: 15, endIndent: 15,)
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
                                ),
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: TabBarSliverPersistentHeaderDelegate(
                                      extent: 48,
                                      child: Container(
                                        height: 48,
                                        // color: Colors.grey[50],
                                        width: MediaQuery.of(context).size.width,
                                        child: TabBar(
                                          // indicatorColor: Theme.of(context).colorScheme.onBackground,
                                          indicatorColor: Colors.transparent,
                                          // isScrollable: true,
                                          isScrollable: false,
                                          // indicatorColor: Colors.blue,
                                          labelColor: Colors.blue,
                                          unselectedLabelColor: Colors.grey[500],
                                          tabs: [
                                            // Tab(icon: Icon(Icons.grid_on),),
                                            // Tab(icon: Icon(Icons.person_outline),)
                                            Tab(
                                                child: Marquee(
                                                    animationDuration: Duration(milliseconds: 1000),
                                                    backDuration: Duration(milliseconds: 1000),
                                                    // backwardAnimation: Curves.easeOutBack,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          // 'Appuntamenti',
                                                          'Prestazioni',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13.5
                                                          ),
                                                        ),
                                                        SizedBox(width: 6,),
                                                        CircleAvatar(
                                                          // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                                          backgroundColor: Colors.blue[400],
                                                          maxRadius: 12,
                                                          child: Center(
                                                            child: Text(
                                                              // '13',
                                                              // myAppointmentsList.length.toString(),
                                                                bookingBusinessPrestazioni!.length.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize: 10.0,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700
                                                                )
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                )
                                            ),
                                            Tab(
                                                child: Marquee(
                                                    animationDuration: Duration(milliseconds: 1000),
                                                    backDuration: Duration(milliseconds: 1000),
                                                    // backwardAnimation: Curves.easeOutBack,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Post',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13.5
                                                          ),
                                                        ),
                                                        SizedBox(width: 6,),
                                                        CircleAvatar(
                                                          // backgroundColor: Colors.grey[300],
                                                          // maxRadius: 11,
                                                          backgroundColor: Colors.blue[400],
                                                          maxRadius: 12,
                                                          child: Center(
                                                            child: Text(
                                                              // '13',
                                                              //   postProvider.businessProfilePostList.length.toString(),
                                                                businessPostList.length.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize: 10.0,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700
                                                                )
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                )
                                            ),
                                            Tab(
                                                child: Marquee(
                                                    animationDuration: Duration(milliseconds: 1000),
                                                    backDuration: Duration(milliseconds: 1000),
                                                    // backwardAnimation: Curves.easeOutBack,
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                          // 'Appuntamenti',
                                                          // 'Locali',
                                                          'Clienti',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13.5
                                                          ),
                                                        ),
                                                        SizedBox(width: 6,),
                                                        CircleAvatar(
                                                          // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                                          backgroundColor: Colors.blue[400],
                                                          radius: 12,
                                                          child: Center(
                                                            child: Text(
                                                                postProvider.businessProfileUsersList.length.toString(),
                                                                // businessList.length.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize: 10.0,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700
                                                                )
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                )
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ),
                              ];
                            },
                            body: NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return true;
                              },
                              child: TabBarView(
                                  children: [
                                    Container(
                                      child: Stack(
                                        fit: StackFit.passthrough,
                                        children: [
                                          ListView(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.only(top: 13),
                                            children: [
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
                                                                                  text: !prestazione.is_price_range ? '€ ${NumberFormat.currency(
                                                                                    // customPattern: '#,##',
                                                                                    locale: 'IT_it',
                                                                                    decimalDigits: 2,
                                                                                    symbol: '',
                                                                                    // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                                                    ).format(prestazione.price!.toDouble())}' : 'Da € ${NumberFormat.currency(
                                                                                    // customPattern: '#,##',
                                                                                    locale: 'IT_it',
                                                                                    decimalDigits: 2,
                                                                                    symbol: '',
                                                                                    // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                                                  ).format(prestazione.price_min!.toDouble())} a € ${NumberFormat.currency(
                                                                                    // customPattern: '#,##',
                                                                                    locale: 'IT_it',
                                                                                    decimalDigits: 2,
                                                                                    symbol: '',
                                                                                    // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                                                  ).format(prestazione.price_max!.toDouble())}',
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
                      
                                    // eventTicketList.isEmpty ? ListView(
                                    //   children: [
                                    //     SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                    //     Center(
                                    //       child: Image.asset(
                                    //         'assets/png/Saly-3.png',
                                    //         height: MediaQuery.of(context).size.height * .2,
                                    //         // width: MediaQuery.of(context).size.width * .7,
                                    //         fit: BoxFit.cover,
                                    //       ),
                                    //     ),
                                    //     SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                    //     Center(
                                    //       child: Text(
                                    //         "Non ci sono eventi",
                                    //         // 'Le mie prestazioni',
                                    //         style: TextStyle(
                                    //           // color: Colors.blue,
                                    //             color: Colors.grey[500],
                                    //             fontWeight: FontWeight.w700,
                                    //             fontSize: 16
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ) : GridView.builder(
                                    //     padding: EdgeInsets.all(2),
                                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    //       childAspectRatio: 1.66,
                                    //       crossAxisCount: 2,
                                    //       crossAxisSpacing: 0,
                                    //       mainAxisSpacing: 0,
                                    //     ),
                                    //     // itemCount: myAppointmentsList.length,
                                    //     itemCount: eventTicketList.length,
                                    //     itemBuilder: (context, i) {
                                    //       // SingleEventReservation singleEventReservation = new SingleEventReservation(
                                    //       //   // id: postProvider.posts[i]['post_id'].toInt(),
                                    //       //   id: postProvider.posts[i]['post_id'],
                                    //       //   description: postProvider.posts[i]['post_description'],
                                    //       //   bookingTime: DateTime.parse(postProvider.posts[i]['post_created_at']),
                                    //       //   // exhibition_id: int.parse(postProvider.posts[i]['exhibition_id']),
                                    //       //   image_video: postProvider.posts[i]['image_video'],
                                    //       //   // user_id: int.parse(postProvider.posts[i]['user_id']),
                                    //       //   user_id: postProvider.posts[i]['user_id'].toInt(),
                                    //       //   title: postProvider.posts[i]['post_title'],
                                    //       // );
                                    //       // return Image.asset(
                                    //       //   'assets/sample/search_demo1.jpg',
                                    //       //   fit: BoxFit.cover,
                                    //       // );
                                    //       return InkWell(
                                    //         onTap: (){
                                    //           Navigator.push(
                                    //               context,
                                    //               PageTransition(
                                    //                 duration: const Duration(milliseconds: 500),
                                    //                 alignment: Alignment.center,
                                    //                 type: PageTransitionType.fade,
                                    //                 child: EventScreen(
                                    //                   // prestazione: new Prestazione(
                                    //                   //   id: myAppointmentsList[i]['prestazione_id'],
                                    //                   //   business: new Business(
                                    //                   //     id: myAppointmentsList[i]['business_id'],
                                    //                   //     name: myAppointmentsList[i]['business_name'],
                                    //                   //     is_booking_business: myAppointmentsList[i]['business_type_id'],
                                    //                   //     profile_image: myAppointmentsList[i]['business_image'],
                                    //                   //     description: myAppointmentsList[i]['business_description'],
                                    //                   //     address: myAppointmentsList[i]['business_address'],
                                    //                   //     phone_number: myAppointmentsList[i]['business_phone_number'],
                                    //                   //     max_contemporary_appointments: myAppointmentsList[i]['max_contemporary_appointments'],
                                    //                   //   ),
                                    //                   //   price: myAppointmentsList[i]['prestazione_price'],
                                    //                   //   image: myAppointmentsList[i]['prestazione_image'],
                                    //                   //   duration: myAppointmentsList[i]['prestazione_duration'],
                                    //                   //   title: myAppointmentsList[i]['prestazione_title'],
                                    //                   //   description: myAppointmentsList[i]['prestazione_description'],
                                    //                   //   last_modification_at: DateTime.parse(myAppointmentsList[i]['prestazione_last_modification_at']),
                                    //                   // ),
                                    //                   event: eventTicketList[i],
                                    //                 ),
                                    //               )
                                    //           );
                                    //         },
                                    //         child: Card(
                                    //           margin: EdgeInsets.all(2),
                                    //           shape: RoundedRectangleBorder(
                                    //             borderRadius: BorderRadius.circular(10),
                                    //           ),
                                    //           clipBehavior: Clip.antiAliasWithSaveLayer,
                                    //           elevation: 8,
                                    //           child: Stack(
                                    //             clipBehavior: Clip.antiAliasWithSaveLayer,
                                    //             fit: StackFit.expand,
                                    //             children: [
                                    //               FutureImage(
                                    //                 eventTicketList[i]!.image != null && eventTicketList[i]!.image != ''
                                    //                 ? eventTicketList[i]!.image! : eventTicketList[i]!.business!.profile_image!,
                                    //                 width: MediaQuery.of(context).size.width,
                                    //               ),
                                    //               const DecoratedBox(
                                    //                 decoration: BoxDecoration(
                                    //                   // backgroundBlendMode: BlendMode.darken,
                                    //                   gradient: LinearGradient(
                                    //                     begin: Alignment.bottomLeft,
                                    //                     end: Alignment.topRight,
                                    //                     colors: [
                                    //                       Colors.black,
                                    //                       // Colors.transparent,
                                    //                       Colors.transparent,
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //               Positioned(
                                    //                 bottom: 15,
                                    //                 left: 15,
                                    //                 width: MediaQuery.of(context).size.width * 0.4,
                                    //                 child: Column(
                                    //                   crossAxisAlignment: CrossAxisAlignment.start,
                                    //                   children: [
                                    //                     GradientText(
                                    //                       eventTicketList[i]!.business!.name!,
                                    //                       overflow: TextOverflow.ellipsis,
                                    //                       maxLines: 1,
                                    //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                    //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                    //                       gradient: LinearGradient(
                                    //                           begin: Alignment.bottomLeft,
                                    //                           end: Alignment.topRight,
                                    //                           colors: [
                                    //                             // Color(0xff8921aa),
                                    //                             // Color(0xffDA44bb),
                                    //
                                    //                             Color(0xffFFA818),
                                    //                             Color(0xffFFB75E),
                                    //                           ]
                                    //                       ),
                                    //                       // gradient: LinearGradient(
                                    //                       //     begin: Alignment.bottomLeft,
                                    //                       //     end: Alignment.topRight,
                                    //                       //     colors: [
                                    //                       //       Colors.blue[500],
                                    //                       //       Color(0xffDA44bb),
                                    //                       //
                                    //                       //       Color(0xff8921aa),
                                    //                       //     ]
                                    //                       // ),
                                    //                       style: TextStyle(
                                    //                           color: Colors.blue,
                                    //                           fontWeight: FontWeight.w700,
                                    //                           fontSize: 13
                                    //                       ),
                                    //                       textAlign: TextAlign.left,
                                    //                     ),
                                    //                     GradientText(
                                    //                       eventTicketList[i]!.title!,
                                    //                       maxLines: 2,
                                    //                       overflow: TextOverflow.ellipsis,
                                    //                       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                    //                       gradient: Gradients.haze,
                                    //                       style: TextStyle(
                                    //                           color: Colors.white,
                                    //                           fontWeight: FontWeight.w700,
                                    //                           fontSize: 15
                                    //                       ),
                                    //                       textAlign: TextAlign.left,
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //       );
                                    //     }
                                    // ),
                      
                                    // postProvider.businessProfilePostList.isEmpty ? ListView(
                                    /*postProvider.businessProfilePostList*/businessPostList.isEmpty ? ListView(
                                      shrinkWrap: true,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                        Center(
                                          child: Image.asset(
                                            'assets/png/Saly-3.png',
                                            height: MediaQuery.of(context).size.height * .2,
                                            // width: MediaQuery.of(context).size.width * .7,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                        Center(
                                          child: Text(
                                            "Non ci sono post",
                                            // 'Le mie prestazioni',
                                            style: TextStyle(
                                              // color: Colors.blue,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : GridView.builder(
                                        padding: EdgeInsets.all(2),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // childAspectRatio: 1.66,
                                          childAspectRatio: 0.5,
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 0,
                                          mainAxisSpacing: 0,
                                        ),
                                        // itemCount: myAppointmentsList.length,
                                        itemCount: /*postProvider.businessProfilePostList*/businessPostList.length,
                                        itemBuilder: (context, i) {
                                          BusinessPost post = /*postProvider.businessProfilePostList*/businessPostList[i];
                      
                                          bool isLiked = false;
                                          for(PostLike e in postProvider.myPostLikesList){
                                            // print(userPostList[i].id);
                                            // print(e.businessPost!.id);
                                            if(post.id == e.businessPost!.id){
                                              isLiked = true;
                                            }
                                          }
                      
                                          // print('postProvider.userProfilePostLikes.length');
                                          // print(postProvider.userProfilePostLikes.length);
                                          // print('postProvider.userProfilePostComments.length');
                                          // print(postProvider.userProfilePostComments.length);
                      
                                          int postLikesCount = 0;
                                          for(PostLike e in postProvider.businessProfilePostLikes){
                                            // print(userPostList[i].id);
                                            // print(e.businessPost!.id);
                                            if(post.id == e.businessPost!.id){
                                              postLikesCount++;
                                            }
                                          }
                      
                                          int postCommentsCount = 0;
                                          for(PostComment e in postProvider.businessProfilePostComments){
                                            // print(userPostList[i].id);
                                            // print(e.businessPost!.id);
                                            if(post.id == e.businessPost!.id){
                                              postCommentsCount++;
                                            }
                                          }
                      
                                          return InkWell(
                                            onTap: (){
                                              // setState(() {
                                              //   socketProvider.setBottomBarVisibility(false);
                                              //   socketProvider.isBottomBarVisible = false;
                                              // });
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      duration: const Duration(milliseconds: 500),
                                                      alignment: Alignment.center,
                                                      type: PageTransitionType.fade,
                                                      child: PostFullScreen(
                                                        // memoryImage: imageCacheBusiness.getImageFromCache(userPostList[i].image_url!)!,
                                                        businessPost: /*postProvider.businessProfilePostList*/post,
                                                        isNetworkLoaded: true,
                                                      )
                                                  )
                                              );
                                              // socketProvider.setBottomBarVisibility(true);
                                            },
                                            child: Card(
                                              margin: EdgeInsets.all(2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              elevation: 8,
                                              child: Stack(
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                fit: StackFit.expand,
                                                children: [
                                                  FutureImage(
                                                    post.image_url!,
                                                    width: MediaQuery.of(context).size.width,
                                                  ),
                                                  const DecoratedBox(
                                                    decoration: BoxDecoration(
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
                                                  //   right: 5,
                                                  //   top: MediaQuery.of(context).size.height * 0.06,
                                                  //   child: Column(
                                                  //     mainAxisAlignment: MainAxisAlignment.start,
                                                  //     // crossAxisAlignment: CrossAxisAlignment.end,
                                                  //     children: [
                                                  //       InkWell(
                                                  //         onTap: () async {
                                                  //           // if (postProvider.isLikedPost){
                                                  //           //   setState(() {
                                                  //           //     /*await*/ postProvider.unlikeBusinessPost(
                                                  //           //         item.id,
                                                  //           //         userProvider!.user!.id
                                                  //           //     );
                                                  //           //   });
                                                  //           // }
                                                  //           // else{
                                                  //           //   setState(() {
                                                  //           //     /*await*/ postProvider.likeBusinessPost(
                                                  //           //       item.id,
                                                  //           //       userProvider!.user!.id
                                                  //           //     );
                                                  //           //   });
                                                  //           // }
                                                  //         },
                                                  //         child: Padding(
                                                  //           padding: const EdgeInsets.only(bottom: .0, top: 11, left: 6, right: 6),
                                                  //           child: Row(
                                                  //             children: [
                                                  //               Icon(
                                                  //                 // Icons.reply,
                                                  //                 postProvider.isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                                  //                 color: postProvider.isLikedPost ? Colors.red : Colors.grey[50],
                                                  //                 // color: Colors.red[500],
                                                  //                 // color: Colors.pink[300],
                                                  //                 size: 15,
                                                  //               ),
                                                  //               SizedBox(width: 5,),
                                                  //               Text(
                                                  //                 // '27',
                                                  //                 // /*postLikes*/postProvider.postLikes.length.toString(),
                                                  //                 /*postLikes*/postProvider.postLikes.length.toString(),
                                                  //                   overflow: TextOverflow.ellipsis,
                                                  //                   style: GoogleFonts.lato(
                                                  //                     fontWeight: FontWeight.w700,
                                                  //                     color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                                  //                     // color: Colors.red[500],
                                                  //                     // color: Colors.pink[300],
                                                  //                     fontSize: 12,
                                                  //                   )
                                                  //               )
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //       SizedBox(height: 5,),
                                                  //       InkWell(
                                                  //         onTap: () {
                                                  //           // Navigator.push(
                                                  //           //     context,
                                                  //           //     PageTransition(
                                                  //           //       duration: const Duration(
                                                  //           //           milliseconds: 500
                                                  //           //       ),
                                                  //           //       alignment: Alignment.center,
                                                  //           //       type: PageTransitionType.fade,
                                                  //           //       child: PostCommentsScreen(
                                                  //           //         isSingleEventPost: false,
                                                  //           //         myUser: userProvider!.user,
                                                  //           //         businessPost: BusinessPost(
                                                  //           //           id: item.id,
                                                  //           //         ),
                                                  //           //       ),
                                                  //           //     )
                                                  //           // );
                                                  //         },
                                                  //         child: Padding(
                                                  //           padding: const EdgeInsets.only(bottom: 0, top: 11, left: 6, right: 6),
                                                  //           child: Row(
                                                  //             children: [
                                                  //               Icon(
                                                  //                 // Icons.mode_comment_outlined,
                                                  //                 Icons.sms_outlined,
                                                  //                 color: Colors.grey[50],
                                                  //                 // color: Colors.blue[400],
                                                  //                 size: 15,
                                                  //               ),
                                                  //               SizedBox(width: 5,),
                                                  //               Text(
                                                  //                 // '320',
                                                  //                 // bookingPostCommentNumber.toString(),
                                                  //                   postProvider.comments!.length.toString(),
                                                  //                   overflow: TextOverflow.ellipsis,
                                                  //                   style: GoogleFonts.lato(
                                                  //                     fontWeight: FontWeight.w700,
                                                  //                     color: Colors.white,
                                                  //                     fontSize: 12,
                                                  //                   )
                                                  //               )
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  Positioned(
                                                    right: 5,
                                                    // top: 50,
                                                    child: InkWell(
                                                      // onTap: (){
                                                      //   Navigator.push(
                                                      //       context,
                                                      //       PageTransition(
                                                      //         duration: const Duration(
                                                      //             milliseconds: 500
                                                      //         ),
                                                      //         alignment: Alignment.center,
                                                      //         type: PageTransitionType.fade,
                                                      //         child: PostFullScreen(
                                                      //           businessPost: homeBusinessPostList[i],
                                                      //           isNetworkLoaded: false,
                                                      //         ),
                                                      //       )
                                                      //   );
                                                      // },
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          top: MediaQuery.of(context).size.height * .07,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(5),
                                                          child: BackdropFilter(
                                                            filter: ImageFilter.blur(
                                                                sigmaY: 30,
                                                                sigmaX: 30
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(top: 5, bottom: 15),
                                                              child: Container(
                                                                width: 45,
                                                                height: 120,
                                                                child: Column(
                                                                  children: [
                                                                    // InkWell(
                                                                    //   onTap: () {
                                                                    //     //print('isLikedPost');
                                                                    //     //print(isLikedPost);
                                                                    //     //print('review');
                                                                    //     //print('andare in una listview in cui ci sono tutte le recensioni di quella prestazione');
                                                                    //   },
                                                                    //   child: Padding(
                                                                    //     padding: const EdgeInsets.only(bottom: 11.0, top: 6, left: 6, right: 6),
                                                                    //     child: Column(
                                                                    //       children: [
                                                                    //         // Icon(
                                                                    //         //   Icons.star,
                                                                    //         //   // color: Colors.grey[50],
                                                                    //         //   color: Colors.yellow[500],
                                                                    //         //   size: 25,
                                                                    //         // ),
                                                                    //         // SizedBox(height: 5,),
                                                                    //         // Text(
                                                                    //         //     '€\n25,50',
                                                                    //         //     textAlign: TextAlign.center,
                                                                    //         //     // overflow: TextOverflow.ellipsis,
                                                                    //         //     style: GoogleFonts.roboto(
                                                                    //         //       fontWeight: FontWeight.w800,
                                                                    //         //       // color: Colors.grey[50],
                                                                    //         //       color: Colors.white,
                                                                    //         //       fontSize: 13,
                                                                    //         //     )
                                                                    //         // )
                                                                    //       ],
                                                                    //     ),
                                                                    //   ),
                                                                    // ),
                                                                    InkWell(
                                                                      // onTap: () async {
                                                                      // if (postProvider.isLikedPost){
                                                                      //   setState(() {
                                                                      //     /*await*/ postProvider.unlikeBusinessPost(
                                                                      //         homeBusinessPostList[i],
                                                                      //         userProvider!.user!
                                                                      //     );
                                                                      //   });
                                                                      // }
                                                                      // else{
                                                                      //   setState(() {
                                                                      //     /*await*/ postProvider.likeBusinessPost(
                                                                      //       // postProvider.postList[index].id,
                                                                      //         homeBusinessPostList[i],
                                                                      //         userProvider!.user!
                                                                      //     );
                                                                      //   });
                                                                      // }
                                                                      // },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
                                                                        child: Column(
                                                                          children: [
                                                                            Icon(
                                                                              // Icons.reply,
                                                                              isLiked ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                                                              color: isLiked ? Colors.red : Colors.grey[50],
                                                                              // color: Colors.red[500],
                                                                              // color: Colors.pink[300],
                                                                              size: 20,
                                                                            ),
                                                                            SizedBox(height: 5,),
                                                                            Text(
                                                                              // '27',
                                                                              //   userPostList[i].likes.length.toString(),
                                                                                postLikesCount.toString(),
                                                                                // post.likes.length.toString(),
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: GoogleFonts.lato(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                                                                  // color: Colors.red[500],
                                                                                  // color: Colors.pink[300],
                                                                                  fontSize: 12,
                                                                                )
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      // onTap: () {
                                                                      // Navigator.push(
                                                                      //     context,
                                                                      //     PageTransition(
                                                                      //       duration: const Duration(
                                                                      //           milliseconds: 500
                                                                      //       ),
                                                                      //       alignment: Alignment.center,
                                                                      //       type: PageTransitionType.fade,
                                                                      //       child: PostCommentsScreen(
                                                                      //           isSingleEventPost: false,
                                                                      //           myUser: userProvider!.user!,
                                                                      //           businessPost: homeBusinessPostList[i]
                                                                      //       ),
                                                                      //     )
                                                                      // );
                                                                      // },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
                                                                        child: Column(
                                                                          children: [
                                                                            Icon(
                                                                              // Icons.mode_comment_outlined,
                                                                              Icons.sms_outlined,
                                                                              color: Colors.grey[50],
                                                                              // color: Colors.blue[400],
                                                                              size: 20,
                                                                            ),
                                                                            SizedBox(height: 5,),
                                                                            Text(
                                                                              // '320',
                                                                              // bookingPostCommentNumber.toString(),
                                                                              //   postProvider.comments!.length.toString(),
                                                                              //   userPostList[i].comments.length.toString(),
                                                                                postCommentsCount.toString(),
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: GoogleFonts.lato(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: Colors.white,
                                                                                  fontSize: 12,
                                                                                )
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // child: Text(
                                                              //   // categories[i].name,
                                                              //   'category.name',
                                                              //   overflow: TextOverflow.ellipsis,
                                                              //   style: GoogleFonts.lato(
                                                              //     fontWeight: FontWeight.w700,
                                                              //     color: Colors.white,
                                                              //     fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Positioned(
                                                  //   bottom: 20.0,
                                                  //   left: 15.0,
                                                  //   // right: 10.0,
                                                  //   child: Column(
                                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                                  //     children: [
                                                  //       Container(
                                                  //         width: MediaQuery.of(context).size.width * 0.37,
                                                  //         child: Marquee(
                                                  //           child: Row(
                                                  //             mainAxisAlignment: MainAxisAlignment.start,
                                                  //             children: [
                                                  //               Visibility(
                                                  //                 // visible: item['prestazione_id'] != null,
                                                  //                 visible: post.prestazione!.id != null,
                                                  //                 child: InkWell(
                                                  //                   highlightColor: Colors.transparent,
                                                  //                   splashColor: Colors.transparent,
                                                  //                   onTap: (){
                                                  //                     Navigator.push(
                                                  //                       context,
                                                  //                       PageTransition(
                                                  //                           duration: const Duration(milliseconds: 500),
                                                  //                           alignment: Alignment.center,
                                                  //                           type: PageTransitionType.fade,
                                                  //                           child: PrestazioneSlotsScreen(
                                                  //                             // prestazione: Prestazione(
                                                  //                             //   id: item['prestazione_id'],
                                                  //                             //   duration: item['prestazione_duration'],
                                                  //                             //   image: item['prestazione_image'],
                                                  //                             //   price: item['prestazione_price']?.toDouble(),
                                                  //                             //   title: item['prestazione_title'],
                                                  //                             //   description: item['prestazione_description'] ?? '',
                                                  //                             //   // business_id: item['business_id'],
                                                  //                             //   business: Business(
                                                  //                             //     id: item['business_id'],
                                                  //                             //     name: item['business_name'],
                                                  //                             //     longitude: item['business_longitude'],
                                                  //                             //     latitude: item['business_latitude'],
                                                  //                             //     type_id: item['business_type_id'],
                                                  //                             //     // profile_image: e['business_image'],
                                                  //                             //     profile_image: item['business_profile_image'],
                                                  //                             //     description: item['business_description'],
                                                  //                             //     room_id: item['business_room_id'],
                                                  //                             //     address: item['business_address'],
                                                  //                             //     phone_number: item['business_phone_number'],
                                                  //                             //     max_contemporary_appointments: item['max_contemporary_appointments'],
                                                  //                             //     category: Category(
                                                  //                             //       id: item['category_id'],
                                                  //                             //       image: item['category_image'],
                                                  //                             //       name: item['category_name'],
                                                  //                             //     )
                                                  //                             //   ),
                                                  //                             // ),
                                                  //                             prestazione: post.prestazione,
                                                  //                           )
                                                  //                       ),
                                                  //                     );
                                                  //                   },
                                                  //                   child: Row(
                                                  //                     mainAxisAlignment: MainAxisAlignment.start,
                                                  //                     crossAxisAlignment: CrossAxisAlignment.center,
                                                  //                     children: [
                                                  //                       // // titleText,
                                                  //                       // // commentText,
                                                  //                       // // imageProfile,
                                                  //                       // Padding(
                                                  //                       //   padding: EdgeInsets.symmetric(horizontal: 5.0),
                                                  //                       //   child: ClipRRect(
                                                  //                       //     borderRadius: BorderRadius.circular(50),
                                                  //                       //     child: Image(
                                                  //                       //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                                  //                       //       image: CachedNetworkImageProvider(
                                                  //                       //         item['business_profile_image'],
                                                  //                       //         errorListener: () => SizedBox(),
                                                  //                       //       ),
                                                  //                       //       width: 41,
                                                  //                       //       height: 41,
                                                  //                       //       fit: BoxFit.cover,
                                                  //                       //     ),
                                                  //                       //   ),
                                                  //                       // ),
                                                  //                       // // SizedBox(height: 10,),
                                                  //                       // Padding(
                                                  //                       //   padding: const EdgeInsets.only(left: 2.0),
                                                  //                       //   child: Column(
                                                  //                       //     crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                       //     children: [
                                                  //                       //       // usernameText,
                                                  //                       //       Container(
                                                  //                       //         width: MediaQuery.of(context).size.width * 0.23,
                                                  //                       //         child: Text(
                                                  //                       //           item['business_name'] ?? '',
                                                  //                       //           maxLines: 1,
                                                  //                       //           style: TextStyle(
                                                  //                       //               color: Colors.yellow,
                                                  //                       //               fontWeight: FontWeight.w700,
                                                  //                       //               fontSize: 11
                                                  //                       //           ),
                                                  //                       //         ),
                                                  //                       //       ),
                                                  //                       //       Container(
                                                  //                       //         width: MediaQuery.of(context).size.width * 0.23,
                                                  //                       //         child: Text(
                                                  //                       //           item['prestazione_title'] ?? '',
                                                  //                       //           // item['business_address'] ?? '',
                                                  //                       //           maxLines: 1,
                                                  //                       //           style: TextStyle(
                                                  //                       //               color: Colors.white,
                                                  //                       //               fontWeight: FontWeight.w500,
                                                  //                       //               fontSize: 12
                                                  //                       //           ),
                                                  //                       //         ),
                                                  //                       //       ),
                                                  //                       //     ],
                                                  //                       //   ),
                                                  //                       // ),
                                                  //
                                                  //                       // SizedBox(width: 10,),
                                                  //
                                                  //                       // RotationTransition(
                                                  //                       //   turns: AlwaysStoppedAnimation(15 / 360),
                                                  //                       //   child: Container(
                                                  //                       //     width: 1,
                                                  //                       //     height: 30,
                                                  //                       //     color: Colors.white,
                                                  //                       //   ),
                                                  //                       // ),
                                                  //                       //
                                                  //                       // SizedBox(width: 15,),
                                                  //
                                                  //                       SizedBox(width: 5,),
                                                  //                       ClipRRect(
                                                  //                         borderRadius: BorderRadius.circular(8),
                                                  //                         child: FutureImage(
                                                  //                           // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                                  //                           // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                                                  //                           // item['prestazione_image'] != null && item['prestazione_image'] != ''
                                                  //                           //   ? item['prestazione_image']
                                                  //                           //   : item['business_profile_image'],
                                                  //                           post.prestazione!.image != null && post.prestazione!.image != ''
                                                  //                               ? post.prestazione!.image!
                                                  //                               : post.business!.profile_image!,
                                                  //                           width: 35,
                                                  //                           height: 35,
                                                  //                         ),
                                                  //                       ),
                                                  //                       SizedBox(width: 5,),
                                                  //                       Padding(
                                                  //                         padding: const EdgeInsets.only(left: 2.0),
                                                  //                         child: Column(
                                                  //                           crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                           children: [
                                                  //                             Container(
                                                  //                               // width: MediaQuery.of(context).size.width * 0.23,
                                                  //                               constraints: BoxConstraints(
                                                  //                                 /*minWidth: 100,*/
                                                  //                                 // maxWidth: MediaQuery.of(context).size.width * 0.23
                                                  //                               ),
                                                  //                               child: Padding(
                                                  //                                 padding: const EdgeInsets.only(left: .0, bottom: 2),
                                                  //                                 child: GradientText(
                                                  //                                   // item['prestazione_title'] ?? item['category_name'],
                                                  //                                   post.prestazione!.title ?? post.business!.category!.name!,
                                                  //                                   shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  //                                   overflow: TextOverflow.ellipsis,
                                                  //                                   maxLines: 1,
                                                  //                                   // gradient: Gradients.haze,
                                                  //                                   style: TextStyle(
                                                  //                                       fontSize: 13,
                                                  //                                       fontWeight: FontWeight.w600
                                                  //                                   ),
                                                  //                                   textAlign: TextAlign.center,
                                                  //                                 ),
                                                  //                               ),
                                                  //                             ),
                                                  //                             Padding(
                                                  //                               padding: const EdgeInsets.only(left: 2),
                                                  //                               child: Text(
                                                  //                                 // item['business_name'] ?? '',
                                                  //                                 // item['prestazione_price']?.toDouble().toString() != null ? "€ " : '',
                                                  //                                 // "${int.tryParse(item['prestazione_duration'].toString()).toString()} min",
                                                  //                                 // "${int.tryParse(item.prestazione!.duration.toString()).toString()} min",
                                                  //                                 post.business!.name ?? '',
                                                  //                                 // ? "${item['prestazione_duration'].toInt().toString()} min"
                                                  //                                 // : '',
                                                  //                                 // item['prestazione_title'] ?? '',
                                                  //                                 maxLines: 1,
                                                  //                                 overflow: TextOverflow.ellipsis,
                                                  //                                 style: TextStyle(
                                                  //                                   // color: Colors.white,
                                                  //                                     color: Colors.yellow[700],
                                                  //                                     fontWeight: FontWeight.w500,
                                                  //                                     fontSize: 12
                                                  //                                 ),
                                                  //                               ),
                                                  //                             ),
                                                  //                           ],
                                                  //                         ),
                                                  //                       ),
                                                  //                     ],
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               SizedBox(width: 15,),
                                                  //               Visibility(
                                                  //                 // visible: item['user_id'] != null,
                                                  //                 visible: post.user!.id != null,
                                                  //                 child: RotationTransition(
                                                  //                   turns: AlwaysStoppedAnimation(15 / 360),
                                                  //                   child: Container(
                                                  //                     width: 1,
                                                  //                     height: 30,
                                                  //                     color: Colors.white,
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               SizedBox(width: 15,),
                                                  //               Visibility(
                                                  //                 // visible: item['user_id'] != null,
                                                  //                 visible: post.user!.id != null,
                                                  //                 child: InkWell(
                                                  //                   highlightColor: Colors.transparent,
                                                  //                   splashColor: Colors.transparent,
                                                  //                   onTap: (){
                                                  //                     Navigator.push(
                                                  //                       context,
                                                  //                       PageTransition(
                                                  //                           duration: const Duration(milliseconds: 500),
                                                  //                           alignment: Alignment.center,
                                                  //                           type: PageTransitionType.fade,
                                                  //                           child: UserProfileScreen(
                                                  //                             // user: User(
                                                  //                             //   id: item['user_id'],
                                                  //                             //   email: item['user_email'],
                                                  //                             //   username: item['user_username'],
                                                  //                             //   name: item['user_name'],
                                                  //                             //   phone_number: item['user_phone_number'],
                                                  //                             //   profile_image: item['user_profile_image'],
                                                  //                             //   description: item['user_description'],
                                                  //                             // ),
                                                  //                             // userId: item.user!.id!,
                                                  //                             user: post.user!,
                                                  //                             isTab: false,
                                                  //                           )
                                                  //                       ),
                                                  //                     );
                                                  //                   },
                                                  //                   child: Row(
                                                  //                     mainAxisAlignment: MainAxisAlignment.start,
                                                  //                     children: [
                                                  //                       Padding(
                                                  //                         padding: EdgeInsets.symmetric(horizontal: 5.0),
                                                  //                         child: ClipRRect(
                                                  //                           borderRadius: BorderRadius.circular(50),
                                                  //                           child: FutureImage(
                                                  //                             // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postProvider.postList[i]['profile_image']),
                                                  //                             // item['user_profile_image'] ?? '',
                                                  //                             post.user!.profile_image ?? '',
                                                  //                             width: 37,
                                                  //                             height: 37,
                                                  //                           ),
                                                  //                         ),
                                                  //                       ),
                                                  //                       // SizedBox(height: 10,),
                                                  //                       Padding(
                                                  //                         padding: const EdgeInsets.only(left: 2.0),
                                                  //                         child: Column(
                                                  //                           crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                           children: [
                                                  //                             // usernameText,
                                                  //                             Container(
                                                  //                               // width: MediaQuery.of(context).size.width * 0.23,
                                                  //                               constraints: BoxConstraints(
                                                  //                                 /*minWidth: 100,*/
                                                  //                                 // maxWidth: MediaQuery.of(context).size.width * 0.2
                                                  //                               ),
                                                  //                               child: Text(
                                                  //                                 // item['user_username'] != null ? "@${item['user_username']}" : '',
                                                  //                                 post.user!.username != null ? "@${post.user!.username}" : '',
                                                  //                                 maxLines: 1,
                                                  //                                 overflow: TextOverflow.ellipsis,
                                                  //                                 style: TextStyle(
                                                  //                                     color: Colors.yellow,
                                                  //                                     fontWeight: FontWeight.w700,
                                                  //                                     fontSize: 11
                                                  //                                 ),
                                                  //                               ),
                                                  //                             ),
                                                  //                             SizedBox(height: 2,),
                                                  //                             Container(
                                                  //                               // width: MediaQuery.of(context).size.width * 0.23,
                                                  //                               constraints: BoxConstraints(
                                                  //                                 /*minWidth: 100,*/
                                                  //                                 // maxWidth: MediaQuery.of(context).size.width * 0.22
                                                  //                               ),
                                                  //                               child: Text(
                                                  //                                 // item['user_name'] ?? '',
                                                  //                                 post.user!.name ?? '',
                                                  //                                 maxLines: 1,
                                                  //                                 overflow: TextOverflow.ellipsis,
                                                  //                                 style: TextStyle(
                                                  //                                     color: Colors.white,
                                                  //                                     fontWeight: FontWeight.w500,
                                                  //                                     fontSize: 12
                                                  //                                 ),
                                                  //                               ),
                                                  //                             ),
                                                  //                           ],
                                                  //                         ),
                                                  //                       ),
                                                  //                       SizedBox(width: 10,),
                                                  //                     ],
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //       Container(
                                                  //         width: MediaQuery.of(context).size.width * 0.37,
                                                  //         margin: EdgeInsets.only(top: 10, left: 5),
                                                  //         // child: Text(
                                                  //         //   "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                                  //         //   style: TextStyle(
                                                  //         //       color: Colors.white,
                                                  //         //       fontWeight: FontWeight.w500,
                                                  //         //       fontSize: 13.5
                                                  //         //   ),
                                                  //         // ),
                                                  //         child: Text(
                                                  //           // "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                                  //           // "Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy.",
                                                  //           // '',
                                                  //           // item['post_description'] ?? '',
                                                  //           post.description ?? '',
                                                  //           overflow: TextOverflow.ellipsis,
                                                  //           maxLines: 3,
                                                  //           textAlign: TextAlign.start,
                                                  //           // collapseText: 'nascondi',
                                                  //           // expandText: 'mostra',
                                                  //           style: TextStyle(
                                                  //               color: Colors.white,
                                                  //               fontWeight: FontWeight.w500,
                                                  //               fontSize: 11.5
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //       SizedBox(height: 10,),
                                                  //       Padding(
                                                  //         padding: const EdgeInsets.only(left: 5.0),
                                                  //         child: Container(
                                                  //           width: MediaQuery.of(context).size.width * 0.77,
                                                  //           child: Row(
                                                  //             // mainAxisAlignment: MainAxisAlignment.end,
                                                  //             children: [
                                                  //               // Spacer(),
                                                  //               Text(
                                                  //                 // '15:32 15 Settembre 2022',
                                                  //                 // DateFormat.yMMMMd('it_IT').format(DateTime.parse(item['post_created_at'])).toString()
                                                  //                 //     + ' alle ' + item['post_created_at'].substring(11, 16),
                                                  //                 DateFormat.yMMMMd('it_IT').format(post.created_at!).toString()
                                                  //                     + ' alle ' + post.created_at!.toString().substring(11, 16),
                                                  //                 style: TextStyle(
                                                  //                     color: Colors.grey[200],
                                                  //                     fontWeight: FontWeight.w500,
                                                  //                     fontSize: 10
                                                  //                 ),
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  Positioned(
                                                    bottom: 15,
                                                    left: 0,
                                                    right: 0,
                                                    // width: MediaQuery.of(context).size.width * 0.34,
                                                    child: Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Marquee(
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                    child: FutureImage(
                                                                      post.user!.profile_image ?? '',
                                                                      // post.booking!.user.profile_image ?? '',
                                                                      width: 25,
                                                                      height: 25,
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 5,),
                                                                  GradientText(
                                                                    // post.business!.name ?? '',
                                                                    // '@' + post.user!.username! ?? '',
                                                                    post.user!.name ?? '',
                                                                    // post.booking!.user.name ?? '',
                                                                    // 'A partire da € 60,00',
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                    // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                    gradient: LinearGradient(
                                                                        begin: Alignment.bottomLeft,
                                                                        end: Alignment.topRight,
                                                                        colors: [
                                                                          // Color(0xff8921aa),
                                                                          // Color(0xffDA44bb),
                                                                          // Colors.pinkAccent
                                                                          Colors.white,
                                                                          Colors.white,
                                                                          // Color(0xffDA44bb)
                                                                          // Color(0xfffd746c),
                                                                          // Color(0xffff9068),
                                                                        ]
                                                                    ),
                                                                    // gradient: LinearGradient(
                                                                    //     begin: Alignment.bottomLeft,
                                                                    //     end: Alignment.topRight,
                                                                    //     colors: [
                                                                    //       Colors.blue[500],
                                                                    //       Color(0xffDA44bb),
                                                                    //
                                                                    //       Color(0xff8921aa),
                                                                    //     ]
                                                                    // ),
                                                                    style: TextStyle(
                                                                        color: Colors.blue[500],
                                                                        fontWeight: FontWeight.w700,
                                                                        fontSize: 13
                                                                    ),
                                                                    textAlign: TextAlign.left,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            Marquee(
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                    child: FutureImage(
                                                                      // post.prestazione!.image ?? '',
                                                                      post.prestazione!.image != null && post.prestazione!.image != ''
                                                                          ? post.prestazione!.image!
                                                                          : post.business!.profile_image!,
                                                                      width: 30,
                                                                      height: 30,
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8,),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      GradientText(
                                                                        // post.business!.name ?? '',
                                                                        // post.booking!.prestazione!.title ?? '',
                                                                        post.prestazione!.title ?? '',
                                                                        // 'A partire da € 60,00',
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                        // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                        gradient: LinearGradient(
                                                                            begin: Alignment.bottomLeft,
                                                                            end: Alignment.topRight,
                                                                            colors: [
                                                                              // Color(0xff8921aa),
                                                                              // Color(0xffDA44bb),
                                                                              // Color(0xffDA44bb)
                                                                              // Color(0xfffd746c),
                                                                              // Color(0xffff9068),
                                                                              // Colors.yellow,
                                                                              Colors.yellow[600]!,
                                                                              Color(0xffFFA818),
                                                                              // Color(0xffF68A3D),
                                                                            ]
                                                                        ),
                                                                        // gradient: LinearGradient(
                                                                        //     begin: Alignment.bottomLeft,
                                                                        //     end: Alignment.topRight,
                                                                        //     colors: [
                                                                        //       Colors.blue[500],
                                                                        //       Color(0xffDA44bb),
                                                                        //
                                                                        //       Color(0xff8921aa),
                                                                        //     ]
                                                                        // ),
                                                                        style: TextStyle(
                                                                            color: Colors.blue[500],
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: 13
                                                                        ),
                                                                        textAlign: TextAlign.left,
                                                                      ),
                                                                      SizedBox(height: 2,),
                                                                      GradientText(
                                                                        // post.business!.name ?? '',
                                                                        // post.booking!.prestazione!.title ?? '',
                                                                        post.business!.name ?? '',
                                                                        // 'A partire da € 60,00',
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                        // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                        gradient: Gradients. hotLinear,
                                                                        // gradient: LinearGradient(
                                                                        //     begin: Alignment.bottomLeft,
                                                                        //     end: Alignment.topRight,
                                                                        //     colors: [
                                                                        //       // Color(0xff8921aa),
                                                                        //       // Color(0xffDA44bb),
                                                                        //       // Color(0xffDA44bb)
                                                                        //       // Color(0xfffd746c),
                                                                        //       // Color(0xffff9068),
                                                                        //       Colors.yellow,
                                                                        //       Colors.yellow,
                                                                        //     ]
                                                                        // ),
                                                                        // gradient: LinearGradient(
                                                                        //     begin: Alignment.bottomLeft,
                                                                        //     end: Alignment.topRight,
                                                                        //     colors: [
                                                                        //       Colors.blue[500],
                                                                        //       Color(0xffDA44bb),
                                                                        //
                                                                        //       Color(0xff8921aa),
                                                                        //     ]
                                                                        // ),
                                                                        style: TextStyle(
                                                                            color: Colors.blue[500],
                                                                            fontWeight: FontWeight.w700,
                                                                            fontSize: 13
                                                                        ),
                                                                        textAlign: TextAlign.left,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                                            Visibility(
                                                              visible: post.description != null,
                                                              child: Container(
                                                                width: MediaQuery.of(context).size.width * .4,
                                                                child: GradientText(
                                                                  post.description ?? '',
                                                                  maxLines: 3,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                  gradient: Gradients.haze,
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.w700,
                                                                      fontSize: 11
                                                                  ),
                                                                  textAlign: TextAlign.left,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                                            Container(
                                                              // width: MediaQuery.of(context).size.width * .3,
                                                              child: Marquee(
                                                                child: Text(
                                                                  // post.created_at!,
                                                                  DateFormat.yMMMd('it_IT').format(post.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                                      + ' alle ' + post.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors.grey[200],
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 11
                                                                  ),
                                                                  textAlign: TextAlign.left,
                                                                ),
                                                              ),
                                                            ),
                                                            // item.is_single_event && item.single_event.begin_at != null
                                                            //     ? GradientText(
                                                            //   DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                                            //   maxLines: 2,
                                                            //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                            //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                            //   // gradient: Gradients.backToFuture,
                                                            //   gradient: Gradients.blush,
                                                            //   // gradient: LinearGradient(
                                                            //   //     begin: Alignment.bottomLeft,
                                                            //   //     end: Alignment.topRight,
                                                            //   //     colors: [
                                                            //   //       Color(0xff8921aa),
                                                            //   //       Color(0xffDA44bb),
                                                            //   //       // Color(0xffDA44bb)
                                                            //   //     ]
                                                            //   // ),
                                                            //   // gradient: LinearGradient(
                                                            //   //     begin: Alignment.bottomLeft,
                                                            //   //     end: Alignment.topRight,
                                                            //   //     colors: [
                                                            //   //       Color(0xff8921aa),
                                                            //   //       Color(0xffDA44bb),
                                                            //   //       // Color(0xffDA44bb)
                                                            //   //     ]
                                                            //   // ),
                                                            //
                                                            //   style: TextStyle(
                                                            //       color: Colors.blue,
                                                            //       fontWeight: FontWeight.w800,
                                                            //       fontSize: 16
                                                            //   ),
                                                            //   textAlign: TextAlign.left,
                                                            // )
                                                            //     : SizedBox(height: 0, width: 0,),
                                                            // SizedBox(height: 1,),
                                                            // GradientText(
                                                            //   // item.is_single_event && item.single_event.title != null
                                                            //   //     ? item.single_event.title
                                                            //   //     : item.prestazione.title != null
                                                            //   //     ? item.prestazione.title : '',
                                                            //   item.is_single_event
                                                            //       ? 'A partire da € 15,00'/* + NumberFormat.currency(
                                                            //                         // customPattern: '#,##',
                                                            //                           decimalDigits: 2,
                                                            //                           symbol: '',
                                                            //                           locale: 'IT_it'
                                                            //                       ).format(item.single_event.)*/
                                                            //       : 'Al prezzo di € ' + NumberFormat.currency(
                                                            //     // customPattern: '#,##',
                                                            //       decimalDigits: 2,
                                                            //       symbol: '',
                                                            //       locale: 'IT_it'
                                                            //   ).format(item.prestazione.price),
                                                            //   maxLines: 2,
                                                            //
                                                            //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                            //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                            //   // gradient: Gradients.backToFuture,
                                                            //   gradient: !item.is_single_event
                                                            //       ? Gradients.blush
                                                            //       : LinearGradient(
                                                            //       begin: Alignment.bottomLeft,
                                                            //       end: Alignment.topRight,
                                                            //       colors: [
                                                            //         Color(0xff8921aa),
                                                            //         Color(0xffDA44bb),
                                                            //         // Color(0xffDA44bb)
                                                            //       ]
                                                            //   ),
                                                            //   style: TextStyle(
                                                            //       color: Colors.blue,
                                                            //       fontWeight: FontWeight.w800,
                                                            //       fontSize: 15
                                                            //   ),
                                                            //   textAlign: TextAlign.left,
                                                            // ),
                                                            // Text(
                                                            //   'A partire da € 60,00',
                                                            //   style: new TextStyle(
                                                            //       fontWeight: FontWeight.w800,
                                                            //       fontSize: 15,
                                                            //
                                                            //       foreground: Paint()..shader = LinearGradient(
                                                            //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                                            //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                                            // )
                                                            // LinearGradient(
                                                            //   begin: Alignment.topLeft,
                                                            //   end: Alignment.bottomRight,
                                                            //   colors: gradientColors,
                                                            // ).createShader(
                                                            //     Rect.fromCircle(
                                                            //       center: Offset(fontSize, -200),
                                                            //       radius: fontSize / 3,
                                                            //     )
                                                            // );
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                      
                                    postProvider.businessProfileUsersList.isEmpty ? ListView(
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                        Center(
                                          child: Image.asset(
                                            'assets/png/Saly-16.png',
                                            height: MediaQuery.of(context).size.height * .2,
                                            // width: MediaQuery.of(context).size.width * .7,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                        Center(
                                          child: Text(
                                            "Non ci sono ancora clienti",
                                            // 'Le mie prestazioni',
                                            style: TextStyle(
                                              // color: Colors.blue,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : GridView.builder(
                                        padding: EdgeInsets.all(2),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio: 1,
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 2,
                                            mainAxisSpacing: 2
                                        ),
                                        // itemCount: 40,
                                        // itemCount: myAppointmentsList.length,
                                        itemCount: postProvider.businessProfileUsersList.length,
                                        itemBuilder: (context, i) {
                                          // SingleEventReservation singleEventReservation = new SingleEventReservation(
                                          //   // id: postProvider.posts[i]['post_id'].toInt(),
                                          //   id: postProvider.posts[i]['post_id'],
                                          //   description: postProvider.posts[i]['post_description'],
                                          //   bookingTime: DateTime.parse(postProvider.posts[i]['post_created_at']),
                                          //   // exhibition_id: int.parse(postProvider.posts[i]['exhibition_id']),
                                          //   image_video: postProvider.posts[i]['image_video'],
                                          //   // user_id: int.parse(postProvider.posts[i]['user_id']),
                                          //   user_id: postProvider.posts[i]['user_id'].toInt(),
                                          //   title: postProvider.posts[i]['post_title'],
                                          // );
                                          // return Image.asset(
                                          //   'assets/sample/search_demo1.jpg',
                                          //   fit: BoxFit.cover,
                                          // );
                      
                                          return InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      duration: const Duration(milliseconds: 500),
                                                      alignment: Alignment.center,
                                                      type: PageTransitionType.fade,
                                                      child: UserProfileScreen(
                                                        isTab: false,
                                                        user: postProvider.businessProfileUsersList[i],
                                                      )
                                                  )
                                              );
                                            },
                                            child: Card(
                                              margin: EdgeInsets.all(2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              elevation: 8,
                                              child: Stack(
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                fit: StackFit.expand,
                                                children: [
                                                  postProvider.businessProfileUsersList[i].profile_image != null && postProvider.businessProfileUsersList[i].profile_image != '' ? FutureImage(
                                                    postProvider.businessProfileUsersList[i].profile_image ?? '',
                                                    width: MediaQuery.of(context).size.width,
                                                  ) : Image.asset(
                                                    // Icons.account_circle_rounded,
                                                    // 'assets/image/default-profile-account-unknown.jpg',
                                                    'assets/image/default-avatar-profile-icon.jpg',
                                                    // color: Colors.grey[700],
                                                    width: MediaQuery.of(context).size.width,
                                                    fit: BoxFit.cover,
                                                    // size: 45,
                                                  ),
                                                  const DecoratedBox(
                                                    decoration: BoxDecoration(
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
                                                  Positioned(
                                                    bottom: 15,
                                                    left: 15,
                                                    width: MediaQuery.of(context).size.width * 0.22,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        /*Gradient*/Text(
                                                          postProvider.businessProfileUsersList[i].name ?? '',
                                                          // 'A partire da € 60,00',
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                          // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                          // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                          // gradient: LinearGradient(
                                                          //     begin: Alignment.bottomLeft,
                                                          //     end: Alignment.topRight,
                                                          //     colors: [
                                                          //       Color(0xff8921aa),
                                                          //       Color(0xffDA44bb),
                                                          //       // Color(0xffDA44bb)
                                                          //     ]
                                                          // ),
                                                          // gradient: Gradients.haze,
                                                          // gradient: LinearGradient(
                                                          //     begin: Alignment.bottomLeft,
                                                          //     end: Alignment.topRight,
                                                          //     colors: [
                                                          //       // Colors.blue[500],
                                                          //       // Color(0xffDA44bb),
                                                          //       //
                                                          //       // Color(0xff8921aa),
                                                          //       Color(0xffFFA818),
                                                          //       Color(0xffFFB75E),
                                                          //     ]
                                                          // ),
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 13
                                                          ),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                        // SizedBox(height: 2,),
                                                        // Container(
                                                        //   width: MediaQuery.of(context).size.width * .25,
                                                        //   child: /*Gradient*/Text(
                                                        //     "${postProvider.businessProfileUsersList[i].username}" ?? '',
                                                        //     maxLines: 2,
                                                        //     // overflow: TextOverflow.ellipsis,
                                                        //     // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        //     // gradient: Gradients.haze,
                                                        //     // gradient: LinearGradient(colors: [
                                                        //     //   Color(0xffFFA818),
                                                        //     //   Color(0xffFFB75E),
                                                        //     // ]),
                                                        //     style: TextStyle(
                                                        //         color: Colors.white,
                                                        //         fontWeight: FontWeight.w700,
                                                        //         fontSize: 12
                                                        //     ),
                                                        //     textAlign: TextAlign.left,
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                      
                                    /*GridView.builder(
                                        padding: EdgeInsets.all(2),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 2,
                                            mainAxisSpacing: 2
                                        ),
                                        itemCount: 40,
                                        itemBuilder: (context, index) {
                                          return Image.asset('assets/sample/search_demo1.jpg', fit: BoxFit.cover,);
                                        }
                                    ),*/
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
              ),
            );
          // }
          // else {
          //   return SizedBox();
          // }
        }
      )
    );
  }

}
