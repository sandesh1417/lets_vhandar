import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

// Shared visual language for the three stacked cards on the product page
// (ticket / details / similar). Centralised here so a tweak to the card
// margin, gap or radius applies everywhere at once.
const double kCardHMargin = 12; // horizontal margin  (use .w)
const double kCardVGap = 6; // gap between cards  (use .h)
const double kCardRadius = 12; // BorderRadius value  (use .r)

/// Outer margin every card shares.
EdgeInsets productCardMargin() =>
    EdgeInsets.symmetric(horizontal: kCardHMargin.w, vertical: kCardVGap.h);

/// Rounded surface decoration every card shares.
BoxDecoration productCardDecoration(BuildContext context) => BoxDecoration(
      color: context.vColors.surface,
      borderRadius: BorderRadius.circular(kCardRadius.r),
    );
