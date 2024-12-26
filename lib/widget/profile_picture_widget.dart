import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

    final bool isValidNetworkImage = imageUrl != null &&
        imageUrl!.isNotEmpty &&
        Uri.tryParse(imageUrl!)?.isAbsolute == true;

    logger.i('💡 Rendering profile picture. Valid image URL: $isValidNetworkImage');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: isValidNetworkImage
                ? NetworkImage(imageUrl!)
                : const AssetImage('assets/images/default.webp') as ImageProvider,
            backgroundColor: Colors.grey[200], // Placeholder background
            onBackgroundImageError: (error, stackTrace) {
            logger.e('❌ Error loading network image: $imageUrl. Falling back to default.');
            },
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}
