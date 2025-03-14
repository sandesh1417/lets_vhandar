import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/features/auth/otp/widgets/otp_section_widget.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String name;
  final String referalCode;
  final String password;
  final String confirmPassword;
  final String? phoneCode;

  const OTPScreen({
    required this.name,
    required this.referalCode,
    required this.password,
    required this.confirmPassword,
    super.key,
    required this.phoneNumber,
    this.phoneCode,
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
      final registrationNotifier = ref.read(registrationProvider.notifier);

      // Call registerWithOtp API
      await registrationNotifier.registerWithOtp(
        context,
        otp: otp,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        name: widget.name,
        referalCode: widget.referalCode,
        phoneNumber: widget.phoneNumber,
        phoneCode: widget.phoneCode,
      );

      // final registrationState = ref.read(registrationProvider);

      // if (registrationState.isRegistered) {
      //   // Save user details in the state
      //   // ref.read(newUserInfoProvider.notifier).state = RegisterModal(
      //   //   phoneNumber: widget.phoneNumber,
      //   //   phoneCode: widget.phoneCode,
      //   //   name: name,
      //   //   password: password,
      //   // );

      //   // Navigate to the next screen (e.g., home screen)
      //   // Navigator.pushReplacementNamed(context, '/home'); // Adjust route as needed
      // } else {
      //   // Show error message
      //   // ScaffoldMessenger.of(context).showSnackBar(
      //   //   SnackBar(content: Text(registrationState.errorMessage ?? "Registration failed")),
      //   // )
      // }
    }
  }

  void _resendOTP() {
    if (_canResendOTP) {
      setState(() {
        _timerSeconds = 30;
        _canResendOTP = false;
      });
      _startOTPTimer();
      ref.read(registrationProvider.notifier).sendOtp(context,phoneNumber:widget.phoneNumber, phoneCode: "+977");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      appBar: const CustomAppBar(title: ''),
      child: Column(
        children: [
          Text('OTP Verification', style: KTextStyle.roboto24blackD7W),
          SizedBox(height: 8.h),
          Text('OTP has been sent to ${widget.phoneNumber}', style: KTextStyle.roboto14Green4W),
          SizedBox(height: 24.h),
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

          // PinputExample(controller: _otpController, focusNode: focusNode, formKey: formKey),
          SizedBox(height: 32.h),
          CustomButton(
            onPress: _verifyOTP,
            buttonTitle: 'Verify',
          ),
          SizedBox(height: 16.h),
          Text(
            _timerSeconds > 0 ? '00:${_timerSeconds.toString().padLeft(2, '0')}' : '',
            style: KTextStyle.roboto24GreenD4W,
          ),
          SizedBox(height: 8.h),
          Text('Didn’t get it?', style: KTextStyle.roboto14Green6W),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _resendOTP,
            child: Text(
              'Send OTP (SMS)',
              style: KTextStyle.roboto16sec5W.copyWith(
                color: _canResendOTP ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
