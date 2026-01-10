import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo/main.dart';


class EditNameScreen extends StatefulWidget {
  // final User user;

  const EditNameScreen({super.key/*, this.user*/});

  @override
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  TextEditingController nameController = TextEditingController(text: '');
  late UserProvider userProvider;

  Future updateName() async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/name");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/name");

    Map<String, dynamic> body = {
      'name': nameController.text,
      'user_id': userProvider.user!.id,
    };

    var response = await http.patch(
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

    if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await userProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print("name aggiornata");

      userProvider.updateName(nameController.text);

      // Fluttertoast.showToast(
      //   msg: 'Nome aggiornato',
      //   backgroundColor: Colors.grey[800],
      // )/*..then((value) => Navigator.pop(context))..then((value) => Phoenix.rebirth(context))*/;
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Nome aggiornato',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      Navigator.pop(context);

      return jsonData;
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.user!.name != null){
      setState(() {
        nameController.text = userProvider.user!.name!;
      });
    }
    else{
      setState(() {
        nameController.text = '';
      });
    }

  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            // title: Text(
            //     "Impostazioni",
            //     style: GoogleFonts.roboto(
            //       color: Colors.blue,
            //       //color: Color.fromRGBO(245, 93, 62, 1),
            //       // background:
            //       // letterSpacing: -3,
            //       // fontSize: 40,
            //       fontWeight: FontWeight.w800,
            //     )
            // ),
            centerTitle: true,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_outlined,
                color: Colors.grey[500],
                size: 27,
              ),
              color: Colors.black,
            ),
            actions: [
              // IconButton(
              //   onPressed: () async {
              //     await UserPreferences.init();
              //     await UserPreferences.setIsLogged(false);
              //     await UserPreferences.setUser('');
              //
              //     /*Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => UsernameScreen()
              //       ),
              //       (route) => false
              //   );*/
              //     Phoenix.rebirth(context);
              //
              //   },
              //   icon: Icon(
              //     Icons.exit_to_app_rounded,
              //     color: Colors.grey[700],
              //     size: 27,
              //   ),
              //   color: Colors.black,
              // ),
            ],
            // backgroundColor: Colors.grey[900],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20,),
                // Lottie.asset(
                //   // 'assets/animations/69165-consulting-creative-3d-animation.json',
                //   'assets/animations/71676-ui-and-ux-design-isometric-animation.json',
                //   // controller: animationController,
                //   width: 200,
                //   height: 200,
                //   // repeat: true
                // ),
                Center(
                  child: Image.asset(
                    'assets/png/Saly-16.png',
                    height: MediaQuery.of(context).size.height * .35,
                    // width: MediaQuery.of(context).size.width * .4,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 30),
                  child: TextField(
                    // obscureText: !_isVisible,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    enabled: true,

                    enableInteractiveSelection: true,
                    /*onChanged: (_) async {
                      // setState(() async {
                      await existsUser();
                      // });
                      //print(usernameController.text);
                      //print(usernameExists.toString());
                    },*/
                    // onChanged: (password) => onPasswordChanged(password),

                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[700],
                          size: 21,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // setState(() {
                          //   _isVisible = !_isVisible;
                          // });
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 0),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      hintText: "Nome",
                      enabled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: MaterialButton(
                          onPressed: () async {
                            await updateName();
                          },
                          // minWidth: MediaQuery.of(context).size.width * 0.6,
                          elevation: 0,
                          color: Colors.blue[500],
                          padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          // elevation: 0,
                          // padding: EdgeInsets.all(18),
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(20)
                          // ),

                          child: Center(
                              child: Text(
                                "Salva",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
