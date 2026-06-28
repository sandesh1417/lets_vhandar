import 'package:flutter/widgets.dart';

/// Self-contained swipe-down-to-dismiss. Wrap the moving content with this; all
/// gesture state lives inside.
///
/// It tracks raw pointers with a passive [Listener] (never a drag
/// [GestureDetector]) so it only *observes* the gesture and never wins the arena
/// from the child's own scrollable. A dismiss only arms when [isAtTop] is true
/// at touch-down; on release a single downward swipe that travelled past
/// [dismissFractionThreshold] of the screen height — or flicked faster than
/// [flingVelocity] — calls [onDismiss] exactly once (the host pops the route, so
/// its existing Hero owns the flight back). Anything else is left untouched, so
/// the child scrolls / taps as normal.
class SwipeDismissWrapper extends StatefulWidget {
  const SwipeDismissWrapper({
    super.key,
    required this.child,
    required this.isAtTop,
    required this.onDismiss,
    this.dismissFractionThreshold = 0.15,
    this.flingVelocity = 600,
  });

  /// Content that owns the gesture surface (here: the product pager).
  final Widget child;

  /// Whether the content is scrolled to the very top — only then is a downward
  /// swipe a dismiss instead of a normal content scroll.
  final bool Function() isAtTop;

  /// Invoked once when a swipe commits to dismissal.
  final VoidCallback onDismiss;

  /// Fraction of screen height a release must exceed to dismiss.
  final double dismissFractionThreshold;

  /// Downward fling speed (px/s) that dismisses regardless of distance.
  final double flingVelocity;

  @override
  State<SwipeDismissWrapper> createState() => _SwipeDismissWrapperState();
}

class _SwipeDismissWrapperState extends State<SwipeDismissWrapper> {
  double _dragVelocity = 0.0; // px/s, from raw pointer deltas
  int _lastMoveTs = 0;
  double _gestureDx = 0.0; // total finger travel since touch-down
  double _gestureDy = 0.0;
  bool _downAtTop = false; // content was at the top when the gesture began

  void _onDown(PointerDownEvent e) {
    _dragVelocity = 0;
    _gestureDx = 0;
    _gestureDy = 0;
    // Only a swipe that starts at the very top is a dismiss; otherwise it's a
    // normal content scroll and must be left alone.
    _downAtTop = widget.isAtTop();
    _lastMoveTs = e.timeStamp.inMicroseconds;
  }

  void _onMove(PointerMoveEvent e) {
    _gestureDx += e.delta.dx;
    _gestureDy += e.delta.dy;
    final now = e.timeStamp.inMicroseconds;
    final dt = (now - _lastMoveTs) / 1e6;
    if (dt > 0) {
      // Light smoothing so one jittery frame can't dominate the release call.
      _dragVelocity = _dragVelocity * 0.3 + (e.delta.dy / dt) * 0.7;
    }
    _lastMoveTs = now;
  }

  void _onUp(PointerEvent e) {
    if (!_downAtTop) return;
    final screenH = MediaQuery.sizeOf(context).height;
    final downwardDominant = _gestureDy > 0 && _gestureDy > _gestureDx.abs();
    final farEnough = _gestureDy > screenH * widget.dismissFractionThreshold;
    final flicked = _dragVelocity > widget.flingVelocity;
    if (downwardDominant && (farEnough || flicked)) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      child: widget.child,
    );
  }
}

/// Bounces like [BouncingScrollPhysics] everywhere EXCEPT the top edge, which is
/// clamped (no upward bounce) — so a downward pull at the top is left for
/// [SwipeDismissWrapper] to read as a dismiss instead of rubber-banding the
/// content. The bottom still bounces normally.
class DismissDragScrollPhysics extends BouncingScrollPhysics {
  const DismissDragScrollPhysics({super.parent});

  @override
  DismissDragScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      DismissDragScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Already at/over the top and trying to move further up → fully clamp.
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    // Crossing the top edge from valid range → clamp at the edge.
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    // Everything else (the bottom edge) keeps the bouncing behaviour.
    return super.applyBoundaryConditions(position, value);
  }
}
