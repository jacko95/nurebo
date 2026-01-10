import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/src/media_type.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class BusinessProvider extends ChangeNotifier {
  Business business = Business();

  // ManagerProvider(){
  //   () async {
  //     await getManager();
  //   };
  // }
  //
  // Future getManager() async {
  //   // final context = SecurityContext.defaultContext;
  //   // final httpClient = HttpClient(context: context);
  //   // final client = IOClient(httpClient);
  //
  //   var url = Uri.parse(Utils.httpServerUrl + "manager");
  //   Map/*<String, String>*/ body = {
  //     'manager_id': Utils.manager_id,
  //   };
  //
  //   // var response = await client.post(
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
  //       }
  //   );
  //
  //   if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
  //     // if (!mounted) return;
  //     // await userProvider.logout(context);
  //   }
  //   if(response.statusCode == 200) {
  //     var jsonData = json.decode(response.body);
  //     Manager manager = Manager(
  //         id: jsonData[0]['manager_id'],
  //         description: jsonData[0]['manager_description'],
  //         name: jsonData[0]['manager_name'],
  //         email: jsonData[0]['manager_email'],
  //         max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
  //         address: jsonData[0]['manager_address'],
  //         phone_number: jsonData[0]['manager_phone_number'],
  //         is_booking_manager: jsonData[0]['is_booking_manager'],
  //         profile_image: jsonData[0]['manager_profile_image'],
  //         latitude: jsonData[0]['manager_latitude'],
  //         longitude: jsonData[0]['manager_longitude'],
  //         category: Category(
  //           id: jsonData[0]['category_id'],
  //           image: jsonData[0]['category_image'],
  //           name: jsonData[0]['category_name'],
  //         )
  //     );
  //     // });
  //
  //     setManager(manager);
  //     // setState(() {
  //     //   managerProvider.manager = manager;
  //     // });
  //
  //     notifyListeners();
  //
  //     return manager;
  //   }
  // }

  // Future logout(context) async {
  //   SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
  //   PrestazioneFavoriteProvider favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
  //   CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
  //
  //   var url = Uri.parse(Utils.httpServerUrl + "authentication/logout");
  //
  //   print('UserPreferences.getUserToken()');
  //   print(UserPreferences.getUserToken());
  //
  //   var splitToken = UserPreferences.getUserToken()!.split('.');
  //   print(splitToken);
  //   String decodedHeader = utf8.fuse(base64).decode(base64.normalize(splitToken[0]));
  //   String decodedPayload = utf8.fuse(base64).decode(base64.normalize(splitToken[1]));
  //   // String decodedSignature = utf8.fuse(base64).decode(splitToken[2]);
  //   print(decodedHeader);
  //   print(decodedPayload);
  //   // print(decodedSignature);
  //   Map authId = jsonDecode(utf8.fuse(base64).decode(base64.normalize(splitToken[1])));
  //   print(authId['id']);
  //
  //   Map body = {
  //     "auth_id": authId['id'],
  //     "user_id": business.id,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!,
  //       }
  //   );
  //
  //   print("response.statusCode:");
  //   print(response.statusCode);
  //
  //
  //   if(response.statusCode == 200) {
  //     // Scaffold.of(context).openEndDrawer();
  //     // if(socketProvider.socket != null){
  //     //   if(socketProvider.socket.connected){
  //     //     // socketProvider.socket.disconnect();
  //     //     // socketProvider.socket.close();
  //     //     socketProvider.socket.destroy();
  //     //   }
  //     // }
  //
  //     // print('socketProvider.socket.id');
  //     // print(socketProvider.socket.id);
  //     print('user.id');
  //     print(business.id);
  //
  //     // socketProvider.removeUserSocket(
  //     //     userProvider.user.id,
  //     //     socketProvider.socket.id
  //     // );
  //
  //     // await UserPreferences.init();
  //     await UserPreferences.setIsLogged(false);
  //     await UserPreferences.setUserId('');
  //     await UserPreferences.setUserToken('');
  //
  //     // userProvider.setUser(null);
  //     emptyBusiness();
  //     favoriteProvider.emptyFavorites();
  //     socketProvider.emptyAppointments();
  //     // socketProvider.emptyDateNotifications();
  //     cartProvider.removeAll();
  //
  //     // FlutterBackgroundService().sendData({"action": "stopService"},);
  //     // if((await FlutterBackgroundService().isServiceRunning()) == true){
  //     // if((await FlutterBackgroundService().isRunning()) == true){
  //     //   // FlutterBackgroundService().sendData({"action": "stopService"},);
  //     //   FlutterBackgroundService().invoke("stopService");
  //     // }
  //
  //     Fluttertoast.showToast(
  //       msg: 'Autenticazione scaduta',
  //       backgroundColor: Colors.grey[700],
  //     );
  //
  //     await Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: LoginScreen(),
  //           type: PageTransitionType.fade,
  //           duration: Duration(milliseconds: 500),
  //         ),
  //             (route) => false
  //       // (route) => true
  //     );
  //
  //     // await SystemChannels.platform.invokeMethod('SystemNavigator.pop')/*.then((value) => Phoenix.rebirth(context))*/;
  //     // Phoenix.rebirth(context);
  //   }
  // }

  setBusiness(Business manager){
    business = manager;
    notifyListeners();
  }

  emptyBusiness(){
    business = Business();
    notifyListeners();
  }

}
