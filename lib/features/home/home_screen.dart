import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          SizedBox(height: 16.h),
          const HomeBannerSlider(),
          SizedBox(height: 12.h),
          HomeSectionTitle(
            title: 'Featured Products',
            onSeeAll: () {
              // Handle See All Top Selling
            },
          ),
          const HomeFeaturedProductsList(),
          HomeSectionTitle(
            title: 'Explore By Categories',
            onSeeAll: () {
              // Handle See All Categories
            },
          ),
          const HomeCategoriesGrid(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
