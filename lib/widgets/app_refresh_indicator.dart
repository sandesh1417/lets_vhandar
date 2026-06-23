import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';

// ---------------------------------------------------------------------------
// AppRefreshIndicator — branded pull-to-refresh for VHANDAR.
//
// Drop-in replacement: same constructor (child / onRefresh / color).
//
// The Vhandar logo mark sits in a floating badge: it reveals as the user pulls
// (a progress ring fills around it), then gently "breathes" while a comet ring
// spins during the refresh. On-brand and premium.
//
// Mechanism: a native RefreshIndicator (made invisible) provides the pull
// gesture + onRefresh callback, while a NotificationListener tracks the pull
// offset to drive our custom overlay.
// ---------------------------------------------------------------------------

class AppRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  /// Resting Y (from the top of the wrapped area) where the pill settles while
  /// refreshing. Defaults to just below the top safe area. Pass a larger value
  /// to float it lower — e.g. just above a banner.
  final double? topOffset;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.topOffset,
  });

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator>
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

    // Notifications from nested scrollables (banner carousels, horizontal
    // product rows, …) bubble through this listener too, picking up an
    // extra depth as they pass the outer scroll view. Without this guard
    // their own at-rest/overscroll metrics get misread as a vertical pull,
    // popping the refresh badge while the user is just scrolling normally.
    if (n.depth != 0) return false;

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
                child: _LogoPill(
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
// _LogoPill — floating badge with the Vhandar logo mark + progress ring.
// ---------------------------------------------------------------------------
class _LogoPill extends StatelessWidget {
  final Color primaryColor;
  final bool refreshing;
  final double pull;
  final AnimationController loop;

  const _LogoPill({
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
          builder: (_, __) {
            // Logo: grows in with the pull, then gently "breathes" (subtle
            // scale pulse) while refreshing so it feels alive.
            final breathe = 0.5 + 0.5 * sin(loop.value * 2 * pi); // 0..1
            final logoScale =
                refreshing ? 0.88 + 0.12 * breathe : (0.55 + 0.45 * pull);
            final logoOpacity = refreshing ? 1.0 : pull.clamp(0.0, 1.0);

            return Stack(
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
                // White badge holding the Vhandar logo mark.
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(11),
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
                  child: Opacity(
                    opacity: logoOpacity,
                    child: Transform.scale(
                      scale: logoScale,
                      child: SvgPicture.asset(KImageConstant.vandharIcon),
                    ),
                  ),
                ),
              ],
            );
          },
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
