import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/providers/product_suggestion_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/tff.dart';

class ProductSuggestionScreen extends ConsumerStatefulWidget {
  const ProductSuggestionScreen({super.key});

  @override
  ConsumerState<ProductSuggestionScreen> createState() => _ProductSuggestionScreenState();
}

class _ProductSuggestionScreenState extends ConsumerState<ProductSuggestionScreen> {
  final TextEditingController _suggestionController = TextEditingController();

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  void _submitSuggestion() {
    final suggestions = _suggestionController.text.trim();
    if (suggestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a suggestion')),
      );
      return;
    }

    final user = ref.read(loginProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to suggest a product')),
      );
      return;
    }

    ref.read(productSuggestionProvider.notifier).suggestProduct(
      suggestions: suggestions,
      suggestedBy: user.id ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSuggestionProvider);

    ref.listen(productSuggestionProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suggestion submitted successfully!')),
        );
        _suggestionController.clear();
        context.pop();
        ref.read(productSuggestionProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return CustomScaffoldWrapper(
      appBar: const CustomScreenHeader(title: 'Suggest Product'),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which product are you looking for?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.vColors.onSurface,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Let us know what products you would like to see on Vhandar. We will try our best to bring them for you.',
              style: TextStyle(
                fontSize: 13.sp,
                color: context.vColors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _suggestionController,
              maxLines: 6,
              hintText: 'Enter product name, brand, or description...',
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submitSuggestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit Suggestion',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
