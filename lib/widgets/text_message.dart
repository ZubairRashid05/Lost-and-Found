import 'package:flutter/material.dart';
import 'package:lost_and_found/widgets/app_image.dart';

class TextMessage extends StatelessWidget {
  final String body;
  final String? imageUrl;
  final bool isMine;

  const TextMessage({
    super.key,
    required this.body,
    required this.imageUrl,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isMine ? Theme.of(context).colorScheme.onPrimary : null;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasBody = body.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(
              source: imageUrl!,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        if (hasImage && hasBody) const SizedBox(height: 8),
        if (hasBody) Text(body, style: TextStyle(color: textColor)),
      ],
    );
  }
}
