import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CartFlyAnimator {
  static final List<GlobalKey> _badgeKeys = [];

  static void registerBadgeKey(GlobalKey key) => _badgeKeys.add(key);

  static void unregisterBadgeKey(GlobalKey key) => _badgeKeys.remove(key);

  static GlobalKey? get _activeKey =>
      _badgeKeys.isNotEmpty ? _badgeKeys.last : null;

  /// Ticks once every time a flying product image reaches the cart badge.
  /// The badge listens to this to play its "catch" bounce in perfect sync
  /// with the landing (rather than the instant the cart count changes).
  static final ValueNotifier<int> landedTick = ValueNotifier<int>(0);

  static void _notifyLanded() => landedTick.value++;

  static void fly(BuildContext context, String? imageUrl, Offset startOffset) {
    final end = _resolveBadgeCenter();
    if (end != null) {
      _insertFly(context, imageUrl, startOffset, end);
      return;
    }

    // First item: the cart badge isn't on screen yet (it only appears once the
    // cart is non-empty). Wait a beat for it to mount after addToCart, then
    // fly to it — falling back to a default landing spot near where the cart
    // pill appears if it still isn't ready.
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!context.mounted) return;
      final target = _resolveBadgeCenter() ?? _fallbackTarget(context);
      _insertFly(context, imageUrl, startOffset, target);
    });
  }

  /// Global centre of the active cart badge, or null if it isn't mounted.
  static Offset? _resolveBadgeCenter() {
    final badgeBox =
        _activeKey?.currentContext?.findRenderObject() as RenderBox?;
    if (badgeBox == null || !badgeBox.attached) return null;
    return badgeBox.localToGlobal(
        Offset(badgeBox.size.width / 2, badgeBox.size.height / 2));
  }

  /// Where to fly when no badge exists yet — roughly where the cart pill
  /// materialises (bottom-centre, above the nav area).
  static Offset _fallbackTarget(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Offset(size.width / 2, size.height - 90);
  }

  static void _insertFly(BuildContext context, String? imageUrl,
      Offset startOffset, Offset endOffset) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingCartImage(
        imageUrl: imageUrl,
        startOffset: startOffset,
        endOffset: endOffset,
        onComplete: () {
          entry.remove();
          // The image just reached the cart — buzz + bounce the badge.
          AppHaptics.light();
          _notifyLanded();
        },
      ),
    );
    Overlay.of(context).insert(entry);
  }

  static void blast(BuildContext context, String? imageUrl) {
    final badgeCtx = _activeKey?.currentContext;
    if (badgeCtx == null) return;
    final badgeBox = badgeCtx.findRenderObject() as RenderBox?;
    if (badgeBox == null) return;
    final origin = badgeBox.localToGlobal(
        Offset(badgeBox.size.width / 2, badgeBox.size.height / 2));

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

  // Eased progress along the curved path (smooth ease-in, ease-out).
  late final Animation<double> _t;
  // Scale: holds full briefly, then eases down into the cart.
  late final Animation<double> _scale;
  // Gentle spin as it travels.
  late final Animation<double> _rotation;
  // Quick fade-in at launch and fade-out as it merges into the cart.
  late final Animation<double> _opacity;

  // Control point of the quadratic bezier (raises the arc above the line
  // between start and end so the image swoops gracefully instead of dropping).
  late final Offset _control;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    final start = widget.startOffset;
    final end = widget.endOffset;
    _control = Offset(
      (start.dx + end.dx) / 2,
      min(start.dy, end.dy) - 120, // lift the arc upward
    );

    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.38)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 80,
      ),
    ]).animate(_ctrl);

    _rotation = Tween<double>(begin: 0.0, end: 0.35)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _opacity = TweenSequence<double>([
      // Fade in fast at launch.
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      // Fade out as it lands in the cart.
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 18,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Quadratic bezier: (1-t)^2·P0 + 2(1-t)t·P1 + t^2·P2
  Offset _bezier(double t) {
    final u = 1 - t;
    final start = widget.startOffset;
    return start * (u * u) + _control * (2 * u * t) + widget.endOffset * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    const double size = 50;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pos = _bezier(_t.value);
        final s = _scale.value;
        return Positioned(
          left: pos.dx - (size * s) / 2,
          top: pos.dy - (size * s) / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacity.value.clamp(0.0, 1.0),
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
    final colors = [
      AppColor.secondary,
      const Color(0xFFFF6B35),
      const Color(0xFFE53935),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFAB47BC),
      const Color(0xFFFF9800),
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
