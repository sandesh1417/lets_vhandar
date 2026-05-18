import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otp;
  final String? phoneCode;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
    this.phoneCode,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgetPasswordState = ref.watch(forgetPasswordProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      appBar: const CustomScreenHeader(title: ''),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.1),
              ),
              child:
                  const Icon(Icons.lock_reset, size: 50, color: Colors.green),
            ),
            SizedBox(height: 24.h),
            Text('Set New Password', style: KTextStyle.roboto24blackD7W),
            SizedBox(height: 8.h),
            Text('Create a new password for your account.',
                style: KTextStyle.roboto14Gray4W),
            SizedBox(height: 32.h),
            CustomTextField(
              controller: passwordController,
              hintText: 'Enter New Password',
              labelText: 'New Password',
              obscureText: !_isPasswordVisible,
              onObscurePressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              validator: TFValidators.validatePassword,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm New Password',
              labelText: 'Confirm New Password',
              obscureText: !_isPasswordVisible,
              onObscurePressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              validator: (value) => TFValidators.validateConfirmPassword(
                  value, passwordController.text),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              isLoading: forgetPasswordState.isLoading,
              onPress: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    CustomSnackbar.error(context,
                        message: 'Passwords do not match');
                    return;
                  }

                  ref.read(forgetPasswordProvider.notifier).resetPassword(
                    context,
                    phoneNumber: widget.phoneNumber,
                    phoneCode: widget.phoneCode,
                    otp: widget.otp,
                    password: passwordController.text,
                    confirmPassword: confirmPasswordController.text,
                    onSuccess: () {
                      context.go(LVRoute.loginScreen.route);
                    },
                  );
                }
              },
              buttonTitle: 'Update Password',
            ),
          ],
        ),
      ),
    );
  }
}
