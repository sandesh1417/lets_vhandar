import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vhandar/core/constants/color_constant.dart';

/// Displays the selected location description and optional error message.
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
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Location description bar ---
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: hasError ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: hasError ? Colors.red.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: hasError ? Colors.red : AppColor.primary,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: isGeocoding
                    ? Row(
                        children: [
                          SizedBox(
                            height: 14.sp,
                            width: 14.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Fetching location...',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: hasError
                              ? Colors.red.shade800
                              : AppColor.textBlack87,
                        ),
                      ),
              ),
            ],
          ),
        ),

        // --- Error text ---
        if (hasError)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                error!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
