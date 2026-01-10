import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key,});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    dateTime2 = DateTime.now();
    // print('DateTime.now().toIso8601String()2');
    // print(dateTime2!.toIso8601String());
    // print('dateTime2!.difference(dateTime1!) 1');
    // print(dateTime2!.difference(dateTime1!));
    // Fluttertoast.showToast(
    //   msg: '${dateTime2!.difference(dateTime1!)} 1',
    //   backgroundColor: Colors.grey[700],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/png/oO4OzsRFBmXxBz4sQUdA.png",
              height: 60,
            ),
          ),
          Positioned(
            // bottom: MediaQuery.of(context).size.width * 0.15,
            top: MediaQuery.of(context).size.height * 0.89,
            right: MediaQuery.of(context).size.width * 0.5 - 15,
            height: 30,
            width: 30,
            // child: const CupertinoActivityIndicator(radius: 15),
            child: CircularProgressIndicator(color: Colors.orange[300]),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.65),
            child: Center(
              child: Text(
                // 'Attendere. Può richiedere fino a 10 secondi',
                'Attendere. Stiamo caricando i locali vicino a te',
                // textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
