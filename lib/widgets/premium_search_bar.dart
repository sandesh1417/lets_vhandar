import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

const _kSearchHints = [
  'Rice',
  'Pasta',
  'Chocolate',
  'Ice Cream',
  'Maida',
  'Noodles',
  'Coffee',
  'Sauce',
  'Syrup',
  'Atta',
  'Dal',
  'Chips',
  'Milk',
  'Bread',
  'Eggs',
  'Sugar',
  'Oil',
  'Ghee',
  'Biscuits',
  'Tea',
  'Juice',
  'Butter',
  'Spices',
  'Namkeen',
  'Poha',
];

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
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTap?.call();
                    },
                    child: const _AnimatedSearchHint(),
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
                widget.onChanged?.call('');
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
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (widget.onScanTap != null) {
                    widget.onScanTap!();
                  } else {
                    context.pushNamed(LVRoute.barcodeScannerScreen.route);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedSearchHint extends StatefulWidget {
  const _AnimatedSearchHint();

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late AnimationController _controller;
  late Animation<Offset> _slideIn;
  late Animation<Offset> _slideOut;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      _controller.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _index = (_index + 1) % _kSearchHints.length);
          _controller.reset();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final keyword = _kSearchHints[_index];
    final nextKeyword = _kSearchHints[(_index + 1) % _kSearchHints.length];

    final baseStyle = TextStyle(
      fontSize: 13.sp,
      color: vc.onSurfaceMuted,
      fontWeight: FontWeight.w400,
    );
    final keywordStyle = baseStyle.copyWith(
      color: vc.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed prefix — never animates
        Text('Search for ', style: baseStyle),

        // Only the keyword animates
        ClipRect(
          child: SizedBox(
            height: 20.h,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final isAnimating = _controller.isAnimating;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (isAnimating)
                      FadeTransition(
                        opacity: _fadeOut,
                        child: SlideTransition(
                          position: _slideOut,
                          child: Text(keyword, style: keywordStyle),
                        ),
                      ),
                    if (isAnimating)
                      FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideIn,
                          child: Text(nextKeyword, style: keywordStyle),
                        ),
                      ),
                    if (!isAnimating)
                      Text(keyword, style: keywordStyle),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
