import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:badges/badges.dart' as badges;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:nurebo/provider/business_provider.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/chat_provider.dart';
import 'package:nurebo/provider/post_favorite_provider.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/notification_provider.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/business_favorite_screen.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/favorites_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/notifications_screen.dart';
import 'package:nurebo/screens/post_liked_screen.dart';
import 'package:nurebo/screens/register_screen.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/news_screen.dart';
import 'package:nurebo/screens/post_feed_screen.dart';
import 'package:nurebo/screens/server_down_screen.dart';
import 'package:nurebo/screens/settings_screen.dart';
import 'package:nurebo/screens/splash_screen.dart';
import 'package:nurebo/screens/user_booking_list_screen.dart';
import 'package:nurebo/screens/user_friends_list_screen.dart';
import 'package:nurebo/services/firebase_options.dart';
import 'package:nurebo/tab_navigator.dart';
import 'package:nurebo/utils/fcm_notification_helper.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/popover.dart';
import 'package:nurebo/widgets/ss_bottombar/service.dart';
import 'package:nurebo/widgets/ss_bottombar/ss_bottom_navbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'models/business.dart';
import 'models/user.dart';
import 'models/category.dart' as category;
import 'package:flutter_native_splash/flutter_native_splash.dart';


DateTime? dateTime1;
DateTime? dateTime2;
final StreamController/*<dynamic>*/ streamController = StreamController/*<dynamic>*/.broadcast();
final Stream/*<dynamic>*/ broadcastStream = streamController.stream.asBroadcastStream();
// final StreamController streamController = StreamController();
String? deviceToken;
/*static*/ final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();
bool isServerDown = false;
// Future fa = Future((){});
// late PackageInfo packageInfo;

// Map<String, dynamic> _deviceData = <String, dynamic>{};
// Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
//   return <String, dynamic>{
//     'version.securityPatch': build.version.securityPatch,
//     'version.sdkInt': build.version.sdkInt,
//     'version.release': build.version.release,
//     'version.previewSdkInt': build.version.previewSdkInt,
//     'version.incremental': build.version.incremental,
//     'version.codename': build.version.codename,
//     'version.baseOS': build.version.baseOS,
//     'board': build.board,
//     'bootloader': build.bootloader,
//     'brand': build.brand,
//     'device': build.device,
//     'display': build.display,
//     'fingerprint': build.fingerprint,
//     'hardware': build.hardware,
//     'host': build.host,
//     'id': build.id,
//     'manufacturer': build.manufacturer,
//     'model': build.model,
//     'product': build.product,
//     'supported32BitAbis': build.supported32BitAbis,
//     'supported64BitAbis': build.supported64BitAbis,
//     'supportedAbis': build.supportedAbis,
//     'tags': build.tags,
//     'type': build.type,
//     'isPhysicalDevice': build.isPhysicalDevice,
//     'systemFeatures': build.systemFeatures,
//   };
// }
// Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
//   return <String, dynamic>{
//     'name': data.name,
//     'systemName': data.systemName,
//     'systemVersion': data.systemVersion,
//     'model': data.model,
//     'localizedModel': data.localizedModel,
//     'identifierForVendor': data.identifierForVendor,
//     'isPhysicalDevice': data.isPhysicalDevice,
//     'utsname.sysname:': data.utsname.sysname,
//     'utsname.nodename:': data.utsname.nodename,
//     'utsname.release:': data.utsname.release,
//     'utsname.version:': data.utsname.version,
//     'utsname.machine:': data.utsname.machine,
//   };
// }
// Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
//   return <String, dynamic>{
//     'numberOfCores': data.numberOfCores,
//     'computerName': data.computerName,
//     'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
//   };
// }
//
//
// Future<void> initPlatformState() async {
//   var deviceData = <String, dynamic>{};
//
//   try {
//     if (kIsWeb) {
//       // deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
//     } else {
//       if (Platform.isAndroid) {
//         deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
//       } else if (Platform.isIOS) {
//         deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
//       } else if (Platform.isLinux) {
//         // deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
//       } else if (Platform.isMacOS) {
//         // deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
//       } else if (Platform.isWindows) {
//         deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
//       }
//     }
//   } on PlatformException {
//     deviceData = <String, dynamic>{
//       'Error:': 'Failed to get platform version.'
//     };
//   }
//
//   // if (!mounted) return;
//
//   // setState(() {
//     _deviceData = deviceData;
//   // });
// }

Future<Business?> getBusiness() async {
  // final context = SecurityContext.defaultContext;
  // final httpClient = HttpClient(context: context);
  // final client = IOClient(httpClient);

  var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}");
  // Map/*<String, String>*/ body = {
  //   'manager_id': Utils.business_id,
  // };

  // var response = await client.post(
  var response = await http.get(
      url,
      // body: jsonEncode(body),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
        // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
      }
  );

  if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
    // if (!mounted) return;
    // await userProvider.logout(context);
  }
  else if(response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    Business business = Business(
        id: jsonData[0]['business_id'],
        description: jsonData[0]['business_description'],
        name: jsonData[0]['business_name'],
        email: jsonData[0]['business_email'],
        max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
        address: jsonData[0]['business_address'],
        phone: jsonData[0]['business_phone'],
        // is_booking_manager: jsonData[0]['is_booking_manager'],
        profile_image: jsonData[0]['business_profile_image'],
        latitude: jsonData[0]['business_latitude'],
        longitude: jsonData[0]['business_longitude'],
        category: category.Category(
          id: jsonData[0]['category_id'],
          image: jsonData[0]['category_image'],
          name: jsonData[0]['category_name'],
        )
    );
    // });

    // managerProvider.setManager(manager);
    // setState(() {
    //   managerProvider.manager = manager;
    // });

    // notifyListeners();
    Utils.business = business;

    return business;
  }
  return null;
}

Future getBusinessChatRoom(String businessId) async {
  var url = Uri.parse("${Utils.httpServerUrl}business/${businessId}/room");
  // Map/*<String, String>*/ body = {
  //   "user_id": userId,
  // };

  var response = await http.get(
      url,
      // body: jsonEncode(body),
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
  // print('dd6df6ff6f6f6f6ff6');

  if(response.statusCode >= 200 && response.statusCode < 400) {
    var jsonData = json.decode(response.body);
    // businessRooms = jsonData;

    // print('dc5cd5c6cvvb8');
    // print(jsonData);

    // Utils.business_room_id = jsonData[0]['business_room_id'];
    Utils.business!.room_id = jsonData[0]['business_room_id'];

    return jsonData;
  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

// Future<void> _showNotification({
//   // String senderUsername,
//   String? body,
//   String? senderUsername,
//   String? senderName,
//   String largeIconPath = 'https://via.placeholder.com/48x48',
//   String prestazioneImage = 'https://via.placeholder.com/48x48',
//   String? text,
//   String? title,
//   String senderId = '0',
//   String subText = '',
// }) async {
//   await UserPreferences.init();
//
//   final player = AudioPlayer();
//   var sound;
//
//   if(subText == 'Cancellazione'){
//     sound = 'my_work_is_done_message_tone.ogg';
//     await player.setAsset('assets/audio/my_work_is_done_message_tone.ogg');
//   }
//   else {
//     sound = 'piece_of_cake_611.mp3';
//     await player.setAsset('assets/audio/piece_of_cake_611.ogg');
//   }
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//   final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
//   final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
//   final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//       macOS: initializationSettingsMacOS
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: null,
//   );
//
//   final Int64List vibrationPattern = Int64List(2);
//
//   if(UserPreferences.getSilentNotifications() == false
//       && UserPreferences.getEnableNotifications() == true) {
//     player.play();
//   }
//
//   if(UserPreferences.getVibrateNotifications() == true && UserPreferences.getEnableNotifications() == true){
//     vibrationPattern[0] = 0;
//     vibrationPattern[1] = 2000;
//   }
//
//   // final String bigPicturePath = await _downloadAndSaveFile(
//   //   // 'https://via.placeholder.com/400x800',
//   //     prestazioneImage,
//   //     'bigPicture'
//   // );
//   // final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
//   //     FilePathAndroidBitmap(largeIconPath),
//   //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
//   //     contentTitle: '$prestazioneTitle',
//   //     htmlFormatContentTitle: true,
//   //     summaryText: "<p>@$username</p>",
//   //     htmlFormatSummaryText: true
//   // );
//
//   final String largeIcon = await _downloadAndSaveFile(
//     // 'https://via.placeholder.com/48x48',
//     //   imageProfile,
//       largeIconPath,
//       'largeIcon'
//   );
//
//   final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'fcm_nurebo_channel', 'fcm_nurebo_channel', //'your channel description',
//     importance: Importance.max,
//     priority: Priority.high,
//     playSound: UserPreferences.getSilentNotifications() == true ? true : false,
//     sound: RawResourceAndroidNotificationSound(sound.split('.').first),
//     ticker: 'ticker',
//     subText: subText,
//     icon: 'calendar',
//     largeIcon: FilePathAndroidBitmap(largeIcon),
//     ledOffMs: 300,
//     ledOnMs: 300,
//     ledColor: Colors.blue,
//     setAsGroupSummary: false,
//
//     // fullScreenIntent: false,
//     // groupKey: '1',
//     // groupAlertBehavior: GroupAlertBehavior.children,
//     // setAsGroupSummary: true,
//     // enableVibration: BusinessPreferences.getVibrateNotifications() == true && BusinessPreferences.getEnableNotifications() == true ? true : false,
//     enableVibration: false,
//     enableLights: true,
//     channelShowBadge: true,
//     // tag: 'Taggatolo',
//     // styleInformation: MediaStyleInformation(
//     //   htmlFormatContent: true,
//     //   htmlFormatTitle: false,
//     // ),
//     // styleInformation: bigPictureStyleInformation,
//     // vibrationPattern: Int64List(20000),//vibrazione non va
//     vibrationPattern: vibrationPattern,
//     visibility: NotificationVisibility.public,
//   );
//
//   var ios = IOSNotificationDetails(
//     sound: sound,
//     presentSound: true,
//     // presentSound: false,
//   );
//
//   final NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: ios
//   );
//
//   // await audioPlayer.setVolume(1.0);
//   // await audioPlayer.play();
//
//   await flutterLocalNotificationsPlugin.show(
//     // 0,
//     Random().nextInt(88887),
//     title,
//     // '@' + username,
//     // beginAt,
//     body,
//     platformChannelSpecifics,
//     payload: 'This is a demo app'
//   );
// }

// Future/*<void>*/ connectBackgroundSocket(String userId/*Socket socket*/) async {
//   await initializeDateFormatting();
//
//   SocketProvider socketProvider = SocketProvider();
//
//   Socket socket = io(
//     Utils.httpServerUrl + "",
//     OptionBuilder()
//       .setTransports(["websocket", "polling"])
//       .enableForceNewConnection()
//           // .disableForceNewConnection()
//           // .enableAutoConnect()
//       .disableAutoConnect()
//           .enableReconnection()
//       // .disableReconnection()
//           .enableForceNew()
//           // .disableForceNew()
//           .enableMultiplex()
//       // .disableMultiplex()
//           .build()
//   );
//
//   // Socket socket = io(Utils.httpServerUrl + "", <String, dynamic> {
//   //   "transports": ["websocket", "polling"],
//   //   "autoConnect": true,
//   //   "forceNew": true,
//   //   "reconnect": true,
//   //   // "hgygy": true
//   // });
//
//   // //print('socket.connected1');
//   // //print(socket.connected);
//   // if(!socket.connected) {
//     socket.connect();
//   // }
//   // //print('socket.connected2');
//   // //print(socket.connected);
//
//   // //print('socket.id');
//   // //print(socket.id);
//   // //print('socket.ids');
//   // //print(socket.ids);
//   // //print('socket.opts');
//   // //print(socket.opts);
//   // //print('socket.flags');
//   // //print(socket.flags);
//   // //print('socket.connected');
//   // //print(socket.connected);
//
//   /*await*/ socket.onConnect((data) /*async*/ {
//     // Utils.connectedSockets++;
//     // if(Utils.connectedSockets > 1) {
//     //   socket.dispose();
//     //   Utils.connectedSockets--;
//     // }
//     // //print('Utils.connectedSockets');
//     // //print(Utils.connectedSockets.toString());
//     // //print('socket.id background');
//     // //print(socket.id);
//     // //print('socket.id');
//     // //print(socket.id);
//     // //print('socket.ids');
//     // //print(socket.ids);
//     // //print('socket.opts');
//     // //print(socket.opts);
//     // //print('socket.flags');
//     // //print(socket.flags);
//     // //print('socket.connected');
//     // //print(socket.connected);
//     // //print('data');
//     // //print(data);
//
//     /*await*/ socket.onReconnectFailed((data) {
//       // //print('onReconnectFailed');
//     });
//
//     /*await*/ socket.onConnectError((data) {
//       // //print('onConnectError');
//     });
//
//     /*await*/ socket.onConnectTimeout((data) {
//       // //print('onConnectTimeout');
//     });
//
//     /*await*/ socket.onReconnectAttempt((data) {
//       // //print('onReconnectAttempt');
//     });
//
//     /*await*/ socket.onReconnectError((data) {
//       // //print('onReconnectError');
//     });
//
//     /*await*/ socket.onReconnect((data) {
//       // //print('onReconnect');
//     });
//
//     /*await*/ socket.onConnecting((data) {
//       // //print('onConnecting');
//     });
//
//     /*await*/ socket.onReconnecting((data) {
//       // //print('onReconnecting');
//     });
//
//     /*await*/ socket.onError((data) {
//       // //print('onError');
//     });
//
//     /*await*/ socket.onDisconnect((data) {
//       // socket.destroy();
//       // socket.disconnect();
//       // socket.close();
//       // socket.dispose();
//       // //print('onDisconnect');
//     });
//
//     socket.emit(
//         "join-notification",
//         {
//           "user_id": userId
//         }
//     );
//
//     socket.on(
//       "cancel_business_appointment_notification",
//       (appointment) async {
//         // //print('appointment business cancel');
//         // //print(appointment);
//         // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//
//         // streamController.sink.add(appointment.toString());
//         streamController.sink.add(appointment);
//
//         socketProvider.setIsCanceledBooking(appointment['appointment_id'].toString());
//
//         // Map<String, dynamic> values = {
//         //   "booking_id": appointment['appointment_id'],
//         //   'booking_price': appointment['prestazione_price'],
//         //   "booking_begin_at": appointment['begin_at'],
//         //   "prestazione_id": appointment['prestazione_id'],
//         //   'prestazione_image': appointment['prestazione_image'],
//         //   'prestazione_title': appointment['prestazione_title'],
//         //   'is_canceled': 1,
//         //   'business_id': appointment['business_id'],
//         //   'business_name': appointment['business_name'],
//         //   'created_at': DateTime.now().toString(),
//         // };
//         //
//         // await socketProvider.insertNotification(
//         //     'appointment_notification',
//         //     values
//         // );
//
//         await _showNotification(
//           // senderUsername: 'meeee',
//           subText: 'Cancellazione',
//           // subText: '@' + appointment['username'],
//           body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(appointment['begin_at']).toLocal()).toString()
//               + ' alle ' + DateTime.parse(appointment['begin_at']).toLocal().toString().substring(11, 16),
//           // note: appointment['note'],
//           // senderUsername: appointment['username'],
//           // senderName: appointment['name'] ?? '',
//           title: appointment['prestazione_title'],
//           // prestazioneImage: appointment['prestazione_image'],
//           largeIconPath: appointment['business_profile_image'],
//         );
//
//         // exit(0);
//
//       },
//     );
//
//     // socket.on('broad', (data) async {
//     //   //print('broad background 007');
//     //   //print(data.toString());
//     //   await _showNotification();
//     // });
//
//     socket.on('remove_background_user_socket', (data) {
//       // //print(data.toString());
//       // //print('background dd socket.id');
//       // //print(socket.id);
//
//       //o faccio l'emit per rimuoverlo serverside o lo disconnect() da qui
//     });
//
//     // return socket;
//   });
//
// }

// Future<void> initializeService(/*{Function() function, Socket socket}*/) async {
//   final service = FlutterBackgroundService();
//   // service = FlutterBackgroundService();
//   await UserPreferences.init();
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//       // onStart: function,
//       // onStart: () => onStart(function: function),
//       // onStart: onStart(function: function),
//       // onStart: await onStart(socket: socket),
//
//       // auto start service
//       // autoStart: true,
//       // autoStart: false,
//       autoStart: UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null && UserPreferences.getEnableNotifications()! /*&& UserPreferences.getBackgroundNotifications()*/,
//       // isForegroundMode: true,
//       isForegroundMode: UserPreferences.getBackgroundNotifications()!,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       // autoStart: true,
//       // autoStart: false,
//       autoStart: UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null && UserPreferences.getEnableNotifications()! /*&& UserPreferences.getBackgroundNotifications()*/,
//
//       // this will executed when app is in foreground in separated isolate
//       onForeground: onStart,
//       // onForeground: function,
//       // onForeground: () => onStart(function: function),
//       // onForeground: onStart(function: function),
//       //   onForeground: await onStart(socket: socket),
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
// }

// // to ensure this executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
// // void onIosBackground() {
// bool onIosBackground(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   // //print('FLUTTER BACKGROUND FETCH');
//   return true;
// }

// // Future<void> /*Future<Function>*/ onStart(/*String userId*//*{Function() function*//*, Socket socket*//*}*/) async {
// void onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//
//   User? user = await getUser();
//   // final service = FlutterBackgroundService();
//
//   // service.onDataReceived.listen((event) {
//   //   if (event/*!*/["action"] == "setAsForeground") {
//   //     service.setForegroundMode(true);
//   //     return;
//   //   }
//   //
//   //   if (event["action"] == "setAsBackground") {
//   //     service.setForegroundMode(false);
//   //   }
//   //
//   //   if (event["action"] == "stopService") {
//   //     // g
//   //     service.stopBackgroundService();
//   //   }
//   //
//   //   // if (event["action"] == "printSocket") {
//   //   //   //print('sock.id kkkk');
//   //   // }
//   // });
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // bring to foreground
//   // service.setForegroundMode(true);
//
//
//   // service.setNotificationInfo(
//   //   // title: "Estetica Elixir",
//   //   title: user.username,
//   //   // content: "Upbookingd at ${DateTime.now()}",
//   //   content: "Notifiche Attive",
//   // );
//
//   if(service is AndroidServiceInstance) {
//     service.setForegroundNotificationInfo(
//       // title: "Estetica Elixir",
//       title: user!.email!,
//       // content: "Upbookingd at ${DateTime.now()}",
//       content: user.username!,
//     );
//
//     // service.setAsBackgroundService();
//   }
//
//   // await connectBackgroundSocket(user.id/*socket*/);
//
// }

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

Future/*<void>*/ connect(String userId/*Socket socket*/) async {
  var chatList;

  await initializeDateFormatting();

  // Socket socket = io(Utils.httpServerUrl + "", <String, dynamic> {
  //   "transports": ["websocket"],
  //   "autoConnect": false,
  // });
  // // 'forceNew': true,
  //
  // chatList = await getAllUserChat(userId);
  //
  // // Connect Socketio manually
  // socket.connect();
  //
  // /*await*/ socket.onConnect((data) {
  //   //print('socket.connected background service');
  //   //print(socket.connected);
  //
  //   //print('chatList');
  //   //print(chatList);
  //   for(var chat in chatList){
  //     //print("chat['id']");
  //     //print(chat['id']);
  //     socket.emit(
  //         "join-chat",
  //         {
  //           "id": chat['id']
  //         }
  //     );
  //   }
  //
  //   /*for(var chat in chatRooms){
  //     //print("chat.single_event.id");
  //     //print(chat.single_event.id.toString());
  //     socket.emit(
  //         "join-chat_room",
  //         {
  //           "id": chat.single_event.id.toString()
  //         }
  //     );
  //   }*/
  // });
  //
  // socket.emit(
  //     "join-notification",
  //     {
  //       "user_id": userId
  //     }
  // );
  //
  // socket.on(
  //   "receive-message",
  //       (msg) {
  //     //print('msg background 007');
  //     //print(msg);
  //     _showNotification(
  //         title: msg['senderUsername'],
  //         largeIconPath: msg['senderProfileImage'],
  //         body: msg['content'],
  //         senderId: msg['senderId']
  //     );
  //   },
  // );
  //
  // socket.on(
  //   "cancel_business_appointment_notification",
  //       (appointment) async {
  //     //print('appointment business cancel');
  //     //print(appointment);
  //
  //     // //print('socket.id background');
  //     // //print(socket.id);
  //
  //     // if(BusinessPreferences.getEnableNotifications() == true){
  //     await _showNotification(
  //       // text: 'tiesto',
  //       // senderUsername: 'meeee',
  //       subText: 'Cancellazione',
  //       // subText: '@' + appointment['username'],
  //       body: DateFormat.yMMMMd('it_IT').format(DateTime.parse(appointment['begin_at'])).toString()
  //           + ' alle ' + appointment['begin_at'].substring(11, 16),
  //       // note: appointment['note'],
  //       // senderUsername: appointment['username'],
  //       // senderName: appointment['name'] ?? '',
  //       title: appointment['prestazione_title'],
  //       // prestazioneImage: appointment['prestazione_image'],
  //       largeIconPath: appointment['business_profile_image'],
  //     );
  //   },
  // );
  //
  // // socket.on('broad', (data) async {
  // //   //print('broad background 007');
  // //   //print(data.toString());
  // //   await _showNotification();
  // // });
}

// /*Future<void>*/ Future<Function> onStart(/*String userId*/{Function() function/*, Socket socket*/}) async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // var jsonData = await getUser();
//   User user = await getUser();
//
//   final service = FlutterBackgroundService();
//
//   // service.setNotificationInfo(
//   //   // title: "My App Service",
//   //   title: "Estetica Elixir",
//   //   // content: "Updated at ${DateTime.now()}",
//   //   content: "Notifiche Attive",
//   // );
//
//   service.onDataReceived.listen((event) {
//     if (event/*!*/["action"] == "setAsForeground") {
//       service.setForegroundMode(true);
//       return;
//     }
//
//     if (event["action"] == "setAsBackground") {
//       service.setForegroundMode(false);
//     }
//
//     if (event["action"] == "stopService") {
//       service.stopBackgroundService();
//     }
//   });
//
//   // bring to foreground
//   // service.setForegroundMode(true);
//   service.setForegroundMode(false);
//
//   // Timer.periodic(const Duration(seconds: 1), (timer) async {
//   //   if (!(await service.isServiceRunning())) timer.cancel();
//   service.setNotificationInfo(
//     // title: "Estetica Elixir",
//     title: user.username,
//     // content: "Updated at ${DateTime.now()}",
//     content: user.name,
//   );
//
//   connect(user.id/*socket*/);
//   // await function;
//   // return;
// }
//
// // to ensure this executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
// void onIosBackground() {
//   WidgetsFlutterBinding.ensureInitialized();
//   //print('FLUTTER BACKGROUND FETCH');
// }
//
// Future<void> initializeService({Function() function, Socket socket}) async {
//   final service = FlutterBackgroundService();
//   // service = FlutterBackgroundService();
//   await UserPreferences.init();
//   // /*User */user = await getUser();
//
//   if(UserPreferences.getBackgroundNotifications() == null){
//     await UserPreferences.setBackgroundNotifications(true);
//   }
//   if(UserPreferences.getEnableNotifications() == null){
//     await UserPreferences.setEnableNotifications(true);
//   }
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//       // onStart: function,
//       // onStart: () => onStart(function: function),
//       // onStart: onStart(function: function),
//       // onStart: await onStart(socket: socket),
//
//       // auto start service
//       // autoStart: true,
//       // autoStart: false,
//       autoStart: UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null && UserPreferences.getEnableNotifications() && UserPreferences.getBackgroundNotifications(),
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       // autoStart: true,
//       // autoStart: false,
//       autoStart: UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null && UserPreferences.getEnableNotifications() && UserPreferences.getBackgroundNotifications(),
//
//       // this will executed when app is in foreground in separated isolate
//       onForeground: onStart,
//       // onForeground: function,
//       // onForeground: () => onStart(function: function),
//       // onForeground: onStart(function: function),
//       //   onForeground: await onStart(socket: socket),
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
// }

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'fcm_nurebo_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          // icon: 'calendar_1',
          // icon: 'calendar',
          icon: 'android12splash',
        ),
      ),
    );
  }
}

Future<void> bottomSheetNotLogged(BuildContext context) async {
  await showModalBottomSheet<int>(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Popover(
        child: Column(
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                // await Navigator.pushAndRemoveUntil(
                //   context,
                //   PageTransition(
                //     child: LoginScreen(),
                //     duration: const Duration(milliseconds: 800),
                //     type: PageTransitionType.fade,
                //   ),
                //   (route) => false
                // );

                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  PageTransition(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    child: LoginScreen(),
                  ),
                );

                //print("Elimina reazione");
                // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                // btn2(context);
              },
              child: Container(
                child: ListTile(
                  title: Text(
                    'Accedi',
                    style: TextStyle(
                      // color: Colors.grey[800]
                        color: Colors.blue[500]
                    ),
                  ),
                  leading: Icon(
                    // Icons.person,
                      Icons.login_outlined,
                      color: Colors.blue[400]
                    // color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                // await Navigator.pushAndRemoveUntil(
                //   context,
                //   PageTransition(
                //     child: LoginScreen(),
                //     duration: const Duration(milliseconds: 800),
                //     type: PageTransitionType.fade,
                //   ),
                //   (route) => false
                // );

                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  PageTransition(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    child: const RegisterScreen(),
                  ),
                );

                //print("Elimina reazione");
                // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                // btn2(context);
              },
              child: Container(
                child: ListTile(
                  title: Text(
                    'Registrati',
                    style: TextStyle(
                      // color: Colors.grey[800]
                        color: Colors.blue[500]
                    ),
                  ),
                  leading: Icon(
                    // Icons.person,
                      Icons.how_to_reg_outlined,
                      color: Colors.blue[400]
                    // color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> bottomSheetOptions(BuildContext context) async {
  SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  // socketProvider.setBottomBarVisibility(false);

  await showModalBottomSheet<int>(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Popover(
        child: Column(
          children: [
            // SettingsTile.switchTile(
            //   title: 'Lock app in background',
            //   leading: Icon(Icons.phonelink_lock),
            //   switchValue: lockInBackground,
            //   onToggle: (bool value) {
            //     setState(() {
            //       lockInBackground = value;
            //       notificationsEnabled = value;
            //     });
            //   },
            // ),
            // SwitchListTile(
            //   // contentPadding: EdgeInsets.all(15),
            //   title: Text("Gluten Free",style: TextStyle(
            //       color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,
            //       fontSize: 20
            //   ),
            //   ),
            //   subtitle: Text("Includes Only Gluten Free Dishes"),
            //   value: filterValues["gluten"], onChanged: (value) {
            //   setState(() {
            //     filterValues["gluten"]=value;
            //   });
            // },),
            Visibility(
              visible: Utils.isBusiness && !UserPreferences.getIsLogged()!,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  // await Navigator.pushAndRemoveUntil(
                  //   context,
                  //   PageTransition(
                  //     child: LoginScreen(),
                  //     duration: const Duration(milliseconds: 800),
                  //     type: PageTransitionType.fade,
                  //   ),
                  //   (route) => false
                  // );

                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageTransition(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.center,
                      type: PageTransitionType.fade,
                      child: LoginScreen(),
                    ),
                  );

                  //print("Elimina reazione");
                  // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                  // btn2(context);
                },
                child: Container(
                  child: ListTile(
                    title: Text(
                      'Accedi o Registrati',
                      style: TextStyle(
                        // color: Colors.grey[800]
                          color: Colors.blue[500]
                      ),
                    ),
                    leading: Icon(
                      // Icons.person,
                        Icons.login_outlined,
                        color: Colors.blue[400]
                      // color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: Utils.isBusiness,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (){
                  if(UserPreferences.getIsLogged()!) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: NotificationsScreen(),
                      ),
                    );
                    // Navigator.of(context).pop();
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: 'Accedi per poter accedere a questa schermata',
                      backgroundColor: Colors.grey[700],
                    );
                  }

                  //print("Elimina reazione");
                  // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                  // btn2(context);
                },
                child: Container(
                  child: ListTile(
                    title: Text("Notifiche"),
                    leading: Icon(Icons.notifications_none_rounded, size: 26),
                  ),
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: (){
                if(UserPreferences.getIsLogged()!) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: UserFriendsListScreen(
                          // userFriends: /*socketProvider.userFriendsList*/[],
                          // user: Utils.user!,
                        )
                    ),
                  );
                  // Navigator.of(context).pop();
                }
                else {
                  Fluttertoast.showToast(
                    msg: 'Accedi per poter accedere a questa schermata',
                    backgroundColor: Colors.grey[700],
                  );
                }

                //print("Elimina reazione");
                // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                // btn2(context);
              },
              child: Container(
                child: ListTile(
                  title: Text("Amici"),
                  // contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * .04),
                  // dense: true,
                  // leading: Icon(Icons.favorite_border_rounded),
                  leading: Icon(
                    Icons.groups_outlined,
                    size: 27,
                  ),
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: (){
                if(UserPreferences.getIsLogged()!) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: FavoritesScreen()
                    ),
                  );
                  // Navigator.of(context).pop();
                }
                else {
                  Fluttertoast.showToast(
                    msg: 'Accedi per poter accedere a questa schermata',
                    backgroundColor: Colors.grey[700],
                  );
                }

                //print("Elimina reazione");
                // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                // btn2(context);
              },
              child: Container(
                child: ListTile(
                  title: Text("Prestazioni Preferite"),
                  // contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * .04),
                  // dense: true,
                  // leading: Icon(Icons.favorite_border_rounded),
                  leading: Icon(
                    Icons.star_outline,
                    size: 27,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !Utils.isBusiness,
              child: GestureDetector(
                onTap: (){
                  if(UserPreferences.getIsLogged()!) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: SavedBusinessScreen()
                      ),
                    );
                    // Navigator.of(context).pop();
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: 'Accedi per poter accedere a questa schermata',
                      backgroundColor: Colors.grey[700],
                    );
                  }
                },
                child: Container(
                  child: ListTile(
                    title: Text("Locali Seguiti"),
                    // contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * .04),
                    // dense: true,
                    // leading: Icon(Icons.favorite_border_rounded),
                    leading: Icon(
                      Icons.bookmark_outline,
                      size: 27,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: (){
                if(UserPreferences.getIsLogged()!) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: PostLikedScreen(
                          // user: widget.user,
                          user: Utils.user,
                        )
                    ),
                  );
                  // Navigator.of(context).pop();
                }
                else {
                  Fluttertoast.showToast(
                    msg: 'Accedi per poter accedere a questa schermata',
                    backgroundColor: Colors.grey[700],
                  );
                }

                //print("Elimina reazione");
                // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
                // btn2(context);
              },
              child: Container(
                child: ListTile(
                  title: Text("Post Piaciuti"),
                  leading: Icon(Icons.favorite_border_rounded),
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: (){
            //     if(UserPreferences.getIsLogged()!) {
            //       Navigator.of(context).pop();
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: UserBookingsScreen(
            //               // user: widget.user,
            //               user: Utils.user,
            //             )
            //         ),
            //       );
            //       // Navigator.of(context).pop();
            //     }
            //     else {
            //       Fluttertoast.showToast(
            //         msg: 'Accedi per poter accedere a questa schermata',
            //         backgroundColor: Colors.grey[700],
            //       );
            //     }
            //   },
            //   child: Container(
            //     child: ListTile(
            //       title: Text("Prenotazioni"),
            //       leading: Icon(Icons.event_note_outlined),
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: (){
                if(UserPreferences.getIsLogged()!){
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: SettingsScreen()
                    ),
                  );
                  // Navigator.of(context).pop();
                }
                else {
                  Fluttertoast.showToast(
                    msg: 'Accedi per poter accedere a questa schermata',
                    backgroundColor: Colors.grey[700],
                  );
                }
              },
              child: Container(
                child: ListTile(
                  title: Text("Impostazioni"),
                  leading: Icon(Icons.settings_outlined),
                ),
              ),
            ),
            Visibility(
              visible: /*Utils.isBusiness*/false,
              child: GestureDetector(
                onTap: (){
                  // Navigator.of(context).pop();
                  // LaunchReview.launch(
                  //   androidAppId: "com.nurebo.nurebo",
                  //   // iOSAppId: "585027354",
                  //   writeReview: false,
                  // );
                },
                child: Container(
                  child: ListTile(
                    title: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.012),
                          child: Text(
                            "Scarica",
                            style: TextStyle(
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Text(
                          // 'Admin',
                          'nurebo',
                          style: TextStyle(
                              color: Colors.orange,
                              // fontWeight: FontWeight.w600,
                              fontSize: 35,
                              letterSpacing: -2.3,
                              fontFamily: 'Panton',
                              fontWeight: FontWeight.w700
                          ),
                        )
                      ],
                    ),
                    leading: Icon(Icons.download_outlined),
                  ),
                ),
              ),
            ),
            // InkWell(
            //   onTap: (){
            //     //print("Elimina reazione");
            //     Navigator.of(context).pop();
            //     // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
            //     // btn2(context);
            //   },
            //   child: Container(
            //     child: ListTile(
            //       title: Text("Esci"),
            //       leading: Icon(Icons.circle_outlined),
            //     ),
            //   ),
            // ),
            // btn1(context),
            // SettingsTile.switchTile(
            //   title: 'Silenzia',
            //   enabled: true,
            //
            //   leading: Icon(Icons.airline_seat_individual_suite_outlined),
            //   switchValue: false,
            //   onToggle: (value) {
            //     setState(() {
            //       // lockInBackground = value;
            //       // notificationsEnabled = value;
            //     });
            //     value = true;
            //   },
            // ),

            // GestureDetector(
            //   onTap: (){
            //
            //   },
            //   child: Container(
            //     child: ListTile(
            //       title: Text("Limita"),
            //       leading: Icon(Icons.account_box_outlined),
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: (){
            //
            //   },
            //   child: Container(
            //     child: ListTile(
            //       title: Text("Blocca"),
            //       leading: Icon(Icons.admin_panel_settings_outlined),
            //     ),
            //   ),
            // ),
            // SettingsTile.switchTile(
            //   title: 'Notifiche',
            //   enabled: true,
            //
            //   leading: Icon(Icons.notifications_active_outlined),
            //   switchValue: false,
            //   onToggle: (value) {
            //     setState(() {
            //       lockInBackground = value;
            //       notificationsEnabled = value;
            //     });
            //     value = true;
            //   },
            //
            // ),
            // SettingsTile.switchTile(
            //   title: 'Post',
            //   leading: Icon(Icons.panorama_outlined),
            //   switchValue: lockInBackground,
            //   onToggle: (bool value) {
            //     setState(() {
            //       lockInBackground = value;
            //       // notificationsEnabled = value;
            //     });
            //   },
            // ),
            // SettingsTile.switchTile(
            //     title: 'Storie',
            //     // subtitle: 'Allow application to access stored fingerprint IDs.',
            //     leading: Icon(Icons.all_inclusive_outlined),
            //     onToggle: (bool value) {},
            //     switchValue: false
            // ),
            // SwitchListTile(
            //   value: true,
            //   // value: context.watch<PostCreateViewModel>().isShareFacebook,
            //   onChanged: (value) {
            //     if(value == true)
            //       value = false;
            //     else value = true;
            //     // context.read<PostCreateViewModel>().enableSocialShare(SocialShare.FACEBOOK, value);
            //   },
            //   title: Text('Facebook'),
            // ),
            // _buildListItem(
            //   context,
            //   title: Text('Total Task'),
            //   leading: Icon(
            //     Icons.check_circle_outline,
            //     color: Colors.black,
            //   ),
            //   trailing: Switch(
            //     value: true,
            //     onChanged: (value) {},
            //   ),
            // ),
            // _buildListItem(
            //   context,
            //   title: Text('Due Soon'),
            //   leading: Icon(Icons.inbox),
            //   trailing: Switch(
            //     value: false,
            //     onChanged: (value) {},
            //   ),
            // ),
            // _buildListItem(
            //   context,
            //   title: Text('Completed'),
            //   leading: Icon(Icons.check_circle),
            //   trailing: Switch(
            //     value: false,
            //     onChanged: (value) {},
            //   ),
            // ),
            // _buildListItem(
            //   context,
            //   title: Text('Working On'),
            //   leading: Icon(Icons.flag),
            //   trailing: Switch(
            //     value: false,
            //     onChanged: (value) {},
            //   ),
            // ),
          ],
        ),
      );
    },
  );

  // socketProvider.setBottomBarVisibility(true);
}

Future getIpLocation(String? ip) async {
  var url = Uri.parse("http://ip-api.com/json/$ip");

  var response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
      }
  );

  if(response.statusCode >= 200 && response.statusCode < 400) {
    var jsonData = json.decode(response.body);
    //print("iplocation: ");
    //print(jsonData);
    return jsonData;
  }
}

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
//     //print('ip location:');
//     //print(ipLocation);
//     // return jsonData;
//     return ipLocation;
//   }
// }
Future getIp() async {
  var url = Uri.parse("https://api.ipify.org?format=json");

  try {
    var response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
      },
    ).timeout(Duration(seconds: 5)); // Imposta il timeout a 5 secondi

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      var ipLocation = await getIpLocation(jsonData['ip']);

      // print(jsonData);
      // print('ipLocation44477');
      // print(ipLocation);

      Utils.ipLongitude = ipLocation['lon'];
      Utils.ipLatitude = ipLocation['lat'];

      // print('Utils.ipLongitude');
      // print(Utils.ipLongitude);
      // print('Utils.ipLatitude');
      // print(Utils.ipLatitude);

      return ipLocation;
    }
    else {
      // Gestisci il caso in cui la richiesta non abbia avuto successo
      print("Errore: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    // Gestisci il caso in cui la richiesta abbia superato il timeout o abbia fallito
    print("Errore: $e");
    return null;
  }
}

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await setupFlutterNotifications();
  // showFlutterNotification(message);

  /*await UserPreferences.init();
  final player = AudioPlayer();
  var sound;

  // if(subText == 'Cancellazione'){
  //   sound = 'my_work_is_done_message_tone.ogg';
  //   await player.setAsset('assets/audio/my_work_is_done_message_tone.ogg');
  // }
  // else {
    sound = 'piece_of_cake_611.mp3';
    await player.setAsset('assets/audio/piece_of_cake_611.ogg');
  // }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: null
  );

  final Int64List vibrationPattern = Int64List(2);

  if(UserPreferences.getSilentNotifications() == false
      && UserPreferences.getEnableNotifications() == true) {
    // audioPlayer.play();
    player.play();
  }

  if(UserPreferences.getVibrateNotifications() == true
      && UserPreferences.getEnableNotifications() == true){
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
  }

  // final String bigPicturePath = await _downloadAndSaveFile(
  //   // 'https://via.placeholder.com/400x800',
  //     prestazioneImage,
  //     'bigPicture'
  // );
  // final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
  //     FilePathAndroidBitmap(largeIconPath),
  //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
  //     contentTitle: '$prestazioneTitle',
  //     htmlFormatContentTitle: true,
  //     summaryText: "<p>@$username</p>",
  //     htmlFormatSummaryText: true
  // );

  final String largeIcon = await _downloadAndSaveFile(
    'https://via.placeholder.com/48x48',
    //   imageProfile,
    //   largeIconPath,
      'largeIcon'
  );

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'fcm_nurebo_channel', 'fcm_nurebo_channel', //'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: UserPreferences.getSilentNotifications() == true ? true : false,
    // sound: RawResourceAndroidNotificationSound(sound.split('.').first),
    ticker: 'ticker',
    // subText: subText,
    icon: 'calendar',
    largeIcon: FilePathAndroidBitmap(largeIcon),

    ledOffMs: 300,
    ledOnMs: 300,
    ledColor: Colors.blue,

    // fullScreenIntent: false,
    // groupKey: '1',
    // groupAlertBehavior: GroupAlertBehavior.children,
    // setAsGroupSummary: true,
    // enableVibration: BusinessPreferences.getVibrateNotifications() == true && BusinessPreferences.getEnableNotifications() == true ? true : false,
    enableVibration: false,
    enableLights: true,
    channelShowBadge: true,
    // tag: 'Taggatolo',
    // styleInformation: MediaStyleInformation(
    //   htmlFormatContent: true,
    //   htmlFormatTitle: false,
    // ),
    // styleInformation: bigPictureStyleInformation,
    // vibrationPattern: Int64List(20000),//vibrazione non va
    vibrationPattern: vibrationPattern,
    visibility: NotificationVisibility.public,
  );

  var ios = IOSNotificationDetails(
    sound: sound,
    presentSound: true,
    // presentSound: false,
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: ios
  );

  // await audioPlayer.setVolume(1.0);
  // await audioPlayer.play();

  await flutterLocalNotificationsPlugin.show(
    // 0,
      Random().nextInt(88887),
      message.notification?.title ?? '',
      // '@' + username,
      // beginAt,
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: 'This is a demo app'
  );*/
  // showNotification(
  //   // id: 1,
  //   title: message.notification?.title ?? '',
  //   body: message.notification?.body ?? '',
  //   // payload: message.notification?.title ?? ''
  // );

  //print(message.data.toString());
  //print(message.notification!.title);
  // FlutterAppBadger.updateBadgeCount(1);
}

Future<void> main() async {
  // print('DateTime.now()1');
  // print(DateTime.now());
  dateTime1 = DateTime.now();
  // print('DateTime.now().toIso8601String()1');
  // print(dateTime1!.toIso8601String());

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // BackgroundIsolateBinaryMessenger.ensureInitialized(ServicesBinding.rootIsolateToken!);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top
      ]
  );

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // HttpOverrides.global = MyHttpOverrides();
  ByteData byteData = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(byteData.buffer.asUint8List());

  // await initializeService();

  // FlutterAppBadger.removeBadge();

  FCMNotificationHelper.registerNotification();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform
  // );
  // /*String*/ deviceToken = await FirebaseMessaging.instance.getToken();
  // //print('deviceToken');
  // //print(deviceToken);
  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // await FirebaseMessaging.instance.requestPermission(
  //   alert: true,
  //   announcement: true,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  // isFlutterLocalNotificationsInitialized = true;
  // await setupFlutterNotifications();
  // FirebaseMessaging.instance.getInitialMessage().then((message) {
  //   if (message != null) {
  //     //print('************ getInitialMessage *****************');
  //     Fluttertoast.showToast(msg: message.notification?.body ?? '');
  //   }
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   //   //print('new messages on opened app');
  //   // showNotification(
  //   //     // id: 1,
  //   //     title: message.notification?.title ?? '',
  //   //     body: 'It is from onMessageOpenedApp',
  //   //     // payload: message.notification?.title ?? '');
  //   //   // Parse the message received
  //   // );
  //   // //print(message.notification?.title ?? '');
  //   // Fluttertoast.showToast(msg: message.notification?.body ?? '');
  //   // Navigator.push(
  //   //   context,
  //   //   PageTransition(
  //   //     duration: const Duration(milliseconds: 500),
  //   //     alignment: Alignment.center,
  //   //     type: PageTransitionType.fade,
  //   //     child: const ExploreScreen()
  //   //   )
  //   // );
  //   Navigator.pushNamed(
  //     context,
  //     '/message',
  //     arguments: MessageArguments(message, true),
  //   );
  // });
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   showNotification(
  //       // id: 1,
  //       title: message.notification?.title ?? '',
  //       body: message.notification?.body ?? '',
  //       // payload: message.notification?.title ?? ''
  //     );
  // });
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);


  await UserPreferences.init();

  // await AndroidAlarmManager.initialize();

  if(Utils.isBusiness) {
    await getBusiness();
    await getBusinessChatRoom(Utils.business_id);
  }

  // if(UserPreferences.getIsLogged()!){
    try {
      await getUser();
    // } catch (e) {
    } on TimeoutException catch (e) {
      isServerDown = true;
      print('un dio che prima fosse un cane');
      // print(e);
    }
  // }

  try {
    await getIp();
  } catch (e) {
    // print('un dio che prima fosse un cane');
    // print(e);
  }

  //todo: mettere lo screen per forzare l'aggiornamento
  // /*await*/ InAppUpdate.checkForUpdate().then((info) async {
  //   // setState(() {
  //   //   _updateInfo = info;
  //   // });
  //   // //print('info.availableVersionCode');
  //   // //print(info.availableVersionCode);
  //   // //print('info.updateAvailability');
  //   // //print(info.updateAvailability);
  //   // //print('info.packageName');
  //   // //print(info.packageName);
  //   // //print('info.installStatus');
  //   // //print(info.installStatus);
  //   // //print('info.clientVersionStalenessDays');
  //   // //print(info.clientVersionStalenessDays);
  //
  //   /*await*/ InAppUpdate.performImmediateUpdate().catchError((e) {
  //     Fluttertoast.showToast(
  //       msg: 'Errore',
  //       backgroundColor: Colors.grey[700],
  //     );
  //   });
  // }).catchError((e) {
  //   Fluttertoast.showToast(
  //     msg: 'Errore',
  //     backgroundColor: Colors.grey[700],
  //   );
  // });

  runApp(
     /*Phoenix(
      child:*/ MultiProvider(
        providers: [
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => UserProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => GeolocationProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => CartProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => ChatProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => SocketProvider(),
          ),
          StreamProvider(
            // child: MyApp(),
            create: (_) => streamController.stream, initialData: 'null',
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => PrestazioneFavoriteProvider(),
          ),
          // ChangeNotifierProvider(
          //   // child: MyApp(),
          //   create: (_) => PostFavoriteProvider(),
          // ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => BusinessFavoriteProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => PostProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => BusinessProvider(),
          ),
          ChangeNotifierProvider(
            // child: MyApp(),
            create: (_) => NotificationProvider(),
          ),
        ],
        child: const NureboApp(),
      ),
    // ),
  );

  // packageInfo = await PackageInfo.fromPlatform();
}

class NureboApp extends StatefulWidget {
  const NureboApp({super.key});

  @override
  State<NureboApp> createState() => _NureboAppState();
}

class _NureboAppState extends State<NureboApp> with WidgetsBindingObserver {
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  late PrestazioneFavoriteProvider favoriteProvider;
  // late PostFavoriteProvider postFavoriteProvider;
  late BusinessFavoriteProvider businessFavoriteProvider;
  late BusinessProvider businessProvider;
  late PostProvider postProvider;
  // GeolocationProvider? geolocationProvider;
  late GeolocationProvider geolocationProvider;
  Future a = Future((){}), b = Future((){});
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FlutterBackgroundService().sendData({"action": "stopService"},);
    // Future.wait([
    //     initializeService()
    // ]).then((value) => Future.wait([
    //   FlutterBackgroundService().start()
    // ]));

    // if(UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null && UserPreferences.getEnableNotifications() /*&& UserPreferences.getBackgroundNotifications()*/){
    //   // FlutterBackgroundService().sendData({"action": "stopService"},);
    //   FlutterBackgroundService().invoke("stopService");
    //   Future.wait([
    //     // FlutterBackgroundService().start()
    //     FlutterBackgroundService().startService()
    //   ]);
    // }

    // FCMNotificationHelper.registerNotification(context);
    /*FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        //print('************ getInitialMessage *****************');
        Fluttertoast.showToast(msg: message.notification?.body ?? '');
        // Navigator.push(
        //     context,
        //     PageTransition(
        //         duration: const Duration(milliseconds: 500),
        //         alignment: Alignment.center,
        //         type: PageTransitionType.fade,
        //         // child: const ExploreScreen()
        //         child: const PostScreen()
        //     )
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const NewsScreen(),
              fullscreenDialog: true,
              // settings: RouteSettings(
              //
              // )
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //   //print('new messages on opened app');
      // //print(message.notification?.title ?? '');
      // Fluttertoast.showToast(msg: message.notification?.body ?? '');
      Navigator.push(
        context,
        PageTransition(
          duration: const Duration(milliseconds: 500),
          alignment: Alignment.center,
          type: PageTransitionType.fade,
          // child: const ExploreScreen()
          child: const PostScreen()
        )
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const NewsScreen(),
            fullscreenDialog: true,
            settings: RouteSettings(

            )
        ),
      );
      Navigator.pushNamed(
        context,
        '/explore_screen',
        // arguments: MessageArguments(message, true),
      );
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        // id: 1,
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        // payload: message.notification?.title ?? ''
        context: context
      );
    });*/

    // FCMNotificationHelper.registerNotification(context);

    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    // postFavoriteProvider = Provider.of<PostFavoriteProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);

    Future.wait([
      initializeDateFormatting(),
      initPlatformState(),
      // getBusiness(),
    ]);

    // _tabController = TabController(vsync: this, length: 2);
    // _scrollController = ScrollController();

    // getAllSingleEvent();
    // getAllRecommendedPrestazione();

    // getAllCategories()
    // // .then((value) => getAllDateCategories())
    //     .then((value) => categoryList.sort((a, b) {
    //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    // })
    // );

    // Future.wait([
    //   // a = getAllSingleEvent(),
    //   b = getAllRecommendedPrestazione(),
    //   c = getAllCategories(),
    //   d = getBestsellers(),
    //   initPlatformState(),
    // ]).then((value) async {
    //   categoryList.sort((a, b) {
    //     return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    //   });
    //
    //   await geolocationProvider.getGeolocationPermission();
    // });
    if(UserPreferences.getIsLogged()!) {
      /*fa = */getUser().then((value) async {
        // foundation.compute((_) => getUser, []).then((value) async {
        // await geolocationProvider.getGeolocationPermission(context);

        print('value5555');
        print(value);
        if(value != null) {
          userProvider.setUser(value);

          // socketProvider.connectSocketProvider(userProvider.user);

          // socketProvider.context = this.context;

          Future.wait([
            socketProvider.getUnseenBusinessUserNotifications(userProvider.user!),
            // socketProvider.getUnseenUserFriendshipNotifications(userProvider.user!),
            // socketProvider.getUserFriendshipRequests(),
            socketProvider.getUserFriends(),
            // connectBackgroundSocket(userProvider.user.id/*socket*/)
            socketProvider.getUserAppointments(userProvider.user!),
            socketProvider.getUserEventReservations(userProvider.user!),
            socketProvider.getAllBusinessChatRoom(),
            socketProvider.updateFcmToken(userProvider.user!),
            socketProvider.insertDevice(userProvider.user!, _deviceData),
            favoriteProvider.getUserEventFavorites(userProvider.user!),
            // postFavoriteProvider.getBusinessPostFavorites(userProvider.user!),
            socketProvider.getAllChatRooms(userId: userProvider.user!.id),
            favoriteProvider.getUserPrestazioneFavorites(userProvider.user!),
            businessFavoriteProvider.getUserSavedBusiness(userProvider.user!),

            // geolocationProvider.putUserLocation(geolocationProvider.position!.latitude, geolocationProvider.position!.longitude, context),
            // geolocationProvider.getGeolocationPermission(context),

            // postProvider.getAllBusinessPosts(),
            postProvider.getAllPostLikes(),
            postProvider.getUserBusinessPostFavorites(Utils.user!),

            // socketProvider.startSession(userProvider.user!, (await getIp()) ?? <String, dynamic>{}),

            // socketProvider.getAllUserChat(userProvider.user.id),

            // socketProvider.getDateNotifications(),
            // socketProvider.connectSocketProvider(userProvider.user)
          ]).then((value) async {
            // geolocationProvider.getGeolocationPermission(context).then((v){
              postProvider.getAllBusinessesPosts(context);
            // });

            if(UserPreferences.getIsLogged()!) {
              () async {
                await socketProvider.startSession(userProvider.user!, (await getIp()) ?? <String, dynamic>{});

                await socketProvider.getLocalNotifications(userProvider.user!, 'appointment_notification');
                await socketProvider.getLocalNotifications(userProvider.user!, 'friendship_notification');

                //print('socketProvider.chatList.length000');
                //print(socketProvider.chatList!.length);
                socketProvider.chatList = await (socketProvider.getAllUserChat(userProvider.user!.id));
                //print('socketProvider.chatList.length111');
                //print(socketProvider.chatList!.length);

                // await socketProvider.connectSocketProvider(userProvider.user);
                // await socketProvider.tryConnectSocket(userProvider.user);
                // late Socket? sock;

                // Utils.socket!.disconnect();
                // socketProvider.socket!.disconnect();
                // Utils.socket!.dispose();
                // socketProvider.socket!.dispose();
                // Utils.socket!.close();
                // socketProvider.socket!.close();
                // Utils.socket!.clearListeners();
                // socketProvider.socket!.clearListeners();

                do {
                  Utils.socket = await socketProvider.connectSocketProvider(userProvider.user);
                } while(Utils.socket == null);
              } ();
            }
            // await socketProvider.connectSocketProvider(userProvider.user);
            // await initializeService();
            // await geolocationProvider.getCurrentLocation();
          });
        }
        // return userProvider.setUser(value);
      });
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive){
      //print('AppLifecycleState.inactive');
      // if(BusinessPreferences.getBackgroundNotifications()){
      //   var a = BackgroundServiceProvider.instance.registerFunction(backgroundFunction);
      // }

      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   var appDir = (await getTemporaryDirectory()).path;
      //   await Directory(appDir).delete(recursive: true);
      //   //print('Delete all cache');
      // });

      if(UserPreferences.getIsLogged()! && userProvider.user != null){
        await socketProvider.closeSession(userProvider.user!);
      }

      // if(/*await FlutterBackgroundService().isRunning() == true && */UserPreferences.getIsLogged() && UserPreferences.getBackgroundNotifications()) {
      //   FlutterBackgroundService().sendData({"action": "stopService"},);
      // }
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);

      // Phoenix.rebirth(context);

      return;
    }
    else if (state == AppLifecycleState.detached) {
      //print('AppLifecycleState.detached');
      // () async {
      //   var appDir = (await getTemporaryDirectory()).path;
      //   //print('appDir');
      //   //print(appDir);
      //   // Directory(appDir).deleteSync(recursive: true);
      //   await Directory(appDir).delete(recursive: true);
      //   //print('Delete all cache');
      // } ();
      // if(/*await FlutterBackgroundService().isRunning() == true && */UserPreferences.getIsLogged() && UserPreferences.getBackgroundNotifications()) {
      //   FlutterBackgroundService().invoke("stopService");
      // }
      // if(/*await FlutterBackgroundService().isRunning() == true && */UserPreferences.getIsLogged() && UserPreferences.getBackgroundNotifications()) {
      //   // FlutterBackgroundService().sendData({"action": "stopService"},);
      //   FlutterBackgroundService().invoke("stopService");
      // }
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);

      // Phoenix.rebirth(context);

      // await socketProvider.closeSession(userProvider.user!);

      return;
    }
    else if (state == AppLifecycleState.paused) {
      //print('AppLifecycleState.paused');
      () async {
        var appDir = (await getTemporaryDirectory()).path;
        // //print('appDir');
        // //print(appDir);
        // Directory(appDir).deleteSync(recursive: true);
        await Directory(appDir).delete(recursive: true);
        // //print('Delete all cache');
      } ();

      // await socketProvider.closeSession(userProvider.user!);

      // if(/*await FlutterBackgroundService().isRunning() == true && */UserPreferences.getIsLogged() && UserPreferences.getBackgroundNotifications()) {
      //   FlutterBackgroundService().invoke("stopService");
      // }
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);

      return;
    }
    else if (state == AppLifecycleState.resumed) {
      //print('AppLifecycleState.resumed');

      if(UserPreferences.getIsLogged()!) {
        await socketProvider.startSession((await getUser())!, (await getIp()) ?? <String, dynamic>{});
      }

      // FlutterBackgroundService().invoke("stopService");
      // if(/*await FlutterBackgroundService().isRunning() == false && */UserPreferences.getIsLogged() && UserPreferences.getBackgroundNotifications()) {
      //   await FlutterBackgroundService().startService();
      // }

      // Phoenix.rebirth(context);

      return;
    }
    //
    // final isBackground = state == AppLifecycleState.paused;
    //
    // if (isBackground) {
    //   TextPreferences.setText(controller.text);
    // }

    /* if (isBackground) {
      // service.stop();
    } else {
      // service.start();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    return GetMaterialApp(
      title: 'Nurebo',
      // navigatorObservers: [GetObserver()],
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false
      ),
      // home: const HomeScreen(),
      home: isServerDown == true ? const ServerDownScreen()
        : const Main(/*user: userProvider.user,*/),
      // home: const SplashScreen(),
      // home: const SplashScreen(),
      routes: {
        // '/': (context) => const nureboApp(),
        '/explore_screen': (context) => const SearchMapScreen(),
        '/post_screen': (context) => const PostFeedScreen(),
      },
    );
  }
}

class Main extends StatefulWidget {
  // final email;
  // final username;
  // final id;
  // final User? user;

  const Main({super.key, /*this.user*/});

  @override
  _MainState createState() {
    return _MainState();
  }
}

class _MainState extends State<Main> {
  String _currentPage = "Page1";
  // String _currentPage;
  List<String> pageKeys = ["Page1", "Page2", "Page3", "Page4", "Page5"];
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Page1": GlobalKey<NavigatorState>(),
    "Page2": GlobalKey<NavigatorState>(),
    "Page3": GlobalKey<NavigatorState>(),
    "Page4": GlobalKey<NavigatorState>(),
    "Page5": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;
  // int _selectedIndex;
  late SocketProvider socketProvider;
  late UserProvider userProvider;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  void selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    }
    else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    // socketProvider.setBottomBarVisibility(false);

    // var notificationProvider = Provider.of<NotificationProvider>(this.context, listen: false);

    // notificationProvider.initialize();

    //todo: da abilitare quando il social sarà pronto
    // if(UserPreferences.getIsLogged() == true && UserPreferences.getUserId() != null){
    //   _currentPage = "Page3";
    //   _selectedIndex = 2;
    // }
    // else{
    //   _currentPage = "Page1";
    //   _selectedIndex = 0;
    // }
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);

    // int messaggiRicevuti = 0;
    // for(var e in socketProvider.messages){
    //   if(e.type == 'destination'){
    //     messaggiRicevuti++;
    //   }
    // }

    int bb = 0;
    // for(var e in socketProvider.messageList){
    //   if(e.unread_messages >= 1){
    //     bb++;
    //   }
    //   // for(var e1 in e.chat_message_list){
    //   //
    //   // }
    //   // if(e.type == 'destination'){
    //   //   messaggiRicevuti++;
    //   // }
    // }

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Page1") {
            selectTab("Page1", 1);
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
            children:<Widget>[
              _buildOffstageNavigator("Page1"),
              _buildOffstageNavigator("Page2"),
              _buildOffstageNavigator("Page3"),
              _buildOffstageNavigator("Page4"),
              _buildOffstageNavigator("Page5"),
            ]
        ),
        // drawer: MyDrawer(),
        bottomNavigationBar: Visibility(
          // visible: true,
          visible: socketProvider.isBottomBarVisible,
          child: Container(
            height: 58,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: BottomNavigationBar(
              selectedItemColor: Colors.blueAccent,
              // selectedItemColor: Colors.orange[600],
              elevation: 0,
              backgroundColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              enableFeedback: false,
              onTap: (int index) async {
                // Utils.tabItem = index;
                socketProvider.setCurrentTab(index);
                if(index == 4 && /*(Utils.isBusiness*/ /*|| Utils.isSocial*//*) &&*/ !UserPreferences.getIsLogged()!){
                  // await bottomSheetOptions(context);
                  await bottomSheetNotLogged(context);
                }
                else {
                  selectTab(pageKeys[index], index);
                }
              },
              currentIndex: _selectedIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    // Icons.home_outlined,
                    // Icons.shopping_bag_outlined,
                    Utils.isSocial ? Icons.shopping_bag_outlined : Icons.home_outlined,
                    size: 28,
                  ),
                  label: 'f',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.camera_alt, size: 28,),
                //   label: '',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(
                    // Utils.isSocial ? Icons.dashboard_rounded : Icons.event,
                    // Utils.isSocial ? Icons.dashboard_rounded : /*Icons.messenger_outline*/Icons.message_outlined,
                    Icons./*photo_library_outlined*/image_outlined,
                    size: /*26*/28,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    //Icons.airplane_ticket_outlined
                    // Icons.shopping_bag_outlined,
                    // Utils.isSocial ? Icons.explore : Icons.chat_outlined,
                    Utils.isSocial ? Icons.explore : /*Icons.event*/Icons.storefront_outlined/*store_mall_directory_outlined*//*store_outlined*/,
                    // FontAwesome5Solid.ticket_alt,
                    size: Utils.isSocial ? 28 : /*26*/28,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  // icon: Provider.of<SocketProvider>(context, listen: false).messages.length == 0
                  // icon: socketProvider.messages.length == 0
                  // icon: messaggiRicevuti == 0
                  icon: /*bb == 0*/Provider.of<CartProvider>(context).items.length == 0 ? Icon(
                    // FontAwesome5Brands.telegram_plane,
                    // Icons.sms_outlined,
                    // Icons.message_outlined,
                    // Utils.isSocial ? Icons.people : Icons.store_outlined,
                    Utils.isSocial ? Icons.people : /*Icons.shopping_cart_outlined*/Icons.event_note_outlined,
                    size: Utils.isSocial ? 26 : 28,
                    // color: Colors.white,
                    // color: Colors.grey[800],
                  ) : badges.Badge(
                    // badgeAnimation: badges.BadgeAnimation.rotation(
                    //   animationDuration: Duration(seconds: 1),
                    //   colorChangeAnimationDuration: Duration(seconds: 1),
                    //   loopAnimation: false,
                    //   curve: Curves.fastOutSlowIn,
                    //   colorChangeAnimationCurve: Curves.easeInCubic,
                    // ),
                      position: badges.BadgePosition.topEnd(top: -10.5, end: -9),
                      badgeStyle: badges.BadgeStyle(
                        // toAnimate: false,
                        padding: EdgeInsets.all(5),
                        shape: badges.BadgeShape.circle,
                        // animationDuration: Duration(milliseconds: 300),
                        // animationType: badges.BadgeAnimationType.fade,
                        // borderRadius: ,
                        // badgeColor: Colors.grey[50],
                        // badgeColor: Colors.blue[200]!,
                        badgeColor: Colors.transparent,
                        elevation: 0,
                      ),
                      badgeContent: Text(
                        // Provider.of<SocketProvider>(context/*, listen: true*/).messages.length.toString(),
                        // socketProvider.messages.length.toString(),
                        // messaggiRicevuti.toString(),
                        // bb.toString(),
                        Provider.of<CartProvider>(context).items.length.toString(),
                        style: GoogleFonts.poppins(
                          // color: Colors.blue,
                          //   color: Colors.white,
                            color: Colors.transparent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5
                        ),
                      ),
                      child: Icon(
                        // FontAwesome5Brands.telegram_plane,
                        // Icons.sms_outlined,
                        // Utils.isSocial ? Icons.people : Icons.store_outlined,
                        Utils.isSocial ? Icons.people : /*Icons.shopping_cart_outlined*/Icons.event_note_outlined,
                        size: Utils.isSocial ? 26 : 28,
                      )
                  ),
                  label: '',
                  // icon: Container(
                  //   height: 28.0,
                  //   width: 28.0,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       // color: Color.fromRGBO(245, 93, 62, 1),
                  //       color: Colors.blue,
                  //       width: 2
                  //     ),
                  //     borderRadius: BorderRadius.circular(100.0),
                  //     image: DecorationImage(
                  //       image: NetworkImage(
                  //         // 'https://images.pexels.com/photos/2346754/pexels-photo-2346754.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'),//AssetImage('assets/images/chris.jpg'),
                  //         allUsers[0].profileImageUrl,
                  //       ),
                  //         fit: BoxFit.cover
                  //       )
                  //   ),
                  //   ),
                  //icon: Icon(Icons.perm_identity, ),
                ),
                // BottomNavigationBarItem(
                //   icon: Provider.of<CartProvider>(context).items.length == 0 ? InkWell(
                //     onTap: () async {
                //       await bottomSheetOptions(context);
                //     },
                //     child: Icon(
                //       // Icons.shopping_cart,
                //       // Icons.shopping_cart_outlined,
                //       Icons.menu_rounded,
                //       // Icons.notifications_none_outlined,
                //       // size: 26.5,
                //       size: 28,
                //     ),
                //   ) : InkWell(
                //     onTap: () async {
                //       await bottomSheetOptions(context);
                //     },
                //     child: badges.Badge(
                //         badgeStyle: badges.BadgeStyle(
                //           // toAnimate: false,
                //           padding: EdgeInsets.all(5),
                //           shape: badges.BadgeShape.circle,
                //           // animationDuration: Duration(milliseconds: 300),
                //           // animationType: badges.BadgeAnimationType.fade,
                //           badgeColor: Colors.blue[200]!,
                //           elevation: 0,
                //
                //         ),
                //
                //         position: badges.BadgePosition.topEnd(top: -10.5, end: -9),
                //         badgeContent: Text(
                //           Provider.of<CartProvider>(context).items.length.toString(),
                //           style: GoogleFonts.poppins(
                //             // color: Colors.blue,
                //               color: Colors.white,
                //               fontWeight: FontWeight.w700,
                //               fontSize: 10.5
                //           ),
                //         ),
                //         child: Icon(
                //           // Icons.shopping_cart,
                //           // Icons.shopping_cart_outlined,
                //           Icons.menu_rounded,
                //           // Icons.notifications_none_outlined,
                //           // size: 26.5,
                //           size: 33,
                //         )
                //     ),
                //   ),
                //   label: '',
                // ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      // InkWell(
                      //   highlightColor: Colors.transparent,
                      //   splashColor: Colors.transparent,
                      //   child: Icon(
                      //     Icons.menu_rounded,
                      //     // Icons.view_headline_rounded,
                      //     // Icons.view_headline_outlined,
                      //     // Icons.apps_rounded,
                      //     // Icons.apps_outlined,
                      //     color: Colors.grey[600],
                      //     size: 28,
                      //   ),
                      //   // onPressed: () => Navigator.of(context).pop(),
                      //   onTap: () async {
                      //     await bottomSheetOptions(context);
                      //   },
                      // ),
                      !UserPreferences.getIsLogged()! /*&& (Utils.isBusiness)*/ ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Icon(
                          // Icons.menu_rounded,
                          Icons.account_circle_rounded,
                          // Icons.view_headline_rounded,
                          // Icons.view_headline_outlined,
                          // Icons.apps_rounded,
                          // Icons.apps_outlined,
                          color: Colors.grey[600],
                          size: 28,
                        ),
                        // onPressed: () => Navigator.of(context).pop(),
                        onTap: () async {
                          await bottomSheetNotLogged(context);
                        },
                      ) : UserPreferences.getIsLogged()! /*&& (Utils.isBusiness)*/ ? Card(
                        semanticContainer: true,
                        margin: const EdgeInsets.all(0),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        elevation: 5,
                        // child: Image.network(
                        child: FutureImage(
                          // Utils.business!.profile_image!,
                          // userProvider.user!.profile_image!,
                          // Utils.user != null ? Utils.user!.profile_image! : '',
                          // UserPreferences.getIsLogged() == true ? Utils.user!.profile_image! : userProvider.user!.profile_image!,
                          userProvider.user?.profile_image ?? '',
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.width * 0.07,
                        ),
                        //margin: EdgeInsets.all(10),
                      ) : InkWell(
                          onTap: () async {
                            // await bottomSheetOptions(context);
                            if(Utils.isSocial){
                              selectTab("Page5", 4);
                            }
                          },
                          child: badges.Badge(
                            showBadge: Provider.of<CartProvider>(context).items.length > 0,
                            badgeStyle: badges.BadgeStyle(
                              // toAnimate: false,
                              padding: EdgeInsets.all(5),
                              shape: badges.BadgeShape.circle,
                              // animationDuration: Duration(milliseconds: 300),
                              // animationType: badges.BadgeAnimationType.fade,
                              badgeColor: Colors.blue[200]!,
                              elevation: 0,
                            ),
                            position: badges.BadgePosition.topEnd(top: -10.5, end: -9),
                            badgeContent: Text(
                              Provider.of<CartProvider>(context).items.length.toString(),
                              style: GoogleFonts.poppins(
                                // color: Colors.blue,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5
                              ),
                            ),
                            child: Icon(
                              // Icons.shopping_cart,
                              // Icons.shopping_cart_outlined,
                              Icons.event_note_outlined,
                              // Icons.menu_rounded,
                              // Icons.notifications_none_outlined,
                              size: 26.5,
                              // size: 33,
                            )
                        ),
                      ),
                      !UserPreferences.getIsLogged()! /*&& Utils.isBusiness*/ ? Positioned(
                        top: 1,
                        left: 18,
                        // top: -1.5,
                        // left: 39,
                          child: Container(
                              width: 11,
                              height: 11,
                              // width: 13,
                              // height: 13,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // color: Colors.black
                                  // color: Colors.grey[100]
                                  color: Colors.white
                              ),
                              child: Center(
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  // width: 5,
                                  // height: 5,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue
                                  )
                                )
                              )
                          )
                      ) : SizedBox(),
                    ],
                  ),
                  label: '',
                ),
                // const BottomNavigationBarItem(
                //   icon: Icon(
                //     Icons.notifications_rounded,
                //     size: 28,
                //   ),
                //   label: '',
                // ),
              ],
              type: BottomNavigationBarType.fixed,
            ),
            // child: ChangeNotifierProvider(
            //   create: (_) => SSBottomBarState(),
            //   child: Consumer<SSBottomBarState>(
            //     builder: (context, state, _) {
            //       return SSBottomNav(
            //         items: [
            //           SSBottomNavItem(
            //             text: 'Store',
            //             iconData: Icons.store,
            //             iconSize: 20,
            //           ),
            //           SSBottomNavItem(
            //               text: 'Explore',
            //               iconData: Icons.explore,
            //               iconSize: 20,
            //           ),
            //           SSBottomNavItem(
            //             text: 'Dashboard',
            //             // iconData: Icons.dashboard_outlined,
            //             iconData: Icons.dashboard,
            //             iconSize: 35,
            //             isIconOnly: true
            //           ),
            //           SSBottomNavItem(
            //             text: 'Chat',
            //             iconData: Icons.people_outline_outlined,
            //             iconSize: 20,
            //             // isIconOnly: true
            //           ),
            //           SSBottomNavItem(
            //             text: 'Cart',
            //             iconData: Icons.shopping_cart_outlined,
            //             iconSize: 20,
            //           ),
            //         ],
            //         state: state,
            //         color: Colors.grey[800],
            //         selectedColor: Colors.white,
            //         unselectedColor: Colors.grey[800],
            //         // visible: _isVisible,
            //         visible: true,
            //         // bottomSheetWidget: _bottomSheet(),
            //         showBottomSheetAt: 2,
            //       );
            //     }
            //   ),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        // user: widget.user,
        user: Utils.user,
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}