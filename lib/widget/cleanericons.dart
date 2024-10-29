import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CleanerIcons {
  // Ear icon widget
  static Widget earIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFC4C3CB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset('assets/images/ear.svg'),
      ),
    );
  }

  // Thumbs-up icon widget
  static Widget thumbsUpIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFC4C3CB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset('assets/images/thumbs_up.svg'),
      ),
    );
  }
}
