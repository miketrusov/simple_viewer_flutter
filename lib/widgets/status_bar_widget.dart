import 'package:flutter/material.dart';
import '../models/image_file.dart';

class StatusBarWidget extends StatelessWidget {
  final ImageFile? imageFile;

  const StatusBarWidget({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            imageFile!.name,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            imageFile!.metadata,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            'Modified: ${imageFile!.lastModified.toLocal().toString().split('.')[0]}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}