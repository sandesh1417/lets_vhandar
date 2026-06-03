import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/profile/providers/family_members_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() =>
      _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(familyMembersProvider.notifier).loadData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyMembersProvider);
    final members = state.members;
    final pending = state.pendingRequests;
    final hasAny = members.isNotEmpty || pending.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Family Members'),
      body: state.isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasAny) ...[
                    _HeroBanner(),
                    SizedBox(height: 24.h),
                    _EmptyBenefitsCard(
                        onAdd: () => _showAddSheet(context)),
                  ] else ...[
                    _CompactHero(),
                    SizedBox(height: 20.h),
                    if (pending.isNotEmpty) ...[
                      _SectionLabel(
                          label: 'Requests', badge: pending.length),
                      SizedBox(height: 8.h),
                      ...pending.map((r) => _ReceivedRequestTile(
                            request: r,
                            onAccept: () =>
                                _showAcceptSheet(context, r['_id'] ?? ''),
                            onReject: () => ref
                                .read(familyMembersProvider.notifier)
                                .removeMember(context, r['_id'] ?? ''),
                          )),
                      SizedBox(height: 16.h),
                    ],
                    if (members.isNotEmpty) ...[
                      const _SectionLabel(label: 'Members'),
                      SizedBox(height: 8.h),
                      ...members.map((r) => _MemberTile(
                            request: r,
                            onRemove: () => ref
                                .read(familyMembersProvider.notifier)
                                .removeMember(context, r['_id'] ?? ''),
                          )),
                      SizedBox(height: 16.h),
                    ],
                    _AddMemberButton(
                        onTap: () => _showAddSheet(context)),
                  ],
                ],
              ),
            ),
    );
  }

  void _showAddSheet(BuildContext context) {
    ref.read(familyMembersProvider.notifier).resetSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemberSheet(),
    );
  }

  void _showAcceptSheet(BuildContext context, String requestId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AcceptRequestSheet(requestId: requestId),
    );
  }
}

// ─── Hero Widgets ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/icons/family_members.svg', width: 160.w),
        SizedBox(height: 18.h),
        Text(
          'Start a family account\nfor free',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: context.vColors.onSurface,
            height: 1.3,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Get more from Vhandar by collaborating\nwith friends and family.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Inter',
            color: context.vColors.onSurfaceMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _CompactHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/family_members.svg',
          width: 52.w,
          height: 52.w,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Family Account',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: context.vColors.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Collaborate with friends and family on Vhandar.',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Inter',
                  color: context.vColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyBenefitsCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBenefitsCard({required this.onAdd});

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
              icon:
                  const Icon(Icons.person_add_outlined, color: Colors.white),
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

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int? badge;
  const _SectionLabel({required this.label, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: context.vColors.onSurface,
          ),
        ),
        if (badge != null && badge! > 0) ...[
          SizedBox(width: 6.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$badge',
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Received Request Tile ────────────────────────────────────────────────────

class _ReceivedRequestTile extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ReceivedRequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final member = _memberData(request);
    final name = member['name'] ?? 'Member';
    final phone = member['phone'] ?? '';
    final relation = (request['relation'] as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.orange.shade50,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade700,
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
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.vColors.onSurfaceMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (relation.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    relation,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: context.vColors.inputBorder),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Member Tile ──────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onRemove;

  const _MemberTile({required this.request, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final member = _memberData(request);
    final name = member['name'] ?? 'Member';
    final phone = member['phone'] ?? '';
    final relation = (request['relation'] as String?) ?? '';
    final accepted = request['requestAccepted'] == true;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

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
              initial,
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
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (relation.isNotEmpty)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: accepted
                    ? AppColor.primary.withValues(alpha: 0.08)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                relation,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: accepted
                      ? AppColor.primary
                      : Colors.orange.shade700,
                ),
              ),
            ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _showRemoveSheet(context),
            child: Icon(
              Icons.more_vert_rounded,
              size: 18.sp,
              color: context.vColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveSheet(BuildContext context) {
    final member = _memberData(request);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _RemoveConfirmSheet(
        name: member['name'] ?? 'Member',
        onConfirm: onRemove,
      ),
    );
  }
}

// ─── Helper: extract name/phone from memberId (populated or plain) ──────────

Map<String, String> _memberData(Map<String, dynamic> request) {
  final memberId = request['memberId'];
  if (memberId is Map<String, dynamic>) {
    return {
      'name': (memberId['name'] as String?) ?? '',
      'phone': (memberId['phoneNumber'] as String?) ?? '',
    };
  }
  // fallback if memberId is just an ID string
  return {'name': '', 'phone': ''};
}

// ─── Remove Confirm Sheet ─────────────────────────────────────────────────────

class _RemoveConfirmSheet extends StatelessWidget {
  final String name;
  final VoidCallback onConfirm;
  const _RemoveConfirmSheet({required this.name, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_remove_outlined,
                color: Colors.red.shade400, size: 26.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            name.isNotEmpty ? 'Remove $name?' : 'Remove member?',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'They will no longer have access to your family account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Inter',
              color: vc.onSurfaceMuted,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: vc.inputBorder),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: vc.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Accept Request Sheet (relation picker) ───────────────────────────────────

class _AcceptRequestSheet extends ConsumerStatefulWidget {
  final String requestId;
  const _AcceptRequestSheet({required this.requestId});

  @override
  ConsumerState<_AcceptRequestSheet> createState() =>
      _AcceptRequestSheetState();
}

class _AcceptRequestSheetState extends ConsumerState<_AcceptRequestSheet> {
  String _relation = 'Others';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isActioning =
        ref.watch(familyMembersProvider).isActioning;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(
            20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            SizedBox(height: 16.h),
            Text(
              'Accept Request',
              style: TextStyle(
                fontSize: 17.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Choose your relation with this person.',
              style: TextStyle(
                fontSize: 12.sp,
                color: vc.onSurfaceMuted,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 16.h),
            _RelationPicker(
              selected: _relation,
              onChanged: (r) => setState(() => _relation = r),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActioning
                    ? null
                    : () async {
                        await ref
                            .read(familyMembersProvider.notifier)
                            .acceptRequest(
                                context, widget.requestId, _relation);
                        if (context.mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isActioning
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Accept',
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

// ─── Add Member Button ────────────────────────────────────────────────────────

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
            color: AppColor.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
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
              'Add Family Member',
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

// ─── Add Member Sheet ─────────────────────────────────────────────────────────

class _AddMemberSheet extends ConsumerStatefulWidget {
  const _AddMemberSheet();

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final state = ref.watch(familyMembersProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            SizedBox(height: 16.h),
            Text(
              'Add Family Member',
              style: TextStyle(
                fontSize: 17.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Search by phone to find the member, then choose your relation.',
              style: TextStyle(
                fontSize: 12.sp,
                color: vc.onSurfaceMuted,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),

            // ── Phone + Search button ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _PhoneField(controller: _phoneController)),
                SizedBox(width: 10.w),
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: state.isSearching
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            ref
                                .read(familyMembersProvider.notifier)
                                .searchByPhone(_phoneController.text);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      disabledBackgroundColor:
                          AppColor.primary.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: state.isSearching
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            // ── Search error ───────────────────────────────────────────────
            if (state.searchError != null) ...[
              SizedBox(height: 10.h),
              _SearchErrorCard(message: state.searchError!),
            ],

            // ── Found user + relation picker ───────────────────────────────
            if (state.foundUser != null) ...[
              SizedBox(height: 12.h),
              _FoundUserCard(user: state.foundUser!),
              SizedBox(height: 16.h),
              Text(
                'Your relation',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: vc.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              _RelationPicker(
                selected: state.selectedRelation,
                onChanged: (r) =>
                    ref.read(familyMembersProvider.notifier).setRelation(r),
              ),
            ],

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (state.foundUser == null || state.isSending)
                    ? null
                    : () async {
                        final sent = await ref
                            .read(familyMembersProvider.notifier)
                            .sendRequest(context);
                        if (sent && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  disabledBackgroundColor:
                      AppColor.primary.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: state.isSending
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        state.foundUser != null
                            ? 'Send Invite to ${(state.foundUser!['name'] as String?) ?? 'Member'}'
                            : 'Search first',
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

// ─── Relation Picker ──────────────────────────────────────────────────────────

class _RelationPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _RelationPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: kFamilyRelations.map((rel) {
        final isSelected = selected == rel;
        return GestureDetector(
          onTap: () => onChanged(rel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primary
                  : AppColor.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? AppColor.primary
                    : AppColor.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              rel,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColor.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Phone Field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style:
          TextStyle(fontSize: 14.sp, fontFamily: 'Inter', color: vc.onSurface),
      decoration: InputDecoration(
        hintText: '98XXXXXXXX',
        hintStyle: TextStyle(fontSize: 13.sp, color: vc.onSurfaceMuted),
        prefixIcon:
            Icon(Icons.phone_outlined, color: AppColor.primary, size: 18.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: vc.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: vc.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      ),
    );
  }
}

// ─── Search Error Card ────────────────────────────────────────────────────────

class _SearchErrorCard extends StatelessWidget {
  final String message;
  const _SearchErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: Colors.red.shade400, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Inter',
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Found User Card ──────────────────────────────────────────────────────────

class _FoundUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _FoundUserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = (user['name'] as String?) ?? 'Member';
    final phone = (user['phoneNumber'] as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColor.primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 14.sp,
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
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColor.primary, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  'Found',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Sheet Handle ─────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: context.vColors.divider,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
