import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationProvider extends ChangeNotifier {


  NotificationProvider(){
    initializeDateFormatting();
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // //initialize
  // Future initialize() async {
  //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   final AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('ic_launcher'); //Add Icon in android->app->src->main->res->drawable
  //   final IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings(); //check AppDelegate.swift in Runner Folder
  //   final InitializationSettings initializationSettings = InitializationSettings(
  //       android: androidInitializationSettings,
  //       iOS: iosInitializationSettings
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

/*  showDateNotification({required String beginAt,
    String? prestazioneTitle,
    String? username,
    String? note,
    String? name,
    String? imageProfile,
    required String imagePrestazione,
  }){
    bookingInstantNotification(
      imagePrestazione: imagePrestazione,
      prestazioneTitle: prestazioneTitle,
      beginAt: beginAt,

    );
  }*/

/*  Future bookingInstantNotification({
    required String beginAt,
    String? prestazioneTitle,
    String? username,
    String? note,
    String? name,
    String? imageProfile,
    required String imagePrestazione,
  }) async {
    final Int64List vibrationPattern = Int64List(2);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
    // vibrationPattern[2] = 10000;
    // vibrationPattern[3] = 5000;

    // final String largeIconPath = await _downloadAndSaveFile(
    //   // 'https://via.placeholder.com/48x48',
    //     imageProfile,
    //     'largeIcon'
    // );

    final String bigPicturePath = await _downloadAndSaveFile(
      // 'https://via.placeholder.com/400x800',
        imagePrestazione,
        'bigPicture'
    );
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
        // FilePathAndroidBitmap(largeIconPath),
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(bigPicturePath),
        contentTitle: '$prestazioneTitle',
        htmlFormatContentTitle: true,
        // summaryText: "<p>@$username</p>",
        // summaryText: "<p>@username</p>",
        summaryText: DateFormat.yMMMMd('it_IT').format(DateTime.parse(beginAt)).toString()
            + ' alle ' + beginAt.substring(11, 16),
        // htmlFormatSummaryText: true
        htmlFormatSummaryText: false
    );

    // final sound = 'slow_spring_board_longer_tail_571.ogg';
    // final sound = 'piece_of_cake_611.mp3';
    var android = AndroidNotificationDetails(
        'fcm_nurebo_channel',
        'fcm_nurebo_channel',
        channelDescription: 'channelDescription',
        // playSound: true,
        playSound: false,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        enableLights: true,
        channelShowBadge: true,

        // tag: 'Taggatolo',
        subText: "Prenotazione",
        fullScreenIntent: true,
        // groupKey: '1',
        // groupAlertBehavior: GroupAlertBehavior.children,
        // setAsGroupSummary: true,
        icon: 'calendar',
        // largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
        // largeIcon: const DrawableResourceAndroidBitmap('calendar'),
        largeIcon: FilePathAndroidBitmap(bigPicturePath),
        ledOffMs: 300,
        ledOnMs: 300,
        ledColor: Colors.blue,
        // onlyAlertOnce: true,

        // styleInformation: MediaStyleInformation(
        //   htmlFormatContent: true,
        //   htmlFormatTitle: false,
        // ),
        styleInformation: bigPictureStyleInformation,
        // vibrationPattern: Int64List(20000),//vibrazione non va
        vibrationPattern: vibrationPattern,
        visibility: NotificationVisibility.public,
        // sound: RawResourceAndroidNotificationSound(sound.split('.').first)
    );

    var ios = IOSNotificationDetails(
      // sound: sound,
      // presentSound: true,

    );

    var platform = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
      // 0,
        Random().nextInt(88887),
        prestazioneTitle,
        // '@' + username,
        // beginAt,
        DateFormat.yMMMMd('it_IT').format(DateTime.parse(beginAt)).toString()
            + ' alle ' + beginAt.substring(11, 16),
        // 'cccio',
        platform,
        payload: 'This is a demo app'
    );
    notifyListeners();
  }*/

/*  Future purchaseNotification({
    String? body,
    String? title,
    // String image,
  }) async {
    final Int64List vibrationPattern = Int64List(2);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
    // vibrationPattern[2] = 10000;
    // vibrationPattern[3] = 5000;

    // final String largeIconPath = await _downloadAndSaveFile(
    //   // 'https://via.placeholder.com/48x48',
    //     imageProfile,
    //     'largeIcon'
    // );

    // final String bigPicturePath = await _downloadAndSaveFile(
    //   // 'https://via.placeholder.com/400x800',
    //     image,
    //     'bigPicture'
    // );
    // final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
    //   // FilePathAndroidBitmap(largeIconPath),
    //     FilePathAndroidBitmap(bigPicturePath),
    //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
    //     contentTitle: '$title',
    //     htmlFormatContentTitle: true,
    //     // summaryText: "<p>@$username</p>",
    //     // summaryText: "<p>@username</p>",
    //     summaryText: DateFormat.yMMMMd('it_IT').format(DateTime.parse(body)).toString()
    //         + ' alle ' + body.substring(11, 16),
    //     // htmlFormatSummaryText: true
    //     htmlFormatSummaryText: false
    // );

    // final sound = 'slow_spring_board_longer_tail_571.ogg';
    // final sound = 'piece_of_cake_611.mp3';
    var android = AndroidNotificationDetails(
      'fcm_nurebo_channel',
      'fcm_nurebo_channel',
      channelDescription: 'channelDescription',
      // playSound: true,
      playSound: false,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      enableLights: true,
      channelShowBadge: true,

      // tag: 'Taggatolo',
      subText: "Prenotazione",
      // fullScreenIntent: true, //per tenere fissa la notifica sullo schermo
      fullScreenIntent: false,
      // groupKey: '1',
      // groupAlertBehavior: GroupAlertBehavior.children,
      // setAsGroupSummary: true,
      icon: 'calendar',
      // largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
      // largeIcon: const DrawableResourceAndroidBitmap('calendar'),
      // largeIcon: FilePathAndroidBitmap(bigPicturePath),
      ledOffMs: 300,
      ledOnMs: 300,
      ledColor: Colors.blue,
      // onlyAlertOnce: true,

      // styleInformation: MediaStyleInformation(
      //   htmlFormatContent: true,
      //   htmlFormatTitle: false,
      // ),
      // styleInformation: bigPictureStyleInformation,
      // vibrationPattern: Int64List(20000),//vibrazione non va
      vibrationPattern: vibrationPattern,
      visibility: NotificationVisibility.public,
      // sound: RawResourceAndroidNotificationSound(sound.split('.').first)
    );

    var ios = IOSNotificationDetails(
      // sound: sound,
      // presentSound: true,

    );

    var platform = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
      // 0,
        Random().nextInt(88887),
        title,
        // '@' + username,
        // beginAt,
        // DateFormat.yMMMMd('it_IT').format(DateTime.parse(body)).toString()
        //     + ' alle ' + body.substring(11, 16),
        body,
        // 'cccio',
        platform,
        payload: 'This is a demo app'
    );

    notifyListeners();
  }*/


/*
  Future<void> showChatMessageNotification({required String userId, String? username, required String profileImage, String? body}) async {
    final Int64List vibrationPattern = Int64List(2);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
    // vibrationPattern[2] = 10000;
    // vibrationPattern[3] = 5000;

    // final String largeIconPath = await _downloadAndSaveFile(
    //   // 'https://via.placeholder.com/48x48',
    //     imageProfile,
    //     'largeIcon'
    // );

    final String bigPicturePath = await _downloadAndSaveFile(
        profileImage,
        'bigPicture'
    );
    // final BigPictureStyleInformation bigPictureStyleInformation =
    // BigPictureStyleInformation(
    //   // FilePathAndroidBitmap(largeIconPath),
    //     FilePathAndroidBitmap(bigPicturePath),
    //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
    //     hideExpandedLargeIcon: true,
    //     contentTitle: '$username' + 'ppp',
    //     htmlFormatContentTitle: true,
    //     // summaryText: "<p>@$username</p>",
    //     // summaryText: "<p>@username</p>",
    //     // summaryText: DateFormat.yMMMMd('it_IT').format(DateTime.parse(beginAt)).toString()
    //     //     + ' alle ' + beginAt.substring(11, 16),
    //     // htmlFormatSummaryText: true
    //     htmlFormatSummaryText: false
    // );

    // final sound = 'slow_spring_board_longer_tail_571.ogg';
    // final sound = 'piece_of_cake_611.mp3';
    var android = AndroidNotificationDetails(
      'fcm_nurebo_channel',
      'channelName 27',
      channelDescription: 'channelDescription',
      // playSound: true,
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      enableLights: true,
      channelShowBadge: true,

      // tag: 'Taggatolo',
      subText: "Messaggio",
      // fullScreenIntent: true,
      // groupKey: '1',
      groupAlertBehavior: GroupAlertBehavior.children,
      // setAsGroupSummary: true,
      icon: 'ic_launcher',
      // largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
      // largeIcon: const DrawableResourceAndroidBitmap('calendar'),
      largeIcon: FilePathAndroidBitmap(bigPicturePath),
      ledOffMs: 300,
      ledOnMs: 300,
      ledColor: Colors.blue,
      // onlyAlertOnce: true,

      // styleInformation: MediaStyleInformation(
      //   htmlFormatContent: true,
      //   htmlFormatTitle: false,
      // ),
      // styleInformation: bigPictureStyleInformation,
      groupKey: userId,
      setAsGroupSummary: true,


      // vibrationPattern: Int64List(20000),//vibrazione non va
      vibrationPattern: vibrationPattern,
      visibility: NotificationVisibility.public,
      // sound: RawResourceAndroidNotificationSound(sound.split('.').first)
    );

    var ios = IOSNotificationDetails(
      // sound: sound,
      // presentSound: true,

    );

    var platform = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
      // 0,
      //   Random().nextInt(999999),
        userId.length,//da cambiare con un valore passato con socket io dall altro client
        // 'plain title',
        */
/*'@' + *//*
username,
        body,
        platform,
        payload: 'This is a demo app'
    );
    notifyListeners();
  }
*/

}
