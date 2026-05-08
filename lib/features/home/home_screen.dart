import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF0FAF5), // very light green tint
            const Color(0xFFFCFCFC), // near white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            SizedBox(height: 14.h),
            const HomeBannerSlider(),
            SizedBox(height: 20.h),
            HomeSectionTitle(
              title: 'Featured Products',
              subtitle: 'Hand-picked for you today',
              onSeeAll: () {},
            ),
            const HomeFeaturedProductsList(),
            SizedBox(height: 20.h),
            HomeSectionTitle(
              title: 'Shop by Category',
              subtitle: 'Find exactly what you need',
              onSeeAll: () {},
            ),
            const HomeCategoriesGrid(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
