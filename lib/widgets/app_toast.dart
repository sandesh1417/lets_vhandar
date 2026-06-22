import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

enum ToastType { success, error, info }

/// Branded, animated toast that slides+fades in from the top — a premium
/// replacement for the default [SnackBar].
///
/// ```dart
/// AppToast.success(context, 'Added to your list');
/// AppToast.error(context, 'Something went wrong');
/// ```
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void success(BuildContext context, String message) =>
      _show(context, message, ToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, ToastType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, ToastType.info);

  static void _show(BuildContext context, String message, ToastType type,
      {Duration duration = const Duration(seconds: 3)}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Only one toast at a time.
    _current?.remove();
    _current = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_current == entry) _current = null;
          entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    await _ctrl.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, IconData icon}) get _style {
    switch (widget.type) {
      case ToastType.success:
        return (bg: AppColor.primary, fg: Colors.white, icon: Icons.check_circle_rounded);
      case ToastType.error:
        return (bg: AppColor.error, fg: Colors.white, icon: Icons.error_rounded);
      case ToastType.info:
        return (bg: const Color(0xFF323232), fg: Colors.white, icon: Icons.info_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 12.h,
      left: 16.w,
      right: 16.w,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(s.icon, color: s.fg, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: s.fg,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
