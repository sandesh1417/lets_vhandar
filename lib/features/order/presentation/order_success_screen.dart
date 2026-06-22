import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/order/presentation/widgets/order_status_stepper.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

/// Full-screen branded "order placed" celebration: a checkmark draws in, a
/// light confetti burst fires, then the order-status stepper and actions slide
/// up. [onContinue] is invoked when the user proceeds (e.g. to the orders tab).
class OrderSuccessScreen extends StatefulWidget {
  final String? orderId;
  final VoidCallback onContinue;

  const OrderSuccessScreen({
    super.key,
    this.orderId,
    required this.onContinue,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool _celebrate = false; // fires confetti once the check finishes drawing
  bool _revealBody = false; // slides up the text + stepper + button

  @override
  void initState() {
    super.initState();
    // Reveal the lower content shortly after the checkmark begins.
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _revealBody = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Scaffold(
      backgroundColor: vc.surface,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_celebrate) const Positioned.fill(child: _ConfettiBurst()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnimatedCheckmark(
                    onDrawn: () {
                      if (!mounted) return;
                      AppHaptics.success();
                      setState(() => _celebrate = true);
                    },
                  ),
                  SizedBox(height: 28.h),
                  AnimatedSlide(
                    offset: _revealBody ? Offset.zero : const Offset(0, 0.25),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _revealBody ? 1 : 0,
                      duration: const Duration(milliseconds: 450),
                      child: Column(
                        children: [
                          Text(
                            'Order Placed!',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: vc.onSurface,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            widget.orderId != null
                                ? 'Order #${widget.orderId}\nWe\'ll deliver it to you soon!'
                                : 'Your order has been placed successfully.\nWe\'ll deliver it to you soon!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.4,
                              color: vc.onSurfaceMuted,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          const OrderStatusStepper(
                              currentStage: OrderStage.placed),
                          SizedBox(height: 36.h),
                          CustomElevatedButton(
                            text: 'Track Order',
                            width: double.infinity,
                            height: 52.h,
                            onPressed: widget.onContinue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Checkmark: circle springs in, then the tick draws on with a CustomPainter.
// ─────────────────────────────────────────────────────────────────────────
class _AnimatedCheckmark extends StatefulWidget {
  final VoidCallback onDrawn;
  const _AnimatedCheckmark({required this.onDrawn});

  @override
  State<_AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<_AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _circle; // 0→1 scale-in
  late final Animation<double> _tick; // 0→1 path draw

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _circle = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );
    _tick = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward().then((_) {
      if (mounted) widget.onDrawn();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 104;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Transform.scale(
          scale: _circle.value.clamp(0.0, 1.0),
          child: Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Container(
                width: (size * 0.72).w,
                height: (size * 0.72).w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: CustomPaint(
                  painter: _CheckPainter(
                    progress: _tick.value,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Filled circle backing the tick.
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w / 2,
      Paint()..color = color,
    );

    if (progress <= 0) return;

    // Checkmark path (relative to the circle box).
    final p1 = Offset(w * 0.28, h * 0.52);
    final p2 = Offset(w * 0.44, h * 0.68);
    final p3 = Offset(w * 0.74, h * 0.34);

    final full = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);

    final metrics = full.computeMetrics().toList();
    final drawn = Path();
    for (final m in metrics) {
      drawn.addPath(m.extractPath(0, m.length * progress.clamp(0.0, 1.0)),
          Offset.zero);
    }

    canvas.drawPath(
      drawn,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────
// Lightweight one-shot confetti burst from the top-centre.
// ─────────────────────────────────────────────────────────────────────────
class _ConfettiBurst extends StatefulWidget {
  const _ConfettiBurst();

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Confetto> _pieces = [];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    const colors = [
      Color(0xFFF5B237), // secondary
      Color(0xFF0A754E), // primary
      Color(0xFFFF6B35),
      Color(0xFF2196F3),
      Color(0xFFAB47BC),
      Color(0xFF4CAF50),
    ];
    for (int i = 0; i < 60; i++) {
      _pieces.add(_Confetto(
        x: rng.nextDouble(),
        startY: -0.05 - rng.nextDouble() * 0.1,
        fallSpeed: 0.7 + rng.nextDouble() * 0.6,
        drift: (rng.nextDouble() - 0.5) * 0.4,
        color: colors[rng.nextInt(colors.length)],
        size: 6 + rng.nextDouble() * 7,
        rotSpeed: (rng.nextDouble() - 0.5) * 12,
      ));
    }
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_pieces, _ctrl.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Confetto {
  final double x; // 0..1 of width
  final double startY; // 0..1 of height (can be negative)
  final double fallSpeed;
  final double drift;
  final Color color;
  final double size;
  final double rotSpeed;
  _Confetto({
    required this.x,
    required this.startY,
    required this.fallSpeed,
    required this.drift,
    required this.color,
    required this.size,
    required this.rotSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetto> pieces;
  final double t; // 0..1
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in pieces) {
      final y = (c.startY + c.fallSpeed * t) * size.height;
      if (y > size.height + 20) continue;
      final x = (c.x + c.drift * t) * size.width;
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotSpeed * t);
      final paint = Paint()..color = c.color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: c.size, height: c.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
