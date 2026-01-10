import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nurebo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';

class PrestazioneFavoriteProvider extends ChangeNotifier {
  List favoritesList = [];


  Future getUserPrestazioneFavorites(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/prestazione/like");

    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // for(var e in favoritesList){
      //   if(e['prestazione_id'] != null){
      //     favoritesList.remove(e);
      //   }
      // }
      removeAllPrestazioneFavorite();
      // myFavoritesList = jsonData;
      // List.from(myFavoritesList).add(jsonData);
      // favoritesList.add(jsonData);
      favoritesList.addAll(jsonData);

      favoritesList.sort((b, a) {
        return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
      });

      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future getUserEventFavorites(User user) async {
    // var url = Uri.parse(Utils.httpServerUrl + "event_favorite/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/event/like");

    Map<String, dynamic> body = {
      'user_id': user.id,
    };

    // var response = await http.post(
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // for(var e in favoritesList){
      //   if(e['event_id'] != null){
      //     favoritesList.remove(e);
      //   }
      // }
      removeAllEventFavorite();
      // myFavoritesList = jsonData;
      // List.from(myFavoritesList).add(jsonData);
      // favoritesList.add(jsonData);
      favoritesList.addAll(jsonData);

      favoritesList.sort((b, a) {
        return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
      });

      // //print('jsonData allaahh');
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  removeAllEventFavorite(){
    for(var e in List.from(favoritesList)){
      if(e['event_id'] != null){
        favoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  removeAllPrestazioneFavorite(){
    for(var e in List.from(favoritesList)){
      if(e['prestazione_id'] != null){
        favoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  removeEventFavorite(String id){
    for(var e in favoritesList){
      if(e['event_id'] != null && e['event_id'] == id) {
        favoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  removePrestazioneFavorite(String id){
    for(var e in favoritesList){
      if(e['prestazione_id'] != null && e['prestazione_id'] == id){
        favoritesList.remove(e);
      }
    }
    notifyListeners();
  }

  emptyFavorites(){
    favoritesList.clear();
    notifyListeners();
  }
}
