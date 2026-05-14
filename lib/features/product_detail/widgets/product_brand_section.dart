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
                margin: EdgeInsets.symmetric(vertical: 20.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.symmetric(
                    horizontal:
                        BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Brand Logo
                    Container(
                      width: 64.w,
                      height: 64.w,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: CustomImageViewer(
                        path: brand.images?.isNotEmpty == true
                            ? brand.images!.first.url
                            : null,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Brand Name & Explore
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand.name ?? 'Brand Name',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B3E2F),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Explore all products',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColor.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade300),
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
