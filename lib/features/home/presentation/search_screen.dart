import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/core/router/app_router.dart';
import 'package:vhandar/features/home/providers/search_provider.dart';
import 'package:vhandar/features/home/widgets/product_grid.dart';
import 'package:vhandar/features/home/widgets/search_sort_bar.dart';
import 'package:vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:vhandar/widgets/tff.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      horizontalPadding: 0,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _searchController,
                autofocus: true,
                hintText: 'Search for products...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).search('');
                        },
                      )
                    : null,
                onChanged: (value) {
                  setState(() {}); // to show/hide clear button
                  ref.read(searchProvider.notifier).search(value);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.barcode_reader, color: AppColor.primary),
              onPressed: () {
                context.pushNamed(LVRoute.barcodeScannerScreen.route);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: TextStyle(color: Colors.red, fontSize: 14.sp),
        ),
      );
    }

    if (state.results.isEmpty && !state.isLoading) {
      final isSearching = _searchController.text.trim().isNotEmpty;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 74.h),
              // Illustration
              Image.asset(
                'assets/images/search_empty.png',
                height: 200.h,
                width: 200.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),
              Text(
                'Nothing here yet',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Try searching again or explore our popular categories for more great options!',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed(LVRoute.productSuggestionScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFF9B141), // Orange/Amber from image
                  foregroundColor: Colors.white,
                  minimumSize: Size(200.w, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Suggest Product',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        const SearchSortBar(),
        Expanded(
          child: ProductGrid(
            products: state.sortedResults,
          ),
        ),
      ],
    );
  }
}
