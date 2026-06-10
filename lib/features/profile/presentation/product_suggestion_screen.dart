import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/providers/product_suggestion_provider.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';

/// Opens the product suggestion sheet from the bottom.
void showProductSuggestionSheet(BuildContext context) {
  showAppSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProductSuggestionSheet(),
  );
}

// Keep the old screen class so the router entry still compiles.
class ProductSuggestionScreen extends StatelessWidget {
  const ProductSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProductSuggestionSheet(context);
      context.pop();
    });
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _ProductSuggestionSheet extends ConsumerStatefulWidget {
  const _ProductSuggestionSheet();

  @override
  ConsumerState<_ProductSuggestionSheet> createState() =>
      _ProductSuggestionSheetState();
}

class _ProductSuggestionSheetState
    extends ConsumerState<_ProductSuggestionSheet> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      CustomSnackbar.error(context, message: 'Please enter a suggestion');
      return;
    }
    final user = ref.read(loginProvider).user;
    if (user == null) {
      CustomSnackbar.error(context,
          message: 'Please login to suggest a product');
      return;
    }
    ref.read(productSuggestionProvider.notifier).suggestProduct(
          suggestions: text,
          suggestedBy: user.id ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSuggestionProvider);
    final vc = context.vColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    ref.listen(productSuggestionProvider, (_, next) {
      if (next.isSuccess) {
        CustomSnackbar.success(context,
            message: 'Suggestion submitted successfully!');
        _ctrl.clear();
        Navigator.of(context).pop();
        ref.read(productSuggestionProvider.notifier).reset();
      }
      if (next.error != null) {
        CustomSnackbar.error(context, message: next.error!);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomInset + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: vc.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Headline + GIF
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Didn't find ",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                    height: 1.2,
                  ),
                ),
              ),
              Image.asset(
                KImageConstant.sadFaceGif,
                width: 32.w,
                height: 32.w,
              ),
            ],
          ),
          Text(
            'what you were looking for?',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: vc.onSurface,
              fontFamily: 'Inter',
              height: 1.2,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            "Suggest something & we'll look into it.",
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),

          SizedBox(height: 20.h),

          // Text area
          Container(
            decoration: BoxDecoration(
              color: vc.scaffoldBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: vc.divider, width: 1.2),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 5,
              minLines: 5,
              style: TextStyle(
                fontSize: 14.sp,
                color: vc.onSurface,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText:
                    "Enter the name of the products you'd like to see on Vhandar.",
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: vc.onSurfaceMuted,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14.w),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColor.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Submit Suggestion',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
