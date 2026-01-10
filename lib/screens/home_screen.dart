import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/recommended.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/business_provider.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/post_full_screen.dart';
import 'package:nurebo/screens/post_comments_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/screens/business_category_list_screen.dart';
import 'package:nurebo/screens/splash_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
// import 'package:nurebo/screens/guest_user_profile_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


// @pragma('vm:entry-point')
Future<User?> getUser() async {
  await UserPreferences.init();

  var url = Uri.parse("${Utils.httpServerUrl}user/${UserPreferences.getUserId()}");

  // Map<String, dynamic> body = {
  //   'id': UserPreferences.getUserId(),
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
  ).timeout(const Duration(seconds: 10));

  if(response.statusCode >= 520 && response.statusCode <= 530) {
    isServerDown = true;
  }
  if(response.statusCode >= 200 && response.statusCode < 400) {
    var jsonData = json.decode(response.body);

    User user = User(
      id: jsonData[0]['id'],
      description: jsonData[0]['description'],
      profile_image: jsonData[0]['profile_image'],
      first_name: jsonData[0]['first_name'],
      name: jsonData[0]['name'],
      username: jsonData[0]['username'],
      phone: jsonData[0]['phone'],
      email: jsonData[0]['email'],
      email_notification: jsonData[0]['email_notification'],
      longitude: jsonData[0]['longitude']?.toDouble(),
      latitude: jsonData[0]['latitude']?.toDouble(),
    );

    Utils.user = user;

    return user;
    // return jsonData;
  }

  return null;
}

class HomeScreen extends StatefulWidget {
  // final User user;

  const HomeScreen({super.key, /*this.user*/});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  late ScrollController _scrollController;
  List singleEventList = [];
  List recommendedSingleEventList = [];
  List categoryList = [];
  List<BusinessPost> homeBusinessPostList = [];
  List<Recommended> recommendedList = [];
  UserProvider? userProvider;
  late SocketProvider socketProvider;
  PrestazioneFavoriteProvider? favoriteProvider;
  BusinessFavoriteProvider? businessFavoriteProvider;
  BusinessProvider? businessProvider;
  late GeolocationProvider geolocationProvider;
  late PostProvider postProvider;
  DateTime? currentBackPressTime;
  Future a = Future(() {},), b = Future(() {},), c = Future(() {},), d = Future(() {},), e = Future(() {},), f = Future(() {},), all = Future(() {},);
  List<Prestazione> bestsellersList = [];
  final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  final completer0 = Completer<dynamic>(), completer1 = Completer<dynamic>(), completer2 = Completer<dynamic>(), completer3 = Completer<dynamic>(), completer4 = Completer<dynamic>();
  int imagesAddedToCache = 0;
  int completerCompleted = 0;


  // int pageNum = 0;
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};
  // Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  //   return <String, dynamic>{
  //     'version.securityPatch': build.version.securityPatch,
  //     'version.sdkInt': build.version.sdkInt,
  //     'version.release': build.version.release,
  //     'version.previewSdkInt': build.version.previewSdkInt,
  //     'version.incremental': build.version.incremental,
  //     'version.codename': build.version.codename,
  //     'version.baseOS': build.version.baseOS,
  //     'board': build.board,
  //     'bootloader': build.bootloader,
  //     'brand': build.brand,
  //     'device': build.device,
  //     'display': build.display,
  //     'fingerprint': build.fingerprint,
  //     'hardware': build.hardware,
  //     'host': build.host,
  //     'id': build.id,
  //     'manufacturer': build.manufacturer,
  //     'model': build.model,
  //     'product': build.product,
  //     'supported32BitAbis': build.supported32BitAbis,
  //     'supported64BitAbis': build.supported64BitAbis,
  //     'supportedAbis': build.supportedAbis,
  //     'tags': build.tags,
  //     'type': build.type,
  //     'isPhysicalDevice': build.isPhysicalDevice,
  //     'systemFeatures': build.systemFeatures,
  //   };
  // }
  // Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  //   return <String, dynamic>{
  //     'name': data.name,
  //     'systemName': data.systemName,
  //     'systemVersion': data.systemVersion,
  //     'model': data.model,
  //     'localizedModel': data.localizedModel,
  //     'identifierForVendor': data.identifierForVendor,
  //     'isPhysicalDevice': data.isPhysicalDevice,
  //     'utsname.sysname:': data.utsname.sysname,
  //     'utsname.nodename:': data.utsname.nodename,
  //     'utsname.release:': data.utsname.release,
  //     'utsname.version:': data.utsname.version,
  //     'utsname.machine:': data.utsname.machine,
  //   };
  // }
  // Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  //   return <String, dynamic>{
  //     'numberOfCores': data.numberOfCores,
  //     'computerName': data.computerName,
  //     'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
  //   };
  // }
  //
  //
  // Future<void> initPlatformState() async {
  //   var deviceData = <String, dynamic>{};
  //
  //   try {
  //     if (foundation.kIsWeb) {
  //       // deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
  //     } else {
  //       if (Platform.isAndroid) {
  //         deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
  //       } else if (Platform.isIOS) {
  //         deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
  //       } else if (Platform.isLinux) {
  //         // deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
  //       } else if (Platform.isMacOS) {
  //         // deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
  //       } else if (Platform.isWindows) {
  //         deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
  //       }
  //     }
  //   } on PlatformException {
  //     deviceData = <String, dynamic>{
  //       'Error:': 'Failed to get platform version.'
  //     };
  //   }
  //
  //   //print('deviceData');
  //   //print(deviceData);
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _deviceData = deviceData;
  //   });
  // }

  static void fetchBestsellersIsolate(SendPort sendPort) async {
    // const url = "https://api.nurebo.com/business/post";
    var url = "${Utils.httpServerUrl}prestazione/bestsellers";
    List<Prestazione> bestsellersList0 = [];

    try {
      final response = await http.get(
          Uri.parse(url),
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

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final responseBody = response.body;
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
                description: e['business_description'],
                address: e['business_address'],
                room_id: e['business_room_id'],
                phone: e['business_phone'],
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
          bestsellersList0.add(bestseller);
          // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestseller.image}');
          // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestseller.business!.profile_image}');
        }
        // Invia la risposta all'isolate principale tramite il SendPort
        // sendPort.send(responseBody);
        sendPort.send(bestsellersList0);
      } else {
        // La chiamata HTTP ha restituito uno stato diverso da 200
        // print('Errore durante la chiamata HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Si è verificato un errore durante la chiamata HTTP
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  void fetchBestsellers() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(fetchBestsellersIsolate, receivePort.sendPort);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      bestsellersList = message;

      for(var e in bestsellersList) {
        // setState(() async {
        await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.image}');
        await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.business!.profile_image}');
        // });
      }

      // print('imageCacheBusiness.imageCache.keys0');
      // print(imageCacheBusiness.imageCache.keys.length);

      completer0.complete(message);
    });
  }

  // Future getBestsellers() async {
  //   var url = Uri.parse("${Utils.httpServerUrl}prestazione/bestsellers");
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
  //   // //print("response.statusCode");
  //   // //print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // //print('jsonData65dc5c5c5');
  //     // //print(jsonData);
  //     for(var e in /*recommendedPrestazioneList*/jsonData){
  //       Prestazione bestseller =  Prestazione(
  //         id: e['prestazione_id'],
  //         business: Business(
  //             id: e['business_id'],
  //             name: e['business_name'],
  //             latitude: e['business_latitude'],
  //             longitude: e['business_longitude'],
  //             business_type_id: 1,
  //             profile_image: e['business_profile_image'],
  //             description: e['business_description'],
  //             address: e['business_address'],
  //             phone_number: e['business_phone_number'],
  //             max_contemporary_appointments: e['max_contemporary_appointments'],
  //             email: e['business_email'],
  //             // category_id: e['category_id'],
  //             category: Category(
  //               id: e['category_id'],
  //               name: e['category_name'],
  //               image: e['category_image'],
  //             )
  //         ),
  //         is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //         image: e['prestazione_image'],
  //         duration: e['prestazione_duration'],
  //         title: e['prestazione_title'],
  //         description: e['prestazione_description'],
  //         // last_modification_at: DateTime.parse(e['prestazione_last_modification_at']),
  //         created_at: DateTime.parse(e['prestazione_created_at']),
  //         // business_id: e['business_id'],
  //       );
  //       bestsellersList.add(bestseller);
  //     }
  //
  //     for(var e in bestsellersList) {
  //       print('e.title');
  //       print(e.title);
  //       await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.image}');
  //       await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.business!.profile_image}');
  //     }
  //     // //print('bestsellers.length');
  //     // //print(bestsellersList.length);
  //     // setState(() {
  //     //   // tickets = jsonData;
  //     //   for(var i = 0; i < jsonData.length; i++){
  //     //     // tickets.add(jsonData[i]['id']);
  //     //     tickets.add(jsonData[i]);
  //     //   }
  //     // });
  //
  //     return jsonData;
  //   }
  // }

  static void fetchRecommendedIsolate(SendPort sendPort) async {
    // const url = "https://api.nurebo.com/business/post";
    var url = "${Utils.httpServerUrl}prestazione/recommended";
    List<Recommended> recommendedList0 = [];

    try {
      final response = await http.get(
          Uri.parse(url),
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

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final responseBody = response.body;
        var jsonData = json.decode(responseBody);

        for(var e in /*recommendedPrestazioneList*/jsonData){
          Recommended recommended = Recommended(
            id: e['recommended_id'],
            // is_single_event: false,
            // single_event_list: ,
            // created_at: DateTime.parse(e['recommended_created_at']),
            prestazione: Prestazione(
              id: e['prestazione_id'],
              isValid: e['prestazione_is_valid'],
              business: Business(
                  id: e['business_id'],
                  name: e['business_name'],
                  latitude: e['business_latitude'],
                  longitude: e['business_longitude'],
                  type_id: 1,
                  room_id: e['business_room_id'],
                  profile_image: e['business_profile_image'],
                  description: e['business_description'],
                  address: e['business_address'],
                  phone: e['business_phone'],
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
              description: e['prestazione_description'] ?? '',
              // last_modification_at: DateTime.parse(e['prestazione_last_modification_at']),
              created_at: DateTime.parse(e['prestazione_created_at']),
              // business_id: e['business_id'],
            ),
            // created_at: null,
          );
          // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${recommended.prestazione.image}');
          recommendedList0.add(recommended);
        }

        // Invia la risposta all'isolate principale tramite il SendPort
        // sendPort.send(responseBody);
        sendPort.send(recommendedList0);
      } else {
        // La chiamata HTTP ha restituito uno stato diverso da 200
        // print('Errore durante la chiamata HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Si è verificato un errore durante la chiamata HTTP
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  void fetchRecommended() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(fetchRecommendedIsolate, receivePort.sendPort);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      // if (message is String) {
      // final data = json.decode(message);
      // var jsonData = json.decode(message);

      // setState(() {
      //   recommendedList = data.toString();
      recommendedList = message;
      // });
      // }
      for(var e in recommendedList){
        // setState(() async {
        await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.prestazione.image}');
        // });
      }

      // print('imageCacheBusiness.imageCache.keys1');
      // print(imageCacheBusiness.imageCache.keys.length);

      completer1.complete(message);
    });
  }

  // Future getAllRecommendedPrestazione() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione/recommended");
  //
  //   // Map<String, dynamic> body = {
  //   //   "user_id": userId,
  //   // };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // //print('iiiiiiiiii');
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   categoryList.addAll(jsonData);
  //     // recommendedPrestazioneList = jsonData;
  //     // });
  //
  //     // //print('recommendedssssssssss');
  //     // //print(jsonData);
  //
  //     // for(int j = 0; j < recommendedPrestazioneList.length; j++){
  //     for(var e in /*recommendedPrestazioneList*/jsonData){
  //       Recommended recommended = Recommended(
  //         id: e['recommended_id'],
  //         // is_single_event: false,
  //         // single_event_list: ,
  //         // created_at: DateTime.parse(e['recommended_created_at']),
  //         prestazione: Prestazione(
  //           id: e['prestazione_id'],
  //           business: Business(
  //             id: e['business_id'],
  //             name: e['business_name'],
  //             latitude: e['business_latitude'],
  //             longitude: e['business_longitude'],
  //             business_type_id: 1,
  //             profile_image: e['business_profile_image'],
  //             description: e['business_description'],
  //             address: e['business_address'],
  //             phone_number: e['business_phone_number'],
  //             max_contemporary_appointments: e['max_contemporary_appointments'],
  //             email: e['business_email'],
  //             // category_id: e['category_id'],
  //             category: Category(
  //               id: e['category_id'],
  //               name: e['category_name'],
  //               image: e['category_image'],
  //             )
  //           ),
  //           is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                
  //               price: e['prestazione_price']?.toDouble(),
  //               price_min: e['prestazione_price_min']?.toDouble(),
  //               price_max: e['prestazione_price_max']?.toDouble(),
                
  //           image: e['prestazione_image'],
  //           duration: e['prestazione_duration'],
  //           title: e['prestazione_title'],
  //           description: e['prestazione_description'] ?? '',
  //           // last_modification_at: DateTime.parse(e['prestazione_last_modification_at']),
  //           created_at: DateTime.parse(e['prestazione_created_at']),
  //           // business_id: e['business_id'],
  //         ),
  //         // created_at: null,
  //       );
  //       recommendedList.add(recommended);
  //     }
  //
  //     for(var e in recommendedList){
  //       // setState(() async {
  //         await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e.prestazione.image}');
  //       // });
  //     }
  //
  //     return jsonData;
  //   }
  // }

  // Future getAllSingleEvent() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "single_event");
  //
  //   // Map<String, dynamic> body = {
  //   //   "id": widget.user.id
  //   // };
  //
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
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
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
  //     // setState(() {
  //       singleEventList = jsonData;
  //     // });
  //     // //print("singleEventList:");
  //     // //print(singleEventList);
  //
  //     return jsonData;
  //   }
  // }

  static void fetchCategoriesIsolate(/*SendPort sendPort*/List<Object> arguments) async {
    SendPort sendPort = arguments[0] as SendPort;
    // print('arguments[1]');
    // print(arguments[1]);

    // const url = "https://api.nurebo.com/business/post";
    var url = "${Utils.httpServerUrl}category/business?is_valid=1&is_visible=1";

    try {
      final response = await http.get(
          Uri.parse(url),
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

      if (response.statusCode >= 200 && response.statusCode < 400) {
        // final responseBody = response.body;
        dynamic/*var*/ jsonData = json.decode(response.body);

        // print('jsonData558848');
        // print(jsonData);
        // jsonData!.sort((a, b) {
        //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
        // });
        jsonData!.sort((a, b) {
          return a['name'].toLowerCase().compareTo(b['name'].toLowerCase()) as int;
        });

        // Invia la risposta all'isolate principale tramite il SendPort
        sendPort.send(jsonData);
      } else {
        // La chiamata HTTP ha restituito uno stato diverso da 200
        // print('Errore durante la chiamata HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Si è verificato un errore durante la chiamata HTTP
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  void fetchCategories() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(fetchCategoriesIsolate, [receivePort.sendPort, 'fd45gx4ggx54g']);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      // setState(() {
      categoryList = message;
      // });

      // setState(() {
      //   categoryList!.addAll(message);
      // });

      // categoryList!.sort((a, b) {
      //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      // });
      for(var e in categoryList!){
        // setState(() async {
        await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e['image']}');
        // });
      }

      // print('imageCacheBusiness.imageCache.keys2');
      // print(imageCacheBusiness.imageCache.keys.length);

      completer2.complete(message);
    });
  }

  // Future getAllCategories() async {
  //   // var url = Uri.parse(Constants.serverUrl + "event_category/all");
  //   // var url = Uri.parse(Utils.httpServerUrl + "category/only_business");
  //   // var url = Uri.parse(Utils.httpServerUrl + "v1/categories?is_valid=1");
  //
  //   var url = Uri.parse("${Utils.httpServerUrl}category/business?is_valid=1&is_visible=1");
  //   // var url = Uri.parse("${Utils.httpServerUrl}category/business?is_valid=1");
  //
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   categoryList.addAll(jsonData);
  //     // });
  //     categoryList = jsonData;
  //
  //     for(var e in categoryList!){
  //       await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${e['image']}');
  //     }
  //
  //     // //print('categoryList!.length');
  //     // //print(categoryList!.length);
  //
  //     return jsonData;
  //   }
  // }

  Future/*<List<Uint8List>>*/ getBestsellers() async {
    // var url = Uri.parse("https://api.nurebo.com/prestazione/bestsellers");
    // var url = Uri.parse("${Utils.httpServerUrl}prestazione/bestsellers");
    Uri url;
    if(Utils.isBusiness == true) {
      url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/prestazione/bestsellers");
    }
    else {
      url = Uri.parse("${Utils.httpServerUrl}business/prestazione/bestsellers");
    }

    Map<String, dynamic> body = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    // Map<String, String?> queryParameters = {
    //   'user_id': user.id,
    // };
    final uri = url.replace(
      queryParameters: /*queryParameters*/body,
    );

    var response = await http.get(
      // url,
      uri,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData1');
      // print(jsonData.length);

      // bestsellersList.addAll(jsonData);
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
              description: e['business_description'],
              address: e['business_address'],
              room_id: e['business_room_id'],
              phone: e['business_phone'],
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
        // print("g85gg5gg5g5gg5g5g5g5");
        // print(e['business_profile_image']);
        await Future.wait([
          // getImage(bestsellersList[i].image!/*['prestazione_image']*/, /*bestsellersListImages*/),
          // getImage(bestsellersList[i].business!.profile_image!/*['business_profile_image']*/, /*bestsellersListImages*/),

          getImageWithRetry(bestseller.image!/*['prestazione_image']*/, /*bestsellersListImages*/),
          getImageWithRetry(bestseller.business!.profile_image!/*['business_profile_image']*/, /*bestsellersListImages*/),

          // fetchImage(bestsellersList[i]['prestazione_image'], /*bestsellersListImages*/),
          // fetchImage(bestsellersList[i]['business_profile_image'], /*bestsellersListImages*/),
          // imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestsellersList[i].image!/*['prestazione_image']*/}'),
          // imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestsellersList[i].business!.profile_image!/*['business_profile_image']*/}'),
        ]);
        bestsellersList.add(bestseller);
      }

      // for (int i = 0; i < bestsellersList.length; i++) {
      //   await Future.wait([
      //     // getImage(bestsellersList[i].image!/*['prestazione_image']*/, /*bestsellersListImages*/),
      //     // getImage(bestsellersList[i].business!.profile_image!/*['business_profile_image']*/, /*bestsellersListImages*/),
      //     getImageWithRetry(bestsellersList[i].image!/*['prestazione_image']*/, /*bestsellersListImages*/),
      //     getImageWithRetry(bestsellersList[i].business!.profile_image!/*['business_profile_image']*/, /*bestsellersListImages*/),
      //     // fetchImage(bestsellersList[i]['prestazione_image'], /*bestsellersListImages*/),
      //     // fetchImage(bestsellersList[i]['business_profile_image'], /*bestsellersListImages*/),
      //     // imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestsellersList[i].image!/*['prestazione_image']*/}'),
      //     // imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${bestsellersList[i].business!.profile_image!/*['business_profile_image']*/}'),
      //   ]);
      //   // imageCacheBusiness.addImageBytesInCache(bestsellersList[i].image!, await getImage(bestsellersList[i].image!));
      //   // imageCacheBusiness.addImageBytesInCache(bestsellersList[i].business!.profile_image!, await getImage(bestsellersList[i].business!.profile_image!));
      //
      //
      //   // if(i == 2){
      //   //   completer1.complete();
      //   //   // print('completer1.complete()');
      //   // }
      // }

      // await downloadImagesUntilComplete2(bestsellersList);

      completer1.complete();
      // print('completer1.complete()');

      // Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        completerCompleted++;
      });

      if(completerCompleted == /*4*/3 /*&& (Utils.isBusiness || Utils.isSocial)*/){
        // setState(() {
        socketProvider.setBottomBarVisibility(true);
        // });
      }
      // return await loadImages(bestsellersList);
    } else {
      throw Exception('Failed to load bestsellers');
    }
  }

  Future<void> downloadImagesUntilComplete2(List<Prestazione> bestsellerssList) async {
    int ccc = 0;
    int maxRetries = 3; // Numero massimo di tentativi
    int currentRetry = 0;

    while (ccc < bestsellerssList.length && currentRetry < maxRetries) {
      ccc = 0;

      for (int i = 0; i < bestsellerssList.length; i++) {
        Uint8List? ggbh = await getImage(bestsellerssList[i].image!);
        Uint8List? jjjuuggbh = await getImage(bestsellerssList[i].business!.profile_image!);
        if (ggbh != null && jjjuuggbh != null) {
          if (ggbh.lengthInBytes > 10000 && jjjuuggbh.lengthInBytes > 10000) {
            try {
              // await getImage(categoryList[i]['image']);
              // await imageCacheBusiness.addImageToCache(categoryList[i]['image']);
              imageCacheBusiness.addImageBytesInCache(bestsellerssList[i].image!, ggbh);
              imageCacheBusiness.addImageBytesInCache(bestsellerssList[i].business!.profile_image!, jjjuuggbh);
              // print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}"]);
            } catch (e) {
              // Gestisci il fallimento, ad esempio incrementando il contatore dei tentativi
              // print("Errore durante il download dell'immagine: $e");
            }
          }
          else {
            ccc++;
          }
        }
      }

      if (ccc < bestsellerssList.length) {
        // Incrementa il contatore dei tentativi e attendi prima di ritentare
        currentRetry++;
        // await Future.delayed(Duration(seconds: 1));
      }
    }

    if (currentRetry >= maxRetries) {
      // Puoi gestire il caso in cui il numero massimo di tentativi è stato raggiunto
      print("Numero massimo di tentativi raggiunto. Alcune immagini potrebbero non essere state scaricate con successo.");
    }

    // completer3.complete();
  }

  Future/*<List<Uint8List>>*/ getAllRecommendedPrestazione() async {
    // var url = Uri.parse("https://api.nurebo.com/prestazione/recommended");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/recommended");
    // Uint8List? cachedImage;

    Map<String, dynamic> body = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    // Map<String, String?> queryParameters = {
    //   'user_id': user.id,
    // };
    final uri = url.replace(
      queryParameters: /*queryParameters*/body,
    );

    var response = await http.get(
      // url,
      uri,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData2');
      // print(jsonData);

      // recommendedList.addAll(jsonData);
      // for(int j = 0; j < recommendedPrestazioneList.length; j++){
      for(var e in /*recommendedPrestazioneList*/jsonData){
        Recommended recommended = Recommended(
          id: e['recommended_id'],
          // is_single_event: false,
          // single_event_list: ,
          // created_at: DateTime.parse(e['recommended_created_at']),
          prestazione: Prestazione(
            id: e['prestazione_id'],
            isValid: e['prestazione_is_valid'],
            business: Business(
                id: e['business_id'],
                name: e['business_name'],
                latitude: e['business_latitude'],
                longitude: e['business_longitude'],
                type_id: 1,
                profile_image: e['business_profile_image'],
                description: e['business_description'],
                address: e['business_address'],
                room_id: e['business_room_id'],
                phone: e['business_phone'],
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
            description: e['prestazione_description'] ?? '',
            // last_modification_at: DateTime.parse(e['prestazione_last_modification_at']),
            created_at: DateTime.parse(e['prestazione_created_at']),
            // business_id: e['business_id'],
          ),
          // created_at: null,
        );
        recommendedList.add(recommended);
      }

      // List kk = List.from(recommendedList);

      // for (var e in recommendedList) {
      for (int i = 0; i < recommendedList.length; i++) {
        // cachedImage = null;
        // /*cachedImage =*/ await getImage(recommendedList[i].prestazione.image!/*['prestazione_image']*/);
        /*cachedImage =*/ await getImageWithRetry(recommendedList[i].prestazione.image!/*['prestazione_image']*/);
        // imageCacheBusiness.addImageBytesInCache(recommendedList[i].prestazione.image!, await getImage(recommendedList[i].prestazione.image!));
        // await fetchImage(recommendedList[i]['prestazione_image']);
        // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!/*['prestazione_image']*/}');

        // if(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}"]!.isEmpty) {
        //   print('objectf5ff5');
        //   print(cachedImage);
        //   print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${kk[i].prestazione.image!}"]);
        // }

        // do {
        //   cachedImage = await getImage(recommendedList[i].prestazione.image!/*['prestazione_image']*/);
        //   // cachedImage = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}');
        // } while (cachedImage == null);
        // if(i == 2){
        //   completer2.complete();
        //   print('completer2.complete()');
        // }
      }

      // await downloadImagesUntilComplete(recommendedList);

      completer2.complete();
      // print('completer2.complete()');

      // Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        completerCompleted++;
      });

      if(completerCompleted == /*4*/3 /*&& (Utils.isBusiness || Utils.isSocial)*/){
        // setState(() {
        socketProvider.setBottomBarVisibility(true);
        // });
      }
    } else {
      throw Exception('Failed to load recommended prestazione');
    }
  }

  Future<void> downloadImagesUntilComplete(List<Recommended> recommendedList) async {
    int ccc = 0;
    int maxRetries = 3; // Numero massimo di tentativi
    int currentRetry = 0;

    while (ccc < recommendedList.length && currentRetry < maxRetries) {
      ccc = 0;

      for (int i = 0; i < recommendedList.length; i++) {
        Uint8List? ggbh = await getImage(recommendedList[i].prestazione.image!);
        if (ggbh != null) {
          if (ggbh.lengthInBytes > 10000) {
            try {
              // await getImage(categoryList[i]['image']);
              // await imageCacheBusiness.addImageToCache(categoryList[i]['image']);
              imageCacheBusiness.addImageBytesInCache(recommendedList[i].prestazione.image!, ggbh);
              // print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}"]);
            } catch (e) {
              // Gestisci il fallimento, ad esempio incrementando il contatore dei tentativi
              // print("Errore durante il download dell'immagine: $e");
            }
          }
          else {
            ccc++;
          }
        }
      }

      if (ccc < recommendedList.length) {
        // Incrementa il contatore dei tentativi e attendi prima di ritentare
        currentRetry++;
        // await Future.delayed(Duration(seconds: 1));
      }
    }

    if (currentRetry >= maxRetries) {
      // Puoi gestire il caso in cui il numero massimo di tentativi è stato raggiunto
      print("Numero massimo di tentativi raggiunto. Alcune immagini potrebbero non essere state scaricate con successo.");
    }

    // completer3.complete();
  }

  /*Future<void> downloadImagesUntilComplete(List<Recommended> recommendedList) async {
    int ccc = 0;

    while (ccc < recommendedList.length) {
      ccc = 0;

      for (int i = 0; i < recommendedList.length; i++) {
        if (imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}"] == null) {
          await getImage(recommendedList[i].prestazione.image!);
          print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${recommendedList[i].prestazione.image!}"]);
        }
        else {
          ccc++;
        }
      }
      await Future.delayed(Duration(seconds: 1)); // Aggiungi un ritardo per evitare loop intensivi
      // print('olabufemi + $ccc');
      // completer2.complete();
    }
  }*/

  Future/*<List<Uint8List>>*/ getAllCategories() async {
    var url = Uri.parse("${Utils.httpServerUrl}category/business?is_valid=1&is_visible=1");

    Map<String, dynamic> body = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    // Map<String, String?> queryParameters = {
    //   'user_id': user.id,
    // };
    final uri = url.replace(
      queryParameters: /*queryParameters*/body,
    );

    var response = await http.get(
      // url,
      uri,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData3');
      // print(jsonData);

      // categoryList = jsonData;
      categoryList.addAll(jsonData);

      for (int i = 0; i < categoryList.length; i++) {
        // await getImage(categoryList[i]['image']);
        await getImageWithRetry(categoryList[i]['image']);
        // imageCacheBusiness.addImageBytesInCache(categoryList[i]['image'], await getImage(categoryList[i]['image']));
        // await fetchImage(categoryList[i]['image']);
        // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${categoryList[i]['image']}');

        // if(i == categoryList.length - 1){
        //   completer3.complete();
        //   // print('completer3.complete()');
        // }
      }

      // await downloadImagesUntilComplete1(categoryList);

      // int cc
      // for (int i = 0; i < categoryList.length; i++) {
      //   await getImage(categoryList[i]['image']);
      // }
      completer3.complete();

      // Future.delayed(const Duration(milliseconds: 200), );
      setState(() {
        completerCompleted++;
      });

      if(completerCompleted == 4 /*&& (Utils.isBusiness || Utils.isSocial)*/){
        // setState(() {
        socketProvider.setBottomBarVisibility(true);
        // });
      }
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future/*<List<Uint8List>>*/ getHomeBusinessPosts() async {
    var url;
    if(Utils.isBusiness) {
      url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post/home");
    }
    else {
      url = Uri.parse("${Utils.httpServerUrl}business/post/home");
    }

    Map<String, dynamic> body = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    // Map<String, String?> queryParameters = {
    //   'user_id': user.id,
    // };
    final uri = url.replace(
      queryParameters: /*queryParameters*/body,
    );

    var response = await http.get(
      // url,
      uri,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // homeBusinessPostList.addAll(jsonData);

      for(var e in jsonData) {
        BusinessPost post = BusinessPost(
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
            // business_id: e['prestazione_business_id'],
            isValid: e['prestazione_is_valid'],
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
        );

        await Future.wait([
          getImageWithRetry(post.image_url!),
          getImageWithRetry(post.prestazione!.image!),
          getImageWithRetry(post.user!.profile_image!),
        ]);

        homeBusinessPostList.add(post);
      }

      // for (int i = 0; i < homeBusinessPostList.length; i++) {
      //   // await getImage(categoryList[i]['image']);
      //   await getImageWithRetry(homeBusinessPostList[i]['image_url']);
      //   // imageCacheBusiness.addImageBytesInCache(categoryList[i]['image'], await getImage(categoryList[i]['image']));
      //   // await fetchImage(categoryList[i]['image']);
      //   // await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${categoryList[i]['image']}');
      //
      //   // if(i == categoryList.length - 1){
      //   //   completer3.complete();
      //   //   // print('completer3.complete()');
      //   // }
      // }

      // await downloadImagesUntilComplete1(categoryList);

      // int cc
      // for (int i = 0; i < categoryList.length; i++) {
      //   await getImage(categoryList[i]['image']);
      // }
      completer4.complete();

      // Future.delayed(const Duration(milliseconds: 200), );
      setState(() {
        completerCompleted++;
      });

      if(completerCompleted == /*4*/3 /*&& (Utils.isBusiness || Utils.isSocial)*/){
        // setState(() {
        socketProvider.setBottomBarVisibility(true);
        // });
      }
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /*Future<void> downloadImagesUntilComplete1(List<dynamic> categoryList) async {
    int ccc = 0;

    while (ccc < categoryList.length) {
      ccc = 0;

      for (int i = 0; i < categoryList.length; i++) {
        if (imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${categoryList[i]['image']}"] == null) {
          imageCacheBusiness.addImageBytesInCache(categoryList[i]['image'], await getImage(categoryList[i]['image']));
          print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${categoryList[i]['image']}"]);
        }
        else {
          ccc++;
        }
      }
      // await Future.delayed(Duration(seconds: 1)); // Aggiungi un ritardo per evitare loop intensivi
      // print('olabufemi + $ccc');
      // completer3.complete();
    }
  }*/

  Future<void> downloadImagesUntilComplete1(List<dynamic> categoryList) async {
    int ccc = 0;
    int maxRetries = 3; // Numero massimo di tentativi
    int currentRetry = 0;

    while (ccc < categoryList.length && currentRetry < maxRetries) {
      ccc = 0;

      for (int i = 0; i < categoryList.length; i++) {
        Uint8List? ggbh = await getImage(categoryList[i]['image']);
        if (ggbh != null) {
          if (ggbh.lengthInBytes > 10000) {
            try {
              // await getImage(categoryList[i]['image']);
              // await imageCacheBusiness.addImageToCache(categoryList[i]['image']);
              imageCacheBusiness.addImageBytesInCache(categoryList[i]['image'], ggbh);
              // print(imageCacheBusiness.imageCache["${Utils.httpServerUrl}image?path=${categoryList[i]['image']}"]);
            } catch (e) {
              // Gestisci il fallimento, ad esempio incrementando il contatore dei tentativi
              print("Errore durante il download dell'immagine: $e");
            }
          }
          else {
            ccc++;
          }
        }
      }

      if (ccc < categoryList.length) {
        // Incrementa il contatore dei tentativi e attendi prima di ritentare
        currentRetry++;
        // await Future.delayed(Duration(seconds: 1));
      }
    }

    if (currentRetry >= maxRetries) {
      // Puoi gestire il caso in cui il numero massimo di tentativi è stato raggiunto
      print("Numero massimo di tentativi raggiunto. Alcune immagini potrebbero non essere state scaricate con successo.");
    }

    // completer3.complete();
  }

  // Future futubuilderwati() async {
  //   await Future.wait([
  //     completer1.future,
  //     completer2.future,
  //     completer3.future,
  //     completer4.future
  //   ]);
  // }

  // Future<dynamic> getImage(String imageUrl) async {
  //   // print("vvv5454cv5");
  //
  //   var url = Uri.parse(imageUrl);
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
  //   // print("response");
  //   // print(response);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     // dynamic jsonData = json.decode(response.body);
  //     // print('jsonData');
  //     // print(jsonData);
  //     // print(jsonData.toString());
  //     // return jsonData.toString();
  //     // print(DateTime.now());
  //     return response.body;
  //   }
  //   return [];
  // }

  List<T?> map<T>(List list, Function handler){
    List<T?> result = [];
    for(var i = 0; i < list.length; i++){
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: 'Premere due volte per uscire',
          backgroundColor: Colors.grey[700]
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<Uint8List?> getImageWithRetry(String url, {int maxRetries = 4}) async {
    // print('ggghhfnnnn');
    // print("ff5f5fg5gggg222225g5g");
    // print(url);
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // print(url);
      try {
        // Uint8List? imageData = await getImage(url);
        Uint8List? imageData = await getImage(url);
        if (imageData != null) {
          if (imageData.lengthInBytes > 10000) {
            return imageData;
          }
          // attempt--;
        }
      } catch (e) {
        // Gestisci l'errore, se necessario
      }
    }
    return null;  // Se tutti i tentativi falliscono, restituisci null
  }

  Future<Uint8List?> getImage(String url) async {
    // print('urlfg6g6g6gg6g6g6gg6g6g6');
    // print(url);
    try {
      if (imageCacheBusiness.imageCache[url] != null) {
        if (imageCacheBusiness.imageCache.keys.contains(url) && imageCacheBusiness.imageCache[url]!.lengthInBytes > 10000 /*&& imageCacheBusiness.imageCache[url]!.isNotEmpty*/) {
          // print('return');
          return null;
        }
      }

      // print('f6gg5gg8ghh8hh8h8h8hh8hh866544');
      // print(url);

      final response = await http.get(
        Uri.parse('${Utils.httpServerUrl}image?path=$url'),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          'Accept-encoding': 'gzip, deflate',
        },
      );

      if (response.statusCode == 200) {
        final response2 = await http.get(
          Uri.parse(response.body),
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
            'Accept-encoding': 'gzip, deflate',
            'connection': 'keep-alive',
            'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
            'X-App-Version-Name': Utils.version_name,
            'X-App-Version-Number': Utils.version_id.toString(),
            'X-Client-Type': 'User-Mobile-App',
          },
        );

        if (response2.statusCode == 200) {
          // return response1.bodyBytes;
          // setState(() {
          // imagesList.add(response2.bodyBytes);
          // imageCacheBusiness.imageCache[url] = response2.bodyBytes;
          // });
          imageCacheBusiness.addImageBytesInCache(
            // '${Utils.httpServerUrl}image?path=$url',
            url,
            response2.bodyBytes,
          );

          return response2.bodyBytes;
        }
        else {
          // print('Failed to download image');
          // print(response2.statusCode);
          // print(url);
          // print(response.body);
        }
      }
    } catch (e) {
      // print('Error downloading image bestsellers: $e');
    }
    return null;
  }

  Future execFutureBuilderMethods() async {
    /*await*/ geolocationProvider.getGeolocationPermission(context).then((value) async {
      // await geolocationProvider.putUserLocation(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude, context);
      postProvider.getAllBusinessesPosts(context);
    }).then((valu) async {
      await Future.wait([
        // Utils.isBusiness ? getBusinessBestsellers()/*.then((value) => completer1.complete())*/ : getBestsellers(),
        getBestsellers()/*.then((value) => completer1.complete())*/,
        // getBestsellersBusiness()/*.then((value) => completer1.complete())*/,
        getAllRecommendedPrestazione()/*.then((value) => completer2.complete())*/,
        // !Utils.isBusiness ? getAllCategories()/*.then((value) => completer3.complete())*/ : Future(() {
        //   completer3.complete();
        //
        //   // Future.delayed(const Duration(milliseconds: 200), );
        //   setState(() {
        //     completerCompleted++;
        //   });
        //
        //   if(completerCompleted == 4 /*&& (Utils.isBusiness || Utils.isSocial)*/){
        //     // setState(() {
        //     socketProvider.setBottomBarVisibility(true);
        //     // });
        //   }
        // },),
        /*Utils.isBusiness*/true ? getHomeBusinessPosts()/*.then((value) => completer4.complete())*/ : Future(() {
          completer4.complete();

          // Future.delayed(const Duration(milliseconds: 200), );
          setState(() {
            completerCompleted++;
          });

          if(completerCompleted == 4 /*&& (Utils.isBusiness || Utils.isSocial)*/){
            // setState(() {
            socketProvider.setBottomBarVisibility(true);
            // });
          }
        },),
        // geolocationProvider.getGeolocationPermission(),
      ]).then((value) async {
        // setState(() {
        //
        // });

        // print('imageBytes.length');
        // print(imageBytes.length);

        // print('bestsellersList.length');
        // print(bestsellersList.length);
        // print('recommendedList.length');
        // print(recommendedList.length);
        // print('categoryList.length');
        // print(categoryList.length);
        // print('imageCacheBusiness.imageCache.keys');
        // print(imageCacheBusiness.imageCache.keys.length);
        // for(var e in imageCacheBusiness.imageCache.keys){
        //   print(e);
        // }

        // await geolocationProvider.getGeolocationPermission(context).then((value) async {
        //   // await geolocationProvider.putUserLocation(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude, context);
        //   postProvider.getAllBusinessesPosts(context);
        // });

        completer0.complete();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

    initializeDateFormatting();

    _tabController = TabController(vsync: this, length: 2);
    _scrollController = ScrollController();

    // getAllSingleEvent();
    // getAllRecommendedPrestazione();

    // getAllCategories()
    // // .then((value) => getAllDateCategories())
    //     .then((value) => categoryList.sort((a, b) {
    //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    // })
    // );

    // f = getImage as Future;

    // print('futu'+DateTime.now().toIso8601String());

    // Future.wait([
    //   // a = getAllSingleEvent(),
    //   b = getAllRecommendedPrestazione()/*.whenComplete(() => print('b'+DateTime.now().toIso8601String()))*/,
    //   c = getAllCategories()/*.whenComplete(() => print('c'+DateTime.now().toIso8601String()))*/,
    //   d = getBestsellers()/*.whenComplete(() => print('d'+DateTime.now().toIso8601String()))*/,
    //   // initPlatformState(),
    // ]);

    // fetchBestsellers();
    // fetchRecommended();
    // fetchCategories();

    all = execFutureBuilderMethods();

    // Future.wait([
    //   geolocationProvider.getGeolocationPermission()
    // ]);

    // print('imageCacheBusiness.imageCache.keys');
    // print(imageCacheBusiness.imageCache.keys);
    // FlutterNativeSplash.remove();

    // Future.wait([
    //   // a = getAllSingleEvent(),
    //   // b = getAllRecommendedPrestazione()/*.whenComplete(() => print('b'+DateTime.now().toIso8601String()))*/,
    //   // c = getAllCategories()/*.whenComplete(() => print('c'+DateTime.now().toIso8601String()))*/,
    //   // d = getBestsellers()/*.whenComplete(() => print('d'+DateTime.now().toIso8601String()))*/,
    //   // initPlatformState(),
    // ]).then((value) async {
    //   print('DateTime.now() waitterm');
    //   print(DateTime.now().toIso8601String());
    //
    //   // categoryList!.sort((a, b) {
    //   //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //   // });
    //   var category;
    //   //print('categoryListdff5gg5gf');
    //   //print(categoryList!.length);
    //   // for(category in categoryList!){
    //     //print(category);
    //   // }
    //
    //   await geolocationProvider.getGeolocationPermission();
    // });

    // getAllRecommendedSingleEvent();
    // getAllEventCategories();
    // getAllDateCategories();
    // getAllEventCategories()
    //     .then((value) => getAllDateCategories())
    //     .then((value) => categoryList.sort((a, b) {
    //       return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //     }));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      socketProvider.setBottomBarVisibility(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();

    // if(socketProvider.socket != null){
    //   if(socketProvider.socket.connected){
    //     socketProvider.socket.destroy();
    //   }
    // }

  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);
    // favoriteProvider = Provider.of<FavoriteProvider>(context, listen: true);
    // businessFavoriteProvider = Provider.of<SavedBusinessProvider>(context, listen: true);

    return FutureBuilder(
      // future: Future.wait([completer1.future, completer2.future, completer3.future, completer4.future]),
      future: all,
      // future: completer0.future,
      // future: Future.wait([all]),
      initialData: const [],
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && completerCompleted == /*4*/3){
          return Scaffold(
            // backgroundColor: Colors.grey[100],
              backgroundColor: Colors.white,
              drawer: Utils.isSocial || !Utils.isBusiness ? NureboDrawer() : SizedBox(),
              onDrawerChanged: /*Utils.isSocial ? */(value) {
                // if(!(!Utils.isSocial && !Utils.isBusiness)){
                //todo: false per nascondere bottombar
                //print(value);
                socketProvider.setBottomBarVisibility(!value);
                // }
              } /*: (_){}*/,
              drawerEnableOpenDragGesture: /*Utils.isSocial || !Utils.isBusiness ? true :*/ false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(55),
                // child: AppBar2(user: widget.user,),
                child: NureboAppBar(/*user: userProvider.user,*/),
              ),
              body: WillPopScope(
                onWillPop: onWillPop,
                child: SafeArea(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    // child: StaggeredGridView.countBuilder(
                    //   shrinkWrap: true,
                    //
                    //   padding: EdgeInsets.only(top: 0),
                    //   crossAxisCount: 3,
                    //   staggeredTileBuilder: (i) => StaggeredTile.count(i == 0 ? 3 : 1, i == 0 ? 2.65 : 1),
                    //   //shrinkWrap: true,
                    //   mainAxisSpacing: 0,
                    //   crossAxisSpacing: 0,
                    //   itemCount: categoryList.length + 1,
                    //   itemBuilder: (context, i) {
                    //     return i == 0
                    //         ? _slider(context, _pageController)
                    //         : _businessItem(context, i-1);
                    //   }
                    //     // ImageCard(
                    //     //   imageData: imageList[index],
                    //     // ),
                    // ),
                    child: ListView(
                      shrinkWrap: false,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                              child: Text(
                                // "Scopri",
                                // "In primo piano",
                                "In evidenza",
                                // "Eventi",
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontFamily: GoogleFonts.abhayaLibre(),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              // child: CarouselSlider.builder(
                              //   carouselController: CarouselController(),
                              //   itemCount: bestsellersList.length,
                              //   itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                              //     return StaggeredGridView.countBuilder(
                              //         shrinkWrap: true,
                              //         padding: EdgeInsets.only(top: 0, bottom: 0),
                              //         crossAxisCount: 2,
                              //         // reverse: true,
                              //         // staggeredTileBuilder: (i) => StaggeredTile.count(1, i % 2 == 1 ? 1 : .5),
                              //         staggeredTileBuilder: (i) => StaggeredTile.count(1, 1),
                              //         mainAxisSpacing: 0,
                              //         physics: const NeverScrollableScrollPhysics(),
                              //         crossAxisSpacing: 0,
                              //         // itemCount: 3,
                              //         itemCount: 2,
                              //         itemBuilder: (context, i) {
                              //           return InkWell(
                              //             highlightColor: Colors.transparent,
                              //             hoverColor: Colors.transparent,
                              //             focusColor: Colors.transparent,
                              //             splashColor: Colors.transparent,
                              //             onTap: (){
                              //               if(/*!item.is_single_event &&*/ bestsellersList[itemIndex] != null){
                              //                 if(i % 2 == 0){
                              //                   Navigator.push(
                              //                       context,
                              //                       PageTransition(
                              //                         duration: const Duration(
                              //                             milliseconds: 500
                              //                         ),
                              //                         alignment: Alignment.center,
                              //                         type: PageTransitionType.fade,
                              //                         child: PrestazioneScreen(
                              //                           prestazione: bestsellersList[itemIndex],
                              //                         ),
                              //                       )
                              //                   );
                              //                 }
                              //                 else {
                              //                   Navigator.push(
                              //                       context,
                              //                       PageTransition(
                              //                         duration: const Duration(
                              //                             milliseconds: 500
                              //                         ),
                              //                         alignment: Alignment.center,
                              //                         type: PageTransitionType.fade,
                              //                         child: BookingBusinessProfileScreen(
                              //                           bookingBusiness: bestsellersList[itemIndex].business,
                              //                         ),
                              //                       )
                              //                   );
                              //                 }
                              //
                              //                 // //print(i);
                              //               }
                              //               else {
                              //                 return null;
                              //               }
                              //             },
                              //             child: Padding(
                              //               padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                              //               child: Opacity(
                              //                 opacity: 1,
                              //                 child: Transform(
                              //                   alignment: FractionalOffset.topLeft,
                              //                   transform: Matrix4.translationValues(
                              //                     0,
                              //                     0.0,
                              //                     0.0,
                              //                   ),
                              //                   child: Card(
                              //                     shape: RoundedRectangleBorder(
                              //                       borderRadius: BorderRadius.circular(10),
                              //                     ),
                              //                     clipBehavior: Clip.antiAliasWithSaveLayer,
                              //                     elevation: 8,
                              //                     child: Stack(
                              //                       clipBehavior: Clip.antiAliasWithSaveLayer,
                              //                       fit: StackFit.expand,
                              //                       children: [
                              //                         // FutureBuilder<dynamic>(
                              //                         //   // future: Future.wait([getImage()]),
                              //                         //   // future: a,
                              //                         //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                              //                         //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                              //                         //   // future: getImage('${Utils.httpServerUrl}image?path=${item.image!}'),
                              //                         //   future: getImage('${Utils.httpServerUrl}image?path=${item.image!}'),
                              //                         //   initialData: [],
                              //                         //   builder: (context, snapshot) {
                              //                         //     // print('snapshot');
                              //                         //     // print(snapshot);
                              //                         //     // print('item.business!.profile_image!');
                              //                         //     // print(item.business!.profile_image!);
                              //                         //
                              //                         //     if(snapshot.connectionState == ConnectionState.done){
                              //                         //       return FutureImage(
                              //                         //         // imageUrl: item.image != null && item.image != '' && i % 2 == 0
                              //                         //         //     ? item.image! : item.business!.profile_image!,
                              //                         //         imageUrl: item.image != null && item.image != '' && i % 2 == 0
                              //                         //             ? snapshot.data : item.business!.profile_image!,
                              //                         //         cacheBusiness: CacheBusiness(
                              //                         //             Config(
                              //                         //                 'customCacheKey',
                              //                         //                 stalePeriod: const Duration(days: 7)
                              //                         //             )
                              //                         //         ),
                              //                         //         fit: BoxFit.cover,
                              //                         //         // colorBlendMode: BlendMode.hardLight,
                              //                         //         width: MediaQuery.of(context).size.width,
                              //                         //         // filterQuality: FilterQuality.high,
                              //                         //         // placeholder: (context, url) => Center(
                              //                         //         //     child: CircularProgressIndicator()
                              //                         //         // ),
                              //                         //         errorWidget: (context, url, error) => SizedBox(),
                              //                         //       );
                              //                         //     }
                              //                         //     else {
                              //                         //       return Container(color: Colors.transparent,);
                              //                         //     }
                              //                         //   }
                              //                         // ),
                              //                         FutureImage(
                              //                           bestsellersList[itemIndex].image != null && bestsellersList[itemIndex].image != '' && i % 2 == 0
                              //                             ? bestsellersList[itemIndex].image!
                              //                             : bestsellersList[itemIndex].business!.profile_image!,
                              //                           width: MediaQuery.of(context).size.width,
                              //                         ),
                              //                         // FutureImage(
                              //                         //   item.image != null && item.image != '' && i % 2 == 0
                              //                         //     ? '${Utils.httpServerUrl}image?path=${item.image!}'
                              //                         //     : item.business!.profile_image!,
                              //                         // ),
                              //                         DecoratedBox(
                              //                           decoration: BoxDecoration(
                              //                             // backgroundBlendMode: BlendMode.darken,
                              //                             gradient: LinearGradient(
                              //                               begin: Alignment.bottomLeft,
                              //                               end: Alignment.topRight,
                              //                               colors: [
                              //                                 Colors.black,
                              //                                 // Colors.transparent,
                              //                                 Colors.transparent,
                              //                               ],
                              //                             ),
                              //                           ),
                              //                         ),
                              //                         i % 2 == 0 ? Positioned(
                              //                           bottom: 15,
                              //                           left: 12,
                              //                           width: MediaQuery.of(context).size.width * 0.4,
                              //                           child: Column(
                              //                             crossAxisAlignment: CrossAxisAlignment.start,
                              //                             children: [
                              //                               GradientText(
                              //                                 /* item.is_single_event && item.single_event.business.name != null
                              //                             ? item.single_event.business.name
                              //                             :*/ bestsellersList[itemIndex].business!.name != null
                              //                                   ? bestsellersList[itemIndex].business!.name! : '',
                              //                                 // 'A partire da € 60,00',
                              //                                 maxLines: 3,
                              //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                                 gradient: /*item.is_single_event
                              //                               ? Gradients.backToFuture
                              //                               // :*/ /*Gradients.blush*/
                              //                                 LinearGradient(
                              //                                     begin: Alignment.bottomLeft,
                              //                                     end: Alignment.topRight,
                              //                                     colors: [
                              //                                       // Color(0xff8921aa),
                              //                                       // Color(0xffDA44bb),
                              //                                       // Colors.pink,
                              //                                       // Colors.pinkAccent,
                              //
                              //                                       // Color(0xffFFA818),
                              //                                       // Color(0xffF68A3D),
                              //                                       Color(0xfffd746c),
                              //                                       Color(0xffff9068),
                              //                                     ]
                              //                                 ),
                              //                                 // gradient: LinearGradient(
                              //                                 //     begin: Alignment.bottomLeft,
                              //                                 //     end: Alignment.topRight,
                              //                                 //     colors: [
                              //                                 //       Colors.blue[500],
                              //                                 //       Color(0xffDA44bb),
                              //                                 //
                              //                                 //       Color(0xff8921aa),
                              //                                 //     ]
                              //                                 // ),
                              //                                 style: TextStyle(
                              //                                     color: Colors.blue,
                              //                                     fontWeight: FontWeight.w700,
                              //                                     fontSize: 11.5
                              //                                 ),
                              //                                 textAlign: TextAlign.left,
                              //                               ),
                              //                               GradientText(
                              //                                 /*item.is_single_event && item.single_event.title != null
                              //                               ? item.single_event.title
                              //                               :*/ bestsellersList[itemIndex].title != null
                              //                                   ? bestsellersList[itemIndex].title! : '',
                              //                                 maxLines: 5,
                              //                                 shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                                 gradient: Gradients.haze,
                              //                                 style: TextStyle(
                              //                                     color: Colors.white,
                              //                                     fontWeight: FontWeight.w700,
                              //                                     fontSize: 18
                              //                                 ),
                              //                                 textAlign: TextAlign.left,
                              //                               ),
                              //                               /* item.is_single_event
                              //                             ? SizedBox(height: 2,)
                              //                             : SizedBox(height: 0,),*/
                              //                               /*item.is_single_event && item.single_event.begin_at != null
                              //                             ? GradientText(
                              //                           DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                              //                           maxLines: 2,
                              //                           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                           // gradient: Gradients.backToFuture,
                              //                           gradient: Gradients.blush,
                              //                           // gradient: LinearGradient(
                              //                           //     begin: Alignment.bottomLeft,
                              //                           //     end: Alignment.topRight,
                              //                           //     colors: [
                              //                           //       Color(0xff8921aa),
                              //                           //       Color(0xffDA44bb),
                              //                           //       // Color(0xffDA44bb)
                              //                           //     ]
                              //                           // ),
                              //                           // gradient: LinearGradient(
                              //                           //     begin: Alignment.bottomLeft,
                              //                           //     end: Alignment.topRight,
                              //                           //     colors: [
                              //                           //       Color(0xff8921aa),
                              //                           //       Color(0xffDA44bb),
                              //                           //       // Color(0xffDA44bb)
                              //                           //     ]
                              //                           // ),
                              //
                              //                           style: TextStyle(
                              //                               color: Colors.blue,
                              //                               fontWeight: FontWeight.w800,
                              //                               fontSize: 16
                              //                           ),
                              //                           textAlign: TextAlign.left,
                              //                         )
                              //                             : SizedBox(height: 0, width: 0,),*/
                              //                               SizedBox(height: 1.5,),
                              //                               GradientText(
                              //                                 // item.is_single_event && item.single_event.title != null
                              //                                 //     ? item.single_event.title
                              //                                 //     : item.prestazione.title != null
                              //                                 //     ? item.prestazione.title : '',
                              //                                 /*item.is_single_event
                              //                               ? 'A partire da € 15,00'*//* + NumberFormat.currency(
                              //                                   // customPattern: '#,##',
                              //                                     decimalDigits: 2,
                              //                                     symbol: '',
                              //                                     locale: 'IT_it'
                              //                                 ).format(item.single_event.)*//*
                              //                               : */'Al prezzo di € ' + NumberFormat.currency(
                              //                                 // customPattern: '#,##',
                              //                                   decimalDigits: 2,
                              //                                   symbol: '',
                              //                                   locale: 'IT_it'
                              //                               ).format(bestsellersList[itemIndex].price),
                              //                                 maxLines: 2,
                              //
                              //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                                 // gradient: Gradients.backToFuture,
                              //                                 gradient: /*!item.is_single_event
                              //                               ?*/ /*Gradients.blush*/
                              //                                 LinearGradient(
                              //                                     begin: Alignment.bottomLeft,
                              //                                     end: Alignment.topRight,
                              //                                     colors: [
                              //                                       // Color(0xff8921aa),
                              //                                       // Color(0xffDA44bb),
                              //                                       // Color(0xffDA44bb)
                              //
                              //                                       // Color(0xffFFA818),
                              //                                       // Color(0xffF68A3D),
                              //
                              //                                       // Color(0xffAE6900),
                              //                                       // Color(0xffCB8A00)
                              //                                       // Color(0xffC82240)
                              //
                              //                                       Color(0xffFFA818),
                              //                                       Color(0xffFFB75E),
                              //
                              //                                       // Color(0xffee9ca7),
                              //                                       // Color(0xffffdde1),
                              //                                     ]
                              //                                 ),
                              //                                 style: TextStyle(
                              //                                     color: Colors.blue,
                              //                                     fontWeight: FontWeight.w700,
                              //                                     fontSize: 11.5
                              //                                 ),
                              //                                 textAlign: TextAlign.left,
                              //                               ),
                              //                               // Text(
                              //                               //   'A partire da € 60,00',
                              //                               //   style: new TextStyle(
                              //                               //       fontWeight: FontWeight.w800,
                              //                               //       fontSize: 15,
                              //                               //
                              //                               //       foreground: Paint()..shader = LinearGradient(
                              //                               //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                              //                               //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                              //                               // )
                              //                               // LinearGradient(
                              //                               //   begin: Alignment.topLeft,
                              //                               //   end: Alignment.bottomRight,
                              //                               //   colors: gradientColors,
                              //                               // ).createShader(
                              //                               //     Rect.fromCircle(
                              //                               //       center: Offset(fontSize, -200),
                              //                               //       radius: fontSize / 3,
                              //                               //     )
                              //                               // );
                              //                             ],
                              //                           ),
                              //                         ) : Positioned(
                              //                           bottom: 15,
                              //                           left: 15,
                              //                           width: MediaQuery.of(context).size.width * 0.38,
                              //                           child: Column(
                              //                             crossAxisAlignment: CrossAxisAlignment.start,
                              //                             children: [
                              //                               GradientText(
                              //                                 bestsellersList[itemIndex].business!.category!.name != null
                              //                                     ? bestsellersList[itemIndex].business!.category!.name! : '',
                              //                                 maxLines: 2,
                              //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                                 // gradient: Gradients.backToFuture,
                              //                                 gradient: /*!item.is_single_event ?*/ /*Gradients.blush*/LinearGradient(
                              //                                     begin: Alignment.bottomLeft,
                              //                                     end: Alignment.topRight,
                              //                                     colors: [
                              //                                       // Color(0xff8921aa),
                              //                                       // Color(0xffDA44bb),
                              //
                              //                                       // Color(0xffFFB75E),
                              //                                       // Color(0xffED8F03),
                              //
                              //                                       Color(0xfffd746c),
                              //                                       Color(0xffff9068),
                              //                                     ]
                              //                                 ),
                              //                                 style: TextStyle(
                              //                                     color: Colors.blue,
                              //                                     fontWeight: FontWeight.w700,
                              //                                     fontSize: 12
                              //                                 ),
                              //                                 textAlign: TextAlign.left,
                              //                               ),
                              //                               SizedBox(height: 1,),
                              //                               /*Gradient*/Text(
                              //                                 /* item.is_single_event && item.single_event.business.name != null
                              //                             ? item.single_event.business.name
                              //                             :*/ bestsellersList[itemIndex].business!.name != null
                              //                                   ? bestsellersList[itemIndex].business!.name! : '',
                              //                                 // 'A partire da € 60,00',
                              //                                 maxLines: 6,
                              //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                                 /*gradient: item.is_single_event
                              //                               ? Gradients.backToFuture
                              //                               :*/
                              //                                 // LinearGradient(
                              //                                 //     begin: Alignment.bottomLeft,
                              //                                 //     end: Alignment.topRight,
                              //                                 //     colors: [
                              //                                 //       Color(0xff8921aa),
                              //                                 //       Color(0xffDA44bb),
                              //                                 //       // Colors.pink,
                              //                                 //       // Colors.pinkAccent,
                              //                                 //     ]
                              //                                 // ),
                              //                                 // gradient: LinearGradient(
                              //                                 //     begin: Alignment.bottomLeft,
                              //                                 //     end: Alignment.topRight,
                              //                                 //     colors: [
                              //                                 //       Colors.blue[500],
                              //                                 //       Color(0xffDA44bb),
                              //                                 //
                              //                                 //       Color(0xff8921aa),
                              //                                 //     ]
                              //                                 // ),
                              //                                 style: TextStyle(
                              //                                     color: Colors.white,
                              //                                     fontWeight: FontWeight.w700,
                              //                                     fontSize: 16
                              //                                 ),
                              //                                 textAlign: TextAlign.left,
                              //                               ),
                              //                               // Text(
                              //                               //   'A partire da € 60,00',
                              //                               //   style: new TextStyle(
                              //                               //       fontWeight: FontWeight.w800,
                              //                               //       fontSize: 15,
                              //                               //
                              //                               //       foreground: Paint()..shader = LinearGradient(
                              //                               //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                              //                               //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                              //                               // )
                              //                               // LinearGradient(
                              //                               //   begin: Alignment.topLeft,
                              //                               //   end: Alignment.bottomRight,
                              //                               //   colors: gradientColors,
                              //                               // ).createShader(
                              //                               //     Rect.fromCircle(
                              //                               //       center: Offset(fontSize, -200),
                              //                               //       radius: fontSize / 3,
                              //                               //     )
                              //                               // );
                              //                             ],
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             ),
                              //           );
                              //         }
                              //     );
                              //   },
                              //   options: CarouselOptions(
                              //       enlargeCenterPage: true,
                              //       viewportFraction: 1,
                              //       autoPlay: true,
                              //       // aspectRatio: 16/9,
                              //       autoPlayCurve: Curves.easeInOut,
                              //       onPageChanged: (i, bho){
                              //         // setState(() {
                              //         //   // _current = bho.index;
                              //         //   _eventsPageController.jumpToPage(bho.index);
                              //         // });
                              //       }
                              //   ),
                              // ),
                              child: CarouselSlider(
                                carouselController: CarouselSliderController(),
                                items: bestsellersList.map((item) {
                                  // //print('item.prestazione.toJson()');
                                  // //print(item.prestazione.toJson());

                                  return StaggeredGridView.countBuilder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(top: 0, bottom: 0),
                                      crossAxisCount: 2,
                                      // reverse: true,
                                      // staggeredTileBuilder: (i) => StaggeredTile.count(1, i % 2 == 1 ? 1 : .5),
                                      staggeredTileBuilder: (i) => StaggeredTile.count(1, 1),
                                      mainAxisSpacing: 0,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 0,
                                      // itemCount: 3,
                                      itemCount: 2,
                                      itemBuilder: (context, i) {
                                        return InkWell(
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: (){
                                            if(/*!item.is_single_event &&*/ item != null){
                                              if(i % 2 == 0 ){
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      duration: const Duration(
                                                          milliseconds: 500
                                                      ),
                                                      alignment: Alignment.center,
                                                      type: PageTransitionType.fade,
                                                      child: PrestazioneSlotsScreen(
                                                        prestazione: item,
                                                      ),
                                                    )
                                                );
                                              }
                                              else {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      duration: const Duration(
                                                          milliseconds: 500
                                                      ),
                                                      alignment: Alignment.center,
                                                      type: PageTransitionType.fade,
                                                      child: BookingBusinessProfileScreen(
                                                        business: item.business,
                                                      ),
                                                    )
                                                );
                                              }

                                              // //print(i);
                                            }
                                            else {
                                              return null;
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                            child: Opacity(
                                              opacity: 1,
                                              child: Transform(
                                                alignment: FractionalOffset.topLeft,
                                                transform: Matrix4.translationValues(
                                                  0,
                                                  0.0,
                                                  0.0,
                                                ),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                  elevation: 8,
                                                  child: Stack(
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    fit: StackFit.expand,
                                                    children: [
                                                      // FutureImage(
                                                      //   item.image != null && item.image != '' && i % 2 == 0
                                                      //       ? item.image! : item.business!.profile_image!,
                                                      //   width: MediaQuery.of(context).size.width,
                                                      //   // forceNetworkImage: true,
                                                      // ),
                                                      Image.memory(
                                                        // item,
                                                        imageCacheBusiness.imageCache[item.image/*['prestazione_image']*/] != null && item.image/*['prestazione_image']*/ != '' && i.isEven
                                                            ? imageCacheBusiness.imageCache[item.image/*['prestazione_image']*/]!
                                                            : (imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/] != null && item.business!.profile_image/*['business_profile_image']*/ != '' && i.isOdd
                                                            ? imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/]!
                                                            : Uint8List(0)),
                                                        width: MediaQuery.of(context).size.width,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, url, error) => Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: MediaQuery.of(context).size.height,
                                                          color: Colors.transparent,
                                                        ),
                                                        gaplessPlayback: true,
                                                        isAntiAlias: true,
                                                      ),
                                                      DecoratedBox(
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
                                                      i % 2 == 0 ? Positioned(
                                                        bottom: 15,
                                                        left: 12,
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            GradientText(
                                                              /* item.is_single_event && item.single_event.business.name != null
                                                      ? item.single_event.business.name
                                                      :*/ item.business!.name != null
                                                                ? item.business!.name! : '',
                                                              // 'A partire da € 60,00',
                                                              maxLines: 3,
                                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                              gradient: /*item.is_single_event
                                                        ? Gradients.backToFuture
                                                        // :*/ /*Gradients.blush*/
                                                              LinearGradient(
                                                                  begin: Alignment.bottomLeft,
                                                                  end: Alignment.topRight,
                                                                  colors: [
                                                                    // Color(0xff8921aa),
                                                                    // Color(0xffDA44bb),
                                                                    // Colors.pink,
                                                                    // Colors.pinkAccent,

                                                                    // Color(0xffFFA818),
                                                                    // Color(0xffF68A3D),
                                                                    Color(0xfffd746c),
                                                                    Color(0xffff9068),
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
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 13
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            GradientText(
                                                              /*item.is_single_event && item.single_event.title != null
                                                        ? item.single_event.title
                                                        :*/ item.title != null
                                                                ? item.title! : '',
                                                              maxLines: 5,
                                                              shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              gradient: Gradients.haze,
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 18
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            /* item.is_single_event
                                                      ? SizedBox(height: 2,)
                                                      : SizedBox(height: 0,),*/
                                                            /*item.is_single_event && item.single_event.begin_at != null
                                                      ? GradientText(
                                                    DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                                    maxLines: 2,
                                                    // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                    // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                    // gradient: Gradients.backToFuture,
                                                    gradient: Gradients.blush,
                                                    // gradient: LinearGradient(
                                                    //     begin: Alignment.bottomLeft,
                                                    //     end: Alignment.topRight,
                                                    //     colors: [
                                                    //       Color(0xff8921aa),
                                                    //       Color(0xffDA44bb),
                                                    //       // Color(0xffDA44bb)
                                                    //     ]
                                                    // ),
                                                    // gradient: LinearGradient(
                                                    //     begin: Alignment.bottomLeft,
                                                    //     end: Alignment.topRight,
                                                    //     colors: [
                                                    //       Color(0xff8921aa),
                                                    //       Color(0xffDA44bb),
                                                    //       // Color(0xffDA44bb)
                                                    //     ]
                                                    // ),

                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 16
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  )
                                                      : SizedBox(height: 0, width: 0,),*/
                                                            SizedBox(height: 1.5,),
                                                            GradientText(
                                                              !item.is_price_range ? 'Al prezzo di € ${NumberFormat.currency(
                                                                // customPattern: '#,##',
                                                                  decimalDigits: 2,
                                                                  symbol: '',
                                                                  locale: 'IT_it'
                                                                // ).format(item['prestazione_price']),
                                                              ).format(item.price!)}' : 'A partire da € ${NumberFormat.currency(
                                                                // customPattern: '#,##',
                                                                  decimalDigits: 2,
                                                                  symbol: '',
                                                                  locale: 'IT_it'
                                                                // ).format(item['prestazione_price']),
                                                              ).format(item.price_min!)}',
                                                              maxLines: 1,
                                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                              // gradient: Gradients.backToFuture,
                                                              gradient: /*!item.is_single_event
                                                        ?*/ /*Gradients.blush*/
                                                              LinearGradient(
                                                                  begin: Alignment.bottomLeft,
                                                                  end: Alignment.topRight,
                                                                  colors: [
                                                                    // Color(0xff8921aa),
                                                                    // Color(0xffDA44bb),
                                                                    // Color(0xffDA44bb)

                                                                    // Color(0xffFFA818),
                                                                    // Color(0xffF68A3D),

                                                                    // Color(0xffAE6900),
                                                                    // Color(0xffCB8A00)
                                                                    // Color(0xffC82240)

                                                                    Color(0xffFFA818),
                                                                    Color(0xffFFB75E),

                                                                    // Color(0xffee9ca7),
                                                                    // Color(0xffffdde1),
                                                                  ]
                                                              ),
                                                              style: TextStyle(
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 13
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
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
                                                      ) : Positioned(
                                                        bottom: 15,
                                                        left: 15,
                                                        width: MediaQuery.of(context).size.width * 0.38,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            GradientText(
                                                              item.business!.category!.name != null
                                                                  ? item.business!.category!.name! : '',
                                                              maxLines: 2,
                                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                              // gradient: Gradients.backToFuture,
                                                              gradient: /*!item.is_single_event ?*/ /*Gradients.blush*/LinearGradient(
                                                                  begin: Alignment.bottomLeft,
                                                                  end: Alignment.topRight,
                                                                  colors: [
                                                                    // Color(0xff8921aa),
                                                                    // Color(0xffDA44bb),

                                                                    // Color(0xffFFB75E),
                                                                    // Color(0xffED8F03),

                                                                    Color(0xfffd746c),
                                                                    Color(0xffff9068),
                                                                  ]
                                                              ),
                                                              style: TextStyle(
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 12
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            SizedBox(height: 1,),
                                                            /*Gradient*/Text(
                                                              /* item.is_single_event && item.single_event.business.name != null
                                                      ? item.single_event.business.name
                                                      :*/ item.business!.name != null
                                                                ? item.business!.name! : '',
                                                              // 'A partire da € 60,00',
                                                              maxLines: 6,
                                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                              /*gradient: item.is_single_event
                                                        ? Gradients.backToFuture
                                                        :*/
                                                              // LinearGradient(
                                                              //     begin: Alignment.bottomLeft,
                                                              //     end: Alignment.topRight,
                                                              //     colors: [
                                                              //       Color(0xff8921aa),
                                                              //       Color(0xffDA44bb),
                                                              //       // Colors.pink,
                                                              //       // Colors.pinkAccent,
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
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 16
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
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
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    viewportFraction: 1,
                                    autoPlay: true,
                                    // aspectRatio: 16/9,
                                    autoPlayCurve: Curves.easeInOut,
                                    onPageChanged: (i, bho){
                                      // setState(() {
                                      //   // _current = bho.index;
                                      //   _eventsPageController.jumpToPage(bho.index);
                                      // });
                                      // if(i == 1){
                                      //   FlutterNativeSplash.remove();
                                      // }
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 0, bottom: 5),
                              child: Text(
                                // "In evidenza",
                                "In vetrina",
                                // "Eventi",
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontFamily: GoogleFonts.abhayaLibre(),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w700,

                                ),
                              ),
                            ),
                            // Divider(
                            //   height: 0,
                            //   thickness: 2,
                            //   indent: 10,
                            //   // endIndent: 35,
                            //   endIndent: 10,
                            // ),
                            // _slider(context, _eventsPageController, [], 3, true),
                            // _slider(context, _eventsPageController, recommendedList, 3, true),
                            // _slider(context, _eventsPageController, lists, 3, true),
                            Container(
                              // child: CarouselSlider.builder(
                              //   carouselController: CarouselController(),
                              //   itemCount: recommendedList.length,
                              //   itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                              //     return InkWell(
                              //       highlightColor: Colors.transparent,
                              //       hoverColor: Colors.transparent,
                              //       focusColor: Colors.transparent,
                              //       splashColor: Colors.transparent,
                              //       onTap: (){
                              //         // if(item.is_single_event && item != null){
                              //         //   Navigator.push(
                              //         //       context,
                              //         //       PageTransition(
                              //         //         duration: const Duration(
                              //         //             milliseconds: 500
                              //         //         ),
                              //         //         alignment: Alignment.center,
                              //         //         type: PageTransitionType.fade,
                              //         //         child: SingleEventScreen(
                              //         //           user: widget.user,
                              //         //           singleEvent: item.single_event,
                              //         //         ),
                              //         //       )
                              //         //   );
                              //         // }
                              //         /*else*/ if(/*!item.is_single_event &&*/ recommendedList[itemIndex] != null){
                              //           Navigator.push(
                              //               context,
                              //               PageTransition(
                              //                 duration: const Duration(
                              //                     milliseconds: 500
                              //                 ),
                              //                 alignment: Alignment.center,
                              //                 type: PageTransitionType.fade,
                              //                 child: PrestazioneScreen(
                              //                   prestazione: recommendedList[itemIndex].prestazione,
                              //                 ),
                              //               )
                              //           );
                              //         }
                              //         else {
                              //           return null;
                              //         }
                              //       },
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(top: 5, bottom: 10, right: 5, left: 5),
                              //         child: Opacity(
                              //           opacity: 1,
                              //           child: Transform(
                              //             alignment: FractionalOffset.topLeft,
                              //             transform: Matrix4.translationValues(
                              //               0,
                              //               0.0,
                              //               0.0,
                              //             ),
                              //             child: Card(
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.circular(10),
                              //               ),
                              //               clipBehavior: Clip.antiAliasWithSaveLayer,
                              //               elevation: 8,
                              //               child: Stack(
                              //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                              //                 fit: StackFit.expand,
                              //                 children: [
                              //                   // FutureBuilder<dynamic>(
                              //                   //   // future: Future.wait([getImage()]),
                              //                   //   // future: a,
                              //                   //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                              //                   //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                              //                   //   future: getImage('${Utils.httpServerUrl}image?path=${item.prestazione.image!}'),
                              //                   //   initialData: [],
                              //                   //   builder: (context, snapshot) {
                              //                   //     // print('snapshot');
                              //                   //     // print(snapshot);
                              //                   //     // print('item.prestazione.business!.profile_image!');
                              //                   //     // print(item.prestazione.business!.profile_image!);
                              //                   //
                              //                   //     if(snapshot.connectionState == ConnectionState.done){
                              //                   //       return FutureImage(
                              //                   //         // imageUrl: item.prestazione.image != null && item.prestazione.image != ''
                              //                   //         //     ? item.prestazione.image! : item.prestazione.business!.profile_image!,
                              //                   //         imageUrl: item.prestazione.image != null && item.prestazione.image != ''
                              //                   //             ? snapshot.data : item.prestazione.business!.profile_image!,
                              //                   //         cacheBusiness: CacheBusiness(
                              //                   //             Config(
                              //                   //                 'customCacheKey',
                              //                   //                 stalePeriod: const Duration(days: 7)
                              //                   //             )
                              //                   //         ),
                              //                   //         fit: BoxFit.cover,
                              //                   //         // colorBlendMode: BlendMode.hardLight,
                              //                   //         width: MediaQuery.of(context).size.width,
                              //                   //         // filterQuality: FilterQuality.high,
                              //                   //         // placeholder: (context, url) => Center(
                              //                   //         //     child: CircularProgressIndicator()
                              //                   //         // ),
                              //                   //         errorWidget: (context, url, error) => SizedBox(),
                              //                   //       );
                              //                   //     }
                              //                   //     else {
                              //                   //       return Container(color: Colors.transparent,);
                              //                   //     }
                              //                   //   }
                              //                   // ),
                              //                   FutureImage(
                              //                     recommendedList[itemIndex].prestazione.image != null && recommendedList[itemIndex].prestazione.image != ''
                              //                         ? recommendedList[itemIndex].prestazione.image!
                              //                         : recommendedList[itemIndex].prestazione.business!.profile_image!,
                              //                     width: MediaQuery.of(context).size.width,
                              //                   ),
                              //                   // FutureImage(
                              //                   //   item.image != null && item.image != '' && i % 2 == 0
                              //                   //       ? '${Utils.httpServerUrl}image?path=${item.image!}'
                              //                   //       : item.business!.profile_image!,
                              //                   // ),
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
                              //                   Positioned(
                              //                     bottom: 20,
                              //                     left: 20,
                              //                     width: MediaQuery.of(context).size.width * 0.75,
                              //                     child: Column(
                              //                       crossAxisAlignment: CrossAxisAlignment.start,
                              //                       children: [
                              //                         GradientText(
                              //                           /* item.is_single_event && item.single_event.business.name != null
                              //                           ? item.single_event.business.name
                              //                           :*/ recommendedList[itemIndex].prestazione.business!.name != null
                              //                             ? recommendedList[itemIndex].prestazione.business!.name! : '',
                              //                           // 'A partire da € 60,00',
                              //                           maxLines: 1,
                              //
                              //                           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                           gradient: /*Gradients.blush*//*item.is_single_event
                              //                             ? Gradients.backToFuture
                              //                             :*/ LinearGradient(
                              //                               begin: Alignment.bottomLeft,
                              //                               end: Alignment.topRight,
                              //                               colors: [
                              //                                 // Color(0xff8921aa),
                              //                                 // Color(0xffDA44bb),
                              //                                 // Color(0xffDA44bb)
                              //
                              //                                 // Color(0xffFFA818),
                              //                                 // Color(0xffF68A3D),
                              //
                              //                                 // Color(0xffFFB75E),
                              //                                 // Color(0xfff46b45),
                              //                                 // Color(0xffED8F03),
                              //
                              //                                 Color(0xfffd746c),
                              //                                 Color(0xffff9068),
                              //                               ]
                              //                           ),
                              //                           // gradient: LinearGradient(
                              //                           //     begin: Alignment.bottomLeft,
                              //                           //     end: Alignment.topRight,
                              //                           //     colors: [
                              //                           //       Colors.blue[500],
                              //                           //       Color(0xffDA44bb),
                              //                           //
                              //                           //       Color(0xff8921aa),
                              //                           //     ]
                              //                           // ),
                              //                           style: TextStyle(
                              //                               color: Colors.blue,
                              //                               fontWeight: FontWeight.w700,
                              //                               fontSize: 15
                              //                           ),
                              //                           textAlign: TextAlign.left,
                              //                         ),
                              //                         GradientText(
                              //                           /*item.is_single_event && item.single_event.title != null
                              //                             ? item.single_event.title
                              //                             :*/ recommendedList[itemIndex].prestazione.title != null
                              //                             ? recommendedList[itemIndex].prestazione.title! : '',
                              //                           maxLines: 2,
                              //                           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                           // gradient: Gradients.haze,
                              //                           gradient: Gradients.haze,
                              //                           style: TextStyle(
                              //                               color: Colors.white,
                              //                               fontWeight: FontWeight.w700,
                              //                               fontSize: 20
                              //                           ),
                              //                           textAlign: TextAlign.left,
                              //                         ),
                              //                         /* item.is_single_event
                              //                           ? SizedBox(height: 2,)
                              //                           : SizedBox(height: 0,),*/
                              //                         /*item.is_single_event && item.single_event.begin_at != null
                              //                           ? GradientText(
                              //                         DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                              //                         maxLines: 2,
                              //                         // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                         // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                         // gradient: Gradients.backToFuture,
                              //                         gradient: Gradients.blush,
                              //                         // gradient: LinearGradient(
                              //                         //     begin: Alignment.bottomLeft,
                              //                         //     end: Alignment.topRight,
                              //                         //     colors: [
                              //                         //       Color(0xff8921aa),
                              //                         //       Color(0xffDA44bb),
                              //                         //       // Color(0xffDA44bb)
                              //                         //     ]
                              //                         // ),
                              //                         // gradient: LinearGradient(
                              //                         //     begin: Alignment.bottomLeft,
                              //                         //     end: Alignment.topRight,
                              //                         //     colors: [
                              //                         //       Color(0xff8921aa),
                              //                         //       Color(0xffDA44bb),
                              //                         //       // Color(0xffDA44bb)
                              //                         //     ]
                              //                         // ),
                              //
                              //                         style: TextStyle(
                              //                             color: Colors.blue,
                              //                             fontWeight: FontWeight.w800,
                              //                             fontSize: 16
                              //                         ),
                              //                         textAlign: TextAlign.left,
                              //                       )
                              //                           : SizedBox(height: 0, width: 0,),*/
                              //                         SizedBox(height: 1,),
                              //                         GradientText(
                              //                           // item.is_single_event && item.single_event.title != null
                              //                           //     ? item.single_event.title
                              //                           //     : item.prestazione.title != null
                              //                           //     ? item.prestazione.title : '',
                              //                           /*item.is_single_event
                              //                             ? 'A partire da € 15,00'*//* + NumberFormat.currency(
                              //                                 // customPattern: '#,##',
                              //                                   decimalDigits: 2,
                              //                                   symbol: '',
                              //                                   locale: 'IT_it'
                              //                               ).format(item.single_event.)*//*
                              //                             : */'Al prezzo di € ' + NumberFormat.currency(
                              //                           // customPattern: '#,##',
                              //                             decimalDigits: 2,
                              //                             symbol: '',
                              //                             locale: 'IT_it'
                              //                         ).format(recommendedList[itemIndex].prestazione.price),
                              //                           maxLines: 2,
                              //
                              //                           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //                           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              //                           // gradient: Gradients.backToFuture,
                              //                           gradient: /*!item.is_single_event
                              //                             ?*/ /*Gradients.blush
                              //                           :*/ LinearGradient(
                              //                               begin: Alignment.bottomLeft,
                              //                               end: Alignment.topRight,
                              //                               colors: [
                              //                                 // Color(0xff8921aa),
                              //                                 // Color(0xffDA44bb),
                              //
                              //                                 // Color(0xffFFA818),
                              //                                 // Color(0xffF68A3D),
                              //
                              //                                 Color(0xffFFA818),
                              //                                 Color(0xffFFB75E),
                              //                                 // Color(0xffED8F03),
                              //
                              //                                 // Color(0xffee9ca7),
                              //                                 // Color(0xffffdde1),
                              //                               ]
                              //                           ),
                              //                           style: TextStyle(
                              //                               color: Colors.blue,
                              //                               fontWeight: FontWeight.w700,
                              //                               fontSize: 15
                              //                           ),
                              //                           textAlign: TextAlign.left,
                              //                         ),
                              //                         // Text(
                              //                         //   'A partire da € 60,00',
                              //                         //   style: new TextStyle(
                              //                         //       fontWeight: FontWeight.w800,
                              //                         //       fontSize: 15,
                              //                         //
                              //                         //       foreground: Paint()..shader = LinearGradient(
                              //                         //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                              //                         //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                              //                         // )
                              //                         // LinearGradient(
                              //                         //   begin: Alignment.topLeft,
                              //                         //   end: Alignment.bottomRight,
                              //                         //   colors: gradientColors,
                              //                         // ).createShader(
                              //                         //     Rect.fromCircle(
                              //                         //       center: Offset(fontSize, -200),
                              //                         //       radius: fontSize / 3,
                              //                         //     )
                              //                         // );
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   },
                              //   options: CarouselOptions(
                              //       enlargeCenterPage: true,
                              //       viewportFraction: 1,
                              //       autoPlay: true,
                              //       // aspectRatio: 16/9,
                              //       autoPlayCurve: Curves.easeInOut,
                              //       onPageChanged: (i, bho){
                              //         // setState(() {
                              //         //   // _current = bho.index;
                              //         //   _eventsPageController.jumpToPage(bho.index);
                              //         // });
                              //       }
                              //
                              //   ),
                              // ),
                              child: CarouselSlider(
                                carouselController: CarouselSliderController(),
                                items: recommendedList.map((item) {
                                  // //print('item.prestazione.toJson()');
                                  // //print(item.prestazione.toJson());

                                  return InkWell(
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: (){
                                      // if(item.is_single_event && item != null){
                                      //   Navigator.push(
                                      //       context,
                                      //       PageTransition(
                                      //         duration: const Duration(
                                      //             milliseconds: 500
                                      //         ),
                                      //         alignment: Alignment.center,
                                      //         type: PageTransitionType.fade,
                                      //         child: SingleEventScreen(
                                      //           user: widget.user,
                                      //           singleEvent: item.single_event,
                                      //         ),
                                      //       )
                                      //   );
                                      // }
                                      /*else*/ if(/*!item.is_single_event &&*/ item != null){
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                              duration: const Duration(
                                                  milliseconds: 500
                                              ),
                                              alignment: Alignment.center,
                                              type: PageTransitionType.fade,
                                              child: PrestazioneSlotsScreen(
                                                prestazione: item.prestazione,
                                              ),
                                            )
                                        );
                                      }
                                      else {
                                        return null;
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5, bottom: 10, right: 5, left: 5),
                                      child: Opacity(
                                        opacity: 1,
                                        child: Transform(
                                          alignment: FractionalOffset.topLeft,
                                          transform: Matrix4.translationValues(
                                            0,
                                            0.0,
                                            0.0,
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            elevation: 8,
                                            child: Stack(
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              fit: StackFit.expand,
                                              children: [
                                                // FutureImage(
                                                //   item.prestazione.image != null && item.prestazione.image != ''
                                                //       ? item.prestazione.image! : item.prestazione.business!.profile_image!,
                                                //   width: MediaQuery.of(context).size.width,
                                                // ),
                                                Image.memory(
                                                  // item,
                                                  item.prestazione.image != null && item.prestazione.image != '' ? (imageCacheBusiness.imageCache[item.prestazione.image] ?? Uint8List(0))
                                                      : /*item.prestazione.business?.profile_image != null && item.prestazione.business?.profile_image != '' ?*/ (imageCacheBusiness.imageCache[item.prestazione.business!.profile_image] ?? Uint8List(0)),
                                                  // : Uint8List(0),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, url, error) => Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height,
                                                    color: Colors.transparent,
                                                  ),
                                                  gaplessPlayback: true,
                                                  isAntiAlias: true,
                                                ),
                                                DecoratedBox(
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
                                                  bottom: 20,
                                                  left: 20,
                                                  width: MediaQuery.of(context).size.width * 0.75,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      GradientText(
                                                        /* item.is_single_event && item.single_event.business.name != null
                                                ? item.single_event.business.name
                                                :*/ item.prestazione.business!.name != null
                                                          ? item.prestazione.business!.name! : '',
                                                        // 'A partire da € 60,00',
                                                        maxLines: 1,

                                                        // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                        gradient: /*Gradients.blush*//*item.is_single_event
                                                  ? Gradients.backToFuture
                                                  :*/ LinearGradient(
                                                            begin: Alignment.bottomLeft,
                                                            end: Alignment.topRight,
                                                            colors: [
                                                              // Color(0xff8921aa),
                                                              // Color(0xffDA44bb),
                                                              // Color(0xffDA44bb)

                                                              // Color(0xffFFA818),
                                                              // Color(0xffF68A3D),

                                                              // Color(0xffFFB75E),
                                                              // Color(0xfff46b45),
                                                              // Color(0xffED8F03),

                                                              Color(0xfffd746c),
                                                              Color(0xffff9068),
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
                                                            color: Colors.blue,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                      GradientText(
                                                        /*item.is_single_event && item.single_event.title != null
                                                  ? item.single_event.title
                                                  :*/ item.prestazione.title != null
                                                          ? item.prestazione.title! : '',
                                                        maxLines: 2,
                                                        shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        // gradient: Gradients.haze,
                                                        gradient: Gradients.haze,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 20
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                      /* item.is_single_event
                                                ? SizedBox(height: 2,)
                                                : SizedBox(height: 0,),*/
                                                      /*item.is_single_event && item.single_event.begin_at != null
                                                ? GradientText(
                                              DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                              maxLines: 2,
                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                              // gradient: Gradients.backToFuture,
                                              gradient: Gradients.blush,
                                              // gradient: LinearGradient(
                                              //     begin: Alignment.bottomLeft,
                                              //     end: Alignment.topRight,
                                              //     colors: [
                                              //       Color(0xff8921aa),
                                              //       Color(0xffDA44bb),
                                              //       // Color(0xffDA44bb)
                                              //     ]
                                              // ),
                                              // gradient: LinearGradient(
                                              //     begin: Alignment.bottomLeft,
                                              //     end: Alignment.topRight,
                                              //     colors: [
                                              //       Color(0xff8921aa),
                                              //       Color(0xffDA44bb),
                                              //       // Color(0xffDA44bb)
                                              //     ]
                                              // ),

                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16
                                              ),
                                              textAlign: TextAlign.left,
                                            )
                                                : SizedBox(height: 0, width: 0,),*/
                                                      SizedBox(height: 1,),
                                                      GradientText(
                                                        // item.is_single_event && item.single_event.title != null
                                                        //     ? item.single_event.title
                                                        //     : item.prestazione.title != null
                                                        //     ? item.prestazione.title : '',
                                                        /*item.is_single_event
                                                  ? 'A partire da € 15,00'*//* + NumberFormat.currency(
                                                      // customPattern: '#,##',
                                                        decimalDigits: 2,
                                                        symbol: '',
                                                        locale: 'IT_it'
                                                    ).format(item.single_event.)*//*
                                                  : */'Al prezzo di € ' + NumberFormat.currency(
                                                        // customPattern: '#,##',
                                                          decimalDigits: 2,
                                                          symbol: '',
                                                          locale: 'IT_it'
                                                      ).format(item.prestazione.price ?? 0),
                                                        maxLines: 2,

                                                        // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                        // gradient: Gradients.backToFuture,
                                                        gradient: /*!item.is_single_event
                                                  ?*/ /*Gradients.blush
                                                :*/ LinearGradient(
                                                            begin: Alignment.bottomLeft,
                                                            end: Alignment.topRight,
                                                            colors: [
                                                              // Color(0xff8921aa),
                                                              // Color(0xffDA44bb),

                                                              // Color(0xffFFA818),
                                                              // Color(0xffF68A3D),

                                                              Color(0xffFFA818),
                                                              Color(0xffFFB75E),
                                                              // Color(0xffED8F03),

                                                              // Color(0xffee9ca7),
                                                              // Color(0xffffdde1),
                                                            ]
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    viewportFraction: 1,
                                    autoPlay: true,
                                    // aspectRatio: 16/9,
                                    autoPlayCurve: Curves.easeInOut,
                                    onPageChanged: (i, bho){
                                      // setState(() {
                                      //   // _current = bho.index;
                                      //   _eventsPageController.jumpToPage(bho.index);
                                      // });
                                    }

                                ),
                              ),
                            ),
                          ],
                        ),

                        Visibility(
                          visible: /*Utils.isBusiness ==*/ true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
                                child: Text(
                                  "Con i nostri clienti",
                                  // "Eventi",
                                  style: TextStyle(
                                    fontSize: 20,
                                    //fontFamily: GoogleFonts.abhayaLibre(),
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w700,

                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                // child: CarouselSlider.builder(
                                //   carouselController: CarouselController(),
                                //   itemCount: bestsellersList.length,
                                //   itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                                //     return StaggeredGridView.countBuilder(
                                //         shrinkWrap: true,
                                //         padding: EdgeInsets.only(top: 0, bottom: 0),
                                //         crossAxisCount: 2,
                                //         // reverse: true,
                                //         // staggeredTileBuilder: (i) => StaggeredTile.count(1, i % 2 == 1 ? 1 : .5),
                                //         staggeredTileBuilder: (i) => StaggeredTile.count(1, 1),
                                //         mainAxisSpacing: 0,
                                //         physics: const NeverScrollableScrollPhysics(),
                                //         crossAxisSpacing: 0,
                                //         // itemCount: 3,
                                //         itemCount: 2,
                                //         itemBuilder: (context, i) {
                                //           return InkWell(
                                //             highlightColor: Colors.transparent,
                                //             hoverColor: Colors.transparent,
                                //             focusColor: Colors.transparent,
                                //             splashColor: Colors.transparent,
                                //             onTap: (){
                                //               if(/*!item.is_single_event &&*/ bestsellersList[itemIndex] != null){
                                //                 if(i % 2 == 0){
                                //                   Navigator.push(
                                //                       context,
                                //                       PageTransition(
                                //                         duration: const Duration(
                                //                             milliseconds: 500
                                //                         ),
                                //                         alignment: Alignment.center,
                                //                         type: PageTransitionType.fade,
                                //                         child: PrestazioneScreen(
                                //                           prestazione: bestsellersList[itemIndex],
                                //                         ),
                                //                       )
                                //                   );
                                //                 }
                                //                 else {
                                //                   Navigator.push(
                                //                       context,
                                //                       PageTransition(
                                //                         duration: const Duration(
                                //                             milliseconds: 500
                                //                         ),
                                //                         alignment: Alignment.center,
                                //                         type: PageTransitionType.fade,
                                //                         child: BookingBusinessProfileScreen(
                                //                           bookingBusiness: bestsellersList[itemIndex].business,
                                //                         ),
                                //                       )
                                //                   );
                                //                 }
                                //
                                //                 // //print(i);
                                //               }
                                //               else {
                                //                 return null;
                                //               }
                                //             },
                                //             child: Padding(
                                //               padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                //               child: Opacity(
                                //                 opacity: 1,
                                //                 child: Transform(
                                //                   alignment: FractionalOffset.topLeft,
                                //                   transform: Matrix4.translationValues(
                                //                     0,
                                //                     0.0,
                                //                     0.0,
                                //                   ),
                                //                   child: Card(
                                //                     shape: RoundedRectangleBorder(
                                //                       borderRadius: BorderRadius.circular(10),
                                //                     ),
                                //                     clipBehavior: Clip.antiAliasWithSaveLayer,
                                //                     elevation: 8,
                                //                     child: Stack(
                                //                       clipBehavior: Clip.antiAliasWithSaveLayer,
                                //                       fit: StackFit.expand,
                                //                       children: [
                                //                         // FutureBuilder<dynamic>(
                                //                         //   // future: Future.wait([getImage()]),
                                //                         //   // future: a,
                                //                         //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                                //                         //   // future: getImage('http://192.168.1.10:5000/image?path=image/prestazione/0b061202-d680-458e-a8be-0817cc51a48c/705a9f4a-7ba9-4b57-bfca-f4a33c099711.jpg'),
                                //                         //   // future: getImage('${Utils.httpServerUrl}image?path=${item.image!}'),
                                //                         //   future: getImage('${Utils.httpServerUrl}image?path=${item.image!}'),
                                //                         //   initialData: [],
                                //                         //   builder: (context, snapshot) {
                                //                         //     // print('snapshot');
                                //                         //     // print(snapshot);
                                //                         //     // print('item.business!.profile_image!');
                                //                         //     // print(item.business!.profile_image!);
                                //                         //
                                //                         //     if(snapshot.connectionState == ConnectionState.done){
                                //                         //       return FutureImage(
                                //                         //         // imageUrl: item.image != null && item.image != '' && i % 2 == 0
                                //                         //         //     ? item.image! : item.business!.profile_image!,
                                //                         //         imageUrl: item.image != null && item.image != '' && i % 2 == 0
                                //                         //             ? snapshot.data : item.business!.profile_image!,
                                //                         //         cacheBusiness: CacheBusiness(
                                //                         //             Config(
                                //                         //                 'customCacheKey',
                                //                         //                 stalePeriod: const Duration(days: 7)
                                //                         //             )
                                //                         //         ),
                                //                         //         fit: BoxFit.cover,
                                //                         //         // colorBlendMode: BlendMode.hardLight,
                                //                         //         width: MediaQuery.of(context).size.width,
                                //                         //         // filterQuality: FilterQuality.high,
                                //                         //         // placeholder: (context, url) => Center(
                                //                         //         //     child: CircularProgressIndicator()
                                //                         //         // ),
                                //                         //         errorWidget: (context, url, error) => SizedBox(),
                                //                         //       );
                                //                         //     }
                                //                         //     else {
                                //                         //       return Container(color: Colors.transparent,);
                                //                         //     }
                                //                         //   }
                                //                         // ),
                                //                         FutureImage(
                                //                           bestsellersList[itemIndex].image != null && bestsellersList[itemIndex].image != '' && i % 2 == 0
                                //                             ? bestsellersList[itemIndex].image!
                                //                             : bestsellersList[itemIndex].business!.profile_image!,
                                //                           width: MediaQuery.of(context).size.width,
                                //                         ),
                                //                         // FutureImage(
                                //                         //   item.image != null && item.image != '' && i % 2 == 0
                                //                         //     ? '${Utils.httpServerUrl}image?path=${item.image!}'
                                //                         //     : item.business!.profile_image!,
                                //                         // ),
                                //                         DecoratedBox(
                                //                           decoration: BoxDecoration(
                                //                             // backgroundBlendMode: BlendMode.darken,
                                //                             gradient: LinearGradient(
                                //                               begin: Alignment.bottomLeft,
                                //                               end: Alignment.topRight,
                                //                               colors: [
                                //                                 Colors.black,
                                //                                 // Colors.transparent,
                                //                                 Colors.transparent,
                                //                               ],
                                //                             ),
                                //                           ),
                                //                         ),
                                //                         i % 2 == 0 ? Positioned(
                                //                           bottom: 15,
                                //                           left: 12,
                                //                           width: MediaQuery.of(context).size.width * 0.4,
                                //                           child: Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children: [
                                //                               GradientText(
                                //                                 /* item.is_single_event && item.single_event.business.name != null
                                //                             ? item.single_event.business.name
                                //                             :*/ bestsellersList[itemIndex].business!.name != null
                                //                                   ? bestsellersList[itemIndex].business!.name! : '',
                                //                                 // 'A partire da € 60,00',
                                //                                 maxLines: 3,
                                //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                                 gradient: /*item.is_single_event
                                //                               ? Gradients.backToFuture
                                //                               // :*/ /*Gradients.blush*/
                                //                                 LinearGradient(
                                //                                     begin: Alignment.bottomLeft,
                                //                                     end: Alignment.topRight,
                                //                                     colors: [
                                //                                       // Color(0xff8921aa),
                                //                                       // Color(0xffDA44bb),
                                //                                       // Colors.pink,
                                //                                       // Colors.pinkAccent,
                                //
                                //                                       // Color(0xffFFA818),
                                //                                       // Color(0xffF68A3D),
                                //                                       Color(0xfffd746c),
                                //                                       Color(0xffff9068),
                                //                                     ]
                                //                                 ),
                                //                                 // gradient: LinearGradient(
                                //                                 //     begin: Alignment.bottomLeft,
                                //                                 //     end: Alignment.topRight,
                                //                                 //     colors: [
                                //                                 //       Colors.blue[500],
                                //                                 //       Color(0xffDA44bb),
                                //                                 //
                                //                                 //       Color(0xff8921aa),
                                //                                 //     ]
                                //                                 // ),
                                //                                 style: TextStyle(
                                //                                     color: Colors.blue,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 11.5
                                //                                 ),
                                //                                 textAlign: TextAlign.left,
                                //                               ),
                                //                               GradientText(
                                //                                 /*item.is_single_event && item.single_event.title != null
                                //                               ? item.single_event.title
                                //                               :*/ bestsellersList[itemIndex].title != null
                                //                                   ? bestsellersList[itemIndex].title! : '',
                                //                                 maxLines: 5,
                                //                                 shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                 gradient: Gradients.haze,
                                //                                 style: TextStyle(
                                //                                     color: Colors.white,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 18
                                //                                 ),
                                //                                 textAlign: TextAlign.left,
                                //                               ),
                                //                               /* item.is_single_event
                                //                             ? SizedBox(height: 2,)
                                //                             : SizedBox(height: 0,),*/
                                //                               /*item.is_single_event && item.single_event.begin_at != null
                                //                             ? GradientText(
                                //                           DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                //                           maxLines: 2,
                                //                           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                           // gradient: Gradients.backToFuture,
                                //                           gradient: Gradients.blush,
                                //                           // gradient: LinearGradient(
                                //                           //     begin: Alignment.bottomLeft,
                                //                           //     end: Alignment.topRight,
                                //                           //     colors: [
                                //                           //       Color(0xff8921aa),
                                //                           //       Color(0xffDA44bb),
                                //                           //       // Color(0xffDA44bb)
                                //                           //     ]
                                //                           // ),
                                //                           // gradient: LinearGradient(
                                //                           //     begin: Alignment.bottomLeft,
                                //                           //     end: Alignment.topRight,
                                //                           //     colors: [
                                //                           //       Color(0xff8921aa),
                                //                           //       Color(0xffDA44bb),
                                //                           //       // Color(0xffDA44bb)
                                //                           //     ]
                                //                           // ),
                                //
                                //                           style: TextStyle(
                                //                               color: Colors.blue,
                                //                               fontWeight: FontWeight.w800,
                                //                               fontSize: 16
                                //                           ),
                                //                           textAlign: TextAlign.left,
                                //                         )
                                //                             : SizedBox(height: 0, width: 0,),*/
                                //                               SizedBox(height: 1.5,),
                                //                               GradientText(
                                //                                 // item.is_single_event && item.single_event.title != null
                                //                                 //     ? item.single_event.title
                                //                                 //     : item.prestazione.title != null
                                //                                 //     ? item.prestazione.title : '',
                                //                                 /*item.is_single_event
                                //                               ? 'A partire da € 15,00'*//* + NumberFormat.currency(
                                //                                   // customPattern: '#,##',
                                //                                     decimalDigits: 2,
                                //                                     symbol: '',
                                //                                     locale: 'IT_it'
                                //                                 ).format(item.single_event.)*//*
                                //                               : */'Al prezzo di € ' + NumberFormat.currency(
                                //                                 // customPattern: '#,##',
                                //                                   decimalDigits: 2,
                                //                                   symbol: '',
                                //                                   locale: 'IT_it'
                                //                               ).format(bestsellersList[itemIndex].price),
                                //                                 maxLines: 2,
                                //
                                //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                                 // gradient: Gradients.backToFuture,
                                //                                 gradient: /*!item.is_single_event
                                //                               ?*/ /*Gradients.blush*/
                                //                                 LinearGradient(
                                //                                     begin: Alignment.bottomLeft,
                                //                                     end: Alignment.topRight,
                                //                                     colors: [
                                //                                       // Color(0xff8921aa),
                                //                                       // Color(0xffDA44bb),
                                //                                       // Color(0xffDA44bb)
                                //
                                //                                       // Color(0xffFFA818),
                                //                                       // Color(0xffF68A3D),
                                //
                                //                                       // Color(0xffAE6900),
                                //                                       // Color(0xffCB8A00)
                                //                                       // Color(0xffC82240)
                                //
                                //                                       Color(0xffFFA818),
                                //                                       Color(0xffFFB75E),
                                //
                                //                                       // Color(0xffee9ca7),
                                //                                       // Color(0xffffdde1),
                                //                                     ]
                                //                                 ),
                                //                                 style: TextStyle(
                                //                                     color: Colors.blue,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 11.5
                                //                                 ),
                                //                                 textAlign: TextAlign.left,
                                //                               ),
                                //                               // Text(
                                //                               //   'A partire da € 60,00',
                                //                               //   style: new TextStyle(
                                //                               //       fontWeight: FontWeight.w800,
                                //                               //       fontSize: 15,
                                //                               //
                                //                               //       foreground: Paint()..shader = LinearGradient(
                                //                               //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                //                               //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                //                               // )
                                //                               // LinearGradient(
                                //                               //   begin: Alignment.topLeft,
                                //                               //   end: Alignment.bottomRight,
                                //                               //   colors: gradientColors,
                                //                               // ).createShader(
                                //                               //     Rect.fromCircle(
                                //                               //       center: Offset(fontSize, -200),
                                //                               //       radius: fontSize / 3,
                                //                               //     )
                                //                               // );
                                //                             ],
                                //                           ),
                                //                         ) : Positioned(
                                //                           bottom: 15,
                                //                           left: 15,
                                //                           width: MediaQuery.of(context).size.width * 0.38,
                                //                           child: Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children: [
                                //                               GradientText(
                                //                                 bestsellersList[itemIndex].business!.category!.name != null
                                //                                     ? bestsellersList[itemIndex].business!.category!.name! : '',
                                //                                 maxLines: 2,
                                //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                                 // gradient: Gradients.backToFuture,
                                //                                 gradient: /*!item.is_single_event ?*/ /*Gradients.blush*/LinearGradient(
                                //                                     begin: Alignment.bottomLeft,
                                //                                     end: Alignment.topRight,
                                //                                     colors: [
                                //                                       // Color(0xff8921aa),
                                //                                       // Color(0xffDA44bb),
                                //
                                //                                       // Color(0xffFFB75E),
                                //                                       // Color(0xffED8F03),
                                //
                                //                                       Color(0xfffd746c),
                                //                                       Color(0xffff9068),
                                //                                     ]
                                //                                 ),
                                //                                 style: TextStyle(
                                //                                     color: Colors.blue,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 12
                                //                                 ),
                                //                                 textAlign: TextAlign.left,
                                //                               ),
                                //                               SizedBox(height: 1,),
                                //                               /*Gradient*/Text(
                                //                                 /* item.is_single_event && item.single_event.business.name != null
                                //                             ? item.single_event.business.name
                                //                             :*/ bestsellersList[itemIndex].business!.name != null
                                //                                   ? bestsellersList[itemIndex].business!.name! : '',
                                //                                 // 'A partire da € 60,00',
                                //                                 maxLines: 6,
                                //                                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                //                                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                //                                 /*gradient: item.is_single_event
                                //                               ? Gradients.backToFuture
                                //                               :*/
                                //                                 // LinearGradient(
                                //                                 //     begin: Alignment.bottomLeft,
                                //                                 //     end: Alignment.topRight,
                                //                                 //     colors: [
                                //                                 //       Color(0xff8921aa),
                                //                                 //       Color(0xffDA44bb),
                                //                                 //       // Colors.pink,
                                //                                 //       // Colors.pinkAccent,
                                //                                 //     ]
                                //                                 // ),
                                //                                 // gradient: LinearGradient(
                                //                                 //     begin: Alignment.bottomLeft,
                                //                                 //     end: Alignment.topRight,
                                //                                 //     colors: [
                                //                                 //       Colors.blue[500],
                                //                                 //       Color(0xffDA44bb),
                                //                                 //
                                //                                 //       Color(0xff8921aa),
                                //                                 //     ]
                                //                                 // ),
                                //                                 style: TextStyle(
                                //                                     color: Colors.white,
                                //                                     fontWeight: FontWeight.w700,
                                //                                     fontSize: 16
                                //                                 ),
                                //                                 textAlign: TextAlign.left,
                                //                               ),
                                //                               // Text(
                                //                               //   'A partire da € 60,00',
                                //                               //   style: new TextStyle(
                                //                               //       fontWeight: FontWeight.w800,
                                //                               //       fontSize: 15,
                                //                               //
                                //                               //       foreground: Paint()..shader = LinearGradient(
                                //                               //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                //                               //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                //                               // )
                                //                               // LinearGradient(
                                //                               //   begin: Alignment.topLeft,
                                //                               //   end: Alignment.bottomRight,
                                //                               //   colors: gradientColors,
                                //                               // ).createShader(
                                //                               //     Rect.fromCircle(
                                //                               //       center: Offset(fontSize, -200),
                                //                               //       radius: fontSize / 3,
                                //                               //     )
                                //                               // );
                                //                             ],
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //           );
                                //         }
                                //     );
                                //   },
                                //   options: CarouselOptions(
                                //       enlargeCenterPage: true,
                                //       viewportFraction: 1,
                                //       autoPlay: true,
                                //       // aspectRatio: 16/9,
                                //       autoPlayCurve: Curves.easeInOut,
                                //       onPageChanged: (i, bho){
                                //         // setState(() {
                                //         //   // _current = bho.index;
                                //         //   _eventsPageController.jumpToPage(bho.index);
                                //         // });
                                //       }
                                //   ),
                                // ),
                                child: CarouselSlider(
                                  carouselController: CarouselSliderController(),
                                  // items: postProvider.postList.map((item) {
                                  items: homeBusinessPostList.map((item) {
                                    // //print('item.prestazione.toJson()');
                                    // //print(item.prestazione.toJson());

                                    return StaggeredGridView.countBuilder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(top: 0, bottom: 0),
                                        crossAxisCount: 2,
                                        // reverse: true,
                                        // staggeredTileBuilder: (i) => StaggeredTile.count(1, i % 2 == 1 ? 1 : .5),
                                        staggeredTileBuilder: (i) => StaggeredTile.count(1, 2),
                                        mainAxisSpacing: 0,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisSpacing: 0,
                                        // itemCount: 3,
                                        itemCount: 2,
                                        itemBuilder: (context, i) {
                                          if(i % 2 == 0){
                                            return InkWell(
                                              highlightColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: (){
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        duration: const Duration(milliseconds: 500),
                                                        alignment: Alignment.center,
                                                        type: PageTransitionType.fade,
                                                        child: PostFullScreen(
                                                          // memoryImage: imageCacheBusiness.getImageFromCache(userPostList[i].image_url!)!,
                                                          businessPost: item,
                                                          isNetworkLoaded: true,
                                                        )
                                                    )
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                                child: Opacity(
                                                  opacity: 1,
                                                  child: Transform(
                                                    alignment: FractionalOffset.topLeft,
                                                    transform: Matrix4.translationValues(
                                                      0,
                                                      0.0,
                                                      0.0,
                                                    ),
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      elevation: 8,
                                                      child: Stack(
                                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                                          fit: StackFit.expand,
                                                          children: [
                                                            // FutureImage(
                                                            //   // item['post_image_url'],
                                                            //   item.image_url!,
                                                            //   width: MediaQuery.of(context).size.width,
                                                            //   forceNetworkImage: false,
                                                            // ),
                                                            Image.memory(
                                                              // item,
                                                              /*imageCacheBusiness.imageCache[item.image/*['prestazione_image']*/] != null && item.image/*['prestazione_image']*/ != '' && i.isEven
                                                                  ?*/ imageCacheBusiness.imageCache[item.image_url/*['prestazione_image']*/]!,
                                                                  // : (imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/] != null && item.business!.profile_image/*['business_profile_image']*/ != '' && i.isOdd
                                                                  // ? imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/]!
                                                                  // : Uint8List(0)
                                                              // ),
                                                              width: MediaQuery.of(context).size.width,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, url, error) => Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                height: MediaQuery.of(context).size.height,
                                                                color: Colors.transparent,
                                                              ),
                                                              gaplessPlayback: true,
                                                              isAntiAlias: true,
                                                            ),
                                                            DecoratedBox(
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
                                                                    top: MediaQuery.of(context).size.height * .05,
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
                                                                          width: 50,
                                                                          height: 130,
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
                                                                                        postProvider.isLikedHomePost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                                                                        color: postProvider.isLikedHomePost ? Colors.red : Colors.grey[50],
                                                                                        // color: Colors.red[500],
                                                                                        // color: Colors.pink[300],
                                                                                        size: 25,
                                                                                      ),
                                                                                      SizedBox(height: 5,),
                                                                                      Text(
                                                                                        // '27',
                                                                                        /*postLikes*/postProvider.homePostLikes.length.toString(),
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
                                                                                        size: 25,
                                                                                      ),
                                                                                      SizedBox(height: 5,),
                                                                                      Text(
                                                                                        // '320',
                                                                                        // bookingPostCommentNumber.toString(),
                                                                                        //   postProvider.comments!.length.toString(),
                                                                                          postProvider.homePostComments.length.toString(),
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
                                                                              child: item.user!.profile_image != null && item.user!.profile_image != '' ? /*FutureImage*/Image.memory(
                                                                                // item.user!.profile_image ?? '',
                                                                                imageCacheBusiness.imageCache[item.user!.profile_image]!,
                                                                                width: 25,
                                                                                height: 25,
                                                                                fit: BoxFit.cover,
                                                                                gaplessPlayback: true,
                                                                                isAntiAlias: true,
                                                                                errorBuilder: (context, url, error) => Container(
                                                                                  width: 25,
                                                                                  height: 25,
                                                                                ),
                                                                              ) : Icon(
                                                                                Icons.account_circle_rounded,
                                                                                color: Colors.grey[300],
                                                                                size: 35,
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 5,),
                                                                            GradientText(
                                                                              // post.business!.name ?? '',
                                                                              // '@' + post.user!.username! ?? '',
                                                                              item.user!.name ?? '',
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
                                                                              // child: FutureImage(
                                                                              //   // post.prestazione!.image ?? '',
                                                                              //   item.prestazione!.image != null && item.prestazione!.image != ''
                                                                              //       ? item.prestazione!.image!
                                                                              //       : item.business!.profile_image!,
                                                                              //   width: 30,
                                                                              //   height: 30,
                                                                              // ),
                                                                              child: Image.memory(
                                                                                  item.prestazione!.image != null && item.prestazione!.image != ''
                                                                                    ? (imageCacheBusiness.imageCache[item.prestazione!.image] ?? Uint8List(0))
                                                                                    : (imageCacheBusiness.imageCache[item.prestazione!.business!.profile_image] ?? Uint8List(0)),
                                                                                  width: 30,
                                                                                  height: 30,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, url, error) => Container(
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    height: MediaQuery.of(context).size.height,
                                                                                    color: Colors.transparent,
                                                                                  ),
                                                                                  gaplessPlayback: true,
                                                                                isAntiAlias: true,
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 8,),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                GradientText(
                                                                                  // post.business!.name ?? '',
                                                                                  // post.booking!.prestazione!.title ?? '',
                                                                                  item.prestazione!.title ?? '',
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
                                                                                  item.business!.name ?? '',
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
                                                                      SizedBox(height: item.description != null && item.description != '' ? 12 : 0,),
                                                                      Visibility(
                                                                        visible: item.description != null,
                                                                        child: Container(
                                                                          width: MediaQuery.of(context).size.width * .4,
                                                                          child: GradientText(
                                                                            item.description ?? '',
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
                                                                      SizedBox(height: item.description != null && item.description != '' ? 12 : 0,),
                                                                      Container(
                                                                        // width: MediaQuery.of(context).size.width * .3,
                                                                        child: Marquee(
                                                                          child: Text(
                                                                            // post.created_at!,
                                                                            DateFormat.yMMMd('it_IT').format(item.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                                                + ' alle ' + item.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
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
                                                            // Positioned(
                                                            //   bottom: 15,
                                                            //   left: 12,
                                                            //   width: MediaQuery.of(context).size.width * 0.4,
                                                            //   child: Column(
                                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                                            //     children: [
                                                            //       // GradientText(
                                                            //       //   // item['prestazione_title'],
                                                            //       //   // '60 min',
                                                            //       //   // "${item['prestazione_duration'].toInt()} min",
                                                            //       //   "${item.prestazione!.duration} min",
                                                            //       //   // 'A partire da € 60,00',
                                                            //       //   maxLines: 1,
                                                            //       //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                            //       //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                            //       //   gradient: LinearGradient(
                                                            //       //       begin: Alignment.bottomLeft,
                                                            //       //       end: Alignment.topRight,
                                                            //       //       colors: [
                                                            //       //         // Color(0xff8921aa),
                                                            //       //         // Color(0xffDA44bb),
                                                            //       //         // Colors.pink,
                                                            //       //         // Colors.pinkAccent,
                                                            //       //
                                                            //       //         // Color(0xffFFA818),
                                                            //       //         // Color(0xffF68A3D),
                                                            //       //         Color(0xfffd746c),
                                                            //       //         Color(0xffff9068),
                                                            //       //       ]
                                                            //       //   ),
                                                            //       //   // gradient: LinearGradient(
                                                            //       //   //     begin: Alignment.bottomLeft,
                                                            //       //   //     end: Alignment.topRight,
                                                            //       //   //     colors: [
                                                            //       //   //       Colors.blue[500],
                                                            //       //   //       Color(0xffDA44bb),
                                                            //       //   //
                                                            //       //   //       Color(0xff8921aa),
                                                            //       //   //     ]
                                                            //       //   // ),
                                                            //       //   style: TextStyle(
                                                            //       //       color: Colors.blue,
                                                            //       //       fontWeight: FontWeight.w700,
                                                            //       //       fontSize: 13
                                                            //       //   ),
                                                            //       //   textAlign: TextAlign.left,
                                                            //       // ),
                                                            //       // SizedBox(height: 2,),
                                                            //       SizedBox(height: 10,),
                                                            //       Container(
                                                            //         width: MediaQuery.of(context).size.width * .37,
                                                            //         child: Text(
                                                            //           // item['prestazione_title'],
                                                            //           item.description ?? '',
                                                            //           maxLines: 3,
                                                            //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                            //           // gradient: Gradients.haze,
                                                            //           overflow: TextOverflow.ellipsis,
                                                            //           style: TextStyle(
                                                            //               color: Colors.white,
                                                            //               fontWeight: FontWeight.w700,
                                                            //               fontSize: 14
                                                            //           ),
                                                            //           textAlign: TextAlign.left,
                                                            //         ),
                                                            //       ),
                                                            //       SizedBox(height: 10,),
                                                            //       Container(
                                                            //         width: MediaQuery.of(context).size.width * .4,
                                                            //         child: Marquee(
                                                            //           child: Text(
                                                            //             DateFormat.yMMMMd('it_IT').format(item.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                                            //                 + ' alle ' + item.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                            //             maxLines: 1,
                                                            //             style: TextStyle(
                                                            //                 color: Colors.grey[100],
                                                            //                 fontWeight: FontWeight.w700,
                                                            //                 fontSize: 12
                                                            //             ),
                                                            //             textAlign: TextAlign.left,
                                                            //           ),
                                                            //         ),
                                                            //       ),
                                                            //       // Text(
                                                            //       //   'A partire da € 60,00',
                                                            //       //   style: new TextStyle(
                                                            //       //       fontWeight: FontWeight.w800,
                                                            //       //       fontSize: 15,
                                                            //       //
                                                            //       //       foreground: Paint()..shader = LinearGradient(
                                                            //       //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                                            //       //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                                            //       // )
                                                            //       // LinearGradient(
                                                            //       //   begin: Alignment.topLeft,
                                                            //       //   end: Alignment.bottomRight,
                                                            //       //   colors: gradientColors,
                                                            //       // ).createShader(
                                                            //       //     Rect.fromCircle(
                                                            //       //       center: Offset(fontSize, -200),
                                                            //       //       radius: fontSize / 3,
                                                            //       //     )
                                                            //       // );
                                                            //     ],
                                                            //   ),
                                                            // )
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          else {
                                            // return SizedBox();
                                            return StaggeredGridView.countBuilder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(top: 0, bottom: 0),
                                                crossAxisCount: 1,
                                                // reverse: true,
                                                // staggeredTileBuilder: (i) => StaggeredTile.count(1, i % 2 == 1 ? 1 : .5),
                                                staggeredTileBuilder: (i) => StaggeredTile.count(2, 1),
                                                mainAxisSpacing: 0,
                                                physics: const NeverScrollableScrollPhysics(),
                                                crossAxisSpacing: 0,
                                                // itemCount: 3,
                                                itemCount: 2,
                                                itemBuilder: (context, i) {
                                                  if(i % 2 == 0){
                                                    return InkWell(
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                      focusColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      onTap: (){
                                                        Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              duration: const Duration(milliseconds: 500),
                                                              alignment: Alignment.center,
                                                              type: PageTransitionType.fade,
                                                              child: PrestazioneSlotsScreen(
                                                                prestazione: item.prestazione,
                                                              ),
                                                            )
                                                        );
                                                        // LaunchReview.launch(
                                                        //   androidAppId: "com.nurebo.nurebo",
                                                        //   // iOSAppId: "585027354",
                                                        //   writeReview: false,
                                                        // );
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                                        child: Opacity(
                                                          opacity: 1,
                                                          child: Transform(
                                                            alignment: FractionalOffset.topLeft,
                                                            transform: Matrix4.translationValues(
                                                              0,
                                                              0.0,
                                                              0.0,
                                                            ),
                                                            child: Card(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              elevation: 8,
                                                              child: Stack(
                                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                  fit: StackFit.expand,
                                                                  children: [
                                                                    // FutureImage(
                                                                    //   // item['prestazione_image'],
                                                                    //   // item.prestazione!.image!,
                                                                    //   item.prestazione!.image != null && item.prestazione!.image != ''
                                                                    //       ? item.prestazione!.image!
                                                                    //       : item.business!.profile_image!,
                                                                    //   width: MediaQuery.of(context).size.width,
                                                                    // ),
                                                                    Image.memory(
                                                                      item.prestazione!.image != null && item.prestazione!.image != ''
                                                                        ? (imageCacheBusiness.imageCache[item.prestazione!.image] ?? Uint8List(0))
                                                                        : (imageCacheBusiness.imageCache[item.prestazione!.business!.profile_image] ?? Uint8List(0)),
                                                                      width: MediaQuery.of(context).size.width,
                                                                      fit: BoxFit.cover,
                                                                      errorBuilder: (context, url, error) => Container(
                                                                        width: MediaQuery.of(context).size.width,
                                                                        height: MediaQuery.of(context).size.height,
                                                                        color: Colors.transparent,
                                                                      ),
                                                                      gaplessPlayback: true,
                                                                      isAntiAlias: true,
                                                                    ),
                                                                    DecoratedBox(
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
                                                                      left: 12,
                                                                      width: MediaQuery.of(context).size.width * 0.4,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          GradientText(
                                                                            // item['prestazione_title'],
                                                                            // '60 min',
                                                                            // "${item['prestazione_duration'].toInt()} min",
                                                                            "${item.prestazione!.duration} min",
                                                                            // 'A partire da € 60,00',
                                                                            maxLines: 1,
                                                                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                            // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                            gradient: LinearGradient(
                                                                                begin: Alignment.bottomLeft,
                                                                                end: Alignment.topRight,
                                                                                colors: [
                                                                                  // Color(0xff8921aa),
                                                                                  // Color(0xffDA44bb),
                                                                                  // Colors.pink,
                                                                                  // Colors.pinkAccent,

                                                                                  // Color(0xffFFA818),
                                                                                  // Color(0xffF68A3D),
                                                                                  Color(0xfffd746c),
                                                                                  Color(0xffff9068),
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
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 13
                                                                            ),
                                                                            textAlign: TextAlign.left,
                                                                          ),
                                                                          SizedBox(height: 2,),
                                                                          /*Gradient*/Text(
                                                                            // item['prestazione_title'],
                                                                            item.prestazione!.title!,
                                                                            maxLines: 5,
                                                                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                            // gradient: Gradients.haze,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 18
                                                                            ),
                                                                            textAlign: TextAlign.left,
                                                                          ),
                                                                          SizedBox(height: 2,),
                                                                          GradientText(
                                                                            !item.prestazione!.is_price_range ? 'Al prezzo di € ${NumberFormat.currency(
                                                                              // customPattern: '#,##',
                                                                                decimalDigits: 2,
                                                                                symbol: '',
                                                                                locale: 'IT_it'
                                                                              // ).format(item['prestazione_price']),
                                                                            ).format(item.prestazione!.price!)}' : 'A partire da € ${NumberFormat.currency(
                                                                              // customPattern: '#,##',
                                                                                decimalDigits: 2,
                                                                                symbol: '',
                                                                                locale: 'IT_it'
                                                                              // ).format(item['prestazione_price']),
                                                                            ).format(item.prestazione!.price_min!)}',
                                                                            maxLines: 1,
                                                                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                            // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                            // gradient: Gradients.backToFuture,
                                                                            gradient: LinearGradient(
                                                                                begin: Alignment.bottomLeft,
                                                                                end: Alignment.topRight,
                                                                                colors: [
                                                                                  // Color(0xff8921aa),
                                                                                  // Color(0xffDA44bb),
                                                                                  // Color(0xffDA44bb)

                                                                                  // Color(0xffFFA818),
                                                                                  // Color(0xffF68A3D),

                                                                                  // Color(0xffAE6900),
                                                                                  // Color(0xffCB8A00)
                                                                                  // Color(0xffC82240)

                                                                                  Color(0xffFFA818),
                                                                                  Color(0xffFFB75E),

                                                                                  // Color(0xffee9ca7),
                                                                                  // Color(0xffffdde1),
                                                                                ]
                                                                            ),
                                                                            style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 13
                                                                            ),
                                                                            textAlign: TextAlign.left,
                                                                          ),
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
                                                                    )
                                                                  ]
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  else {
                                                    return InkWell(
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                      focusColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      onTap: (){
                                                        Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              duration: const Duration(milliseconds: 500),
                                                              alignment: Alignment.center,
                                                              type: PageTransitionType.fade,
                                                              child: UserProfileScreen(
                                                                isTab: false,
                                                                // userId: item.user!.id!,
                                                                user: item.user!,
                                                              ),
                                                            )
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                                        child: Opacity(
                                                          opacity: 1,
                                                          child: Transform(
                                                            alignment: FractionalOffset.topLeft,
                                                            transform: Matrix4.translationValues(
                                                              0,
                                                              0.0,
                                                              0.0,
                                                            ),
                                                            child: Card(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              elevation: 8,
                                                              child: Stack(
                                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                  fit: StackFit.expand,
                                                                  children: [
                                                                    // item.user!.profile_image != null && item.user!.profile_image != '' ? FutureImage(
                                                                    //   // item['user_profile_image'],
                                                                    //   item.user!.profile_image ?? '',
                                                                    //   width: MediaQuery.of(context).size.width,
                                                                    // ) : Image.asset(
                                                                    //   // Icons.account_circle_rounded,
                                                                    //   // 'assets/image/default-profile-account-unknown.jpg',
                                                                    //   'assets/image/default-avatar-profile-icon.jpg',
                                                                    //   // color: Colors.grey[700],
                                                                    //   width: MediaQuery.of(context).size.width,
                                                                    //   fit: BoxFit.cover,
                                                                    //   // size: 45,
                                                                    // ),
                                                                    imageCacheBusiness.imageCache[item.user!.profile_image] != null ? Image.memory(
                                                                        imageCacheBusiness.imageCache[item.user!.profile_image]!,
                                                                        width: MediaQuery.of(context).size.width,
                                                                        fit: BoxFit.cover,
                                                                        errorBuilder: (context, url, error) => Container(
                                                                          width: MediaQuery.of(context).size.width,
                                                                          height: MediaQuery.of(context).size.height,
                                                                          color: Colors.transparent,
                                                                        ),
                                                                        gaplessPlayback: true,
                                                                        isAntiAlias: true,
                                                                      ) : Image.asset(
                                                                        // Icons.account_circle_rounded,
                                                                        // 'assets/image/default-profile-account-unknown.jpg',
                                                                        'assets/image/default-avatar-profile-icon.jpg',
                                                                        // color: Colors.grey[700],
                                                                        width: MediaQuery.of(context).size.width,
                                                                        fit: BoxFit.cover,
                                                                        // size: 45,
                                                                    ),
                                                                    DecoratedBox(
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
                                                                      left: 12,
                                                                      width: MediaQuery.of(context).size.width * 0.4,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          // GradientText(
                                                                          //   // item['prestazione_title'],
                                                                          //   // '60 min',
                                                                          //   // "${item['prestazione_duration'].toInt()} min",
                                                                          //   // "@${item['user_username']}",
                                                                          //   "@${item.user!.username}",
                                                                          //   // 'A partire da € 60,00',
                                                                          //   maxLines: 1,
                                                                          //   overflow: TextOverflow.ellipsis,
                                                                          //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                          //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                          //   gradient: LinearGradient(
                                                                          //       begin: Alignment.bottomLeft,
                                                                          //       end: Alignment.topRight,
                                                                          //       colors: [
                                                                          //         // Color(0xff8921aa),
                                                                          //         // Color(0xffDA44bb),
                                                                          //         // Colors.pink,
                                                                          //         // Colors.pinkAccent,
                                                                          //
                                                                          //         // Color(0xffFFA818),
                                                                          //         // Color(0xffF68A3D),
                                                                          //
                                                                          //         // Color(0xfffd746c),
                                                                          //         // Color(0xffff9068),
                                                                          //
                                                                          //         Colors.yellow[600]!,
                                                                          //         Color(0xffFFA818),
                                                                          //       ]
                                                                          //   ),
                                                                          //   // gradient: LinearGradient(
                                                                          //   //     begin: Alignment.bottomLeft,
                                                                          //   //     end: Alignment.topRight,
                                                                          //   //     colors: [
                                                                          //   //       Colors.blue[500],
                                                                          //   //       Color(0xffDA44bb),
                                                                          //   //
                                                                          //   //       Color(0xff8921aa),
                                                                          //   //     ]
                                                                          //   // ),
                                                                          //   style: TextStyle(
                                                                          //       color: Colors.blue,
                                                                          //       fontWeight: FontWeight.w600,
                                                                          //       fontSize: 15
                                                                          //   ),
                                                                          //   textAlign: TextAlign.left,
                                                                          // ),
                                                                          // SizedBox(height: 2,),
                                                                          /*Gradient*/Text(
                                                                            // item['user_name'],
                                                                            item.user!.name!,
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                            // gradient: Gradients.haze,
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 18
                                                                            ),
                                                                            textAlign: TextAlign.left,
                                                                          ),
                                                                          // SizedBox(height: 2,),
                                                                          // GradientText(
                                                                          //   "@${item['user_username']}",
                                                                          //   maxLines: 2,
                                                                          //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                                          //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                                          //   // gradient: Gradients.backToFuture,
                                                                          //   gradient: LinearGradient(
                                                                          //       begin: Alignment.bottomLeft,
                                                                          //       end: Alignment.topRight,
                                                                          //       colors: [
                                                                          //         // Color(0xff8921aa),
                                                                          //         // Color(0xffDA44bb),
                                                                          //         // Color(0xffDA44bb)
                                                                          //
                                                                          //         // Color(0xffFFA818),
                                                                          //         // Color(0xffF68A3D),
                                                                          //
                                                                          //         // Color(0xffAE6900),
                                                                          //         // Color(0xffCB8A00)
                                                                          //         // Color(0xffC82240)
                                                                          //
                                                                          //         Color(0xffFFA818),
                                                                          //         Color(0xffFFB75E),
                                                                          //
                                                                          //         // Color(0xffee9ca7),
                                                                          //         // Color(0xffffdde1),
                                                                          //       ]
                                                                          //   ),
                                                                          //   style: TextStyle(
                                                                          //       color: Colors.blue,
                                                                          //       fontWeight: FontWeight.w700,
                                                                          //       fontSize: 11.5
                                                                          //   ),
                                                                          //   textAlign: TextAlign.left,
                                                                          // ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                            );
                                          }
                                          // return InkWell(
                                          //   highlightColor: Colors.transparent,
                                          //   hoverColor: Colors.transparent,
                                          //   focusColor: Colors.transparent,
                                          //   splashColor: Colors.transparent,
                                          //   onTap: (){
                                          //     if(/*!item.is_single_event &&*/ item != null){
                                          //       if(i % 2 == 0){
                                          //         Navigator.push(
                                          //             context,
                                          //             PageTransition(
                                          //               duration: const Duration(
                                          //                   milliseconds: 500
                                          //               ),
                                          //               alignment: Alignment.center,
                                          //               type: PageTransitionType.fade,
                                          //               child: PrestazioneScreen(
                                          //                 prestazione: item,
                                          //               ),
                                          //             )
                                          //         );
                                          //       }
                                          //       else {
                                          //         Navigator.push(
                                          //             context,
                                          //             PageTransition(
                                          //               duration: const Duration(
                                          //                   milliseconds: 500
                                          //               ),
                                          //               alignment: Alignment.center,
                                          //               type: PageTransitionType.fade,
                                          //               child: BookingBusinessProfileScreen(
                                          //                 bookingBusiness: item.business,
                                          //               ),
                                          //             )
                                          //         );
                                          //       }
                                          //
                                          //       // //print(i);
                                          //     }
                                          //     else {
                                          //       return null;
                                          //     }
                                          //   },
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                          //     child: Opacity(
                                          //       opacity: 1,
                                          //       child: Transform(
                                          //         alignment: FractionalOffset.topLeft,
                                          //         transform: Matrix4.translationValues(
                                          //           0,
                                          //           0.0,
                                          //           0.0,
                                          //         ),
                                          //         child: Card(
                                          //           shape: RoundedRectangleBorder(
                                          //             borderRadius: BorderRadius.circular(10),
                                          //           ),
                                          //           clipBehavior: Clip.antiAliasWithSaveLayer,
                                          //           elevation: 8,
                                          //           child: Stack(
                                          //             clipBehavior: Clip.antiAliasWithSaveLayer,
                                          //             fit: StackFit.expand,
                                          //             children: [
                                          //               // FutureImage(
                                          //               //   item.image != null && item.image != '' && i % 2 == 0
                                          //               //       ? item.image! : item.business!.profile_image!,
                                          //               //   width: MediaQuery.of(context).size.width,
                                          //               //   // forceNetworkImage: true,
                                          //               // ),
                                          //               Image.memory(
                                          //                 // item,
                                          //                 imageCacheBusiness.imageCache[item.image/*['prestazione_image']*/] != null && item.image/*['prestazione_image']*/ != '' && i.isEven
                                          //                     ? imageCacheBusiness.imageCache[item.image/*['prestazione_image']*/]!
                                          //                     : (imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/] != null && item.business!.profile_image/*['business_profile_image']*/ != '' && i.isOdd
                                          //                     ? imageCacheBusiness.imageCache[item.business!.profile_image/*['business_profile_image']*/]!
                                          //                     : Uint8List(0)
                                          //                 ),
                                          //                 width: MediaQuery.of(context).size.width,
                                          //                 fit: BoxFit.cover,
                                          //                 errorBuilder: (context, url, error) => Container(
                                          //                   width: MediaQuery.of(context).size.width,
                                          //                   height: MediaQuery.of(context).size.height,
                                          //                   color: Colors.transparent,
                                          //                 ),
                                          //                 gaplessPlayback: true,
                                          //                 isAntiAlias: true,
                                          //               ),
                                          //               DecoratedBox(
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
                                          //               i % 2 == 0 ? Positioned(
                                          //                 bottom: 15,
                                          //                 left: 12,
                                          //                 width: MediaQuery.of(context).size.width * 0.4,
                                          //                 child: Column(
                                          //                   crossAxisAlignment: CrossAxisAlignment.start,
                                          //                   children: [
                                          //                     GradientText(
                                          //                       /* item.is_single_event && item.single_event.business.name != null
                                          //                   ? item.single_event.business.name
                                          //                   :*/ item.business!.name != null
                                          //                         ? item.business!.name! : '',
                                          //                       // 'A partire da € 60,00',
                                          //                       maxLines: 3,
                                          //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //                       gradient: /*item.is_single_event
                                          //                     ? Gradients.backToFuture
                                          //                     // :*/ /*Gradients.blush*/
                                          //                       LinearGradient(
                                          //                           begin: Alignment.bottomLeft,
                                          //                           end: Alignment.topRight,
                                          //                           colors: [
                                          //                             // Color(0xff8921aa),
                                          //                             // Color(0xffDA44bb),
                                          //                             // Colors.pink,
                                          //                             // Colors.pinkAccent,
                                          //
                                          //                             // Color(0xffFFA818),
                                          //                             // Color(0xffF68A3D),
                                          //                             Color(0xfffd746c),
                                          //                             Color(0xffff9068),
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
                                          //                           fontSize: 11.5
                                          //                       ),
                                          //                       textAlign: TextAlign.left,
                                          //                     ),
                                          //                     GradientText(
                                          //                       /*item.is_single_event && item.single_event.title != null
                                          //                     ? item.single_event.title
                                          //                     :*/ item.title != null
                                          //                         ? item.title! : '',
                                          //                       maxLines: 5,
                                          //                       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                       gradient: Gradients.haze,
                                          //                       style: TextStyle(
                                          //                           color: Colors.white,
                                          //                           fontWeight: FontWeight.w700,
                                          //                           fontSize: 18
                                          //                       ),
                                          //                       textAlign: TextAlign.left,
                                          //                     ),
                                          //                     /* item.is_single_event
                                          //                   ? SizedBox(height: 2,)
                                          //                   : SizedBox(height: 0,),*/
                                          //                     /*item.is_single_event && item.single_event.begin_at != null
                                          //                   ? GradientText(
                                          //                 DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                          //                 maxLines: 2,
                                          //                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //                 // gradient: Gradients.backToFuture,
                                          //                 gradient: Gradients.blush,
                                          //                 // gradient: LinearGradient(
                                          //                 //     begin: Alignment.bottomLeft,
                                          //                 //     end: Alignment.topRight,
                                          //                 //     colors: [
                                          //                 //       Color(0xff8921aa),
                                          //                 //       Color(0xffDA44bb),
                                          //                 //       // Color(0xffDA44bb)
                                          //                 //     ]
                                          //                 // ),
                                          //                 // gradient: LinearGradient(
                                          //                 //     begin: Alignment.bottomLeft,
                                          //                 //     end: Alignment.topRight,
                                          //                 //     colors: [
                                          //                 //       Color(0xff8921aa),
                                          //                 //       Color(0xffDA44bb),
                                          //                 //       // Color(0xffDA44bb)
                                          //                 //     ]
                                          //                 // ),
                                          //
                                          //                 style: TextStyle(
                                          //                     color: Colors.blue,
                                          //                     fontWeight: FontWeight.w800,
                                          //                     fontSize: 16
                                          //                 ),
                                          //                 textAlign: TextAlign.left,
                                          //               )
                                          //                   : SizedBox(height: 0, width: 0,),*/
                                          //                     SizedBox(height: 1.5,),
                                          //                     GradientText(
                                          //                       // item.is_single_event && item.single_event.title != null
                                          //                       //     ? item.single_event.title
                                          //                       //     : item.prestazione.title != null
                                          //                       //     ? item.prestazione.title : '',
                                          //                       /*item.is_single_event
                                          //                     ? 'A partire da € 15,00'*//* + NumberFormat.currency(
                                          //                         // customPattern: '#,##',
                                          //                           decimalDigits: 2,
                                          //                           symbol: '',
                                          //                           locale: 'IT_it'
                                          //                       ).format(item.single_event.)*//*
                                          //                     : */'Al prezzo di € ' + NumberFormat.currency(
                                          //                       // customPattern: '#,##',
                                          //                         decimalDigits: 2,
                                          //                         symbol: '',
                                          //                         locale: 'IT_it'
                                          //                     ).format(item.price),
                                          //                       maxLines: 2,
                                          //
                                          //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //                       // gradient: Gradients.backToFuture,
                                          //                       gradient: /*!item.is_single_event
                                          //                     ?*/ /*Gradients.blush*/
                                          //                       LinearGradient(
                                          //                           begin: Alignment.bottomLeft,
                                          //                           end: Alignment.topRight,
                                          //                           colors: [
                                          //                             // Color(0xff8921aa),
                                          //                             // Color(0xffDA44bb),
                                          //                             // Color(0xffDA44bb)
                                          //
                                          //                             // Color(0xffFFA818),
                                          //                             // Color(0xffF68A3D),
                                          //
                                          //                             // Color(0xffAE6900),
                                          //                             // Color(0xffCB8A00)
                                          //                             // Color(0xffC82240)
                                          //
                                          //                             Color(0xffFFA818),
                                          //                             Color(0xffFFB75E),
                                          //
                                          //                             // Color(0xffee9ca7),
                                          //                             // Color(0xffffdde1),
                                          //                           ]
                                          //                       ),
                                          //                       style: TextStyle(
                                          //                           color: Colors.blue,
                                          //                           fontWeight: FontWeight.w700,
                                          //                           fontSize: 11.5
                                          //                       ),
                                          //                       textAlign: TextAlign.left,
                                          //                     ),
                                          //                     // Text(
                                          //                     //   'A partire da € 60,00',
                                          //                     //   style: new TextStyle(
                                          //                     //       fontWeight: FontWeight.w800,
                                          //                     //       fontSize: 15,
                                          //                     //
                                          //                     //       foreground: Paint()..shader = LinearGradient(
                                          //                     //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                          //                     //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                          //                     // )
                                          //                     // LinearGradient(
                                          //                     //   begin: Alignment.topLeft,
                                          //                     //   end: Alignment.bottomRight,
                                          //                     //   colors: gradientColors,
                                          //                     // ).createShader(
                                          //                     //     Rect.fromCircle(
                                          //                     //       center: Offset(fontSize, -200),
                                          //                     //       radius: fontSize / 3,
                                          //                     //     )
                                          //                     // );
                                          //                   ],
                                          //                 ),
                                          //               ) : Positioned(
                                          //                 bottom: 15,
                                          //                 left: 15,
                                          //                 width: MediaQuery.of(context).size.width * 0.38,
                                          //                 child: Column(
                                          //                   crossAxisAlignment: CrossAxisAlignment.start,
                                          //                   children: [
                                          //                     GradientText(
                                          //                       item.business!.category!.name != null
                                          //                           ? item.business!.category!.name! : '',
                                          //                       maxLines: 2,
                                          //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //                       // gradient: Gradients.backToFuture,
                                          //                       gradient: /*!item.is_single_event ?*/ /*Gradients.blush*/LinearGradient(
                                          //                           begin: Alignment.bottomLeft,
                                          //                           end: Alignment.topRight,
                                          //                           colors: [
                                          //                             // Color(0xff8921aa),
                                          //                             // Color(0xffDA44bb),
                                          //
                                          //                             // Color(0xffFFB75E),
                                          //                             // Color(0xffED8F03),
                                          //
                                          //                             Color(0xfffd746c),
                                          //                             Color(0xffff9068),
                                          //                           ]
                                          //                       ),
                                          //                       style: TextStyle(
                                          //                           color: Colors.blue,
                                          //                           fontWeight: FontWeight.w700,
                                          //                           fontSize: 12
                                          //                       ),
                                          //                       textAlign: TextAlign.left,
                                          //                     ),
                                          //                     SizedBox(height: 1,),
                                          //                     /*Gradient*/Text(
                                          //                       /* item.is_single_event && item.single_event.business.name != null
                                          //                   ? item.single_event.business.name
                                          //                   :*/ item.business!.name != null
                                          //                         ? item.business!.name! : '',
                                          //                       // 'A partire da € 60,00',
                                          //                       maxLines: 6,
                                          //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                          //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                          //                       /*gradient: item.is_single_event
                                          //                     ? Gradients.backToFuture
                                          //                     :*/
                                          //                       // LinearGradient(
                                          //                       //     begin: Alignment.bottomLeft,
                                          //                       //     end: Alignment.topRight,
                                          //                       //     colors: [
                                          //                       //       Color(0xff8921aa),
                                          //                       //       Color(0xffDA44bb),
                                          //                       //       // Colors.pink,
                                          //                       //       // Colors.pinkAccent,
                                          //                       //     ]
                                          //                       // ),
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
                                          //                           color: Colors.white,
                                          //                           fontWeight: FontWeight.w700,
                                          //                           fontSize: 16
                                          //                       ),
                                          //                       textAlign: TextAlign.left,
                                          //                     ),
                                          //                     // Text(
                                          //                     //   'A partire da € 60,00',
                                          //                     //   style: new TextStyle(
                                          //                     //       fontWeight: FontWeight.w800,
                                          //                     //       fontSize: 15,
                                          //                     //
                                          //                     //       foreground: Paint()..shader = LinearGradient(
                                          //                     //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                          //                     //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                          //                     // )
                                          //                     // LinearGradient(
                                          //                     //   begin: Alignment.topLeft,
                                          //                     //   end: Alignment.bottomRight,
                                          //                     //   colors: gradientColors,
                                          //                     // ).createShader(
                                          //                     //     Rect.fromCircle(
                                          //                     //       center: Offset(fontSize, -200),
                                          //                     //       radius: fontSize / 3,
                                          //                     //     )
                                          //                     // );
                                          //                   ],
                                          //                 ),
                                          //               ),
                                          //             ],
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // );
                                        }
                                    );
                                  }).toList(),
                                  options: CarouselOptions(
                                      enlargeCenterPage: true,
                                      viewportFraction: 1,
                                      height: MediaQuery.of(context).size.height * .5,
                                      autoPlay: true,
                                      // aspectRatio: 16/9,
                                      autoPlayCurve: Curves.easeInOut,
                                      onPageChanged: (i, bho) async {
                                        // print('socketProvider.currentTab');
                                        // print(socketProvider.currentTab);
                                        if(socketProvider.currentTab == 0){
                                          /*await*/ Future.wait([
                                            postProvider.getBusinessHomePostLikes(homeBusinessPostList[i].id, homeBusinessPostList[i].business!.id!),
                                            postProvider.getBusinessHomePostComments(homeBusinessPostList[i].id!, homeBusinessPostList[i].business!.id!),
                                          ]);
                                        }
                                      }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Visibility(
                          visible: /*!Utils.isBusiness*/false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10, top: 14, bottom: 10),
                                child: Text(
                                  "Categorie",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      // color: Colors.blue
                                      color: Colors.grey
                                  ),
                                ),
                              ),
                              // Divider(
                              //   height: 0,
                              //   thickness: 2,
                              //   indent: 10,
                              //   endIndent: 10,
                              // ),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.17,
                                // height: MediaQuery.of(context).size.height * 0.5,
                                child: PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (categoryList.length/3).ceil(),
                                    // physics: const BouncingScrollPhysics(),
                                    // itemCount: categoryList!.length,
                                    controller: PageController(),
                                    onPageChanged: (i){
                                      // //print(i);
                                      // //print(categoryList!.length);
                                      // setState(() {
                                      //   pageNum = i+1;
                                      // });
                                    },
                                    itemBuilder: (context, index){
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 0, right: 5, left: 5, bottom: 10),
                                        child: StaggeredGridView.countBuilder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.only(top: 0),
                                            crossAxisCount: 3,
                                            staggeredTileBuilder: (i) => const StaggeredTile.count(1, 1),
                                            //shrinkWrap: true,
                                            mainAxisSpacing: 0,
                                            physics: const NeverScrollableScrollPhysics(),
                                            crossAxisSpacing: 0,
                                            // itemCount: categoryList!.length,
                                            itemCount: 3,
                                            itemBuilder: (context, ind) {
                                              int indice = ((categoryList.length/(categoryList.length/3)).floor()*index)+ind;

                                              //print("((${categoryList!.length}/(${categoryList!.length}/3)).floor()*$index)+$ind");
                                              //print(indice);

                                              if(indice >= categoryList.length) {
                                                return const SizedBox();
                                              }

                                              // //print('ind');
                                              // //print(ind);
                                              Category category = Category(
                                                //todo: da aggiustare e anche la chiamata a category/is_valid cambiarla in category/only_business
                                                // id: categoryList[i]['id'].toInt(),
                                                id: categoryList[indice]['id'],
                                                image: categoryList[indice]['image'],
                                                name: categoryList[indice]['name'],
                                              );

                                              // return Padding(
                                              //   padding: const EdgeInsets.only(top: 0, right: 5, left: 5, bottom: 10),
                                              //   child: StaggeredGridView.countBuilder(
                                              //       shrinkWrap: true,
                                              //       padding: EdgeInsets.only(top: 0),
                                              //       crossAxisCount: 3,
                                              //       staggeredTileBuilder: (i) => const StaggeredTile.count(1, 1),
                                              //       //shrinkWrap: true,
                                              //       mainAxisSpacing: 0,
                                              //       physics: const NeverScrollableScrollPhysics(),
                                              //       crossAxisSpacing: 0,
                                              //       // itemCount: categoryList!.length,
                                              //       itemCount: 3,
                                              //       itemBuilder: (context, ind) {
                                              //         int indice = ((categoryList!.length/(categoryList!.length/3)).floor()*index)+ind;
                                              //
                                              //         //print("((${categoryList!.length}/(${categoryList!.length}/3)).floor()*$index)+$ind");
                                              //         //print(indice);
                                              //
                                              //         if(indice >= categoryList!.length) {
                                              //           return const SizedBox();
                                              //         }
                                              //         // //print('ind');
                                              //         // //print(ind);
                                              //         Category category = Category(
                                              //           //todo: da aggiustare e anche la chiamata a category/is_valid cambiarla in category/only_business
                                              //           // id: categoryList[i]['id'].toInt(),
                                              //           id: categoryList![indice]['id'],
                                              //           image: categoryList![indice]['image'],
                                              //           name: categoryList![indice]['name'],
                                              //         );
                                              //
                                              //         return Container(
                                              //           height: MediaQuery.of(context).size.height * 0.25,
                                              //           width: MediaQuery.of(context).size.width,
                                              //           child: GestureDetector(
                                              //             onTap: (){
                                              //               Navigator.push(
                                              //                   context,
                                              //                   PageTransition(
                                              //                       duration: const Duration(milliseconds: 500),
                                              //                       alignment: Alignment.center,
                                              //                       type: PageTransitionType.fade,
                                              //                       child: BusinessScreen(
                                              //                         // user: widget.user,
                                              //                         categoryId: category.id.toString(),
                                              //                       )
                                              //                   )
                                              //               );
                                              //             },
                                              //             // child: Card(
                                              //             //   semanticContainer: true,
                                              //             //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                              //             //   child: Image.network(
                                              //             //     convs[i].profilePicture,
                                              //             //     fit: BoxFit.cover,
                                              //             //   ),
                                              //             //   // shape: RoundedRectangleBorder(
                                              //             //   //   borderRadius: BorderRadius.circular(12.0),
                                              //             //   // ),
                                              //             //   elevation: 8,
                                              //             //   //margin: EdgeInsets.all(10),
                                              //             // ),
                                              //             child: Card(
                                              //               elevation: 8,
                                              //               child: Container(
                                              //                 child: Row(
                                              //                   mainAxisAlignment: MainAxisAlignment.center,
                                              //                   crossAxisAlignment: CrossAxisAlignment.center,
                                              //                   children: <Widget>[
                                              //                     // SvgPicture.asset("assets/svg/icon_location.svg"),
                                              //                     // SizedBox(width: 7,),
                                              //                     ClipRRect(
                                              //                       borderRadius: BorderRadius.circular(5),
                                              //                       child: BackdropFilter(
                                              //                         filter: ImageFilter.blur(
                                              //                             sigmaY: 30,
                                              //                             sigmaX: 30
                                              //                         ),
                                              //                         child: Padding(
                                              //                           padding: EdgeInsets.all(3),
                                              //                           child: Text(
                                              //                             // categories[i].name,
                                              //                             category.name!,
                                              //                             overflow: TextOverflow.ellipsis,
                                              //                             style: GoogleFonts.lato(
                                              //                               fontWeight: FontWeight.w700,
                                              //                               color: Colors.white,
                                              //                               fontSize: 15,
                                              //                             ),
                                              //                           ),
                                              //                         ),
                                              //                       ),
                                              //                     ),
                                              //                   ],
                                              //                 ),
                                              //                 //margin: EdgeInsets.all(2),
                                              //                 // width: MediaQuery.of(context).size.width,
                                              //                 // height: MediaQuery.of(context).size.width,
                                              //                 decoration: BoxDecoration(
                                              //                   borderRadius: BorderRadius.circular(5),
                                              //                   // color: Colors.white.withOpacity(1)),
                                              //                   image: DecorationImage(
                                              //                     fit: BoxFit.cover,
                                              //                     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                                              //                     image: CachedNetworkImageProvider(
                                              //                       // categories[i].image,
                                              //                       category.image!,
                                              //                       cacheBusiness: CacheBusiness(
                                              //                           Config(
                                              //                               'customCacheKey',
                                              //                               stalePeriod: const Duration(days: 7)
                                              //                           )
                                              //                       ),
                                              //                       errorListener: () => SizedBox(),
                                              //                     ),
                                              //                   ),
                                              //                   boxShadow: [
                                              //                     // BoxShadow(
                                              //                     //   color: Colors.grey[400].withOpacity(0.3),
                                              //                     //   spreadRadius: 0.5,
                                              //                     //   blurRadius: 1,
                                              //                     //   offset: Offset(5, 5), // changes position of shadow
                                              //                     // ),
                                              //                   ],
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         );
                                              //       }
                                              //     // ImageCard(
                                              //     //   imageData: imageList[index],
                                              //     // ),
                                              //   ),
                                              // );

                                              return InkWell(
                                                highlightColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          duration: const Duration(milliseconds: 500),
                                                          alignment: Alignment.center,
                                                          type: PageTransitionType.fade,
                                                          child: BusinessCategoryListScreen(
                                                            // user: widget.user,
                                                            categoryId: category.id.toString(),
                                                          )
                                                      )
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                                  child: Opacity(
                                                    opacity: 1,
                                                    child: Transform(
                                                      alignment: FractionalOffset.topLeft,
                                                      transform: Matrix4.translationValues(
                                                        0,
                                                        0.0,
                                                        0.0,
                                                      ),
                                                      child: Card(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                                        elevation: 8,
                                                        child: Stack(
                                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                                          fit: StackFit.expand,
                                                          children: [
                                                            // FutureImage(
                                                            //   category.image!,
                                                            //   width: MediaQuery.of(context).size.width,
                                                            //   // height: MediaQuery.of(context).size.height * 0.25,
                                                            // ),
                                                            Image.memory(
                                                              // category.image!,
                                                              imageCacheBusiness.imageCache[categoryList[indice]['image']] ?? Uint8List(0),
                                                              // categoryListImages[indice],
                                                              // width: MediaQuery.of(context).size.width,
                                                              // height: MediaQuery.of(context).size.height * 0.25,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            // FutureImage(
                                                            //   item.image != null && item.image != '' && i % 2 == 0
                                                            //     ? '${Utils.httpServerUrl}image?path=${item.image!}'
                                                            //     : item.business!.profile_image!,
                                                            // ),
                                                            DecoratedBox(
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
                                                            Center(
                                                              child: Container(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: <Widget>[
                                                                    // SvgPicture.asset("assets/svg/icon_location.svg"),
                                                                    // SizedBox(width: 7,),
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(5),
                                                                      child: BackdropFilter(
                                                                        filter: ImageFilter.blur(
                                                                            sigmaY: 30,
                                                                            sigmaX: 30
                                                                        ),
                                                                        child: Padding(
                                                                          padding: EdgeInsets.all(3),
                                                                          child: Text(
                                                                            // categories[i].name,
                                                                            category.name!,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: Colors.white,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                //margin: EdgeInsets.all(2),
                                                                // width: MediaQuery.of(context).size.width,
                                                                // height: MediaQuery.of(context).size.width,
                                                                // decoration: BoxDecoration(
                                                                //   borderRadius: BorderRadius.circular(5),
                                                                // color: Colors.white.withOpacity(1)),
                                                                // image: DecorationImage(
                                                                //   fit: BoxFit.cover,
                                                                //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                                                                //   image: CachedNetworkImageProvider(
                                                                //     // categories[i].image,
                                                                //     category.image!,
                                                                //     errorListener: () => SizedBox(),
                                                                //   ),
                                                                // ),
                                                                // boxShadow: [
                                                                // BoxShadow(
                                                                //   color: Colors.grey[400].withOpacity(0.3),
                                                                //   spreadRadius: 0.5,
                                                                //   blurRadius: 1,
                                                                //   offset: Offset(5, 5), // changes position of shadow
                                                                // ),
                                                                // ],
                                                                // ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          // ImageCard(
                                          //   imageData: imageList[index],
                                          // ),
                                        ),
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,)
                      ],
                    )
                  ),
                ),
              )
          );
        }
        else{
          return const SplashScreen();
        }
      }
    );

  }

// _slider(context, _pageController, List list, int length, isInverted){
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         height: MediaQuery.of(context).size.height * 0.225,
//         margin: const EdgeInsets.only(top: 10),
//         child: PageView(
//           physics: BouncingScrollPhysics(),
//           pageSnapping: true,
//           allowImplicitScrolling: true,
//           // scrollBehavior: ScrollBehavior(),
//           controller: _pageController,
//           scrollDirection: Axis.horizontal,
//           children: List.generate(
//             recommendedList.length,
//             (int i) => Padding(
//               padding: const EdgeInsets.only(/*left: 6,*/ right: 20),
//               child: Column(
//                 children: [
//                   // Row(
//                   //   children: [
//                   //     Text(
//                   //       "6 attachments",
//                   //       style: TextStyle(fontSize: 12),
//                   //     ),
//                   //     Spacer(),
//                   //     Text(
//                   //       "Download All",
//                   //       style: Theme.of(context)
//                   //           .textTheme
//                   //           .caption,
//                   //     ),
//                   //     SizedBox(width: 20),
//                   //     // WebsafeSvg.asset(
//                   //     //   "assets/Icons/Download.svg",
//                   //     //   height: 16,
//                   //     //   color: kGrayColor,
//                   //     // ),
//                   //   ],
//                   // ),
//                   // Divider(thickness: 1),
//                   // SizedBox(height: 20),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.175,
//                     child: StaggeredGridView.countBuilder(
//                       physics: const NeverScrollableScrollPhysics(),
//                       padding: const EdgeInsets.all(0),
//                       crossAxisCount: 4,
//                       itemCount: 3,
//                       itemBuilder: (BuildContext context, int index) =>
//                         Stack(
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           fit: StackFit.passthrough,
//                           children: [
//                             Card(
//                               elevation: 5,
//                               clipBehavior: Clip.antiAliasWithSaveLayer,
//                               // child: Image.asset(
//                               child: Image.network(
//                                 // "assets/images/Img_$index.png",
//                                 recommendedList[i]/*[index]*/.single_event.image,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             isInverted && index == length-2 ? Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: BackdropFilter(
//                                   filter: ImageFilter.blur(
//                                       sigmaY: 30,
//                                       sigmaX: 30
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.all(3),
//                                     child: Text(
//                                       // categories[i].name,
//                                       // category.name,
//                                       // categoryList[i]['name'],
//                                       // 'DiscoPub beach volley',
//                                       recommendedList[i]/*[index]*/.single_event.title,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: GoogleFonts.lato(
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ) :
//                             !isInverted && index == length-3 ? Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: BackdropFilter(
//                                   filter: ImageFilter.blur(
//                                       sigmaY: 30,
//                                       sigmaX: 30
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.all(3),
//                                     child: Text(
//                                       // categories[i].name,
//                                       // category.name,
//                                       // categoryList[i]['name'],
//                                       // 'DiscoPub beach volley',
//                                       recommendedList[i]/*[index]*/.single_event.title,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: GoogleFonts.lato(
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ) :
//                             Text('')
//                           ],
//                         ),
//                         staggeredTileBuilder: (int index) =>
//                           StaggeredTile.count(
//                             2,
//                             // index.isOdd ? 2 : 1,
//                             isInverted && index.isOdd ? 2 : 1,
//                           ),
//                         mainAxisSpacing: 5,
//                         crossAxisSpacing: 5,
//                     ),
//                   )
//                 ],
//               ),
//             )
//           ),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(right: 40, top: 5),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             SmoothPageIndicator(
//               controller: _pageController,
//               // count: events.length,
//               // count: singleEventList.length,
//               // count: 10,
//               count: recommendedList.length,
//
//               effect: const ExpandingDotsEffect(
//                   activeDotColor: Color(0xFF8a8a8a),
//                   dotColor: Color(0xFFababab),
//                   dotHeight: 4.8,
//                   dotWidth: 6,
//                   spacing: 4.8
//               ),
//             ),
//           ],
//         ),
//       ),
//
//     ],
//   );
// }

// Widget categoryGridView(){
//   return StaggeredGridView.countBuilder(
//     crossAxisCount: 3,
//     // controller: ,
//     staggeredTileBuilder: (i) => StaggeredTile.count(/*i == 0 ? 3 : 1, i == 0 ? 2.65 : 1*/1, 1),
//     //shrinkWrap: true,
//     mainAxisSpacing: 0,
//     crossAxisSpacing: 0,
//     itemCount: categories.length,
//     itemBuilder: (context, i) {
//       return /*i == 0 ? _slider(context, _pageController) : */_businessItem(context, i/*i >= categories.length ? i=1 : i*/);
//     }
//       // ImageCard(
//       //   imageData: imageList[index],
//       // ),
//   );
// }

// Widget eventGridView(){
//   return StaggeredGridView.countBuilder(
//       crossAxisCount: 3,
//
//       // controller: ,
//       staggeredTileBuilder: (i) => StaggeredTile.count(/*i == 0 ? 3 : 1, i == 0 ? 2.65 : 1*/3, 1.5),
//       //shrinkWrap: true,
//       mainAxisSpacing: 0,
//       crossAxisSpacing: 0,
//       itemCount: events.length,
//       itemBuilder: (context, i) {
//         return /*i == 0 ? _slider(context, _pageController) : */_listEvent(context, i/*i >= categories.length ? i=1 : i*/);
//       }
//     // ImageCard(
//     //   imageData: imageList[index],
//     // ),
//   );
// }

}

// Tab bar
class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  TabController _tabController;
  CustomSliverDelegate(this._tabController);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // height: 50.0,
      // decoration: BoxDecoration(
      //   color: Colors.grey[50],
      //
      // ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(10),
          // topRight: Radius.circular(10),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      height: 48,
      // child: TabBar(
      //   controller: _tabController,
      //   indicatorColor: Colors.black,
      //   tabs: <Widget>[
      //     Icon(Icons.grid_on),
      //     Icon(Icons.contacts),
      //   ],
      // ),
      child: TabBar(
        controller: _tabController,
        // indicatorColor: Theme.of(context).colorScheme.onBackground,
        indicatorColor: Colors.transparent,

        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey[500],
        tabs: <Widget>[
          // Tab(icon: Icon(Icons.grid_on),),
          // Tab(icon: Icon(Icons.person_outline),)
          Tab(
            child: Text('Categorie'),
          ),
          Tab(
              child: Text('In evidenza')
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 42.0;

  @override
  double get minExtent => 42.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class RoundedRectangleTabIndicator extends Decoration {
  final BoxPainter _painter;

  RoundedRectangleTabIndicator({
    required Color color, required double weight, required double width
  }) : _painter = _RRectanglePainterColor(color, weight, width);

  @override
  BoxPainter createBoxPainter([Function()? onChanged]) => _painter;
}

class _RRectanglePainterColor extends BoxPainter {
  final Paint _paint;
  final double weight;
  final double width;

  _RRectanglePainterColor(Color color, this.weight, this.width)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    // Custom Position
    // cfg.size.width*0.5 to make it start from center
    // subtract by 7.2 to make it really center
    final Offset customOffset = offset +
        Offset(cfg.size!.width / 2 - (width * 0.5), cfg.size!.height - weight);

    //Custom Rectangle
    Rect myRect = customOffset & Size(width, weight);

    // Custom Rounded Rectangle
    RRect myRRect = RRect.fromRectXY(myRect, weight, weight);

    // Finally we have to draw
    canvas.drawRRect(myRRect, _paint);
  }
}