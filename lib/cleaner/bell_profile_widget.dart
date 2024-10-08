import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BellProfileWidget extends StatefulWidget {
  final Function onBellTap;

  const BellProfileWidget({super.key, required this.onBellTap});

  @override
  _BellProfileWidgetState createState() => _BellProfileWidgetState();
}

class _BellProfileWidgetState extends State<BellProfileWidget> {
  bool _isHovered = false; // Track hover state
  bool _isClicked = false; // Track click state for animation

  void _toggleBell() {
    setState(() {
      _isClicked = true; // Trigger click effect
    });

    // Add a 0.5-second delay before calling the callback function
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onBellTap(); // Trigger the provided callback after the delay
    });

    // Reset the click effect after animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isClicked = false; // Reset click state after animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true; // Change bell image on hover
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false; // Revert bell image when hover ends
        });
      },
      child: GestureDetector(
        onTap: _toggleBell, // Handle bell action on tap
        child: AnimatedScale(
          scale: _isClicked ? 0.9 : 1.0, // Scale down when clicked
          duration: const Duration(milliseconds: 200), // Smooth transition
          child: SvgPicture.asset(
            _isHovered
                ? 'assets/images/bellring.svg'
                : 'assets/images/bell.svg', // Show bellring.svg on hover
            width: 30.0,
            height: 30.0,
          ),
        ),
      ),
    );
  }
}
