import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinputExample extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final Function(String) onCompleted;
  final String? Function(String?)? validator;

  const PinputExample({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.formKey,
    required this.onCompleted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          length: 5,
          controller: controller,
          focusNode: focusNode,
          defaultPinTheme: defaultPinTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          validator: validator,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: onCompleted,
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                width: 22,
                height: 1,
                color: focusedBorderColor,
              ),
            ],
          ),
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: focusedBorderColor),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              color: fillColor,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: focusedBorderColor),
            ),
          ),
          errorPinTheme: defaultPinTheme.copyBorderWith(
            border: Border.all(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
