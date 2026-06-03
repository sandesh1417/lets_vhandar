import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';
import 'package:lets_vhandar/features/my_list/providers/my_list_provider.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myListProvider);
    final vc = context.vColors;
    final list = state.lists.firstWhere(
      (l) => l.id == listId,
      orElse: () =>
          SavedList(id: listId, name: 'List', createdAt: DateTime.now()),
    );

    return Scaffold(
      backgroundColor: vc.scaffoldBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: vc.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18.sp, color: vc.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                ),
                if (list.products.isNotEmpty)
                  Text(
                    '${list.products.length} item${list.products.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: 'Inter',
                      color: vc.onSurfaceMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: vc.divider),
            ),
          ),
        ],
        body: list.products.isEmpty
            ? _buildEmpty(context, ref, list)
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
                itemCount: list.products.length,
                itemBuilder: (context, i) {
                  final product = list.products[i];
                  return _ProductTile(
                    product: product,
                    onRemove: () => ref
                        .read(myListProvider.notifier)
                        .removeProduct(listId, product.id),
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, list),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref, SavedList list) {
    final vc = context.vColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40.sp,
              color: AppColor.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'List is Empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap "Add Products" below\nto build your list.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Inter',
              color: vc.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, SavedList list) {
    final vc = context.vColors;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 12.h, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: vc.surface,
        border: Border(top: BorderSide(color: vc.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: () => _showAddProductSheet(context, ref, list),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            'Add Products',
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProductSheet(
      BuildContext context, WidgetRef ref, SavedList list) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddProductSheet(listId: listId, list: list),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final SavedProduct product;
  final VoidCallback onRemove;

  const _ProductTile({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: vc.surfaceVariant,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: vc.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: product.imageUrl != null
                  ? CustomImageViewer(
                      path: product.imageUrl,
                      fit: BoxFit.contain,
                      borderRadius: 10.r,
                    )
                  : Icon(Icons.shopping_bag_outlined,
                      color: Colors.grey.shade400, size: 26.sp),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Product',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.unit != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    product.unit!,
                    style: TextStyle(
                        fontSize: 11.sp, color: vc.onSurfaceMuted),
                  ),
                ],
                if (product.price != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Rs. ${product.price!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.remove_rounded,
                color: Colors.red.shade400,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Product Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddProductSheet extends ConsumerStatefulWidget {
  final String listId;
  final SavedList list;

  const _AddProductSheet({required this.listId, required this.list});

  @override
  ConsumerState<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<_AddProductSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final searchState = ref.watch(searchProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 6.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: vc.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Products',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface,
                          ),
                        ),
                        Text(
                          'to "${widget.list.name}"',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Inter',
                            color: vc.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: vc.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: vc.onSurfaceMuted, size: 18.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Container(
                height: 46.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: vc.surfaceVariant,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: vc.divider),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: vc.onSurfaceMuted, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) =>
                            ref.read(searchProvider.notifier).search(v),
                        style: TextStyle(
                            fontSize: 14.sp, color: vc.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                              fontSize: 13.sp, color: vc.onSurfaceMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          ref.read(searchProvider.notifier).search('');
                        },
                        child: Icon(Icons.close_rounded,
                            color: vc.onSurfaceMuted, size: 18.sp),
                      ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: vc.divider),

            // Results
            Expanded(
              child: searchState.isLoading
                  ? const Center(child: CustomCircularLoader())
                  : searchState.results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                searchState.query.isEmpty
                                    ? Icons.search_rounded
                                    : Icons.search_off_rounded,
                                size: 40.sp,
                                color: vc.onSurfaceMuted
                                    .withValues(alpha: 0.4),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                searchState.query.isEmpty
                                    ? 'Type to search products'
                                    : 'No results for "${searchState.query}"',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: vc.onSurfaceMuted,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: searchState.results.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 80.w,
                            color: context.vColors.divider,
                          ),
                          itemBuilder: (ctx, i) {
                            final product = searchState.results[i];
                            if (product.id == null) return const SizedBox();
                            return _SearchResultTile(
                              product: product,
                              listId: widget.listId,
                              alreadyAdded: widget.list.products
                                  .any((p) => p.id == product.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Result Tile
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultTile extends ConsumerWidget {
  final ProductData product;
  final String listId;
  final bool alreadyAdded;

  const _SearchResultTile({
    required this.product,
    required this.listId,
    required this.alreadyAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;
    final isAdded = ref.watch(myListProvider.select((s) => s.lists.any(
        (l) => l.id == listId && l.products.any((p) => p.id == product.id))));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Image
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: vc.surfaceVariant,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: vc.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CustomImageViewer(
                path: product.images?.first.url,
                fit: BoxFit.contain,
                borderRadius: 10.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.unit != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    product.unit!,
                    style: TextStyle(
                        fontSize: 11.sp, color: vc.onSurfaceMuted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Add / Added button
          GestureDetector(
            onTap: isAdded
                ? () => ref
                    .read(myListProvider.notifier)
                    .removeProduct(listId, product.id!)
                : () async {
                    final saved = SavedProduct(
                      id: product.id!,
                      name: product.name,
                      unit: product.unit,
                      price: product.actualPrice,
                      imageUrl: product.images?.isNotEmpty == true
                          ? product.images!.first.url
                          : null,
                    );
                    final wasAdded = await ref
                        .read(myListProvider.notifier)
                        .addProduct(listId, saved);
                    if (!wasAdded && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name ?? 'Item'} is already in this list'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isAdded ? AppColor.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isAdded ? AppColor.primary : vc.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                isAdded ? 'Added' : 'Add',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: isAdded ? Colors.white : vc.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
