import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:bubble/bubble.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/business_category_list_screen.dart';
import 'package:nurebo/screens/event_business_profile_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart' as map_launcher;



class ExploreScreen extends StatefulWidget {

  const ExploreScreen({Key? key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  late GeolocationProvider geolocationProvider;
  // List businessList = [];
  List<Business> businessList = [];
  Future a = Future(() {}), b = Future(() {}), c = Future(() {});
  final MapController mapController = MapController();
  // final markers = <Marker>[
  //   Marker(
  //     width: 80,
  //     height: 80,
  //     point: LatLng(51.5, -0.09),
  //     builder: (ctx) => const FlutterLogo(
  //       textColor: Colors.blue,
  //       key: ObjectKey(Colors.blue),
  //     ),
  //   ),
  //   Marker(
  //     width: 80,
  //     height: 80,
  //     point: LatLng(53.3498, -6.2603),
  //     builder: (ctx) => const FlutterLogo(
  //       textColor: Colors.green,
  //       key: ObjectKey(Colors.green),
  //     ),
  //   ),
  //   Marker(
  //     width: 80,
  //     height: 80,
  //     point: LatLng(48.8566, 2.3522),
  //     builder: (ctx) => const FlutterLogo(
  //       textColor: Colors.purple,
  //       key: ObjectKey(Colors.purple),
  //     ),
  //   ),
  // ];
  final List<LatLng> ciccio = [
    LatLng(45.5, 9.09),
    LatLng(45.4, 9.15),
    LatLng(45.45, 9.2),
  ];
  List<Marker> markers = [];


  Future callFutureBuilder() async {
    /*a = */getBusinessByCategory();
    /*b = */geolocationProvider.checkGeolocationPermission(context);
  }

  List<Marker> generateMarkers() {
    List<Marker> mm = [];
    List<Marker> businessMarkers = List<Marker>.generate(/*ciccio.length*/businessList.length, (index) {
      return Marker(
        width: 150,
        height: 55,
        rotate: true,

        // point: ciccio[index],
        point: LatLng(
          // businessList[index]['business_latitude'],
          businessList[index].latitude ?? ciccio[0].latitude,
          // businessList[index]['business_longitude'],
          businessList[index].longitude ?? ciccio[0].longitude,
        ),
        builder: (ctx) => InkWell(
          onTap: () {
            // print('businessList[index]');
            // print(businessList[index].name);

            Navigator.push(
              context,
              PageTransition(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  type: PageTransitionType.fade,
                  child: businessList[index].type_id == 1 ? BookingBusinessProfileScreen(
                    business: businessList[index],
                    // user: widget.user,
                  ) : businessList[index].type_id == 2 ? EventBusinessProfileScreen(
                    eventBusiness: businessList[index],
                    // user: widget.user,
                  ) : SizedBox()
              ),
            );
          },
          // child: const Icon(
          //   // textColor: Colors.red,
          //   // key: ObjectKey(Colors.red),
          //   // Icons.web_stories,
          //   // Icons.storefront_rounded,
          //   Icons.deck_rounded,
          //   size: 40,
          //   color: Colors.black,
          // ),
          child: Bubble(
            margin: BubbleEdges.only(top: 0),
            padding: BubbleEdges.only(top: 5, bottom: 5, left: 5, right: 5),

            alignment: Alignment.topLeft,
            nip: BubbleNip.leftBottom,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // // titleText,
                // // commentText,
                // // imageProfile,
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 5.0),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(50),
                //     child: Image(
                //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postList[i]['profile_image']),
                //       image: CachedNetworkImageProvider(
                //         item['business_profile_image'],
                //         errorListener: () => SizedBox(),
                //       ),
                //       width: 41,
                //       height: 41,
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                // // SizedBox(height: 10,),
                // Padding(
                //   padding: const EdgeInsets.only(left: 2.0),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // usernameText,
                //       Container(
                //         width: MediaQuery.of(context).size.width * 0.23,
                //         child: Text(
                //           item['business_name'] ?? '',
                //           maxLines: 1,
                //           style: TextStyle(
                //               color: Colors.yellow,
                //               fontWeight: FontWeight.w700,
                //               fontSize: 11
                //           ),
                //         ),
                //       ),
                //       Container(
                //         width: MediaQuery.of(context).size.width * 0.23,
                //         child: Text(
                //           item['prestazione_title'] ?? '',
                //           // item['business_address'] ?? '',
                //           maxLines: 1,
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.w500,
                //               fontSize: 12
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // SizedBox(width: 10,),

                // RotationTransition(
                //   turns: AlwaysStoppedAnimation(15 / 360),
                //   child: Container(
                //     width: 1,
                //     height: 30,
                //     color: Colors.white,
                //   ),
                // ),
                //
                // SizedBox(width: 15,),

                SizedBox(width: 5,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureImage(
                    // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postList[i]['profile_image']),
                    // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                    // 'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                    // businessList[index]['business_profile_image'],
                    businessList[index].profile_image ?? '',
                    width: 35,
                    height: 35,
                  ),
                ),
                SizedBox(width: 5,),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2.1),
                        child: Container(
                          width: 70,
                          child: Marquee(
                            child: Text(
                              // 'Discoteca Lumiere',
                              // businessList[index]['business_address'],
                              businessList[index].address ?? '',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.5
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Container(
                          width: 70,
                          child: Marquee(
                            child: GradientText(
                              // 'Hallloween Night',
                              // businessList[index]['business_name'],
                              businessList[index].name ?? '',
                              shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              // gradient: Gradients.haze,
                              // gradient: LinearGradient(
                              //   begin: Alignment.topCenter,
                              //   end: Alignment.bottomCenter,
                              //   colors: [
                              //     Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                              //     Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
                              //   ],
                              // ),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    Marker userMarker = (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
        width: 45.0,
        height: 45.0,
        // point: new LatLng(40.73, -74.00),
        // point: LatLng(45.4281857,9.1531147),
        // point: LatLng(45.44131,9.14952),
        // point: LatLng(45.4281857,9.1531147),
        // point: LatLng(widget.business!.latitude!, widget.business!.longitude!),
        point: LatLng(geolocationProvider.position?.latitude ?? ciccio[0].latitude, geolocationProvider.position?.longitude ?? ciccio[0].longitude),
        // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
        builder: (context) => Material(
          type: MaterialType.transparency,
          child: InkWell(
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 8,
              child: FutureImage(
                userProvider.user != null && userProvider.user!.profile_image != null ? userProvider.user!.profile_image! : '',
                width: 10,
                height: 10,
              ),
            ),
            onTap: () async {
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
                  destination: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                  // destinationTitle: destinationTitle,
                  origin: map_launcher.Coords(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude),
                  originTitle: 'originTitle',
                  // waypoints: waypoints,
                  directionsMode: map_launcher.DirectionsMode.driving,
                  mapType: map_launcher.MapType.google,
                );
              }

              //lanciare il dialog animation
            },
          ),
        )
    ) : Marker(point: LatLng(ciccio[0].latitude, ciccio[0].longitude), builder: (BuildContext context) { return widget; });

    // setState(() {
      markers.add(userMarker);
      markers.addAll(businessMarkers);
      mm.add(userMarker);
      mm.addAll(businessMarkers);
    // });

    return mm;
  }

  Future getBusinessByCategory() async {
    // var url = Uri.parse(Utils.httpServerUrl + "category/business");
    // Map<String, dynamic> body = {
    //   "category_id": 10
    // };
    // var url = Uri.parse(Utils.httpServerUrl + "category/10/business");
    var url = Uri.parse("${Utils.httpServerUrl}business?is_visible=1&is_valid=1");

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
        // setState(() {
        //   businessList.addAll(jsonData);
        // });

        if(mounted){
          setState(() {
            for (var e in jsonData) {
              businessList.add(
                  Business(
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
                        id: e['business_category_id'],
                        name: e['category_name'],
                        image: e['category_image'],
                      )
                  )
              );
            }
          });
        }

        //print('businessList');
        //print(businessList);

        return jsonData;
      }
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    initializeDateFormatting();
    // generateMarkers();

    Future.wait([
      // a = getBusinessByCategory(),
      // // b = generateMarkers(),
      // b = geolocationProvider.checkGeolocationPermission(context),
      c = callFutureBuilder(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    // socketProvider.dispose();
    // geolocationProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        // preferredSize: Size.fromHeight(100),
        preferredSize: Size.fromHeight(55),
        // child: AppBar2(user: widget.user,),
        child: NureboAppBar(
          // user: userProvider.user,
          // user: widget.user,
        ),
      ),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(55),
      //   child: AppBar(
      //     elevation: 0,
      //     backgroundColor: Colors.white,//Color.fromRGBO(245, 93, 62, 1),
      //     title: Text(
      //       'Mappa',
      //       style: TextStyle(
      //           color: Colors.blue,
      //           // color: Colors.grey[800],
      //           fontSize: 18,
      //           fontWeight: FontWeight.w700
      //       ),
      //     ),
      //     centerTitle: true,
      //     leading: IconButton(
      //       onPressed: (){
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(
      //         Icons.arrow_back_outlined,
      //         color: Colors.grey[500],
      //         size: 27,
      //       ),
      //       color: Colors.black,
      //     ),
      //     actions: [
      //       // Padding(
      //       //   padding: const EdgeInsets.only(right: 15),
      //       //   child: Icon(
      //       //     Icons.textsms_outlined,
      //       //     color: Colors.grey[600],
      //       //     // color: Colors.blue[500],
      //       //     size: 28,
      //       //   ),
      //       // )
      //
      //       // InkWell(
      //       //   onTap: () {
      //       //     // _bottomSheetOptions(context);
      //       //   },
      //       //   child: Padding(
      //       //     padding: const EdgeInsets.only(right: 15.0, left: 15),
      //       //     child: Icon(
      //       //       // SimpleLineIcons.options_vertical,
      //       //       // MaterialIcons.list,
      //       //       // MaterialIcons.filter_list,
      //       //       Icons.filter_list,
      //       //       // MaterialIcons.format_list_bulleted,
      //       //       // size: 17,
      //       //       size: 30,
      //       //       color: Colors.grey[500],
      //       //     ),
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // ),
      drawer: NureboDrawer(),
      onDrawerChanged: (value){
        if(Utils.isSocial){
          //todo: false per nascondere bottombar
          //print(value);
          socketProvider.setBottomBarVisibility(!value);
        }
      },
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            height: MediaQuery.of(context).size.height * .2,
            child: Container(
              // height: MediaQuery.of(context).size.height * 0.175,
              // height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (businessList.length/3).ceil(),
                  // physics: const BouncingScrollPhysics(),
                  // itemCount: categoryList!.length,
                  controller: PageController(),
                  onPageChanged: (i){
                    //print(i);
                    // setState(() {
                    //   pageNum = i+1;
                    // });
                  },
                  itemBuilder: (context, index){

                    return Padding(
                      padding: const EdgeInsets.only(top: 0, right: 5, left: 5, bottom: 10),
                      child: StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          // padding: EdgeInsets.only(top: 0),
                          padding: EdgeInsets.all(0),
                          crossAxisCount: 3,
                          staggeredTileBuilder: (i) => StaggeredTile.count(1, 1),
                          //shrinkWrap: true,
                          mainAxisSpacing: 0,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 0,
                          // itemCount: categoryList!.length,
                          itemCount: 3,
                          itemBuilder: (context, ind) {
                            int indice = ((businessList.length/(businessList.length/3)).floor()*index)+ind;

                            if(indice >= businessList.length) {
                              return const SizedBox();
                            }
                            // if(((businessList.length/3).ceil()*index)+ind >= businessList.length) {
                            //   return const SizedBox();
                            // }
                            // //print('ind');
                            // //print(ind);
                            return Container(
                              // height: MediaQuery.of(context).size.height * 0.2,
                              // width: MediaQuery.of(context).size.width * .7,
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: businessList[indice].type_id == 1 ? BookingBusinessProfileScreen(
                                        business: businessList[indice],
                                        // user: widget.user,
                                      ) : businessList[indice].type_id == 2 ? EventBusinessProfileScreen(
                                        eventBusiness: businessList[indice],
                                        // user: widget.user,
                                      ) : SizedBox()
                                    ),
                                  );
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
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                                            child: FutureImage(
                                              // businessList[((businessList.length/3).ceil()*index)+ind]['business_profile_image'],
                                              // businessList[indice]['business_profile_image'],
                                              businessList[indice].profile_image ?? '',
                                              width: MediaQuery.of(context).size.width,
                                            ),
                                          )
                                      ),
                                      Center(
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * .25,
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            // color: Colors.white.withOpacity(1)),
                                            // image: DecorationImage(
                                            //   fit: BoxFit.cover,
                                            //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                                            //   image: FutureImage(
                                            //     // categories[i].image,
                                            //     businessList[((businessList.length/3).ceil()*index)+ind]['business_profile_image'],
                                            //     width: null,
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
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaY: 30,
                                                  sigmaX: 30
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: Marquee(
                                                  child: Text(
                                                    // categories[i].name,
                                                    // businessList[((businessList.length/3).ceil()*index)+ind]['business_name'],
                                                    // businessList[indice]['business_name'],
                                                    businessList[indice].name ?? '',
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.lato(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
          ),
          FutureBuilder(
            // future: Future.wait([a, b]),
            future: c,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                return Flexible(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      // controller: mapController,
                      // center: LatLng(51.5, -0.09),
                      center: LatLng(
                        businessList.isNotEmpty ? (businessList[0].latitude ?? ciccio[0].latitude) : ciccio[0].latitude,
                        businessList.isNotEmpty ? (businessList[0].longitude ?? ciccio[0].longitude) : ciccio[0].longitude,
                      ),
                      zoom: 11.5,
                      onTap: (tapPosition, latLng) {
                        // TapDownDetails? details = TapDownDetails();
                        // var x = details.globalPosition.dx;
                        // var y = details.globalPosition.dy;
                        // print(x);
                        // print(y);
                        // print(latLng);
                        // print(tapPosition.global.dx);
                        // print(tapPosition.global.dy);
                      }, // Handle the tap event
                    ),
                    children: [
                    // layers: [
                      TileLayer(
                      // TileLayerOptions(
                        // options: TileLayerOptions(
                        //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        //   tileProvider: NetworkTileProvider(),
                        //   userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                        // ),
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider: NetworkTileProvider(),
                        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      ),
                      // MarkerLayer(markers: markers)
                      // MarkerLayerOptions(
                      //   markers: List<Marker>.generate(/*ciccio.length*/businessList.length, (index) {
                      //   return Marker(
                      //     width: 150,
                      //     height: 55,
                      //     rotate: true,
                      //
                      //     // point: ciccio[index],
                      //     point: LatLng(
                      //       // businessList[index]['business_latitude'],
                      //       businessList[index].latitude!,
                      //       // businessList[index]['business_longitude'],
                      //       businessList[index].longitude!,
                      //     ),
                      //     builder: (ctx) => InkWell(
                      //       onTap: () {
                      //         // print('businessList[index]');
                      //         // print(businessList[index].name);
                      //
                      //         Navigator.push(
                      //           context,
                      //           PageTransition(
                      //             duration: const Duration(milliseconds: 500),
                      //             alignment: Alignment.center,
                      //             type: PageTransitionType.fade,
                      //             child: businessList[index].type_id == 1 ? BookingBusinessProfileScreen(
                      //               bookingBusiness: businessList[index],
                      //               // user: widget.user,
                      //             ) : businessList[index].type_id == 2 ? EventBusinessProfileScreen(
                      //               eventBusiness: businessList[index],
                      //               // user: widget.user,
                      //             ) : SizedBox()
                      //           ),
                      //         );
                      //       },
                      //       // child: const Icon(
                      //       //   // textColor: Colors.red,
                      //       //   // key: ObjectKey(Colors.red),
                      //       //   // Icons.web_stories,
                      //       //   // Icons.storefront_rounded,
                      //       //   Icons.deck_rounded,
                      //       //   size: 40,
                      //       //   color: Colors.black,
                      //       // ),
                      //       child: Bubble(
                      //         margin: BubbleEdges.only(top: 0),
                      //         padding: BubbleEdges.only(top: 5, bottom: 5, left: 5, right: 5),
                      //
                      //         alignment: Alignment.topLeft,
                      //         nip: BubbleNip.leftBottom,
                      //         color: Colors.white,
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             // // titleText,
                      //             // // commentText,
                      //             // // imageProfile,
                      //             // Padding(
                      //             //   padding: EdgeInsets.symmetric(horizontal: 5.0),
                      //             //   child: ClipRRect(
                      //             //     borderRadius: BorderRadius.circular(50),
                      //             //     child: Image(
                      //             //       // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postList[i]['profile_image']),
                      //             //       image: CachedNetworkImageProvider(
                      //             //         item['business_profile_image'],
                      //             //         errorListener: () => SizedBox(),
                      //             //       ),
                      //             //       width: 41,
                      //             //       height: 41,
                      //             //       fit: BoxFit.cover,
                      //             //     ),
                      //             //   ),
                      //             // ),
                      //             // // SizedBox(height: 10,),
                      //             // Padding(
                      //             //   padding: const EdgeInsets.only(left: 2.0),
                      //             //   child: Column(
                      //             //     crossAxisAlignment: CrossAxisAlignment.start,
                      //             //     children: [
                      //             //       // usernameText,
                      //             //       Container(
                      //             //         width: MediaQuery.of(context).size.width * 0.23,
                      //             //         child: Text(
                      //             //           item['business_name'] ?? '',
                      //             //           maxLines: 1,
                      //             //           style: TextStyle(
                      //             //               color: Colors.yellow,
                      //             //               fontWeight: FontWeight.w700,
                      //             //               fontSize: 11
                      //             //           ),
                      //             //         ),
                      //             //       ),
                      //             //       Container(
                      //             //         width: MediaQuery.of(context).size.width * 0.23,
                      //             //         child: Text(
                      //             //           item['prestazione_title'] ?? '',
                      //             //           // item['business_address'] ?? '',
                      //             //           maxLines: 1,
                      //             //           style: TextStyle(
                      //             //               color: Colors.white,
                      //             //               fontWeight: FontWeight.w500,
                      //             //               fontSize: 12
                      //             //           ),
                      //             //         ),
                      //             //       ),
                      //             //     ],
                      //             //   ),
                      //             // ),
                      //
                      //             // SizedBox(width: 10,),
                      //
                      //             // RotationTransition(
                      //             //   turns: AlwaysStoppedAnimation(15 / 360),
                      //             //   child: Container(
                      //             //     width: 1,
                      //             //     height: 30,
                      //             //     color: Colors.white,
                      //             //   ),
                      //             // ),
                      //             //
                      //             // SizedBox(width: 15,),
                      //
                      //             SizedBox(width: 5,),
                      //             ClipRRect(
                      //               borderRadius: BorderRadius.circular(8),
                      //               child: FutureImage(
                      //                 // image: NetworkImage(/*imagePosts[i].user.profileImageUrl*/postList[i]['profile_image']),
                      //                 // 'https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=1600',
                      //                 // 'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                      //                 // businessList[index]['business_profile_image'],
                      //                 businessList[index].profile_image!,
                      //                 width: 35,
                      //                 height: 35,
                      //               ),
                      //             ),
                      //             SizedBox(width: 5,),
                      //             Padding(
                      //               padding: const EdgeInsets.only(left: 2.0),
                      //               child: Column(
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   Padding(
                      //                     padding: const EdgeInsets.only(left: 2.1),
                      //                     child: Container(
                      //                       width: 70,
                      //                       child: Marquee(
                      //                         child: Text(
                      //                           // 'Discoteca Lumiere',
                      //                           // businessList[index]['business_address'],
                      //                           businessList[index].address!,
                      //                           style: TextStyle(
                      //                               color: Colors.grey[600],
                      //                               fontWeight: FontWeight.w500,
                      //                               fontSize: 10.5
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: const EdgeInsets.only(left: 2.0),
                      //                     child: Container(
                      //                       width: 70,
                      //                       child: Marquee(
                      //                         child: GradientText(
                      //                           // 'Hallloween Night',
                      //                           // businessList[index]['business_name'],
                      //                           businessList[index].name!,
                      //                           shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                      //                           // gradient: Gradients.haze,
                      //                           // gradient: LinearGradient(
                      //                           //   begin: Alignment.topCenter,
                      //                           //   end: Alignment.bottomCenter,
                      //                           //   colors: [
                      //                           //     Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                      //                           //     Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
                      //                           //   ],
                      //                           // ),
                      //                           style: TextStyle(
                      //                               fontSize: 15,
                      //                               fontWeight: FontWeight.w600
                      //                           ),
                      //                           textAlign: TextAlign.center,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //
                      //       ),
                      //     ),
                      //   );
                      // })),
                      // MarkerLayerOptions(
                      MarkerLayer(
                        markers: /*markers*/generateMarkers()
                      )
                    ],
                  ),
                );
              }
              return const SizedBox();
            }
          ),
        ],
      ),
    );
  }
}
