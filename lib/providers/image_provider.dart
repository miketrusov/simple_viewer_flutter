import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../models/image_file.dart';
import '../services/file_service.dart';

// Provider for the file service
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

// State class for the image viewer
class ImageViewerState {
  final List<ImageFile> images;
  final int currentIndex;
  final bool isLoading;
  final String? errorMessage;
  final bool isFullScreen;
  final double rotation;

  ImageViewerState({
    this.images = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.errorMessage,
    this.isFullScreen = false,
    this.rotation = 0,
  });

  // Get currently selected image
  ImageFile? get currentImage {
    if (images.isEmpty || currentIndex < 0 || currentIndex >= images.length) {
      return null;
    }
    return images[currentIndex];
  }

  // Create a copy with modified properties
  ImageViewerState copyWith({
    List<ImageFile>? images,
    int? currentIndex,
    bool? isLoading,
    String? errorMessage,
    bool? clearError,
    bool? isFullScreen,
    double? rotation,
  }) {
    return ImageViewerState(
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError == true ? null : errorMessage ?? this.errorMessage,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      rotation: rotation ?? this.rotation,
    );
  }
}

// Provider for the image viewer state
final imageViewerProvider = StateNotifierProvider<ImageViewerNotifier, ImageViewerState>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return ImageViewerNotifier(fileService);
});

// Notifier class to manage image viewer state
class ImageViewerNotifier extends StateNotifier<ImageViewerState> {
  final FileService _fileService;

  ImageViewerNotifier(this._fileService) : super(ImageViewerState());

  // Close current folder/image
  void closeFolder() {
    state = ImageViewerState();
  }

  // Open a single image file
  Future<void> openImage() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final image = await _fileService.pickImage();
      
      if (image != null) {
        state = state.copyWith(
          images: [image],
          currentIndex: 0,
          isLoading: false,
          rotation: 0,
        );
      } else {
        // User canceled the picker
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to open image: ${e.toString()}',
      );
    }
  }

  // Open a folder of images
  Future<void> openFolder() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final images = await _fileService.pickFolder();
      
      if (images.isNotEmpty) {
        state = state.copyWith(
          images: images,
          currentIndex: 0,
          isLoading: false,
          rotation: 0,
        );
      } else {
        // Either user canceled or no images in folder
        state = state.copyWith(
          isLoading: false,
          errorMessage: images.isEmpty ? 'No supported images found in this folder.' : null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to open folder: ${e.toString()}',
      );
    }
  }

  // Navigate to next image
  void nextImage() {
    if (state.images.isEmpty) return;
    
    final nextIndex = (state.currentIndex + 1) % state.images.length;
    state = state.copyWith(
      currentIndex: nextIndex,
      rotation: 0,
    );
  }

  // Navigate to previous image
  void previousImage() {
    if (state.images.isEmpty) return;
    
    final prevIndex = (state.currentIndex - 1 + state.images.length) % state.images.length;
    state = state.copyWith(
      currentIndex: prevIndex,
      rotation: 0,
    );
  }

  // Navigate to specific image by index
  void goToImage(int index) {
    if (state.images.isEmpty || index < 0 || index >= state.images.length) return;
    
    state = state.copyWith(
      currentIndex: index,
      rotation: 0,
    );
  }

  // Toggle fullscreen mode
  Future<void> toggleFullScreen() async {
    // Toggle fullscreen state
    final isCurrentlyFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isCurrentlyFullScreen);
    
    // Update our state
    state = state.copyWith(isFullScreen: !isCurrentlyFullScreen);
  }

  // Rotate the current image
  void rotateImage(bool clockwise) {
    final rotationAmount = clockwise ? 90.0 : -90.0;
    final newRotation = (state.rotation + rotationAmount) % 360;
    state = state.copyWith(rotation: newRotation);
  }
}