import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class FamilyMembersScreen extends ConsumerWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;
    final members = user?.familyRequests ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Family Members'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 40.h),
        child: Column(
          children: [
            // Hero illustration + headline
            _HeroBanner(),
            SizedBox(height: 28.h),

            // Members list or empty prompt
            members.isEmpty
                ? _EmptyMembersCard(onAdd: () => _showAddSheet(context))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: context.vColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...members.map((m) => _MemberTile(member: m)),
                      SizedBox(height: 16.h),
                      _AddMemberButton(
                          onTap: () => _showAddSheet(context)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemberSheet(),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/family_members.svg',
          width: 180.w,
        ),
        SizedBox(height: 20.h),
        Text(
          'Start a family account\nfor free',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: context.vColors.onSurface,
            height: 1.3,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Get more from Vhandar by collaborating\nwith Friends and Family.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            color: context.vColors.onSurfaceMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _EmptyMembersCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMembersCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const _BenefitRow(
            icon: Icons.shopping_cart_outlined,
            text: 'Share a single cart & checkout together',
          ),
          SizedBox(height: 12.h),
          const _BenefitRow(
            icon: Icons.local_offer_outlined,
            text: 'Everyone gets exclusive family offers',
          ),
          SizedBox(height: 12.h),
          const _BenefitRow(
            icon: Icons.star_outline_rounded,
            text: 'Pool Vhandar Points across the family',
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_outlined, color: Colors.white),
              label: Text(
                'Add Family Member',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColor.primary, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: context.vColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final dynamic member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member is Map ? (member['name'] ?? 'Member') : 'Member';
    final phone = member is Map ? (member['phoneNumber'] ?? '') : '';
    final status = member is Map ? (member['status'] ?? 'pending') : 'pending';
    final isPending = status == 'pending';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColor.primary.withValues(alpha: 0.1),
            child: Text(
              (name as String).isNotEmpty ? name[0].toUpperCase() : 'M',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: context.vColors.onSurface,
                  ),
                ),
                if ((phone as String).isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                        fontSize: 11.sp, color: context.vColors.onSurfaceMuted),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.orange.shade50
                  : AppColor.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              isPending ? 'Pending' : 'Active',
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: isPending ? Colors.orange.shade700 : AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMemberButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColor.primary.withValues(alpha: 0.4), width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
          color: AppColor.primary.withValues(alpha: 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined,
                color: AppColor.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Add Another Member',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet();

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.vColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.vColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Add Family Member',
              style: TextStyle(
                fontSize: 17.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'They\'ll receive an invite to join your family account.',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: context.vColors.onSurfaceMuted,
                  fontFamily: 'Inter'),
            ),
            SizedBox(height: 20.h),
            _Field(
              controller: _nameController,
              label: 'Name',
              hint: 'e.g. Mom, Dad, Sister',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 12.h),
            _Field(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '98XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: wire up API invite
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Invite sent to ${_phoneController.text}'),
                      backgroundColor: AppColor.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Send Invite',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: context.vColors.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter', color: context.vColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(fontSize: 13.sp, color: context.vColors.onSurfaceMuted),
            prefixIcon:
                Icon(icon, color: AppColor.primary, size: 18.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.vColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.vColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
