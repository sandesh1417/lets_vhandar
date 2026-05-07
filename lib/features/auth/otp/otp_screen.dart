import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/features/auth/otp/widgets/otp_section_widget.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

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
  int _timerSeconds = 30;
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    focusNode = FocusNode();
    _startOTPTimer();
  }

  void _startOTPTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
          _startOTPTimer();
        } else {
          setState(() => _canResendOTP = true);
        }
      }
    });
  }

  @override
  void dispose() {
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
        );
      }
    }
  }

  void _resendOTP() {
    if (_canResendOTP) {
      setState(() {
        _timerSeconds = 30;
        _canResendOTP = false;
      });
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
      appBar: const CustomAppBar(title: ''),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.1),
            ),
            child:
                const Icon(Icons.mail_outline, size: 50, color: Colors.orange),
          ),
          SizedBox(height: 24.h),
          Text('OTP Verification', style: KTextStyle.roboto24blackD7W),
          SizedBox(height: 8.h),
          Text.rich(
            TextSpan(
              text: 'Code sent to ',
              style: KTextStyle.roboto14Gray4W,
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
          Text('Didn\'t receive the code?', style: KTextStyle.roboto14Gray4W),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _resendOTP,
            child: Text(
              'Resend OTP',
              style: KTextStyle.roboto16sec5W.copyWith(
                color: _canResendOTP ? Colors.orange : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
