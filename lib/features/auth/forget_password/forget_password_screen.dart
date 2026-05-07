import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  late TextEditingController phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgetPasswordState = ref.watch(forgetPasswordProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      appBar: const CustomAppBar(
        title: '',
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.green),
          SizedBox(height: 20.h),
          Text(
            'Forgot Password',
            style: KTextStyle.roboto24blackD7W,
          ),
          SizedBox(height: 8.h),
          Text('Enter your phone number and we\'ll send a reset code.',
              textAlign: TextAlign.center, style: KTextStyle.roboto14Green4W),
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
              isLoading: forgetPasswordState.isLoading,
              onPress: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ref.read(forgetPasswordProvider.notifier).sendOtp(
                    context,
                    phoneNumber: phoneController.text,
                    phoneCode: "+977",
                    onSuccess: () {
                      context.push(
                        LVRoute.oTPScreen.route,
                        extra: {
                          'phoneNumber': phoneController.text,
                          'phoneCode': '+977',
                          'isResetPassword': true,
                        },
                      );
                    },
                  );
                }
              },
              buttonTitle: 'Send Reset Code'),
        ]),
      ),
    );
  }
}
