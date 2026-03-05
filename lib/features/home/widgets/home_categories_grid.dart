import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCategoriesGrid extends StatelessWidget {
  const HomeCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 60.h,
              width: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(Icons.category_outlined,
                    color: Colors.grey, size: 24.sp),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Cat $index',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
