import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// StateNotifier to manage bell states
class BellStateNotifier extends StateNotifier<BellState> {
  BellStateNotifier() : super(BellState());

  void setPressed(bool isPressed) {
    state = state.copyWith(isPressed: isPressed);
  }

  void setClicked(bool isClicked) {
    state = state.copyWith(isClicked: isClicked);
  }
}

// State model
class BellState {
  final bool isPressed;
  final bool isClicked;

  BellState({this.isPressed = false, this.isClicked = false});

  BellState copyWith({bool? isPressed, bool? isClicked}) {
    return BellState(
      isPressed: isPressed ?? this.isPressed,
      isClicked: isClicked ?? this.isClicked,
    );
  }
}

// StateNotifierProvider
final bellStateProvider = StateNotifierProvider<BellStateNotifier, BellState>(
  (ref) => BellStateNotifier(),
);

class BellProfileWidget extends ConsumerWidget {
  final Function onBellTap;

  const BellProfileWidget({super.key, required this.onBellTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bellState = ref.watch(bellStateProvider);
    final bellNotifier = ref.read(bellStateProvider.notifier);

    return GestureDetector(
      onTap: () {
        bellNotifier.setClicked(true); // Set clicked state

        // Reset click state after animation
        Future.delayed(const Duration(milliseconds: 200), () {
          bellNotifier.setClicked(false);
          onBellTap(); // Trigger callback
        });
      },
      onLongPressStart: (_) => bellNotifier.setPressed(true), // Set pressed state
      onLongPressEnd: (_) => bellNotifier.setPressed(false), // Reset pressed state
      child: AnimatedScale(
        scale: bellState.isClicked ? 0.9 : 1.0, // Slightly scale down when clicked
        duration: const Duration(milliseconds: 200), // Smooth scaling
        child: SvgPicture.asset(
          bellState.isPressed ? 'assets/images/bellring.svg' : 'assets/images/bell.svg', // Change icon on long press
          width: 30.0,
          height: 30.0,
        ),
      ),
    );
  }
}
