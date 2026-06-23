import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/theme_provider.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/services/update_service.dart';
import 'package:lets_vhandar/core/theme/app_theme.dart';
import 'package:lets_vhandar/core/utils/scroll_activity.dart';
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
              final content = child ?? const SizedBox.shrink();
              // Track scroll activity app-wide so the cart pill (and anything
              // else) can shrink while scrolling. Notifications bubble up here
              // from every route's scroll views.
              final tracked = NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Only the page's own (outermost, vertical) scroll view
                  // should drive this — nested horizontal carousels/lists
                  // (banner slider, product rows, …) bubble notifications
                  // through here too, with extra depth, and would otherwise
                  // make the cart pill shrink/expand on every banner swipe
                  // or autoplay tick even though the page itself is still.
                  if (notification.depth == 0 &&
                      notification.metrics.axis == Axis.vertical) {
                    AppScrollActivity.notify();
                  }
                  return false; // don't consume — let others still receive it
                },
                child: content,
              );
              if (UpdateService.instance.updateType == UpdateType.forced) {
                return ForceUpdateGate(child: tracked);
              }
              return tracked;
            },
          ),
        );
      },
    );
  }
}
