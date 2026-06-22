import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/widgets/shimmer_button_effect.dart';

/// A tappable wrapper that adds the same tactile press-scale used on buttons to
/// any widget (cards, tiles, chips), plus an optional light haptic. Reuses
/// [PressScale] so the motion language stays consistent across the app.
///
/// ```dart
/// Pressable(onTap: () => openProduct(), child: ProductCard(...))
/// ```
class Pressable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool enableHaptic;
  final HitTestBehavior behavior;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onTap != null,
      pressedScale: pressedScale,
      child: GestureDetector(
        behavior: behavior,
        onTap: onTap == null
            ? null
            : () {
                if (enableHaptic) AppHaptics.light();
                onTap!();
              },
        child: child,
      ),
    );
  }
}
