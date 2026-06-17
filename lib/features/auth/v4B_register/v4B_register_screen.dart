// ignore: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/features/profile/presentation/business_location_picker_screen.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/tff.dart';
import 'package:pinput/pinput.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

const _kBusinessCategories = <({String name, IconData icon})>[
  (name: 'Restaurant', icon: Icons.restaurant_outlined),
  (name: 'Cafe', icon: Icons.local_cafe_outlined),
  (name: 'Hotel', icon: Icons.hotel_outlined),
  (name: 'Resort', icon: Icons.beach_access_outlined),
  (name: 'Hostel', icon: Icons.bed_outlined),
  (name: 'Canteen', icon: Icons.lunch_dining_outlined),
];

class V4BRegistrationScreen extends ConsumerStatefulWidget {
  const V4BRegistrationScreen({super.key});

  @override
  V4BRegistrationScreenState createState() => V4BRegistrationScreenState();
}

class V4BRegistrationScreenState extends ConsumerState<V4BRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();

  // State
  bool _showPassword = false;
  bool _showConfirm = false;
  String? _selectedCategory;
  bool _showCategoryError = false;
  bool _isPan = true;
  LatLng? _locationLatLng;
  String? _locationAddress;
  bool _showLocationError = false;

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _businessNameCtrl.dispose();
    _taxNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<BusinessLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessLocationPickerScreen(
          initialLatLng: _locationLatLng,
          initialAddress: _locationAddress,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _locationLatLng = result.latLng;
        _locationAddress = result.address;
        _showLocationError = false;
      });
    }
  }

  void _showCategoryPicker() {
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(
        selected: _selectedCategory,
        onSelected: (c) => setState(() {
          _selectedCategory = c;
          _showCategoryError = false;
        }),
      ),
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    if (_selectedCategory == null) setState(() => _showCategoryError = true);
    if (_locationAddress == null) setState(() => _showLocationError = true);
    if (!formValid || _selectedCategory == null || _locationAddress == null) {
      return;
    }

    // Send OTP via the business endpoint (?isBusiness=true)
    await ref.read(registrationProvider.notifier).sendOtpForBusiness(
          context,
          phoneNumber: _phoneCtrl.text.trim(),
          phoneCode: '+977',
          onSuccess: () => _showOtpSheet(),
        );
  }

  void _showOtpSheet() {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _OtpSheet(
        phoneNumber: _phoneCtrl.text.trim(),
        onVerify: (otp) => _registerBusiness(otp),
        onResend: () {
          ref.read(registrationProvider.notifier).sendOtpForBusiness(
                context,
                phoneNumber: _phoneCtrl.text.trim(),
                phoneCode: '+977',
              );
        },
      ),
    );
  }

  Future<void> _registerBusiness(String otp) async {
    await ref.read(registrationProvider.notifier).registerBusinessWithOtp(
      context,
      otp: otp,
      phoneNumber: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      confirmPassword: _confirmPassCtrl.text.trim(),
      businessName: _businessNameCtrl.text.trim(),
      businessCategory: _selectedCategory!,
      panNumber: _isPan ? _taxNumberCtrl.text.trim() : '',
      vatNumber: _isPan ? '' : _taxNumberCtrl.text.trim(),
      phoneCode: '+977',
      lat: _locationLatLng?.latitude,
      long: _locationLatLng?.longitude,
      address: _locationAddress,
      onSuccess: () {
        if (mounted) {
          Navigator.of(context).pop(); // close OTP sheet
          context.go(LVRoute.loginScreen.route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registrationProvider).isLoading;
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Vhandar For Business',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Green hero header ───────────────────────────────────────
              Container(
                width: double.infinity,
                color: AppColor.primary,
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 36.h),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/V4B_logo.svg',
                      height: 44.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Create Business Account',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // ── Light form area (rises over the green hero) ─────────────
              Transform.translate(
                offset: Offset(0, -20.h),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: vc.scaffoldBg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Contact & Security ──────────────────────────────────────
                      _SectionCard(
                        vc: vc,
                        icon: Icons.lock_outline,
                        title: 'Contact & Security',
                        children: [
                          _Label('Mobile Number', vc),
                          SizedBox(height: 6.h),
                          CustomTextField(
                            controller: _phoneCtrl,
                            hintText: 'Enter 10-digit mobile number',
                            keyBoardType: TextInputType.number,
                            textInputFormatter: TenDigitInputFormatter(),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 13.h),
                              child: Text(
                                '+977',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: vc.onSurface,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            validator: TFValidators.validatePhone,
                          ),
                          SizedBox(height: 14.h),
                          _Label('Email Address', vc),
                          SizedBox(height: 6.h),
                          CustomTextField(
                            controller: _emailCtrl,
                            hintText: 'Enter business email',
                            keyBoardType: TextInputType.emailAddress,
                            prefixIcon: _PrefixIcon(Icons.email_outlined, vc),
                            validator: TFValidators.validateEmail,
                            suffixIcon: const SizedBox.shrink(),
                          ),
                          SizedBox(height: 14.h),
                          _Label('Password', vc),
                          SizedBox(height: 6.h),
                          CustomTextField(
                            controller: _passwordCtrl,
                            hintText: 'Create a password',
                            obscureText: !_showPassword,
                            prefixIcon: _PrefixIcon(Icons.key_outlined, vc),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _showPassword = !_showPassword),
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18.sp,
                                color: vc.onSurfaceMuted,
                              ),
                            ),
                            validator: TFValidators.validatePassword,
                          ),
                          SizedBox(height: 14.h),
                          _Label('Confirm Password', vc),
                          SizedBox(height: 6.h),
                          CustomTextField(
                            controller: _confirmPassCtrl,
                            hintText: 'Repeat your password',
                            obscureText: !_showConfirm,
                            prefixIcon: _PrefixIcon(Icons.key_outlined, vc),
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _showConfirm = !_showConfirm),
                              child: Icon(
                                _showConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18.sp,
                                color: vc.onSurfaceMuted,
                              ),
                            ),
                            validator: (v) =>
                                TFValidators.validateConfirmPassword(
                                    v, _passwordCtrl.text),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ── Business Details ────────────────────────────────────────
                      _SectionCard(
                        vc: vc,
                        icon: Icons.store_outlined,
                        title: 'Business Details',
                        children: [
                          _Label('Business Name', vc),
                          SizedBox(height: 6.h),
                          CustomTextField(
                            controller: _businessNameCtrl,
                            hintText: 'Enter your business name',
                            prefixIcon:
                                _PrefixIcon(Icons.storefront_outlined, vc),
                            suffixIcon: const SizedBox.shrink(),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                          SizedBox(height: 14.h),
                          _Label('Category', vc),
                          SizedBox(height: 6.h),
                          _TapField(
                            icon: Icons.category_outlined,
                            text:
                                _selectedCategory ?? 'Select business category',
                            hasValue: _selectedCategory != null,
                            hasError: _showCategoryError,
                            trailingIcon: Icons.keyboard_arrow_down_rounded,
                            onTap: _showCategoryPicker,
                            vc: vc,
                          ),
                          if (_showCategoryError) ...[
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Text(
                                'Please select a business category',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context).colorScheme.error,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 14.h),
                          _Label('Tax Type', vc),
                          SizedBox(height: 8.h),
                          _PanVatToggle(
                            isPan: _isPan,
                            onChanged: (v) => setState(() {
                              _isPan = v;
                              _taxNumberCtrl.clear();
                            }),
                            vc: vc,
                          ),
                          SizedBox(height: 10.h),
                          CustomTextField(
                            controller: _taxNumberCtrl,
                            hintText: _isPan
                                ? 'Enter PAN number'
                                : 'Enter VAT number',
                            prefixIcon: _PrefixIcon(Icons.badge_outlined, vc),
                            suffixIcon: const SizedBox.shrink(),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ── Business Location ───────────────────────────────────────
                      _SectionCard(
                        vc: vc,
                        icon: Icons.location_on_outlined,
                        title: 'Business Location',
                        children: [
                          _Label('Pin Location on Map', vc),
                          SizedBox(height: 6.h),
                          _TapField(
                            icon: Icons.map_outlined,
                            text: _locationAddress ?? 'Tap to select on map',
                            hasValue: _locationAddress != null,
                            hasError: _showLocationError,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: _pickLocation,
                            vc: vc,
                            maxLines: 2,
                          ),
                          if (_showLocationError) ...[
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Text(
                                'Please pin your business location on the map',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context).colorScheme.error,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                          if (_locationLatLng != null) ...[
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.my_location,
                                    size: 12.sp, color: AppColor.primary),
                                SizedBox(width: 4.w),
                                Text(
                                  '${_locationLatLng!.latitude.toStringAsFixed(4)}, ${_locationLatLng!.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: vc.onSurfaceMuted,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 32.h),

                      CustomButton(
                        buttonTitle: 'Register',
                        isLoading: isLoading,
                        isEnabled: !isLoading,
                        onPress: _submit,
                      ),
                      SizedBox(height: 16.h),

                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'By registering, you agree to our ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: vc.onSurfaceMuted,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _openUrl(
                                      'https://www.vhandar.com/privacy-policy'),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Text(
                                  ' & ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: vc.onSurfaceMuted,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _openUrl(
                                      'https://www.vhandar.com/terms-of-service'),
                                  child: Text(
                                    'Terms of Use',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final VhandarColors vc;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.vc,
    required this.icon,
    required this.title,
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
                  child: Icon(icon, color: AppColor.primary, size: 16.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
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
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
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

class _Label extends StatelessWidget {
  final String text;
  final VhandarColors vc;
  const _Label(this.text, this.vc);

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

// ── Prefix icon helper ────────────────────────────────────────────────────────

class _PrefixIcon extends StatelessWidget {
  final IconData icon;
  final VhandarColors vc;
  const _PrefixIcon(this.icon, this.vc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Icon(icon, size: 18.sp, color: vc.onSurfaceMuted),
    );
  }
}

// ── Tappable field ────────────────────────────────────────────────────────────

class _TapField extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasValue;
  final bool hasError;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final VhandarColors vc;
  final int maxLines;

  const _TapField({
    required this.icon,
    required this.text,
    required this.hasValue,
    required this.trailingIcon,
    required this.onTap,
    required this.vc,
    this.hasError = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final borderColor = hasError
        ? errorColor
        : hasValue
            ? AppColor.primary.withValues(alpha: 0.4)
            : vc.divider;
    final bgColor = hasError
        ? errorColor.withValues(alpha: 0.04)
        : hasValue
            ? AppColor.primary.withValues(alpha: 0.05)
            : vc.surfaceVariant;
    final iconColor = hasError
        ? errorColor
        : hasValue
            ? AppColor.primary
            : vc.onSurfaceMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: iconColor),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: hasValue ? vc.onSurface : vc.onSurfaceMuted,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(trailingIcon, size: 18.sp, color: vc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

// ── PAN / VAT toggle ──────────────────────────────────────────────────────────

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
        _Chip(
            label: 'PAN',
            selected: isPan,
            onTap: () => onChanged(true),
            vc: vc),
        SizedBox(width: 10.w),
        _Chip(
            label: 'VAT',
            selected: !isPan,
            onTap: () => onChanged(false),
            vc: vc),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VhandarColors vc;

  const _Chip(
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

// ── Category picker sheet ─────────────────────────────────────────────────────

class _CategorySheet extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CategorySheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: vc.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 4.h),

          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.category_outlined,
                      size: 18.sp, color: AppColor.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Category',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: vc.onSurface,
                        ),
                      ),
                      Text(
                        'What type of business do you run?',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: vc.onSurfaceMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: vc.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16.sp, color: vc.onSurfaceMuted),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: vc.divider),
          SizedBox(height: 8.h),

          // ── Category list ───────────────────────────────────────────
          ...(_kBusinessCategories.map((entry) {
            final isSelected = entry.name == selected;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  onSelected(entry.name);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primary.withValues(alpha: 0.25)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary.withValues(alpha: 0.12)
                              : vc.surfaceVariant,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          entry.icon,
                          size: 18.sp,
                          color:
                              isSelected ? AppColor.primary : vc.onSurfaceMuted,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          entry.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Inter',
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColor.primary : vc.onSurface,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                key: const ValueKey('check'),
                                color: AppColor.primary,
                                size: 20.sp)
                            : Icon(Icons.radio_button_unchecked_rounded,
                                key: const ValueKey('empty'),
                                color: vc.divider,
                                size: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })),

          SizedBox(height: 12.h + bottomPad),
        ],
      ),
    );
  }
}

// ── OTP bottom sheet ──────────────────────────────────────────────────────────

class _OtpSheet extends ConsumerStatefulWidget {
  final String phoneNumber;
  final Future<void> Function(String otp) onVerify;
  final VoidCallback onResend;

  const _OtpSheet({
    required this.phoneNumber,
    required this.onVerify,
    required this.onResend,
  });

  @override
  ConsumerState<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends ConsumerState<_OtpSheet> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int _seconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_seconds > 0) {
        setState(() => _seconds--);
        _startTimer();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registrationProvider).isLoading;
    final vc = context.vColors;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
            24.w, 20.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sms_outlined,
                  size: 28.sp, color: AppColor.primary),
            ),
            SizedBox(height: 14.h),
            Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Code sent to +977 ${widget.phoneNumber}',
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurfaceMuted,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 24.h),
            Form(
              key: _formKey,
              child: Pinput(
                length: 5,
                controller: _otpCtrl,
                focusNode: _focusNode,
                autofocus: true,
                defaultPinTheme: PinTheme(
                  width: 52.w,
                  height: 52.w,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.35)),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 52.w,
                  height: 52.w,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.primary, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_otpCtrl.text.length < 5) {
                          CustomSnackbar.error(context,
                              message: 'Please enter the 5-digit OTP');
                          return;
                        }
                        await widget.onVerify(_otpCtrl.text);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColor.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
              ),
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: _canResend
                  ? () {
                      setState(() {
                        _seconds = 30;
                        _canResend = false;
                        _otpCtrl.clear();
                      });
                      _startTimer();
                      widget.onResend();
                    }
                  : null,
              child: RichText(
                text: TextSpan(
                  text: "Didn't receive it? ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: vc.onSurfaceMuted,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text:
                          _canResend ? 'Resend OTP' : 'Resend in ${_seconds}s',
                      style: TextStyle(
                        color:
                            _canResend ? AppColor.primary : vc.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
