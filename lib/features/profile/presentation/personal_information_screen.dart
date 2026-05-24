import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomScreenHeader(
        title: 'Personal Information',
        trailing: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, color: Colors.white, size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green cover + floating avatar card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100.h,
                  width: double.infinity,
                  color: AppColor.primary,
                ),
                Positioned(
                  bottom: -50.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46.r,
                        backgroundColor:
                            AppColor.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person,
                            size: 50.sp, color: AppColor.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 62.h),

            // Name + phone under avatar
            Text(
              user?.name ?? 'User',
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              user?.phoneNumber ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 28.h),

            // Info card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: user?.name ?? '-',
                    showDivider: true,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: user?.phoneNumber != null
                        ? '${user?.phoneCode ?? ''} ${user?.phoneNumber}'
                        : '-',
                    showDivider: true,
                  ),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: user?.email?.isNotEmpty == true
                        ? user!.email!
                        : '-',
                    showDivider: true,
                  ),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: user?.birthDate ?? '-',
                    showDivider: true,
                  ),
                  _InfoRow(
                    icon: Icons.wc_outlined,
                    label: 'Gender',
                    value: user?.gender ?? '-',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Delete account button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () => showDeleteAccountDialog(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever_outlined,
                          color: Colors.red.shade600, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColor.primary, size: 18.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 68.w,
            endIndent: 16.w,
            color: Colors.grey.shade100,
          ),
      ],
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
