import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

// class LoadingOverlay {
//   LoadingOverlay();
//   bool _dialogIsOpen = false;

//   void show(BuildContext context) {
//     if (_dialogIsOpen) return;
//     _dialogIsOpen = true;
//     log("showing Loader");
//     showDialog(
//       barrierColor: Colors.black54.withValues(alpha: 0.2),
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (didPop) _dialogIsOpen = false;
//         },
//         child: const Center(
//           child: SizedBox(
//             height: 150,
//             width: 150,
//             child: Center(child: CupertinoActivityIndicator(radius: 15)),
//           ),
//         ),
//       ),
//     ).whenComplete(() => _dialogIsOpen = false);
//   }

//   void hide(BuildContext context) {
//     if (!_dialogIsOpen) return;
//     _dialogIsOpen = false;
//     context.pop();
//   }
// }

/// Premium loader — the same clean circular line as the pull-to-refresh
/// spinner: a faint full-circle track with a solid rounded arc rotating around
/// it. More on-brand than the iOS spinner.
class CircularLoader extends StatefulWidget {
  /// Defaults to white (for use on coloured buttons). Pass a colour to override.
  final Color? color;
  final double size;
  final double strokeWidth;

  const CircularLoader({
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth = 2.0,
  });

  @override
  State<CircularLoader> createState() => _CircularLoaderState();
}

class _CircularLoaderState extends State<CircularLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      // Fast but still smooth. Going much below ~450ms starts to strobe at
      // 60fps (the head jumps too far per frame) and looks juddery.
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColor.white;
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.rotate(
            angle: _ctrl.value * 2 * math.pi,
            child: CustomPaint(
              painter: _RingLoaderPainter(
                color: color,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingLoaderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RingLoaderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Very faint full-circle track for definition.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color.withValues(alpha: 0.08),
    );

    // Shooting-star streak: a sweep gradient that stays transparent for most of
    // the circle (the long tail) and brightens sharply only near the head. The
    // whole loader is rotated by the controller, so the star "shoots" around.
    final shader = SweepGradient(
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.35),
        color,
      ],
      stops: const [0.0, 0.5, 0.86, 1.0],
    ).createShader(rect);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    // Glowing head (the "star") at the leading end, with a white sparkle core.
    final head = Offset(center.dx + radius, center.dy);
    canvas.drawCircle(
      head,
      strokeWidth * 2.2,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(head, strokeWidth / 2 + 1.0, Paint()..color = color);
    canvas.drawCircle(
      head,
      math.max(strokeWidth / 2 - 0.2, 0.6),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_RingLoaderPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
