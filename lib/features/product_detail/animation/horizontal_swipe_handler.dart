import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Two-stage horizontal swipe: while the page is maximized to [fullscreen], a
/// horizontal drag ANYWHERE on it minimizes back to the card (via [onMinimize]);
/// in card view the detector is disabled (null callback) so a horizontal swipe
/// pages between products as usual. [fullscreen] flips only at the threshold, so
/// this rebuilds rarely — not per scroll frame.
///
/// (The image carousel's own stage — collapsing fullscreen when the swipe starts
/// on the photo — lives inside ProductImageSlider; this handles the rest of the
/// page surface.)
class HorizontalSwipeToMinimize extends StatelessWidget {
  const HorizontalSwipeToMinimize({
    super.key,
    required this.fullscreen,
    required this.onMinimize,
    required this.child,
  });

  final ValueListenable<bool> fullscreen;
  final VoidCallback onMinimize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: fullscreen,
      builder: (context, fs, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: fs ? (_) => onMinimize() : null,
        child: child,
      ),
      child: child,
    );
  }
}
