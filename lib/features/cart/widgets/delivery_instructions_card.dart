import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class DeliveryInstructionsCard extends StatefulWidget {
  const DeliveryInstructionsCard({super.key});

  @override
  State<DeliveryInstructionsCard> createState() =>
      _DeliveryInstructionsCardState();
}

class _DeliveryInstructionsCardState extends State<DeliveryInstructionsCard> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _options = [
    {
      'icon': Icons.notifications_off_outlined,
      'title': 'Not Ring The Bell',
      'subtitle': 'Partner will not ring the bell'
    },
    {
      'icon': Icons.door_back_door_outlined,
      'title': 'No Contact Delivery',
      'subtitle': 'Partner will leave your order at your door'
    },
    {
      'icon': Icons.pets_outlined,
      'title': 'Beware Of Pets',
      'subtitle': 'Partner will be informed'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: SvgPicture.asset(
            'assets/icons/vhandar_delivery_info.svg',
            width: 28.w,
            height: 28.w,
          ),
          title: Text(
            'Delivery Instructions',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: vc.onSurface),
          ),
          subtitle: Text(
            'Delivery partner will be notified',
            style: TextStyle(fontSize: 12.sp, color: vc.onSurfaceMuted),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
              child: SizedBox(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    final opt = _options[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = isSelected ? -1 : index;
                        });
                      },
                      child: Container(
                        width: 130.w,
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border.all(
                              color:
                                  isSelected ? AppColor.primary : vc.divider),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(opt['icon'],
                                color: isSelected
                                    ? AppColor.primary
                                    : vc.onSurfaceMuted,
                                size: 20.sp),
                            SizedBox(height: 4.h),
                            Text(
                              opt['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColor.primary
                                      : vc.onSurface),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              opt['subtitle'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 8.sp, color: vc.onSurfaceMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
