import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class HomeBannerSlider extends ConsumerStatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  ConsumerState<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends ConsumerState<HomeBannerSlider>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  Timer? _timer;

  static const int _kMultiplier = 500;
  static const Duration _kTransitionDuration = Duration(milliseconds: 700);
  static const Duration _kAutoScrollInterval = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    _animController = AnimationController(
      vsync: this,
      duration: _kTransitionDuration,
      value: 1.0,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(_kAutoScrollInterval, (_) => _next());
  }

  void _stopAutoScroll() => _timer?.cancel();

  void _next() {
    if (!_pageController.hasClients) return;
    final banners = ref.read(bannerProvider).value;
    if (banners == null || banners.length <= 1) return;

    _animController.forward(from: 0.0).then((_) {
      _pageController.nextPage(
        duration: _kTransitionDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAsync = ref.watch(bannerProvider);

    return bannerAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        final count = banners.length;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  if (notif is ScrollStartNotification &&
                      notif.dragDetails != null) {
                    _stopAutoScroll();
                  } else if (notif is ScrollEndNotification) {
                    _startAutoScroll();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: count * _kMultiplier,
                  onPageChanged: (_) {
                    _animController.forward(from: 0.0);
                  },
                  itemBuilder: (context, virtualIndex) {
                    final banner = banners[virtualIndex % count];
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: GestureDetector(
                        onTap: () => navigateToSlug(
                          context,
                          banner.link,
                          isBrand: false,
                        ),
                        child: CustomImageViewer(
                          path: banner.images?.first.url,
                          borderRadius: 0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: const AspectRatio(
            aspectRatio: 16 / 9,
            child: CustomShimmer.rectangular(height: double.infinity),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
