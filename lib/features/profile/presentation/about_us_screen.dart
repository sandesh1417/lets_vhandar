import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_info.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/social_media_row.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  String get _appVersion => AppInfo.version;
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=vhandar.com';

  void _shareApp() {
    SharePlus.instance.share(ShareParams(
      text:
          "Shop groceries fast with Vhandar!\n\nDownload the app: $_playStoreUrl",
      subject: "Let's Vhandar – Quick Grocery Delivery",
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
      backgroundColor: vc.scaffoldBg,
      appBar: const CustomScreenHeader(title: 'About'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24.w, 0, 24.w, MediaQuery.of(context).padding.bottom + 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            Image.asset(
              KImageConstant.appIcon,
              width: 100.w,
              height: 100.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12.h),
            Text(
              'Quick & easy way to get groceries delivered',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurfaceMuted,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Enjoy effortless online grocery shopping with swift delivery services and a diverse range of essential items.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurfaceMuted,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '#letsvhandar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Version $_appVersion',
                style: TextStyle(
                  color: const Color(0xFF6F4B00),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            const SocialMediaRow(),
            SizedBox(height: 28.h),
            Divider(color: vc.divider, thickness: 1),
            SizedBox(height: 16.h),
            Text(
              'Vhandar Merchandise Pvt Ltd',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurface,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Reg.no: 354027/81/82',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurfaceMuted,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shareApp,
                icon: Icon(Icons.ios_share_rounded,
                    size: 18.sp, color: AppColor.primary),
                label: Text(
                  'Share Vhandar App',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(
                      color: AppColor.primary.withValues(alpha: 0.4),
                      width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
