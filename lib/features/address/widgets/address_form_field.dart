import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/widgets/tff.dart';

/// Reusable styled text field for the address form.
class AddressFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const AddressFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      keyBoardType: keyboardType,
      hintText: hint,
    );
  }
}
