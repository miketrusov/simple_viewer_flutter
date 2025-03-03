import 'package:flutter/material.dart';
import '../models/image_file.dart';

class GalleryWidget extends StatefulWidget {
  final List<ImageFile> images;
  final int currentIndex;
  final Function(int) onImageSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

  static const double _thumbnailSize = 80.0;
  static const double _collapsedHeight = 24.0;
  static const double _expandedHeight = _thumbnailSize + 16.0;

  const GalleryWidget({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onImageSelected,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  final ScrollController _scrollController = ScrollController();
  int _lastIndex = 0;

  @override
  void didUpdateWidget(GalleryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll when current index changes
    if (widget.currentIndex != _lastIndex && !widget.isCollapsed) {
      _lastIndex = widget.currentIndex;
      _scrollToCurrentImage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentImage() {
    if (!_scrollController.hasClients) return;

    // Calculate the target scroll offset
    final double targetOffset = widget.currentIndex * (GalleryWidget._thumbnailSize + 8.0);
    final double currentOffset = _scrollController.offset;
    final double viewportWidth = _scrollController.position.viewportDimension;

    // Only scroll if the target is not fully visible
    if (targetOffset < currentOffset || 
        targetOffset + GalleryWidget._thumbnailSize > currentOffset + viewportWidth) {
      // Center the thumbnail in the viewport
      final double centerOffset = targetOffset - (viewportWidth / 2) + (GalleryWidget._thumbnailSize / 2);
      
      _scrollController.animateTo(
        centerOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.isCollapsed ? GalleryWidget._collapsedHeight : GalleryWidget._expandedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Collapse/expand handle
          GestureDetector(
            onTap: widget.onToggleCollapsed,
            child: Container(
              height: GalleryWidget._collapsedHeight,
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  widget.isCollapsed ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ),
            ),
          ),
          // Thumbnails
          if (!widget.isCollapsed)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.images.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  final isSelected = index == widget.currentIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () => widget.onImageSelected(index),
                      child: Container(
                        width: GalleryWidget._thumbnailSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.file(
                            image.file,
                            fit: BoxFit.cover,
                            cacheWidth: GalleryWidget._thumbnailSize.toInt() * 2,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.error,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}