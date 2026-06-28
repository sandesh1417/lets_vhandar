import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Owns the card↔fullscreen morph state, driven by the active page's scroll
/// offset. Scrolling down grows [progress] 0→1 (card → edge-to-edge fullscreen);
/// scrolling back to the top shrinks it. [fullscreen] is a coarse on/off flag
/// derived from [progress] that flips only at the threshold (not per frame), so
/// listeners that only care about the maximized state — the pager physics, the
/// horizontal swipe-to-minimize, the image carousel — don't rebuild every frame.
///
/// All the morph math lives here and in [CardMaximizeChrome]; UI just consumes
/// the progress.
class CardMaximizeController {
  /// 0 = floating rounded card, 1 = fullscreen. Drive the chrome + scrim.
  final ValueNotifier<double> progress = ValueNotifier(0.0);

  /// True once [progress] crosses the fullscreen threshold.
  final ValueNotifier<bool> fullscreen = ValueNotifier(false);

  // How far you have to scroll to fully maximize. Roughly in sync with the image
  // header going edge-to-edge, so the two read as one motion.
  double get _distance => 120.h;

  /// Feed the active page's scroll offset; updates [progress] and [fullscreen].
  void updateFromOffset(double offset) {
    progress.value = (offset / _distance).clamp(0.0, 1.0);
    final fs = progress.value >= 0.9;
    if (fs != fullscreen.value) fullscreen.value = fs;
  }

  void dispose() {
    progress.dispose();
    fullscreen.dispose();
  }
}

/// The per-page card chrome that morphs with [progress]: side margins, corner
/// radius, drop shadow and width all lerp from "floating card" to "fullscreen",
/// and off-centre neighbour pages fade out as the centred one maximizes.
///
/// Pass the page content as [child] (built once); only this thin chrome layer
/// repaints per frame.
class CardMaximizeChrome extends StatelessWidget {
  const CardMaximizeChrome({
    super.key,
    required this.progress,
    required this.isCurrent,
    required this.child,
  });

  /// The active page's maximize progress (shared across pages so neighbours can
  /// fade in sync).
  final ValueListenable<double> progress;

  /// Only the centred page maximizes; neighbours stay as cards and only peek.
  final bool isCurrent;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, maximize, child) {
        final m = isCurrent ? maximize : 0.0;
        // Top margin floats the card 6.h below the status bar; the bottom margin
        // floats it the same 6.h ABOVE the system navigation (bottomInset). At
        // fullscreen the bottom settles to just the inset so the bar still clears
        // the navigation. The page's own bottom safe-area padding is stripped by
        // the caller so the add-to-cart bar sits flush at the card's edge.
        final tPad = lerpDouble(topInset + 6.h, 0.0, m)!;
        final bPad = lerpDouble(bottomInset + 6.h, bottomInset, m)!;
        final radius = lerpDouble(16.r, 0.0, m)!;
        // The pager viewport is < 1.0, which would otherwise shrink the card.
        // Force a fixed card-view width (screen minus a 16.w margin each side)
        // with an OverflowBox; it grows to the full screen as it maximizes.
        final screenW = MediaQuery.sizeOf(context).width;
        final cardW = lerpDouble(screenW - 32.w, screenW, m)!;
        Widget card = Padding(
          padding: EdgeInsets.only(top: tPad, bottom: bPad),
          child: OverflowBox(
            minWidth: cardW,
            maxWidth: cardW,
            alignment: Alignment.center,
            child: PhysicalModel(
              color: Colors.transparent,
              // Shadow eases out as it fills the screen — a fullscreen page has
              // nothing to cast a shadow onto.
              elevation: lerpDouble(14.0, 0.0, m)!,
              shadowColor: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(radius),
              // antiAliasWithSaveLayer (not plain antiAlias) so the rounded clip
              // also applies to the add-to-cart bar's BackdropFilter. The
              // RepaintBoundary child caches the result, so the saveLayer only
              // re-runs mid-transition.
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: child,
            ),
          ),
        );
        if (!isCurrent) {
          // Neighbours peek at rest to hint the list is swipeable, then fade out
          // as the centred card maximizes — so no neighbour edges show fullscreen.
          final opacity = (1.0 - maximize).clamp(0.0, 1.0);
          if (opacity <= 0.0) return const SizedBox.shrink();
          card = Opacity(opacity: opacity, child: card);
        }
        return card;
      },
      child: child,
    );
  }
}
