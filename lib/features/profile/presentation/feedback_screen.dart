import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/profile/providers/feedback_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _rating = 0;
  final Set<String> _selectedCategories = {};
  final TextEditingController _descriptionController = TextEditingController();
  int _charCount = 0;

  static const _categories = [
    'Website Experience',
    'Recent Order',
    'In-Store Experience',
    'Customer Service',
    'Delivery/Pickup Options',
    'Other',
  ];

  static const _labels = [
    '',
    'Very poor',
    'Poor',
    'Fair',
    'Good',
    'Excellent!'
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(
      () => setState(() => _charCount = _descriptionController.text.length),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      CustomSnackbar.info(context, message: 'Please select a rating');
      return;
    }
    final user = ref.read(loginProvider).user;
    if (user == null) {
      CustomSnackbar.info(context, message: 'Please login to submit feedback');
      return;
    }
    ref.read(feedbackProvider.notifier).submitFeedback(
          description: _descriptionController.text,
          ratings: _rating.toString(),
          createdBy: user.id ?? '',
          category: _selectedCategories.join(', '),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackProvider);
    final vc = context.vColors;

    ref.listen(feedbackProvider, (_, next) {
      if (next.isSuccess) {
        CustomSnackbar.success(context,
            message: 'Thank you for your feedback!');
        context.pop();
        ref.read(feedbackProvider.notifier).reset();
      }
      if (next.error != null) {
        CustomSnackbar.error(context, message: next.error!);
      }
    });

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
      backgroundColor: vc.surface,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: CustomElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              isLoading: state.isLoading,
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              loaderSize: 24.w,
              loaderColor: AppColor.primary,
              text: 'Submit Feedback',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── White top section ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/icons/feedback.svg',
                    width: 110.w,
                    height: 110.w,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Your feedback matters!\nHelp us improve the Vhandar app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: vc.onSurface,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  _StarRow(
                    rating: _rating,
                    onRate: (r) => setState(() {
                      _rating = r;
                      _selectedCategories.clear();
                    }),
                  ),
                  SizedBox(height: 10.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _rating == 0
                          ? '(1 = Very poor, 5 = Excellent!)'
                          : _labels[_rating],
                      key: ValueKey(_rating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: vc.onSurfaceMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Gray expandable panel ──────────────────────────────
            if (_rating > 0)
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: _FeedbackPanel(
                  rating: _rating,
                  starIndex: _rating,
                  totalStars: 5,
                  categories: _categories,
                  selectedCategories: _selectedCategories,
                  descriptionController: _descriptionController,
                  charCount: _charCount,
                  onCategoryTap: (cat) => setState(() {
                    if (_selectedCategories.contains(cat)) {
                      _selectedCategories.remove(cat);
                    } else {
                      _selectedCategories.add(cat);
                    }
                  }),
                ),
              ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star row
// ─────────────────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRate;

  const _StarRow({required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starNum = i + 1;
        final isFilled = starNum <= rating;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onRate(starNum);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 48.sp,
              color: isFilled
                  ? AppColor.secondary
                  : context.vColors.onSurfaceMuted.withValues(alpha: 0.4),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable feedback panel (gray area)
// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackPanel extends StatelessWidget {
  final int rating;
  final int starIndex;
  final int totalStars;
  final List<String> categories;
  final Set<String> selectedCategories;
  final TextEditingController descriptionController;
  final int charCount;
  final ValueChanged<String> onCategoryTap;

  const _FeedbackPanel({
    required this.rating,
    required this.starIndex,
    required this.totalStars,
    required this.categories,
    required this.selectedCategories,
    required this.descriptionController,
    required this.charCount,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isDark = context.isDark;
    final panelBg = isDark ? vc.surfaceVariant : const Color(0xFFEEEEEE);
    final isNegative = rating <= 3;
    final isPositive = rating == 5;

    // compute left offset for the triangle pointer based on selected star
    final double screenW = MediaQuery.of(context).size.width;
    const double hPad = 24.0;
    final double starAreaW = screenW - hPad * 2;
    final double starW = starAreaW / totalStars;
    final double triangleX = hPad + starW * (starIndex - 1) + starW / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Triangle pointer ──────────────────────────────
        SizedBox(
          height: 14.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: triangleX - 12,
                top: 0,
                child: CustomPaint(
                  size: Size(24.w, 14.h),
                  painter: _TrianglePainter(color: panelBg),
                ),
              ),
            ],
          ),
        ),

        // ── Panel content ─────────────────────────────────
        Container(
          color: panelBg,
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPositive) ...[
                Text(
                  "We're really glad you had a good experience!",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: vc.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
              ] else if (isNegative) ...[
                Text(
                  'Sorry to hear it. What was the problem?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: vc.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                _CategoryChips(
                  categories: categories,
                  selected: selectedCategories,
                  onTap: onCategoryTap,
                ),
                SizedBox(height: 16.h),
              ] else ...[
                // rating == 4 (Good): no header, no chips
                SizedBox(height: 4.h),
              ],

              // Text area
              Container(
                decoration: BoxDecoration(
                  color: vc.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isDark ? vc.divider : const Color(0xFFCCCCCC),
                  ),
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  maxLength: 300,
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: vc.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Please tell us more (Max 300 characters)',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurfaceMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14.w),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount / 300',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: vc.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category chips grid
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isDark = context.isDark;

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: categories.map((cat) {
        final isSelected = selected.contains(cat);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(cat);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? (isDark ? Colors.white70 : Colors.black54)
                    : (isDark ? vc.divider : const Color(0xFFCCCCCC)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: vc.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Triangle painter for the panel pointer
// ─────────────────────────────────────────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
