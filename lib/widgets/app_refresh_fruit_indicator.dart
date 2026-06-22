import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';

// ---------------------------------------------------------------------------
// AppRefreshFruitsIndicator — grocery-themed pull-to-refresh for VHANDAR.
//
// Drop-in replacement: same constructor (child / onRefresh / color).
//
// A woven basket fills with produce as the user pulls; once refreshing, the
// fruit juggles in a bouncing wave above the basket. Everything is vector-
// drawn (CustomPainter) so it stays crisp and consistent across devices.
//
// Mechanism: a native RefreshIndicator (made invisible) provides the pull
// gesture + onRefresh callback, while a NotificationListener tracks the pull
// offset to drive our custom overlay.
// ---------------------------------------------------------------------------

class AppRefreshFruitsIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  /// Resting Y (from the top of the wrapped area) where the pill settles while
  /// refreshing. Defaults to just below the top safe area. Pass a larger value
  /// to float it lower — e.g. just above a banner.
  final double? topOffset;

  const AppRefreshFruitsIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.topOffset,
  });

  @override
  State<AppRefreshFruitsIndicator> createState() =>
      _AppRefreshFruitsIndicatorState();
}

class _AppRefreshFruitsIndicatorState extends State<AppRefreshFruitsIndicator>
    with SingleTickerProviderStateMixin {
  // How far the user has pulled (0–1, clamped).
  double _pull = 0.0;
  bool _refreshing = false;

  // Continuous bounce loop while refreshing.
  late final AnimationController _loop;

  static const double _triggerDistance = 80.0;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // "Caught it" tick the moment the pull commits to a refresh.
    AppHaptics.light();
    setState(() => _refreshing = true);
    _loop.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _pull = 0.0;
        });
        _loop.stop();
      }
    }
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (_refreshing) return false;

    if (n is ScrollUpdateNotification && n.metrics.extentBefore == 0) {
      final drag = -(n.scrollDelta ?? 0);
      if (drag > 0) {
        setState(() {
          _pull = (_pull + drag / _triggerDistance).clamp(0.0, 1.0);
        });
      }
    } else if (n is OverscrollNotification && n.overscroll < 0) {
      setState(() {
        _pull = (_pull + (-n.overscroll) / _triggerDistance).clamp(0.0, 1.0);
      });
    } else if (n is ScrollEndNotification && !_refreshing) {
      setState(() => _pull = 0.0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.color ?? AppColor.primary;

    // Where the pill settles. Default: just below the top safe area; callers
    // can override via [topOffset] (e.g. to float it just above a banner).
    final topInset = MediaQuery.of(context).padding.top;
    const hiddenTop = -90.0; // fully off-screen above
    final restingTop = widget.topOffset ?? (topInset + 12.0);

    return RefreshIndicator(
      // Hide the native indicator: transparent colours + zero elevation so it
      // contributes no spinner and no drop shadow. Only our pill shows.
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      elevation: 0,
      onRefresh: _handleRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            widget.child,
            AnimatedPositioned(
              duration: _refreshing
                  ? const Duration(milliseconds: 220)
                  : Duration.zero,
              curve: Curves.easeOut,
              top: _refreshing
                  ? restingTop
                  : (_pull > 0
                      ? hiddenTop + (_pull * (restingTop - hiddenTop))
                      : hiddenTop),
              left: 0,
              right: 0,
              child: Center(
                child: _BasketPill(
                  primaryColor: primaryColor,
                  refreshing: _refreshing,
                  pull: _pull,
                  loop: _loop,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BasketPill — the floating capsule containing the basket animation + label.
// ---------------------------------------------------------------------------
class _BasketPill extends StatelessWidget {
  final Color primaryColor;
  final bool refreshing;
  final double pull;
  final AnimationController loop;

  const _BasketPill({
    required this.primaryColor,
    required this.refreshing,
    required this.pull,
    required this.loop,
  });

  @override
  Widget build(BuildContext context) {
    // Compact circular badge — pops in as the user pulls, like a refresh spinner.
    final scale = refreshing ? 1.0 : (0.7 + 0.3 * pull);
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 60,
        height: 60,
        child: AnimatedBuilder(
          animation: loop,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring: fills with the pull, then spins while refreshing.
              CustomPaint(
                size: const Size(60, 60),
                painter: _RingPainter(
                  color: primaryColor,
                  t: loop.value,
                  pull: pull,
                  refreshing: refreshing,
                ),
              ),
              // White badge holding the basket animation.
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _BasketPainter(
                    accent: primaryColor,
                    t: loop.value,
                    pull: pull,
                    refreshing: refreshing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RingPainter — the circular progress / spinner ring around the badge.
//   • While pulling: a determinate arc grows from the top with the pull.
//   • While refreshing: a comet arc rotates continuously.
// ---------------------------------------------------------------------------
class _RingPainter extends CustomPainter {
  final Color color;
  final double t; // spin loop 0–1
  final double pull; // 0–1
  final bool refreshing;

  _RingPainter({
    required this.color,
    required this.t,
    required this.pull,
    required this.refreshing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    // Faint full-circle track for definition.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    if (refreshing) {
      // Rotate the whole canvas around the centre so the gradient stays
      // centred (avoids GradientRotation's off-centre origin quirk).
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(t * 2 * pi);

      final localRect = Rect.fromCircle(center: Offset.zero, radius: radius);
      // Sweep gradient transparent → solid = a smooth shimmering comet tail.
      final shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 1.0),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(localRect);

      final comet = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader;
      canvas.drawCircle(Offset.zero, radius, comet);

      // Bright head at the leading (opaque) end of the comet, with a sparkle.
      final head = Offset(radius, 0);
      canvas.drawCircle(head, stroke / 2 + 1, Paint()..color = color);
      canvas.drawCircle(
        head,
        stroke / 2 - 0.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      canvas.restore();
    } else {
      final sweep = pull.clamp(0.0, 1.0) * 2 * pi;
      if (sweep <= 0) return;
      const start = -pi / 2; // 12 o'clock
      // Faint → bright along the arc so it shimmers as it fills.
      final shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * pi,
        colors: [color.withValues(alpha: 0.25), color],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.t != t ||
      old.pull != pull ||
      old.refreshing != refreshing ||
      old.color != color;
}

// ---------------------------------------------------------------------------
// _BasketPainter — woven basket + three pieces of produce.
//   • While pulling: fruit reveals/grows inside the basket one by one.
//   • While refreshing: fruit bounces in a staggered wave above the rim.
// ---------------------------------------------------------------------------
class _BasketPainter extends CustomPainter {
  final Color accent;
  final double t; // bounce loop 0–1
  final double pull; // 0–1
  final bool refreshing;

  _BasketPainter({
    required this.accent,
    required this.t,
    required this.pull,
    required this.refreshing,
  });

  // Warm wicker tone for the basket, plus three produce colours.
  static const Color _wicker = Color(0xFFC68B59);
  static const Color _leaf = Color(0xFF4CAF50);
  static const List<Color> _fruitColors = [
    Color(0xFFE74C3C), // tomato / apple
    Color(0xFFF39C12), // orange
    Color(0xFF7CB342), // green apple
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topY = size.height - 15; // basket rim
    final botY = size.height - 3; // basket base
    const topHalf = 16.0;
    const botHalf = 10.0;

    // Slight vertical jiggle of the whole basket while refreshing.
    final jiggle = refreshing ? sin(t * 2 * pi) * 1.0 : 0.0;

    // ── Produce ─────────────────────────────────────────────────────────
    // Drawn before the basket front so items appear to sit inside it.
    final xs = [cx - 11, cx, cx + 11];
    final rest = topY - 6 + jiggle; // resting fruit-centre height
    for (int i = 0; i < 3; i++) {
      double yc, scale, opacity;
      if (refreshing) {
        final phase = (t + i / 3.0) % 1.0;
        yc = rest - sin(phase * pi) * 11.0; // bounce up
        scale = 1.0;
        opacity = 1.0;
      } else {
        final revealed = (pull * 3 - i).clamp(0.0, 1.0);
        if (revealed <= 0) continue;
        yc = rest - revealed * 2.0; // nudge up as it settles in
        scale = 0.45 + 0.55 * revealed;
        opacity = revealed;
      }
      _drawFruit(
          canvas, Offset(xs[i], yc), 5.0 * scale, _fruitColors[i], opacity);
    }

    // ── Basket ──────────────────────────────────────────────────────────
    final stroke = Paint()
      ..color = _wicker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ty = topY + jiggle;
    final by = botY + jiggle;

    // Body (trapezoid).
    final body = Path()
      ..moveTo(cx - topHalf, ty)
      ..lineTo(cx - botHalf, by)
      ..lineTo(cx + botHalf, by)
      ..lineTo(cx + topHalf, ty);
    canvas.drawPath(body, stroke);

    // Woven detail: a horizontal band + a few verticals.
    stroke.strokeWidth = 1.3;
    final midY = (ty + by) / 2;
    const midHalf = (topHalf + botHalf) / 2 - 1;
    canvas.drawLine(
        Offset(cx - midHalf, midY), Offset(cx + midHalf, midY), stroke);
    for (final f in [-0.5, 0.0, 0.5]) {
      canvas.drawLine(
        Offset(cx + f * topHalf, ty + 1),
        Offset(cx + f * botHalf, by - 1),
        stroke,
      );
    }
    stroke.strokeWidth = 2.4;

    // Rim (ellipse) drawn last so it caps the body + items.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, ty), width: topHalf * 2, height: 5),
      stroke,
    );
  }

  void _drawFruit(
      Canvas canvas, Offset c, double r, Color color, double opacity) {
    if (opacity <= 0 || r <= 0) return;
    final body = Paint()..color = color.withValues(alpha: opacity);
    canvas.drawCircle(c, r, body);

    // Leaf at the top-right.
    canvas.save();
    canvas.translate(c.dx + r * 0.35, c.dy - r * 0.95);
    canvas.rotate(-0.6);
    final leaf = Paint()..color = _leaf.withValues(alpha: opacity);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 1.0, height: r * 0.5),
      leaf,
    );
    canvas.restore();

    // Glossy highlight.
    final hl = Paint()..color = Colors.white.withValues(alpha: 0.55 * opacity);
    canvas.drawCircle(Offset(c.dx - r * 0.3, c.dy - r * 0.32), r * 0.26, hl);
  }

  @override
  bool shouldRepaint(_BasketPainter old) =>
      old.t != t ||
      old.pull != pull ||
      old.refreshing != refreshing ||
      old.accent != accent;
}
