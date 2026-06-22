import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class AddressForm extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final String addressType;
  final ValueChanged<String> onAddressTypeChanged;
  final TextEditingController houseCtrl;
  final TextEditingController floorCtrl;
  final TextEditingController localityCtrl;
  final TextEditingController landMarkCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final bool isEditing;
  final bool submitted;
  final VoidCallback onSave;

  const AddressForm({
    super.key,
    required this.formKey,
    required this.scrollController,
    required this.addressType,
    required this.onAddressTypeChanged,
    required this.houseCtrl,
    required this.floorCtrl,
    required this.localityCtrl,
    required this.landMarkCtrl,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.isEditing,
    required this.submitted,
    required this.onSave,
  });

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  bool _iAmReceiver = false;

  void _toggleReceiver(bool value) {
    final user = ref.read(loginProvider).user;
    setState(() {
      _iAmReceiver = value;
      if (value) {
        widget.nameCtrl.text = user?.name ?? '';
        widget.phoneCtrl.text = user?.phoneNumber ?? '';
      } else {
        widget.nameCtrl.clear();
        widget.phoneCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final fieldFill = vc.surface;

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SAVE AS ───────────────────────────────────────────────────────
            Text(
              'SAVE AS',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: vc.onSurfaceMuted,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _TypeChip(
                  label: 'Home',
                  svgAsset: 'assets/icons/address_home.svg',
                  selected: widget.addressType == 'home',
                  onTap: () => widget.onAddressTypeChanged('home'),
                ),
                SizedBox(width: 10.w),
                _TypeChip(
                  label: 'Office',
                  svgAsset: 'assets/icons/address_office.svg',
                  selected: widget.addressType == 'office',
                  onTap: () => widget.onAddressTypeChanged('office'),
                ),
                SizedBox(width: 10.w),
                _TypeChip(
                  label: 'Others',
                  svgAsset: 'assets/icons/address_other.svg',
                  selected: widget.addressType == 'others',
                  onTap: () => widget.onAddressTypeChanged('others'),
                ),
              ],
            ),
            SizedBox(height: 22.h),

            // ── Address fields ────────────────────────────────────────────────
            const _FieldLabel('House / Flat / Building no.'),
            SizedBox(height: 6.h),
            _InputField(
              controller: widget.houseCtrl,
              hint: 'e.g. 4B, Green Towers',
              fill: fieldFill,
            ),
            SizedBox(height: 14.h),

            const _FieldLabel('Floor (optional)'),
            SizedBox(height: 6.h),
            _InputField(
              controller: widget.floorCtrl,
              hint: 'e.g. 3rd Floor',
              fill: fieldFill,
            ),
            SizedBox(height: 14.h),

            const _FieldLabel('Area / Sector / Locality *'),
            SizedBox(height: 6.h),
            _InputField(
              controller: widget.localityCtrl,
              hint: 'e.g. Thamel, Kathmandu',
              fill: fieldFill,
              validator: AppValidators.required,
            ),
            SizedBox(height: 14.h),

            const _FieldLabel('Nearby landmark (optional)'),
            SizedBox(height: 6.h),
            _InputField(
              controller: widget.landMarkCtrl,
              hint: 'e.g. Near City Centre Mall',
              fill: fieldFill,
            ),
            SizedBox(height: 24.h),

            // ── Receiver section ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receiver details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: vc.onSurface,
                        ),
                      ),
                      Text(
                        'Who will receive this order?',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: vc.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // "I am the receiver" toggle
                GestureDetector(
                  onTap: () => _toggleReceiver(!_iAmReceiver),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _iAmReceiver
                          ? AppColor.primary.withValues(alpha: 0.1)
                          : vc.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: _iAmReceiver ? AppColor.primary : vc.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iAmReceiver
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 14.sp,
                          color: _iAmReceiver
                              ? AppColor.primary
                              : vc.onSurfaceMuted,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'It\'s me',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _iAmReceiver
                                ? AppColor.primary
                                : vc.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Auto-filled info card or editable fields
            if (_iAmReceiver)
              _ReceiverInfoCard(
                name: widget.nameCtrl.text,
                phone: widget.phoneCtrl.text,
                onClear: () => _toggleReceiver(false),
              )
            else ...[
              const _FieldLabel('Receiver name *'),
              SizedBox(height: 6.h),
              _InputField(
                controller: widget.nameCtrl,
                hint: 'Full name',
                fill: fieldFill,
                validator: AppValidators.required,
              ),
              SizedBox(height: 14.h),
              const _FieldLabel('Receiver phone *'),
              SizedBox(height: 6.h),
              _InputField(
                controller: widget.phoneCtrl,
                hint: '+977 9XXXXXXXXX',
                fill: fieldFill,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: AppValidators.validatePhone,
              ),
            ],
            SizedBox(height: 32.h),

            // ── Save button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: CustomElevatedButton(
                onPressed: widget.onSave,
                isLoading: widget.isSaving,
                loaderSize: 22,
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                text: widget.isEditing ? 'Update Address' : 'Save Address',
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ── Type chip ─────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final String svgAsset;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.svgAsset,
    required this.selected,
    required this.onTap,
  });

  static const _selectedBorder = Color(0xFFFFB300);
  static const _selectedBg = Color(0xFFFFF8E1);
  static const _selectedText = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? _selectedBg
                : (context.isDark ? vc.surfaceVariant : Colors.white),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(
              color: selected ? _selectedBorder : vc.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgAsset,
                width: 20.w,
                height: 20.w,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _selectedText : vc.onSurface,
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

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: context.vColors.onSurface,
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color fill;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.fill,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final radius = BorderRadius.circular(12.r);
    final defaultBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: vc.inputBorder, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColor.primary, width: 1.5),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColor.error, width: 1),
    );
    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColor.error, width: 1.5),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: vc.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: vc.onSurfaceMuted,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: fill,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        errorStyle: TextStyle(
          fontSize: 11.sp,
          color: AppColor.error,
        ),
      ),
    );
  }
}

// ── Receiver info card (shown when "It's me" is toggled) ─────────────────────

class _ReceiverInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onClear;

  const _ReceiverInfoCard({
    required this.name,
    required this.phone,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded,
                color: AppColor.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'No name on profile',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                  ),
                ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded,
                size: 18.sp, color: vc.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
