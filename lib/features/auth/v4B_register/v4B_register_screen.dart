import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/core/utils/validation.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class V4BRegistrationScreen extends ConsumerStatefulWidget {
  const V4BRegistrationScreen({super.key});

  @override
  V4BRegistrationScreenState createState() => V4BRegistrationScreenState();
}

class V4BRegistrationScreenState extends ConsumerState<V4BRegistrationScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _buisnessNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswprdController;
  late TextEditingController _categoryController;
  late TextEditingController _panNumberController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _buisnessNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswprdController = TextEditingController();
    _categoryController = TextEditingController();
    _panNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _buisnessNameController.dispose();
    _passwordController.dispose();
    _confirmPasswprdController.dispose();
    _categoryController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return CustomScaffoldWrapper(
      horizontalPadding: 16.w,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 30.h),
            SvgPicture.asset(KImageConstant.vandharIcon),
            SizedBox(height: 15.h),
            Text('Vhandar Grocery app', style: KTextStyle.roboto22black8W),
            SizedBox(height: 4.h),
            Text('Create an Business Account',
                style: KTextStyle.roboto16black5W),
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
              suffixIcon: const SizedBox(),
              controller: _emailController,
              hintText: 'Enter Email Address',
              labelText: 'Email',
              onObscurePressed: () {
                // ref.read(passwordVisibilityProvider.notifier).update((state) => !isPasswordVisible);
              },
              validator: TFValidators.validateEmail,
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
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _confirmPasswprdController,
              hintText: 'Confirm Password',
              labelText: 'Confirm Password',
              obscureText: isPasswordVisible,
              onObscurePressed: () {
                ref
                    .read(passwordVisibilityProvider.notifier)
                    .update((state) => !isPasswordVisible);
              },
              validator: (value) => TFValidators.validateConfirmPassword(
                  value, _passwordController.text),
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _categoryController,
              hintText: 'Category',
              labelText: 'Category',
              onObscurePressed: () {},
              suffixIcon: const SizedBox(),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _buisnessNameController,
              hintText: 'Business Name',
              labelText: 'Business Name',
              onObscurePressed: () {},
              suffixIcon: const SizedBox(),
              validator: TFValidators.validateBusinessName,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: _panNumberController,
              hintText: 'PAN Number',
              labelText: 'PAN Number',
              onObscurePressed: () {},
              suffixIcon: const SizedBox(),
              validator: TFValidators.validatePanNumber,
            ),
            SizedBox(height: 20.h),
            CustomButton(
                onPress: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Additional check for password match
                    if (_passwordController.text !=
                        _confirmPasswprdController.text) {
                      CustomSnackbar.error(context,
                          message: 'Passwords do not match');
                      return;
                    }

                    // context.push(LVRoute.oTPScreen.route); //    /otp    otp
                    // ref.read(authStateProvider.notifier).login(
                    //       _emailController.text,
                    //       __passwordController.text,
                    //     );
                  }
                },
                buttonTitle: 'Join Vhandar'),
            SizedBox(height: 20.h),
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
