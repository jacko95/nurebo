import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

// //import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nurebo/utils/utils.dart';
// //import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/widgets/image_cache_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class FutureImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double? height;
  final bool? forceNetworkImage;
  final Color? color;

  const FutureImage(this.imageUrl, {Key? key, required this.width, this.height, this.forceNetworkImage = false, this.color = Colors.transparent,});

  @override
  _FutureImageState createState() => _FutureImageState();
}

class _FutureImageState extends State<FutureImage>  {
  static final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  // late Future<dynamic> imageFuture;
  late Future<dynamic> imageFuture = downloadImageToCache();
  // late Future<dynamic> imageFuture = fetchImage();
  late Future<Uint8List?> cacheImageFuture;
  // final serverImageUrl = '${Utils.httpServerUrl}image?path=${widget.imageUrl}';
  late Uint8List? cacheImage;


  static void fetchImageIsolate(/*SendPort sendPort*/List<Object> arguments) async {
    SendPort sendPort = arguments[0] as SendPort;

    // const url = "https://api.nurebo.com/business/post";
    var url = '${Utils.httpServerUrl}image?path=${arguments[1]}';

    try {
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
          }
      );

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final responseBody = response.body;

        // Invia la risposta all'isolate principale tramite il SendPort
        sendPort.send(responseBody);

      }
      else {
        // La chiamata HTTP ha restituito uno stato diverso da 200
        // print('Errore durante la chiamata HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Si è verificato un errore durante la chiamata HTTP
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  /*void*/dynamic fetchImage() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, widget.imageUrl]);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      // if (message is String) {
      // final data = json.decode(message);
      // setState(() {
      //   jsonData = data.toString();
      // });
      try {
        await imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
        // print('messagefgd5gf5fg5');
        // print(message);
        return message;
      } catch (error) {
        // Gestisci l'errore qui
        // print(error);
      }

      // return message;
      // }
    });
  }

  Future<dynamic/*Uint8List?*/> downloadImageToCache(/*String imageUrl*/) async {
    // print("vvv5454cv5");

    // var url = Uri.parse(imageUrl);
    var url = Uri.parse('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // var url = Uri.parse(widget.imageUrl);

    var response = await http.get(
        url,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          'Accept-encoding': 'gzip, deflate',
          'Cache-Control': 'max-age=3600'
        }
    );

    // print("response");
    // print(response);

    // print('gg6dd6dd6');
    // print('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

    if(response.statusCode >= 200 && response.statusCode < 400) {
      // dynamic jsonData = json.decode(response.body);
      // print('jsonData');
      // print(jsonData);
      // print(jsonData.toString());
      // return jsonData.toString();

      // final response1 = await http.get(
      //   Uri.parse(response.body),
      //   headers: {
      //     'Accept': '*/*',
      //     'Content-Type': 'application/json',
      //     'Accept-encoding': 'gzip, deflate',
      //     'connection': 'keep-alive',
      //   },
      // );
      //
      // Uint8List result = await FlutterImageCompress.compressWithList(
      //   response1.bodyBytes,
      //   // minHeight: 1920,
      //   // minWidth: 1080,
      //   quality: 60,
      //   // rotate: 180,
      // );
      // // print(list.length);
      // // print(result.length);
      // print('result.lengthInBytes');
      // print('${(result.lengthInBytes / (1024 * 1024)).toStringAsFixed(3)} MBBBBBBBBB');

      // if (response1.statusCode == 200) {
      //
      // }

      // Future.wait([
      /*await*/ imageCacheBusiness.addImageToCache(
          '${Utils.httpServerUrl}image?path=${widget.imageUrl}'
        // snapshot.data!
      );
      // ]);
      // print(DateTime.now());

      // setState(() {
      //
      // });

      return response.body;
      // return response1.bodyBytes;
      // return result;
    }

    return [];
    // return null;
  }

  Future<Uint8List?> _getImage() async {
    Uint8List? cachedImage;

    do {
      await downloadImageToCache();
      // Sostituisci questa logica con la tua implementazione per scaricare l'immagine.
      cachedImage = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

      // if (cachedImage == null) {
      //   // Attendi prima di ritentare, puoi modificare la durata del ritardo a tuo piacimento.
      //   await Future.delayed(const Duration(seconds: 2));
      // }
    } while (cachedImage == null);

    return cachedImage;
  }

  Future<Uint8List?> _getImageFuture() async {
    Uint8List? cachedImage;
    do {
      // Qui puoi implementare la logica per scaricare l'immagine, ad esempio utilizzando un metodo asincrono.
      // Aspetta un po' prima di ritentare, puoi aggiungere un `await Future.delayed(Duration(seconds: 2));` ad esempio.
      // Imposta `cachedImage` con l'immagine scaricata o null se non riuscito.
      cachedImage = await downloadImage();
    } while (cachedImage == null);

    return cachedImage;
  }

  Future<Uint8List?> downloadImage() async {
    // Implementa la logica per scaricare l'immagine, ad esempio utilizzando http.get o un'altra libreria.
    // Restituisci l'immagine scaricata o null se non riuscito.
    // Puoi anche aggiungere un ritardo con `await Future.delayed(Duration(seconds: 2));` se vuoi ritentare dopo un certo periodo.
    return null; // Sostituisci con la tua logica di scaricamento dell'immagine.
  }

  @override
  void initState() {
    super.initState();
    // imageFuture = getImage();
    // cacheImageFuture = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // cacheImage = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}')!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _getImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          // Immagine scaricata con successo
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: widget.width,
            height: widget.height,
            isAntiAlias: true,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => Container(
              width: widget.width,
              height: widget.height,
              color: widget.color,
            ),
          );
        } else {
          // Attendi e ritenta
          return Container(
            width: widget.width,
            height: widget.height,
            color: widget.color,
          );
        }
      },
    );
  }

}
