import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class GeolocationProvider extends ChangeNotifier {
  Position? position;
  LocationPermission? locationPermission;


  Future<Position?> getGeolocationPermission(BuildContext context) async {
    locationPermission = await Geolocator.checkPermission();
    locationPermission = await Geolocator.requestPermission();
    // //print(locationPermission.toString());

    if(locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // forceAndroidLocationBusiness: true,
      );
      // print('fb5f5gg65gg65');
      // print(position!.latitude);
      // print(position!.longitude);
      if(UserPreferences.getIsLogged()!){
        await putUserLocation(position?.latitude ?? 0, position?.longitude ?? 0, context);
      }
    }
    else if(locationPermission == LocationPermission.deniedForever){
      //mostrare un dialog con questa scritta
      // //print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
      await Geolocator.openAppSettings();
    }
    else if(locationPermission == LocationPermission.denied){
      //mostrare un dialog con questa scritta
      // //print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");

      try {
        await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          // forceAndroidLocationBusiness: true,
        );
        if(UserPreferences.getIsLogged()!){
          await putUserLocation(position!.latitude, position!.longitude, context);
        }
      } on Exception catch (e) {
        // print(e);
      }
      // print('66gghhhh6');
      // print(position?.latitude);
      // print(position?.longitude);
    }

    notifyListeners();
    return position;
  }

  Future<Position?> checkGeolocationPermission(BuildContext context) async {
    locationPermission = await Geolocator.checkPermission();
    // locationPermission = await Geolocator.requestPermission();
    // //print(locationPermission.toString());

    if(locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // forceAndroidLocationBusiness: true,
      );
      // print('2f2gg2gghh333');
      // print(position?.latitude);
      // print(position?.longitude);
      if(UserPreferences.getIsLogged()!){
        await putUserLocation(position?.latitude ?? 0, position?.longitude ?? 0, context);
      }
    }
    // else if(locationPermission == LocationPermission.deniedForever){
    //
    //   //mostrare un dialog con questa scritta
    //   //print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
    //   await Geolocator.openAppSettings();
    // }
    // else if(locationPermission == LocationPermission.denied){
    //   //mostrare un dialog con questa scritta
    //   //print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
    //   await Geolocator.requestPermission();
    //
    // }

    notifyListeners();
    return position;
  }

  Future putUserLocation(/*User user,*/ double latitude, double longitude, BuildContext context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/location");

    Map<String, dynamic> body = {
      'user_id': userProvider.user!.id,
      'latitude': latitude,
      'longitude': longitude,
    };

    var response = await http.put(
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
        }
    );

    //print("sdsdgsg response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      userProvider.setLocation(latitude, longitude);
      notifyListeners();
      return jsonData;
    }
  }
}
