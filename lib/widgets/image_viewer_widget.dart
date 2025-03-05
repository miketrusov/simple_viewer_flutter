import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_file.dart';
import '../providers/image_provider.dart';

class ImageViewerWidget extends ConsumerWidget {
  final ImageFile imageFile;
  final double rotation;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const ImageViewerWidget({
    super.key,
    required this.imageFile,
    required this.rotation,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = FocusNode();

    return Focus(
      focusNode: focusNode..requestFocus(),
      child: GestureDetector(
        onDoubleTap: onToggleFullScreen,
        onSecondaryTap: () {
          // Show context menu
          final RenderBox button = context.findRenderObject() as RenderBox;
          final position = button.localToGlobal(Offset.zero);
          
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx + button.size.width,
              position.dy,
              position.dx + button.size.width + 1,
              position.dy + 1,
            ),
            items: [
              PopupMenuItem(
                child: const Text('Rotate Right 90°'),
                onTap: () => ref.read(imageViewerProvider.notifier).rotateImage(true),
              ),
              PopupMenuItem(
                child: const Text('Rotate Left 90°'),
                onTap: () => ref.read(imageViewerProvider.notifier).rotateImage(false),
              ),
              PopupMenuItem(
                child: const Text('Reset Rotation'),
                onTap: () {
                  final notifier = ref.read(imageViewerProvider.notifier);
                  while (ref.read(imageViewerProvider).rotation != 0) {
                    notifier.rotateImage(true);
                  }
                },
              ),
            ],
          );
        },
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              // Image viewer with rotation
              Transform.rotate(
                angle: rotation * (3.1415926535897932 / 180),
                child: PhotoView(
                  imageProvider: FileImage(imageFile.file),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 4,
                  initialScale: PhotoViewComputedScale.contained,
                  scaleStateController: PhotoViewScaleStateController(),
                  backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  enableRotation: false, // We handle rotation ourselves
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, 
                            color: Colors.red, 
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Overlay controls
              Positioned(
                top: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Card(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFullScreen 
                              ? Icons.fullscreen_exit 
                              : Icons.fullscreen,
                          ),
                          tooltip: isFullScreen 
                            ? 'Exit Fullscreen (F)' 
                            : 'Enter Fullscreen (F)',
                          onPressed: onToggleFullScreen,
                        ),
                        PopupMenuButton<double>(
                          icon: const Icon(Icons.rotate_right),
                          tooltip: 'Rotate (< >)',
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 90,
                              child: Text('Rotate Right 90° (>)'),
                            ),
                            const PopupMenuItem(
                              value: -90,
                              child: Text('Rotate Left 90° (<)'),
                            ),
                            const PopupMenuItem(
                              value: 180,
                              child: Text('Rotate 180°'),
                            ),
                            const PopupMenuItem(
                              value: 0,
                              child: Text('Reset Rotation'),
                            ),
                          ],
                          onSelected: (value) {
                            final notifier = ref.read(imageViewerProvider.notifier);
                            if (value == 90) {
                              notifier.rotateImage(true);
                            } else if (value == -90) {
                              notifier.rotateImage(false);
                            } else if (value == 180) {
                              notifier.rotateImage(true);
                              notifier.rotateImage(true);
                            } else if (value == 0) {
                              while (ref.read(imageViewerProvider).rotation != 0) {
                                notifier.rotateImage(true);
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close Folder',
                          onPressed: () => ref.read(imageViewerProvider.notifier).closeFolder(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}