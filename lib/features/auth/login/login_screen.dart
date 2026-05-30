import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isFormFilled = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final filled = _phoneController.text.length == 10 &&
        _passwordController.text.isNotEmpty;
    if (filled != _isFormFilled) setState(() => _isFormFilled = filled);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      isScrollable: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () =>
                ref.read(loginProvider.notifier).enterGuestMode(context),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Skip Login',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
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
                        'Log in or Sign up',
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
                        prefixIcon: Icon(Icons.phone_rounded,
                            size: 18.sp, color: context.vColors.onSurfaceMuted),
                        prefixText: '+977 ',
                        autofillHints: const [AutofillHints.username],
                        keyBoardType: const TextInputType.numberWithOptions(),
                        textInputFormatter: TenDigitInputFormatter(),
                        validator: TFValidators.validatePhone,
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        labelText: 'Password',
                        obscureText: isPasswordVisible,
                        autofillHints: const [AutofillHints.password],
                        prefixIcon: Icon(Icons.lock_outline_rounded,
                            size: 18.sp, color: context.vColors.onSurfaceMuted),
                        onObscurePressed: () {
                          ref
                              .read(passwordVisibilityProvider.notifier)
                              .update((state) => !isPasswordVisible);
                        },
                        validator: TFValidators.validatePassword,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                        () => _rememberMe = v ?? false),
                                    activeColor: AppColor.primary,
                                    side: BorderSide(
                                        color: context.vColors.onSurfaceMuted, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(4.r),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: context.vColors.onSurfaceMuted,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context
                                .push(LVRoute.forgetPasswordScreen.route),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      CustomButton(
                        isLoading: loginState.isLoading,
                        btnHeight: 52.h,
                        buttonColor: _isFormFilled
                            ? AppColor.secondary
                            : const Color(0xFF9C9C9C),
                        txtStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: _isFormFilled
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                        ),
                        onPress: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ref.read(loginProvider.notifier).login(
                                  context,
                                  _phoneController.text,
                                  _passwordController.text,
                                );
                          }
                        },
                        buttonTitle: 'Continue',
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () =>
                            context.push(LVRoute.registerScreen.route),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: context.vColors.onSurfaceMuted,
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
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
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
