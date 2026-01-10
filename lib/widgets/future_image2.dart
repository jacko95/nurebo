import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/image_cache_manager.dart';

class FutureImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double? height;
  final bool? forceNetworkImage;
  final Color? color;

  const FutureImage(
      this.imageUrl, {
        Key? key,
        required this.width,
        this.height,
        this.forceNetworkImage = false,
        this.color = Colors.transparent,
      });

  @override
  _FutureImageState createState() => _FutureImageState();
}

class _FutureImageState extends State<FutureImage> {
  static final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();

  Future<Uint8List?> _getImage() async {
    Uint8List? cachedImage;

    do {
      await downloadImageToCache();
      cachedImage = imageCacheBusiness.getImageFromCache(
        '${Utils.httpServerUrl}image?path=${widget.imageUrl}',
      );
    } while (cachedImage == null);

    return cachedImage;
  }

  Future<void> downloadImageToCache() async {
    var url = Uri.parse('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

    try {
      final response = await http.get(
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
          'Cache-Control': 'max-age=3600',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 400) {
        await imageCacheBusiness.addImageToCache(
          '${Utils.httpServerUrl}image?path=${widget.imageUrl}',
        );
      }
    } catch (e) {
      // Gestisci l'errore qui
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _getImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
