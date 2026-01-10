import 'dart:convert';
import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/business_favorite_provider.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/notification_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/delete_account.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/settings_notification_screen.dart';
import 'package:nurebo/screens/edit_description_screen.dart';
import 'package:nurebo/screens/edit_email_screen.dart';
import 'package:nurebo/screens/edit_name_screen.dart';
import 'package:nurebo/screens/edit_phone_number_screen.dart';
import 'package:nurebo/screens/edit_profile_image_screen.dart';
import 'package:nurebo/screens/edit_username_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/custom_dialog.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../provider/cart_provider.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProvider userProvider;
  late PrestazioneFavoriteProvider favoriteProvider;
  late BusinessFavoriteProvider businessFavoriteProvider;
  late PostProvider postProvider;
  CartProvider? cartProvider;
  NotificationProvider? notificationProvider;
  late SocketProvider socketProvider;


  Future deleteAccount() async {
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      // "deleted_at": DateTime.now().toUtc().toString(),
      // "deleted_at": DateTime.now()/*.toIso8601String()*/.toString(),
    };

    var response = await http.delete(
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

    // //print("response.statusCode deleted account:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // await UserPreferences.init();
      await UserPreferences.setIsLogged(false);
      await UserPreferences.setUserId('');
      await UserPreferences.setUserToken('');
      await UserPreferences.setDeviceId('');

      // userProvider.setUser(null);
      userProvider.emptyUser();
      Utils.user = User();
      favoriteProvider.emptyFavorites();
      businessFavoriteProvider.emptySavedBusiness();
      socketProvider.emptyAppointments();
      socketProvider.emptyDateNotifications();

      // // if((await FlutterBackgroundService().isServiceRunning()) == true){
      // if((await FlutterBackgroundService().isRunning()) == true){
      //   // FlutterBackgroundService().sendData({"action": "stopService"},);
      //   FlutterBackgroundService().invoke("stopService");
      // }

      await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginScreen(),
            duration: const Duration(milliseconds: 500),
            type: PageTransitionType.fade,
          ),
          (route) => false
      );
      // socketProvider.socket.disconnect();
      // Phoenix.rebirth(context);
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop')/*.then((value) => Phoenix.rebirth(context))*/;

      // return exit(0);

      return jsonData;
    }
  }

  void _showDeletingDialog(String module) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Vuoi eliminare il tuo account?',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              await deleteAccount();
            },
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    // socketProvider.socket.destroy();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    cartProvider = Provider.of<CartProvider>(context, listen: true);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);
    businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);
    notificationProvider = Provider.of<NotificationProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          titleSpacing: 0,
          // leadingWidth: 40,
          leading: IconButton(
            icon: Icon(
              // Icons.arrow_back,
              Icons.arrow_back_ios_new,
              // size: 22,
              size: 16,
              color: Colors.grey[500],
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Impostazioni',
            // 'Le mie prestazioni',
            style: TextStyle(
                color: Colors.blue,
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 17
            ),
          ),
          actions: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                await userProvider.logout(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Icon(
                  Icons.logout,
                  size: 25,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
      // body: buildSettingsList(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          // backgroundColor: Colors.white,
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15),
                  child: Text(
                    'Account',
                    style: GoogleFonts.roboto(
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                          //color: Color.fromRGBO(245, 93, 62, 1),
                          // background:
                          // letterSpacing: -3,
                          fontSize: 15,
                          //fontWeight: FontWeight.w200,
                        ),
                    ),
                ),
              ],
            ),

            SizedBox(height: 20,),

            Center(
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (){
                  if(UserPreferences.getIsLogged()!){
                    Navigator.push(
                      context,
                      PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: EditProfileImageScreen()
                      ),
                    );
                  }
                },
                child: Stack(
                  // fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Hero(
                      tag: 'changeImage',
                      child: Card(
                        color: Colors.grey[200],
                        // borderRadius: BorderRadius.circular(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 3,
                        child: FutureImage(
                          userProvider.user != null && userProvider.user!.profile_image != null ? userProvider.user!.profile_image! : 'username@nurebo.com',
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.3,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      right: -12,
                      child: Container(
                        width: 40,
                        child: FloatingActionButton(
                          // onPressed: context.read<CounterModel>().increment,
                          // tooltip: 'Increment',
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                          ),
                          backgroundColor: Colors.grey[500],
                          onPressed: () {  },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // ListTile(
            //   title: Text("Immagine Profilo"),
            //   // title: Text(userProvider.user.profile_image.toString()),
            //   trailing: Icon(
            //     Icons.arrow_forward_ios_sharp,
            //     size: 22,
            //   ),
            //   leading: CircleAvatar(
            //     maxRadius: 20,
            //     minRadius: 20,
            //     backgroundColor: Colors.grey[300],
            //     backgroundImage: CachedNetworkImageProvider(
            //       // userProvider.user ?? 'profile_image',
            //       userProvider.user != null && userProvider.user.profile_image != null ? userProvider.user.profile_image : 'username@nurebo.com',
            //     ),
            //   ),
            //   // subtitle: '@moltenius',
            //   // subtitle: Text(userProvider.user.username),
            //   subtitle: Text(
            //     // userProvider.user.profile_image.toString(),
            //     // userProvider.user ?? 'Immagine Profilo',
            //     userProvider.user != null && userProvider.user.profile_image != null ? userProvider.user.profile_image.toString() : 'Immagine Profilo',
            //     maxLines: 2,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            //   onTap: () {
            //     if(UserPreferences.getIsLogged()){
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: UpbookingProfileImageScreen()
            //
            //         ),
            //       );
            //     }
            //   },
            // ),
            // SizedBox(height: 10),

            // ListTile(
            //   title: Text('Username'),
            //   trailing: Icon(
            //     Icons.arrow_forward_ios_sharp,
            //     size: 22,
            //   ),
            //   leading: const Padding(
            //     padding: EdgeInsets.only(top: 7),
            //     child: Icon(Icons.account_circle_outlined, size: 25,),
            //   ),
            //   // subtitle: '@moltenius',
            //   subtitle: Text(
            //       // userProvider.user/*.username*/ ?? 'Username',
            //     userProvider.user != null && userProvider.user!.username != null ? userProvider.user!.username! : 'Username',
            //   ),
            //   onTap: () {
            //     if(UserPreferences.getIsLogged()!){
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: EditUsernameScreen(user: userProvider.user,)
            //         ),
            //       );
            //     }
            //   },
            // ),

            ListTile(
              title: Text('Nome e Cognome'),
              trailing: Icon(
                Icons.arrow_forward_ios_sharp,
                size: 22,
              ),
              leading: const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.perm_identity_outlined, size: 25,),
              ),
              // subtitle: '@moltenius',
              subtitle: Text(
                  // userProvider.user/*.username*/ ?? 'Username',
                userProvider.user != null && userProvider.user!.name != null ? userProvider.user!.name! : 'Nome',
              ),
              onTap: () {
                if(UserPreferences.getIsLogged()!){
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: EditNameScreen()
                    ),
                  );
                }
              },
            ),

            // ListTile(
            //   title: Text('Numero di Telefono'),
            //   trailing: Icon(
            //     Icons.arrow_forward_ios_sharp,
            //     size: 22,
            //   ),
            //   isThreeLine: false,
            //   leading: Padding(
            //     padding: EdgeInsets.only(top: 7),
            //     child: Icon(Icons.phone_outlined, size: 25,),
            //   ),
            //   // subtitle: '+39 371 658 4578',
            //   subtitle: Text(
            //     // userProvider.user/*.phone_number*/ ?? 'Numero di Telefono',
            //     userProvider.user != null && userProvider.user.phone_number != null ? userProvider.user.phone_number : 'Numero di Telefono',
            //
            //   ),
            //   onTap: () {
            //     if(UserPreferences.getIsLogged()){
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: UpdatePhoneNumberScreen()
            //         ),
            //       );
            //     }
            //
            //   },
            // ),

            ListTile(
              title: Text('Email'),
              trailing: Icon(
                Icons.arrow_forward_ios_sharp,
                size: 22,
              ),
              leading: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.email_outlined, size: 25,),
              ),
              // subtitle: 'metauros95@gmail.com',
              subtitle: Text(
                  // userProvider.user/*.email*/ ?? 'Email',
                userProvider.user != null && userProvider.user!.email != null ? userProvider.user!.email! : 'Email',
              ),
              onTap: () {
                if(UserPreferences.getIsLogged()!){
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: EditEmailScreen(/*user: userProvider.user,*/)
                    ),
                  );
                }
              },
            ),

            ListTile(
              title: Text('Descrizione'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 22,
                  ),
                ],
              ),
              leading: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.book_outlined, size: 25,),
              ),
              // subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              subtitle: Text(
                // userProvider.user/*.description*/ ?? 'Descrizione',
                userProvider.user != null && userProvider.user!.description != null ? userProvider.user!.description! : 'Descrizione',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                if(UserPreferences.getIsLogged()!){
                  Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        type: PageTransitionType.fade,
                        child: EditDescriptionScreen()
                    ),
                  );
                }

              },
            ),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 20, bottom: 5),
                  child: Text(
                    'Generale',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),

            ListTile(
              title: Text('Lingua'),
              subtitle: Text(
                  'Italiano'
              ),
              leading: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.language_outlined, size: 25,),
              ),
              // subtitle: 'Italiano',
              // onTap: () {
                // Navigator.of(context).push(
                //     MaterialPageRoute(
                //       builder: (_) => LanguagesScreen(),
                //     )
                // );
                // Navigator.push(
                //   context,
                //   PageTransition(
                //       duration: const Duration(milliseconds: 500),
                //       alignment: Alignment.center,
                //       type: PageTransitionType.rightToLeft,
                //       // child: UpbookingUsernameScreen(user: userProvider.user,)
                //       child: NotificationSettingsScreen(business: widget.business,)
                //   ),
                // );
              // },
            ),

            SizedBox(height: 10,),

            ListTile(
              title: Text(
                  'Pagamenti'
              ),
              // isThreeLine: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 40),
                child: Text(
                    'Attualmente sono disponibili solo pagamenti in contanti'
                ),
              ),
              leading: Icon(
                  Icons.payment_outlined
              ),
            ),

            SizedBox(height: 10,),

            // ListTile(
            //   title: Text(
            //     'Notifiche'
            //   ),
            //   leading: Icon(
            //       Icons.notifications_outlined
            //   ),
            //   onTap: (){
            //     if(UserPreferences.getIsLogged()!){
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //             duration: const Duration(milliseconds: 500),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: SettingsNotificationScreen()
            //         ),
            //       );
            //     }
            //
            //   },
            // ),

            // ListTile(title: Text('Sicurezza'), leading: Icon(Icons.lock_outline_rounded)),
            // ListTile(title: Text('Chat'), leading: Icon(Icons.chat_bubble_outline)),
            // ListTile(title: Text('Dati'), leading: Icon(Icons.sd_card_outlined)),

            // SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 10),
                  child: Text(
                    'Legale',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),

            // SizedBox(height: 5,),

            ListTile(
                title: Text('Termini di Servizio'), leading: Icon(Icons.description_outlined)),
            ListTile(
                title: Text('Licenze'),
                leading: Icon(Icons.collections_bookmark_outlined)
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 10),
                  child: Text(
                    'Altro',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            Center(
              child: OutlinedButton(
                onPressed: (){
                  if(UserPreferences.getIsLogged()!){
                    _showDeletingDialog(
                        "Premere su 'Elimina' se vuoi eliminare definitivamente il tuo account"
                    );
                    // Navigator.push(
                    //     context,
                    //     PageTransition(
                    //         duration: const Duration(milliseconds: 500),
                    //         alignment: Alignment.center,
                    //         type: PageTransitionType.fade,
                    //         child: DeleteAccount()
                    //     )
                    // );
                  }
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(15))
                ),
                child: Text(
                  "Elimina l'account",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    //color: Color.fromRGBO(245, 93, 62, 1),
                    // background:
                    // letterSpacing: -3,
                    fontSize: 14,
                    //fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),

            SizedBox(height: 25,),

            const Column(
              children: [
                Divider(
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  // child: Image.asset(
                  //   'assets/settings.png',
                  //   height: 50,
                  //   width: 50,
                  //   color: Color(0xFF777777),
                  // ),
                  child: Text(
                    // 'Versione: 2.4.0 (287)',
                    'Versione: ${Utils.version_name} (${Utils.version_id})',
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
