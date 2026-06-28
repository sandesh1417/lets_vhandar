import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

import 'product_brand_section.dart';

/// Brand / store row at the bottom of the ticket card: a perforated "ticket
/// cutout" divider followed by the brand section.
class ProductStoreRow extends StatelessWidget {
  const ProductStoreRow({super.key, required this.brandId});

  final String brandId;

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TicketCutoutDivider(bgColor: vc.scaffoldBg, surfaceColor: vc.surface),
        ProductBrandSection(brandId: brandId),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TICKET CUTOUT DIVIDER
//
// Draws on a single CustomPaint:
//   1. Full-width surface-coloured bar (background)
//   2. Left + right D-shaped notches (bgColor → looks "cut out")
//   3. Dashed line between the notches
//
// WHY bgColor not transparent? The card has a box-shadow; a truly transparent
// hole would reveal the shadow bleed from the container behind it. Matching the
// scaffold bg colour hides that and creates the illusion of a physical cutout.
// ═════════════════════════════════════════════════════════════════════════════
class _TicketCutoutDivider extends StatelessWidget {
  final Color bgColor;
  final Color surfaceColor;

  const _TicketCutoutDivider({
    required this.bgColor,
    required this.surfaceColor,
  });

  static const double _r = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _r * 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _CutoutDividerPainter(
          bgColor: bgColor,
          surfaceColor: surfaceColor,
        ),
      ),
    );
  }
}

class _CutoutDividerPainter extends CustomPainter {
  final Color bgColor;
  final Color surfaceColor;

  const _CutoutDividerPainter({
    required this.bgColor,
    required this.surfaceColor,
  });

  static const double _r = 16;
  static const double _dashWidth = 7;
  static const double _dashGap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final w = size.width;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, size.height),
      Paint()..color = surfaceColor,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, cy), radius: _r),
      -math.pi / 2,
      math.pi,
      true,
      Paint()..color = bgColor,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, cy), radius: _r),
      math.pi / 2,
      math.pi,
      true,
      Paint()..color = bgColor,
    );

    final paint = Paint()
      ..color = bgColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    double x = _r + _dashGap;
    final endX = w - _r - _dashGap;
    while (x < endX) {
      canvas.drawLine(
        Offset(x, cy),
        Offset((x + _dashWidth).clamp(x, endX), cy),
        paint,
      );
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(_CutoutDividerPainter old) =>
      old.bgColor != bgColor || old.surfaceColor != surfaceColor;
}
