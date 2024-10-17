import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;
  const CustomBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid white background
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
        // Gradient top section
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4C7D90),
                  Colors.white
                ],
              ),
            ),
          ),
        ),
        // Content over the background
        child,
      ],
    );
  }
}
