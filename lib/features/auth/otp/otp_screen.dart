import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/features/auth/otp/widgets/otp_section_widget.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
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
        final forgetPasswordNotifier =
            ref.read(forgetPasswordProvider.notifier);
        await forgetPasswordNotifier.verifyOtp(
          context,
          otp: otp,
          phoneNumber: widget.phoneNumber,
          phoneCode: widget.phoneCode,
          onSuccess: () {
            context.push(
              LVRoute.resetPasswordScreen.route,
              extra: {
                'phoneNumber': widget.phoneNumber,
                'phoneCode': widget.phoneCode,
                'otp': otp,
              },
            );
          },
        );
      } else {
        final registrationNotifier = ref.read(registrationProvider.notifier);
        await registrationNotifier.registerWithOtp(
          context,
          otp: otp,
          password: widget.password ?? '',
          confirmPassword: widget.confirmPassword,
          name: widget.name,
          referalCode: widget.referalCode,
          phoneNumber: widget.phoneNumber,
          phoneCode: widget.phoneCode,
          onSuccess: () {
            context.go(LVRoute.loginScreen.route);
          },
        );
      }
    }
  }

  void _resendOTP() {
    if (_canResendOTP) {
      _startOTPTimer();
      if (widget.isResetPassword) {
        ref.read(forgetPasswordProvider.notifier).sendOtp(context,
            phoneNumber: widget.phoneNumber,
            phoneCode: widget.phoneCode ?? "+977");
      } else {
        ref.read(registrationProvider.notifier).sendOtp(context,
            phoneNumber: widget.phoneNumber,
            phoneCode: widget.phoneCode ?? "+977");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);
    final forgetPasswordState = ref.watch(forgetPasswordProvider);
    final isLoading = widget.isResetPassword
        ? forgetPasswordState.isLoading
        : registrationState.isLoading;

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      appBar: const CustomScreenHeader(title: ''),
      body: Column(
        children: [
          SvgPicture.asset(
            KImageConstant.otpScreen,
            width: 160.w,
            height: 160.w,
          ),
          SizedBox(height: 24.h),
          Text('OTP Verification', style: KTextStyle.roboto24blackD7W.copyWith(color: context.vColors.onSurface)),
          SizedBox(height: 8.h),
          Text.rich(
            TextSpan(
              text: 'Code sent to ',
              style: KTextStyle.roboto14Gray4W.copyWith(color: context.vColors.onSurfaceMuted),
              children: [
                TextSpan(
                  text: '${widget.phoneCode ?? "+977"} ${widget.phoneNumber}',
                  style: KTextStyle.roboto14GreenD4W
                      .copyWith(color: Colors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          PinputExample(
            controller: _otpController,
            focusNode: focusNode,
            formKey: formKey,
            onCompleted: (otp) {
              debugPrint("Entered OTP: $otp");
            },
            validator: (value) {
              return value != null && value.length == 5 ? null : "Invalid OTP";
            },
          ),
          SizedBox(height: 32.h),
          CustomButton(
            isLoading: isLoading,
            onPress: _verifyOTP,
            buttonTitle: 'Verify Code',
          ),
          SizedBox(height: 24.h),
          Text('Didn\'t receive the code?', style: KTextStyle.roboto14Gray4W.copyWith(color: context.vColors.onSurfaceMuted)),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _resendOTP,
            child: Text(
              'Resend OTP',
              style: KTextStyle.roboto16sec5W.copyWith(
                color: _canResendOTP ? Colors.orange : context.vColors.onSurfaceMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
