import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';

class HomeBannerSlider extends ConsumerStatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  ConsumerState<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends ConsumerState<HomeBannerSlider> {
  late final PageController _pageController;
  Timer? _timer;

  static const int _kMultiplier = 500;
  static const Duration _kTransitionDuration = Duration(milliseconds: 700);
  static const Duration _kAutoScrollInterval = Duration(seconds: 4);

  bool _precached = false;

  // Warm the image cache for every banner so they appear instantly (no
  // per-image shimmer flash) when their page comes up.
  void _precacheBanners(List banners) {
    if (_precached) return;
    _precached = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final b in banners) {
        final url = b.images?.first.url as String?;
        if (url != null && url.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(url), context);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
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

    // Smooth horizontal slide to the next banner — no fade (the fade caused
    // the blink).
    _pageController.nextPage(
      duration: _kTransitionDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAsync = ref.watch(bannerProvider);

    return bannerAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        _precacheBanners(banners);
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
                  itemBuilder: (context, virtualIndex) {
                    final banner = banners[virtualIndex % count];
                    return GestureDetector(
                      onTap: () => navigateToSlug(
                        context,
                        banner.link,
                        isBrand: false,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: banner.images?.first.url ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        // No bright shimmer + no slow cross-fade: cached
                        // banners appear instantly; a subtle neutral fills
                        // only the genuine first network load.
                        fadeInDuration: const Duration(milliseconds: 120),
                        placeholderFadeInDuration: Duration.zero,
                        placeholder: (_, __) => _BannerPlaceholder(),
                        errorWidget: (_, __, ___) => _BannerPlaceholder(),
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
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _BannerPlaceholder(),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Subtle neutral fill used while a banner loads — replaces the bright white
/// shimmer that flashed before each image.
class _BannerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED),
    );
  }
}
