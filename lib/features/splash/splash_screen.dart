import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/local/shared_preferences_services.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/app_info.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:path_parsing/path_parsing.dart';

// ── SVG path data for the V mark ──────────────────────────────────────────
const _vPathData =
    'M588 124.466C588 148.228 586.209 171.574 582.756 194.368C575.578 241.7 561.23 286.664 540.847 328.132C513.151 384.528 474.295 434.445 427.166 475H273.678L258.739 424.116L230.562 328.132L191.291 194.368H104.116L99.4639 178.535L61 47.508H298.33L313.054 97.6722L341.446 194.368L380.717 328.132L381.237 329.9C381.716 329.316 382.188 328.724 382.643 328.132C413.218 289.64 435.312 244.117 446.119 194.368C451.01 171.846 453.584 148.452 453.584 124.466C453.584 98.0883 450.467 72.4461 444.584 47.876L445.567 47.508L571.062 0C575.387 15.5213 578.928 31.3706 581.629 47.508C585.818 72.5341 588 98.2483 588 124.466Z';

// ── V fill + letters SVGs (same 690×634 viewBox) ─────────────────────────
const _vFillSvg = '''
<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="$_vPathData" fill="#F5B237"/>
</svg>''';

const _svgLetters = [
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M111.803 544.311C111.803 578.442 98.2902 609.425 76.3116 632.231H29.4869L0.015625 532.202H42.632L62.4417 596.498C62.6445 596.245 62.8435 595.992 63.0426 595.735C72.7868 580.976 78.458 563.305 78.458 544.311C78.458 540.275 78.2007 536.296 77.705 532.395L110.949 529.531C111.052 530.419 111.803 540.226 111.803 544.311Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M209.319 570.488C207.992 565.307 205.348 560.89 201.376 557.255C197.404 553.51 192.278 551.629 185.989 551.629C182.018 551.629 178.328 552.183 174.91 553.283C166.749 556.037 160.905 560.945 157.379 568.006L159.033 525L119.816 528.526L124.133 632.352H154.571L156.225 594.145C156.779 583.002 160.305 577.44 166.813 577.44C169.457 577.44 171.33 578.54 172.438 580.748C173.538 582.957 174.42 587.365 175.083 593.981L178.718 632.352H207.665C210.201 612.394 211.473 598.389 211.473 590.337C211.473 582.284 210.755 575.668 209.319 570.488Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M249.724 633.995C241.235 633.995 234.228 631.513 228.72 626.551C223.322 621.589 220.613 614.591 220.613 605.548C220.613 596.505 223.703 589.779 229.874 585.699C236.045 581.509 243.489 579.41 252.205 579.41C260.92 579.41 268.473 580.791 274.862 583.545C273.426 574.393 267.637 569.812 257.494 569.812C252.859 569.812 247.133 570.748 240.29 572.621L236.154 557.734C246.079 553.653 256.167 551.617 266.428 551.617C295.984 551.617 310.761 564.186 310.761 589.334C310.761 597.932 309.771 609.847 307.78 625.061L306.953 632.341H279.661L278.67 623.243C271.172 630.414 261.52 633.995 249.724 633.995ZM264.61 613.482C269.573 613.482 273.817 612.101 277.343 609.347L276.353 598.432C273.599 596.559 270.509 595.623 267.091 595.623C263.674 595.623 261.03 596.45 258.821 598.104C256.722 599.759 255.676 601.794 255.676 604.221C255.676 606.648 256.503 608.802 258.158 610.674C259.812 612.546 261.966 613.482 264.61 613.482Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M383.134 551.617C390.85 551.617 397.466 554.871 402.983 561.378C408.609 567.885 411.417 576.374 411.417 586.853C411.417 597.332 410.145 612.382 407.609 632.341H378.662L375.354 595.287C374.254 583.49 371.055 577.592 365.757 577.592C359.468 577.592 356.105 583.545 355.669 595.46L354.514 632.35H324.077L320.605 553.944H357.986L357.323 568.004C357.877 566.904 359.14 565.195 361.131 562.878C363.112 560.56 365.048 558.688 366.92 557.252C371.773 553.498 377.172 551.626 383.134 551.626V551.617Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M420.57 591.327C420.57 583.72 421.615 577.158 423.715 571.642C425.923 566.125 428.786 561.99 432.313 559.236C438.82 554.165 446.045 551.629 453.979 551.629C457.951 551.629 461.586 552.456 464.895 554.11C468.312 555.655 470.684 557.255 472.011 558.909L473.992 561.226L472.674 525H510.391L505.929 632.352H481.117L478.309 621.601C471.693 629.762 463.531 633.843 453.825 633.843C444.227 633.952 436.293 630.371 430.004 623.091C423.715 615.812 420.579 605.224 420.579 591.336L420.57 591.327ZM464.567 573.796C458.06 573.796 454.806 580.412 454.806 593.645C454.806 596.071 454.97 598.389 455.306 600.588C455.643 602.788 456.633 605.105 458.287 607.532C459.941 609.959 462.368 611.167 465.567 611.167C468.766 611.167 471.193 609.404 472.847 605.878C474.61 602.243 475.492 598.162 475.492 593.636C475.492 580.403 471.856 573.787 464.576 573.787L464.567 573.796Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M548.548 633.995C540.059 633.995 533.052 631.513 527.544 626.551C522.137 621.589 519.438 614.591 519.438 605.548C519.438 596.505 522.528 589.779 528.699 585.699C534.87 581.509 542.313 579.41 551.029 579.41C559.745 579.41 567.297 580.791 573.686 583.545C572.25 574.393 566.461 569.812 556.318 569.812C551.683 569.812 545.957 570.748 539.114 572.621L534.979 557.734C544.903 553.653 554.991 551.617 565.252 551.617C594.808 551.617 609.586 564.186 609.586 589.334C609.586 597.932 608.595 609.847 606.605 625.061L605.778 632.341H578.485L577.494 623.243C569.996 630.414 560.344 633.995 548.548 633.995ZM563.435 613.482C568.397 613.482 572.641 612.101 576.167 609.347L575.177 598.432C572.423 596.559 569.333 595.623 565.916 595.623C562.498 595.623 559.854 596.45 557.645 598.104C555.546 599.759 554.501 601.794 554.501 604.221C554.501 606.648 555.328 608.802 556.982 610.674C558.636 612.546 560.79 613.482 563.435 613.482Z" fill="white"/></svg>''',
  '''<svg width="690" height="634" viewBox="0 0 690 634" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M656.16 564.686C662.004 555.971 669.229 551.617 677.827 551.617C681.907 551.617 685.652 552.608 689.078 554.598L685.107 581.727C680.699 578.637 675.736 577.092 670.22 577.092C664.703 577.092 661.34 579.301 659.468 583.708C658.368 586.462 657.65 589.116 657.314 591.652L654.17 632.341H624.396L619.434 553.935H652.016L656.151 564.686H656.16Z" fill="white"/></svg>''',
];

// ── Build the V Flutter Path (scaled to fit render size) ─────────────────
Path _buildVPath(Size size) {
  final raw = Path();
  writeSvgPathDataToPath(_vPathData, _PathReceiver(raw));
  // Original viewBox: 690×634, only V mark reaches ~y=475
  final scaleX = size.width / 690;
  final scaleY = size.height / 634;
  return raw.transform(
    Matrix4.diagonal3Values(scaleX, scaleY, 1).storage,
  );
}

// PathReceiver bridges path_parsing → Flutter Path
class _PathReceiver extends PathProxy {
  final Path _path;
  _PathReceiver(this._path);
  @override
  void close() => _path.close();
  @override
  void cubicTo(
          double x1, double y1, double x2, double y2, double x, double y) =>
      _path.cubicTo(x1, y1, x2, y2, x, y);
  @override
  void lineTo(double x, double y) => _path.lineTo(x, y);
  @override
  void moveTo(double x, double y) => _path.moveTo(x, y);
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // V stroke draw: 0→1200ms
  late final Animation<double> _strokeProgress;
  // V fill snap: 1200→1350ms
  late final Animation<double> _fillOpacity;
  // Letters: v(1250) h(1310) a(1370) n(1430) d(1490) a(1550) r(1610), each 160ms
  late final List<Animation<double>> _letterFade;
  late final List<Animation<Offset>> _letterSlide;
  // Tagline pill: 1800→2150ms
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  // Footer: 2200→2500ms
  late final Animation<double> _footerFade;

  static const int _dur = 2800;
  double _t(int ms) => ms / _dur;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light,
    //   statusBarBrightness: Brightness.dark,
    //   systemNavigationBarColor: Color(0xFF0B754E),
    //   systemNavigationBarIconBrightness: Brightness.light,
    // ));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: _dur));

    _strokeProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Interval(_t(0), _t(1200), curve: Curves.easeInOut)),
    );

    _fillOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Interval(_t(1200), _t(1360), curve: Curves.easeIn)),
    );

    _letterFade = [];
    _letterSlide = [];
    final starts = [1250, 1310, 1370, 1430, 1490, 1550, 1610];
    for (int i = 0; i < 7; i++) {
      final s = _t(starts[i]);
      final e = _t(starts[i] + 160);
      _letterFade.add(Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(s, e.clamp(0, 1), curve: Curves.easeOut)),
      ));
      _letterSlide.add(
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(s, e.clamp(0, 1),
                  curve: const ElasticOutCurve(0.75))),
        ),
      );
    }

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Interval(_t(1800), _t(2150), curve: Curves.easeOut)),
    );
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Interval(_t(1800), _t(2150), curve: Curves.easeOutCubic)),
    );

    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: Interval(_t(2200), _t(2500), curve: Curves.easeOut)),
    );

    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    //   statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    //   systemNavigationBarColor: isDark ? Colors.black : Colors.white,
    //   systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    // ));
    super.dispose();
  }

  Future<void> _checkSession() async {
    await ref.read(loginProvider.notifier).restoreSession();
    final token = await SessionPreferences().getToken();
    final isGuest = await SessionPreferences().getGuestMode();
    await Future.delayed(const Duration(milliseconds: 3600));
    if (!mounted) return;
    if ((token != null && token.isNotEmpty) || isGuest) {
      ref.read(dashboardIndexProvider.notifier).state = 0;
      context.go(LVRoute.dashboardScreen.route);
    } else {
      context.go(LVRoute.loginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoW = 220.w;
    final logoH = logoW * (634 / 690);

    return Scaffold(
      body: Container(
        color: AppColor.primary,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo area ────────────────────────────────────
                  SizedBox(
                    width: logoW,
                    height: logoH,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, __) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // V stroke with glow (draws using PathMetric)
                            CustomPaint(
                              painter: _VStrokePainter(
                                progress: _strokeProgress.value,
                                size: Size(logoW, logoH),
                              ),
                            ),

                            // V fill — snaps in after stroke completes
                            Opacity(
                              opacity: _fillOpacity.value,
                              child: SvgPicture.string(
                                _vFillSvg,
                                width: logoW,
                                height: logoH,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Letters cascade
                            ...List.generate(
                                7,
                                (i) => FadeTransition(
                                      opacity: _letterFade[i],
                                      child: SlideTransition(
                                        position: _letterSlide[i],
                                        child: SvgPicture.string(
                                          _svgLetters[i],
                                          width: logoW,
                                          height: logoH,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // ── Tagline plain text ────────────────────────────
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _taglineFade,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Text(
                          'Fastest Grocery Delivery App',
                          style: TextStyle(
                            fontFamily: 'Volte', // cspell:ignore Volte
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.secondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Opacity(
                  opacity: _footerFade.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vhandar Merchandise Pvt Ltd',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'v${AppInfo.version}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Draws the V stroke progressively with golden glow ─────────────────────
class _VStrokePainter extends CustomPainter {
  final double progress;
  final Size size;

  _VStrokePainter({required this.progress, required this.size});

  static Path? _cachedPath;
  static Size? _cachedSize;

  Path _getPath() {
    if (_cachedPath != null && _cachedSize == size) return _cachedPath!;
    _cachedPath = _buildVPath(size);
    _cachedSize = size;
    return _cachedPath!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final fullPath = _getPath();
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(0, (s, m) => s + m.length);
    final target = totalLength * progress;

    final drawn = Path();
    double remaining = target;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final take = remaining.clamp(0.0, metric.length);
      drawn.addPath(metric.extractPath(0, take), Offset.zero);
      remaining -= take;
    }

    // Sharp golden stroke
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColor.secondary,
    );
  }

  @override
  bool shouldRepaint(_VStrokePainter old) => old.progress != progress;
}
