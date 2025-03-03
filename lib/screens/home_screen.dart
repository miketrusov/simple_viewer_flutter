import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/image_provider.dart';
import '../widgets/image_viewer_widget.dart';
import '../widgets/status_bar_widget.dart';
import '../widgets/gallery_widget.dart';

// Provider for gallery collapsed state
final galleryCollapsedProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    ref.read(imageViewerProvider.notifier).state = 
      ref.read(imageViewerProvider).copyWith(isFullScreen: true);
  }

  @override
  void onWindowLeaveFullScreen() {
    ref.read(imageViewerProvider.notifier).state = 
      ref.read(imageViewerProvider).copyWith(isFullScreen: false);
  }

  @override
  Widget build(BuildContext context) {
    final imageViewerState = ref.watch(imageViewerProvider);
    final imageViewerNotifier = ref.read(imageViewerProvider.notifier);

    // Handle keyboard events
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            imageViewerNotifier.previousImage();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            imageViewerNotifier.nextImage();
          } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            imageViewerNotifier.toggleFullScreen();
          } else if (event.logicalKey == LogicalKeyboardKey.escape && 
                     imageViewerState.isFullScreen) {
            imageViewerNotifier.toggleFullScreen();
          } else if (event.logicalKey == LogicalKeyboardKey.period) {
            imageViewerNotifier.rotateImage(true);
          } else if (event.logicalKey == LogicalKeyboardKey.comma) {
            imageViewerNotifier.rotateImage(false);
          }
        }
      },
      child: Scaffold(
        body: imageViewerState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, imageViewerState, ref),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ImageViewerState state, WidgetRef ref) {
    final imageViewerNotifier = ref.read(imageViewerProvider.notifier);

    // Show error message if there is one
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => imageViewerNotifier.closeFolder(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    // Show welcome message if no images are loaded
    if (state.images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library, size: 72, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Simple Viewer',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Open an image or folder to get started',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => imageViewerNotifier.openImage(),
                  icon: const Icon(Icons.photo),
                  label: const Text('Open Image'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => imageViewerNotifier.openFolder(),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Folder'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show image viewer with gallery when images are loaded
    return Column(
      children: [
        // Main content area
        Expanded(
          child: state.currentImage != null
              ? ImageViewerWidget(
                  imageFile: state.currentImage!,
                  rotation: state.rotation,
                  isFullScreen: state.isFullScreen,
                  onToggleFullScreen: () => imageViewerNotifier.toggleFullScreen(),
                )
              : const SizedBox.shrink(),
        ),
        // Status bar
        if (!state.isFullScreen)
          StatusBarWidget(imageFile: state.currentImage),
        // Gallery
        if (!state.isFullScreen)
          GalleryWidget(
            images: state.images,
            currentIndex: state.currentIndex,
            onImageSelected: (index) => imageViewerNotifier.goToImage(index),
            isCollapsed: ref.watch(galleryCollapsedProvider),
            onToggleCollapsed: () => ref
                .read(galleryCollapsedProvider.notifier)
                .update((state) => !state),
          ),
      ],
    );
  }
}