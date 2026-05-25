import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
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
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    phoneController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final filled = phoneController.text.length == 10;
    if (filled != _isFormFilled) setState(() => _isFormFilled = filled);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgetPasswordState = ref.watch(forgetPasswordProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      appBar: const CustomScreenHeader(title: ''),
      body: Form(
        key: _formKey,
        child: Column(children: [
          SizedBox(height: 16.h),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_open_outlined,
                size: 34.sp, color: AppColor.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            'Forgot Password',
            style: KTextStyle.roboto24blackD7W.copyWith(color: context.vColors.onSurface),
          ),
          SizedBox(height: 8.h),
          Text(
            "Enter your phone number and we'll send a reset code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.vColors.onSurfaceMuted,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 32.h),
          CustomTextField(
            controller: phoneController,
            hintText: 'Enter Mobile Number',
            labelText: 'Mobile Number',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 8.w),
              child: Text('+ 977', style: KTextStyle.roboto16black5W.copyWith(color: context.vColors.onSurface)),
            ),
            keyBoardType: const TextInputType.numberWithOptions(),
            textInputFormatter: TenDigitInputFormatter(),
            validator: TFValidators.validatePhone,
          ),
          SizedBox(height: 20.h),
          CustomButton(
            isLoading: forgetPasswordState.isLoading,
            btnHeight: 52.h,
            buttonColor:
                _isFormFilled ? AppColor.secondary : context.vColors.surfaceVariant,
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
                ref.read(forgetPasswordProvider.notifier).sendOtp(
                  context,
                  phoneNumber: phoneController.text,
                  phoneCode: "+977",
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
            buttonTitle: 'Send Reset Code',
          ),
        ]),
      ),
    );
  }
}
