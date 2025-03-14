import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/config/routing/app_router.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/register/providers/register_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
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

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _referalCodeController = TextEditingController();
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
    return CustomScaffoldWrapper(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 50.h),
            SvgPicture.asset(KImageConstant.vandharIcon),
            SizedBox(height: 15.h),
            Text('Vhandar Grocery app', style: KTextStyle.roboto22black8W),
            SizedBox(height: 4.h),
            Text('Create an Account', style: KTextStyle.roboto16black5W),
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
              validator: LoginValidators.validatePhone,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _nameController,
              hintText: 'Enter Name',
              labelText: 'Name',
              onObscurePressed: () {},
              suffixIcon: const SizedBox(),
              validator: LoginValidators.validateName,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Enter Password',
              labelText: 'Password',
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              validator: LoginValidators.validatePassword,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              labelText: 'Confirm Password',
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              validator: LoginValidators.validatePassword,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _referalCodeController,
              hintText: 'Referral Code',
              labelText: 'Referral Code',
              onObscurePressed: () {},
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              onPress: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Save user data to the state
                  ref.read(registrationProvider.notifier).sendOtp(_phoneController.text, "+977");
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

                  // Navigate to OTP screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const OTPScreen(phoneNumber: '')),
                  // );
                }
              },
              buttonTitle: 'Join Vhandar',
            ),
          ],
        ),
      ),
    );
  }
}
