import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/theme_provider.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/services/update_service.dart';
import 'package:lets_vhandar/core/theme/app_theme.dart';
import 'package:lets_vhandar/core/widgets/update_sheet.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ColoredBox(color: AppColor.primary),
      builder: (_, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: MaterialApp.router(
            title: 'Vhandar',
            routerConfig: locator<LVGoRouter>().getGoRouter,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            builder: (context, child) {
              if (UpdateService.instance.updateType == UpdateType.forced) {
                return ForceUpdateGate(child: child ?? const SizedBox.shrink());
              }
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
