import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Provider to manage the icon states (e.g., visibility or size adjustment)
final iconSizeProvider = StateProvider<double>((ref) => 50.0);

class CleanIcons extends ConsumerWidget {
  const CleanIcons({super.key}); // Converted 'key' to a super parameter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconSize = ref.watch(iconSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Icons Example'),
        actions: [
          IconButton(
            onPressed: () {
              final notifier = ref.read(iconSizeProvider.notifier);
              notifier.state = notifier.state == 50.0 ? 70.0 : 50.0; // Toggle icon size
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MopIcon(size: iconSize),           // Example usage of MopIcon
            VacuumingIcon(size: iconSize),     // Example usage of VacuumingIcon
            WipeIcon(size: iconSize),          // Example usage of WipeIcon
            WindowIcon(size: iconSize),        // Example usage of WindowIcon
            ToiletIcon(size: iconSize),        // Example usage of ToiletIcon
          ],
        ),
      ),
    );
  }
}

// Reusable MopIcon Widget
class MopIcon extends StatelessWidget {
  final double size;

  const MopIcon({super.key, required this.size}); // Converted 'key' to a super parameter

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

  const VacuumingIcon({super.key, required this.size}); // Converted 'key' to a super parameter

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

  const WipeIcon({super.key, required this.size}); // Converted 'key' to a super parameter

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

  const WindowIcon({super.key, required this.size}); // Converted 'key' to a super parameter

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

  const ToiletIcon({super.key, required this.size}); // Converted 'key' to a super parameter

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/toilet.svg',
      height: size,
      width: size,
    );
  }
}
