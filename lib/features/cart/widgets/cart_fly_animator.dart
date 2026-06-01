import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CartFlyAnimator {
  static final List<GlobalKey> _badgeKeys = [];

  static void registerBadgeKey(GlobalKey key) => _badgeKeys.add(key);

  static void unregisterBadgeKey(GlobalKey key) => _badgeKeys.remove(key);

  static GlobalKey? get _activeKey =>
      _badgeKeys.isNotEmpty ? _badgeKeys.last : null;

  static void fly(BuildContext context, String? imageUrl, Offset startOffset) {
    final badgeCtx = _activeKey?.currentContext;
    if (badgeCtx == null) return;
    final badgeBox = badgeCtx.findRenderObject() as RenderBox?;
    if (badgeBox == null) return;
    final endOffset = badgeBox
        .localToGlobal(Offset(badgeBox.size.width / 2, badgeBox.size.height / 2));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingCartImage(
        imageUrl: imageUrl,
        startOffset: startOffset,
        endOffset: endOffset,
        onComplete: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  static void blast(BuildContext context, String? imageUrl) {
    final badgeCtx = _activeKey?.currentContext;
    if (badgeCtx == null) return;
    final badgeBox = badgeCtx.findRenderObject() as RenderBox?;
    if (badgeBox == null) return;
    final origin = badgeBox
        .localToGlobal(Offset(badgeBox.size.width / 2, badgeBox.size.height / 2));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BlastCartImage(
        imageUrl: imageUrl,
        origin: origin,
        onComplete: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

// ─────────────────────────────────────────────────────────
// FLY IN — gravity fall from product image into cart badge
// ─────────────────────────────────────────────────────────
class _FlyingCartImage extends StatefulWidget {
  final String? imageUrl;
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onComplete;

  const _FlyingCartImage({
    required this.imageUrl,
    required this.startOffset,
    required this.endOffset,
    required this.onComplete,
  });

  @override
  State<_FlyingCartImage> createState() => _FlyingCartImageState();
}

class _FlyingCartImageState extends State<_FlyingCartImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Scale: full size for first 45%, then shrinks into cart
  late final Animation<double> _scale;
  // Slight rotation as it falls
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInQuart)),
        weight: 55,
      ),
    ]).animate(_ctrl);

    _rotation = Tween<double>(begin: 0.0, end: 0.25)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 50;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final start = widget.startOffset;
        final end = widget.endOffset;

        // x: easeInOut — slight side drift
        final dx = start.dx + (end.dx - start.dx) *
            Curves.easeInOut.transform(t);
        // y: gravity — accelerates toward cart
        final dy = start.dy + (end.dy - start.dy) *
            Curves.easeInCubic.transform(t);

        final s = _scale.value;
        return Positioned(
          left: dx - (size * s) / 2,
          top: dy - (size * s) / 2,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: s,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CustomImageViewer(
                        path: widget.imageUrl, fit: BoxFit.cover),
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

// ─────────────────────────────────────────────────────────
// BLAST OUT — image pops out of cart then smashes
// ─────────────────────────────────────────────────────────
class _Particle {
  final double angle;
  final double distance;
  final Color color;
  final double size;
  _Particle(
      {required this.angle,
      required this.distance,
      required this.color,
      required this.size});
}

class _BlastCartImage extends StatefulWidget {
  final String? imageUrl;
  final Offset origin;
  final VoidCallback onComplete;

  const _BlastCartImage({
    required this.imageUrl,
    required this.origin,
    required this.onComplete,
  });

  @override
  State<_BlastCartImage> createState() => _BlastCartImageState();
}

class _BlastCartImageState extends State<_BlastCartImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase 1 (0→0.28): snap out of cart with spring
  late final Animation<double> _popScale;
  late final Animation<double> _popRise; // 0 = at origin, 1 = risen 50px up

  // Phase 2 (0.28→1.0): explode + fade
  late final Animation<double> _smashScale;
  late final Animation<double> _smashOpacity;
  late final Animation<double> _particleT;

  final List<_Particle> _particles = [];
  static const _sz = 50.0;
  static const _riseBy = 50.0;

  @override
  void initState() {
    super.initState();

    final rng = Random();
    const colors = [
      Color(0xFFF5C842),
      Color(0xFFFF6B35),
      Color(0xFFE53935),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFFAB47BC),
      Color(0xFFFF9800),
    ];
    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle(
        angle: (i * pi * 2 / 12) + rng.nextDouble() * 0.5,
        distance: 50 + rng.nextDouble() * 50,
        color: colors[rng.nextInt(colors.length)],
        size: 5 + rng.nextDouble() * 6,
      ));
    }

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Phase 1: quick spring pop (0 → 0.28)
    _popScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.28, curve: Curves.easeOutBack)),
    );
    _popRise = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.28, curve: Curves.easeOut)),
    );

    // Phase 2: smash (0.28 → 0.65)
    _smashScale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.28, 0.62, curve: Curves.easeOut)),
    );

    // Fade out: 0.28 → 0.88
    _smashOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.28, 0.88, curve: Curves.easeIn)),
    );

    // Particles scatter: 0.28 → 0.95
    _particleT = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.28, 0.95, curve: Curves.easeOut)),
    );

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
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
      builder: (_, __) {
        final t = _ctrl.value;
        final isPopping = t < 0.28;

        final cx = widget.origin.dx;
        // Rise upward during pop phase, stay risen during smash
        final cy = widget.origin.dy - _riseBy * _popRise.value;

        final currentScale = isPopping ? _popScale.value : _smashScale.value;
        final currentOpacity = isPopping ? 1.0 : _smashOpacity.value;

        return Stack(
          children: [
            // ── Product image ──
            if (currentOpacity > 0)
              Positioned(
                left: cx - (_sz * currentScale) / 2,
                top: cy - (_sz * currentScale) / 2,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: currentOpacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: currentScale,
                      child: Container(
                        width: _sz,
                        height: _sz,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: isPopping
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : [],
                        ),
                        child: ClipOval(
                          child: CustomImageViewer(
                              path: widget.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Particles ──
            ..._particles.map((p) {
              final pt = _particleT.value;
              if (pt <= 0) return const SizedBox.shrink();
              // Particles originate from where the image was risen to
              final px = cx + cos(p.angle) * p.distance * pt;
              final py = cy + sin(p.angle) * p.distance * pt - 20 * pt;
              final pOpacity = (1.0 - pt).clamp(0.0, 1.0);
              return Positioned(
                left: px - p.size / 2,
                top: py - p.size / 2,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: pOpacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration:
                          BoxDecoration(color: p.color, shape: BoxShape.circle),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
