import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

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
        ],
      ),
    );
  }
}
