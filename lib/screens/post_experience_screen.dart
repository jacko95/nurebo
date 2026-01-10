import 'dart:convert';
import 'dart:io';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:kadingira/models/date.dart';
// import 'package:kadingira/models/experience.dart';
// import 'package:kadingira/models/business.dart';
// import 'package:kadingira/models/prestazione.dart';
// import 'package:kadingira/models/single_event.dart';
// import 'package:kadingira/models/user.dart';
// import 'package:kadingira/provider/user_provider.dart';
// import 'package:kadingira/utils/utils.dart';
// import 'package:kadingira/widgets/account.dart';
// import 'package:kadingira/widgets/account_selector.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/selector/account.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../widgets/selector/account_selector.dart';


class PostExperienceScreen extends StatefulWidget {

  @override
  _PostExperienceScreenState createState() => _PostExperienceScreenState();
}

class _PostExperienceScreenState extends State<PostExperienceScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _imageList = [];
  CarouselSliderController carouselController = CarouselSliderController();
  String resultText = "";
  int selectedId = -1;
  late UserProvider userProvider;
  List allEntities = [];
  List<Account> accountList = [];
  TextEditingController _descriptionController = TextEditingController();
  double _rating = 3.5;


  Future getAllPrestazione() async {
    var url = Uri.parse(Utils.httpServerUrl + "date/user/prestazione");

    Map/*<String, String>*/ body = {
      'user_id': userProvider.user!.id,
    };

    var response = await http.post(
    // var response = await http.get(
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

    //print("getAllPrestazione response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      setState(() {
        // results = jsonData;
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('allEntities.toString()');
      // //print(allEntities.toString());
      //print(jsonData);
      return jsonData;
    }
  }

  Future getAllEvent() async {
    var url = Uri.parse(Utils.httpServerUrl + "single_event_reservation/user/single_event");

    Map/*<String, String>*/ body = {
      'user_id': userProvider.user!.id,
    };

    var response = await http.post(
    // var response = await http.get(
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

    //print("getAllEvent response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      setState(() {
        allEntities.addAll(jsonData);
        // allEntities.shuffle();
      });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchEvent allEntities.toString()');
      // //print(allEntities.toString());
      //print(jsonData);
      return jsonData;
    }
  }

  Future insertExperienceImage(XFile _image, String? experienceId, bool isDateExperience) async {
    String imageName = _image.path.split('/').last;
    // List<int> imageBytes = File(filePath.path).readAsBytesSync();

    var request = http.MultipartRequest(
        'POST',
        !isDateExperience
          ? Uri.parse(Utils.httpServerUrl + "single_event_post/insert")
          : Uri.parse(Utils.httpServerUrl + "date_post/insert")
    );

    String imageMimeType = lookupMimeType(_image.path)!;
    //print('imageMimeType');
    //print(imageMimeType);

    request.files.add(
        await http.MultipartFile.fromPath(
            'image',
            // imageFilePath,
            _image.path,
            filename: '${imageName.split('image_picker').last}',
            // contentType: new MediaType('image', 'jpeg')
            // contentType: new MediaType('image', 'png')
            contentType: MediaType(
                imageMimeType.split('/').first,
                imageMimeType.split('/').last
            )
        )
    );
    // request.files.add(
    //   http.MultipartFile.fromBytes(
    //     'image',
    //     _imageFile.readAsBytesSync(),
    //     filename: '$imageName',
    //     // contentType: new MediaType('image', 'jpeg')
    //     contentType: new MediaType('image', 'png')
    //     // contentType: new MediaType('image', 'jpg')
    //   )
    // );

    // http.MultipartFile.fromString(
    //   'image',
    //   _imageFile.path,
    //   filename: '$imageName',
    // );

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip, deflate',
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip, deflate';
    // request.fields['file'] = name;
    if(isDateExperience){
      request.fields['date_experience_id'] = experienceId!;
    }
    else{
      request.fields['single_event_experience_id'] = experienceId!;
    }

    var res = await request.send();
    return res.statusCode;
  }

  Future insertSingleEventExperience() async {
    var url = Uri.parse(Utils.httpServerUrl + "single_event_experience/insert");

    Map/*<String, String>*/ body = {
      'user_id': userProvider.user!.id,
      'single_event_reservation_id': allEntities[selectedId]['single_event_reservation_id'],
      'description': _descriptionController.text,
    };

    var response = await http.post(
      // var response = await http.get(
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

    //print("insertEventExperience response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print(jsonData);
      for(var e in _imageList){
        insertExperienceImage(
          e,
          jsonData['id'],
          false
        );
      }
      Fluttertoast.showToast(
        msg: 'Esperienza creata con successo',
        backgroundColor: Colors.grey[700],
      )..then((value) => Navigator.pop(context));

      return jsonData;
    }
  }

  Future insertDateExperience() async {
    var url = Uri.parse(Utils.httpServerUrl + "date_experience/insert");

    Map/*<String, String>*/ body = {
      'user_id': userProvider.user!.id,
      'date_id': allEntities[selectedId]['date_id'],
      'description': _descriptionController.text,
    };

    var response = await http.post(
      // var response = await http.get(
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

    //print("insertDateExperience response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print(jsonData);
      for(var e in _imageList){
        insertExperienceImage(
          e,
          jsonData['id'],
          true
        );
      }
      Fluttertoast.showToast(
        msg: 'Esperienza creata con successo',
        backgroundColor: Colors.grey[700],
      )..then((value) => Navigator.pop(context));
      return jsonData;
    }
  }

  void selectImage() async {
    final XFile selected = (await _imagePicker.pickImage(source: ImageSource.gallery))!;
    if (selected.path.isEmpty) {
      //print(selected.path.toString());
      _imageList.add(selected);
    }
    setState(() {
      // _image = File(pickedImage.path);
      _imageList.add(selected);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    Future.wait([
      getAllPrestazione(),
      getAllEvent()
    ]).then((value) {
      allEntities.sort((b, a) {
        return a['begin_at'].compareTo(b['begin_at']);
      });
      //print('allEntities.length\n' + allEntities.length.toString());
      accountList = List.generate(
        allEntities.length,
        (index){
          return Account(
            title: allEntities[index]['title'],
            subtitle: allEntities[index]['business_name'],
            datetime: DateFormat.yMMMMd('it_IT').format(DateTime.parse(allEntities[index]['begin_at'])).toString()
            + ' alle ' + DateTime.parse(allEntities[index]['begin_at']).toString().substring(11, 16),
            accountImageWidget: FutureImage(
              allEntities[index]['image'],
              width: MediaQuery.of(context).size.width,
            )
          );
        }
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,
      backgroundColor: Colors.grey[50],
      // backgroundColor: Color.fromRGBO(247, 251, 254, 1),
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        // leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            // color: Colors.blue,
            color: Colors.grey[500],
            size: 25,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        // backgroundColor: Colors.white,
        backgroundColor: Colors.grey[50],
        // backgroundColor: Color.fromRGBO(247, 251, 254, 1),
        // title: Text(
        //   'Crea Esperienza',
        //   style: TextStyle(
        //       color: Colors.blue,
        //   ),
        // ),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            // shrinkWrap: true,
            children: [
              SizedBox(height: 10,),
              _imageList.length == 0 ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: selectImage,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              // Icons.image_outlined,
                              Icons.add_photo_alternate_outlined,
                              color: Colors.grey[400],
                              size: 60,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Aggiungi l'immagine\ndella tua esperienza",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[500],
                                // color: Colors.blue[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ) : CarouselSlider(
                carouselController: carouselController,
                items: List.generate(
                  _imageList.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image.file(
                          File(
                            _imageList[index].path,
                          ),
                          fit: BoxFit.cover,
                          // width: 200,
                          width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.height * 0.8,
                          // height: 150,
                        ),
                      ),
                    );
                  }
                ),
                options: CarouselOptions(
                    autoPlay: true,
                    height: MediaQuery.of(context).size.height * 0.32,
                    enlargeCenterPage: true,
                    // aspectRatio: 16/9,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      // setState(() {
                      //   _current = index;
                      // });
                    }
                )
              ),
              // SizedBox(height: 10,),
              // Container(
              //   height: 80,
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     shrinkWrap: true,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(
              //             left: 10,
              //             right: 0,
              //             top: 2,
              //             bottom: 2
              //         ),
              //         child: MaterialButton(
              //           // color: Colors.blue,
              //           color: Colors.white,
              //           elevation: 1,
              //           // height: 60,
              //           // minWidth: MediaQuery.of(context).size.width * 0.9,
              //           minWidth: 80,
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(8))
              //           ),
              //           clipBehavior: Clip.antiAliasWithSaveLayer,
              //           child: Icon(
              //             // Icons.add,
              //             Icons.add_photo_alternate_outlined,
              //             // color: Colors.grey[500],
              //             color: Colors.blue[500],
              //             // color: Colors.white,
              //             size: 35,
              //           ),
              //           onPressed: () {
              //             selectImage();
              //           },
              //           // child: Text("Select Image"),
              //         ),
              //       ),
              //       Container(
              //         // height: 60,
              //         // width: MediaQuery.of(context).size.width,
              //         child: ListView.builder(
              //           // padding: EdgeInsets.all(15),
              //           padding: const EdgeInsets.symmetric(horizontal: 6),
              //           shrinkWrap: true,
              //           scrollDirection: Axis.horizontal,
              //           physics: NeverScrollableScrollPhysics(),
              //           // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //           //   crossAxisCount: 2,
              //           //   childAspectRatio: /*1.66*/16/9,
              //           //   mainAxisSpacing: 20,
              //           //   // crossAxisSpacing: 20,
              //           //   crossAxisSpacing: 5,
              //           // ),
              //           itemBuilder: (BuildContext context, int i) {
              //             return Stack(
              //                 fit: StackFit.passthrough,
              //                 children: [
              //                   InkWell(
              //                     onTap: (){
              //                       carouselController.jumpToPage(i);
              //                     },
              //                     child: Card(
              //                       elevation: 2,
              //                       shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.all(Radius.circular(8))
              //                       ),
              //                       clipBehavior: Clip.antiAliasWithSaveLayer,
              //                       child: Image.file(
              //                         File(_imageList[i].path),
              //                         fit: BoxFit.cover,
              //                         width: 80,
              //                         // height: 150,
              //                       ),
              //                     ),
              //                   ),
              //                   Positioned(
              //                     top: 10,
              //                     right: 10,
              //                     child: Container(
              //                       height: 33,
              //                       width: 33,
              //                       // height: MediaQuery.of(context).size.width * 0.06,
              //                       // width: MediaQuery.of(context).size.width * 0.37,
              //                       decoration: BoxDecoration(
              //                         color: Colors.black.withOpacity(0.45),
              //                         borderRadius: BorderRadius.circular(5),
              //                       ),
              //                       child: IconButton(
              //                           onPressed: () {
              //                             setState(() {
              //                               _imageList.removeAt(i);
              //                             });
              //                           },
              //                           icon: Icon(
              //                             Icons.delete,
              //                             // color: Colors.grey[300],
              //                             // color: Colors.blue[500],
              //                             color: Colors.white,
              //                             size: 18,
              //                           )
              //                       ),
              //                     ),
              //                   ),
              //                   // Positioned(
              //                   //   top: 0,
              //                   //   right: 0,
              //                   //   child: IconButton(
              //                   //       onPressed: () {
              //                   //         _imageList.removeAt(i);
              //                   //         setState(() {}
              //                   //         );
              //                   //       },
              //                   //       icon: Icon(
              //                   //         Icons.delete,
              //                   //         // color: Colors.grey[300],
              //                   //         color: Colors.blue[500],
              //                   //         size: 25,
              //                   //       )
              //                   //     ),
              //                   //   )
              //                 ]
              //             );
              //           },
              //           itemCount: _imageList.length,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                  padding: EdgeInsets.only(
                    top: 25.0,
                    bottom: 10,
                    right: 60,
                    left: 60
                  ),
                  child: InkWell(
                    onTap: (){
                      showAccountSelectorSheet(
                        context: context,
                        accountList: accountList,
                        isSheetDismissible: true, //Optional
                        // initiallySelectedIndex: 2, //Optional
                        initiallySelectedIndex: selectedId, //Optional
                        hideSheetOnItemTap: false, //Optional
                        // addAccountTitle: "Add User", //Optional
                        // showAddAccountOption: true, //Optional
                        // backgroundColor: Colors.blue[700], //Optional
                        backgroundColor: Colors.white, //Optional
                        // arrowColor: Colors.white, //Optional
                        arrowColor: Colors.grey, //Optional
                        // unselectedRadioColor: Colors.white, //Optional
                        unselectedRadioColor: Colors.grey, //Optional
                        // selectedRadioColor: Colors.amber, //Optional
                        selectedRadioColor: Colors.blue, //Optional
                        // unselectedTextColor: Colors.white, //Optional
                        unselectedTextColor: Colors.grey[900], //Optional
                        // selectedTextColor: Colors.amber, //Optional
                        unselectedSubtitleColor: Colors.grey[500],
                        unselectedDatetimeColor: Colors.grey[700],
                        selectedTextColor: Colors.blue, //Optional
                        //Optional
                        tapCallback: (index) {
                          setState(() {
                            resultText =
                            "selected account is : ${accountList[index].title}";
                            selectedId = index;
                          });
                          //print(resultText);
                        },
                        //Optional
                        addAccountTapCallback: () {
                          setState(() {
                            resultText = "Add account clicked";
                          });
                          //print(resultText);
                        },
                      );
                    },
                    child: selectedId == -1 ? Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 2,
                      child: Container(
                        width: double.infinity,
                        // width: 200,
                        height: 80,
                        decoration: BoxDecoration(
                          // color: Colors.blue.shade50.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              // Iconsax.folder_open,
                              Icons.storefront,
                              // color: Colors.blue,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              'Seleziona la tua esperienza',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                // color: Colors.blue[500],
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        // width: double.infinity,
                        // width: 200,
                        height: 80,
                        decoration: BoxDecoration(
                          // color: Colors.blue.shade50.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: allEntities[selectedId]['image'],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Marquee(
                                    child: Row(
                                      children: [
                                        GradientText(
                                          allEntities[selectedId]['title'],
                                          style: GoogleFonts.roboto(
                                            // color: Colors.white,
                                            // color: Colors.grey[800],
                                            // color: Colors.blue[500],
                                              letterSpacing: 0,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800
                                          ),
                                          gradient: allEntities[selectedId]['is_date_business'] == 1 ? LinearGradient(
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                              colors: [
                                                Color(0xff8921aa),
                                                // Color(0xffDA44bb),
                                                Colors.pink
                                              ]
                                          ) :
                                          // Gradients.cosmicFusion,
                                          // Gradients.rainbowBlue,
                                          Gradients.backToFuture,
                                          // textAlign: TextAlign.start,
                                          // maxLines: 1,
                                          //softWrap: true,
                                          // overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    // textAlign: TextAlign.start,
                                    maxLines: 2,
                                    //softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: allEntities[selectedId]['business_name'],
                                      style: GoogleFonts.roboto(
                                        // color: Colors.white,
                                          color: Colors.grey[600],
                                          letterSpacing: 0,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 1.5,),
                                  Marquee(
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat.yMMMMd('it_IT').format(DateTime.parse(allEntities[selectedId]['begin_at'])).toString()
                                              + ' alle ' + DateTime.parse(allEntities[selectedId]['begin_at']).toString().substring(11, 16),
                                          style: GoogleFonts.roboto(
                                            color: Colors.green,
                                            letterSpacing: 0,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 15,
                  top: 15,
                  bottom: 0
                ),
                // child: Text(
                //   // 'Descrizione:',
                //   'Racconta la tua esperienza:',
                //   style: TextStyle(
                //       fontSize: 15.0,
                //       color: Colors.grey[600],
                //       // color: Colors.blue[500],
                //       fontWeight: FontWeight.w600,
                //   ),
                // ),
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      unratedColor: Colors.amber.withAlpha(50),
                      itemCount: 5,
                      glow: false,
                      itemSize: 50.0,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        // Icons.storefront_rounded,
                        color: Colors.amber,
                        // color: Colors.pinkAccent,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                      updateOnDrag: true,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Voto: $_rating',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          // color: Colors.grey[700],
                          color: Colors.blue[500],
                          // fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(right: 15, left: 15, top: 10),
                child: Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  semanticContainer: true,
                  child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        color: Colors.white,
                        child: TextField(
                          controller: _descriptionController,
                          autofocus: false,
                          expands: true,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey[700],
                            // color: Colors.blue[500],
                            fontWeight: FontWeight.w500
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: "Raccontaci la tua esperienza...",
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          maxLines: null,
                        ),
                      )
                  ),
                ),
              ),
              SizedBox(
                // height: MediaQuery.of(context).size.height * 0.37,
                height: 10,
              ),
              Container(
                // height: 150,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // shrinkWrap: true,
                  // scrollDirection: Axis.vertical,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //     left: 15,
                    //     right: 15,
                    //     top: 15,
                    //     bottom: 15
                    //   ),
                    //   child: MaterialButton(
                    //     // color: Colors.blue,
                    //     color: Colors.white,
                    //     elevation: 5,
                    //     height: 70,
                    //     minWidth: MediaQuery.of(context).size.width * 0.9,
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(8))
                    //     ),
                    //     clipBehavior: Clip.antiAliasWithSaveLayer,
                    //     child: Icon(
                    //       Icons.add,
                    //       // color: Colors.grey[500],
                    //       color: Colors.blue[500],
                    //       // color: Colors.white,
                    //       size: 35,
                    //     ),
                    //     onPressed: () {
                    //       selectImage();
                    //     },
                    //     // child: Text("Select Image"),
                    //   ),
                    // ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 25),
                        child: MaterialButton(
                          onPressed: () async {
                            if(allEntities[selectedId]['date_id'] != null){
                              insertDateExperience();
                            }
                            else if(allEntities[selectedId]['single_event_reservation_id'] != null){
                              insertSingleEventExperience();
                            }
                            // else print('there is sommething wrong');
                          },
                          height: 45,
                          // elevation: 0,
                          elevation: 2,
                          minWidth: MediaQuery.of(context).size.width * 0.9,
                          color: Colors.blue[500],
                          child: Text(
                            // "Carica",
                            "Anteprima",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            // borderRadius: BorderRadius.circular(20.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   height: 70,
                    //   width: MediaQuery.of(context).size.width * 0.9,
                    //   child: Card(
                    //     elevation: 2,
                    //     // color: Colors.white,
                    //     color: Colors.blue,
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(8))
                    //     ),
                    //     clipBehavior: Clip.antiAliasWithSaveLayer,
                    //     child: Icon(
                    //       Icons.add,
                    //       // color: Colors.grey[500],
                    //       color: Colors.white,
                    //       size: 30,
                    //     )
                    //   ),
                    // ),
                  ],
                ),
              )
            ]
          ),
        ),
      ),
    );
  }

}
