import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/features/auth/otp/widgets/otp_section_widget.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    focusNode = FocusNode();

    /// In case you need an SMS autofill feature
    // smsRetriever = SmsRetrieverImpl(
    //   SmartAuth(),
    // );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      appBar: const CustomAppBar(
        title: '',
      ),
      child: Column(
        children: [
          Text(
            'OTP Verification',
            style: KTextStyle.roboto24blackD7W,
          ),
          SizedBox(height: 8.h),
          Text('OTP has been sent to +9779851357358', style: KTextStyle.roboto14Green4W),
          SizedBox(height: 24.h),
          const PinputExample(),
          SizedBox(height: 32.h),
          CustomButton(
              onPress: () {
                focusNode.unfocus();
                formKey.currentState!.validate();
                // if (_formKey.currentState?.validate() ?? false) {
                // ref.read(authStateProvider.notifier).login(
                //       _emailController.text,
                //       __passwordController.text,
                //     );
                // }
              },
              buttonTitle: 'Verify'),
          SizedBox(height: 16.h),
          Text('00:00', style: KTextStyle.roboto24GreenD4W),
          SizedBox(height: 8.h),
          Text('Didn’t get it?', style: KTextStyle.roboto14Green6W),
          SizedBox(height: 8.h),
          Text('Send OTP (SMS)', style: KTextStyle.roboto16sec5W)
        ],
      ),
    );
  }
}
