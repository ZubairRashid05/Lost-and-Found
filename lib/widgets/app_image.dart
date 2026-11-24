import 'dart:io';

import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  static ImageProvider<Object> providerFor(String source) {
    if (source.startsWith('http')) return NetworkImage(source);
    if (File(source).existsSync()) return FileImage(File(source));
    return AssetImage(source);
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: providerFor(source),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        final total = progress.expectedTotalBytes;
        return SizedBox(
          width: width,
          height: height ?? 200,
          child: Center(
            child: CircularProgressIndicator(
              value: total == null
                  ? null
                  : progress.cumulativeBytesLoaded / total,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height ?? 200,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hide_image_sharp, size: 48),
                // Text('Could not load this picture'),
              ],
            ),
          ),
        );
      },
    );
  }
}
