import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductItemCard extends StatelessWidget {
  final String? name;
  final String? price;
  final String? save;

  const ProductItemCard({
    super.key,
    this.name,
    this.price,
    this.save,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
                child: Center(
                  child: Icon(Icons.image,
                      color: Colors.grey.shade300, size: 40.sp),
                ),
              ),
              if (save != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r)),
                    ),
                    child: Column(
                      children: [
                        Text('SAVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold)),
                        Text(save!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? 'Product Name',
                    style:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Text(price ?? '₹0',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
