import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/presentation/widgets/brand_card.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class BrandScreen extends ConsumerWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandProvider);

    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFFBFBFB),
      isScrollable: false,
      appBar: const CustomScreenHeader(title: 'All Brands'),
      body: brandsAsync.when(
        data: (brands) {
          if (brands.isEmpty) {
            return const Center(child: Text("No brands found"));
          }

          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return BrandCard(
                name: brand.name ?? '',
                imageUrl: brand.images?.isNotEmpty == true
                    ? brand.images!.first.url
                    : null,
                onTap: () => navigateToSlug(context, brand.slug, isBrand: true),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
