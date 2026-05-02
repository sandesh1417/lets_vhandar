import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

import 'address_form_field.dart';
import 'address_type_chip.dart';

/// The scrollable form section: type chips, input fields, and save button.
class AddressForm extends StatelessWidget {
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
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter complete address',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textBlack,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
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
              color: AppColor.textBlack87,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              AddressTypeChip(
                label: 'Home',
                icon: Icons.home_rounded,
                selected: addressType == 'home',
                onTap: () => onAddressTypeChanged('home'),
              ),
              SizedBox(width: 8.w),
              AddressTypeChip(
                label: 'Office',
                icon: Icons.business_rounded,
                selected: addressType == 'office',
                onTap: () => onAddressTypeChanged('office'),
              ),
              SizedBox(width: 8.w),
              AddressTypeChip(
                label: 'Others',
                icon: Icons.location_on_rounded,
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
            style: TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
          ),
          SizedBox(height: 8.h),
          AddressFormField(controller: nameCtrl, hint: 'Receiver name'),
          SizedBox(height: 10.h),

          Text(
            'Receiver phone number',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppColor.textBlack87,
            ),
          ),
          SizedBox(height: 8.h),
          AddressFormField(
            controller: phoneCtrl,
            hint: 'Phone number',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20.h),

          // --- Save / Update button ---
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isEditing ? 'Update Address' : 'Save Address',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
