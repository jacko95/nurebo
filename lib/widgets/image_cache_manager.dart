import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nurebo/screens/home_screen.dart';


class ImageCacheBusiness {
  static final ImageCacheBusiness _instance = ImageCacheBusiness._internal();

  factory ImageCacheBusiness() {
    return _instance;
  }

  ImageCacheBusiness._internal();

  final Map<String, Uint8List> imageCache = {};


  Uint8List? getImageFromCache(String url) {
    // print('urlsffd');
    // print(url);

    if (imageCache.containsKey(url)) {
      return imageCache[url];
    }
    // await downloadImage(url);
    return null;
    // return _imageCache[url];
  }

  bool addImageBytesInCache(String url, Uint8List? bytes) {
    // print('urlsffd');
    // print(url);

    if (bytes != null) {
      if (bytes.lengthInBytes > 10000) {
        imageCache[url] = bytes;
        return true;
      }
    }
    // await downloadImage(url);
    return false;
    // return _imageCache[url];
  }

  // void addImageToCache(String url, Uint8List imageData) async {
  //   _imageCache[url] = imageData;
  // }

  // Future<void> addImageToCache(String url) async {
  //   if(_imageCache.keys.contains(url)){
  //     print('return');
  //     return;
  //   }
  //
  //   // print('_imageCache');
  //   // for(var e in _imageCache.keys){
  //   //   print(e);
  //   // }
  //
  //   // Effettua la richiesta GET al link firmato per ottenere i dati dell'immagine
  //   final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // print('urldfgg');
  //   // print(url);
  //
  //   if (response.statusCode == 200) {
  //     // print('response.body');
  //     // print(response.body);
  //     // final imageData = response.bodyBytes;
  //     // final imageData = response.body;
  //     // _imageCache[url] = imageData as Uint8List;
  //     // _imageCache[url] = imageData;
  //
  //     final response1 = await http.get(
  //       Uri.parse(response.body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //     );
  //
  //     if (response1.statusCode == 200) {
  //       // print('response1.body');
  //       // print(response1.body);
  //       final imageData1 = response1.bodyBytes;
  //       // final imageData = response.body;
  //
  //       _imageCache[url] = imageData1;
  //       // _imageCache.putIfAbsent(url, () => _imageCache[url] = imageData1);
  //
  //       // print('sfddggddg');
  //       // for(var e in _imageCache.keys){
  //       //   print(e);
  //       // }
  //
  //     } else {
  //       throw Exception('Failed to download image');
  //     }
  //   } else {
  //     throw Exception('Failed to download image');
  //   }
  // }

  void removeImageFromCache(String url) async {
    if (imageCache.keys.contains(url)) {
      imageCache.remove(url);
      // print('hit');
      // for (var element in imageCache.keys) {print(element);}
      // print(imageCache.containsKey(url));
      return;
    }
    // print('not hit');
  }

  Future<void> addImageToCache(String url) async {
    if (imageCache.keys.contains(url)) {
      // print('return');
      return;
    }

    final receivePort = ReceivePort();

    await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, url]);

    receivePort.listen((message) async {
      if (message is Uint8List) {

        // Uint8List result = await FlutterImageCompress.compressWithList(
        //   message,
        //   // minHeight: 1920,
        //   // minWidth: 1080,
        //   quality: 60,
        //   // rotate: 180,
        // );
        // // print(list.length);
        // // print(result.length);
        // print('result.lengthInBytes');
        // print('${(result.lengthInBytes / (1024 * 1024)).toStringAsFixed(3)} MBBB');

        imageCache[url] = message;
        // imageCache.addIf(true, url, message);

        if(imageCache.keys.length == 1) {
          // FlutterNativeSplash.remove();
          // print('DateTime.now()2');
          // print(DateTime.now());
        }

        // _imageCache[url] = result;

        // Uint8List myUint8List = Uint8List.fromList(message);
        // Directory customDirectory = Directory('ciccionessim'); // Specifica il percorso della cartella desiderata
        // if (!(await customDirectory.exists())) {
        //   customDirectory.createSync(recursive: true);
        //   String filePath = '${customDirectory.path}/gfbbdb5.jpg';
        //   final file = File(filePath);
        //   await file.writeAsBytes(myUint8List);
        //
        // }
        // Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        // Directory? appDocumentsDir = await getApplicationSupportDirectory();
        // String filePath = '${appDocumentsDir.path}/gfbbdb5.jpg';
        // final file = File(filePath);
        // await file.writeAsBytes(myUint8List);

        // final file = File('dgdgdg.jpg');
        // await file.writeAsBytes(message);
        // final sink = file.openWrite();
        // sink.add(message);
        // // sink.add(myUint8List);
        // sink.close();
        // // file.writeAsBytes(response1.bodyBytes);

        // print('imageCache.keys.length4');
        // print(imageCache.keys.length);
        // print(url);

        receivePort.close();
      } else {
        // print('Failed to download image 0');
      }
    });
  }

  static void fetchImageIsolate(List<Object> arguments) async {
    SendPort sendPort = arguments[0] as SendPort;
    String url = arguments[1] as String;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
        'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
        'X-App-Version-Name': Utils.version_name,
        'X-App-Version-Number': Utils.version_id.toString(),
        'X-Client-Type': 'User-Mobile-App',
      },
    );

    if (response.statusCode == 200) {
      final response1 = await http.get(
        Uri.parse(response.body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        },
      );

      if (response1.statusCode == 200) {
        sendPort.send(response1.bodyBytes);
      }
      else {
        // print('Failed to download image 1');
        // print(response1.statusCode);
        // print(url);
        // print(response.body);
      }
    }
    else {
      // print('Failed to download image 2');
    }
  }

  Future<Uint8List> compressImage(Uint8List list) async {
    Uint8List result = await FlutterImageCompress.compressWithList(
      list,
      // minHeight: 1920,
      // minWidth: 1080,
      quality: 10,
      // rotate: 180,
    );
    // print(list.length);
    // print(result.length);
    // print('result.lengthInBytes');
    // print((result.lengthInBytes / (1024 * 1024)).toStringAsFixed(3));

    return result;
  }

// Future<Uint8List> downloadImage(String url) async {
//   // Effettua il download dell'immagine e restituisci un Uint8List con i dati binari
//
//   // Esempio di utilizzo del pacchetto http per il download dell'immagine
//   final response = await http.get(Uri.parse(url));
//   if (response.statusCode == 200) {
//     final imageData = response.bodyBytes;
//     _imageCache[url] = imageData;
//     return imageData;
//   } else {
//     // print(url);
//     throw Exception('Failed to download image');
//   }
// }
}
