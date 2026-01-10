import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo/main.dart';


class EditDescriptionScreen extends StatefulWidget {
  // final User user;

  const EditDescriptionScreen({super.key/*, this.user*/});

  @override
  _EditDescriptionScreenState createState() => _EditDescriptionScreenState();
}

class _EditDescriptionScreenState extends State<EditDescriptionScreen> {
  TextEditingController descriptionController = TextEditingController(text: '');
  late UserProvider userProvider;


  Future updateDescription() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/description");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/description");

    Map<String, dynamic> body = {
      'description': descriptionController.text,
      'user_id': userProvider.user!.id,
    };

    var response = await http.patch(
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

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print("description aggiornata");

      userProvider.updateDescription(descriptionController.text);

      // Fluttertoast.showToast(
      //   msg: 'Descrizione aggiornata',
      //   backgroundColor: Colors.grey[800],
      // )/*..then((value) => Navigator.pop(context))..then((value) => Phoenix.rebirth(context))*/;
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Descrizione aggiornata',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);

      Navigator.pop(context);
      return jsonData;
    }
  }

  @override
  void initState() {
    // timer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   setState(() {
    //     activeIndex++;
    //     if(activeIndex == 4)
    //       activeIndex = 0;
    //   });
    // });
    super.initState();

    userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.user!.description != null){
      setState(() {
        descriptionController.text = userProvider.user!.description!;
      });
    }
    else{
      setState(() {
        descriptionController.text = '';
      });
    }


    // users = UserPreferences.getUsers();
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            // title: Text(
            //     "Impostazioni",
            //     style: GoogleFonts.roboto(
            //       color: Colors.blue,
            //       //color: Color.fromRGBO(245, 93, 62, 1),
            //       // background:
            //       // letterSpacing: -3,
            //       // fontSize: 40,
            //       fontWeight: FontWeight.w800,
            //     )
            // ),
            centerTitle: true,
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
            actions: [],
            // backgroundColor: Colors.grey[900],
          ),
        ),
        body: Container(
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
                SizedBox(height: 20,),
                Lottie.asset(
                  'assets/animations/68978-3d-hand.json',
                  // controller: animationController,
                  width: 200,
                  height: 200,
                  // repeat: true
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 40),
                  child: TextField(
                    // obscureText: !_isVisible,
                    controller: descriptionController,
                    keyboardType: TextInputType.name,
                    enabled: true,
                    maxLines: 10,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Icon(
                          Icons.wysiwyg,
                          color: Colors.grey[700],
                          size: 21,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      hintText: "",
                      enabled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: MaterialButton(
                          onPressed: () async {
                            // if(_isUsername){
                            //   // await sendEmail();
                            //   upbookingDescription();
                            // }
                            await updateDescription();
                          },
                          // minWidth: MediaQuery.of(context).size.width * 0.6,
                          elevation: 0,
                          color: Colors.blue[500],
                          padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          // elevation: 0,
                          // padding: EdgeInsets.all(18),
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(20)
                          // ),
                          child: Center(
                              child: Text(
                                "Salva",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    // Center(
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width * 0.75,
                    //     child: MaterialButton(
                    //       onPressed: () async {
                    //         Navigator.pushAndRemoveUntil(
                    //             context,
                    //             PageTransition(
                    //               child: RegisterScreen1(),
                    //               duration: const Duration(milliseconds: 1),
                    //               type: PageTransitionType.fade,
                    //             ),
                    //                 (route) => false
                    //         );
                    //       },
                    //       // minWidth: MediaQuery.of(context).size.width * 0.6,
                    //       elevation: 0,
                    //       color: Colors.grey[500],
                    //       // color: Colors.lightBlue[200],
                    //       // color: Colors.purple[300],
                    //       padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(20)
                    //       ),
                    //       // elevation: 0,
                    //       // padding: EdgeInsets.all(18),
                    //       // shape: RoundedRectangleBorder(
                    //       //     borderRadius: BorderRadius.circular(20)
                    //       // ),
                    //       child: Center(
                    //           child: Text(
                    //             "Registrati",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.white
                    //             ),
                    //           )
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
