import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/brand_detail_provider.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_grid.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

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

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return CustomScaffoldWrapper(
      backgroundColor: context.vColors.scaffoldBg,
      isScrollable: false,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.only(
              top: statusBarHeight + 10.h,
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _isSearchExpanded
                      ? Container(
                          height: 42.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 20.sp,
                                color: context.isDark
                                    ? Colors.white60
                                    : Colors.grey.shade400,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: context.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyle(
                                      fontSize: 13.sp,
                                      color: context.isDark
                                          ? Colors.white54
                                          : Colors.grey.shade400,
                                      fontFamily: 'Inter',
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    isCollapsed: true,
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(brandSearchQueryProvider(
                                                _currentBrandSlug)
                                            .notifier)
                                        .state = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : brandAsync.when(
                          data: (brand) {
                            final imageUrl = brand.images?.firstOrNull?.url ??
                                brand.images?.firstOrNull?.path;
                            return Row(
                              children: [
                                if (imageUrl != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CustomImageViewer(
                                      path: imageUrl,
                                      width: 34.w,
                                      height: 34.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                                Expanded(
                                  child: Text(
                                    brand.name ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showSortModal(),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isSearchExpanded) {
                        _searchController.clear();
                        ref
                            .read(brandSearchQueryProvider(_currentBrandSlug)
                                .notifier)
                            .state = '';
                      }
                      _isSearchExpanded = !_isSearchExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _isSearchExpanded ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: ref.watch(appLayoutProvider)
          ? Row(
              children: [
                // Brands Sidebar
                Container(
                  width: 76.w,
                  color: context.vColors.surface,
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
                        Center(child: CircularProgressIndicator(color: AppColor.primary)),
                    error: (err, _) =>
                        Center(child: Icon(Icons.error_outline, size: 24.sp)),
                  ),
                ),
                // Product Grid Area
                Expanded(
                  child: Container(
                    color: context.vColors.scaffoldBg,
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
                        return ProductGrid(
                          products: products,
                          padding: EdgeInsets.fromLTRB(5.w, 6.h, 5.w, 40.h),
                          mainAxisSpacing: 6.h,
                          crossAxisSpacing: 6.w,
                        );
                      },
                      loading: () =>
                          Center(child: CircularProgressIndicator(color: AppColor.primary)),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text('Error: $err',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red, fontSize: 12.sp)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: context.vColors.scaffoldBg,
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
                    Center(child: CircularProgressIndicator(color: AppColor.primary)),
                error: (err, _) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text('Error: $err',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.red, fontSize: 12.sp)),
                  ),
                ),
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
      backgroundColor: context.vColors.surface,
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
                        color: context.vColors.divider,
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
                                    : context.vColors.onSurface,
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
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(width: 3.w, color: AppColor.primary),
                )
              : null,
        ),
        child: Column(
          children: [
            if (imageUrl != null) ...[
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.r),
                  child: CustomImageViewer(
                    path: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColor.primary : context.vColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
