import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/config/routing/app_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

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
              routerConfig: GetIt.instance<LVGoRouter>().getGoRouter,
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColor.bg,
                ),
                // colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
                useMaterial3: true,
                // textTheme: TextTheme()
              ),
              darkTheme: ThemeData(
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColor.bg,
                ),
                // colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
                useMaterial3: true,
                // textTheme: TextTheme()
              ),
              // home: const SplashScreen(),
            ),
          );
        });
  }
}
