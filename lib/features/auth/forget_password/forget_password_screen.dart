import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/forget_password/providers/forget_password_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  late TextEditingController phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgetPasswordState = ref.watch(forgetPasswordProvider);
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      isScrollable: false,
      appBar: const CustomScreenHeader(title: ''),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    SvgPicture.asset(
                      KImageConstant.forgetPassword,
                      width: 140.w,
                      height: 140.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Forgot Password?',
                      style: KTextStyle.roboto24blackD7W
                          .copyWith(color: vc.onSurface),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Enter your registered phone number\nand we'll send you a reset code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: vc.onSurfaceMuted,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Mobile Number',
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone_rounded,
                          size: 18.sp, color: vc.onSurfaceMuted),
                      prefixText: '+977 ',
                      keyBoardType: const TextInputType.numberWithOptions(),
                      textInputFormatter: TenDigitInputFormatter(),
                      validator: AppValidators.validatePhone,
                    ),
                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),
            CustomElevatedButton(
              isLoading: forgetPasswordState.isLoading,
              width: double.infinity,
              height: 52.h,
              backgroundColor: AppColor.secondary,
              foregroundColor: const Color(0xFF1A1A1A),
              onPressed: () {
                setState(() => _submitted = true);
                if (_formKey.currentState?.validate() ?? false) {
                  ref.read(forgetPasswordProvider.notifier).sendOtp(
                    context,
                    phoneNumber: phoneController.text,
                    phoneCode: '+977',
                    onSuccess: () {
                      context.push(
                        LVRoute.oTPScreen.route,
                        extra: {
                          'phoneNumber': phoneController.text,
                          'phoneCode': '+977',
                          'isResetPassword': true,
                        },
                      );
                    },
                  );
                }
              },
              text: 'Send Reset Code',
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
