import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class ImageUtils {
  /// Gets image dimensions from a file
  static Future<(int width, int height)?> getImageDimensions(File file) async {
    ui.Codec? codec;
    try {
      final bytes = await file.readAsBytes();
      codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final width = image.width;
      final height = image.height;
      
      // Clean up
      image.dispose();
      
      return (width, height);
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    } finally {
      codec?.dispose();
    }
  }
}