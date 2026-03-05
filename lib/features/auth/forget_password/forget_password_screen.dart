import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO:: change to state
    TextEditingController phoneController = TextEditingController();
    return CustomScaffoldWrapper(
      appBar: const CustomAppBar(
        title: '',
      ),
      body: Column(children: [
        Text(
          'OTP Verification',
          style: KTextStyle.roboto24blackD7W,
        ),
        SizedBox(height: 8.h),
        Text('OTP has been sent to +9779851357358',
            style: KTextStyle.roboto14Green4W),
        SizedBox(height: 32.h),
        CustomTextField(
          controller: phoneController,
          hintText: 'Enter Mobile Number',
          labelText: 'Number',
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w),
            child: Text(
              '+ 977',
              style: KTextStyle.roboto16black5W,
            ),
          ),
          keyBoardType: const TextInputType.numberWithOptions(),
          textInputFormatter: TenDigitInputFormatter(),
          validator: TFValidators.validatePhone,
        ),
        SizedBox(height: 24.h),
        CustomButton(
            onPress: () {
              context.push(LVRoute.oTPScreen.route);
            },
            buttonTitle: 'Reset Password'),
      ]),
    );
  }
}
