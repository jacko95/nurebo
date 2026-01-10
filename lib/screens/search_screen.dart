import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/timetable.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/event_business_profile_screen.dart';
import 'package:nurebo/screens/event_screen.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class SearchScreen extends StatefulWidget {
  final String text;

  const SearchScreen({super.key, required this.text});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  //TODO: Fare la ricerca locale: scaricare tutti gli utenti una sola volta e filtrare qui.
  List results = [];
  // var results;
  List allEntities = [];
  //ordinare results in ordine alfabetico se _textController.text.length == 1 o 4 o 5
  Future a = Future(() {},), b = Future(() {},), c = Future(() {},);
  late GeolocationProvider geolocationProvider;


  Future getAllPrestazione() async {
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/is_valid");

    // Map/*<String, String>*/ body = {
    //   'title': _textController.text,
    // };

    Map<String, dynamic> queryParameters = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    final uri = url.replace(
      queryParameters: queryParameters,
    );

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

    //print("searchUserByUsername response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   // results = jsonData;
      //   results.addAll(jsonData);
      //   results.shuffle();
      // });

      setState(() {
        // results = jsonData;
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('allEntities.toString()');
      // print('prestazione results');
      // print(jsonData.length);

      return jsonData;
    }
  }

  Future/*<List<UserModel>> */searchPrestazioneByTitle() async {
    var url = Uri.parse(Utils.httpServerUrl + "prestazione/search");

    Map/*<String, String>*/ body = {
      'title': _textController.text,
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

    //print("searchUserByUsername response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      setState(() {
        // results = jsonData;
        results.addAll(jsonData);
        results.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      //print('searchUserByUsername results.toString()');
      //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future getAllUser() async {
    var url = Uri.parse(Utils.httpServerUrl + "user");

    // Map/*<String, String>*/ body = {
    //   'username': _textController.text,
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

    //print("searchUserByUsername response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   // results = jsonData;
      //   results.addAll(jsonData);
      //   results.shuffle();
      // });

      setState(() {
        // results = jsonData;
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername allEntities.toString()');
      // //print(allEntities.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future/*<List<UserModel>> */searchUserByUsername() async {
    var url = Uri.parse("${Utils.httpServerUrl}user/search/username");

    Map/*<String, String>*/ body = {
      'username': _textController.text,
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

    //print("searchUserByUsername response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      setState(() {
        // results = jsonData;
        results.addAll(jsonData);
        results.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      //print('searchUserByUsername results.toString()');
      //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future/*<List<UserModel>> */searchEvent() async {
    // var url = Uri.parse(Utils.httpServerUrl + "single_event/search");
    var url = Uri.parse(Utils.httpServerUrl + "event/search");

    Map/*<String, String>*/ body = {
      'name': _textController.text,
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

    //print("searchEvent response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      setState(() {
        results.addAll(jsonData);
        results.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      //print('searchEvent results.toString()');
      //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future getAllEvent() async {
    // var url = Uri.parse(Utils.httpServerUrl + "single_event");
    var url = Uri.parse(Utils.httpServerUrl + "event");

    // Map/*<String, String>*/ body = {
    //   'name': _textController.text,
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

    //print("searchEvent response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   results.addAll(jsonData);
      //   results.shuffle();
      // });

      setState(() {
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchEvent allEntities.toString()');
      // //print(allEntities.toString());
      //print('resultsfbbbddbbddb');
      //print(jsonData);
      return jsonData;
    }
  }

  Future getAllBusiness() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business");
    var url = Uri.parse("${Utils.httpServerUrl}business?is_visible=1&is_valid=1");

    // Map/*<String, String>*/ body = {
    //   'name': _textController.text,
    // };
    Map<String, dynamic> queryParameters = {
      "ip_latitude": Utils.ipLatitude.toString(),
      "ip_longitude": Utils.ipLongitude.toString(),
      "geo_latitude": geolocationProvider.position?.latitude.toString(),
      "geo_longitude": geolocationProvider.position?.longitude.toString(),
    };

    final uri = url.replace(
      queryParameters: queryParameters,
    );

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

    //print("business getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      //   results.addAll(jsonData);
      //   results.shuffle();
      // });

      setState(() {
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchEvent allEntities.toString()');
      // //print(allEntities.toString());
      // print('business results');
      // print(jsonData.length);
      return jsonData;
    }
  }

  search(){
    setState(() {
      results.clear();
    });

    bool bb = false;
    for(var e in allEntities){
      if((e['user_username'] != null && e['user_username'].toString().toLowerCase().contains(_textController.text.toLowerCase()) ||
          (e['user_name'] != null && e['user_name'].toString().toLowerCase().contains(_textController.text.toLowerCase()))) &&
          Utils.isSocial){
        setState(() {
          bb = true;
          results.add(e);
        });
      }
      else if((e['prestazione_title'] != null && e['prestazione_title'].toString().toLowerCase().contains(_textController.text.toLowerCase()))
          /*&& e['business_address'] == null*/){
        setState(() {
          bb = true;
          results.add(e);
        });
      }
      else if((e['business_name'] != null && e['business_name'].toString().toLowerCase().contains(_textController.text.toLowerCase()))){
        setState(() {
          bb = true;
          results.add(e);
        });
      }
      else if((e['business_address'] != null && e['business_address'].toString().toLowerCase().contains(_textController.text.toLowerCase()))){
        setState(() {
          bb = true;
          results.add(e);
        });
      }
      // else results.clear();
    }
    if(!bb){
      setState(() {
        results.clear();
      });
    }
    else{
      results.shuffle();
    }
  }

  search2(){
    // searchUserByUsername();
    // searchEvent();
    // searchPrestazioneByTitle();
    // //print('usernamesss');
    // for(var e in results){
    //   //print(e['username']);
    // }
    // setState(() {
    //   results.where((e) {
    //     String usernameLower = '';
    //     String titleLower = '';
    //     if (e['username'] != null){
    //       /*final*/usernameLower = e['username'].toLowerCase();
    //     }
    //     else if (e['title'] != null){
    //       /*final*/titleLower = e['title'].toLowerCase();
    //     }
    //
    //     return usernameLower.contains(_textController.text.toLowerCase()) &&
    //         titleLower.contains(_textController.text.toLowerCase());
    //     // allEntities.where((element) =>
    //     // element.username.toLowerCase().contains(_textController.text.toLowerCase())).toList();
    //     /*if (e['username'] != null) {
    //       return e['username'].toLowerCase().contains(_textController.text.toLowerCase())*//*.toList()*//*;
    //     }
    //     if (e['title'] != null) {
    //       return e['title'].toLowerCase().contains(_textController.text.toLowerCase())*//*.toList()*//*;
    //     }
    //     else return null;*/
    //   }).toList();
    // });
  }

  @override
  void initState() {
    super.initState();
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);

    // searchUserByUsername();
    // searchEvent();
    // searchPrestazioneByTitle();

    Future.wait([
      // a = /*Utils.isEventsEnabled ? */getAllEvent(),
      b = getAllPrestazione(),
      // getAllUser(),
      c = getAllBusiness()
    ]).then((value) {
    // getAllEvent().then((value) =>
    //   getAllPrestazione()).then((value) =>
    //     // getAllBusiness()).then((value) =>
    //       getAllUser()).then((value) {
            setState(() {
              // _textController.text = '';
              _textController.text = widget.text;
              results.addAll(allEntities);
              results.shuffle();
            });
      }).then((value) {
      return search();
    });
    // results.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 3,
        // leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey[600],
              size: 27,
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        // centerTitle: true,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextField(
            style: TextStyle(
                fontWeight: FontWeight.w600
            ),
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 0, top: 13, right: 20),
              prefixIconConstraints: BoxConstraints(minWidth: 0, maxHeight: 30),
              // hintText: 'Cerca eventi, utenti, locali...',
              // hintText: 'Cerca...',
              hintText: 'Cerca per indirizzo, prestazione, locale...',
              labelStyle: TextStyle(
                // color: Colors.blue[500]
                color: Colors.grey[500]
              ),
              hintStyle: TextStyle(
                  // fontSize: 18,
                  fontSize: 15,
                // color: Colors.blue[300]
                color: Colors.grey[400],
                fontWeight: FontWeight.w400

              ),
              helperStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[300]
              ),
              enabled: true,
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              isDense: false,
              isCollapsed: false,
              alignLabelWithHint: true,
              // prefixStyle: TextStyle(
              //   fontWeight: FontWeight.w900
              // ),
              suffixIcon: _textController.text != '' ? IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 27,
                  color: Colors.grey,
                ),
                onPressed: (){
                  setState(() {
                    _textController.text = '';
                    results.clear();
                    results.addAll(allEntities);
                    results.shuffle();
                  });

                  // searchUserByUsername();
                  // searchEvent();
                  // searchPrestazioneByTitle();

                },
              ) : Text(' '),
              //   prefixIcon: IconButton(
              //     icon: Icon(
              //       Icons.arrow_back,
              //     ),
              //     onPressed: (){
              //
              //
              //     },
              //   ),
            ),
            onChanged: (value){
              search();
            },
            controller: _textController,
          ),
        ),
        actions: [
          // SizedBox(width: 15,),
          // InkWell(
          //   onTap: (){
          //     Navigator.push(
          //         context,
          //         PageTransition(
          //             duration: const Duration(
          //                 milliseconds: 500
          //             ),
          //             alignment: Alignment.center,
          //             type: PageTransitionType.fade,
          //             child: const SearchMapScreen()
          //         )
          //     );
          //   },
          //   splashColor: Colors.transparent,
          //   focusColor: Colors.transparent,
          //   overlayColor: MaterialStateProperty.all(Colors.transparent),
          //   hoverColor: Colors.transparent,
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 20.0),
          //     child: Icon(
          //       Icons.map_outlined,
          //       // color: Colors.grey[400],
          //       color: Colors.blue[400],
          //       size: 30,
          //     ),
          //   ),
          // ),
          // SizedBox(width: 10,)
        ],
      ),
      //TODO: Ricerca di soli utenti
      // body: ListView.builder(
      //   itemBuilder: (context, index){
      //     return ListTile(
      //       leading: Card(
      //         // margin: EdgeInsets.only(right: ),
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(5.0),
      //         ),
      //         clipBehavior: Clip.antiAliasWithSaveLayer,
      //         elevation: 20,
      //         child: results[index]['profile_image'] != null ? Image.network(
      //           // "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      //           results[index]['profile_image'],
      //           // listData[index],
      //           fit: BoxFit.cover,
      //           width: 50,
      //           height: 50,
      //         ) : Text(""),
      //       ),
      //       title: Text(
      //         "@" + results[index]['username'],
      //       ),
      //       subtitle: Text(results[index]['email']),
      //       trailing: Text(
      //         /*'Followers:\n' + */ /*user.numFollowers.toString() + '\nfollowers'*/
      //         '#' + Random().nextInt(99999).toString(),
      //         style: TextStyle(color: Colors.blue),
      //       ),
      //       // onTap: (){
      //       //   query = results[index]['username'];
      //       //   // query = listUsername[index]/*['username']*/;
      //       //   showResults(context);
      //       // },
      //
      //       // leading: Image.network(
      //       //   listData[index],
      //       // ),
      //     );
      //
      //   },
      //   itemCount: results.length == null ? 0 : results.length,
      //
      // )
      body: FutureBuilder(
        future: Future.wait([/*a,*/ b, c]),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done) {

            return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  if (results[index]['user_username'] != null && Utils.isSocial) {
                    return GestureDetector(
                      onTap: () {
                        // //print(results[index]['username']);
                        Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: UserProfileScreen(
                                // user: User(
                                //   profile_image: results[index]['user_profile_image'],
                                //   id: results[index]['user_id'],
                                //   username: results[index]['user_username'],
                                //   email: results[index]['user_email'],
                                //   name: results[index]['user_name'],
                                //   description: results[index]['user_description'],
                                // ),
                                // userId: results[index]['user_id'],
                                user: results[index],
                                isTab: false,
                              ),
                            )
                        );
                      },
                      child: ListTile(
                        leading: Card(
                          // margin: EdgeInsets.only(right: ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 4,
                          child: /*results[index]['profile_image'] != null ?*/ FutureImage(
                            // "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                            results[index]['user_profile_image'] ?? "guest_profile_image.png",
                            width: 50,
                            height: 50,
                          ) /* : Text("")*/,
                        ),
                        title: Text(
                          "@" + results[index]['user_username'],
                        ),
                        // subtitle: Text(results[index]['email']),
                        subtitle: Text(results[index]['user_name'] ?? ''),
                        trailing: Text(
                          /*'Followers:\n' + */ /*user.numFollowers.toString() + '\nfollowers'*/
                          '#' + Random().nextInt(99999).toString(),
                          style: TextStyle(color: Colors.blue),
                        ),
                        // onTap: (){
                        // query = listData[index]['username'];
                        // // query = listUsername[index]/*['username']*/;
                        // showResults(context);
                        // },

                        // leading: Image.network(
                        //   listData[index],
                        // ),
                      ),
                    );
                  }
                  else if (results[index]['prestazione_title'] != null) {
                    // SingleEvent singleEvent = new SingleEvent(
                    //   id: int.parse(listData[index]['id']),
                    //   image: listData[index]['image'],
                    //   title: listData[index]['title'],
                    //   description: listData[index]['description'],
                    //   event_business_id: int.parse(listData[index]['event_business_id']),
                    //   // event_cateogry_id: int.parse(singleEventList[i]['event_cateogry_id']),
                    //   performer_name: listData[index]['performer_name'],
                    //   start_date: DateTime.parse(listData[index]['start_date']),
                    //   // end_date: DateTime.parse(singleEventList[i]['end_date']),
                    // );
                    Prestazione prestazione = Prestazione(
                      id: results[index]['prestazione_id'],
                      duration: results[index]['prestazione_duration'],
                      image: results[index]['prestazione_image'],
                      price: results[index]['prestazione_price']?.toDouble(),
                      is_price_range: (results[index]['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                      price_min: results[index]['prestazione_price_min']?.toDouble(),
                      price_max: results[index]['prestazione_price_max']?.toDouble(),
                      title: results[index]['prestazione_title'],
                      description: results[index]['prestazione_description'] ?? '',
                      created_at: DateTime.parse(results[index]['prestazione_created_at']),
                      // business_id: favoriteProvider.myFavoritesList[i]['business_id'],
                      business: Business(
                          profile_image: results[index]['business_profile_image'],
                          id: results[index]['business_id'],
                          type_id: 1,
                          room_id: results[index]['business_room_id'],
                          longitude: results[index]['business_longitude'],
                          latitude: results[index]['business_latitude'],
                          name: results[index]['business_name'],
                          email: results[index]['business_email'],
                          description: results[index]['business_description'],
                          address: results[index]['business_address'],
                          phone: results[index]['business_phone'],
                          max_contemporary_appointments: results[index]['max_contemporary_appointments'],
                          category: Category(
                            id: results[index]['category_id'],
                            image: results[index]['category_image'],
                            name: results[index]['category_name'],
                          )
                      ),
                    );

                    return GestureDetector(
                      onTap: () {
                        // print(results[index]['prestazione_image']);
                        // print(results[index]['business_profile_image']);

                        Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: PrestazioneSlotsScreen(
                                prestazione: prestazione,
                              ),
                            )
                        );
                      },
                      child: ListTile(
                        // isThreeLine: true,
                        leading: Card(
                          // margin: EdgeInsets.only(right: ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 4,
                          child: FutureImage(
                            // results[index]['prestazione_image'] != '' && results[index]['prestazione_image'] != null
                            //   ? results[index]['prestazione_image'] : results[index]['business_profile_image'],
                            prestazione.image != '' && prestazione.image != null
                              ? prestazione.image! : prestazione.business!.profile_image!,
                            // event.image,
                            width: 77.5,
                            height: 50,
                          ),
                        ),
                        // title: Text(
                        //   results[index]['title'],
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //     /*color: Colors.blue*/fontWeight: FontWeight.w500,
                        //     color: Colors.blue
                        //   ),
                        // ),
                        // horizontalTitleGap: 0,
                        minVerticalPadding: 0,
                        title: Marquee(
                          child: GradientText(
                            // results[index]['prestazione_title'] ?? '',
                            prestazione.title ?? '',
                            // 'A partire da € 60,00',
                            maxLines: 1,
                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                            // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                            gradient: /*results[index]['category_id']*/prestazione.business!.category == 10 ? Gradients.backToFuture : LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xff8921aa),
                                  Color(0xffDA44bb),

                                  // Color(0xffDA44bb)
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
                                fontWeight: FontWeight.w500,
                                fontSize: 16
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        subtitle: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(event.performer_name),
                            SizedBox(
                              height: 0,
                            ),
                            // Text(
                            //   // "25 posti disponibili",
                            //   "Prenotazioni aperte",
                            //   style: TextStyle(
                            //     color: Colors.greenAccent[700],
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),

                            Text(
                              results[index]['business_name'] ?? '',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
                              ),
                            ),

                          ],
                        ),
                        trailing: Text(
                          /*results[index]['begin_at'] == null || results[index]['begin_at'] == '' &&*/ !prestazione.is_price_range
                            ? '€ ${NumberFormat.currency(
                            // customPattern: '#,##',
                              decimalDigits: 2,
                              symbol: '',
                              locale: 'IT_it'
                            ).format(prestazione.price ?? 0)}'
                            : prestazione.is_price_range ? 'da € ${NumberFormat.currency(
                            // customPattern: '#,##',
                              decimalDigits: 2,
                              symbol: '',
                              locale: 'IT_it'
                            ).format(prestazione.price_min)}\na € ${NumberFormat.currency(
                            // customPattern: '#,##',
                              decimalDigits: 2,
                              symbol: '',
                              locale: 'IT_it'
                            ).format(prestazione.price_max)}'
                            : '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    );
                  }
                  else if (results[index]['event_title'] != null && Utils.isEventsEnabled) {
                    // SingleEvent singleEvent = new SingleEvent(
                    //   id: int.parse(listData[index]['id']),
                    //   image: listData[index]['image'],
                    //   title: listData[index]['title'],
                    //   description: listData[index]['description'],
                    //   event_business_id: int.parse(listData[index]['event_business_id']),
                    //   // event_cateogry_id: int.parse(singleEventList[i]['event_cateogry_id']),
                    //   performer_name: listData[index]['performer_name'],
                    //   start_date: DateTime.parse(listData[index]['start_date']),
                    //   // end_date: DateTime.parse(singleEventList[i]['end_date']),
                    // );

                    return GestureDetector(
                      onTap: () {
                        // //print(results[index]['prestazione_title']);
                        Event event = Event(
                          id: results[index]['event_id'],
                          image: results[index]['event_image'],
                          title: results[index]['event_title'],
                          description: results[index]['event_description'],
                          business_id: results[index]['business_id'],
                          // event_cateogory_id: int.parse(singleEventList[i]['event_cateogry_id']),
                          // performer_name: eventList[i]['performer_name'],
                          begin_at: DateTime.parse(
                              results[index]['event_begin_at']),
                          end_at: DateTime.parse(
                              results[index]['event_end_at']),
                          business: Business(
                              profile_image: results[index]['business_profile_image'],
                              id: results[index]['business_id'],
                              type_id: 1,
                              longitude: results[index]['business_longitude'],
                              latitude: results[index]['business_latitude'],
                              name: results[index]['business_name'],
                              room_id: results[index]['business_room_id'],
                              email: results[index]['business_email'],
                              description: results[index]['business_description'],
                              address: results[index]['business_address'],
                              phone: results[index]['business_phone'],
                              max_contemporary_appointments: results[index]['max_contemporary_appointments'],
                              category: Category(
                                id: results[index]['category_id'],
                                image: results[index]['category_image'],
                                name: results[index]['category_name'],
                              )
                          ),
                        );

                        Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: EventScreen(
                                event: event,
                              ),
                            )
                        );
                      },
                      child: ListTile(
                        // isThreeLine: true,
                        leading: Card(
                          // margin: EdgeInsets.only(right: ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 4,
                          child: FutureImage(
                            results[index]['event_image'] ?? '',
                            // event.image,
                            width: 77.5,
                            height: 50,
                          ),
                        ),
                        // title: Text(
                        //   results[index]['title'],
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //     /*color: Colors.blue*/fontWeight: FontWeight.w500,
                        //     color: Colors.blue
                        //   ),
                        // ),
                        // horizontalTitleGap: 0,
                        minVerticalPadding: 0,

                        title: Marquee(
                          child: GradientText(
                            results[index]['event_title'] ?? '',
                            // 'A partire da € 60,00',
                            maxLines: 1,

                            // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                            // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                            gradient: results[index]['category_id'] == 10
                                ? Gradients.backToFuture
                                : LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xff8921aa),
                                  Color(0xffDA44bb),
                                  // Color(0xffDA44bb)
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
                                fontWeight: FontWeight.w500,
                                fontSize: 16
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        subtitle: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(event.performer_name),
                            SizedBox(
                              height: 0,
                            ),
                            // Text(
                            //   // "25 posti disponibili",
                            //   "Prenotazioni aperte",
                            //   style: TextStyle(
                            //     color: Colors.greenAccent[700],
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),

                            Marquee(
                              child: Text(
                                results[index]['business_address'] ?? '',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14
                                ),
                              ),
                            ),

                          ],
                        ),
                        // trailing: Text(
                        //     results[index]['begin_at'] == null || results[index]['begin_at'] == '' ? '€ ' + NumberFormat.currency(
                        //     // customPattern: '#,##',
                        //       decimalDigits: 2,
                        //       symbol: '',
                        //       locale: 'IT_it'
                        //   ).format(results[index]['prestazione_price']): '',
                        //   style: TextStyle(
                        //     color: Colors.green[600],
                        //     fontWeight: FontWeight.w600
                        //   ),
                        // ),
                      ),
                    );
                  }
                  else if(results[index]['business_address'] != null /*&& Utils.isEventsEnabled*/) {
                    // SingleEvent singleEvent = new SingleEvent(
                    //   id: int.parse(listData[index]['id']),
                    //   image: listData[index]['image'],
                    //   title: listData[index]['title'],
                    //   description: listData[index]['description'],
                    //   event_business_id: int.parse(listData[index]['event_business_id']),
                    //   // event_cateogry_id: int.parse(singleEventList[i]['event_cateogry_id']),
                    //   performer_name: listData[index]['performer_name'],
                    //   start_date: DateTime.parse(listData[index]['start_date']),
                    //   // end_date: DateTime.parse(singleEventList[i]['end_date']),
                    // );

                    Business business = Business(
                        id: results[index]['business_id'],
                        profile_image: results[index]['business_profile_image'],
                        name: results[index]['business_name'],
                        email: results[index]['business_email'],
                        longitude: results[index]['business_longitude'],
                        latitude: results[index]['business_latitude'],
                        room_id: results[index]['business_room_id'],
                        description: results[index]['business_description'],
                        phone: results[index]['business_phone'],
                        address: results[index]['business_address'],
                        // category_id: businessList[i]['category_id'],
                        type_id: results[index]['business_type_id'].toInt(),
                        distance: results[index]['business_distance'],
                        max_contemporary_appointments: results[index]['max_contemporary_appointments'],
                        // id: results[index]['id'],
                        // profile_image: results[index]['profile_image'],
                        // name: results[index]['name'],
                        // email: results[index]['email'],
                        // longitude: results[index]['longitude'],
                        // latitude: results[index]['latitude'],
                        // description: results[index]['description'],
                        // phone_number: results[index]['phone_number'],
                        // address: results[index]['address'],
                        // // category_id: businessList[i]['category_id'],
                        // //todo: da cambiare in type_id anche in db
                        // business_type_id: results[index]['business_type_id'].toInt(),
                        // max_contemporary_appointments: results[index]['max_contemporary_appointments'],
                        category: Category(
                          id: results[index]['category_id'],
                          image: results[index]['category_image'],
                          name: results[index]['category_name'],
                        ),
                        // timetable: Timetable(
                        //   id: results[index]['timetable_id'] ?? '',
                        //   weekdayId: results[index]['weekday_id'] ?? -1,
                        //   openAtHour: results[index]['open_at_hour'] ?? '0',
                        //   openAtMinute: results[index]['open_at_minute'] ?? '0',
                        //   closeAtHour: results[index]['close_at_hour'] ?? '0',
                        //   closeAtMinute: results[index]['close_at_minute'] ?? '0',
                        // )
                    );

                    return Visibility(
                      visible: results[index]['category_id'].toString() == '14' ||
                          results[index]['category_id'].toString() == '15' ||
                          results[index]['category_id'].toString() == '18',
                      child: GestureDetector(
                        onTap: (){

                          //print(results[index]['business_name']);

                          if(results[index]['category_id'].toString() == '14' ||
                              results[index]['category_id'].toString() == '15' ||
                              results[index]['category_id'].toString() == '18'){
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 500),
                                    alignment: Alignment.center,
                                    type: PageTransitionType.fade,
                                    child: BookingBusinessProfileScreen(
                                        business: business
                                    )
                                )
                            );
                          }
                          else {
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 500),
                                    alignment: Alignment.center,
                                    type: PageTransitionType.fade,
                                    child: EventBusinessProfileScreen(
                                        eventBusiness: business
                                    )
                                )
                            );
                          }
                        },
                        child: ListTile(
                          // isThreeLine: true,
                          leading: Card(
                            // margin: EdgeInsets.only(right: ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 4,
                            child: FutureImage(
                              // imageUrl: results[index]['business_profile_image'] ?? '',
                              results[index]['business_profile_image'] ?? '',
                              // event.image,
                              // fit: BoxFit.cover,
                              width: 65,
                              height: 50,
                              // errorWidget: (context, url, error) => SizedBox(),
                            ),
                          ),
                          // title: Text(
                          //   results[index]['title'],
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //     /*color: Colors.blue*/fontWeight: FontWeight.w500,
                          //     color: Colors.blue
                          //   ),
                          // ),
                          // horizontalTitleGap: 0,
                          minVerticalPadding: 0,
                          title: Marquee(
                            child: GradientText(
                              // results[index]['business_name'] ?? '',
                              results[index]['business_name'] ?? '',
                              // 'A partire da € 60,00',
                              maxLines: 1,
                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              // gradient: Gradients.cosmicFusion,
                              // gradient: results[index]['category_id'] == 10 ? Gradients.cosmicFusion : LinearGradient(
                              //     begin: Alignment.bottomLeft,
                              //     end: Alignment.topRight,
                              //     colors: [
                              //       Color(0xff8921aa),
                              //       Color(0xffDA44bb),
                              //       // Color(0xffDA44bb)
                              //     ]
                              // ),
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    // Colors.black,
                                    // Colors.black,
                                    // Color(0xffDA44bb),
                                    // Color(0xff8921aa),

                                    // Color(0xffFFA818),
                                    Color(0xffF68A3D),
                                    Color(0xfffd746c),
                                    // Color(0xffff9068),
                                  ]
                              ),
                              style: TextStyle(
                                  // color: Colors.blue,
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          subtitle: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(event.performer_name),
                              SizedBox(
                                height: 0,
                              ),
                              // Text(
                              //   // "25 posti disponibili",
                              //   "Prenotazioni aperte",
                              //   style: TextStyle(
                              //     color: Colors.greenAccent[700],
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Marquee(
                                  child: Text(
                                    // results[index]['business_address'] ?? '',
                                    results[index]['business_address'] ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                          // trailing: Text(
                          //   DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.tryParse(business.timetable!.openAtHour!)!, int.tryParse(business.timetable!.openAtMinute!)!)
                          //     .isBefore(DateTime.now())
                          //     && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.tryParse(business.timetable!.closeAtHour!)!, int.tryParse(business.timetable!.closeAtMinute!)!)
                          //     .isAfter(DateTime.now()) && business.timetable!.weekdayId != -1 ? 'Aperto' : 'Chiuso',
                          //   style: TextStyle(
                          //     color: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.tryParse(business.timetable!.openAtHour!)!, int.tryParse(business.timetable!.openAtMinute!)!)
                          //       .isBefore(DateTime.now()) && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.tryParse(business.timetable!.closeAtHour!)!, int.tryParse(business.timetable!.closeAtMinute!)!)
                          //       .isAfter(DateTime.now()) && business.timetable!.weekdayId != -1 ? Colors.green[600] : Colors.red[600],
                          //     fontWeight: FontWeight.w600
                          //   ),
                          // ),

                          // trailing: Text(
                          //     results[index]['begin_at'] == null || results[index]['begin_at'] == '' ? '€ ' + NumberFormat.currency(
                          //     // customPattern: '#,##',
                          //       decimalDigits: 2,
                          //       symbol: '',
                          //       locale: 'IT_it'
                          //   ).format(results[index]['price']): '',
                          //   style: TextStyle(
                          //     color: Colors.green[600],
                          //     fontWeight: FontWeight.w600
                          //   ),
                          // ),

                          trailing: Text(
                            business.distance != null && business.distance! > 0
                              ? "${business.distance!.toStringAsFixed(2)} km"
                              : '',
                            style: TextStyle(
                              // color: Colors.grey[600],
                              color: Colors.blue[500],
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  else {
                    return const SizedBox();
                  }
                }
            );
          }
          else {
            return const Center(child: CircularProgressIndicator(),);
          }
        }
      ),

    );
  }
}
