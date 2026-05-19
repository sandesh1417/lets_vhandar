import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/widgets/account_menu_item.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/widgets/account_section.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;

    return CustomScaffoldWrapper(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomScreenHeader(title: 'Personal Information'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildInfoCard(context, user),
            SizedBox(height: 10.h),
            AccountSection(
              // title: 'Danger Zone',
              children: [
                AccountMenuItem(
                  showRightArrow: false,
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  showDivider: false,
                  onTap: () => showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onPressed: () {
                  // Navigate to Edit Profile
                },
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                child: Icon(Icons.person, size: 45.sp, color: AppColor.primary),
              ),
              SizedBox(width: 20.w),
              _buildPointsBadge('844'), // Placeholder points
            ],
          ),
          SizedBox(height: 30.h),
          _buildInfoRow('Name', user?.name ?? '-'),
          _buildInfoRow('Phone Number', user?.phoneNumber ?? '-'),
          _buildInfoRow('Email Address', user?.email ?? '-'),
          _buildInfoRow('Date of Birth', '-'),
          _buildInfoRow('Gender', '-'),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(String points) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0D4D3B),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(Icons.workspace_premium,
                color: Colors.orange, size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'vhandarpoints',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D4D3B),
                ),
              ),
              Text(
                points,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  CustomDialog.show(
    context: context,
    icon: Icons.delete_forever_outlined,
    iconColor: Colors.red.shade400,
    iconBgColor: Colors.red.shade50,
    title: 'Delete Account',
    message:
        'This action is permanent and cannot be undone. All your data, orders, and addresses will be removed.',
    confirmLabel: 'Yes, Delete Account',
    confirmGradient: [Colors.red.shade600, Colors.red.shade400],
    onConfirm: () async {
      await ref.read(loginProvider.notifier).deleteAccount(context);
    },
  );
}
