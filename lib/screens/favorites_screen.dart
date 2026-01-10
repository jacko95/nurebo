import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/event_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class FavoritesScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  final User? user;

  const FavoritesScreen({super.key, this.user});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // List myPrestazione = [];
  // var results;
  UserProvider? userProvider;
  late PrestazioneFavoriteProvider favoriteProvider;

  // Future getUserPrestazioneLiked() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
  //
  //   Map<String, dynamic> body = {
  //     // 'user_id': widget.user.id,
  //     'user_id': userProvider.user.id,
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
  //   //print("ticketUsers response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       myPrestazione = jsonData;
  //       // results.addAll(jsonData);
  //       // results.shuffle();
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     //print(jsonData);
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    userProvider = Provider.of<UserProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);

    // getUserPrestazioneLiked();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);

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
          // 'Salvati',
          'Preferiti',
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
        child: favoriteProvider.favoritesList.isNotEmpty ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: 5,
              left: 10,
              right: 10,
              bottom: 10
            ),
            crossAxisCount: 3,
            staggeredTileBuilder: (i) => StaggeredTile.count(1, 2),
            //shrinkWrap: true,
            mainAxisSpacing: 0,
            // physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 0,
            itemCount: favoriteProvider.favoritesList.length,
            itemBuilder: (context, i) {
              // //print('favoriteProvider.myFavoritesList');
              for(var e in favoriteProvider.favoritesList){
                // //print(e);
              }
              // //print('favoriteProvider.myFavoritesList.length');
              // //print(favoriteProvider.favoritesList.length);

              Prestazione prestazione;
              Event event;

              if(favoriteProvider.favoritesList[i]['prestazione_id'] != null){
                prestazione = Prestazione(
                  id: favoriteProvider.favoritesList[i]['prestazione_id'],
                  duration: favoriteProvider.favoritesList[i]['prestazione_duration'],
                  isValid: favoriteProvider.favoritesList[i]['prestazione_is_valid'],
                  image: favoriteProvider.favoritesList[i]['prestazione_image'],
                  price: favoriteProvider.favoritesList[i]['prestazione_price']?.toDouble(),
                  is_price_range: (favoriteProvider.favoritesList[i]['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                  price_min: favoriteProvider.favoritesList[i]['prestazione_price_min']?.toDouble(),
                  price_max: favoriteProvider.favoritesList[i]['prestazione_price_max']?.toDouble(),
                  title: favoriteProvider.favoritesList[i]['prestazione_title'],
                  description: favoriteProvider.favoritesList[i]['prestazione_description'] ?? '',
                  created_at: DateTime.parse(favoriteProvider.favoritesList[i]['created_at']),

                  // business_id: favoriteProvider.myFavoritesList[i]['business_id'],

                  business: Business(
                      profile_image: favoriteProvider.favoritesList[i]['business_profile_image'],
                      id: favoriteProvider.favoritesList[i]['business_id'],
                      type_id: 1,
                      longitude: favoriteProvider.favoritesList[i]['business_longitude'],
                      latitude: favoriteProvider.favoritesList[i]['business_latitude'],
                      name: favoriteProvider.favoritesList[i]['business_name'],
                      email: favoriteProvider.favoritesList[i]['business_email'],
                      description: favoriteProvider.favoritesList[i]['business_description'],
                      address: favoriteProvider.favoritesList[i]['business_address'],
                      room_id: favoriteProvider.favoritesList[i]['business_room_id'],
                      phone: favoriteProvider.favoritesList[i]['business_phone'],
                      max_contemporary_appointments: favoriteProvider.favoritesList[i]['max_contemporary_appointments'],
                      category: Category(
                        id: favoriteProvider.favoritesList[i]['category_id'],
                        image: favoriteProvider.favoritesList[i]['category_image'],
                        name: favoriteProvider.favoritesList[i]['category_name'],
                      )
                  ),
                );

                return InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: PrestazioneSlotsScreen(
                            prestazione: prestazione,
                            // bookingBusiness: prestazione.business,
                            // user: widget.user,
                          ),
                        )
                    );
                  },
                  child: Hero(
                    // tag: i,
                    tag: prestazione.image != null && prestazione.image != '' ? prestazione : prestazione.business!,
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
                          FutureImage(
                            prestazione.image != null && prestazione.image != '' ? prestazione.image! : prestazione.business!.profile_image!,
                            width: MediaQuery.of(context).size.width,
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
                            left: 13,
                            width: MediaQuery.of(context).size.width * 0.24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GradientText(
                                  prestazione.business!.name ?? '',
                                  // 'A partire da € 60,00',
                                  maxLines: 5,

                                  // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                  // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        // Color(0xff8921aa),
                                        // Color(0xffDA44bb),
                                        // Color(0xffDA44bb)
                                        Color(0xffFFA818),
                                        Color(0xffF68A3D),
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
                                Container(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: GradientText(
                                    prestazione.title!,
                                    maxLines: 5,
                                    shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                    gradient: Gradients.haze,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15
                                    ),
                                    textAlign: TextAlign.left,
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
                        ],
                      ),
                    ),
                  ),
                );
              }
              // else if(favoriteProvider.favoritesList[i]['event_id'] != null){
              //   event = Event(
              //     id: favoriteProvider.favoritesList[i]['event_id'],
              //     image: favoriteProvider.favoritesList[i]['event_image'],
              //     title: favoriteProvider.favoritesList[i]['event_title'],
              //     description: favoriteProvider.favoritesList[i]['event_description'],
              //     business_id: favoriteProvider.favoritesList[i]['business_id'],
              //     // event_cateogory_id: int.parse(singleEventList[i]['event_cateogry_id']),
              //     // performer_name: eventList[i]['performer_name'],
              //     begin_at: DateTime.parse(favoriteProvider.favoritesList[i]['event_begin_at']),
              //     end_at: DateTime.parse(favoriteProvider.favoritesList[i]['event_end_at']),
              //     business: Business(
              //         profile_image: favoriteProvider.favoritesList[i]['business_profile_image'],
              //         id: favoriteProvider.favoritesList[i]['business_id'],
              //         type_id: 1,
              //         longitude: favoriteProvider.favoritesList[i]['business_longitude'],
              //         latitude: favoriteProvider.favoritesList[i]['business_latitude'],
              //         name: favoriteProvider.favoritesList[i]['business_name'],
              //         email: favoriteProvider.favoritesList[i]['business_email'],
              //         description: favoriteProvider.favoritesList[i]['business_description'],
              //         address: favoriteProvider.favoritesList[i]['business_address'],
              //         phone_number: favoriteProvider.favoritesList[i]['business_phone_number'],
              //         room_id: favoriteProvider.favoritesList[i]['business_room_id'],
              //         max_contemporary_appointments: favoriteProvider.favoritesList[i]['max_contemporary_appointments'],
              //         category: Category(
              //           id: favoriteProvider.favoritesList[i]['category_id'],
              //           image: favoriteProvider.favoritesList[i]['category_image'],
              //           name: favoriteProvider.favoritesList[i]['category_name'],
              //         )
              //     ),
              //   );
              //
              //   return InkWell(
              //     highlightColor: Colors.transparent,
              //     splashColor: Colors.transparent,
              //     onTap: (){
              //
              //         Navigator.push(
              //             context,
              //             PageTransition(
              //               duration: const Duration(milliseconds: 500),
              //               alignment: Alignment.center,
              //               type: PageTransitionType.fade,
              //               child: EventScreen(
              //                 event: event,
              //                 // bookingBusiness: prestazione.business,
              //                 // user: widget.user,
              //               ),
              //             )
              //         );
              //     },
              //     child: Hero(
              //       // tag: i,
              //       tag: event.image != null && event.image != '' ? event : event.business!,
              //       child: Card(
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         clipBehavior: Clip.antiAliasWithSaveLayer,
              //         elevation: 8,
              //         child: Stack(
              //           clipBehavior: Clip.antiAliasWithSaveLayer,
              //           fit: StackFit.expand,
              //           children: [
              //             FutureImage(
              //               event.image != null && event.image != '' ? event.image! : event.business!.profile_image!,
              //               width: MediaQuery.of(context).size.width,
              //             ),
              //             DecoratedBox(
              //               decoration: BoxDecoration(
              //                 // backgroundBlendMode: BlendMode.darken,
              //                 gradient: LinearGradient(
              //                   begin: Alignment.bottomLeft,
              //                   end: Alignment.topRight,
              //                   colors: [
              //                     Colors.black,
              //                     // Colors.transparent,
              //                     Colors.transparent,
              //                   ],
              //                 ),
              //               ),
              //             ),
              //             Positioned(
              //               bottom: 15,
              //               left: 13,
              //               width: MediaQuery.of(context).size.width * 0.24,
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   GradientText(
              //                     event.business!.name ?? '',
              //                     // 'A partire da € 60,00',
              //                     maxLines: 5,
              //
              //                     // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
              //                     // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
              //                     gradient: LinearGradient(
              //                         begin: Alignment.bottomLeft,
              //                         end: Alignment.topRight,
              //                         colors: [
              //                           // Color(0xff8921aa),
              //                           // Color(0xffDA44bb),
              //                           // Color(0xffDA44bb)
              //                           Color(0xffFFA818),
              //                           Color(0xffF68A3D),
              //                         ]
              //                     ),
              //                     // gradient: LinearGradient(
              //                     //     begin: Alignment.bottomLeft,
              //                     //     end: Alignment.topRight,
              //                     //     colors: [
              //                     //       Colors.blue[500],
              //                     //       Color(0xffDA44bb),
              //                     //
              //                     //       Color(0xff8921aa),
              //                     //     ]
              //                     // ),
              //                     style: TextStyle(
              //                         color: Colors.blue,
              //                         fontWeight: FontWeight.w700,
              //                         fontSize: 13
              //                     ),
              //                     textAlign: TextAlign.left,
              //                   ),
              //                   Container(
              //                     width: MediaQuery.of(context).size.width * .3,
              //                     child: GradientText(
              //                       event.title!,
              //                       maxLines: 5,
              //                       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
              //                       gradient: Gradients.haze,
              //                       style: TextStyle(
              //                           color: Colors.white,
              //                           fontWeight: FontWeight.w700,
              //                           fontSize: 15
              //                       ),
              //                       textAlign: TextAlign.left,
              //                     ),
              //                   ),
              //                   // item.is_single_event && item.single_event.begin_at != null
              //                   //     ? GradientText(
              //                   //   DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
              //                   //   maxLines: 2,
              //                   //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
              //                   //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
              //                   //   // gradient: Gradients.backToFuture,
              //                   //   gradient: Gradients.blush,
              //                   //   // gradient: LinearGradient(
              //                   //   //     begin: Alignment.bottomLeft,
              //                   //   //     end: Alignment.topRight,
              //                   //   //     colors: [
              //                   //   //       Color(0xff8921aa),
              //                   //   //       Color(0xffDA44bb),
              //                   //   //       // Color(0xffDA44bb)
              //                   //   //     ]
              //                   //   // ),
              //                   //   // gradient: LinearGradient(
              //                   //   //     begin: Alignment.bottomLeft,
              //                   //   //     end: Alignment.topRight,
              //                   //   //     colors: [
              //                   //   //       Color(0xff8921aa),
              //                   //   //       Color(0xffDA44bb),
              //                   //   //       // Color(0xffDA44bb)
              //                   //   //     ]
              //                   //   // ),
              //                   //
              //                   //   style: TextStyle(
              //                   //       color: Colors.blue,
              //                   //       fontWeight: FontWeight.w800,
              //                   //       fontSize: 16
              //                   //   ),
              //                   //   textAlign: TextAlign.left,
              //                   // )
              //                   //     : SizedBox(height: 0, width: 0,),
              //                   // SizedBox(height: 1,),
              //                   // GradientText(
              //                   //   // item.is_single_event && item.single_event.title != null
              //                   //   //     ? item.single_event.title
              //                   //   //     : item.prestazione.title != null
              //                   //   //     ? item.prestazione.title : '',
              //                   //   item.is_single_event
              //                   //       ? 'A partire da € 15,00'/* + NumberFormat.currency(
              //                   //                         // customPattern: '#,##',
              //                   //                           decimalDigits: 2,
              //                   //                           symbol: '',
              //                   //                           locale: 'IT_it'
              //                   //                       ).format(item.single_event.)*/
              //                   //       : 'Al prezzo di € ' + NumberFormat.currency(
              //                   //     // customPattern: '#,##',
              //                   //       decimalDigits: 2,
              //                   //       symbol: '',
              //                   //       locale: 'IT_it'
              //                   //   ).format(item.prestazione.price),
              //                   //   maxLines: 2,
              //                   //
              //                   //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
              //                   //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
              //                   //   // gradient: Gradients.backToFuture,
              //                   //   gradient: !item.is_single_event
              //                   //       ? Gradients.blush
              //                   //       : LinearGradient(
              //                   //       begin: Alignment.bottomLeft,
              //                   //       end: Alignment.topRight,
              //                   //       colors: [
              //                   //         Color(0xff8921aa),
              //                   //         Color(0xffDA44bb),
              //                   //         // Color(0xffDA44bb)
              //                   //       ]
              //                   //   ),
              //                   //   style: TextStyle(
              //                   //       color: Colors.blue,
              //                   //       fontWeight: FontWeight.w800,
              //                   //       fontSize: 15
              //                   //   ),
              //                   //   textAlign: TextAlign.left,
              //                   // ),
              //                   // Text(
              //                   //   'A partire da € 60,00',
              //                   //   style: new TextStyle(
              //                   //       fontWeight: FontWeight.w800,
              //                   //       fontSize: 15,
              //                   //
              //                   //       foreground: Paint()..shader = LinearGradient(
              //                   //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
              //                   //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
              //                   // )
              //                   // LinearGradient(
              //                   //   begin: Alignment.topLeft,
              //                   //   end: Alignment.bottomRight,
              //                   //   colors: gradientColors,
              //                   // ).createShader(
              //                   //     Rect.fromCircle(
              //                   //       center: Offset(fontSize, -200),
              //                   //       radius: fontSize / 3,
              //                   //     )
              //                   // );
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   );
              // }

              else return SizedBox();
            }
          // ImageCard(
          //   imageData: imageList[index],
          // ),
        ) : ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .07,),
            Center(
              child: Image.asset(
                'assets/png/Saly-15.png',
                height: MediaQuery.of(context).size.height * .4,
                // width: MediaQuery.of(context).size.width * .7,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                // 'Non ci sono ancora notifiche...',
                "Non ci sono preferiti",
                // 'Le mie prestazioni',
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
