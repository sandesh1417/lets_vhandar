import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';

class CategorySearchAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String categorySlug;
  final String categoryName;

  const CategorySearchAppBar({
    super.key,
    required this.categorySlug,
    required this.categoryName,
  });

  @override
  ConsumerState<CategorySearchAppBar> createState() => _CategorySearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CategorySearchAppBarState extends ConsumerState<CategorySearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
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
                ref.read(searchQueryProvider(widget.categorySlug).notifier).state = value;
              },
            )
          : Text(
              widget.categoryName,
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            ref.watch(subCategoryLayoutProvider(widget.categorySlug))
                ? Icons.view_sidebar_rounded
                : Icons.view_headline_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            final current =
                ref.read(subCategoryLayoutProvider(widget.categorySlug));
            ref.read(subCategoryLayoutProvider(widget.categorySlug).notifier).state =
                !current;
          },
        ),
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.close : Icons.search,
              color: Colors.black),
          onPressed: () {
            setState(() {
              if (_isSearchExpanded) {
                _searchController.clear();
                ref.read(searchQueryProvider(widget.categorySlug).notifier).state =
                    '';
              }
              _isSearchExpanded = !_isSearchExpanded;
            });
          },
        ),
      ],
    );
  }
}
