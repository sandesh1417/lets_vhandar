import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/presentation/widgets/brand_card.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';

class BrandScreen extends ConsumerStatefulWidget {
  const BrandScreen({super.key});

  @override
  ConsumerState<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends ConsumerState<BrandScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandProvider);

    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFFBFBFB),
      isScrollable: false,
      resizeToAvoidBottomInset: false,
      appBar: const CustomScreenHeader(title: 'All Brands'),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: PremiumSearchBar(
              controller: _searchController,
              hintText: 'Search brands...',
              showScanIcon: false,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: brandsAsync.when(
              data: (brands) {
                if (brands.isEmpty) {
                  return const Center(child: Text("No brands found"));
                }

                final filteredBrands = _searchQuery.isEmpty
                    ? brands
                    : brands
                        .where((brand) => (brand.name ?? '')
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                if (filteredBrands.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching brands found",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
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
                  itemCount: filteredBrands.length,
                  itemBuilder: (context, index) {
                    final brand = filteredBrands[index];
                    return BrandCard(
                      name: brand.name ?? '',
                      imageUrl: brand.images?.isNotEmpty == true
                          ? brand.images!.first.url
                          : null,
                      onTap: () =>
                          navigateToSlug(context, brand.slug, isBrand: true),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
