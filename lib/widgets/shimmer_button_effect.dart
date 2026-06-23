import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lets_vhandar/widgets/loader.dart';

/// Reusable button animation effects.
///
/// This file holds the *logic* for the three premium button effects so that
/// individual button widgets only have to compose them, never re-implement
/// them:
///
///   1. [ShimmerSweepOverlay]    – idle diagonal light sweep (attention).
///   2. [LoadingShimmerContent]  – skeleton shimmer + spinner for `isLoading`.
///   3. [PressScale]             – press-down scale micro-interaction.
///
/// Each effect owns its own [AnimationController] and disposes it correctly.
/// All are pure overlays — they never read or mutate the host button's colors,
/// padding or border radius beyond what is passed in, so they cannot change a
/// button's existing look.

// ~30° expressed in radians, used to tilt the idle shimmer band.
const double _kShimmerAngle = math.pi / 6;

// ─────────────────────────────────────────────────────────────────────────
// SHIMMER TIMING KNOBS — tweak these to control the feel app-wide.
// (Or override per-button via the matching props on CustomElevatedButton.)
// Lower numbers = faster.
// ─────────────────────────────────────────────────────────────────────────

/// Idle sweep: how long one light sweep takes to glide across the button.
const Duration kShimmerSweepDuration = Duration(milliseconds: 1200);

/// Idle sweep: the rest/pause between two consecutive sweeps.
/// Lower = the shimmer repeats more often.
const Duration kShimmerPauseDuration = Duration(milliseconds: 1800);

/// Loading sweep: speed of the continuous sweep shown while `isLoading` is
/// true. Kept short on purpose so it reads as active "processing".
const Duration kLoadingShimmerDuration = Duration(milliseconds: 650);

/// Idle "attention" shimmer: a diagonal band of light that glides across the
/// surface on a timed loop (sweep, then pause, then repeat).
///
/// Drop it into a [Stack] as a `Positioned.fill` layer *above* the button
/// background but *below* the label. Clip it to the button shape with a
/// surrounding [ClipRRect] — the painter itself never draws outside its bounds.
class ShimmerSweepOverlay extends StatefulWidget {
  /// Duration of a single left-to-right sweep.
  final Duration sweepDuration;

  /// Idle pause between two consecutive sweeps.
  final Duration pauseDuration;

  const ShimmerSweepOverlay({
    super.key,
    this.sweepDuration = kShimmerSweepDuration,
    this.pauseDuration = kShimmerPauseDuration,
  });

  @override
  State<ShimmerSweepOverlay> createState() => _ShimmerSweepOverlayState();
}

class _ShimmerSweepOverlayState extends State<ShimmerSweepOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();

    // One full cycle = sweep + pause. The controller runs over the whole
    // cycle; a CurvedAnimation with an Interval animates the sweep only during
    // the first portion and then holds the band off-screen for the pause.
    final total = widget.sweepDuration + widget.pauseDuration;
    final sweepFraction =
        widget.sweepDuration.inMilliseconds / total.inMilliseconds;

    _controller = AnimationController(vsync: this, duration: total)..repeat();

    _sweep = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, sweepFraction, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the real laid-out width before painting — render nothing until the
    // constraints are bounded so the shimmer never flashes at the wrong size.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            constraints.maxWidth <= 0 ||
            !constraints.hasBoundedHeight ||
            constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _sweep,
          builder: (context, _) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _DiagonalShimmerPainter(progress: _sweep.value),
            );
          },
        );
      },
    );
  }
}

class _DiagonalShimmerPainter extends CustomPainter {
  /// 0 → band fully off the left edge, 1 → band fully off the right edge.
  final double progress;

  _DiagonalShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // Band travels from x = -1.5·w to x = 2.5·w (a 4·w span) so it fully
    // clears both edges before/after the visible sweep.
    final dx = (-1.5 + progress * 4.0) * w;
    final bandRect = Rect.fromLTWH(dx, 0, w, h);

    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.32),
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.45, 0.55, 1.0],
      // Tilt the band ~30°. Rotation is about the band rect's centre.
      transform: const GradientRotation(-_kShimmerAngle),
    ).createShader(bandRect);

    // Outside `bandRect` the clamped gradient resolves to its fully
    // transparent edge stops, so only the moving band lightens the surface.
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_DiagonalShimmerPainter old) => old.progress != progress;
}

/// Loading-state content: a continuous left-to-right skeleton shimmer with a
/// small spinner centred on top. Sized by its parent (use as a `Positioned.fill`
/// layer so it covers the whole button); clip it with a surrounding [ClipRRect].
class LoadingShimmerContent extends StatefulWidget {
  /// Skeleton base — the host button's background colour. Painted at 60% alpha.
  final Color baseColor;

  /// Spinner colour (defaults to white).
  final Color spinnerColor;

  /// Cupertino loader radius. Null falls back to the indicator's default (10).
  final double? spinnerRadius;

  /// Speed of the continuous sweep. Lower = faster (more "busy") feel.
  final Duration sweepDuration;

  const LoadingShimmerContent({
    super.key,
    required this.baseColor,
    this.spinnerColor = Colors.white,
    this.spinnerRadius,
    this.sweepDuration = kLoadingShimmerDuration,
  });

  @override
  State<LoadingShimmerContent> createState() => _LoadingShimmerContentState();
}

class _LoadingShimmerContentState extends State<LoadingShimmerContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Continuous sweep, no pause, while loading.
    _controller = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _LoadingShimmerPainter(
                progress: _controller.value,
                baseColor: widget.baseColor,
              ),
            );
          },
        ),
        CircularLoader(
          color: widget.spinnerColor,
          // size: (widget.spinnerRadius ?? 12) * 2,
        ),
      ],
    );
  }
}

class _LoadingShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _LoadingShimmerPainter({required this.progress, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final full = Offset.zero & size;

    // Skeleton base: the button background at 60% opacity.
    canvas.drawRect(full, Paint()..color = baseColor.withValues(alpha: 0.6));

    // Moving highlight: white, straight left-to-right sweep.
    final dx = (-1.0 + progress * 2.0) * w;
    final bandRect = Rect.fromLTWH(dx, 0, w, h);
    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.3),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(bandRect);

    canvas.drawRect(full, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_LoadingShimmerPainter old) =>
      old.progress != progress || old.baseColor != baseColor;
}

/// Press-down scale micro-interaction: scales to [pressedScale] on pointer
/// down and springs back to 1.0 on release.
///
/// Uses a [Listener] (pointer events) rather than a [GestureDetector] so it
/// never enters the gesture arena and therefore never competes with — or
/// cancels — the wrapped button's own tap handling.
class PressScale extends StatefulWidget {
  final Widget child;

  /// When false the wrapper is inert (e.g. disabled / loading buttons).
  final bool enabled;

  final double pressedScale;
  final Duration downDuration;
  final Duration releaseDuration;
  final Curve downCurve;
  final Curve releaseCurve;

  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.96,
    this.downDuration = const Duration(milliseconds: 120),
    this.releaseDuration = const Duration(milliseconds: 200),
    this.downCurve = Curves.easeOut,
    this.releaseCurve = Curves.elasticOut,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    // Guard against callbacks firing after the element is gone.
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final pressed = _pressed;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: pressed ? widget.pressedScale : 1.0,
        duration: pressed ? widget.downDuration : widget.releaseDuration,
        curve: pressed ? widget.downCurve : widget.releaseCurve,
        child: widget.child,
      ),
    );
  }
}
