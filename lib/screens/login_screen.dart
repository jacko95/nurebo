import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/register_screen.dart';
import 'package:nurebo/screens/login_otp_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart' as regexx;
import 'package:url_launcher/url_launcher.dart';
import 'package:nurebo/main.dart';


class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController usernameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  late User user;
  bool _isEmail = true;
  UserProvider? userProvider;
  late SocketProvider socketProvider;
  double? width;
  late double height;
  DateTime? currentBackPressTime;
  bool loginClick = false;


  // Future getIpLocation(String? ip) async {
  //   var url = Uri.parse("http://ip-api.com/json/$ip");
  //
  //   var response = await http.get(
  //       url,
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // //print("response.statusCode");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   // tickets = jsonData;
  //     //   for(var i = 0; i < jsonData.length; i++){
  //     //     // tickets.add(jsonData[i]['id']);
  //     //     tickets.add(jsonData[i]);
  //     //   }
  //     // });
  //     // //print("tickets: ");
  //     // //print(tickets);
  //     // //print("post.length: " + postList.length.toString());
  //     return jsonData;
  //   }
  // }
  //
  // Future getIp() async {
  //   var url = Uri.parse("https://api.ipify.org?format=json");
  //
  //   var response = await http.get(
  //       url,
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // //print("response.statusCode");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     var ipLocation = await getIpLocation(jsonData['ip']);
  //     // //print('ip location:');
  //     // //print(ipLocation);
  //     // return jsonData;
  //     return ipLocation;
  //   }
  // }

  Future sendEmail() async {
    var ipAddr = await getIp();
    // //print('ipAddr');
    // //print(ipAddr['zip']);

    // var url = Uri.parse("${Utils.httpServerUrl}authentication/send_email");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id.toString()}/authentication/send_email");

    Map<String, dynamic> body = {
      "email": user.email,
      "user_id": user.id.toString(),
      "business_id": Utils.business_id,
      "ip_address": ipAddr['query'],
      "postal_code": ipAddr['zip'],
    };
    // Map<String, dynamic> body = {
    //   "email": user.email,
    //   "user_id": userProvider.user.id,
    // };

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

      // if(Utils.isBusiness){
      //   Navigator.push(
      //     context,
      //     PageTransition(
      //       duration: const Duration(milliseconds: 500),
      //       alignment: Alignment.center,
      //       type: PageTransitionType.fade,
      //       child: LoginOtpScreen(
      //         authId: jsonData,
      //         // authId: jsonData['id'],
      //         user: user,
      //         isEmailVerification: true,
      //       ),
      //     ),
      //   );
      // }
      // else {
        await Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: LoginOtpScreen(
                authId: jsonData,
                // authId: jsonData['id'],
                user: user,
                isEmailVerification: true,
              ),
              duration: const Duration(milliseconds: 500),
              type: PageTransitionType.fade,
            ),
                (route) => false
        );
      // }

      return jsonData;
    }
    else if(response.statusCode == 429){
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Troppi tentativi di accesso. Riprova più tardi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
    else {
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Errore del server. Riprova più tardi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      setState(() {
        loginClick = false;
      });
    }
  }

  // Future verifyUser() async {
  //   var url = Uri.parse("${Utils.httpServerUrl}authentication/email");
  //
  //   Map<String, String> body = {
  //     // "id": '12',
  //     "email": emailController.text,
  //   };
  //
  //   var response = await http.post(
  //     url,
  //     body: jsonEncode(body),
  //     headers: {
  //       'Accept': '*/*',
  //       'Content-Type': 'application/json',
  //       'Accept-encoding': 'gzip, deflate',
  //       'connection': 'keep-alive',
  //       'X-App-Version-Name': Utils.version_name,
  //       'X-App-Version-Number': Utils.version_id.toString(),
  //       'X-Client-Type': 'User-Mobile-App',
  //     }
  //   );
  //
  //   // //print("response.statusCode:");
  //   // //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var userData = json.decode(response.body);
  //
  //     // //print("jsonData email");
  //     // //print(userData);
  //     // Map data = Map.from(userData);
  //     User user = User(
  //       // id: int.parse(userData[0]['id']),
  //       // id: int.parse(userData['id']),
  //       id: userData[0]['id'],
  //       profile_image: userData[0]['profile_image'],
  //       // phone_number: int.parse(userData[0]['phone_number']),
  //       // phone_number: int.parse(userData[0]['phone_number']),
  //       phone_number: userData[0]['phone_number'],
  //       email: userData[0]['email'],
  //       email_notification: userData[0]['email_notification'],
  //       password: userData[0]['password'],
  //       username: userData[0]['username'],
  //       description: userData[0]['description'],
  //       first_name: userData[0]['first_name'],
  //       last_name: userData[0]['last_name'],
  //       name: userData[0]['name'],
  //     );
  //
  //     // Provider.of<UserProvider>(context).user = user;
  //     // //print('UserProvider:');
  //     // //print(Provider.of<UserProvider>(context).user.toJson());
  //
  //
  //     // Navigator.push(
  //     //     context,
  //     //     PageTransition(
  //     //       duration: const Duration(milliseconds: 500),
  //     //       alignment: Alignment.center,
  //     //       type: PageTransitionType.fade,
  //     //       // child: NotificationScreen(),
  //     //       child: SendOTPScreen(
  //     //         // username: userData[0]['username'],
  //     //         // userId: userData[0]['id'],
  //     //         user: user,
  //     //       ),
  //     //     )
  //     // );
  //
  //     return userData;
  //   }
  // }

  Future existsEmail(String email) async {
    // //print('coglio');

    // setState(() {
    //   // _isUsername = false;
    //   _isEmail = false;
    // });

    var url = Uri.parse(Utils.httpServerUrl + "user/email");
    // User user1;

    // Map<String, String> body = {
    //   // "id": '12',
    //   "username": usernameController.text,
    // };

    // //print(email);
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

    if(response.statusCode == 454) {
      Fluttertoast.showToast(
        msg: 'Utente non registrato',
        backgroundColor: Colors.grey[900],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var userData = json.decode(response.body);

      // //print("jsonData username");
      // //print(userData);
      // //print("userData[0]['id']");
      // //print(userData[0]['id']);
      // //print("userData[0]['email']");
      // //print(userData[0]['email']);
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
            _isEmail = true;
          });

          User user1 = User(
            // id: int.parse(userData[0]['id']),
            // id: int.parse(userData['id']),
            id: userData[0]['id'],
            profile_image: userData[0]['profile_image'],
            // phone_number: int.parse(userData[0]['phone_number']),
            phone: userData[0]['phone'],
            email: userData[0]['email'],
            email_notification: userData[0]['email_notification'],
            // password: userData[0]['password'],
            username: userData[0]['username'],
            // city: userData[0]['city'],
            description: userData[0]['description'],
            first_name: userData[0]['first_name'],
            name: userData[0]['name'],
            latitude: userData[0]['latitude']?.toDouble(),
            longitude: userData[0]['longitude']?.toDouble(),
            // last_name: userData[0]['last_name'],
            // last_login: DateTime.parse(userData[0]['last_login']),
            // last_login: userData[0]['last_login'],
            // payment_card: int.parse(userData['payment_card']),
          );

          setState(() {
            user = user1;
            // userProvider.user.username = ;
          });

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
      // return userData;
      return _isEmail;
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Premere due volte per uscire', );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    Future.delayed(const Duration(microseconds: 0), () => {
      socketProvider.setBottomBarVisibility(false)
    });

    // setState(() {
    //   usernameExists = false;
    // });
    // users = UserPreferences.getUsers();
  }

  @override
  void dispose() {
    super.dispose();

    // usernameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // //print('height');
    // //print(height);
    // //print('width');
    // //print(width);

    return WillPopScope(
      onWillPop: userProvider!.goBackToMain,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,

        // appBar: AppBar(
        //   titleSpacing: 0,
        //   // backgroundColor: Colors.grey[50],
        //   elevation: 0,
        //   backgroundColor: Colors.transparent, // Trasparenza dell'app bar
        //   // leadingWidth: 40,
        //   leading: Visibility(
        //     visible: !loginClick,
        //     child: InkWell(
        //       highlightColor: Colors.transparent,
        //       splashColor: Colors.transparent,
        //       child: Padding(
        //         padding: const EdgeInsets.only(left: 10.0, top: 10),
        //         child: Icon(
        //           Icons.arrow_back,
        //           // Icons.arrow_back_ios_new,
        //           size: 30,
        //           // size: 16,
        //           color: Colors.grey[500],
        //         ),
        //       ),
        //       onTap: userProvider!.goBackToMain,
        //     ),
        //   ),
        // ),
        body: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // image: AssetImage('assets/images/bg_image.png'),
                  image: NetworkImage(
                    // 'https://images.pexels.com/photos/8448563/pexels-photo-8448563.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                    'https://images.pexels.com/photos/4153618/pexels-photo-4153618.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF111122).withOpacity(0.8), Color(0xFF111122)],
                ),
              ),
            ),
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // padding: const EdgeInsets.only(
                          //   left: 0,
                          //   right: 0,
                          //   top: 0
                          // ),
                          // shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     Visibility(
                            //       visible: !loginClick,
                            //       child: Container(
                            //         margin: EdgeInsets.only(top: 12, bottom: 17, left: 15),
                            //         child: OutlinedButton(
                            //           // style: ButtonStyle(
                            //           //   padding: EdgeInsets.all(0),
                            //           // ),
                            //             style: OutlinedButton.styleFrom(
                            //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            //
                            //               // backgroundColor: Colors.grey[50],
                            //               backgroundColor: Colors.white,
                            //               // minimumSize: Size(50, 30),
                            //               alignment: Alignment.center,
                            //             ),
                            //             onPressed: () async {
                            //               if(Utils.isSocial || Utils.isBusiness){
                            //                 //todo: false per nascondere bottombar
                            //                 socketProvider.setBottomBarVisibility(true);
                            //               }
                            //
                            //               if(!Utils.isBusiness){
                            //                 await Navigator.pushAndRemoveUntil(
                            //                     context,
                            //                     PageTransition(
                            //                       child: const HomeScreen(),
                            //                       type: PageTransitionType.fade,
                            //                       duration: const Duration(milliseconds: 500),
                            //                     ),
                            //                         (route) => false
                            //                 );
                            //               }
                            //               else {
                            //                 await Navigator.pushAndRemoveUntil(
                            //                     context,
                            //                     PageTransition(
                            //                       child: Main(user: userProvider!.user),
                            //                       type: PageTransitionType.fade,
                            //                       duration: const Duration(milliseconds: 500),
                            //                     ),
                            //                         (route) => false
                            //                 );
                            //               }
                            //
                            //               // Navigator.pop(context);
                            //             },
                            //             child: Row(
                            //               children: [
                            //                 Icon(
                            //                   Icons.arrow_back_outlined,
                            //                   color: Colors.grey[600],
                            //                   size: 23,
                            //                 ),
                            //                 // SizedBox(width: 8),
                            //                 // Text(
                            //                 //   // 'Non Disponibile',
                            //                 //   'Ritorna alla Home',
                            //                 //   style: TextStyle(
                            //                 //     // color: Colors.blue[500],
                            //                 //     color: Colors.grey[700],
                            //                 //     // color: Colors.red[700],
                            //                 //     fontWeight: FontWeight.w700,
                            //                 //     fontSize: 12,
                            //                 //   ),
                            //                 // ),
                            //               ],
                            //             )
                            //         ),
                            //       ),
                            //     ),
                            //     // InkWell(
                            //     //   highlightColor: Colors.transparent,
                            //     //   splashColor: Colors.transparent,
                            //     //   onTap: () async {
                            //     //     await Navigator.pushAndRemoveUntil(
                            //     //         context,
                            //     //         PageTransition(
                            //     //           child: const HomeScreen(),
                            //     //           type: PageTransitionType.fade,
                            //     //           duration: const Duration(milliseconds: 500),
                            //     //         ),
                            //     //         (route) => false
                            //     //     );
                            //     //   },
                            //     //   child: Padding(
                            //     //     padding: const EdgeInsets.all(20),
                            //     //     child: Icon(
                            //     //       Icons.home_outlined,
                            //     //       size: 30,
                            //     //       // color: Colors.grey[700],
                            //     //       color: Colors.blue[500],
                            //     //     ),
                            //     //   ),
                            //     // ),
                            //   ],
                            // ),
                            // SizedBox(height: 15),

                            RichText(
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    // color: Colors.white,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Bentornato da\n',
                                        // text: exhibitions[i].tipo,
                                        style: TextStyle(
                                            // fontWeight: FontWeight.w700,
                                            // fontSize: 16,
                                            // color: Colors.blue
                                            fontSize: MediaQuery.of(context).size.width * 0.05,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[50],
                                        )
                                    ),
                                    TextSpan(
                                      // text: 'kalixira',
                                      // text: 'nurebo',
                                      text: 'nurebo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        // color: Colors.blue[500],
                                        color: Colors.orange[600],
                                        fontFamily: 'Panton',
                                        letterSpacing: -4,
                                        fontSize: MediaQuery.of(context).size.width * 0.15,
                                      )
                                    ),
                                  ]
                              ),
                            ),
                            SizedBox(height: 20,),

                            height > 700 ? Visibility(
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.27,
                                // child: Lottie.asset(
                                //   loginClick == false ? 'assets/animations/48594-digital-media-3d.json' : 'assets/animations/88708-email.json',
                                //   // controller: animationController,
                                //   // width: 200,
                                //   // height: 200,
                                //   // repeat: true
                                //
                                // ),
                              ),
                            ) : Container(height: MediaQuery.of(context).size.height * 0.07,),

                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.09,
                                  right: MediaQuery.of(context).size.width * 0.09,
                                  top: 30
                              ),
                              child: TextFormField(
                                // cursorColor: Colors.white,
                                // onChanged: (email) => existsEmail(email),
                                onChanged: (email) /*=>*/ async {
                                  setState(() {
                                    _isEmail = EmailValidator.validate(email) && email.isEmail();
                                  });
                                  // if(!EmailValidator.valibooking(email)){
                                  // if(emailTextController.text.toString().isEmail()){
                                  if(_isEmail == false){
                                    // //print('porcodio');
                                    //
                                    // setState(() {
                                    //   _isEmail = true;
                                    // });
                                    // await existsEmail(email);
                                  }
                                  else{
                                    // Fluttertoast.showToast(
                                    //     msg: "Valid Email",
                                    //     toastLength: Toast.LENGTH_SHORT,
                                    //     gravity: ToastGravity.TOP,
                                    //     timeInSecForIosWeb: 1,
                                    //     fontSize: 16.0
                                    // );
                                  }
                                },
                                controller: emailController,
                                autofillHints: const [AutofillHints.email],
                                // validator: (email) => email != null && !EmailValidator.valibooking(email)
                                //     ? 'Enter a valid email'
                                //     : null,
                                keyboardType: TextInputType.emailAddress,
                                // enabled: true,
                                enabled: !loginClick ? true : false,
                                enableInteractiveSelection: true,
                                /*onChanged: (_) async {
                                  // setState(() async {
                                  await existsUser();
                                  // });
                                  //print(usernameController.text);
                                  //print(usernameExists.toString());
                                },*/
                                // onChanged: (password) => onPasswordChanged(password),

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  // border: InputBorder.none,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Icon(
                                      Icons.mail_outlined,
                                      color: Colors.grey[700],
                                      size: 21,
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 0),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: emailController.text == '' ? Colors.transparent :
                                          _isEmail ? Colors.green : Colors.red,
/*                                          border: !_isEmail
                                                ? Border.all(color: Colors.transparent)
                                                : Border.all(color: Colors.grey.shade400),*/
                                          border: Border.all(color: Colors.transparent),
                                          // border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: Center(
                                        child: Icon(
                                          !_isEmail ? Icons.clear : Icons.check,
                                          color: emailController.text.isNotEmpty ? Colors.white : Colors.transparent,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.black)
                                  ),
                                  hintText: "Email",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                                ),
                              ),
                            ),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //
                            //   children: <Widget>[
                            //     Text(
                            //         // 'Hello',
                            //         'Kad',
                            //         softWrap: true,
                            //         style: TextStyle(
                            //             fontSize: 80.0, fontWeight: FontWeight.bold,
                            //           // height: 0
                            //           wordSpacing: 0
                            //         )
                            //     ),
                            //     Row(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       mainAxisAlignment: MainAxisAlignment.start,
                            //
                            //       children: [
                            //         Text(
                            //           // 'There',
                            //             'ingira',
                            //             softWrap: true,
                            //
                            //             style: TextStyle(
                            //                 fontSize: 80.0,
                            //                 fontWeight: FontWeight.bold,
                            //                 wordSpacing: 0,
                            //               height: 0.75
                            //             )
                            //         ),
                            //         Text(
                            //             '.',
                            //             softWrap: true,
                            //
                            //             style: TextStyle(
                            //                 fontSize: 80.0,
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.green,
                            //                 wordSpacing: 0,
                            //               height: 0.75
                            //             )
                            //         )
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            // TextField(
                            //   controller: usernameController,
                            //   keyboardType: TextInputType.name,
                            //   enabled: true,
                            //   enableInteractiveSelection: true,
                            //   onChanged: (_) async {
                            //     // setState(() async {
                            //       await existsUser();
                            //     // });
                            //     // await existsUser();
                            //     //print(usernameController.text);
                            //     //print(usernameExists.toString());
                            //   },
                            // ),
                            // Center(
                            //   child: ElevatedButton(
                            //     onPressed: () async {
                            //       await verifyUser();
                            //
                            //       // await sendSms();
                            //       // Navigator.push(
                            //       //   context,
                            //       //   MaterialPageRoute(builder: (context) => AuthScreen())
                            //       // );
                            //     },
                            //     // color: Colors.redAccent,
                            //     child: Text('Accedi'),
                            //   ),
                            // ),
                            // Container(
                            //   width: MediaQuery.of(context).size.width * .7,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: ElevatedButton(
                            //       style: ButtonStyle(
                            //         backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[500]),
                            //         // foregroundColor: Colors.grey,
                            //       ),
                            //       onPressed: (){
                            //         Navigator.pushAndRemoveUntil(
                            //           context,
                            //           MaterialPageRoute(
                            //               // builder: (context) => RegisterScreen(),
                            //               builder: (context) => RegisterScreen1(),
                            //           ),
                            //           (route) => false
                            //         );
                            //         // debug//print("CLicckk");
                            //       },
                            //       child: Text(
                            //         "Iscriviti",
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 30,
                            ),
                            Visibility(
                              visible: loginClick == false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height * 0.075,
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: MaterialButton(
                                        onPressed: () async {
                                          // if(_isUsername && usernameController.text != ''){
                                          if(_isEmail && emailController.text != ''){
                                            if((await existsEmail(emailController.text)) == true){
                                              setState(() {
                                                loginClick = true;
                                              });
                                              await sendEmail();
                                            }
                                          }
                                          else{
                                            Fluttertoast.showToast(
                                              // msg: 'Email aggiornata a ${widget.user.email}',
                                              msg: 'Email non valida',
                                              backgroundColor: Colors.grey[700],
                                              // )..then((value) => Navigator.pop(context));
                                            )/*.then((value) => */;
                                          }
                                        },
                                        // minWidth: MediaQuery.of(context).size.width * 0.6,
                                        elevation: 0,
                                        // color: Colors.blue[500],
                                        color: Colors.orange[600],
                                        padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        // elevation: 0,
                                        // padding: EdgeInsets.all(18),
                                        // shape: RoundedRectangleBorder(
                                        //     borderRadius: BorderRadius.circular(20)
                                        // ),
                                        child: Center(
                                            child: Text(
                                              // "Accedi tramite Email",
                                              "Login tramite Email",
                                              // "Login",
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
                                    height: 15,
                                  ),
                                  // Center(
                                  //   child: Container(
                                  //     width: MediaQuery.of(context).size.width * 0.75,
                                  //     child: MaterialButton(
                                  //       onPressed: () async {
                                  //         // await verifyUser();
                                  //         // if(_isUsername && usernameController.text != ''){
                                  //         if(_isEmail && emailController.text != ''){
                                  //           await sendSms();
                                  //         }
                                  //         else{
                                  //           Fluttertoast.showToast(
                                  //             // msg: 'Email aggiornata a ${widget.user.email}',
                                  //             msg: 'Username non valido',
                                  //             backgroundColor: Colors.grey[700],
                                  //             // )..then((value) => Navigator.pop(context));
                                  //           )/*.then((value) => */;
                                  //         }
                                  //       },
                                  //       // minWidth: MediaQuery.of(context).size.width * 0.6,
                                  //       elevation: 0,
                                  //       color: Colors.blue[500],
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
                                  //             "Accedi tramite SMS",
                                  //             style: TextStyle(
                                  //                 fontWeight: FontWeight.bold,
                                  //                 color: Colors.white
                                  //             ),
                                  //           )
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: 15,
                                  // ),
                                  Visibility(
                                    visible: !Utils.isBusiness,
                                    child: Center(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        // child: MaterialButton(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                PageTransition(
                                                  // child: RegisterScreen1(),
                                                  child: RegisterScreen(),
                                                  duration: const Duration(milliseconds: 500),
                                                  type: PageTransitionType.fade,
                                                ),
                                                    (route) => false
                                            );
                                          },
                                          style: ButtonStyle(
                                            // backgroundColor: MaterialStateProperty.all(Colors.grey[500]),
                                            backgroundColor: MaterialStateProperty.all(Colors.white),
                                            // side: MaterialStateProperty.all(BorderSide(width: 1.5, color: Colors.blue[400]!)),
                                            // foregroundColor: MaterialStateProperty.all(Colors.blue),
                                            // color: Colors.lightBlue[200],
                                            // color: Colors.purple[300],
                                            padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50, 18, 50, 18)),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                )
                                            ),
                                          ),
                                          // // minWidth: MediaQuery.of(context).size.width * 0.6,
                                          // elevation: 0,
                                          // color: Colors.grey[500],
                                          // // color: Colors.lightBlue[200],
                                          // // color: Colors.purple[300],
                                          // padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                                          // shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(10),
                                          // ),
                                          child: Center(
                                              child: Text(
                                                "Registrati",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    // color: Colors.white
                                                    // color: Colors.blue[500]
                                                    color: Colors.orange[600]
                                                ),
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(height: 30,),
                                  SizedBox(
                                    height: height > 700
                                      ? MediaQuery.of(context).size.height * 0.055
                                      : MediaQuery.of(context).size.height * 0.065,
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     Text(
                                  //       'Non hai un account?',
                                  //       style: TextStyle(
                                  //         color: Colors.grey.shade600,
                                  //         fontSize: 14.0, fontWeight:
                                  //         FontWeight.w400
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: 5,),
                                  //     InkWell(
                                  //       onTap: (){
                                  //         Navigator.pushAndRemoveUntil(
                                  //           context,
                                  //           PageTransition(
                                  //             child: RegisterScreen1(),
                                  //             duration: const Duration(milliseconds: 1),
                                  //             type: PageTransitionType.fade,
                                  //
                                  //           ),
                                  //           (route) => false
                                  //         );
                                  //       },
                                  //       highlightColor: Colors.transparent,
                                  //       splashColor: Colors.transparent,
                                  //       child: Padding(
                                  //         padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  //         child: Text(
                                  //           'Registrati',
                                  //           style: TextStyle(
                                  //               color: Colors.blue,
                                  //               fontSize: 14.0,
                                  //               fontWeight: FontWeight.w500
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     )
                                  //   ],
                                  // ),

                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     Text(
                                  //       // "Non ti ricordi l'username?",
                                  //       // "Non ti ricordi l'email del tuo account?",
                                  //       "Non ti ricordi la tua E-mail?",
                                  //       style: TextStyle(
                                  //           color: Colors.grey.shade600,
                                  //           fontSize: 14.0,
                                  //           fontWeight: FontWeight.w400
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: 5,),
                                  //     InkWell(
                                  //       onTap: () async {
                                  //         const url = 'mailto:support@nurebo.com?subject=&body=';
                                  //         final Uri parsedUrl = Uri.parse(url);
                                  //         if (!await launchUrl(parsedUrl)) {
                                  //           throw 'Could not launch $parsedUrl';
                                  //         }
                                  //       },
                                  //       highlightColor: Colors.transparent,
                                  //       splashColor: Colors.transparent,
                                  //       child: Padding(
                                  //         padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  //         child: Text(
                                  //           // 'Clicca qui',
                                  //           'Contattaci',
                                  //           style: TextStyle(
                                  //               color: Colors.blue,
                                  //               fontSize: 14.0,
                                  //               fontWeight: FontWeight.w500
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     )
                                  //   ],
                                  // ),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                  )
                                ],
                              ),
                            ),
                            /*usernameExists == true ? Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // await verifyUser();
                                    await sendEmail();
                                  },
                                  // color: Colors.redAccent,
                                  child: Text('Accedi tramite Email'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await sendSms();
                                    // await verifyUser();
                                  },
                                  // color: Colors.redAccent,
                                  child: Text('Accedi tramite SMS'),
                                ),
                              ],
                            )
                                : Text("")*/
                            // SizedBox(height: 30,),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: loginClick,
                    child: SizedBox(height: MediaQuery.of(context).size.height * 0.275,)
                  )
                ],
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              // height: 50,
              // width: 50,
              child: GestureDetector(
                // highlightColor: Colors.transparent,
                // splashColor: Colors.transparent,
                // onTap: (){userProvider!.goBackToMain();},
                onTap:userProvider!.goBackToMain,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                  child: Center(
                    child: Icon(
                      // Icons.star_rounded,
                      // Icons.star_half_rounded,
                      // Icons.star_border_rounded,
                      Icons.arrow_back_outlined,
                      // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                      // color: _theme,
                      color: Colors.grey[700],
                      // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                      size: 23.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
