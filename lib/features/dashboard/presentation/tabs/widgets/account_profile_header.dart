import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class AccountProfileHeader extends StatelessWidget {
  final dynamic user;

  const AccountProfileHeader({super.key, required this.user});

  int _completionPercent() {
    final isBusiness = user?.isBusiness == true;
    final bd = user?.businessDetail as Map<String, dynamic>?;
    if (isBusiness) {
      final fields = [
        bd?['businessName'] as String?,
        user?.phoneNumber as String?,
        bd?['businessCategory'] as String?,
        (bd?['panNumber'] as String?)?.isNotEmpty == true
            ? bd!['panNumber'] as String
            : bd?['vatNumber'] as String?,
        user?.email as String?,
      ];
      final filled = fields.where((f) => f != null && f.isNotEmpty).length;
      return ((filled / fields.length) * 100).round();
    } else {
      final fields = [
        user?.name as String?,
        user?.phoneNumber as String?,
        user?.email as String?,
        user?.birthDate as String?,
        user?.gender as String?,
      ];
      final filled = fields.where((f) => f != null && f.isNotEmpty).length;
      return ((filled / fields.length) * 100).round();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isBusiness = user?.isBusiness == true;
    final businessDetail = user?.businessDetail as Map<String, dynamic>?;
    final displayName = isBusiness
        ? (businessDetail?['businessName'] as String? ??
            user?.name ??
            'Business')
        : (user?.name ?? 'User Name');
    final displayPhone = user?.phoneNumber ?? 'Phone Number';
    final category = businessDetail?['businessCategory'] as String?;
    final pan = businessDetail?['panNumber'] as String?;
    final vat = businessDetail?['vatNumber'] as String?;
    final email = user?.email as String?;
    final birthDate = user?.birthDate as String?;
    final percent = _completionPercent();
    final isVerified = percent == 100;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                isBusiness
                    ? KImageConstant.businessProfile
                    : KImageConstant.userProfile,
                width: 60.w,
                height: 60.w,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: vc.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 5.w),
                          Icon(Icons.verified_rounded,
                              size: 17.sp, color: AppColor.primary),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    _IconInfoRow(
                      icon: Icons.phone_outlined,
                      text: displayPhone,
                      vc: vc,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      _IconInfoRow(
                          icon: Icons.email_outlined, text: email, vc: vc),
                    ],
                    if (!isBusiness &&
                        birthDate != null &&
                        birthDate.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      _IconInfoRow(
                          icon: Icons.cake_outlined, text: birthDate, vc: vc),
                    ],
                    if (isBusiness) ...[
                      if (category != null && category.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _capitalize(category),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                      if ((pan != null && pan.isNotEmpty) ||
                          (vat != null && vat.isNotEmpty)) ...[
                        SizedBox(height: 4.h),
                        Text(
                          pan != null && pan.isNotEmpty
                              ? 'PAN: $pan'
                              : 'VAT: $vat',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: vc.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isVerified) ...[
            SizedBox(height: 14.h),
            _CompletionBar(percent: percent, vc: vc),
          ],
        ],
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  final int percent;
  final VhandarColors vc;

  const _CompletionBar({required this.percent, required this.vc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Complete your profile',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: vc.onSurfaceMuted,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 5.h,
            backgroundColor: AppColor.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
          ),
        ),
      ],
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VhandarColors vc;
  final double? fontSize;
  final FontWeight? fontWeight;

  const _IconInfoRow({
    required this.icon,
    required this.text,
    required this.vc,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12.sp, color: vc.onSurfaceMuted),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 11.sp,
              color: vc.onSurfaceMuted,
              fontWeight: fontWeight ?? FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
