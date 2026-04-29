import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_summary_bar.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/providers/brand_detail_provider.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_grid.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class BrandDetailScreen extends ConsumerStatefulWidget {
  final String brandSlug;

  const BrandDetailScreen({super.key, required this.brandSlug});

  @override
  ConsumerState<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends ConsumerState<BrandDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  late String _currentBrandSlug;

  @override
  void initState() {
    super.initState();
    _currentBrandSlug = widget.brandSlug;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandProvider);
    final brandAsync = ref.watch(brandBySlugProvider(_currentBrandSlug));
    final productsAsync =
        ref.watch(filteredBrandProductsProvider(_currentBrandSlug));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                style: TextStyle(fontSize: 14.sp),
                onChanged: (value) {
                  ref
                      .read(
                          brandSearchQueryProvider(_currentBrandSlug).notifier)
                      .state = value;
                },
              )
            : brandAsync.when(
                data: (brand) => Text(
                  brand.name ?? '',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const Text('Brand'),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search,
                color: Colors.black),
            onPressed: () {
              setState(() {
                if (_isSearchExpanded) {
                  _searchController.clear();
                  ref
                      .read(
                          brandSearchQueryProvider(_currentBrandSlug).notifier)
                      .state = '';
                }
                _isSearchExpanded = !_isSearchExpanded;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Brands Sidebar
              Container(
                width: 85.w,
                color: const Color(0xFFF8F9FA),
                child: brandsAsync.when(
                  data: (brands) {
                    return ListView.builder(
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        final isSelected = _currentBrandSlug == brand.slug;
                        return _buildSidebarItem(
                          brand.name ?? '',
                          brand.slug!,
                          isSelected,
                          brand.images?.isNotEmpty == true
                              ? brand.images!.first.url
                              : null,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Icon(Icons.error_outline, size: 24.sp)),
                ),
              ),
              // Product Grid Area
              Expanded(
                child: Column(
                  children: [
                    // Sort Bar
                    _buildSortBar(),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF5F6F8),
                        child: productsAsync.when(
                          data: (products) {
                            if (products.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined,
                                        size: 48.sp, color: Colors.grey),
                                    SizedBox(height: 12.h),
                                    Text('No products found',
                                        style: TextStyle(
                                            color: AppColor.textMuted,
                                            fontSize: 14.sp)),
                                  ],
                                ),
                              );
                            }
                            return ProductGrid(products: products);
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                'Error: $err',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 12.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CartSummaryBar(
              onTap: () {
                ref.read(dashboardIndexProvider.notifier).state = 3;
                context.go('/dashboardScreen');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    final currentSort = ref.watch(brandSelectedSortProvider(_currentBrandSlug));
    final sortLabels = {
      'relevance': 'Relevance',
      'price_low_high': 'Price (Low to High)',
      'price_high_low': 'Price (High to Low)',
      'discount_high_low': 'Discount (High to Low)',
      'discount_low_high': 'Discount (Low to High)',
      'name_a_z': 'Name (A to Z)',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Sort By',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () => _showSortModal(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sortLabels[currentSort] ?? 'Relevance',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down,
                      size: 14.sp, color: AppColor.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortModal() {
    final options = [
      {'val': 'relevance', 'label': 'Relevance'},
      {'val': 'price_low_high', 'label': 'Price (Low to High)'},
      {'val': 'price_high_low', 'label': 'Price (High to Low)'},
      {'val': 'discount_high_low', 'label': 'Discount (High to Low)'},
      {'val': 'discount_low_high', 'label': 'Discount (Low to High)'},
      {'val': 'name_a_z', 'label': 'Name (A to Z)'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    'Sort By',
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final currentSort = ref
                          .watch(brandSelectedSortProvider(_currentBrandSlug));
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final isSelected = currentSort == opt['val'];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              opt['label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColor.primary
                                    : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: AppColor.primary)
                                : const Icon(Icons.radio_button_unchecked,
                                    color: Colors.grey),
                            onTap: () {
                              ref
                                  .read(brandSelectedSortProvider(
                                          _currentBrandSlug)
                                      .notifier)
                                  .state = opt['val'];
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (context.mounted) Navigator.pop(context);
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem(
      String title, String slug, bool isSelected, String? imageUrl) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentBrandSlug = slug;
          _isSearchExpanded = false;
          _searchController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(width: 4.w, color: AppColor.primary),
                )
              : null,
        ),
        child: Column(
          children: [
            if (imageUrl != null) ...[
              CustomImageViewer(
                path: imageUrl,
                height: 32.h,
                width: 32.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 4.h),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColor.primary : AppColor.textBlack54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
