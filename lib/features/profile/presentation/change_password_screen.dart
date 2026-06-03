import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/providers/change_password_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
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

  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isLoading = ref.watch(changePasswordProvider).isLoading;
    final userId = ref.watch(loginProvider).user?.id ?? '';

    return CustomScaffoldWrapper(
      isScrollable: false,
      appBar: const CustomScreenHeader(title: 'Change Password'),
      horizontalPadding: 16.w,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      'Keep your account secure with a strong password.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Current password
                    CustomTextField(
                      controller: _oldPasswordController,
                      labelText: 'Current Password',
                      hintText: 'Enter current password',
                      obscureText: !_oldVisible,
                      prefixIcon: Icon(Icons.lock_outline_rounded,
                          size: 18.sp, color: vc.onSurfaceMuted),
                      onObscurePressed: () =>
                          setState(() => _oldVisible = !_oldVisible),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Current password is required'
                          : null,
                    ),

                    SizedBox(height: 14.h),

                    // New password
                    CustomTextField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      obscureText: !_newVisible,
                      prefixIcon: Icon(Icons.lock_open_rounded,
                          size: 18.sp, color: vc.onSurfaceMuted),
                      onObscurePressed: () =>
                          setState(() => _newVisible = !_newVisible),
                      validator: TFValidators.validatePassword,
                    ),

                    SizedBox(height: 14.h),

                    // Confirm password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm New Password',
                      hintText: 'Re-enter new password',
                      obscureText: !_confirmVisible,
                      prefixIcon: Icon(Icons.lock_outline_rounded,
                          size: 18.sp, color: vc.onSurfaceMuted),
                      onObscurePressed: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                      validator: (v) => TFValidators.validateConfirmPassword(
                          v, _newPasswordController.text),
                    ),

                    SizedBox(height: 16.h),

                    // Hint
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 13.sp,
                            color: AppColor.primary.withValues(alpha: 0.7)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            'Minimum 6 characters. Use a mix of letters and numbers for a stronger password.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: vc.onSurfaceMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Button
            CustomButton(
              isLoading: isLoading,
              onPress: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_newPasswordController.text ==
                      _oldPasswordController.text) {
                    CustomSnackbar.error(context,
                        message:
                            'New password must be different from current password');
                    return;
                  }
                  ref.read(changePasswordProvider.notifier).changePassword(
                    context,
                    userId: userId,
                    oldPassword: _oldPasswordController.text,
                    password: _newPasswordController.text,
                    confirmPassword: _confirmPasswordController.text,
                    onSuccess: () => context.pop(),
                  );
                }
              },
              buttonTitle: 'Update Password',
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
