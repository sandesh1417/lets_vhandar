import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

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
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Icon(Icons.markunread_mailbox_outlined,
              color: AppColor.primary, size: 28.sp),
          title: Text(
            'Delivery Instructions',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack),
          ),
          subtitle: Text(
            'Delivery partner will be notified',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: SizedBox(
                height: 120.h,
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
                        width: 140.w,
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade50
                              : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(opt['icon'],
                                color: isSelected
                                    ? AppColor.primary
                                    : Colors.grey.shade500,
                                size: 24.sp),
                            SizedBox(height: 8.h),
                            Text(
                              opt['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColor.primary
                                      : AppColor.textBlack),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              opt['subtitle'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 9.sp, color: Colors.grey.shade600),
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
