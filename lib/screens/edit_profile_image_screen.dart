import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/src/media_type.dart';


class EditProfileImageScreen extends StatefulWidget {

  const EditProfileImageScreen({Key? key});

  @override
  _EditProfileImageScreenState createState() => _EditProfileImageScreenState();
}

class _EditProfileImageScreenState extends State<EditProfileImageScreen> {
  late UserProvider userProvider;
  final ImagePicker _imagePicker = ImagePicker();
  // Future a = Future((){});

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

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    // users = UserPreferences.getUsers();
  }

  @override
  void dispose() {
    super.dispose();
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
            actions: [],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // SizedBox(height: 20,),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Hero(
                  tag: 'changeImage',
                  child: userProvider.user != null && userProvider.user!.profile_image != null ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FutureImage(
                      // userProvider.user.profile_image != null ? userProvider.user.profile_image : '',
                      userProvider.user != null && userProvider.user!.profile_image != null ? userProvider.user!.profile_image! : 'immagine profilo',
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.width * .7,
                    ),
                  ) : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        color: Colors.grey[200]
                      ),
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
                            int status = await userProvider.uploadProfileImage(/*XFile _image*/);
                            if(status == 200){
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
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
                                "Cambia Immagine Profilo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              )
                          ),
                        ),
                      ),
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
