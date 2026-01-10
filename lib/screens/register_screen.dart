import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/register_otp_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:url_launcher/url_launcher.dart';


class RegisterScreen extends StatefulWidget {

  const RegisterScreen({ super.key });

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // TextEditingController name = TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  // TextEditingController nameTextController = TextEditingController();
  // TextEditingController phone = TextEditingController(text: "+39 ");
  // TextEditingController phoneTextController = TextEditingController(text: "+39 ");
  TextEditingController emailTextController = TextEditingController();
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  Timer? timer;
  bool _isUsername = true;
  // bool _isName = true;
  bool _isEmail = true;
  bool _isName = true;
  bool _isFirstName = true;
  bool _isLastName = true;
  DateTime? currentBackPressTime;
  double? width;
  late double height;
  bool registerClick = false;
  late SocketProvider socketProvider;
  late UserProvider userProvider;


  Future existsUsername(String username) async {
    // //print('coglio');

    setState(() {
      _isUsername = false;
    });
    // var url = Uri.parse(Utils.httpServerUrl + "user/username");
    var url = Uri.parse("${Utils.httpServerUrl}user/$username");
    // User user1;

    Map<String, String> body = {
      // "id": '12',
      "username": usernameTextController.text,
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
            _isUsername = true;
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

  Future existsEmail(String email) async {
    // //print('brutta');

    setState(() {
      _isEmail = false;
    });
    var url = Uri.parse(Utils.httpServerUrl + "user/email");
    User user1;

    // Map<String, String> body = {
    //   // "id": '12',
    //   "username": username.text,
    // };

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
        if(userData[0]['id'] != null /*&& EmailValidator.valibooking(email)*/) {
          // if(!EmailValidator.valibooking(email)){
            setState(() {
              // usernameExists = true;
              _isEmail = true;
            });
          // }

          // FocusScope.of(context).unfocus(); //chiude la keyboard, ma anche altro
          user1 = User(
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
            // last_name: userData[0]['last_name'],
            // last_login: DateTime.parse(userData[0]['last_login']),
            // last_login: userData[0]['last_login'],
            // payment_card: int.parse(userData['payment_card']),
          );

          // setState(() {
          //   user = user1;
          // });
          //
          // //print(user.id);

          return user1;
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

  Future register() async {
    var url = Uri.parse(Utils.httpServerUrl + "user/register");

    Map<String, String> body = {
      // "name": name.text,
      "username": usernameTextController.text,
      "email": emailTextController.text,
      // "phone_number": "+39 ${phoneTextController.text}"
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

    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400){
      var userData = json.decode(response.body)/*.toString()*/;
      //print(userData.toString());
      //print("Utente registrato!");
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginScreen(),
            duration: const Duration(milliseconds: 800),
            type: PageTransitionType.fade,

          ),
          (route) => false
      );
      // var userDataToStr = userData.toString();
      // if(userData.toString()/*userDataToStr*/ == "Errore"){
      //   showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         // key: _formKey,
      //         actions: [
      //           ElevatedButton(
      //             style: ButtonStyle(
      //               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      //               backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      //             ),
      //             onPressed: (){
      //               Navigator.pop(context);
      //             },
      //             child: Text("Cancel"),
      //           ),
      //         ],
      //         content: Text(
      //           "Utente già registrato",
      //         ),
      //         title: Text(
      //           "Message",
      //         ),
      //       )
      //   );
      // }
      // else{
      //   // if(userData['status'].toString() == "Admin"){
      //   //   // Navigator.push(
      //   //   //   context,
      //   //   //   MaterialPageRoute(
      //   //   //       builder: (context) => Dashboard(
      //   //   //
      //   //   //       )
      //   //   //   ),
      //   //   // );
      //   // }
      //   // else{
      //   //   // Navigator.push(
      //   //   //   context,
      //   //   //   MaterialPageRoute(
      //   //   //       builder: (context) => MyHomePage(
      //   //   //         name: userData['name'].toString(),
      //   //   //         email: userData['username'].toString(),
      //   //   //
      //   //   //       )
      //   //   //   ),
      //   //   // );
      //   // }
      //   showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         // key: _formKey,
      //         actions: [
      //           ElevatedButton(
      //             style: ButtonStyle(
      //               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      //               backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
      //             ),
      //             onPressed: (){
      //               Navigator.pop(context);
      //             },
      //             child: Text("Cancel"),
      //           ),
      //         ],
      //         content: Text(
      //           "Utente registrato con successo",
      //         ),
      //         title: Text(
      //           "Message",
      //         ),
      //       )
      //   );
      //   debug//print(userData.toString());
      // }
    }
  }

  // Future sendEmail() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "validation_email/send_email");
  //   var url = Uri.parse(Utils.httpServerUrl + "user/register/send_email");
  //
  //   Map<String, dynamic> body = {
  //     "email": emailTextController.text,
  //     "username": usernameTextController.text,
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
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // //print('jsonData sendemail');
  //     // //print(jsonData);
  //
  //     if(jsonData['id'].length == 36){
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           PageTransition(
  //             child: EmailRegistrationScreen(
  //               username: usernameTextController.text,
  //               email: emailTextController.text,
  //               // name: nameTextController.text,
  //               authId: jsonData['id'],
  //               // phoneNumber: phoneTextController.text,
  //             ),
  //             duration: const Duration(milliseconds: 1),
  //             type: PageTransitionType.fade,
  //           ),
  //           (route) => false
  //       );
  //     }
  //
  //     return jsonData;
  //   }
  // }
  Future sendEmail() async {
    var ipAddr = await getIp();
    // //print('ipAddr');
    // //print(ipAddr['zip']);

    var url = Uri.parse("${Utils.httpServerUrl}user/register/send_email");

    Map<String, dynamic> body = {
      "email": emailTextController.text,
      "username": usernameTextController.text,
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //print('jsonData dv545454544bbbb');
      //print(jsonData);

      if(jsonData['id'].length == 36){
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: RegisterOtpScreen(
                username: usernameTextController.text,
                email: emailTextController.text,
                name: nameTextController.text,
                authId: jsonData['id'],
                // phoneNumber: phoneTextController.text,
              ),
              duration: const Duration(milliseconds: 1),
              type: PageTransitionType.fade,
            ),
                (route) => false
        );
      }

      return jsonData;
    }
    else{
      return response.statusCode;
    }
  }

  // Future verifyEmail() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "validation_email/send_email");
  //
  //   //print('babu');
  //
  //   Map<String, dynamic> body = {
  //     "username": usernameTextController.text,
  //     "phone_number": phoneTextController.text,
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
  //   //print("response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   chatMessageList = jsonData;
  //     // });
  //
  //     await sendEmail();
  //
  //     //print("jsonData sms");
  //     //print(jsonData);
  //
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: OTPSMSVerifyRegistrationScreen(
  //             username: usernameTextController.text,
  //             email: emailTextController.text,
  //             phoneNumber: phoneTextController.text,
  //           ),
  //           duration: const Duration(milliseconds: 1),
  //           type: PageTransitionType.fade,
  //         ),
  //             (route) => false
  //     );
  //
  //     return jsonData;
  //   }
  // }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Premere due volte per uscire',
        backgroundColor: Colors.grey[700]
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  // Future<bool> goBackToMain() async {
  //   if(Utils.isSocial || Utils.isBusiness){
  //     //todo: false per nascondere bottombar
  //     socketProvider.setBottomBarVisibility(true);
  //   }
  //
  //   if(!Utils.isBusiness){
  //     await Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: const HomeScreen(),
  //           type: PageTransitionType.fade,
  //           duration: const Duration(milliseconds: 500),
  //         ),
  //             (route) => false
  //     );
  //   }
  //   else {
  //     await Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: Main(/*user: userProvider!.user*/),
  //           type: PageTransitionType.fade,
  //           duration: const Duration(milliseconds: 500),
  //         ),
  //             (route) => false
  //     );
  //   }
  //
  //   // Navigator.pop(context);
  //   return true;
  // }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    Future.delayed(const Duration(microseconds: 0), () => {
      socketProvider.setBottomBarVisibility(false)
    });
  }

  @override
  void dispose() {
    // timer.cancel();
    usernameTextController.dispose();
    // nameTextController.dispose();
    emailTextController.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    nameTextController.dispose();
    // phoneTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: userProvider.goBackToMain,
      child: Scaffold(
        // appBar: AppBar(
        //   titleSpacing: 0,
        //   backgroundColor: Colors.grey[50],
        //   elevation: 0,
        //   // leadingWidth: 40,
        //   leading: Visibility(
        //     visible: !registerClick,
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
        //       onTap: userProvider.goBackToMain,
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
                    'https://images.pexels.com/photos/3993461/pexels-photo-3993461.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                      // 'https://images.pexels.com/photos/4153618/pexels-photo-4153618.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: 20,),
                  // SizedBox(height: 20,),
                  // InkWell(
                  //   onTap: (){
                  //     Navigator.pop(context);
                  //   },
                  //   child: Container(
                  //     // width: 150,
                  //     // height: 100,
                  //     // color: Colors.grey[500],
                  //     padding: EdgeInsets.all(15),
                  //     decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         // color: Colors.white
                  //         color: Colors.grey[500],
                  //     ),
                  //     child: Icon(
                  //       // Icons.star_rounded,
                  //       // Icons.star_half_rounded,
                  //       // Icons.star_border_rounded,
                  //       Icons.clear,
                  //       // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                  //       // color: _theme,
                  //       // color: Colors.grey[700],
                  //       color: Colors.white,
                  //       // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                  //       size: 23.5,
                  //     )
                  //   ),
                  // ),
                  Expanded(
                    child: ListView(
                      // reverse: true,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () async {
                                // await Navigator.pushAndRemoveUntil(
                                //     context,
                                //     PageTransition(
                                //       child: LoginScreen(),
                                //       type: PageTransitionType.fade,
                                //       duration: Duration(milliseconds: 500),
                                //     ),
                                //         (route) => false
                                // );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                // child: Icon(
                                //   Icons.arrow_back_outlined,
                                //   size: 30,
                                //   color: Colors.grey[500],
                                //   // color: Colors.blue[500],
                                // ),
                                child: SizedBox(height: 30),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.08,),
                        Center(
                          child: RichText(
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
                                      text: 'Benvenuto su\n',
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
                                    //   text: 'nurebo',
                                      text: 'nurebo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        // color: Colors.blue[500],
                                        color: Colors.orange[600],
                                        fontFamily: 'Panton',
                                        letterSpacing: -3,
                                        fontSize: MediaQuery.of(context).size.width * 0.15,
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),

                        height > 700 ? Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.17,
                            // child: Lottie.asset(
                            //   // 'assets/animations/95698-phone-25fps.json',
                            //   registerClick == false ? 'assets/animations/46809-web-develop-d.json' : 'assets/animations/88708-email.json',
                            //   // controller: animationController,
                            //   width: registerClick == false ? 200 : 500,
                            //   height: registerClick == false ? 200 : 500,
                            //   // repeat: true
                            // ),
                          ),
                        ) : Center(child: Container(height: MediaQuery.of(context).size.height * 0.07,)),

                        Visibility(
                          visible: registerClick == false,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.09,
                                    right: MediaQuery.of(context).size.width * 0.09,
                                    top: 30
                                ),
                                child: TextFormField(
                                  // onChanged: (email) => existsEmail(email),
                                  onChanged: (email) /*=>*/ async {
                                    setState(() {
                                      _isEmail = !EmailValidator.validate(email) && !email.isEmail();
                                    });
                                    // if(!EmailValidator.valibooking(email)){
                                    // if(emailTextController.text.toString().isEmail()){
                                    if(_isEmail == false){
                                      // //print('porcodio');
                                      //
                                      // setState(() {
                                      //   _isEmail = true;
                                      // });
                                      dynamic errr23 = await existsEmail(email);
                                      // print(errr23);
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
                                  controller: emailTextController,
                                  autofillHints: [AutofillHints.email],
                                  // validator: (email) => email != null && !EmailValidator.valibooking(email)
                                  //     ? 'Enter a valid email'
                                  //     : null,
                                  keyboardType: TextInputType.emailAddress,
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

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
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
                                            color: emailTextController.text == '' ? Colors.transparent :
                                            _isEmail
                                                ? Colors.red
                                                : Colors.green,
                                            /* border: !_isEmail
                                              ? Border.all(color: Colors.transparent)
                                              : Border.all(color: Colors.grey.shade400),*/
                                            border: Border.all(color: Colors.transparent),
                                            // border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Center(
                                          child: Icon(
                                            !_isEmail ? Icons.check : Icons.clear,
                                            color: emailTextController.text.isNotEmpty ? Colors.white : Colors.transparent,                                              size: 15,
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
                                    hintText: "Email",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                                  ),
                                ),
                              ),
                            //   Padding(
                            //     padding: EdgeInsets.only(
                            //         left: MediaQuery.of(context).size.width * 0.09,
                            //         right: MediaQuery.of(context).size.width * 0.09,
                            //         top: 20
                            //     ),
                            //     child: TextField(
                            //       controller: usernameTextController,
                            //       keyboardType: TextInputType.name,
                            //       enabled: true,
                            //       enableInteractiveSelection: true,
                            //       /*onChanged: (_) async {
                            //         // setState(() async {
                            //         await existsUser();
                            //         // });
                            //         //print(usernameController.text);
                            //         //print(usernameExists.toString());
                            //       },*/
                            //       // onChanged: (username) => isUsernameInDB(username),
                            //       onChanged: (username) async {
                            //         // bool cc = usernameController.text.length < 6;
                            //         // RegExp validationRule = RegExp(r'^[a-zA-Z0-9]+$');
                            //         RegExp validationRule = RegExp(r'^(?=[a-zA-Z0-9._]{6,20}$)(?!.*[_.]{2})[^_.].*[^_.]$');
                            //         bool cc = !validationRule.hasMatch(usernameTextController.text);
                            //
                            //         if(cc) {
                            //           setState(() {
                            //             _isUsername = true;
                            //           });
                            //         }
                            //         else{
                            //           await existsUsername(username);
                            //           // setState(() {
                            //           //   _isUsername = true;
                            //           // });
                            //           /*if(_isUsername == false){
                            //   //
                            //   // setState(() {
                            //   //   _isEmail = true;
                            //   // });
                            //   await existsUser(username);
                            // }
                            // else{
                            //   // Fluttertoast.showToast(
                            //   //     msg: "Valid Email",
                            //   //     toastLength: Toast.LENGTH_SHORT,
                            //   //     gravity: ToastGravity.TOP,
                            //   //     timeInSecForIosWeb: 1,
                            //   //     fontSize: 16.0
                            //   // );
                            // }*/
                            //         }
                            //         // existsUser(username);
                            //       },
                            //       autofillHints: [AutofillHints.username],
                            //       decoration: InputDecoration(
                            //         filled: true,
                            //         fillColor: Colors.white,
                            //         prefixIcon: Padding(
                            //           padding: const EdgeInsets.only(bottom: 3.0),
                            //           child: Icon(
                            //             // Icons.person_outline,
                            //             Icons.account_circle_outlined,
                            //             color: Colors.grey[700],
                            //             size: 21,
                            //           ),
                            //         ),
                            //         suffixIcon: Padding(
                            //           padding: const EdgeInsets.all(15.0),
                            //           child: AnimatedContainer(
                            //             duration: Duration(milliseconds: 0),
                            //             width: 20,
                            //             height: 20,
                            //             decoration: BoxDecoration(
                            //                 color: usernameTextController.text == '' ? Colors.transparent :
                            //                 !_isUsername
                            //                     ? Colors.green
                            //                     : Colors.red,
                            //                 border: Border.all(color: Colors.transparent),
                            //                 // border: Border.all(color: Colors.grey.shade400),
                            //                 borderRadius: BorderRadius.circular(50)
                            //             ),
                            //             child: Center(
                            //               child: Icon(
                            //                 !_isUsername ? Icons.check : Icons.clear,
                            //                 color: usernameTextController.text.isNotEmpty ? Colors.white : Colors.transparent,
                            //                 size: 15,
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(10),
                            //             borderSide: BorderSide(color: Colors.black)
                            //         ),
                            //         focusedBorder: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(10),
                            //             borderSide: BorderSide(color: Colors.black)
                            //         ),
                            //         hintText: "Username",
                            //         contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                            //       ),
                            //     ),
                            //   ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.09,
                                    right: MediaQuery.of(context).size.width * 0.09,
                                    top: 20
                                ),
                                child: TextField(
                                  controller: nameTextController,
                                  keyboardType: TextInputType.name,
                                  enabled: true,
                                  enableInteractiveSelection: true,
                                  onChanged: (name) async {
                                    RegExp validationRule = RegExp(r'^(?=[a-zA-Z ]{6,40}$)(?!.* {2})[a-zA-Z][a-zA-Z ]*[a-zA-Z]$');
                                    bool cc = !validationRule.hasMatch(nameTextController.text);

                                    // print('cc');
                                    // print(cc);

                                    if(cc == true) {
                                      setState(() {
                                        _isName = true;
                                      });
                                    }
                                    else{
                                      setState(() {
                                        _isName = false;
                                      });
                                    }
                                  },
                                  autofillHints: [AutofillHints.name],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 3.0),
                                      child: Icon(
                                        // Icons.person_outline,
                                        Icons.account_circle_outlined,
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
                                            color: nameTextController.text == ''
                                              ? Colors.transparent
                                              : !_isName ? Colors.green : Colors.red,
                                            border: Border.all(color: Colors.transparent),
                                            // border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Center(
                                          child: Icon(
                                            !_isName ? Icons.check : Icons.clear,
                                            color: nameTextController.text.isNotEmpty ? Colors.white : Colors.transparent,
                                            size: 15,
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
                                    hintText: "Nome e Cognome",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                        //   child: TextField(
                        //     controller: nameTextController,
                        //     keyboardType: TextInputType.name,
                        //     enabled: true,
                        //     enableInteractiveSelection: true,
                        //     /*onChanged: (_) async {
                        //     // setState(() async {
                        //     await existsUser();
                        //     // });
                        //     //print(usernameController.text);
                        //     //print(usernameExists.toString());
                        //   },*/
                        //     // onChanged: (username) => isUsernameInDB(username),
                        //     onChanged: (username) async {
                        //       bool cc = nameTextController.text.length < 6;
                        //
                        //       if(cc) {
                        //         setState(() {
                        //           _isName = true;
                        //         });
                        //       }
                        //       else{
                        //         setState(() {
                        //           _isName = false;
                        //         });
                        //       }
                        //       // existsUser(username);
                        //     },
                        //     autofillHints: [AutofillHints.username],
                        //     decoration: InputDecoration(
                        //       prefixIcon: Padding(
                        //         padding: const EdgeInsets.only(bottom: 3.0),
                        //         child: Icon(
                        //           Icons.person_outline,
                        //           color: Colors.grey[700],
                        //           size: 21,
                        //         ),
                        //       ),
                        //       suffixIcon: Padding(
                        //         padding: const EdgeInsets.all(15.0),
                        //         child: AnimatedContainer(
                        //           duration: Duration(milliseconds: 0),
                        //           width: 20,
                        //           height: 20,
                        //           decoration: BoxDecoration(
                        //               color: nameTextController.text == '' ? Colors.transparent :
                        //                 !_isName
                        //                   ? Colors.green
                        //                   : Colors.red,
                        //               border: Border.all(color: Colors.transparent),
                        //               // border: Border.all(color: Colors.grey.shade400),
                        //               borderRadius: BorderRadius.circular(50)
                        //           ),
                        //           child: Center(
                        //             child: Icon(
                        //               !_isName ? Icons.check : Icons.clear,
                        //               color: Colors.white,
                        //               size: 15,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           borderSide: BorderSide(color: Colors.black)
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           borderSide: BorderSide(color: Colors.black)
                        //       ),
                        //       hintText: "Nome",
                        //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        //     ),
                        //   ),
                        // ),

                        Visibility(
                          visible: !registerClick,
                          child: Column(
                            children: [
                              SizedBox(height: 25,),
                              Center(
                                child: MaterialButton(
                                  onPressed: () async {
                                    // register();
                                    if(/*!_isPhoneNumber && */!_isName && /*!_isUsername &&*/ !_isEmail) {
                                      // await verifyPhoneNumber();

                                      setState(() {
                                        registerClick = true;
                                      });

                                      await sendEmail();
                                    }
                                    else{
                                      String log = '';
                                      // if(_isPhoneNumber)
                                      //   log = log + 'Numero di telefono non valido\n';
                                      // if(_isUsername)
                                      //   log = log + 'Username non valido\n';
                                      if(_isName)
                                        log = log + 'Nome e Cognome non validi\n';
                                      if(_isEmail)
                                        log = log + 'Email non valida';
                                      Fluttertoast.showToast(
                                        // msg: 'Email aggiornata a ${widget.user.email}',
                                        // msg: 'Username non valido',
                                        msg: log.trim(),
                                        backgroundColor: Colors.grey[700],
                                        // )..then((value) => Navigator.pop(context));
                                      )/*.then((value) => */;
                                    }
                                  },
                                  height: 45,
                                  elevation: 0,
                                  minWidth: MediaQuery.of(context).size.width * 0.75,
                                  // color: Colors.blue[500],
                                  color: Colors.orange[600],
                                  child: Text(
                                    "Registrati",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15,),
                              // MaterialButton(
                              Visibility(
                                visible: !Utils.isBusiness,
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    child: OutlinedButton(
                                      onPressed: (){
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            PageTransition(
                                              child: LoginScreen(),
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
                                      // height: 45,
                                      // elevation: 0,
                                      // minWidth: MediaQuery.of(context).size.width * 0.75,
                                      // color: Colors.grey[500],
                                      // padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(10.0),
                                      // ),
                                      child: Text(
                                        // "Accedi",
                                        "Login",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          //   color: Colors.blue[500],
                                            color: Colors.orange[600],
                                            fontSize: 15.0
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25,),
                            ],
                          ),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'Hai dei problemi?',
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
        )
      ),
    );
  }
}
