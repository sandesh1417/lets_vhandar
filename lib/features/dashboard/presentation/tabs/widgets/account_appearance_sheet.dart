import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/theme_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';

void showAppearanceSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(themeModeProvider);
  showAppSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _AppearanceSheet(current: current, ref: ref),
  );
}

class _AppearanceSheet extends StatefulWidget {
  final ThemeMode current;
  final WidgetRef ref;
  const _AppearanceSheet({required this.current, required this.ref});

  @override
  State<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<_AppearanceSheet> {
  late ThemeMode _selected;

  static const _options = [
    (mode: ThemeMode.light, label: 'Light', icon: Icons.wb_sunny_rounded),
    (mode: ThemeMode.dark, label: 'Dark', icon: Icons.nights_stay_rounded),
    (mode: ThemeMode.system, label: 'System', icon: Icons.desktop_mac_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  void _pick(ThemeMode mode) {
    AppHaptics.light();
    setState(() => _selected = mode);
    widget.ref.read(themeModeProvider.notifier).setMode(mode);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: vc.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.palette_outlined,
                      color: AppColor.primary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: vc.onSurface,
                      ),
                    ),
                    Text(
                      'Choose how Vhandar looks on this device',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vc.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: _options.map((opt) {
                final isSelected = _selected == opt.mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(opt.mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColor.primary : vc.surfaceVariant,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opt.icon,
                            size: 24.sp,
                            color:
                                isSelected ? Colors.white : vc.onSurfaceMuted,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : vc.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
