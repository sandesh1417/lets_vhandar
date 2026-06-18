import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_constants.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/features/auth/otp/widgets/otp_section_widget.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String name;
  final String referalCode;
  final String? password;
  final String confirmPassword;
  final String? phoneCode;
  final bool isResetPassword;

  const OTPScreen({
    this.name = '',
    this.referalCode = '',
    this.password,
    this.confirmPassword = '',
    super.key,
    required this.phoneNumber,
    this.phoneCode,
    this.isResetPassword = false,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = AppConstants.otpTimerSeconds;
  bool _canResendOTP = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    focusNode = FocusNode();
    _startOTPTimer();
  }

  void _startOTPTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = AppConstants.otpTimerSeconds;
      _canResendOTP = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResendOTP = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    if (formKey.currentState?.validate() ?? false) {
      final otp = _otpController.text;
      if (widget.isResetPassword) {
        await ref.read(forgetPasswordProvider.notifier).verifyOtp(
          context,
          otp: otp,
          phoneNumber: widget.phoneNumber,
          phoneCode: widget.phoneCode,
          onSuccess: () {
            context.push(LVRoute.resetPasswordScreen.route, extra: {
              'phoneNumber': widget.phoneNumber,
              'phoneCode': widget.phoneCode,
              'otp': otp,
            });
          },
        );
      } else {
        await ref.read(registrationProvider.notifier).registerWithOtp(
              context,
              otp: otp,
              password: widget.password ?? '',
              confirmPassword: widget.confirmPassword,
              name: widget.name,
              referalCode: widget.referalCode,
              phoneNumber: widget.phoneNumber,
              phoneCode: widget.phoneCode,
              onSuccess: () => context.go(LVRoute.loginScreen.route),
            );
      }
    }
  }

  void _resendOTP() {
    if (!_canResendOTP) return;
    _startOTPTimer();
    if (widget.isResetPassword) {
      ref.read(forgetPasswordProvider.notifier).sendOtp(context,
          phoneNumber: widget.phoneNumber,
          phoneCode: widget.phoneCode ?? '+977');
    } else {
      ref.read(registrationProvider.notifier).sendOtp(context,
          phoneNumber: widget.phoneNumber,
          phoneCode: widget.phoneCode ?? '+977');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isLoading = widget.isResetPassword
        ? ref.watch(forgetPasswordProvider).isLoading
        : ref.watch(registrationProvider).isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(LVRoute.loginScreen.route);
      },
      child: CustomScaffoldWrapper(
        isScrollable: false,
        horizontalPadding: 16.w,
        appBar: const CustomScreenHeader(title: ''),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Illustration
                    SvgPicture.asset(
                      KImageConstant.otpScreen,
                      width: 140.w,
                      height: 140.w,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: 20.h),

                    // Title
                    Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: vc.onSurface,
                        fontFamily: 'Inter',
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      'Enter the verification code sent to',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        fontFamily: 'Inter',
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Phone number badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_rounded,
                              size: 14.sp, color: AppColor.primary),
                          SizedBox(width: 6.w),
                          Text(
                            '${widget.phoneCode ?? "+977"} ${widget.phoneNumber}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // OTP input
                    PinputExample(
                      controller: _otpController,
                      focusNode: focusNode,
                      formKey: formKey,
                      onCompleted: (_) {},
                      validator: (value) => value != null &&
                              value.length == AppConstants.otpLength
                          ? null
                          : 'Invalid OTP',
                    ),

                    SizedBox(height: 20.h),

                    // Timer / Resend row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: vc.onSurfaceMuted,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: _resendOTP,
                          child: _canResendOTP
                              ? Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primary,
                                    fontFamily: 'Inter',
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: vc.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '0:${_timerSeconds.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: vc.onSurfaceMuted,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),

            // Verify button pinned to bottom
            CustomElevatedButton(
              isLoading: isLoading,
              width: double.infinity,
              height: 45.h,
              backgroundColor: AppColor.secondary,
              onPressed: _verifyOTP,
              text: 'Verify',
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
