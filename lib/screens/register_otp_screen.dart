import 'dart:async';
import 'dart:convert';

import 'package:nurebo/widgets/circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:telephony/telephony.dart';
import 'package:nurebo/services/telephony/telephony.dart';
// import 'package:vibration/vibration.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String? username;
  final String name;
  final String? phoneNumber;
  final String email;
  final String? authId;

  const RegisterOtpScreen({super.key, this.username, this.phoneNumber, required this.email, required this.name, this.authId});

  @override
  _RegisterOtpScreenState createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  int pinLength = 6;
  bool hasError = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();
  // final SmsReceiver receiver = SmsReceiver();
  final Telephony telephony = Telephony.instance;
  String? smsOTP;
  final int startTime = 30;
  late Duration duration;
  late Timer timer;
  int _currentIndex = 0;
  bool _isResendAgain = false;
  late Timer _timer;
  int _start = 300;
  CountDownController _controller = CountDownController();
  int _duration = 300;
  late UserProvider userProvider;
  static const restartChannel = MethodChannel('com.nurebo.nurebo/restart');


  verify() {
    setState(() {
      // _isLoading = true;
    });

    const oneSec = Duration(milliseconds: 2000);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        // _isLoading = false;
        // _isVerified = true;
      });
    });
  }

  void resend() {
    setState(() {
      _isResendAgain = true;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start == 0) {
          _start = 300;
          _isResendAgain = false;
          _timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  Future<void> _restartApp() async {
    try {
      await restartChannel.invokeMethod('restartApp');
    } on PlatformException catch (e) {
      // print("Failed to restart app: '${e.message}'.");
    }
  }

  Future verifyOtp() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/email/verify");
    // var url = Uri.parse("${Utils.httpServerUrl}validation_email/verify");
    var url = Uri.parse("${Utils.httpServerUrl}user/register/verify");

    Map<String, String?> body = {
      "username": widget.username,
      "name": widget.name,
      // "id": widget.authId,
      "auth_id": widget.authId,
      "fcm_token": deviceToken,
      "email": widget.email,
      "inserted_otp": _textEditingController.text,
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

    //print("response.ff4d4v54f54:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDatadsvvv2x6xx6v5v5vx5vx5vgg');
      // print(jsonData);

      //print(jsonData['success']);
      if(/*valore ricevuto dal server == "corretto"*/jsonData['success'] == 1) {
        // //print("jsonData['success'] == 1");
        // await register(jsonData['token']);
        await UserPreferences.setUserId(jsonData['user_id'].toString());
        await UserPreferences.setIsLogged(true);
        // await UserProvider().updateIsLogged(true);
        // await UserPreferences.setUserToken(userData['token']);
        await UserPreferences.setUserToken(jsonData['token']);

        // await getUser().then((value) => userProvider.setUser(value));
        userProvider.setUser(
          User(
            id: jsonData['user_id'],
            email: jsonData['user_email'],
            username: jsonData['user_username'],
            name: jsonData['user_name'],
            email_notification: 1,
            fcm_token: jsonData['fcm_token'],
            latitude: jsonData['latitude']?.toDouble(),
            longitude: jsonData['longitude']?.toDouble(),
          )
        );

        await _restartApp();

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     PageTransition(
        //       // child: Main(
        //       //   user: new User(
        //       //     id: userData['id'],
        //       //     profile_image: 'https://images.pexels.com/photos/7269213/pexels-photo-7269213.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        //       //     // profile_image: 'https://cdn-icons-png.flaticon.com/512/456/456212.png',
        //       //     // profile_image: 'http://192.168.1.225/default_user_image/user (1).png',
        //       //     phone_number: widget.phoneNumber,
        //       //     username: widget.username,
        //       //     email: widget.email
        //       //   ),
        //       // ),
        //       // child: HomeScreen(),
        //       child: Main(),
        //       duration: const Duration(milliseconds: 800),
        //       type: PageTransitionType.fade,
        //     ),
        //     (route) => false
        // );
      }
      else if(jsonData['success'] == 0) {
        // //print("jsonData['success''] = 0");

        /*UserPreferences.setUser(widget.user.id.toString());
        UserPreferences.setIsLogged(false);*/

        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginScreen(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 100),
          ),
          (route) => false
        );
      }
      //else
      //push to view in cui mostra che l'otp è sbagliato
      //con un botton per riprovare l'autenticazione

      return jsonData;
    }
  }

  // Future register(String? token) async {
  //   var url = Uri.parse("${Utils.httpServerUrl}user/register");
  //
  //   Map<String, String?> body = {
  //     "auth_id": widget.authId,
  //     "username": widget.username,
  //     "email": widget.email,
  //     // "name": widget.name,
  //     // "phone_number": widget.phoneNumber
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
  //   //print('response.statusCodedf5df5dg5dgdg5dg5dv5vv5vd5dv5');
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400){
  //     var userData = json.decode(response.body)/*.toString()*/;
  //     // //print(userData.toString());
  //     // //print("Utente registrato!");
  //     /*Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: UsernameScreen(),
  //           duration: const Duration(milliseconds: 800),
  //           type: PageTransitionType.fade,
  //
  //         ),
  //             (route) => false
  //     );*/
  //
  //     // //print("userData['id']");
  //     // //print(userData['id']);
  //     await UserPreferences.setUserId(userData['id'].toString());
  //     await UserPreferences.setIsLogged(true);
  //     // await UserProvider().updateIsLogged(true);
  //     // await UserPreferences.setUserToken(userData['token']);
  //     await UserPreferences.setUserToken(token!);
  //
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           // child: Main(
  //           //   user: new User(
  //           //     id: userData['id'],
  //           //     profile_image: 'https://images.pexels.com/photos/7269213/pexels-photo-7269213.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  //           //     // profile_image: 'https://cdn-icons-png.flaticon.com/512/456/456212.png',
  //           //     // profile_image: 'http://192.168.1.225/default_user_image/user (1).png',
  //           //     phone_number: widget.phoneNumber,
  //           //     username: widget.username,
  //           //     email: widget.email
  //           //   ),
  //           // ),
  //           child: HomeScreen(),
  //           duration: const Duration(milliseconds: 800),
  //           type: PageTransitionType.fade,
  //         ),
  //         (route) => false
  //     );
  //     // var userDataToStr = userData.toString();
  //     // if(userData.toString()/*userDataToStr*/ == "Errore"){
  //     //   showDialog(
  //     //       context: context,
  //     //       builder: (context) => AlertDialog(
  //     //         // key: _formKey,
  //     //         actions: [
  //     //           ElevatedButton(
  //     //             style: ButtonStyle(
  //     //               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  //     //               backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
  //     //             ),
  //     //             onPressed: (){
  //     //               Navigator.pop(context);
  //     //             },
  //     //             child: Text("Cancel"),
  //     //           ),
  //     //         ],
  //     //         content: Text(
  //     //           "Utente già registrato",
  //     //         ),
  //     //         title: Text(
  //     //           "Message",
  //     //         ),
  //     //       )
  //     //   );
  //     // }
  //     // else{
  //     //   // if(userData['status'].toString() == "Admin"){
  //     //   //   // Navigator.push(
  //     //   //   //   context,
  //     //   //   //   MaterialPageRoute(
  //     //   //   //       builder: (context) => Dashboard(
  //     //   //   //
  //     //   //   //       )
  //     //   //   //   ),
  //     //   //   // );
  //     //   // }
  //     //   // else{
  //     //   //   // Navigator.push(
  //     //   //   //   context,
  //     //   //   //   MaterialPageRoute(
  //     //   //   //       builder: (context) => MyHomePage(
  //     //   //   //         name: userData['name'].toString(),
  //     //   //   //         email: userData['username'].toString(),
  //     //   //   //
  //     //   //   //       )
  //     //   //   //   ),
  //     //   //   // );
  //     //   // }
  //     //   showDialog(
  //     //       context: context,
  //     //       builder: (context) => AlertDialog(
  //     //         // key: _formKey,
  //     //         actions: [
  //     //           ElevatedButton(
  //     //             style: ButtonStyle(
  //     //               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  //     //               backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
  //     //             ),
  //     //             onPressed: (){
  //     //               Navigator.pop(context);
  //     //             },
  //     //             child: Text("Cancel"),
  //     //           ),
  //     //         ],
  //     //         content: Text(
  //     //           "Utente registrato con successo",
  //     //         ),
  //     //         title: Text(
  //     //           "Message",
  //     //         ),
  //     //       )
  //     //   );
  //     //   debug//print(userData.toString());
  //     // }
  //   }
  // }

  Widget buildTime() {
    return Text(
      "${duration.inSeconds}",
      style: TextStyle(
          fontSize: 45
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(
        Duration(
          seconds: 1,
        ),
        (_) => addTime()
    );
  }

  addTime() {
    final addSeconds = 1;
    final seconds = duration.inSeconds - addSeconds;
    setState(() {
      // final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
    if(seconds == 0) {
      // //print("Countdown terminato!");
      timer.cancel();
      // reset();
      // startTimer();
      /*Navigator. pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => SendOTPScreen(),
          builder: (context) => UsernameScreen(),
        ),
      );*/
    }
  }

  void reset(){
    // setState(() {

    //   duration = Duration(seconds: startTime);
    // });
    setState(() =>
      duration = Duration(seconds: startTime)
    );
  }

  @override
  void dispose() {
    super.dispose();
    // timer.cancel();
    // _timer.cancel();
  }

  @override
  void initState() {
    // timer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   setState(() {
    //     _currentIndex++;
    //
    //     if(_currentIndex == 3)
    //       _currentIndex = 0;
    //   });
    // });
    super.initState();
    // //print("widget.loginId:");
    // //print(widget.loginId);
    UserPreferences.init();

    userProvider = Provider.of<UserProvider>(context, listen: false);


    // duration = Duration(seconds: startTime);
    // startTimer();

    // receiver.onSmsReceived.listen((SmsMessage smsMessage) async {
    //   setState(() {
    //     this.smsOTP = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'), '');
    //     _textEditingController.text = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'), '');
    //   });
    // });
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          // //print('message.body5');
          // //print(message.body);
          this.smsOTP = message.body!.replaceAll(RegExp(r'[^0-9]'), '');
          _textEditingController.text = message.body!.replaceAll(RegExp(r'[^0-9]'), '');
          // Vibration.vibrate(duration: 500);
        },
        // onBackgroundMessage: backgroundMessageHandler,
        // listenInBackground: true
        listenInBackground: false
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        // appBar: AppBar(
        //   title: Text('Verify OTP'),
        //   // backgroundColor: Colors.red,
        //   elevation: 0.0,
        //   centerTitle: true,
        // ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                // Container(
                //   height: MediaQuery.of(context).size.height * 0.35,
                //   child: Stack(
                //       children: [
                //         Positioned(
                //           top: 0,
                //           left: 0,
                //           right: 0,
                //           bottom: 0,
                //           child: AnimatedOpacity(
                //             opacity: _currentIndex == 0 ? 1 : 0,
                //             duration: Duration(seconds: 1,),
                //             curve: Curves.linear,
                //             child: Image.network('https://ouch-cdn2.icons8.com/eza3-Rq5rqbcGs4EkHTolm43ZXQPGH_R4GugNLGJzuo/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNjk3/L2YzMDAzMWUzLTcz/MjYtNDg0ZS05MzA3/LTNkYmQ0ZGQ0ODhj/MS5zdmc.png',),
                //           ),
                //         ),
                //         Positioned(
                //           top: 0,
                //           left: 0,
                //           right: 0,
                //           bottom: 0,
                //           child: AnimatedOpacity(
                //             opacity: _currentIndex == 1 ? 1 : 0,
                //             duration: Duration(seconds: 1),
                //             curve: Curves.linear,
                //             child: Image.network('https://ouch-cdn2.icons8.com/pi1hTsTcrgVklEBNOJe2TLKO2LhU6OlMoub6FCRCQ5M/rs:fit:784:666/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMzAv/MzA3NzBlMGUtZTgx/YS00MTZkLWI0ZTYt/NDU1MWEzNjk4MTlh/LnN2Zw.png',),
                //           ),
                //         ),
                //         Positioned(
                //           top: 0,
                //           left: 0,
                //           right: 0,
                //           bottom: 0,
                //           child: AnimatedOpacity(
                //             opacity: _currentIndex == 2 ? 1 : 0,
                //             duration: Duration(seconds: 1),
                //             curve: Curves.linear,
                //             child: Image.network('https://ouch-cdn2.icons8.com/ElwUPINwMmnzk4s2_9O31AWJhH-eRHnP9z8rHUSS5JQ/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNzkw/Lzg2NDVlNDllLTcx/ZDItNDM1NC04YjM5/LWI0MjZkZWI4M2Zk/MS5zdmc.png',),
                //           ),
                //         )
                //       ]
                //   ),
                // ),

                Visibility(
                  visible: _controller.isPaused,
                  child: Lottie.asset(
                    'assets/animations/98288-loading.json',
                    // controller: animationController,
                    width: 200,
                    height: 200,
                    // repeat: true
                  ),
                ),
                Visibility(
                  visible: !_controller.isPaused,
                  child: CircularCountDownTimer(
                    // Countdown duration in Seconds.
                    duration: _duration,

                    // Countdown initial elapsed Duration in Seconds.
                    initialDuration: 0,

                    // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                    controller: _controller,

                    // Width of the Countdown Widget.
                    width: MediaQuery.of(context).size.width * 0.3,

                    // Height of the Countdown Widget.
                    height: MediaQuery.of(context).size.height * 0.2,

                    // Ring Color for Countdown Widget.
                    ringColor: Colors.grey[300]!,

                    // Ring Gradient for Countdown Widget.
                    ringGradient: null,

                    // Filling Color for Countdown Widget.
                    fillColor: Colors.blue[500]!,

                    // Filling Gradient for Countdown Widget.
                    fillGradient: null,

                    // Background Color for Countdown Widget.
                    backgroundColor: Colors.blue[300],

                    // Background Gradient for Countdown Widget.
                    backgroundGradient: null,

                    // Border Thickness of the Countdown Ring.
                    strokeWidth: 15.0,

                    // Begin and end contours with a flat edge and no extension.
                    strokeCap: StrokeCap.round,
                    // strokeCap: StrokeCap.square,

                    // Text Style for Countdown Text.
                    textStyle: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),

                    // Format for the Countdown Text.
                    textFormat: CountdownTextFormat.S,

                    // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                    isReverse: true,

                    // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                    isReverseAnimation: true,

                    // Handles visibility of the Countdown Text.
                    isTimerTextShown: true,

                    // Handles the timer start.
                    autoStart: true,

                    // This Callback will execute when the Countdown Starts.
                    onStart: () {
                      // Here, do whatever you want
                      // //print('Countdown Started');
                    },

                    // This Callback will execute when the Countdown Ends.
                    onComplete: () {
                      // Here, do whatever you want
                      // //print('Countdown Ended');
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 200),
                          type: PageTransitionType.fade,
                          child: LoginScreen(),
                        )
                      );
                    },
                  ),
                ),
                // Center(child: buildTime()),
                // Center(
                //   child: Text(
                //     "Verification",
                //     style: TextStyle(
                //         fontSize: 30,
                //         fontWeight: FontWeight.bold
                //     ),
                //   ),
                // ),
                SizedBox(height: 30,),
                Text(
                  "Controlla la tua Email e inserisci il codice",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),
                ),
                SizedBox(height: 20,),
                Form(
                  key: _formKey,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: PinCodeTextField(
                      highlightColor: Colors.grey,
                      defaultBorderColor: Colors.grey,
                      hasTextBorderColor: Colors.grey,
                      autofocus: false,
                      hideCharacter: false,
                      highlight: true,
                      pinBoxHeight: 40,
                      pinBoxWidth: 40,
                      controller: _textEditingController,
                      maxLength: pinLength,
                      hasError: hasError,
                      // maskCharacter: '*',
                      onTextChanged: (/*text*/_) async {
                        // if (text.length == 6) {
                        // if (_textEditingController.text.length == 6) {
                        //   // setState(() {
                        //   //   receiver.onSmsReceived.listen((SmsMessage smsMessage) async{
                        //   //     this.smsOTP = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'),'');
                        //   //   });
                        //   // });
                        //   /*var ret = */
                        //   await verifyOtp();
                        //   // if(ret == 1){
                        //   //   Navigator.push(
                        //   //       context,
                        //   //       MaterialPageRoute(builder: (context) => DashBoard())
                        //   //   );
                        //   // }
                        //   // otpData = text;
                        //   // smsOTP = text;
                        //   //print(_textEditingController.text);
                        // }
                      },
                      pinBoxRadius: 5,
                      onDone: (text) {
                        //   await verifyOtp();
                      },
                      wrapAlignment: WrapAlignment.start,
                      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                      pinTextStyle: TextStyle(fontSize: 18.0, color: Colors.black),
                      // pinTextAnimatedSwitcherTransition:
                      //     ProvidedPinBoxTextAnimation.scalingTransition,
                      // pinTextAnimatedSwitcherDuration:
                      //     const Duration(milliseconds: 300),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text("Non hai ricevuto il messaggio?", style: TextStyle(fontSize: 14, color: Colors.grey.shade500),),
                //     TextButton(
                //         onPressed: () {
                //           if (_isResendAgain) return;
                //           resend();
                //         },
                //         child: Text(
                //           _isResendAgain
                //               ? "Riprova tra " + _start.toString()
                //               : "Riprova",
                //           style: TextStyle(
                //               color: Colors.blueAccent
                //           ),
                //         )
                //     )
                //   ],
                // ),
                SizedBox(height: 50,),
                Visibility(
                  visible: !_controller.isPaused,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: MaterialButton(
                        onPressed: () async {
                          // await verifyUser();
                          // await sendSms();
                          _controller.pause();

                          await verifyOtp();
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
                              "Conferma",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            )
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialogFailed(BuildContext context,String title, String description,String buttonName) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text(buttonName),
      onPressed: () {
       Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
