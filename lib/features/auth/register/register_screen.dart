import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/tff.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _referalCodeController;
  bool isPasswordVisible = true;
  bool _submitted = false;

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _referalCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      appBar: const CustomScreenHeader(title: ''),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: [
            SizedBox(height: 12.h),
            SvgPicture.asset(KImageConstant.vandharIcon),
            SizedBox(height: 10.h),
            Text(
              'Vhandar Grocery app',
              style: TextStyle(
                fontSize: 22.sp,
                color: context.vColors.onSurface,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 16.sp,
                color: context.vColors.onSurface,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Mobile Number',
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_rounded,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              prefixText: '+977 ',
              autofillHints: const [AutofillHints.username],
              keyBoardType: const TextInputType.numberWithOptions(),
              textInputFormatter: TenDigitInputFormatter(),
              validator: AppValidators.validatePhone,
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              labelText: 'Full Name',
              autofillHints: const [AutofillHints.name],
              prefixIcon: Icon(Icons.person_outline_rounded,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              suffixIcon: const SizedBox(),
              validator: AppValidators.validateName,
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Password',
              labelText: 'Password',
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                setState(() => isPasswordVisible = !isPasswordVisible);
              },
              validator: AppValidators.validatePassword,
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              labelText: 'Confirm Password',
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                setState(() => isPasswordVisible = !isPasswordVisible);
              },
              validator: (value) => AppValidators.validateConfirmPassword(
                  value, _passwordController.text),
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _referalCodeController,
              hintText: 'Referral Code (Optional)',
              labelText: 'Referral Code',
              prefixIcon: Icon(Icons.discount_outlined,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 12.h),
            CustomElevatedButton(
              isLoading: registrationState.isLoading,
              width: double.infinity,
              height: 52.h,
              backgroundColor: AppColor.secondary,
              foregroundColor: const Color(0xFF1A1A1A),
              onPressed: () {
                setState(() => _submitted = true);
                if (_formKey.currentState?.validate() ?? false) {
                  ref.read(registrationProvider.notifier).sendOtp(
                    context,
                    phoneNumber: _phoneController.text,
                    phoneCode: "+977",
                    onSuccess: () {
                      context.push(
                        LVRoute.oTPScreen.route,
                        extra: {
                          'phoneNumber': _phoneController.text,
                          'phoneCode': '+977',
                          'name': _nameController.text,
                          'referalCode': _referalCodeController.text,
                          'password': _passwordController.text,
                          'confirmPassword': _confirmPasswordController.text,
                        },
                      );
                    },
                  );
                } else {
                  AppHaptics.error();
                }
              },
              text: 'Join Vhandar',
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child:
                        Divider(color: context.vColors.divider, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: context.vColors.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Expanded(
                    child:
                        Divider(color: context.vColors.divider, thickness: 1)),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                onPressed: () {
                  context.push(LVRoute.v4BRegistrationScreen.route);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B9171), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  'Create a Business Account',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: const Color(0xFF3B9171),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10.h,
                bottom: MediaQuery.of(context).padding.bottom + 8.h,
              ),
              child: Column(
                children: [
                  Text(
                    'By continuing, you agree to our ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.vColors.onSurfaceMuted,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _openUrl('https://www.vhandar.com/privacy-policy'),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Text(
                        ' & ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.vColors.onSurfaceMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openUrl(
                            'https://www.vhandar.com/terms-of-service'),
                        child: Text(
                          'Terms of Use',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
