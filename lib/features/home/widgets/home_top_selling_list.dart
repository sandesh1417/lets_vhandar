import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';

class HomeFeaturedProductsList extends StatelessWidget {
  const HomeFeaturedProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return const ProductItemCard(
            name: 'Product Name',
            price: '₹99',
            save: '₹10',
          );
        },
      ),
    );
  }
}
