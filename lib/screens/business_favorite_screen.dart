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
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class SavedBusinessScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  final User? user;

  const SavedBusinessScreen({super.key, this.user});

  @override
  _SavedBusinessScreenState createState() => _SavedBusinessScreenState();
}

class _SavedBusinessScreenState extends State<SavedBusinessScreen> {
  // List myPrestazione = [];
  // var results;
  UserProvider? userProvider;
  late BusinessFavoriteProvider businessFavoriteProvider;

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
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);

    // getUserPrestazioneLiked();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);

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
          'Seguiti',
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
        child: businessFavoriteProvider.savedBusinessList!.isNotEmpty ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: 5,
              left: 10,
              right: 10,
              bottom: 10
            ),
            crossAxisCount: 2,
            staggeredTileBuilder: (i) => StaggeredTile.count(1, 1),
            //shrinkWrap: true,
            mainAxisSpacing: 0,
            // physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 0,
            itemCount: businessFavoriteProvider.savedBusinessList!.length,
            itemBuilder: (context, i) {
              Business business = Business(
                  profile_image: businessFavoriteProvider.savedBusinessList![i]['business_profile_image'],
                  id: businessFavoriteProvider.savedBusinessList![i]['business_id'],
                  type_id: 1,
                  room_id: businessFavoriteProvider.savedBusinessList![i]['business_room_id'],
                  longitude: businessFavoriteProvider.savedBusinessList![i]['business_longitude'],
                  latitude: businessFavoriteProvider.savedBusinessList![i]['business_latitude'],
                  name: businessFavoriteProvider.savedBusinessList![i]['business_name'],
                  email: businessFavoriteProvider.savedBusinessList![i]['business_email'],
                  description: businessFavoriteProvider.savedBusinessList![i]['business_description'],
                  address: businessFavoriteProvider.savedBusinessList![i]['business_address'],
                  phone: businessFavoriteProvider.savedBusinessList![i]['business_phone'],
                  max_contemporary_appointments: businessFavoriteProvider.savedBusinessList![i]['max_contemporary_appointments'],
                  category: Category(
                    id: businessFavoriteProvider.savedBusinessList![i]['category_id'],
                    image: businessFavoriteProvider.savedBusinessList![i]['category_image'],
                    name: businessFavoriteProvider.savedBusinessList![i]['category_name'],
                  )
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
                      child: BookingBusinessProfileScreen(
                        business: business,
                        // bookingBusiness: prestazione.business,
                        // user: widget.user,
                      ),
                    )
                  );
                },
                child: Hero(
                  // tag: i,
                  tag: business.profile_image != null && business.profile_image != '' ? business : business,
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
                          business.profile_image != null && business.profile_image != '' ? business.profile_image! : business.profile_image!,
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
                        Positioned(
                          bottom: 16,
                          left: 15,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*Gradient*/Text(
                                business.name ?? '',
                                // 'A partire da € 60,00',
                                maxLines: 6,

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
                                    fontSize: 15
                                ),
                                textAlign: TextAlign.left,
                              ),
                              // Container(
                              //   width: MediaQuery.of(context).size.width * .3,
                              //   child: GradientText(
                              //     business.name ?? '',
                              //     maxLines: 5,
                              //     shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              //     gradient: Gradients.haze,
                              //     style: TextStyle(
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.w800,
                              //         fontSize: 15
                              //     ),
                              //     textAlign: TextAlign.left,
                              //   ),
                              // ),
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
                "Nessun elemento Salvato",
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
