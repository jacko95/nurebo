import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/event_business_profile_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
// import 'package:flutter_icons/flutter_icons.dart';


class BusinessCategoryListScreen extends StatefulWidget {
  // final User? user;
  final String? categoryId;
  // final bool isEventBusiness;

  const BusinessCategoryListScreen({super.key, /*this.user,*/ this.categoryId});

  @override
  _BusinessCategoryListScreenState createState() => _BusinessCategoryListScreenState();
}

class _BusinessCategoryListScreenState extends State<BusinessCategoryListScreen> with SingleTickerProviderStateMixin{
  final _pageController = PageController(viewportFraction: 0.877);
  int _current = 0;
  List<Business> businessList = [];
  List? singleEventList = [];
  late TabController _tabController;
  late ScrollController _scrollController;
  late UserProvider userProvider;
  late GeolocationProvider geolocationProvider;
  Future all = Future((){});
  final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();


  Future getAllEventBusinessByCategory() async {
    // var url = Uri.parse("${Utils.httpServerUrl}category/business");
    var url = Uri.parse("${Utils.httpServerUrl}category/${widget.categoryId}/business");

    Map<String, dynamic> body = {
      "category_id": widget.categoryId
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

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        businessList!.addAll(jsonData);
      });
      // //print(jsonData);

      return jsonData;
    }
  }

  Future getAllDateBusinessByCategory() async {
    var url = Uri.parse(Utils.httpServerUrl + "category/booking_business");
    // var chatProvider = Provider.of<ChatProvider>(context);

    Map<String, dynamic> body = {
      "category_id": widget.categoryId
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
      setState(() {
        businessList!.addAll(jsonData);
      });
      // //print(jsonData);

      return jsonData;
    }
  }

  Future getAllBusinessByCategory() async {
    // var url = Uri.parse(Utils.httpServerUrl + "category/business");
    var url = Uri.parse("${Utils.httpServerUrl}category/${widget.categoryId}/business");

    Map<String, dynamic> body = {
      "category_id": widget.categoryId,
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

    // //print('UserPreferences.getUserToken()');
    // //print(UserPreferences.getUserToken());

    // var response = await http.post(
    var response = await http.get(
        uri,
        // url,
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
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()/*+'dddd'*/,
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   businessList!.addAll(jsonData);
      // });
      // //print(jsonData);
      for(var e in jsonData){
        double? distanceTemp = getDistance(e['business_latitude']?.toDouble(), e['business_longitude']?.toDouble());
        Business businessTemp = Business(
          // id: int.parse(businessList[i]['id']),
          id: e['business_id'],
          profile_image: e['business_profile_image'],
          name: e['business_name'],
          email: e['business_email'],
          longitude: e['business_longitude'],
          latitude: e['business_latitude'],
          distance: distanceTemp ?? 0.00,
          description: e['business_description'],
          phone: e['business_phone'],
          address: e['business_address'],
          // category_id: businessList[i]['category_id'],
          type_id: e['business_type_id'].toInt(),
          max_contemporary_appointments: e['max_contemporary_appointments'],
          room_id: e['business_room_id'],
          category: Category(
            id: e['category_id'],
            image: e['category_image'],
            name: e['category_name'],
          )
        );

        // if(distanceTemp! < 30000){
          businessList.add(businessTemp);
        // }
      }

      return jsonData;
    }
  }

  double? getDistance(double latitude, double longitude){
    double distanceInMeters = Geolocator.distanceBetween(
      // 52.2165957, 6.9437819, 52.3546274, 4.8285838
      // 45.4281857, 9.1531147, 45.44131, 9.14952
      // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
        geolocationProvider.position!.latitude, geolocationProvider.position!.longitude,
        latitude, longitude
    );
    return distanceInMeters;
  }

  Future getAllBusinessByCategoryCacheJWT() async {
    // var url = Uri.parse(Utils.httpServerUrl + "category/business");
    var url = Uri.parse("${Utils.httpServerUrl}category/${widget.categoryId}/business");

    Map<String, dynamic> body = {
      "category_id": widget.categoryId
    };

    // String fileName = "businessByCategory.json";
    // String fileName = "category-business_" + widget.categoryId.toString();
    // String fileName = "category-business/$body".replaceAll('/', '');
    String fileName = "category-business_$body";
    // //print('fileName');
    // //print(fileName);
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + "/" + fileName);

    if (file.existsSync()) {
      // //print("Loading from cache");
      var jsonData = file.readAsStringSync();
      // setState(() {
      // businessList = jsonDecode(jsonData) as List?;
      for(var e in jsonDecode(jsonData)){
        businessList.add(
            Business(
              // id: int.parse(businessList[i]['id']),
                id: e['business_id'],
                profile_image: e['business_profile_image'],
                name: e['business_name'],
                email: e['business_email'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                description: e['business_description'],
                phone: e['business_phone'],
                address: e['business_address'],
                // category_id: businessList[i]['category_id'],
                type_id: e['business_type_id'].toInt(),
                max_contemporary_appointments: e['max_contemporary_appointments'],
                room_id: e['business_room_id'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            )
        );
      }
      // });
      // //print(businessList.toString());
      // return response;
      return jsonData;
    }
    else {
      // //print("Loading from http request");

      // //print('UserPreferences.getUserToken()');
      // //print(UserPreferences.getUserToken());

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

      if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
        // if (!mounted) return;
        await userProvider.logout(context);
      }
      if(response.statusCode >= 200 && response.statusCode < 400) {
        var jsonData = json.decode(response.body);
        setState(() {
          businessList!.addAll(jsonData);
        });
        // //print(jsonData);
        file.writeAsStringSync(response.body, flush: true, mode: FileMode.write);
        // file.writeAsStringSync((response.body as List).toString(), flush: true, mode: FileMode.write);

        Future.delayed(
          const Duration(seconds: 25),
          () async {
            // //print('deleted $fileName in cache');
            await file.delete(recursive: true);
            // file.deleteSync(recursive: true);
          },
        );
        // await AndroidAlarmBusiness.oneShot(
        //   // Duration(minutes: 2),
        //     Duration(seconds: 25),
        //     Random().nextInt(88887),
        //     /*(file) => */deleteCache/*(file)*/,
        //     // (_) {
        //     //   //print('deleted $fileName');
        //     //   file.delete(recursive: true);
        //     // },
        //     exact: true,
        //     wakeup: true,
        //     allowWhileIdle: true,
        //     rescheduleOnReboot: true,
        //     alarmClock: true
        // );

        return jsonData;
      }
    }
  }

  Future getAllBusinessByCategoryCache() async {
    // await geolocationProvider.getGeolocationPermission(context)/*.then((value) async {
    //   // await geolocationProvider.putUserLocation(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude, context);
    // })*/;

    // var url = Uri.parse(Utils.httpServerUrl + "category/business");
    // var url = Uri.parse("${Utils.httpServerUrl}category/business");
    var url = Uri.parse("${Utils.httpServerUrl}category/${widget.categoryId}/business");

    Map<String, dynamic> body = {
      "category_id": widget.categoryId,
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

    var jsonData;

    // String fileName = "businessByCategory.json";
    // String fileName = "category-business_" + widget.categoryId.toString();
    // String fileName = "category-business/$body".replaceAll('/', '');
    String fileName = "category-business_$body";
    // //print('fileName');
    // //print(fileName);
    var dir = await getTemporaryDirectory();
    File file = File("${dir.path}/$fileName");

    if (file.existsSync()) {
      // //print("Loading from cache");
      /*var*/ jsonData = file.readAsStringSync();
      // setState(() {
      // businessList = jsonDecode(jsonData) as List?;
      for(var e in jsonDecode(jsonData)){
        businessList.add(
            Business(
              // id: int.parse(businessList[i]['id']),
                id: e['business_id'],
                profile_image: e['business_profile_image'],
                name: e['business_name'],
                email: e['business_email'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                description: e['business_description'],
                phone: e['business_phone'],
                address: e['business_address'],
                // category_id: businessList[i]['category_id'],
                type_id: e['business_type_id'].toInt(),
                max_contemporary_appointments: e['max_contemporary_appointments'],
                room_id: e['business_room_id'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
            )
        );
      }
      // });
      // //print(businessList.toString());
      // return response;
      // return jsonData;
    }
    else {
      // //print("Loading from http request");

      // var response = await http.post(
      var response = await http.get(
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
          }
      );

      // //print("response.statusCode:");
      // //print(response.statusCode);
      if(response.statusCode >= 200 && response.statusCode < 400) {
        /*var*/ jsonData = json.decode(response.body);
        // setState(() {
        //   businessList!.addAll(jsonData);
        // });
        for(var e in jsonData){
          businessList.add(
              Business(
                // id: int.parse(businessList[i]['id']),
                  id: e['business_id'],
                  profile_image: e['business_profile_image'],
                  name: e['business_name'],
                  email: e['business_email'],
                  longitude: e['business_longitude'],
                  latitude: e['business_latitude'],
                  description: e['business_description'],
                  phone: e['business_phone'],
                  address: e['business_address'],
                  // category_id: businessList[i]['category_id'],
                  type_id: e['business_type_id'].toInt(),
                  max_contemporary_appointments: e['max_contemporary_appointments'],
                  room_id: e['business_room_id'],
                  category: Category(
                    id: e['category_id'],
                    image: e['category_image'],
                    name: e['category_name'],
                  )
              )
          );
        }
        // //print(jsonData);
        file.writeAsStringSync(response.body, flush: true, mode: FileMode.write);
        // file.writeAsStringSync((response.body as List).toString(), flush: true, mode: FileMode.write);

        Future.delayed(
          const Duration(seconds: 25),
          () async {
            // //print('deleted $fileName in cache');
            await file.delete(recursive: true);
            // file.deleteSync(recursive: true);
          },
        );
        // await AndroidAlarmBusiness.oneShot(
        //   // Duration(minutes: 2),
        //     Duration(seconds: 25),
        //     Random().nextInt(88887),
        //     /*(file) => */deleteCache/*(file)*/,
        //     // (_) {
        //     //   //print('deleted $fileName');
        //     //   file.delete(recursive: true);
        //     // },
        //     exact: true,
        //     wakeup: true,
        //     allowWhileIdle: true,
        //     rescheduleOnReboot: true,
        //     alarmClock: true
        // );

        // return jsonData;
      }
    }

    // businessList.sort((a, b) {
    //   // return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //   return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
    // });

    return jsonData;
  }

  Future getAllBusinessByCategoryJWT() async {
    // var url = Uri.parse(Utils.httpServerUrl + "category/business");
    var url = Uri.parse("${Utils.httpServerUrl}category/${widget.categoryId}/business");

    Map<String, dynamic> body = {
      "category_id": widget.categoryId
    };

    // //print('UserPreferences.getUserToken()');
    // //print(UserPreferences.getUserToken());

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
      setState(() {
        businessList!.addAll(jsonData);
      });
      // //print(jsonData);

      return jsonData;
    }
  }

  Future getAllSingleEvent() async {
    var url = Uri.parse("${Utils.httpServerUrl}event");

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

    // //print("response.statusCode");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        singleEventList = jsonData;
      });
      // //print("singleEventList:");
      // //print(singleEventList);

      return jsonData;
    }
  }

  List<T?> map<T>(List list, Function handler){
    List<T?> result = [];
    for(var i = 0; i < list.length; i++){
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future waitFutureBuilder() async {
    // // getAllBusinessByCategoryCacheJWT()
    // (await getAllBusinessByCategoryCache())
    // // getAllBusinessByCategoryJWT()
    // // getAllBusinessByCategory()
    // // .then((value) => getAllEventBusinessByCategory())
    //     .then((value) => businessList!.sort((a, b) {
    //   // return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //   return a['business_name'].toLowerCase().compareTo(b['business_name'].toLowerCase());
    // })
    // );
    await geolocationProvider.getGeolocationPermission(context);/*.then((v) async {*/
      // await Future.wait([
      //   // getAllBusinessByCategoryCache(),
      //   getAllBusinessByCategory(),
      // ]);
      await getAllBusinessByCategory();
      businessList.sort((a, b) {
        // return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
        // return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        return a.distance!.compareTo(b.distance!);
      });
    // });

  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    _tabController = TabController(vsync: this, length: 2);
    _scrollController = ScrollController();
    // getAllSingleEvent();

    // getAllDateBusinessByCategory()
    //   .then((value) => getAllEventBusinessByCategory())
    //   .then((value) => businessList.sort((a, b) {
    //     return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //   })
    // );

    // Future.wait([
      all = waitFutureBuilder();
    // ]);

    // // getAllBusinessByCategoryCacheJWT()
    // getAllBusinessByCategoryCache()
    // // getAllBusinessByCategoryJWT()
    // // getAllBusinessByCategory()
    //   // .then((value) => getAllEventBusinessByCategory())
    //   .then((value) => businessList!.sort((a, b) {
    //     // return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //     return a['business_name'].toLowerCase().compareTo(b['business_name'].toLowerCase());
    //   })
    // );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    return Scaffold(
      // backgroundColor: Colors.grey[100],
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
          // title: Text(
          //   'Estetista',
          //   style: TextStyle(
          //       color: Colors.blue,
          //       // color: Colors.grey[800],
          //       fontSize: 18,
          //       fontWeight: FontWeight.w700
          //   ),
          // ),
          // centerTitle: true,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.grey[500],
              size: 27,
            ),
            color: Colors.black,
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
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                // _bottomSheetOptions(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15),
                child: Icon(
                  // SimpleLineIcons.options_vertical,
                  // MaterialIcons.list,
                  // MaterialIcons.filter_list,
                  Icons.filter_list,
                  // MaterialIcons.format_list_bulleted,
                  // size: 17,
                  size: 30,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: FutureBuilder(
          // future: all,
          future: Future.wait([all]),
          // initialData: const [],
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done && businessList.length > 0) {
              return ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1.09
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: businessList!.length,
                      itemBuilder: (context, i) {
                        // Business business = Business(
                        //   // id: int.parse(businessList[i]['id']),
                        //   id: businessList![i]['business_id'],
                        //   profile_image: businessList![i]['business_profile_image'],
                        //   name: businessList![i]['business_name'],
                        //   email: businessList![i]['business_email'],
                        //   longitude: businessList![i]['business_longitude'],
                        //   latitude: businessList![i]['business_latitude'],
                        //   description: businessList![i]['business_description'],
                        //   phone_number: businessList![i]['business_phone_number'],
                        //   address: businessList![i]['business_address'],
                        //   // category_id: businessList[i]['category_id'],
                        //   type_id: businessList![i]['business_type_id'].toInt(),
                        //   max_contemporary_appointments: businessList![i]['max_contemporary_appointments'],
                        //   room_id: businessList![i]['business_room_id'],
                        //   category: Category(
                        //     id: businessList![i]['category_id'],
                        //     image: businessList![i]['category_image'],
                        //     name: businessList![i]['category_name'],
                        //   )
                        // );
                        Business business = businessList[i];

                        return GestureDetector(
                          onTap: (){
                            if(business.type_id == 1){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: BookingBusinessProfileScreen(
                                        business: business,
                                        // user: widget.user,
                                      )
                                  )
                              );
                            }
                            else if(business.type_id == 2){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: EventBusinessProfileScreen(
                                        eventBusiness: business,
                                        // user: widget.user,
                                      )
                                  )
                              );
                            }
                          },
                          child: Container(
                            // color: Colors.white,
                            height: MediaQuery.of(context).size.height * .2,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  // height: MediaQuery.of(context).size.height * .2,

                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width * 0.00125,
                                    // left: MediaQuery.of(context).size.width * 0.0025,
                                    // right: MediaQuery.of(context).size.width * 0.0025
                                  ),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: RichText(
                                        // textAlign: TextAlign.start,
                                        maxLines: 1,
                                        //softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          // text: " ${posts[i].event}",
                                            text: business.name,
                                            // text: events[i].title,
                                            style: GoogleFonts.roboto(
                                                color: Colors.blue,
                                                letterSpacing: 0,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: MediaQuery.of(context).size.height * .142,
                                      padding: EdgeInsets.symmetric(horizontal: 2.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: FutureImage(
                                          business.profile_image!,
                                          width: MediaQuery.of(context).size.width
                                        ),
                                        // child: Image.memory(
                                        //   imageCacheBusiness.imageCache[business.profile_image] ?? Uint8List(0),
                                        //   width: MediaQuery.of(context).size.width,
                                        //   fit: BoxFit.cover,
                                        //   errorBuilder: (context, url, error) => Container(
                                        //     width: MediaQuery.of(context).size.width,
                                        //     height: MediaQuery.of(context).size.height,
                                        //     color: Colors.transparent,
                                        //   ),
                                        //   gaplessPlayback: true,
                                        //   isAntiAlias: true,
                                        // ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      right: 15,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10,
                                            left: 15
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaY: 50, sigmaX: 50),
                                            child: Container(
                                              height: MediaQuery.of(context).size.width * 0.06,
                                              // width: MediaQuery.of(context).size.width * 0.37,
                                              decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.26)
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Marquee(
                                                  child: Text(
                                                    // discotheque.address.substring(
                                                    //       0, discotheque.address.length - 3
                                                    //   ).substring(
                                                    //     0, discotheque.address.indexOf(' ')
                                                    // ),
                                                    // 'Milano',
                                                    // business.address!.split(', ')[3]/* + ', ' + business.address.split(', ')[4]*/,
                                                    // business.distance!.toStringAsFixed(2)/* + ', ' + business.address.split(', ')[4]*/,
                                                    '${(business.distance!/1000).toStringAsFixed(2)} km',
                                                    style: GoogleFonts.lato(
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  // text: discotheque.address.substring(
                                                  //     discotheque.address.length - 10
                                                  // ),
                                                  // style: GoogleFonts.lato(
                                                  //   fontWeight: FontWeight.w800,
                                                  //   color: Colors.white,
                                                  //   fontSize: 10,
                                                  // ),
                                                  // // numberOfRounds: 3,
                                                  // blankSpace: 20,
                                                  // velocity: 20,
                                                  // scrollAxis: Axis.horizontal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                    // top: 14,
                                      bottom: 14,
                                      left: 12,
                                      right: 12
                                  ),
                                  child: RichText(
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text: business.description,
                                        // text: events[i].description,
                                        style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 11
                                        )
                                    ),
                                  ),
                                ),
                                // Divider(
                                //   height: 0,
                                //   thickness: 1,
                                // ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Expanded(
                    //   child: StaggeredGridView.countBuilder(
                    //     padding: EdgeInsets.only(top: 10),
                    //     crossAxisCount: 3,
                    //     staggeredTileBuilder: (i) => StaggeredTile.count(i == 0 ? 3 : 1, i == 0 ? 2.65 : 1),
                    //     //shrinkWrap: true,
                    //     mainAxisSpacing: 0,
                    //     crossAxisSpacing: 0,
                    //     itemCount: discothequeList.length+1,
                    //     itemBuilder: (context, i) {
                    //       return i == 0 ? _slider(context, _pageController) : _listItem(context, i-1);
                    //     }
                    //       // ImageCard(
                    //       //   imageData: imageList[index],
                    //       // ),
                    //   )
                    // ),
                  ]
              );
            }
            else if(snapshot.connectionState == ConnectionState.done && businessList.length == 0) {
              return Container(
                color: Colors.white,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * .2,),
                      Lottie.asset(
                        // 'assets/80495-bookmark.json',
                        // 'assets/29384-favorite-heart.json',
                        // 'assets/39551-crypto-blockchain.json',
                        // 'assets/41176-pulse.json',
                        // 'assets/72991-payer.json',
                        'assets/animations/46762-cellphone-3d.json',
                        // controller: animationController,
                        // width: 200,
                        height: 270,
                        // repeat: true

                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .85,
                          child: Text(
                            'Non ci sono ancora locali nelle vicinanze...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.blue,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                                fontSize: 22
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(

                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width * .85,
                      child: Text(
                        'Stiamo caricando i locali nelle vicinanze...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // color: Colors.blue,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                            fontSize: 22
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        ),
      ),
    );
  }

  _listItem(context, i){
    // Business business = Business(
    //   // id: int.parse(businessList[i]['id']),
    //   id: businessList![i]['id'],
    //   profile_image: businessList![i]['image'],
    //   name: businessList![i]['name'],
    // );

    Business business = businessList![i];

    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: (){
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ResultsEventCategory()),
          // );
        },
        child: Card(
          elevation: 8,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                    // child: FutureImage(
                    //   business.profile_image!,
                    //   width: MediaQuery.of(context).size.width,
                    // ),
                    child: Image.memory(
                      imageCacheBusiness.imageCache[business.profile_image] ?? Uint8List(0),
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
                  ),
                ),
              ),
              Container(
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
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            // categories[i].name,
                            business.name!,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  // color: Colors.white.withOpacity(1)),
                  // image: DecorationImage(
                  //   fit: BoxFit.cover,
                  //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                  //   image: CachedNetworkImageProvider(
                  //     // categories[i].image,
                  //     business.profile_image!,
                  //     errorListener: () => SizedBox(),
                  //   ),
                  // ),
                  boxShadow: [
                    // BoxShadow(
                    //   color: Colors.grey[400].withOpacity(0.3),
                    //   spreadRadius: 0.5,
                    //   blurRadius: 1,
                    //   offset: Offset(5, 5), // changes position of shadow
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _listEvent(context, i){
    return Container(
      // height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: (){
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ResultsEventCategory()),
          // );
        },
        // child: Card(
        //   semanticContainer: true,
        //   clipBehavior: Clip.antiAliasWithSaveLayer,
        //   child: Image.network(
        //     convs[i].profilePicture,
        //     fit: BoxFit.cover,
        //   ),
        //   // shape: RoundedRectangleBorder(
        //   //   borderRadius: BorderRadius.circular(12.0),
        //   // ),
        //   elevation: 8,
        //   //margin: EdgeInsets.all(10),
        // ),
        child: Card(
          elevation: 8,
          child: Stack(
            children: [
              Container(
                // width: MediaQuery.of(context).size.width * 0.37,
                // height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  // color: Colors.white.withOpacity(1)),
                  // image: DecorationImage(
                  //   fit: BoxFit.cover,
                  //   colorFilter: ColorFilter.mode(
                  //       Colors.black.withOpacity(0.15),
                  //       BlendMode.darken
                  //   ),
                    // image: CachedNetworkImageProvider(
                    //   // events[i].eventImage,
                    //   singleEventList![i]['image'],
                    //   errorListener: () => SizedBox(),
                    // ),
                  // ),
                  boxShadow: [
                    // BoxShadow(
                    //   color: Colors.grey[400].withOpacity(0.3),
                    //   spreadRadius: 0.5,
                    //   blurRadius: 1,
                    //   offset: Offset(5, 5), // changes position of shadow
                    // ),
                  ],
                ),
                // width: MediaQuery.of(context).size.width * 0.37,
                // height: 30,
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
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            // events[i].title,
                            singleEventList![i]['title'],
                            maxLines: 2,
                            //overflow: TextOverflow.visible,
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w700,
                                // color: Colors.white,
                                fontSize: 15
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: ClipRect(
                  child: FutureImage(
                    singleEventList![i]['image'],
                    width: MediaQuery.of(context).size.width,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
  //       return /*i == 0 ? _slider(context, _pageController) : */_listItem(context, i/*i >= categories.length ? i=1 : i*/);
  //     }
  //       // ImageCard(
  //       //   imageData: imageList[index],
  //       // ),
  //   );
  // }
  //
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

  buildSearch() {
    final styleActive = const TextStyle(color: Colors.blue);
    final styleNotActive = TextStyle(color: Colors.grey[400]);
    final styleHint = const TextStyle(color: Colors.black54);
    final String hintText = 'Cerca eventi o per';
    final style = styleNotActive;

    return GestureDetector(
      onTap: (){
        // Navigator.push(
        //     context,
        //     PageTransition(
        //         duration: const Duration(milliseconds: 50),
        //         alignment: Alignment.topLeft,
        //         type: PageTransitionType.fade,
        //         child: Search(),
        //     )
        // );
      },
      child: Container(
        height: 42,
        margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.black26),
        ),
        padding: const EdgeInsets.only(left: 12, right: 5),
        child: Container(
          // decoration: InputDecoration(
          //   icon: Icon(Icons.search, color: style.color),
          //   suffixIcon: Icon(Icons.close, color: style.color),
          //   hintText: hintText,
          //   hintStyle: style,
          //   border: InputBorder.none,
          // ),
          // style: style,
          // onChanged: widget.onChanged,
        ),
      ),
    );
  }
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
        borderRadius: const BorderRadius.only(
          // topLeft: Radius.circular(10),
          // topRight: Radius.circular(10),
            bottomLeft: const Radius.circular(8),
            bottomRight: const Radius.circular(8)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
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
          const Tab(
            child: Text('Categorie'),
          ),
          const Tab(
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

  RoundedRectangleTabIndicator(
      {required Color color, required double weight, required double width})
      : _painter = _RRectanglePainterColor(color, weight, width);

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