import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

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
            child: MaterialApp(
                title: 'Lets Vhandar',
                theme: ThemeData(
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppColor.bg,
                  ),
                  colorScheme: ColorScheme.fromSeed(
                      // seedColor: const Color.fromRGBO(10, 117, 78, 1)
                      seedColor: AppColor.primary),
                  useMaterial3: true,
                ),
                home: const LoginScreen()),
          );
        });
  }
}
