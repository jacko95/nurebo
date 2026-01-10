import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/verify_email.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/src/regex_extension.dart';
import 'package:nurebo/main.dart';


class EditEmailScreen extends StatefulWidget {
  // final User? user;

  const EditEmailScreen({super.key, /*this.user*/});

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  TextEditingController emailController = TextEditingController(text: '');
  int activeIndex = 0;
  bool _isEmail = true;
  bool isEmailSent = false;
  late UserProvider userProvider;


  Future sendEmail() async {
    var ipAddr = await getIp();

    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id.toString()}/authentication/send_email");

    Map<String, dynamic> body = {
      "email": emailController.text,
      "user_id": userProvider.user!.id.toString(),
      "business_id": Utils.business_id,
      "ip_address": ipAddr['query'],
      "postal_code": ipAddr['zip'],
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

      // //print("jsonData email");
      // //print(jsonData);

      await Navigator.push(
        context,
        PageTransition(
          child: VerifyEmail(
            authId: jsonData,
            // authId: jsonData['id'],
            user: userProvider.user!,
            isEmailVerification: true,
            email: emailController.text,
          ),
          duration: const Duration(milliseconds: 500),
          type: PageTransitionType.fade,
        ),
      );

      setState(() {
        isEmailSent = false;
      });

      return jsonData;
    }
  }

  Future existsEmail(String email) async {
    // //print('coglio');

    setState(() {
      _isEmail = true;
    });
    var url = Uri.parse(Utils.httpServerUrl + "user/email");
    // User user1;


    Map<String, String> body1 = {
      // "id": '12',
      "email": email,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body1),
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
            _isEmail = false;
          });

          // user1 = new User(
          //   // id: int.parse(userData[0]['id']),
          //   // id: int.parse(userData['id']),
          //   id: userData[0]['id'],
          //   profile_image: userData[0]['profile_image'],
          //   // phone_number: int.parse(userData[0]['phone_number']),
          //   phone_number: userData[0]['phone_number'],
          //   email: userData[0]['email'],
          //   // password: userData[0]['password'],
          //   username: userData[0]['username'],
          //   // city: userData[0]['city'],
          //   description: userData[0]['description'],
          //   first_name: userData[0]['first_name'],
          //   name: userData[0]['name'],
          //   // last_name: userData[0]['last_name'],
          //   // last_login: DateTime.parse(userData[0]['last_login']),
          //   // last_login: userData[0]['last_login'],
          //   // payment_card: int.parse(userData['payment_card']),
          // );

          // setState(() {
          //   // user = user1;
          //   userProvider.user.username = ;
          // });

          // //print(user.id);

          // return user1;
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

  Future updateEmail() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/email");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/email");

    Map<String, dynamic> body = {
      'email': emailController.text,
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
      // setState(() {
        // singleEventPostList = jsonData;
      // });
      // //print("email aggiornata");

      // setState(() {
      //   // user = user1;
      //   userProvider.user.email = emailController.text;
      // });

      userProvider.updateEmail(emailController.text);

      // Fluttertoast.showToast(
      //   msg: 'Email aggiornata a ${emailController.text}',
      //   backgroundColor: Colors.grey[700],
      //
      // )..then((value) => Navigator.pop(context));
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Email aggiornata',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      Navigator.pop(context);
      // //print(postList);
      // //print("post.length: " + postList.length.toString());
      return jsonData;
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.user!.email != null){
      setState(() {
        emailController.text = userProvider.user!.email!;
      });
    }
    else{
      setState(() {
        emailController.text = '';
      });
    }

    // users = UserPreferences.getUsers();
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
    emailController.dispose();
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
                  !isEmailSent ? 'assets/animations/68658-creative-3d-visual-animation-website-development.json' : 'assets/animations/88708-email.json',
                  // controller: animationController,
                  width: 200,
                  height: 200,
                  // repeat: true

                ),
                SizedBox(height: 20,),

                Visibility(
                  visible: isEmailSent,
                    child: Column(
                      children: [
                        Text(
                          'Invio della Email in corso...'
                        ),
                        SizedBox(height: 20,)
                      ],
                    )
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 30),
                  child: TextField(
                    // obscureText: !_isVisible,
                    controller: emailController,
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
                    onChanged: (email) async {
                      // bool cc = emailController.text.length < 6;
                      bool cc = !EmailValidator.validate(email) && !email.isEmail();
                      if(cc) {
                        setState(() {
                          _isEmail = false;
                        });
                      }
                      else{
                        await existsEmail(email);
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
                          Icons.email_outlined,
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
                          padding: const EdgeInsets.only(right: 3, left: 0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 0),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: emailController.text == userProvider.user!.email ? Colors.transparent
                                : _isEmail
                                    ? Colors.green
                                    : Colors.red,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(
                                _isEmail
                                    ? Icons.check
                                    : Icons.clear,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      isDense: false,
                      // suffixIconConstraints: BoxConstraints(
                      //   maxHeight: 20,
                      //   maxWidth: 20
                      // ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      hintText: "Email",
                      enabled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 0, vertical: 20
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Visibility(
                  visible: !isEmailSent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: MaterialButton(
                            onPressed: () async {
                              if(_isEmail && userProvider.user!.email != emailController.text){
                                setState(() {
                                  isEmailSent = true;
                                });
                                await sendEmail();
                                // upbookingEmail();
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
                                  "Invia",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                )
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
