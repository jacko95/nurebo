import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/services/firebase_options.dart';
import 'package:nurebo/utils/notification_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  //
  // showLocalNotification(
  //     id: 1,
  //     title: message.notification?.title ?? '',
  //     body: message.notification?.body ?? '',
  //     payload: message.notification?.title ?? '');

  // if (message.notification?.title == 'Title botwana sadame ujungi') {
  //   Get.to(() => const Screen1View());
  // } else {
  //   Get.to(() => const Screen2View());
  // }
}

class FCMNotificationHelper {
  static void registerNotification(/*BuildContext? context*/) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    LocalNotification service = LocalNotification();
    await service.initializeLocalNotifications(/*context*/);

    FirebaseMessaging.instance.getToken().then((value) {
      // if (kDebugMode) {
        //print(value);
      // }
        deviceToken = value;
    });

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        //print('************ getInitialMessage *****************');
        dev.log(
          'getInitialMessage',
          name: 'my.app.category',
          error: jsonEncode(message.data),
        );
        //print(message.notification!.title);
        //print(message.data);
        // Get.showSnackbar(GetSnackBar(title: 'getInitialMessage',message: message.notification?.body ?? '',));
        if (message.notification?.title == 'Title botwana sadame ujungi') {
          // Get.to(() => const NewsScreen());
          // Navigator.push(
          //     context!,
          //     PageTransition(
          //         duration: const Duration(milliseconds: 500),
          //         alignment: Alignment.center,
          //         type: PageTransitionType.fade,
          //         child: const NewsScreen()
          //     )
          // );
          // Navigator.push(
          //   context!,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => const NewsScreen(),
          //       fullscreenDialog: true,
          //       settings: RouteSettings(
          //
          //       )
          //   ),
          // );
        }
        else {
          // Get.to(() => const ExploreScreen());
          // Navigator.push(
          //     context!,
          //     PageTransition(
          //         duration: const Duration(milliseconds: 500),
          //         alignment: Alignment.center,
          //         type: PageTransitionType.fade,
          //         child: const ExploreScreen()
          //     )
          // );
        }
      }
    });

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        //   //print('new messages on opened app');
        // showLocalNotification(
        //     id: 1,
        //     title: message.notification?.title ?? '',
        //     body: 'It is from onMessageOpenedApp',
        //     payload: message.notification?.title ?? '');
        //   // Parse the message received
        // if (message.notification?.title == 'Title botwana sadame ujungi') {
        //   Get.to(() => const Screen1View());
        // } else {
        //   Get.to(() => const Screen2View());
        // }

        //print(message.notification?.title ?? '');
        // Get.showSnackbar(GetSnackBar(title: 'onMessageOpenedApp',message: message.notification?.body ?? '',));
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(
          id: 1,
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: message.notification?.title ?? '',
          largeIconPath: message.notification?.android!.imageUrl ?? 'https://via.placeholder.com/48x48',
        );
        // Parse the message received
        // if (message.notification?.title == 'Title botwana sadame ujungi') {
        //   Get.to(() => const Screen1View());
        // } else {
        //   Get.to(() => const Screen2View());
        // }
      });
    } else {
      //print('User declined or has not accepted permission');
    }
  }
}
