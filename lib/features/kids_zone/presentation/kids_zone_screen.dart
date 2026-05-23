import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/kids_zone/providers/kids_zone_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:flutter/services.dart';

import 'games/healthy_catcher_game.dart';
import 'games/price_master_game.dart';
import 'games/grocery_matcher_game.dart';
import 'games/spelling_chef_game.dart';
import 'games/fruit_pop_game.dart';
import 'games/sort_it_out_game.dart';

class KidsZoneScreen extends ConsumerWidget {
  const KidsZoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsState = ref.watch(kidsZoneProvider);
    
    // Level progress setup: 300 coins per level
    final level = 1 + (kidsState.coins ~/ 300);
    final progress = (kidsState.coins % 300) / 300;

    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: const CustomScreenHeader(
        title: 'Kids Fun Zone 🎮',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Coins Summary & Chef Level Progress Banner ---
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.yellowAccent,
                          size: 34.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KIDS COINS WALLET',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${kidsState.coins} Coins',
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Chef Level $level',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level Progress',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8.h,
                    ),
                  ),
                ],
              ),
            ),

            // --- Section: Select Game ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Play & Learn Games 🎯',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textBlack,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Game Cards grid view
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.92,
                children: [
                  _buildGameCard(
                    context: context,
                    title: 'Food Catcher 🍎',
                    desc: 'Catch healthy items, avoid sugars!',
                    gradient: const [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    icon: Icons.shopping_basket_outlined,
                    category: 'Arcade',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HealthyCatcherGame()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Price Master 💰',
                    desc: 'Estimate item prices to score!',
                    gradient: const [Color(0xFF2196F3), Color(0xFF03A9F4)],
                    icon: Icons.calculate_outlined,
                    category: 'Math',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PriceMasterGame()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Card Match 🧩',
                    desc: 'Match grocery pairs quickly!',
                    gradient: const [Color(0xFF9C27B0), Color(0xFFE040FB)],
                    icon: Icons.grid_view_outlined,
                    category: 'Memory',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GroceryMatcherGame()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Spelling Chef 👨‍🍳',
                    desc: 'Fill in the blanks of grocery names!',
                    gradient: const [Color(0xFFFF9800), Color(0xFFFFC107)],
                    icon: Icons.restaurant_menu,
                    category: 'Spelling',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SpellingChefGame()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Fruit Pop 🍑',
                    desc: 'Tap fruits before they fly away!',
                    gradient: const [Color(0xFFE94560), Color(0xFF0F3460)],
                    icon: Icons.touch_app,
                    category: 'Reaction',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FruitPopGame()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Sort It Out 🗂️',
                    desc: 'Drag food into the right bins!',
                    gradient: const [Color(0xFF6B2FA0), Color(0xFF9B59B6)],
                    icon: Icons.drag_indicator,
                    category: 'Sorting',
                    onPlay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SortItOutGame()),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // --- Section: Rewards shop ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Redeem Rewards for Parents 🎁',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textBlack,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Play games to earn coins, then claim real grocery coupons!',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textMuted,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            _buildRewardItem(
              context,
              ref,
              title: 'Rs. 20 Parent Discount Coupon',
              desc: 'Redeem code to save Rs. 20 on your parent\'s next bill.',
              cost: 200,
              couponCode: 'KIDS20OFF',
              userCoins: kidsState.coins,
              isRedeemed: kidsState.redeemedCoupons.contains('KIDS20OFF'),
            ),
            _buildRewardItem(
              context,
              ref,
              title: 'Free Fresh Red Apple 🍎',
              desc: 'Add a free organic apple to your parent\'s delivery basket.',
              cost: 400,
              couponCode: 'FREEKIDSAPPLE',
              userCoins: kidsState.coins,
              isRedeemed: kidsState.redeemedCoupons.contains('FREEKIDSAPPLE'),
            ),
            _buildRewardItem(
              context,
              ref,
              title: 'Free Cream Chocolate Bar 🍫',
              desc: 'Add a sweet chocolate treat to your parent\'s order for free.',
              cost: 600,
              couponCode: 'FREEKIDSCHOCO',
              userCoins: kidsState.coins,
              isRedeemed: kidsState.redeemedCoupons.contains('FREEKIDSCHOCO'),
            ),
            _buildRewardItem(
              context,
              ref,
              title: 'Rs. 50 Parent Discount Coupon',
              desc: 'Redeem code to save Rs. 50 on your parent\'s next bill.',
              cost: 800,
              couponCode: 'KIDS50OFF',
              userCoins: kidsState.coins,
              isRedeemed: kidsState.redeemedCoupons.contains('KIDS50OFF'),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String desc,
    required List<Color> gradient,
    required IconData icon,
    required String category,
    required VoidCallback onPlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20.sp),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String desc,
    required int cost,
    required String couponCode,
    required int userCoins,
    required bool isRedeemed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textMuted,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.monetization_on,
                        color: Colors.orange, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$cost Coins',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          if (isRedeemed)
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: couponCode));
                CustomSnackbar.success(context,
                    message: 'Coupon code $couponCode copied to clipboard!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary.withOpacity(0.1),
                foregroundColor: AppColor.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Copy Code',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            )
          else
            ElevatedButton(
              onPressed: userCoins < cost
                  ? null
                  : () {
                      CustomDialog.show(
                        context: context,
                        icon: Icons.card_giftcard,
                        title: 'Redeem Reward',
                        message:
                            'Redeem $cost Coins to unlock this parent coupon code: $couponCode?',
                        confirmLabel: 'Redeem Now',
                        onConfirm: () async {
                          final success = await ref
                              .read(kidsZoneProvider.notifier)
                              .redeemCoupon(couponCode, cost);
                          if (success && context.mounted) {
                            CustomSnackbar.success(context,
                                message:
                                    'Unlocked successfully! Tell your parents to use code $couponCode.');
                          }
                        },
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Unlock',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
