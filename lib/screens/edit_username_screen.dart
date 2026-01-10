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
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'package:nurebo/widgets/drawer.dart';
import 'package:nurebo/main.dart';


class EditUsernameScreen extends StatefulWidget {
  final User? user;

  const EditUsernameScreen({Key? key, this.user});

  @override
  _EditUsernameScreenState createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  TextEditingController usernameController = TextEditingController(text: '');
  int activeIndex = 0;
  bool _isUsername = true;
  late UserProvider userProvider;

  Future existsUsername(String username) async {
    // //print('coglio');

    setState(() {
      _isUsername = true;
    });
    // var url = Uri.parse(Utils.httpServerUrl + "user/username");
    var url = Uri.parse("${Utils.httpServerUrl}user/$username");
    // User user1;

    Map<String, String> body = {
      // "id": '12',
      "username": usernameController.text,
    };

    Map<String, String> body1 = {
      // "id": '12',
      "username": username,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body1),
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
      var userData = json.decode(response.body);

      // //print("jsonData username");
      // //print(userData);
      // //print("userData[0]['id']");
      // //print(userData[0]['id']);
      // //print("userData['id']");
      // //print(userData['id']);
      // setState(() {
      //   _isUsername = false;
      // });
      if(userData != null) {

        if(userData[0]['id'] != null) {
          setState(() {
            // usernameExists = true;
            // _isUsername = true;
            _isUsername = false;
          });

        }
        else{
          // setState(() {
          //   // usernameExists = false;
          //   _isUsername = false;
          // });
        }
      }
      else{
        // setState(() {
        //   // usernameExists = false;
        //   _isUsername = false;
        // });
      }
      return userData;
    }
  }

  Future updateUsername() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/username");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/username");
    // Map<String, dynamic> body = {
    //   'username': usernameController.text,
    //   'id': widget.user.id,
    // };
    Map<String, dynamic> body = {
      'username': usernameController.text,
      'user_id': userProvider.user!.id,
    };

    // var response = await http.put(
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
      // //print("username aggiornato");
      userProvider.updateUsername(usernameController.text);

      // Fluttertoast.showToast(
      //   msg: 'Username aggiornato',
      //   backgroundColor: Colors.grey[800],
      // );
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Username aggiornato',
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
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.user!.username != null){
      setState(() {
        usernameController.text = userProvider.user!.username!;
      });
    }
    else{
      setState(() {
        usernameController.text = '';
      });
    }


    // users = UserPreferences.getUsers();
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
    usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            actions: [
              // IconButton(
              //   onPressed: () async {
              //     await UserPreferences.init();
              //     await UserPreferences.setIsLogged(false);
              //     await UserPreferences.setUser('');
              //
              //     /*Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => UsernameScreen()
              //       ),
              //       (route) => false
              //   );*/
              //     Phoenix.rebirth(context);
              //
              //   },
              //   icon: Icon(
              //     Icons.exit_to_app_rounded,
              //     color: Colors.grey[700],
              //     size: 27,
              //   ),
              //   color: Colors.black,
              // ),
            ],
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
                  'assets/animations/69165-consulting-creative-3d-animation.json',
                  // controller: animationController,
                  width: 200,
                  height: 200,
                  // repeat: true

                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 30),
                  child: TextField(
                    // obscureText: !_isVisible,
                    controller: usernameController,
                    keyboardType: TextInputType.name,
                    enabled: true,
                    enableInteractiveSelection: true,
                    /*onChanged: (_) async {
                      // setState(() async {
                      await existsUser();
                      // });
                      //print(usernameController.text);
                      //print(usernameExists.toString());
                    },*/
                    // onChanged: (password) => onPasswordChanged(password),
                    onChanged: (username) async {
                      // bool cc = usernameController.text.length < 6;
                      // RegExp validationRule = RegExp(r'^[a-zA-Z0-9]+$');
                      RegExp validationRule = RegExp(r'^(?=[a-zA-Z0-9._]{6,20}$)(?!.*[_.]{2})[^_.].*[^_.]$');
                      bool cc = !validationRule.hasMatch(usernameController.text);

                      if(cc) {
                        setState(() {
                          _isUsername = false;
                        });
                      }
                      else{
                        await existsUsername(username);
                        // setState(() {
                        //   _isUsername = true;
                        // });
                        /*if(_isUsername == false){
                          //
                          // setState(() {
                          //   _isEmail = true;
                          // });
                          await existsUser(username);
                        }
                        else{
                          // Fluttertoast.showToast(
                          //     msg: "Valid Email",
                          //     toastLength: Toast.LENGTH_SHORT,
                          //     gravity: ToastGravity.TOP,
                          //     timeInSecForIosWeb: 1,
                          //     fontSize: 16.0
                          // );
                        }*/
                      }
                      // existsUser(username);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.grey[700],
                          size: 21,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // setState(() {
                          //   _isVisible = !_isVisible;
                          // });
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 0),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: usernameController.text == userProvider.user!.username ? Colors.transparent
                                : _isUsername
                                    ? Colors.green
                                    : Colors.red,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(
                                _isUsername
                                    ? Icons.check
                                    : Icons.clear,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
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
                      hintText: "Username",
                      enabled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                            if(_isUsername){
                              // await sendEmail();
                              updateUsername();
                            }
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
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
