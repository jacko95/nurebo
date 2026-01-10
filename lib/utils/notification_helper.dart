import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  if (kDebugMode) {
    //print('background clicked');
  }
  // if (notificationResponse.payload == 'Title botwana sadame ujungi') {
  //   Get.to(() => const Screen1View());
  // } else {
  //   Get.to(() => const Screen2View());
  // }
}

final localNotifications = FlutterLocalNotificationsPlugin();

class LocalNotification {
   Future<void> initializeLocalNotifications(/*BuildContext? context*/) async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('android12splash'/*'calendar'*/);

    DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    LinuxInitializationSettings initializationSettingsLinux = const LinuxInitializationSettings(
      defaultActionName: 'Open notification'
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux
    );

    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        //print('notificationResponse1');
        //print(notificationResponse.payload);
        //print(notificationResponse.id);
        // //print(notificationResponse.actionId);
        if (notificationResponse.payload == 'Title botwana sadame ujungi') {
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
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground
    );
  }

  // this function is applicable to iOS versions older than 10.
  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {}
}

Future<void> showNotification({
  /*required*/ int? id,
  required String title,
  required String body,
  /*required*/ String? payload = '',
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String subText = '',
  String? senderId = '0',
  BuildContext? context,
}) async {
  final platformChannelSpecifics = await _notificationDetails(
    largeIconPath: largeIconPath,
    subText: subText,
    context: context,
  );
  await localNotifications.show(
    // id,
    Random().nextInt(999999),
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(
    Uri.parse("${Utils.httpServerUrl}image?path=$url"),
    headers: {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Accept-encoding': 'gzip, deflate',
      'connection': 'keep-alive',
      'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
      'X-App-Version-Name': Utils.version_name,
      'X-App-Version-Number': Utils.version_id.toString(),
      'X-Client-Type': 'User-Mobile-App',
      HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!,
    }
  );
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<NotificationDetails> _notificationDetails({
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String subText = '',
  BuildContext? context,
}) async {
  final String largeIcon = await _downloadAndSaveFile(
    largeIconPath,
    'largeIcon'
  );

  final Int64List vibrationPattern = Int64List(2);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 2000;

  final AndroidNotificationDetails androidPlatformChannelSpecifics = /*const*/ AndroidNotificationDetails(
    // 'fcm_nurebo_channel', // id
    Random().nextInt(999999).toString(), // id
    'fcm_nurebo_channel', // title
    importance: Importance.high,
    playSound: true,
    groupKey: 'com.nurebo.nurebo',
    channelDescription: 'channel description',
    priority: Priority.max,
    // icon: 'calendar',
    icon: 'android12splash',
    // icon: 'calendar_1',
    ticker: 'ticker',
    // color: const Color(0xff2196f3),

    largeIcon: FilePathAndroidBitmap(largeIcon),
    ledOffMs: 300,
    ledOnMs: 300,
    ledColor: Colors.blue,
    enableVibration: false,
    enableLights: true,
    channelShowBadge: true,
    vibrationPattern: vibrationPattern,
    visibility: NotificationVisibility.public,
    subText: subText,
    // sound: const RawResourceAndroidNotificationSound('piece_of_cake_611.mp3'),
    styleInformation: const MediaStyleInformation(),
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_nurebo_channel', // id
      'fcm_nurebo_channel', // title
      importance: Importance.high,
      playSound: true
  );

  await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      channel
  );

  DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
    threadIdentifier: "thread1",
  );

  final details = await localNotifications.getNotificationAppLaunchDetails();
  if (details != null && details.didNotificationLaunchApp) {}
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails
  );

  return platformChannelSpecifics;
}
