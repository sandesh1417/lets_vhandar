import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';

class AddressLocationBanner extends StatelessWidget {
  final String description;
  final bool isGeocoding;
  final String? error;

  const AddressLocationBanner({
    super.key,
    required this.description,
    this.isGeocoding = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: hasError
                ? Colors.red.withValues(alpha: 0.08)
                : vc.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? Colors.red.withValues(alpha: 0.3)
                  : vc.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: hasError ? Colors.red.shade400 : AppColor.primary,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: isGeocoding
                    ? Row(
                        children: [
                          CustomCircularLoader(
                            size: 14,
                            strokeWidth: 2,
                            color: AppColor.primary.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Fetching location...',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: vc.onSurfaceMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: hasError
                              ? Colors.red.shade400
                              : vc.onSurface,
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.h),
            child: Text(
              error!,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
