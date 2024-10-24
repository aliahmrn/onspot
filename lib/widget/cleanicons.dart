import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CleanIcons extends StatelessWidget {
  const CleanIcons({Key? key}) : super(key: key);  // 'key' passed to super

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Icons Example'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            MopIcon(size: 50),           // Example usage of MopIcon
            VacuumingIcon(size: 50),      // Example usage of VacuumingIcon
            WipeIcon(size: 50),           // Example usage of WipeIcon
            WindowIcon(size: 50),         // Example usage of WindowIcon
            ToiletIcon(size: 50),         // Example usage of ToiletIcon
          ],
        ),
      ),
    );
  }
}

// Reusable MopIcon Widget
class MopIcon extends StatelessWidget {
  final double size;

  const MopIcon({super.key, this.size = 24.0}); // Added 'super.key' for key parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/mop.svg',
      height: size,
      width: size,
    );
  }
}

// Reusable VacuumingIcon Widget
class VacuumingIcon extends StatelessWidget {
  final double size;

  const VacuumingIcon({super.key, this.size = 24.0}); // Added 'super.key' for key parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/vacuuming.svg',
      height: size,
      width: size,
    );
  }
}

// Reusable WipeIcon Widget
class WipeIcon extends StatelessWidget {
  final double size;

  const WipeIcon({super.key, this.size = 24.0}); // Added 'super.key' for key parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/wipe.svg',
      height: size,
      width: size,
    );
  }
}

// Reusable WindowIcon Widget
class WindowIcon extends StatelessWidget {
  final double size;

  const WindowIcon({super.key, this.size = 24.0}); // Added 'super.key' for key parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/window.svg',
      height: size,
      width: size,
    );
  }
}

// Reusable ToiletIcon Widget
class ToiletIcon extends StatelessWidget {
  final double size;

  const ToiletIcon({super.key, this.size = 24.0}); // Added 'super.key' for key parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/toilet.svg',
      height: size,
      width: size,
    );
  }
}
