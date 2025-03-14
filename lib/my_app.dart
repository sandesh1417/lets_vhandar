import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/config/routing/app_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: MaterialApp.router(
            title: 'Lets Vhandar',
            routerConfig: locator<LVGoRouter>().getGoRouter,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: AppColor.bg,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: AppColor.bg,
              ),
            ),
          ),
        );
      },
    );
  }
}
