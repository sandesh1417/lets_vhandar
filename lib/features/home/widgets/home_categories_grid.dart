import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart' show CustomShimmer;
import 'package:lets_vhandar/widgets/pressable.dart';
import 'package:lets_vhandar/widgets/staggered_entrance.dart';

// Rotating pastel palette for card backgrounds
const _cardColors = [
  Color(0xFFE05252), // red
  Color(0xFFE87A2E), // orange
  Color(0xFFD4A017), // amber
  Color(0xFF2E9E5B), // green
  Color(0xFF2E7DD4), // blue
  Color(0xFF7B4FD4), // purple
  Color(0xFFD44F9E), // pink
  Color(0xFF2EA8A8), // teal
  Color(0xFFD4762E), // peach
  Color(0xFF5EA82E), // lime
];

const _cardColorsDark = [
  Color(0xFF3D1A1A),
  Color(0xFF3D2A1A),
  Color(0xFF3D351A),
  Color(0xFF1A3D2A),
  Color(0xFF1A2A3D),
  Color(0xFF2A1A3D),
  Color(0xFF3D1A2E),
  Color(0xFF1A3D3D),
  Color(0xFF3D2E1A),
  Color(0xFF2A3D1A),
];

class HomeCategoriesGrid extends ConsumerWidget {
  const HomeCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 130.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              final colors = isDark ? _cardColorsDark : _cardColors;
              final bg = colors[index % colors.length];
              final imageUrl = category.images?.isNotEmpty == true
                  ? category.images!.first.url
                  : null;

              return StaggeredEntrance(
                index: index,
                child: Pressable(
                onTap: () =>
                    navigateToSlug(context, category.slug, isBrand: false),
                child: Container(
                  width: 90.w,
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Image fixed at bottom — no layout shift
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 88.h,
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 90.w,
                                height: 88.h,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    _BottomPulseLoader(cardColor: bg),
                                errorWidget: (_, __, ___) => _Placeholder(),
                              )
                            : _Placeholder(),
                      ),
                      // Name at top, always visible
                      Positioned(
                        top: 10.h,
                        left: 8.w,
                        right: 8.w,
                        child: Text(
                          category.name ?? '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 130.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 6,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CustomShimmer.rectangular(
              width: 90.w,
              height: 130.h,
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/placeholder.svg',
        fit: BoxFit.contain,
      );
}

class _BottomPulseLoader extends StatefulWidget {
  final Color cardColor;
  const _BottomPulseLoader({required this.cardColor});

  @override
  State<_BottomPulseLoader> createState() => _BottomPulseLoaderState();
}

class _BottomPulseLoaderState extends State<_BottomPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        // Band sweeps from bottom (t=0) to top (t=1)
        final t = _ctrl.value;
        final bandCenter = 1.2 - t * 2.4; // goes from 1.2 → -1.2
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: [
                (bandCenter - 0.25).clamp(0.0, 1.0),
                bandCenter.clamp(0.0, 1.0),
                (bandCenter + 0.25).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
