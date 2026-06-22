import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

/// The canonical order lifecycle, in order.
enum OrderStage { placed, packed, outForDelivery, delivered }

extension OrderStageInfo on OrderStage {
  String get label {
    switch (this) {
      case OrderStage.placed:
        return 'Placed';
      case OrderStage.packed:
        return 'Packed';
      case OrderStage.outForDelivery:
        return 'On the way';
      case OrderStage.delivered:
        return 'Delivered';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStage.placed:
        return Icons.receipt_long_rounded;
      case OrderStage.packed:
        return Icons.inventory_2_rounded;
      case OrderStage.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStage.delivered:
        return Icons.home_rounded;
    }
  }
}

/// Horizontal order-status stepper with a progress line that animates as it
/// fills up to [currentStage]. Reusable on the success screen and order detail.
class OrderStatusStepper extends StatelessWidget {
  /// Index of the furthest reached stage (0 = placed … 3 = delivered).
  final OrderStage currentStage;
  final Duration duration;

  const OrderStatusStepper({
    super.key,
    required this.currentStage,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    const stages = OrderStage.values;
    final reached = currentStage.index;
    // Fraction of the whole track that should be filled (between node centres).
    final targetFraction =
        stages.length == 1 ? 0.0 : reached / (stages.length - 1);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetFraction),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, fill, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            const nodeSize = 34.0;
            final usable = width - nodeSize; // line spans node centres
            final filledPx = usable * fill;

            return SizedBox(
              height: 64.h,
              child: Stack(
                children: [
                  // Track (background line) + filled line, vertically centred
                  // on the node row.
                  Positioned(
                    left: nodeSize / 2,
                    right: nodeSize / 2,
                    top: nodeSize / 2 - 1.5,
                    child: Container(
                      height: 3,
                      color: context.vColors.divider,
                    ),
                  ),
                  Positioned(
                    left: nodeSize / 2,
                    top: nodeSize / 2 - 1.5,
                    child: Container(
                      height: 3,
                      width: filledPx.clamp(0.0, usable),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Nodes + labels.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < stages.length; i++)
                        _node(
                          context,
                          stages[i],
                          // A node lights up once the fill reaches it.
                          done: fill * (stages.length - 1) >= i - 0.001,
                          nodeSize: nodeSize,
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _node(BuildContext context, OrderStage stage,
      {required bool done, required double nodeSize}) {
    final active = done ? AppColor.primary : context.vColors.divider;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColor.primary : context.vColors.surface,
            border: Border.all(color: active, width: 2),
          ),
          child: Icon(
            stage.icon,
            size: 16.sp,
            color: done ? Colors.white : context.vColors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          stage.label,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: done ? FontWeight.w700 : FontWeight.w500,
            color: done ? AppColor.primary : context.vColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
