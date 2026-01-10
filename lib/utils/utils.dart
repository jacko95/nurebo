import 'package:flutter/material.dart';
import 'package:nurebo/main.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Utils {
  // static const String httpServerUrl = "https://" + serverUrl;
  static const String httpServerUrl = "http://" + serverUrl;
  static const String serverUrl = "192.168.1.6:5000/";
  // static const String serverUrl = "api.nurebo.com/";
  // static const String serverUrl = "192.168.46.146:5000/"; //mobile
  // static const String serverUrl = "clexira.online/";
  // static const String serverUrl = "dev.nurebo.com/";
  // static const String serverUrl = "192.168.1.225:5000/api/v1/";
  // static const String serverUrl = "dev.nurebo.com/api/v1/";
  // static const String serverUrl = "api.nurebo.com/api/v1/";
  // static const String serverUrl = "www.pleunia.com/";
  // static const String serverUrl = "www.pleunia.com/api/v1/";
  // static const String serverUrl = "18.184.152.135/";
  // static String serverUrl = "supperman.hopto.org:5000/";
  static bool isForeground = false;
  static bool isEventsEnabled = false;
  // static bool isSocketConnected = false;
  static bool isSocial = false;
  static bool isBusiness = false;
  static Socket? socket;
  static double? ipLatitude;
  static double? ipLongitude;
  // static const int app_type = 0; //nurebo app
  // static const int app_type = 1; // social nurebo app
  static const int app_type = 2; //business app
  static const business_id = 'dcsvfb888';
  // static const business_id = '';
  // static String business_room_id = '';
  static const bool isDev = true;
  static Business? business;
  static User? user;
  // static int tabItem = 0;
  // static int connectedSockets = 0;
  static const version_id = 226;
  static const version_name = '0.2.9';
  // static final version_name = packageInfo.version;
  // static bool isBottombarVisible = true;

  static final List<String> animations = [
    '',
  ];

  static OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Colors.transparent),
  );

  static const TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 25.0,
    letterSpacing: 1.5,
    fontWeight: FontWeight.bold,
  );

  static const Color darkPrimary = Color(0xff312F45);
  static const Color darkAccent = Color(0xff1176E8);
  static const Color darkBG = Color(0xff1F2533);

  static const Color lightPrimary = Colors.white;
  static const Color lightAccent = Colors.amber;
  static const Color lightBG = Color(0xFFEEEEEE);

  Color? w = Colors.grey[200];
  static const List<Color> darkBGColors = [darkBG, darkBG];

  static const List<Color> lightBGColors = [
    Color(0xff0D5F64),
    Color(0xff219077),
    Color(0xffA5CDCC)
  ];

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // backgroundColor: lightBG,
    primaryColor: lightPrimary,
    hintColor: lightAccent,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // backgroundColor: darkBG,
    primaryColor: darkPrimary,
    hintColor: darkAccent,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      elevation: 0,
    ),
  );
}