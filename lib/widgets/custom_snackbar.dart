import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomSnackbar {
  static OverlayEntry? _current;

  static void _show(
    BuildContext context, {
    required String message,
    required _SnackType type,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    final entry = _buildEntry(context, message: message, type: type);
    _current = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }

  static OverlayEntry _buildEntry(
    BuildContext context, {
    required String message,
    required _SnackType type,
  }) {
    return OverlayEntry(
      builder: (_) => _SnackOverlay(message: message, type: type),
    );
  }

  static void success(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    _show(context,
        message: message, type: _SnackType.success, duration: duration);
  }

  static void error(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    _show(context,
        message: message, type: _SnackType.error, duration: duration);
  }

  static void info(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    _show(context, message: message, type: _SnackType.info, duration: duration);
  }
}

enum _SnackType { success, error, info }

class _SnackOverlay extends StatefulWidget {
  final String message;
  final _SnackType type;

  const _SnackOverlay({required this.message, required this.type});

  @override
  State<_SnackOverlay> createState() => _SnackOverlayState();
}

class _SnackOverlayState extends State<_SnackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case _SnackType.success:
        return const Color(0xFF1B5E20);
      case _SnackType.error:
        return const Color(0xFFC62828);
      case _SnackType.info:
        return AppColor.primary;
    }
  }

  Color get _accentColor {
    switch (widget.type) {
      case _SnackType.success:
        return const Color(0xFF4CAF50);
      case _SnackType.error:
        return const Color(0xFFEF5350);
      case _SnackType.info:
        return AppColor.primary.withValues(alpha: 0.7);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case _SnackType.success:
        return Icons.check_circle_rounded;
      case _SnackType.error:
        return Icons.error_rounded;
      case _SnackType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 96.h,
      left: 16.w,
      right: 16.w,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: _bgColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, color: Colors.white, size: 18.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
