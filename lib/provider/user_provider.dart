import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:nurebo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo/main.dart';


class UserProvider extends ChangeNotifier {
  User? user;
  final ImagePicker _imagePicker = ImagePicker();
  late bool isLogged;
  static const restartChannel = MethodChannel('com.nurebo.nurebo/restart');


  UserProvider(){
    updateIsLogged();
  }

  Future<XFile> selectProfileImage() async {
    final XFile selected = (await _imagePicker.pickImage(source: ImageSource.gallery))!;
    if (selected.path.isEmpty) {
      // //print(selected.path.toString());
      // _imageList.add(selected);
    }
    // setState(() {
    //   // _image = File(pickedImage.path);
    //   _imageList.add(selected);
    // });
    return selected;
  }

  Future<void> _restartApp() async {
    try {
      await restartChannel.invokeMethod('restartApp');
    } on PlatformException catch (e) {
      // print("Failed to restart app: '${e.message}'.");
    }
  }

  Future uploadProfileImage(/*XFile _image*/) async {
    XFile _image = await selectProfileImage();

    String imageName = _image.path.split('/').last;
    // List<int> imageBytes = File(filePath.path).readAsBytesSync();

    var request = http.MultipartRequest(
        'POST',
        // Uri.parse(Utils.httpServerUrl + "user/profile_image")
        Uri.parse("${Utils.httpServerUrl}user/${user!.id}/profile_image")
    );

    String imageMimeType = lookupMimeType(_image.path)!;
    // //print('imageMimeType');
    // //print(imageMimeType);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        // imageFilePath,
        _image.path,
        filename: '${imageName.split('image_picker').last}',
        // contentType: new MediaType('image', 'jpeg')
        // contentType: new MediaType('image', 'png')
        contentType: MediaType(
            imageMimeType.split('/').first,
            imageMimeType.split('/').last
        )
      )
    );
    // request.files.add(
    //   http.MultipartFile.fromBytes(
    //     'image',
    //     _imageFile.readAsBytesSync(),
    //     filename: '$imageName',
    //     // contentType: new MediaType('image', 'jpeg')
    //     contentType: new MediaType('image', 'png')
    //     // contentType: new MediaType('image', 'jpg')
    //   )
    // );

    // http.MultipartFile.fromString(
    //   'image',
    //   _imageFile.path,
    //   filename: '$imageName',
    // );

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip, deflate',
      HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip, deflate';
    // request.fields['file'] = name;

    request.fields['user_id'] = user!.id!;
    var res = await request.send();
    if(res.statusCode >= 200 && res.statusCode < 400){
      // user.profile_image = 'http://192.168.1.225/kadingira-server/posts/${imageName.split('image_picker').last}';
      // var jsonData = json.decode(response.body);

      var resData = await res.stream.bytesToString();
      var jsonData = json.decode(resData);

      // //print('res.statusCode');
      // //print(res.statusCode);
      // //print('res.stream.bytesToString()');
      // //print(await res.stream.bytesToString());
      // //print(json.decode(g)['Location']);
      // //print(jsonData);

      // user!.profile_image = jsonData['Location'];
      user!.profile_image = jsonData['Key'];

      // Fluttertoast.showToast(
      //   msg: 'Immagine Profilo aggiornata',
      //   backgroundColor: Colors.grey[700],
      // );
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Immagine Profilo aggiornata',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      // notifyListeners();
      await _restartApp();
    }
    else {
      final SnackBar snackBar = SnackBar(
        content: Text(
          await res.stream.bytesToString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
    notifyListeners();
    return res.statusCode;
  }

  Future logout(context) async {
    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
    PrestazioneFavoriteProvider favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    BusinessFavoriteProvider businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    var splitToken = UserPreferences.getUserToken()!.split('.');
    // //print(splitToken);
    String decodedHeader = utf8.fuse(base64).decode(base64.normalize(splitToken[0]));
    String decodedPayload = utf8.fuse(base64).decode(base64.normalize(splitToken[1]));
    // String decodedSignature = utf8.fuse(base64).decode(splitToken[2]);
    // //print(decodedHeader);
    // //print(decodedPayload);
    // //print(decodedSignature);
    Map authId = jsonDecode(utf8.fuse(base64).decode(base64.normalize(splitToken[1])));
    // //print(authId['id']);

    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/authentication/${authId['id']}/logout");

    // //print('UserPreferences.getUserToken()');
    // //print(UserPreferences.getUserToken());

    Map body = {
      "auth_id": authId['id'],
      "user_id": user!.id,
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!,
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode <= 401) {
      // Scaffold.of(context).openEndDrawer();
      // if(socketProvider.socket != null){
      //   if(socketProvider.socket.connected){
      //     // socketProvider.socket.disconnect();
      //     // socketProvider.socket.close();
      //     socketProvider.socket.destroy();
      //   }
      // }

      // //print('socketProvider.socket.id');
      // //print(socketProvider.socket.id);
      // //print('user.id');
      // //print(user.id);

      // socketProvider.removeUserSocket(
      //     userProvider.user.id,
      //     socketProvider.socket.id
      // );

      // await UserPreferences.init();
      await UserPreferences.setIsLogged(false);
      await UserPreferences.setUserId('');
      await UserPreferences.setUserToken('');
      await UserPreferences.setDeviceId('');

      // Utils.socket!.disconnect();
      // socketProvider.socket!.disconnect();
      // Utils.socket!.dispose();
      // socketProvider.socket!.dispose();
      // Utils.socket!.close();
      // socketProvider.socket!.close();
      // Utils.socket!.clearListeners();
      // socketProvider.socket!.clearListeners();
      // Utils.socket!.destroy();
      // socketProvider.socket!.destroy();
      Utils.socket!.emit(
        "remove_user_socket",
        {
          "userId": Utils.user!.id,
          "socketId": Utils.socket!.id,
        }
      );

      // userProvider.setUser(null);
      emptyUser();
      Utils.user = User();
      favoriteProvider.emptyFavorites();
      businessFavoriteProvider.emptySavedBusiness();
      socketProvider.emptyAppointments();
      socketProvider.emptyDateNotifications();
      cartProvider.removeAll();

      socketProvider.setBottomBarVisibility(false);

      // FlutterBackgroundService().sendData({"action": "stopService"},);
      // if((await FlutterBackgroundService().isServiceRunning()) == true){
      // if((await FlutterBackgroundService().isRunning()) == true){
      //   // FlutterBackgroundService().sendData({"action": "stopService"},);
      //   FlutterBackgroundService().invoke("stopService");
      // }

      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );

      // if(Utils.isBusiness){
      //   await Navigator.pushAndRemoveUntil(
      //       context,
      //       PageTransition(
      //         child: HomeScreen(),
      //         type: PageTransitionType.fade,
      //         duration: Duration(milliseconds: 500),
      //       ),
      //           (route) => false
      //     // (route) => true
      //   );
      // }
      // else{
        /*await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            // child: LoginScreen(),
            child: Main(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 500),
          ),
          // (route) => false
          ModalRoute.withName('/'),
          // (route) => true
        );
        Navigator.popUntil(
          context,
          ModalRoute.withName('/')
        );
        // Get.toNamed('/');
        Navigator.push(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 500),
            alignment: Alignment.center,
            type: PageTransitionType.fade,
            child: const Main()
          ),
        );*/

        // Navigator.of(context).replaceAll([
        //   MaterialPageRoute(builder: (context) => MyHomePage()),
        // ]);

        // final controller = Get.find<GetxController>();
        // controller.pages.clear();
        // controller.pages.add(const Main());

        Get.offAll(() => const Main());

        // Get.reset();
        // Get.to(const Main());


        // Navigator.of(context).pop();
        // Utils.tabItem =
        // selectTab("Page1", 1);
      // }

      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop')/*.then((value) => Phoenix.rebirth(context))*/;
      // Phoenix.rebirth(context);
    }
    // else if(response.statusCode == 401) {
    //   Fluttertoast.showToast(
    //     msg: 'Autenticazione scaduta',
    //     backgroundColor: Colors.grey[700],
    //   );
    //
    //   await Navigator.pushAndRemoveUntil(
    //       context,
    //       PageTransition(
    //         child: LoginScreen(),
    //         type: PageTransitionType.fade,
    //         duration: Duration(milliseconds: 500),
    //       ),
    //           (route) => false
    //     // (route) => true
    //   );
    // }
  }

  Future<bool> goBackToMain() async {
    // if(Utils.isSocial || Utils.isBusiness){
    //   //todo: false per nascondere bottombar
    //   socketProvider.setBottomBarVisibility(true);
    // }

    // if(!Utils.isBusiness){
    //   await Navigator.pushAndRemoveUntil(
    //       context,
    //       PageTransition(
    //         child: const HomeScreen(),
    //         type: PageTransitionType.fade,
    //         duration: const Duration(milliseconds: 500),
    //       ),
    //           (route) => false
    //   );
    // }
    // else {
    //   await Navigator.pushAndRemoveUntil(
    //       context,
    //       PageTransition(
    //         child: Main(/*user: userProvider!.user*/),
    //         type: PageTransitionType.fade,
    //         duration: const Duration(milliseconds: 500),
    //       ),
    //           (route) => false
    //   );
    // }
    Get.offAll(() => const Main());

    // Navigator.pop(context);
    return true;
  }

  setUser(User? user){
    this.user = user;
    notifyListeners();
  }

  setLocation(double latitude, double longitude){
    user!.latitude = latitude;
    user!.longitude = longitude;
    notifyListeners();
  }

  emptyUser(){
    Utils.user = User();
    user = User();
    notifyListeners();
  }

  //todo: sono tutti da settare con chiamata http
  updateUsername(String username){
    this.user!.username = username;
    notifyListeners();
  }

  updatePhone(String phone){
    this.user!.phone = phone;
    notifyListeners();
  }

  updateEmail(String email){
    this.user!.email = email;
    notifyListeners();
  }

  updateEmailNotification(int emailNotification){
    this.user!.email_notification = emailNotification;
    notifyListeners();
  }

  updateDescription(String description){
    user!.description = description;
    notifyListeners();
  }

  updateName(String name){
    user!.name = name;
    notifyListeners();
  }

  updateIsLogged(){
    isLogged = UserPreferences.getIsLogged()!;
    notifyListeners();
  }

}
