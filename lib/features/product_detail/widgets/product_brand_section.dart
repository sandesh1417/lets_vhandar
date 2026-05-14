import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class ProductBrandSection extends ConsumerWidget {
  final String brandId;
  const ProductBrandSection({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(brandByIdProvider(brandId)).when(
          data: (brand) {
            if (brand == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => context.pushNamed('brandDetailScreen',
                  pathParameters: {'slug': brand.slug ?? ''}),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    // Minimized Brand Logo
                    Container(
                      width: 42.w,
                      height: 42.w,
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: CustomImageViewer(
                        path: brand.images?.isNotEmpty == true
                            ? brand.images!.first.url
                            : null,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Brand Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            brand.name ?? 'Brand Name',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textBlack87,
                            ),
                          ),
                          Text(
                            'Explore Brand',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColor.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.grey.shade400, size: 14.sp),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
