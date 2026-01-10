import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
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
import 'package:phone_number/phone_number.dart';


class EditPhoneNumberScreen extends StatefulWidget {
  // final User user;

  @override
  _EditPhoneNumberScreenState createState() => _EditPhoneNumberScreenState();
}

class _EditPhoneNumberScreenState extends State<EditPhoneNumberScreen> {
  TextEditingController phoneNumberController = TextEditingController(text: '');
  int activeIndex = 0;
  bool _isPhoneNumber = true;
  late UserProvider userProvider;

  Future sendSms() async {
    var url = Uri.parse("http://192.168.1.242:8087");
    // //print(this.user.id);

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      "phone": phoneNumberController.text,
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
      // //print("jsonData sms");
      // //print(jsonData);

      // Navigator.pushAndRemoveUntil(
      //   context,
      //   PageTransition(
      //     child: VerifyUpbookingOTPScreen(
      //       authId: jsonData,
      //       user: userProvider.user,
      //       phoneNumber: phoneNumberController.text,
      //       isEmailVerification: false,
      //     ),
      //     // child: OTPEmailVerifyRegistrationScreen(
      //     //   username: user.username,
      //     //   email: user.email,
      //     //   phoneNumber: user.phone_number,
      //     // ),
      //     duration: const Duration(milliseconds: 300),
      //     type: PageTransitionType.fade,
      //   ),
      //   // (route) => route.isFirst
      //   (route) => true
      // );

      return jsonData;
    }
  }

  Future existsPhoneNumber(String phoneNumber) async {
    // //print('coglio');

    setState(() {
      _isPhoneNumber = false;
    });
    // var url = Uri.parse(Utils.httpServerUrl + "user/username");
    var url = Uri.parse("${Utils.httpServerUrl}user/$phoneNumber");
    // User user1;

    Map<String, String> body = {
      // "id": '12',
      "username": phoneNumberController.text,
    };

    Map<String, String> body1 = {
      // "id": '12',
      "username": phoneNumber,
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
            _isPhoneNumber = true;
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

  Future updatePhoneNumber() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/phone_number");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/phone");
    Map<String, dynamic> body = {
      'phone': phoneNumberController.text,
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
      // //print("phone number aggiornato");

      // setState(() {
      //   // user = user1;
      //   userProvider.user.phone_number = phoneNumberController.text;
      // });

      userProvider.updatePhone(phoneNumberController.text);

      Fluttertoast.showToast(
        msg: 'phone number aggiornato a ${phoneNumberController.text}',
        backgroundColor: Colors.grey[700],

      )..then((value) => Navigator.pop(context));

      // //print(postList);
      // //print("post.length: " + postList.length.toString());
      return jsonData;
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.user!.phone != null){
      setState(() {
        phoneNumberController.text = userProvider.user!.phone!;
      });
    }
    else{
      setState(() {
        phoneNumberController.text = '';
      });
    }

  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
    phoneNumberController.dispose();
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
                // SizedBox(height: 20,),

                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 30),
                  child: TextField(
                    // obscureText: !_isVisible,
                    controller: phoneNumberController,
                    keyboardType: TextInputType.name,
                    enabled: true,
                    enableInteractiveSelection: true,
                    // onChanged: (password) => onPasswordChanged(password),
                    onChanged: (phoneNumber) /*=> */ async {

                      RegionInfo region = RegionInfo(
                          name: 'IT',
                          prefix: 3,
                          code: '+39'
                      );

                      // bool isValid = await PhoneNumberUtil().valibooking(
                      //     // '+39 3701315819',
                      //     phoneNumber,
                      //     region.code
                      // );
                      // //print('isValid');
                      // //print(isValid.toString());
                      // PhoneNumber phoneNumber0;
                      try {
                        PhoneNumber phoneNumber0 = await PhoneNumberUtil().parse(
                          // phoneTextController.text,
                            phoneNumber,
                            regionCode: region.code
                        );
                        // //print('phoneNumber');
                        // //print(phoneNumber.toString());
                        // //print('phoneNumber0');
                        // //print(phoneNumber0.toString());
                        // //print(phoneNumber0.type.toString());
                        // //print(phoneNumber0.e164.toString());
                        // //print(phoneNumber0.national.toString());
                        setState(() {
                          _isPhoneNumber = (phoneNumber0.type == PhoneNumberType.MOBILE);
                        });
                        // if(!EmailValidator.valibooking(email)){
                        // if(emailTextController.text.toString().isEmail()){
                        if(_isPhoneNumber == false){
                          existsPhoneNumber(phoneNumber);
                        }
                        else{

                        }
                      } on PlatformException catch (_) {
                        // //print('mela');
                        setState(() {
                          _isPhoneNumber = false;
                        });
                      } on NoSuchMethodError catch(_){
                        // //print('bimbo');
                      }
                    },
                    // onChanged: (phoneNumber) async {
                    //   bool cc = phoneNumberController.text.length < 6;
                    //   if(cc) {
                    //     setState(() {
                    //       _isPhoneNumber = false;
                    //     });
                    //   }
                    //   else{
                    //     await existsPhoneNumber(phoneNumber);
                    //     // setState(() {
                    //     //   _isUsername = true;
                    //     // });
                    //     /*if(_isUsername == false){
                    //       //
                    //       // setState(() {
                    //       //   _isEmail = true;
                    //       // });
                    //       await existsUser(username);
                    //     }
                    //     else{
                    //       // Fluttertoast.showToast(
                    //       //     msg: "Valid Email",
                    //       //     toastLength: Toast.LENGTH_SHORT,
                    //       //     gravity: ToastGravity.TOP,
                    //       //     timeInSecForIosWeb: 1,
                    //       //     fontSize: 16.0
                    //       // );
                    //     }*/
                    //   }
                    //   // existsUser(username);
                    // },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Icon(
                          Icons.phone,
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
                                color: phoneNumberController.text == userProvider.user!.phone ? Colors.transparent
                                    : _isPhoneNumber
                                    ? Colors.green
                                    : Colors.red,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(
                                _isPhoneNumber
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
                      hintText: "Numero di telefono",
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
                            if(_isPhoneNumber){
                              await sendSms();
                              // upbookingPhoneNumber();
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
                                // "Aggiorna Numero di Telefono",
                                // "Modifica Numero di Telefono",
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
                    SizedBox(height: 30,)
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
