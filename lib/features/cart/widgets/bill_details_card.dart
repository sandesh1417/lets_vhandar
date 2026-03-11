import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class BillDetailsCard extends StatelessWidget {
  final int totalItems;
  final double totalPrice;
  final double totalMrp;

  const BillDetailsCard({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.totalMrp,
  });

  @override
  Widget build(BuildContext context) {
    final double savings = totalMrp - totalPrice;
    final bool hasSavings = savings > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.greenTxtColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items total',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColor.textBlack87)),
                            if (hasSavings) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE4B9),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('Saved Rs.${savings.toInt()}',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8D5B18))),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasSavings)
                          Text('Rs. ${totalMrp.toInt()}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColor.textStrikeThrough,
                                  decoration: TextDecoration.lineThrough)),
                        Text('Rs. ${totalPrice.toInt()}',
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delivery_dining,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Delivery charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Rs.100',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.textStrikeThrough,
                                decoration: TextDecoration.lineThrough)),
                        SizedBox(width: 6.w),
                        Text('FREE',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.secondary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Handling Charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Text('Rs.0',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grand total',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.greenTxtColor)),
                        SizedBox(height: 2.h),
                        Text('Incl. all taxes and charges',
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColor.textMuted)),
                      ],
                    ),
                    Text('Rs. ${totalPrice.toInt()}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary)),
                  ],
                ),
              ],
            ),
          ),
          // Saved Banner bottom part
          if (hasSavings)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4B9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer,
                      size: 14.sp, color: const Color(0xFF8D5B18)),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF8D5B18)),
                      children: [
                        TextSpan(
                            text: 'Rs. ${savings.toInt()} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Saved! Free Delivery!'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
