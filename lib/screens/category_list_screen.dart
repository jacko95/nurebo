import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/category.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/post_favorite_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/business_category_list_screen.dart';
import 'package:nurebo/screens/event_screen.dart';
import 'package:nurebo/screens/post_full_screen.dart';
import 'package:nurebo/screens/prestazione_slots_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/app_bar.dart';
import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class CategoryListScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  // final User? user;

  const CategoryListScreen({super.key});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List categoryList = [];
  Future a = Future(() {});
  late UserProvider userProvider;
  // late PostFavoriteProvider postFavoriteProvider;
  late SocketProvider socketProvider;
  final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();


  Future/*<List<Uint8List>>*/ getAllCategories() async {
    var url = Uri.parse("${Utils.httpServerUrl}category/business?is_valid=1&is_visible=1");

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
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData3');
      // print(jsonData);

      // categoryList = jsonData;
      categoryList.addAll(jsonData);

      // for (int i = 0; i < categoryList.length; i++) {
      //   // await getImage(categoryList[i]['image']);
      //   await getImageWithRetry(categoryList[i]['image']);
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

    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    userProvider = Provider.of<UserProvider>(context, listen: false);
    // postFavoriteProvider = Provider.of<PostFavoriteProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    Future.wait([
      a = getAllCategories(),
    ]);

    // getUserPrestazioneLiked();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    // postFavoriteProvider = Provider.of<PostFavoriteProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   titleSpacing: 0,
      //   // leadingWidth: 40,
      //   // leading: IconButton(
      //   //   icon: Icon(
      //   //     // Icons.arrow_back,
      //   //     Icons.arrow_back_ios_new,
      //   //     // size: 22,
      //   //     size: 16,
      //   //     color: Colors.grey[500],
      //   //   ),
      //   //   onPressed: (){
      //   //     Navigator.pop(context);
      //   //   },
      //   // ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   elevation: 0,
      //   // title: Text(
      //   //   // 'Salvati',
      //   //   'Piaciuti',
      //   //   // 'Le mie prestazioni',
      //   //   style: TextStyle(
      //   //       color: Colors.blue,
      //   //       // color: Colors.grey[800],
      //   //       fontWeight: FontWeight.w600,
      //   //       fontSize: 15
      //   //   ),
      //   // ),
      // ),
      appBar: PreferredSize(
        // preferredSize: Size.fromHeight(100),
        preferredSize: Size.fromHeight(55),
        // child: AppBar2(user: widget.user,),
        child: NureboAppBar(
          // user: userProvider.user,
          // user: widget.user,
        ),
      ),
      // drawer: NureboDrawer(),
      // onDrawerChanged: (value){
      //   // if(Utils.isSocial || Utils.isBusiness){
      //     //todo: false per nascondere bottombar
      //     //print(value);
      //     socketProvider.setBottomBarVisibility(!value);
      //   // }
      // },
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .01),
            FutureBuilder(
              // future: Future.wait([a]),
              future: a,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.66
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                        // shrinkWrap: true,
                        padding: EdgeInsets.only(
                            top: 5,
                            left: 10,
                            right: 10,
                            bottom: 10
                        ),
                        itemCount: categoryList.length,
                        itemBuilder: (context, i) {
                          Category category = Category(
                            // id: categoryList[i]['id'].toInt(),
                            id: categoryList[i]['id'],
                            image: categoryList[i]['image'],
                            name: categoryList[i]['name'],
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
                                        FutureImage(
                                          category.image!,
                                          width: MediaQuery.of(context).size.width,
                                          // height: MediaQuery.of(context).size.height * 0.25,
                                        ),
                                        // Image.memory(
                                        //   // category.image!,
                                        //   imageCacheBusiness.imageCache[category.image!] ?? Uint8List(0),
                                        //   // categoryListImages[indice],
                                        //   // width: MediaQuery.of(context).size.width,
                                        //   // height: MediaQuery.of(context).size.height * 0.25,
                                        //   fit: BoxFit.cover,
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
                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                      child: Text(
                                                        // categories[i].name,
                                                        category.name!,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white,
                                                          // fontSize: 15,
                                                          fontSize: 18,
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
                    ),
                  );
                }
                else {
                  return SizedBox();
                }

              }
            ),
          ],
        ),
      ),

    );
  }
}
