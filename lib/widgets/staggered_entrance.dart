import 'package:flutter/material.dart';

/// Wrap a list/grid item to give it a one-shot fade + slide-up entrance.
/// Pass the item's [index] so each one starts slightly after the previous,
/// producing a choreographed reveal instead of a flat paint.
///
/// ```dart
/// itemBuilder: (context, i) => StaggeredEntrance(
///   index: i,
///   child: ProductCard(...),
/// ),
/// ```
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  /// Delay added per item before it starts animating.
  final Duration perItemDelay;

  /// Cap so long lists don't wait forever (delay stops growing past this).
  final Duration maxDelay;

  final Duration duration;

  /// How far (in logical px) the item slides up into place.
  final double slideOffset;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.perItemDelay = const Duration(milliseconds: 55),
    this.maxDelay = const Duration(milliseconds: 500),
    this.duration = const Duration(milliseconds: 380),
    this.slideOffset = 24,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fade = curved;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curved);

    final delayMs = (widget.index * widget.perItemDelay.inMilliseconds)
        .clamp(0, widget.maxDelay.inMilliseconds);
    if (delayMs == 0) {
      _ctrl.forward();
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}
