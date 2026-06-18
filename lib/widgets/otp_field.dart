import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/color_constant.dart';
import '../core/theme/vhandar_colors.dart';

/// A single, app-wide custom OTP / verification-code input.
///
/// Renders [length] cells with a few small, tasteful touches:
/// * the active cell softly scales up and glows as the cursor advances,
/// * each digit "pops" in with a quick scale + fade,
/// * a slim cursor blinks inside the active (empty) cell.
///
/// It is a [FormField] under the hood, so it plugs straight into an existing
/// [Form] + `formState.validate()` flow and shows an error message when the
/// [validator] fails.
class OtpField extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  const OtpField({
    super.key,
    this.length = 5,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final AnimationController _cursorCtrl;
  FormFieldState<String>? _field;
  bool _completedFired = false;

  bool get _ownsController => widget.controller == null;
  bool get _ownsFocus => widget.focusNode == null;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _controller.addListener(_handleChange);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    _focusNode.removeListener(_onFocusChange);
    _cursorCtrl.dispose();
    if (_ownsController) _controller.dispose();
    if (_ownsFocus) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _handleChange() {
    final text = _controller.text;
    _field?.didChange(text);
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      if (!_completedFired) {
        _completedFired = true;
        HapticFeedback.lightImpact();
        widget.onCompleted?.call(text);
      }
    } else {
      _completedFired = false;
    }
    if (mounted) setState(() {});
  }

  void _requestEdit() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      builder: (field) {
        _field = field;
        final hasError = field.hasError;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _requestEdit,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.length,
                      (i) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: _Cell(
                          char: i < _controller.text.length
                              ? _controller.text[i]
                              : '',
                          active: _focusNode.hasFocus &&
                              i == _controller.text.length,
                          hasError: hasError,
                          cursor: _cursorCtrl,
                        ),
                      ),
                    ),
                  ),
                  // Invisible field that actually captures keystrokes.
                  Positioned.fill(child: _buildHiddenInput()),
                ],
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 8.h),
              Text(
                field.errorText!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHiddenInput() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      enableInteractiveSelection: false,
      showCursor: false,
      cursorWidth: 0,
      // Transparent + 1px so the real text/caret never shows; the cells render
      // the digits instead.
      style:
          const TextStyle(color: Colors.transparent, fontSize: 1, height: 0.1),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String char;
  final bool active;
  final bool hasError;
  final Animation<double> cursor;

  const _Cell({
    required this.char,
    required this.active,
    required this.hasError,
    required this.cursor,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final filled = char.isNotEmpty;

    late final Color borderColor;
    late final Color bgColor;
    late final double borderWidth;
    if (hasError) {
      borderColor = AppColor.error;
      bgColor = AppColor.error.withValues(alpha: 0.05);
      borderWidth = 1.5;
    } else if (active) {
      borderColor = AppColor.primary;
      bgColor = AppColor.primary.withValues(alpha: 0.08);
      borderWidth = 2;
    } else if (filled) {
      borderColor = AppColor.primary.withValues(alpha: 0.4);
      bgColor = AppColor.primary.withValues(alpha: 0.06);
      borderWidth = 1.5;
    } else {
      borderColor = vc.inputBorder;
      bgColor = vc.inputFill;
      borderWidth = 1.5;
    }

    return AnimatedScale(
      scale: active ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 52.w,
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: active && !hasError
              ? [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: filled
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  char,
                  key: ValueKey<String>(char),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                ),
              )
            : active
                ? FadeTransition(
                    opacity: cursor,
                    child: Container(
                      width: 2,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
