import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
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
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return CustomScaffoldWrapper(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 50.h),
            SvgPicture.asset(KImageConstant.vandharIcon),
            SizedBox(height: 15.h),
            Text('Vhandar Grocery app', style: KTextStyle.roboto22black8W),
            SizedBox(height: 4.h),
            Text('Log in or Sign up', style: KTextStyle.roboto16black5W),
            SizedBox(height: 30.h),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Enter Mobile Number',
              labelText: 'Number',
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w),
                child: Text(
                  '+ 977',
                  style: KTextStyle.roboto16black5W,
                ),
              ),
              keyBoardType: const TextInputType.numberWithOptions(),
              textInputFormatter: TenDigitInputFormatter(),
              validator: TFValidators.validatePhone,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Enter Password',
              labelText: 'Password',
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                ref
                    .read(passwordVisibilityProvider.notifier)
                    .update((state) => !isPasswordVisible);
              },
              validator: TFValidators.validatePassword,
            ),
            SizedBox(height: 20.h),
            CustomButton(
                onPress: () {
                  // context.push(LVRoute.oTPScreen.route); //    /otp    otp
                  if (_formKey.currentState?.validate() ?? false) {
                    ref.read(loginProvider.notifier).login(
                          context,
                          _phoneController.text,
                          _passwordController.text,
                        );
                  }
                },
                buttonTitle: 'Continue'),
            SizedBox(height: 16.h),
            GestureDetector(
              child: Text(
                'Forget Password ?',
                style: KTextStyle.roboto14sec7W,
              ),
              onTap: () {
                context.push(LVRoute.forgetPasswordScreen.route);
              },
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => context.push(LVRoute.registerScreen.route),
              child: RichText(
                text: TextSpan(
                  text: 'Dont have an Account? ',
                  style: TextStyle(color: AppColor.greenTxtColor),
                  children: <TextSpan>[
                    TextSpan(text: 'Sign Up', style: KTextStyle.roboto16sec5W),
                    const TextSpan(
                      text: '.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 245.h),
            Text(
              'By continuing, you agree to our ',
              style: KTextStyle.roboto12lGray3W,
            ),
            RichText(
              text: TextSpan(
                text: 'Privacy Policy',
                style: KTextStyle.roboto12sec4W,
                children: <TextSpan>[
                  TextSpan(text: ' & ', style: KTextStyle.roboto14hintTxt4W),
                  TextSpan(
                    text: 'Terms of Use',
                    style: KTextStyle.roboto12sec4W,
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
