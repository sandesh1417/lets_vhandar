import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Wallet'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(),
            SizedBox(height: 28.h),
            Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 20.h),
            _EmptyTransactions(),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF064D34),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064D34).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: SvgPicture.asset(
                  'assets/icons/wallet.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Rs. 0',
            style: TextStyle(
              fontSize: 34.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Available to use on your next order',
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          SvgPicture.asset(
            'assets/icons/transaction.svg',
            width: 140.w,
            height: 140.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: context.vColors.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Your wallet transaction history\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              color: context.vColors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
