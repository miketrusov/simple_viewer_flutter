import 'dart:io';

class ImageFile {
  final File file;
  final String path;
  final String name;
  final int size;
  final DateTime lastModified;
  int? width;
  int? height;
  
  ImageFile({
    required this.file,
    required this.path,
    required this.name,
    required this.size,
    required this.lastModified,
    this.width,
    this.height,
  });

  // Factory constructor to create an ImageFile from a File object
  factory ImageFile.fromFile(File file) {
    return ImageFile(
      file: file,
      path: file.path,
      name: file.path.split(Platform.pathSeparator).last,
      size: file.lengthSync(),
      lastModified: file.lastModifiedSync(),
    );
  }

  // Method to update image dimensions
  void updateDimensions(int width, int height) {
    this.width = width;
    this.height = height;
  }

  // Get formatted file size
  String get formattedSize {
    final kb = size / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = kb / 1024;
      return '${mb.toStringAsFixed(1)} MB';
    }
  }

  // Get metadata for display
  String get metadata {
    if (width != null && height != null) {
      return '$formattedSize • $width × $height';
    }
    return formattedSize;
  }
}