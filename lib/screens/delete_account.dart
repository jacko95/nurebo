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
// import 'package:vibration/vibration.dart';
import 'package:nurebo/widgets/circular_countdown_timer/circular_countdown_timer.dart';
import 'package:webview_flutter/webview_flutter.dart';


class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  late WebViewController controller;
  String deletePageUrl = 'https://nurebo.com/delete-account.html';


  // NavigationDecision _handleNavigationRequest(NavigationRequest request) {
  //   if (request.url.startsWith('popup://')) {
  //     final message = Uri.decodeComponent(request.url.replaceFirst('popup://', ''));
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Popup rilevato: $message")),
  //     );
  //     return NavigationDecision.prevent;
  //   }
  //   return NavigationDecision.navigate;
  // }
  //
  // void _injectPopupDetectionJS() async {
  //   final String popupDetectionJS = '''
  //     (function() {
  //       function notifyFlutter(message) {
  //         window.location.href = 'popup://' + encodeURIComponent(message);
  //       }
  //
  //       window.alert = function(message) {
  //         notifyFlutter("alert: " + message);
  //         return true;
  //       };
  //
  //       window.confirm = function(message) {
  //         notifyFlutter("confirm: " + message);
  //         return true;
  //       };
  //
  //       window.prompt = function(message, defaultText) {
  //         notifyFlutter("prompt: " + message + " (default: " + defaultText + ")");
  //         return true;
  //       };
  //     })();
  //   ''';
  //
  //   await controller.runJavaScript(popupDetectionJS);
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {

          },
          onPageFinished: (String url) {

          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            // return _handleNavigationRequest(request);
            return NavigationDecision.navigate;
          },
        ),
      )..loadRequest(Uri.parse(deletePageUrl));
    // _injectPopupDetectionJS();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              // Icons.arrow_back,
              Icons.arrow_back_ios_new,
              size: 20,
              // size: 16,
              color: Colors.grey[500],
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: WebViewWidget(
            controller: controller,
            // javascriptMode: JavascriptMode.unrestricted,
            // initialUrl: "http://maps.google.com/maps?&z={INSERT_MAP_ZOOM}&mrt={INSERT_TYPE_OF_SEARCH}&t={INSERT_MAP_TYPE}&q={INSERT_MAP_LAT_COORDINATES}+{INSERT_MAP_LONG_COORDINATES}",
            // initialUrl: "https://maps.google.com/maps?&z=15&mrt=yp&t=k&q=27.9879012+86.9253141",
            // initialUrl: "https://www.google.com",
            // initialUrl: websiteUrl,
          ),
        ),
      ),
    );
  }

}
