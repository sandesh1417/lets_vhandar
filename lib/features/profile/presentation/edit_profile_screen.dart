import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/presentation/business_location_picker_screen.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/tff.dart';

const _kBusinessCategories = [
  'Restaurant',
  'Cafe',
  'Hotel',
  'Resort',
  'Hostel',
  'Canteen',
];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  String? _selectedGender;

  // Business fields
  late TextEditingController _businessNameController;
  late TextEditingController _panVatController;
  String? _selectedCategory;
  bool _isPan = true;
  LatLng? _businessLatLng;
  String? _businessLocationAddress;

  @override
  void initState() {
    super.initState();
    final user = ref.read(loginProvider).user;
    final bd = user?.businessDetail;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _birthDateController = TextEditingController(text: user?.birthDate ?? '');
    _selectedGender = user?.gender;

    _businessNameController =
        TextEditingController(text: bd?['businessName'] as String? ?? '');
    _selectedCategory = bd?['businessCategory'] as String?;

    final pan = bd?['panNumber'] as String?;
    final vat = bd?['vatNumber'] as String?;
    _isPan = pan != null && pan.isNotEmpty;
    _panVatController =
        TextEditingController(text: _isPan ? (pan ?? '') : (vat ?? ''));

    final lat = bd?['lat'] ?? bd?['latitude'];
    final lng = bd?['long'] ?? bd?['longitude'];
    if (lat != null && lng != null) {
      _businessLatLng =
          LatLng((lat as num).toDouble(), (lng as num).toDouble());
    }
    _businessLocationAddress =
        (bd?['locationAddress'] ?? bd?['addressName']) as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _businessNameController.dispose();
    _panVatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime? initial;
    try {
      if (_birthDateController.text.isNotEmpty) {
        initial = DateTime.parse(_birthDateController.text);
      }
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primary),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<BusinessLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessLocationPickerScreen(
          initialLatLng: _businessLatLng,
          initialAddress: _businessLocationAddress,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _businessLatLng = result.latLng;
        _businessLocationAddress = result.address;
      });
    }
  }

  void _showCategoryPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategoryPickerSheet(
        categories: _kBusinessCategories,
        selected: _selectedCategory,
        onSelected: (c) => setState(() => _selectedCategory = c),
      ),
    );
  }

  Future<void> _save(bool isBusiness) async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> payload;

    if (isBusiness) {
      final existingBd = ref.read(loginProvider).user?.businessDetail ?? {};
      final panVat = _panVatController.text.trim();
      payload = {
        'businessDetail': {
          ...existingBd,
          'businessName': _businessNameController.text.trim(),
          'businessCategory': _selectedCategory ?? '',
          if (_isPan) 'panNumber': panVat else 'panNumber': null,
          if (!_isPan) 'vatNumber': panVat else 'vatNumber': null,
          if (_businessLatLng != null) 'lat': _businessLatLng!.latitude,
          if (_businessLatLng != null) 'long': _businessLatLng!.longitude,
          if (_businessLocationAddress != null)
            'locationAddress': _businessLocationAddress,
          // clear old keys if they existed
          'latitude': null,
          'longitude': null,
        },
      };
    } else {
      final email = _emailController.text.trim();
      final birthDate = _birthDateController.text.trim();
      payload = {
        'name': _nameController.text.trim(),
        if (email.isNotEmpty) 'email': email else 'email': null,
        if (_selectedGender != null) 'gender': _selectedGender,
        if (birthDate.isNotEmpty) 'birthDate': birthDate else 'birthDate': null,
      };
    }

    final ok =
        await ref.read(loginProvider.notifier).updateProfile(context, payload);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final isBusiness = loginState.user?.isBusiness == true;
    final vc = context.vColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: CustomScreenHeader(
        title: isBusiness ? 'Edit Business Info' : 'Edit Profile',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            // Avatar header band
            _AvatarHeader(isBusiness: isBusiness),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBusiness) ...[
                      _buildBusinessForm(loginState, vc),
                    ] else ...[
                      _buildPersonalForm(vc),
                    ],
                    SizedBox(height: 32.h),
                    CustomButton(
                      buttonTitle:
                          loginState.isLoading ? 'Saving...' : 'Save Changes',
                      isLoading: loginState.isLoading,
                      isEnabled: !loginState.isLoading &&
                          (!isBusiness || _selectedCategory != null),
                      onPress: () => _save(isBusiness),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessForm(loginState, VhandarColors vc) {
    final phone = loginState.user?.phoneNumber ?? '';
    final phoneCode = loginState.user?.phoneCode ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormCard(
          vc: vc,
          sectionIcon: Icons.store_outlined,
          sectionTitle: 'Business Details',
          children: [
            // Read-only mobile
            _FieldLabel('Mobile Number', vc),
            SizedBox(height: 6.h),
            _ReadOnlyField(
              icon: Icons.phone_outlined,
              value: '$phoneCode $phone'.trim(),
              vc: vc,
            ),
            SizedBox(height: 16.h),

            _FieldLabel('Business Name', vc),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: _businessNameController,
              hintText: 'Enter business name',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),

            _FieldLabel('Category', vc),
            SizedBox(height: 6.h),
            _CategoryButton(
              selected: _selectedCategory,
              onTap: () => _showCategoryPicker(context),
              vc: vc,
            ),
            if (_selectedCategory == null) ...[
              SizedBox(height: 4.h),
              Text(
                'Please select a category',
                style: TextStyle(fontSize: 11.sp, color: Colors.red.shade400),
              ),
            ],
            SizedBox(height: 16.h),

            _FieldLabel('Business Location', vc),
            SizedBox(height: 6.h),
            _LocationButton(
              address: _businessLocationAddress,
              onTap: _pickLocation,
              vc: vc,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _FormCard(
          vc: vc,
          sectionIcon: Icons.badge_outlined,
          sectionTitle: 'Tax Information',
          children: [
            _FieldLabel('Tax Type', vc),
            SizedBox(height: 8.h),
            _PanVatToggle(
              isPan: _isPan,
              onChanged: (v) => setState(() => _isPan = v),
              vc: vc,
            ),
            SizedBox(height: 12.h),
            _FieldLabel(_isPan ? 'PAN Number' : 'VAT Number', vc),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: _panVatController,
              hintText: _isPan ? 'Enter PAN number' : 'Enter VAT number',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalForm(VhandarColors vc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormCard(
          vc: vc,
          sectionIcon: Icons.person_outline,
          sectionTitle: 'Personal Details',
          children: [
            _FieldLabel('Full Name', vc),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: _nameController,
              hintText: 'Enter your name',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _FieldLabel('Email Address', vc),
            SizedBox(height: 6.h),
            ValueListenableBuilder(
              valueListenable: _emailController,
              builder: (_, __, ___) => CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyBoardType: TextInputType.emailAddress,
                suffixIcon: _emailController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() => _emailController.clear()),
                        child: Icon(Icons.cancel_outlined,
                            size: 18.sp, color: Colors.grey.shade400),
                      )
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _FormCard(
          vc: vc,
          sectionIcon: Icons.cake_outlined,
          sectionTitle: 'Additional Info',
          children: [
            _FieldLabel('Date of Birth', vc),
            SizedBox(height: 6.h),
            ValueListenableBuilder(
              valueListenable: _birthDateController,
              builder: (_, __, ___) => CustomTextField(
                controller: _birthDateController,
                hintText: 'Select date of birth',
                isReadOnly: true,
                onTap: _pickDate,
                suffixIcon: _birthDateController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _birthDateController.clear()),
                        child: Icon(Icons.cancel_outlined,
                            size: 18.sp, color: Colors.grey.shade400),
                      )
                    : Icon(Icons.calendar_today_outlined,
                        size: 18.sp, color: AppColor.primary),
              ),
            ),
            SizedBox(height: 16.h),
            _FieldLabel('Gender', vc),
            SizedBox(height: 8.h),
            _GenderSelector(
              selected: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
              vc: vc,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Avatar header ────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final bool isBusiness;
  const _AvatarHeader({required this.isBusiness});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    // Avatar circle = 72.w image + 3.w padding on all sides = 78.w total.
    // Place avatar so its centre sits on the dividing line between the green
    // band and the white form area — no overflow, no clip needed.
    const double greenHeight = 80.0;
    final double avatarDiameter = 78.w;
    final double avatarTop = greenHeight.h - avatarDiameter / 2;
    final double totalHeight = greenHeight.h + avatarDiameter / 2 + 16.h;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Green band
          Container(
            height: greenHeight.h,
            width: double.infinity,
            color: AppColor.primary,
          ),
          // Avatar centred on the band boundary
          Positioned(
            top: avatarTop,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: vc.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      isBusiness
                          ? KImageConstant.businessProfile
                          : KImageConstant.userProfile,
                      width: 72.w,
                      height: 72.w,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: vc.surface, width: 1.5),
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 10.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form card container ──────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final VhandarColors vc;
  final IconData sectionIcon;
  final String sectionTitle;
  final List<Widget> children;

  const _FormCard({
    required this.vc,
    required this.sectionIcon,
    required this.sectionTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child:
                      Icon(sectionIcon, color: AppColor.primary, size: 16.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: vc.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: vc.divider),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final VhandarColors vc;
  const _FieldLabel(this.text, this.vc);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: vc.onSurfaceMuted,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Read-only field ───────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String value;
  final VhandarColors vc;

  const _ReadOnlyField(
      {required this.icon, required this.value, required this.vc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: vc.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: vc.onSurfaceMuted),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: vc.onSurfaceMuted,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 14.sp, color: vc.onSurfaceMuted),
        ],
      ),
    );
  }
}

// ── Category button ───────────────────────────────────────────────────────────

class _CategoryButton extends StatelessWidget {
  final String? selected;
  final VoidCallback onTap;
  final VhandarColors vc;

  const _CategoryButton(
      {required this.selected, required this.onTap, required this.vc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: selected != null
              ? AppColor.primary.withValues(alpha: 0.05)
              : vc.surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected != null
                ? AppColor.primary.withValues(alpha: 0.4)
                : vc.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant_outlined,
                size: 16.sp,
                color: selected != null ? AppColor.primary : vc.onSurfaceMuted),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                selected ?? 'Select category',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: selected != null ? vc.onSurface : vc.onSurfaceMuted,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20.sp, color: vc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

// ── Location button ───────────────────────────────────────────────────────────

class _LocationButton extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;
  final VhandarColors vc;

  const _LocationButton(
      {required this.address, required this.onTap, required this.vc});

  @override
  Widget build(BuildContext context) {
    final hasLocation = address != null && address!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: hasLocation
              ? AppColor.primary.withValues(alpha: 0.05)
              : vc.surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasLocation
                ? AppColor.primary.withValues(alpha: 0.4)
                : vc.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16.sp,
              color: hasLocation ? AppColor.primary : vc.onSurfaceMuted,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                hasLocation ? address! : 'Tap to pin on map',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasLocation ? vc.onSurface : vc.onSurfaceMuted,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.map_outlined, size: 16.sp, color: vc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

// ── Category picker bottom sheet ─────────────────────────────────────────────

class _CategoryPickerSheet extends StatefulWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CategoryPickerSheet({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late List<String> _filtered;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() => _filtered = q.isEmpty
          ? widget.categories
          : widget.categories
              .where((c) => c.toLowerCase().contains(q))
              .toList());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
            child: Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 18.sp, color: AppColor.primary),
                SizedBox(width: 8.w),
                Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: vc.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: widget.categories.length * 52.h > 320.h
                ? 320.h
                : widget.categories.length * 52.h + 16.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final cat = _filtered[i];
                final isSelected = cat == widget.selected;
                return InkWell(
                  onTap: () {
                    widget.onSelected(cat);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  isSelected ? AppColor.primary : vc.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: AppColor.primary, size: 18.sp),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAN / VAT toggle ────────────────────────────────────────────────────────

class _PanVatToggle extends StatelessWidget {
  final bool isPan;
  final ValueChanged<bool> onChanged;
  final VhandarColors vc;

  const _PanVatToggle(
      {required this.isPan, required this.onChanged, required this.vc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleChip(
          label: 'PAN',
          selected: isPan,
          onTap: () => onChanged(true),
          vc: vc,
        ),
        SizedBox(width: 10.w),
        _ToggleChip(
          label: 'VAT',
          selected: !isPan,
          onTap: () => onChanged(false),
          vc: vc,
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VhandarColors vc;

  const _ToggleChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.vc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.primary.withValues(alpha: 0.1)
              : vc.surfaceVariant,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColor.primary : vc.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: selected ? AppColor.primary : vc.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}

// ── Gender selector ───────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;
  final VhandarColors vc;

  const _GenderSelector(
      {required this.selected, required this.onChanged, required this.vc});

  @override
  Widget build(BuildContext context) {
    const options = ['Male', 'Female', 'Other'];
    return Row(
      children: options.map((g) {
        final isSelected = selected == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: g != options.last ? 8.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primary.withValues(alpha: 0.1)
                    : vc.surfaceVariant,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected ? AppColor.primary : vc.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                g,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: isSelected ? AppColor.primary : vc.onSurfaceMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
