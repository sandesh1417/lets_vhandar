import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;
    final isBusiness = user?.isBusiness == true;
    final businessDetail = user?.businessDetail;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomScreenHeader(
        title: isBusiness ? 'Business Information' : 'Personal Information',
        trailing: GestureDetector(
          onTap: () => context.push(LVRoute.editProfileScreen.route),
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
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
                        color: context.vColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        isBusiness
                            ? KImageConstant.businessProfile
                            : KImageConstant.userProfile,
                        width: 92.w,
                        height: 92.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 62.h),

            // Name + phone/category under avatar
            Text(
              isBusiness
                  ? (businessDetail?['businessName'] as String? ??
                      user?.name ??
                      'Business')
                  : (user?.name ?? 'User'),
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isBusiness
                  ? (businessDetail?['businessCategory'] as String? ?? '')
                  : (user?.phoneNumber ?? ''),
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 20.h),

            // ── Profile completion card ─────────────────────────────
            _ProfileCompletionCard(
              user: user,
              isBusiness: isBusiness,
              businessDetail: businessDetail,
              onEdit: () => context.push(LVRoute.editProfileScreen.route),
            ),

            SizedBox(height: 20.h),

            // Info card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: context.vColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isBusiness
                  ? Column(
                      children: [
                        _InfoRow(
                          icon: Icons.store_outlined,
                          label: 'Business Name',
                          value:
                              businessDetail?['businessName'] as String? ?? '-',
                          showDivider: true,
                        ),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Mobile Number',
                          value: user?.phoneNumber != null
                              ? '${user?.phoneCode ?? ''} ${user!.phoneNumber}'
                              : '-',
                          showDivider: true,
                        ),
                        _InfoRow(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value:
                              businessDetail?['businessCategory'] as String? ??
                                  '-',
                          showDivider: true,
                        ),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: _panVatLabel(businessDetail),
                          value: _panVatValue(businessDetail),
                          showDivider: true,
                        ),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Business Location',
                          value: _locationAddress(businessDetail),
                          showDivider: false,
                        ),
                      ],
                    )
                  : Column(
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
                    color: context.isDark
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.isDark
                          ? Colors.red.withValues(alpha: 0.35)
                          : Colors.red.shade100,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever_outlined,
                          color: context.isDark
                              ? Colors.red.shade300
                              : Colors.red.shade600,
                          size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: context.isDark
                              ? Colors.red.shade300
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Completion Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCompletionCard extends StatelessWidget {
  final dynamic user;
  final bool isBusiness;
  final Map<String, dynamic>? businessDetail;
  final VoidCallback onEdit;

  const _ProfileCompletionCard({
    required this.user,
    required this.isBusiness,
    required this.businessDetail,
    required this.onEdit,
  });

  List<({String label, IconData icon, bool filled})> _fields() {
    if (isBusiness) {
      final pan = businessDetail?['panNumber'] as String?;
      final vat = businessDetail?['vatNumber'] as String?;
      final hasPanVat =
          (pan != null && pan.isNotEmpty) || (vat != null && vat.isNotEmpty);
      final location = businessDetail?['locationAddress'] as String? ??
          businessDetail?['addressName'] as String?;
      return [
        (
          label: 'Business Name',
          icon: Icons.store_outlined,
          filled:
              (businessDetail?['businessName'] as String?)?.isNotEmpty == true,
        ),
        (
          label: 'Category',
          icon: Icons.category_outlined,
          filled:
              (businessDetail?['businessCategory'] as String?)?.isNotEmpty ==
                  true,
        ),
        (
          label: 'PAN / VAT Number',
          icon: Icons.badge_outlined,
          filled: hasPanVat,
        ),
        (
          label: 'Business Location',
          icon: Icons.location_on_outlined,
          filled: location != null && location.isNotEmpty,
        ),
      ];
    }
    return [
      (
        label: 'Full Name',
        icon: Icons.person_outline,
        filled: (user?.name as String?)?.isNotEmpty == true,
      ),
      (
        label: 'Email Address',
        icon: Icons.email_outlined,
        filled: (user?.email as String?)?.isNotEmpty == true,
      ),
      (
        label: 'Date of Birth',
        icon: Icons.cake_outlined,
        filled: (user?.birthDate as String?)?.isNotEmpty == true,
      ),
      (
        label: 'Gender',
        icon: Icons.wc_outlined,
        filled: (user?.gender as String?)?.isNotEmpty == true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final fields = _fields();
    final filled = fields.where((f) => f.filled).length;
    final total = fields.length;
    final percent = total == 0 ? 1.0 : filled / total;
    final isComplete = filled == total;

    final Color progressColor = isComplete
        ? const Color(0xFF2E7D32)
        : percent >= 0.6
            ? AppColor.primary
            : const Color(0xFFF5B237);

    final missing = fields.where((f) => !f.filled).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: vc.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete
                          ? 'Profile Complete 🎉'
                          : 'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: vc.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isComplete
                          ? 'Your profile is fully set up'
                          : '${missing.length} field${missing.length == 1 ? '' : 's'} left to complete',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'Inter',
                        color: vc.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${(percent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // ── Progress bar ─────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 7.h,
                backgroundColor: vc.divider,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Field count label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$filled / $total fields filled',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Inter',
                  color: vc.onSurfaceMuted,
                ),
              ),
              if (!isComplete)
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Fill now →',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ),
            ],
          ),

          // ── Missing fields ────────────────────────────────────────
          if (missing.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Divider(height: 1, color: vc.divider),
            SizedBox(height: 12.h),
            Text(
              'What\'s missing',
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: vc.onSurfaceMuted,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: missing.map((f) {
                return GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5B237).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFF5B237).withValues(alpha: 0.40),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(f.icon,
                            size: 12.sp, color: const Color(0xFFB07000)),
                        SizedBox(width: 5.w),
                        Text(
                          f.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB07000),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
    final vc = context.vColors;
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
                        color: vc.onSurfaceMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: vc.onSurface,
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
            color: vc.divider,
          ),
      ],
    );
  }
}

String _locationAddress(Map<String, dynamic>? detail) {
  return (detail?['locationAddress'] ?? detail?['addressName'] ?? '-')
      as String;
}

String _panVatLabel(Map<String, dynamic>? detail) {
  final pan = detail?['panNumber'] as String?;
  if (pan != null && pan.isNotEmpty) return 'PAN No.';
  return 'VAT No.';
}

String _panVatValue(Map<String, dynamic>? detail) {
  final pan = detail?['panNumber'] as String?;
  final vat = detail?['vatNumber'] as String?;
  if (pan != null && pan.isNotEmpty) return pan;
  if (vat != null && vat.isNotEmpty) return vat;
  return '-';
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
