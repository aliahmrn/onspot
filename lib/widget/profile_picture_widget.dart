import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';


class ProfilePictureWidget extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? overlay;

  const ProfilePictureWidget({
    Key? key,
    required this.radius,
    this.imageUrl,
    this.onTap,
    this.overlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();

    // Determine if the image is a valid network URL or a local file path
    final bool isNetworkImage = imageUrl != null &&
        Uri.tryParse(imageUrl!)?.isAbsolute == true;

    final bool isLocalFile = imageUrl != null &&
        !isNetworkImage &&
        imageUrl!.startsWith('/'); // Local file paths typically start with '/'

    logger.i(
        '💡 Rendering profile picture. Image URL: $imageUrl, Is Network: $isNetworkImage, Is Local File: $isLocalFile');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: isNetworkImage
                ? NetworkImage(imageUrl!)
                : isLocalFile
                    ? FileImage(File(imageUrl!)) // Use FileImage for local files
                    : const AssetImage('assets/images/default.webp') as ImageProvider,
            backgroundColor: Colors.grey[200], // Placeholder background
            onBackgroundImageError: (error, stackTrace) {
              logger.e('❌ Error loading image: $imageUrl. Falling back to default.');
            },
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}
