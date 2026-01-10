import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:telephony/telephony.dart';
import 'package:nurebo/services/telephony/telephony.dart';
// import 'package:vibration/vibration.dart';
import 'package:nurebo/widgets/circular_countdown_timer/circular_countdown_timer.dart';


class VerifyEmail extends StatefulWidget {
  final String? authId;
  final User user;
  final String email;
  final bool? isEmailVerification;

  const VerifyEmail({super.key, this.authId, required this.user, this.isEmailVerification, required this.email});

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  int pinLength = 6;
  bool hasError = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();
  // final SmsReceiver receiver = SmsReceiver();
  final Telephony telephony = Telephony.instance;
  String? smsOTP;
  final int startTime = 30;
  late Duration duration;
  // late Timer timer;
  int _currentIndex = 0;

  bool _isResendAgain = false;
  late Timer _timer;
  // int _start = 60;
  late int _start;

  CountDownController _controller = CountDownController();
  // int _duration = 60;
  late int _duration;
  late UserProvider userProvider;
  late SocketProvider socketProvider;
  late PrestazioneFavoriteProvider favoriteProvider;
  late BusinessFavoriteProvider businessFavoriteProvider;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        // deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          // deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          // deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    //print('deviceData');
    //print(deviceData);

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  verify() {
    // setState(() {
      // _isLoading = true;
    // });

    const oneSec = Duration(milliseconds: 2000);
    _timer = Timer.periodic(oneSec, (timer) {
      // setState(() {
        // _isLoading = false;
        // _isVerified = true;
      // });
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
          if(widget.isEmailVerification!) {
            _start = 300;
          } else {
            _start = 60;
          }
          _isResendAgain = false;
          _timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  Future patchEmail() async {
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/email");

    Map<String, dynamic> body = {
      'user_id': userProvider.user!.id,
      'email': widget.email,
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
      },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('sdc54vsv4v5d5fb');
      //print(jsonData);

      userProvider.updateEmail(widget.email);

      final SnackBar snackBar = SnackBar(
        content: Text(
          'Email aggiornata correttamente',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);

      return jsonData;
    }
  }

  Future verifyOtp() async {
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user.id.toString()}/authentication/${widget.authId.toString()}/verify");

    Map<String, String> body = {
      "id": widget.authId.toString(),
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

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      if(jsonData['success'] == 1) {

        Future.wait([
          patchEmail(),
          // socketProvider.insertDevice(userProvider.user!, _deviceData),
        ]);

        if(widget.isEmailVerification!){

          // await Navigator.pushAndRemoveUntil(
          //     context,
          //     PageTransition(
          //       // child: Main(user: widget.user,),
          //       child: const HomeScreen(),
          //       type: PageTransitionType.fade,
          //       duration: Duration(milliseconds: 500),
          //     ),
          //     (route) => false
          // )/*.then((value) => Phoenix.rebirth(context))*/;

          Navigator.pop(context);
          Navigator.pop(context);
          socketProvider.setBottomBarVisibility(true);

          // Main main = const Main();
          // main.selectTab("page1", 0);
        }
        else{
          await Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                // child: Main(user: widget.user,),
                child: HomeScreen(),
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 500),
              ),
              (route) => false
          );
        }
      }
      // else if(jsonData == 0) {
      else if(jsonData['success'] == 0) {
        Navigator.pop(context);

        final SnackBar snackBar = SnackBar(
          content: Text(
            'Email non aggiornata',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        );
        snackbarKey.currentState?.showSnackBar(snackBar);
      }

      return jsonData;
    }
    else{
      Navigator.pop(context);
    }
  }

  Widget buildTime() {
    return Text(
      "${duration.inSeconds}",
      style: const TextStyle(
          fontSize: 45
      ),
    );
  }

  // void startTimer() {
  //   timer = Timer.periodic(
  //       Duration(
  //         seconds: 1,
  //       ),
  //       (_) => addTime()
  //   );
  // }

  // addTime() {
  //   final addSeconds = 1;
  //   final seconds = duration.inSeconds - addSeconds;
  //   setState(() {
  //     // final seconds = duration.inSeconds + addSeconds;
  //     duration = Duration(seconds: seconds);
  //   });
  //   if(seconds == 0) {
  //     // //print("Countdown terminato!");
  //     timer.cancel();
  //     // reset();
  //     // startTimer();
  //     /*Navigator. pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         // builder: (context) => SendOTPScreen(),
  //         builder: (context) => UsernameScreen(),
  //       ),
  //     );*/
  //   }
  // }

  void reset(){
    // setState(() {
    //   duration = Duration(seconds: startTime);
    // });
    setState(() => duration = Duration(seconds: startTime));
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    // _controller.pause();

    if(Utils.isSocial){
      //todo: false per nascondere bottombar
      Future.delayed(const Duration(microseconds: 0), () => {
        socketProvider.setBottomBarVisibility(false)
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);

    Future.wait([
      initPlatformState(),
    ]);

    Future.delayed(const Duration(microseconds: 0), () => {
      socketProvider.setBottomBarVisibility(false)
    });


    _start = !widget.isEmailVerification! ? 60 : 300;
    _duration = !widget.isEmailVerification! ? 60 : 300;
    // //print("widget.loginId:");
    // //print(widget.loginId);

    // UserPreferences.init();//???

    // duration = Duration(seconds: startTime);
    // startTimer();
    if(!widget.isEmailVerification!){
      // receiver.onSmsReceived.listen((SmsMessage smsMessage) async {
      //   setState(() {
      //     this.smsOTP = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'), '');
      //     _textEditingController.text = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'), '');
      //   });
      // });
      telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            // Handle message
            // //print('message.body6');
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
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
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

                      Navigator.pop(context);

                      // Navigator.pushReplacement(
                      //   context,
                      //   PageTransition(
                      //     duration: const Duration(milliseconds: 200),
                      //     type: PageTransitionType.fade,
                      //     child: LoginScreen(),
                      //   )
                      // );
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
                Container(
                  width: MediaQuery.of(context).size.width * .85,
                  child: Text(
                    // !widget.isEmailVerification ? "Inserire il codice a 6 cifre inviato da\n+39 379 221 6112"
                    //   : "Inserire il codice a 6 cifre inviato da nurebo",
                    "Controlla la tua Email e inserisci il codice",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),
                  ),
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
                      // onTextChanged: (/*text*/_) async {
                      //   // // if (text.length == 6) {
                      //   if (_textEditingController.text.length == pinLength) {
                      //   //   // setState(() {
                      //   //   //   receiver.onSmsReceived.listen((SmsMessage smsMessage) async{
                      //   //   //     this.smsOTP = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'),'');
                      //   //   //   });
                      //   //   // });
                      //   //   // if(widget.isEmailVerification){
                      //   //   //
                      //   //   // }
                      //     /*var ret = */await verifyOtp();
                      //   //   // if(ret == 1){
                      //   //   //   Navigator.push(
                      //   //   //       context,
                      //   //   //       MaterialPageRoute(builder: (context) => DashBoard())
                      //   //   //   );
                      //   //   // }
                      //   //   // otpData = text;
                      //   //   // smsOTP = text;
                      //   //   //print(_textEditingController.text);
                      //   }
                      // },
                      pinBoxRadius: 5,
                      // onDone: (/*text*/_) async {
                      // //   await verifyOtp();
                      // },
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
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: MaterialButton(
                      onPressed: () async {
                        // await verifyUser();
                        // await sendSms();
                        // _timer.cancel();
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
