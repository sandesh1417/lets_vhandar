import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class PremiumSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onScanTap;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showScanIcon;
  final bool autofocus;

  const PremiumSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search for products...',
    this.onScanTap,
    this.readOnly = false,
    this.onTap,
    this.showScanIcon = true,
    this.autofocus = false,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search-active.svg',
            width: 20.sp,
            height: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: widget.readOnly
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.hintText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                : TextField(
                    controller: widget.controller,
                    autofocus: widget.autofocus,
                    onChanged: widget.onChanged,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
          ),
          if (!widget.readOnly && widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Icon(
                  Icons.close_rounded,
                  color: vc.onSurfaceMuted,
                  size: 20.sp,
                ),
              ),
            ),
          if (widget.showScanIcon) ...[
            Container(
              height: 18.h,
              width: 1,
              color: vc.divider,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
            ),
            SizedBox(
              width: 28.w,
              child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/barcode.svg',
                width: 18.sp,
                height: 18.sp,
                colorFilter: ColorFilter.mode(vc.onSurface, BlendMode.srcIn),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: widget.onScanTap ??
                  () {
                    context.pushNamed(LVRoute.barcodeScannerScreen.route);
                  },
            ),
            ),
          ],
        ],
      ),
    );
  }
}
