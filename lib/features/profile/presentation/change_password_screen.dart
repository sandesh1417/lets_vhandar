import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/providers/change_password_provider.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordProvider);
    final userId = ref.watch(loginProvider).user?.id ?? '';

    return CustomScaffoldWrapper(
      appBar: const CustomAppBar(title: 'Change Password'),
      horizontalPadding: 16.w,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Text('Current Password',
                  style: KTextStyle.roboto14BlackD5W
                      .copyWith(color: Colors.black)),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _oldPasswordController,
                hintText: 'Enter current Password',
                obscureText: !_isOldPasswordVisible,
                prefixIcon:
                    Icon(Icons.lock_outline, size: 20.sp, color: Colors.grey),
                onObscurePressed: () {
                  setState(
                      () => _isOldPasswordVisible = !_isOldPasswordVisible);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
                labelText: 'Current Password',
              ),
              SizedBox(height: 20.h),
              Text('New Password',
                  style: KTextStyle.roboto14BlackD5W
                      .copyWith(color: Colors.black)),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _newPasswordController,
                hintText: 'Enter new Password',
                obscureText: !_isNewPasswordVisible,
                prefixIcon:
                    Icon(Icons.lock_outline, size: 20.sp, color: Colors.grey),
                onObscurePressed: () {
                  setState(
                      () => _isNewPasswordVisible = !_isNewPasswordVisible);
                },
                validator: TFValidators.validatePassword,
                labelText: 'New Password',
              ),
              SizedBox(height: 8.h),
              Text(
                'Password must be more than 6 characters and one you haven\'t used before.',
                style: KTextStyle.roboto12lGray3W.copyWith(fontSize: 11.sp),
              ),
              SizedBox(height: 20.h),
              Text('Retype Password',
                  style: KTextStyle.roboto14BlackD5W
                      .copyWith(color: Colors.black)),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: !_isConfirmPasswordVisible,
                prefixIcon:
                    Icon(Icons.lock_outline, size: 20.sp, color: Colors.grey),
                onObscurePressed: () {
                  setState(() =>
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                },
                validator: (value) => TFValidators.validateConfirmPassword(
                  value,
                  _newPasswordController.text,
                ),
                labelText: 'Confirm Password',
              ),
              SizedBox(height: 40.h),
              CustomButton(
                isLoading: changePasswordState.isLoading,
                onPress: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_newPasswordController.text ==
                        _oldPasswordController.text) {
                      CustomSnackbar.error(context,
                          message:
                              'New password must not be the same as old password');
                      return;
                    }

                    ref.read(changePasswordProvider.notifier).changePassword(
                      context,
                      userId: userId,
                      oldPassword: _oldPasswordController.text,
                      password: _newPasswordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      onSuccess: () {
                        Navigator.pop(context);
                      },
                    );
                  }
                },
                buttonTitle: 'Change Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
