import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BellProfileWidget extends StatefulWidget {
  final Function onBellTap;

  const BellProfileWidget({super.key, required this.onBellTap});

  @override
  BellProfileWidgetState createState() => BellProfileWidgetState();
}

class BellProfileWidgetState extends State<BellProfileWidget> {
  bool _isPressed = false; // Track long press for hover-like effect
  bool _isClicked = false; // Track tap state for scaling

  void _handleTap() {
    setState(() {
      _isClicked = true; // Trigger click effect
    });

    // Add a small delay before resetting the click effect
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isClicked = false; // Reset click state after animation
      });
      widget.onBellTap(); // Trigger the provided callback
    });
  }

  void _handleLongPress(bool isPressed) {
    setState(() {
      _isPressed = isPressed; // Update the state based on press
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap, // Handle bell tap
      onLongPressStart: (_) => _handleLongPress(true), // Start long press
      onLongPressEnd: (_) => _handleLongPress(false), // End long press
      child: AnimatedScale(
        scale: _isClicked ? 0.9 : 1.0, // Slightly scale down when clicked
        duration: const Duration(milliseconds: 200), // Smooth scaling
        child: SvgPicture.asset(
          _isPressed ? 'assets/images/bellring.svg' : 'assets/images/bell.svg', // Change icon on long press
          width: 30.0,
          height: 30.0,
        ),
      ),
    );
  }
}
