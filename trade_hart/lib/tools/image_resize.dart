import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  static Future<Widget> getImageWithMaxSize(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final bytes = data.buffer.asUint8List();

    if (bytes.length <= 300 * 1024) {
      // Si la taille de l'image est déjà inférieure à 300 Ko, on la garde telle quelle.
      return Image.asset(imagePath);
    } else {
      // Si l'image dépasse 300 Ko, on la compresse.
      final List<int> compressedBytes =
          await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1024, // Hauteur minimale
        minWidth: 1024, // Largeur minimale
        quality: 90, // Qualité de compression (0-100)
      );

      return Image.memory(
        Uint8List.fromList(compressedBytes),
        fit: BoxFit.cover,
      );
    }
  }
}
