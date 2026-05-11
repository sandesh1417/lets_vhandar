import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_grid.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

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
      horizontalPadding: 16.w,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: CustomTextField(
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

    if (!state.isLoading &&
        state.results.isEmpty &&
        _searchController.text.trim().isNotEmpty) {
      return Center(
        child: Text(
          'No products found.',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'What are you looking for?',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ProductGrid(
            products: state.results,
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
