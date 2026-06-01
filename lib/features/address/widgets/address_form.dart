import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

import 'address_form_field.dart';
import 'address_type_chip.dart';

/// The scrollable form section: type chips, input fields, and save button.
class AddressForm extends StatelessWidget {
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
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter complete address',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: context.vColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Help us find your location precisely',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.vColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.vColors.onSurfaceMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // --- Address type selector ---
            Text(
              'Save address as *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                AddressTypeChip(
                  label: 'Home',
                  svgAsset: 'assets/icons/address_home.svg',
                  selected: addressType == 'home',
                  onTap: () => onAddressTypeChanged('home'),
                ),
                SizedBox(width: 8.w),
                AddressTypeChip(
                  label: 'Office',
                  svgAsset: 'assets/icons/address_office.svg',
                  selected: addressType == 'office',
                  onTap: () => onAddressTypeChanged('office'),
                ),
                SizedBox(width: 8.w),
                AddressTypeChip(
                  label: 'Others',
                  svgAsset: 'assets/icons/address_other.svg',
                  selected: addressType == 'others',
                  onTap: () => onAddressTypeChanged('others'),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // --- Input fields ---
            AddressFormField(controller: houseCtrl, hint: 'House / Flat no.'),
            SizedBox(height: 10.h),
            AddressFormField(controller: floorCtrl, hint: 'Floor (optional)'),
            SizedBox(height: 10.h),
            AddressFormField(controller: localityCtrl, hint: 'Area / Locality'),
            SizedBox(height: 10.h),
            AddressFormField(controller: landMarkCtrl, hint: 'Landmark'),
            SizedBox(height: 14.h),

            Text(
              'Receiver name for seamless delivery experience.',
              style: TextStyle(fontSize: 12.sp, color: context.vColors.onSurfaceMuted),
            ),
            SizedBox(height: 8.h),
            AddressFormField(
              controller: nameCtrl,
              hint: 'Receiver name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Receiver name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 10.h),

            Text(
              'Receiver phone number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            AddressFormField(
              controller: phoneCtrl,
              hint: 'Phone number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                final cleanVal = value.trim();
                if (!RegExp(r'^\d+$').hasMatch(cleanVal)) {
                  return 'Enter a valid phone number (digits only)';
                }
                if (cleanVal.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // --- Save / Update button ---
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.secondary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Update Address' : 'Save Address',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
