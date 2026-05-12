import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/auth/login/providers/login_provider.dart';
import 'package:vhandar/features/profile/providers/feedback_provider.dart';
import 'package:vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:vhandar/widgets/tff.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _rating = 1;
  String _selectedCategory = '';
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<String> _categories = [
    "Recent Order",
    "Order Tracking",
    "Customer Service",
    "Delivery/Pickup Options",
    "Website Experience",
    "App Experience",
    "In-Store Experience",
    "Others"
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    final user = ref.read(loginProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit feedback')),
      );
      return;
    }

    ref.read(feedbackProvider.notifier).submitFeedback(
      description: _descriptionController.text,
      ratings: _rating.toString(),
      createdBy: user.id ?? '',
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackProvider);

    ref.listen(feedbackProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
        context.pop();
        ref.read(feedbackProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return CustomScaffoldWrapper(
      isScrollable: true,
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Column(
                children: [
                  Text(
                    'Your feedback matters!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Help us improve the Vhandar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 40.sp,
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      );
                    }),
                  ),
                  Text(
                    _getRatingText(_rating),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Sorry to hear it. What was the problem?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black45,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    alignment: WrapAlignment.center,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = selected ? cat : '');
                        },
                        selectedColor: Colors.orange.shade50,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.orange : Colors.black87,
                          fontSize: 12.sp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color: isSelected ? Colors.orange : Colors.grey.shade300,
                          ),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  CustomTextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    hintText: 'Description',
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Share with Vhandar',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 20.h),
            Text.rich(
              TextSpan(
                text: 'Questions or concerns?\nWe are here to help. Visit the ',
                children: [
                  TextSpan(
                    text: 'Help Center.',
                    style: TextStyle(color: AppColor.secondary),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Very Poor';
      case 2: return 'Poor';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}
