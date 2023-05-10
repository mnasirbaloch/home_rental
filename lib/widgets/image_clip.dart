import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageClip extends StatelessWidget {
  final String url;
  final double? width, height;
  const ImageClip({Key? key, required this.url, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 85,
      height: height ?? 85,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ExtendedImage.network(
          url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
