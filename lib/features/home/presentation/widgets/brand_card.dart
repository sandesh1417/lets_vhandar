import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class BrandCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const BrandCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 75.h,
            width: 75.w,
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: ClipRRect(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CustomImageViewer(
                  path: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: vc.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
