import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CleanerIcons {
  // Ear icon widget with secondary color background, onSecondary icon color, and outline color
  static Widget earIcon(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outlineColor), // Outline color
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(
          'assets/images/ear.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn), // Icon color
        ),
      ),
    );
  }

  // Thumbs-up icon widget with secondary color background, onSecondary icon color, and outline color
  static Widget thumbsUpIcon(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outlineColor), // Outline color
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(
          'assets/images/thumbs_up.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn), // Icon color
        ),
      ),
    );
  }
}
