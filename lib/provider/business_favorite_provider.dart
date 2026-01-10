import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:provider/provider.dart';

class BusinessFavoriteProvider extends ChangeNotifier {
  List? savedBusinessList = [];


  Future getUserSavedBusiness(User user/*, BuildContext context*/) async {
    // PostProvider postProvider = Provider.of<PostProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user.id}/business/save");

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

      savedBusinessList = jsonData;

      // //print('jsonData22222222');
      // //print(jsonData);
      // await postProvider.getAllBusinessesPosts();

      notifyListeners();
      return jsonData;
    }
  }

  // Future saveBusiness(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/save");
  //
  //   Map<String, dynamic> body = {
  //     // "user_id": widget.user.id,
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     await getUserSavedBusiness(user/*userId*/);
  //
  //     notifyListeners();
  //     return response.statusCode;
  //   }
  // }
  //
  // Future unsaveBusiness(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/unsave");
  //
  //   Map<String, dynamic> body = {
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     await getUserSavedBusiness(user/*userId*/);
  //
  //     notifyListeners();
  //
  //     return response.statusCode;
  //   }
  // }

  // Future getPrestazioneLike(User user, Business business) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "saved_business/user_business");
  //
  //   Map<String, dynamic> body = {
  //     "user_id": user.id,
  //     'business_id': business.id
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
  //       }
  //   );
  //
  //   // if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
  //   //   await logout();
  //   // }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // businessPostLikes = jsonData;
  //     //print("likes???");
  //     // //print(posts);
  //     //print(jsonData);
  //
  //     if(jsonData == 1){
  //       setState(() {
  //         isLikedPost = true;
  //       });
  //
  //     }
  //     else if(jsonData == 0){
  //       setState(() {
  //         isLikedPost = false;
  //       });
  //     }
  //     // notifyListeners();
  //     return jsonData;
  //   }
  // }

  emptySavedBusiness(){
    savedBusinessList!.clear();
    notifyListeners();
  }
}
