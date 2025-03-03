import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_file.dart';
import '../utils/image_utils.dart';

class FileService {
  // List of supported image formats
  static const List<String> supportedFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'tif'
  ];

  // Pick a single image file
  Future<ImageFile?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedFormats,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final imageFile = ImageFile.fromFile(file);
      
      // Load image dimensions
      final dimensions = await ImageUtils.getImageDimensions(file);
      if (dimensions != null) {
        imageFile.updateDimensions(dimensions.$1, dimensions.$2);
      }
      
      // Save to recent files
      await _saveRecentFile(imageFile.path);
      
      return imageFile;
    }
    return null;
  }

  // Pick a folder and return all image files in it
  Future<List<ImageFile>> pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    
    if (result != null) {
      return loadImagesFromFolder(result);
    }
    return [];
  }

  // Load all images from a folder
  Future<List<ImageFile>> loadImagesFromFolder(String folderPath) async {
    final directory = Directory(folderPath);
    final List<ImageFile> imageFiles = [];
    
    try {
      final files = directory.listSync();
      
      // First create all ImageFile objects
      for (final fileEntity in files) {
        if (fileEntity is File) {
          final extension = fileEntity.path.split('.').last.toLowerCase();
          
          if (supportedFormats.contains(extension)) {
            imageFiles.add(ImageFile.fromFile(fileEntity));
          }
        }
      }
      
      // Sort files by name
      imageFiles.sort((a, b) => a.name.compareTo(b.name));
      
      // Then load dimensions in parallel for better performance
      await Future.wait(
        imageFiles.map((imageFile) async {
          final dimensions = await ImageUtils.getImageDimensions(imageFile.file);
          if (dimensions != null) {
            imageFile.updateDimensions(dimensions.$1, dimensions.$2);
          }
        })
      );
      
      // Save folder to recent folders
      await _saveRecentFolder(folderPath);
      
      return imageFiles;
    } catch (e) {
      debugPrint('Error loading images from folder: $e');
      return [];
    }
  }

  // Save recent file path to SharedPreferences
  Future<void> _saveRecentFile(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFiles = prefs.getStringList('recentFiles') ?? [];
    
    // Add to the start of the list and remove duplicates
    if (recentFiles.contains(filePath)) {
      recentFiles.remove(filePath);
    }
    recentFiles.insert(0, filePath);
    
    // Keep only the 10 most recent files
    if (recentFiles.length > 10) {
      recentFiles.removeRange(10, recentFiles.length);
    }
    
    await prefs.setStringList('recentFiles', recentFiles);
  }

  // Save recent folder path to SharedPreferences
  Future<void> _saveRecentFolder(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentFolders = prefs.getStringList('recentFolders') ?? [];
    
    // Add to the start of the list and remove duplicates
    if (recentFolders.contains(folderPath)) {
      recentFolders.remove(folderPath);
    }
    recentFolders.insert(0, folderPath);
    
    // Keep only the 5 most recent folders
    if (recentFolders.length > 5) {
      recentFolders.removeRange(5, recentFolders.length);
    }
    
    await prefs.setStringList('recentFolders', recentFolders);
  }

  // Get list of recent files
  Future<List<String>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recentFiles') ?? [];
  }

  // Get list of recent folders
  Future<List<String>> getRecentFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recentFolders') ?? [];
  }
}