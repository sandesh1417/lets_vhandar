import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';
import 'package:lets_vhandar/features/my_list/providers/my_list_provider.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myListProvider);
    final list = state.lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => SavedList(
          id: listId, name: 'List', createdAt: DateTime.now()),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomScreenHeader(title: list.name),
      body: list.products.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: list.products.length,
              itemBuilder: (context, i) {
                final product = list.products[i];
                return _ProductListTile(
                  product: product,
                  onRemove: () => ref
                      .read(myListProvider.notifier)
                      .removeProduct(listId, product.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context, ref, list),
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/vhandar_favorite_lists.svg',
              width: 140.w,
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
            SizedBox(height: 8.h),
            Text(
              'Tap "Add Products" to start\nbuilding your list.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Inter',
                color: vc.onSurfaceMuted,
                height: 1.5,
              ),
            ),
          ],
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
    final searchState = ref.watch(searchProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.vColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.vColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'Add to "${widget.list.name}"',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: context.vColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        color: context.vColors.onSurfaceMuted, size: 22.sp),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: context.vColors.divider,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: context.vColors.onSurfaceMuted, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) =>
                            ref.read(searchProvider.notifier).search(v),
                        style: TextStyle(fontSize: 13.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                              fontSize: 13.sp, color: Colors.grey.shade400),
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
                        child: Icon(Icons.close,
                            color: Colors.grey.shade400, size: 18.sp),
                      ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: context.vColors.divider),

            // Results
            Expanded(
              child: searchState.isLoading
                  ? const Center(child: CustomCircularLoader())
                  : searchState.results.isEmpty
                      ? Center(
                          child: Text(
                            searchState.query.isEmpty
                                ? 'Type to search products'
                                : 'No results found',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: searchState.results.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 72.w,
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
    final isAdded =
        ref.watch(myListProvider.select((s) => s.lists.any((l) =>
            l.id == listId && l.products.any((p) => p.id == product.id))));

    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: context.vColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: context.vColors.divider),
        ),
        child: CustomImageViewer(
          path: product.images?.first.url,
          fit: BoxFit.contain,
          borderRadius: 8.r,
        ),
      ),
      title: Text(
        product.name ?? '',
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: context.vColors.onSurface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        product.unit ?? '',
        style: TextStyle(
            fontSize: 11.sp, color: context.vColors.onSurfaceMuted),
      ),
      trailing: GestureDetector(
        onTap: isAdded
            ? () => ref
                .read(myListProvider.notifier)
                .removeProduct(listId, product.id!)
            : () {
                final saved = SavedProduct(
                  id: product.id!,
                  name: product.name,
                  unit: product.unit,
                  price: product.actualPrice,
                  imageUrl: product.images?.isNotEmpty == true
                      ? product.images!.first.url
                      : null,
                );
                ref
                    .read(myListProvider.notifier)
                    .addProduct(listId, saved);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: isAdded
                ? AppColor.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isAdded ? AppColor.primary : context.vColors.divider,
            ),
          ),
          child: Text(
            isAdded ? 'Added' : 'Add',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: isAdded ? Colors.white : context.vColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final SavedProduct product;
  final VoidCallback onRemove;

  const _ProductListTile({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
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
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: context.vColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: context.vColors.divider),
            ),
            child: product.imageUrl != null
                ? CustomImageViewer(
                    path: product.imageUrl,
                    fit: BoxFit.contain,
                    borderRadius: 8.r,
                  )
                : Icon(Icons.shopping_bag_outlined,
                    color: Colors.grey.shade400, size: 24.sp),
          ),
          SizedBox(width: 12.w),
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
                    color: context.vColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.unit != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    product.unit!,
                    style: TextStyle(
                        fontSize: 11.sp, color: context.vColors.onSurfaceMuted),
                  ),
                ],
                if (product.price != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Rs. ${product.price!.toInt()}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.remove_circle_outline,
                color: Colors.red.shade400, size: 22.sp),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
