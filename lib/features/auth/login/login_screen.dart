import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      child: Column(
        children: [
          SizedBox(
            height: 50.h,
          ),
          SvgPicture.asset(KImageConstant.vandharIcon),
          SizedBox(
            height: 15.h,
          ),
          Text('Vhandar Grocery app', style: KTextStyle.roboto22black8W),
          SizedBox(height: 4.h),
          Text('Log in or Sign up', style: KTextStyle.roboto16black5W),
          SizedBox(height: 30.h),
          CustomTextField(
            hintText: 'Enter Mobile Number',
            labelText: 'Number',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w),
              child: Text(
                '+ 977',
                style: KTextStyle.roboto16black5W,
              ),
            ),
            // errorText: '',
          ),
          // SizedBox(height: 16.h),
          const CustomTextField(
            hintText: 'Enter Password',
            labelText: 'Number',
            obscureText: true,
          ),
          CustomButton(onPress: () {}, buttonTitle: 'Continue'),
          SizedBox(height: 16.h),
          GestureDetector(
            child: Text(
              'Forget Password ?',
              style: KTextStyle.roboto14sec7W,
            ),
            onTap: () {},
          ),
          SizedBox(height: 16.h),
          RichText(
            text: TextSpan(
              text: 'Dont have an Account? ',
              style: TextStyle(color: AppColor.greenTxt),
              children: <TextSpan>[
                TextSpan(text: 'Sign Up', style: KTextStyle.roboto16sec5W),
                const TextSpan(
                  text: '.',
                  style: TextStyle(color: Colors.black),
                ),
              ],
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
        ],
      ),
    );
  }
}
