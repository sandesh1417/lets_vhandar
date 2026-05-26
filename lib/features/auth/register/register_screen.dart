import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/tff.dart';

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
  bool isPasswordVisible = false;
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _referalCodeController = TextEditingController();
    _phoneController.addListener(_onFormChanged);
    _nameController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final filled = _phoneController.text.length == 10 &&
        _nameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
    if (filled != _isFormFilled) setState(() => _isFormFilled = filled);
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
        child: Column(
          children: [
            SizedBox(height: 30.h),
            SvgPicture.asset(KImageConstant.vandharIcon),
            SizedBox(height: 15.h),
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
            SizedBox(height: 30.h),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Mobile Number',
              labelText: 'Mobile Number',
              prefixText: '+977 ',
              autofillHints: const [AutofillHints.username],
              keyBoardType: const TextInputType.numberWithOptions(),
              textInputFormatter: TenDigitInputFormatter(),
              validator: TFValidators.validatePhone,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              labelText: 'Full Name',
              autofillHints: const [AutofillHints.name],
              prefixIcon: Icon(Icons.person_outline_rounded,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              suffixIcon: const SizedBox(),
              validator: TFValidators.validateName,
            ),
            SizedBox(height: 12.h),
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
              validator: TFValidators.validatePassword,
            ),
            SizedBox(height: 12.h),
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
              validator: (value) => TFValidators.validateConfirmPassword(
                  value, _passwordController.text),
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _referalCodeController,
              hintText: 'Referral Code (Optional)',
              labelText: 'Referral Code',
              prefixIcon: Icon(Icons.discount_outlined,
                  size: 18.sp, color: context.vColors.onSurfaceMuted),
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              isLoading: registrationState.isLoading,
              btnHeight: 52.h,
              buttonColor: _isFormFilled
                  ? AppColor.secondary
                  : context.vColors.surfaceVariant,
              txtStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: _isFormFilled
                    ? const Color(0xFF1A1A1A)
                    : context.vColors.onSurfaceMuted,
              ),
              onPress: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    CustomSnackbar.error(context,
                        message: 'Passwords do not match');
                    return;
                  }
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
                }
              },
              buttonTitle: 'Join Vhandar',
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Divider(
                        color: context.vColors.divider, thickness: 1)),
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
                    child: Divider(
                        color: context.vColors.divider, thickness: 1)),
              ],
            ),
            SizedBox(height: 16.h),
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
            SizedBox(height: 32.h),
            Text(
              'By continuing, you agree to our ',
              style: TextStyle(
                fontSize: 12.sp,
                color: context.vColors.onSurfaceMuted,
                fontWeight: FontWeight.w300,
                fontFamily: 'Inter',
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.primary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' & ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.vColors.onSurfaceMuted,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Use',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
