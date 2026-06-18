import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();

  bool _hasPermission = false;
  bool _isPermissionChecked = false;
  bool _isProcessing = false;
  bool _isManualEntry = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    final granted =
        status.isGranted ? true : (await Permission.camera.request()).isGranted;
    setState(() {
      _hasPermission = granted;
      _isPermissionChecked = true;
    });
  }

  // Strip leading zeros — "0012345" → "12345"
  String _normalizeBarcode(String raw) => raw.replaceFirst(RegExp(r'^0+'), '');

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        HapticFeedback.mediumImpact();
        _handleBarcode(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _handleBarcode(String raw) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _cameraController.stop();

    final code = _normalizeBarcode(raw.trim());

    try {
      final repo = locator<ProductRepository>();
      final result = await repo.searchProducts(code, limit: 5);

      if (!mounted) return;

      result.when(
        success: (products) {
          if (products.isEmpty) {
            _showNotFound(code);
          } else {
            context.pushReplacementNamed(
              LVRoute.productDetailScreen.route,
              extra: products.first,
            );
          }
        },
        failure: (_) => _showNotFound(code),
      );
    } catch (_) {
      _showNotFound(code);
    }
  }

  void _showNotFound(String code) {
    if (!mounted) return;
    CustomSnackbar.error(context,
        message: 'No product found for barcode: $code');
    setState(() => _isProcessing = false);
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildBody(),
      ),
    );
  }

  void _showScanningTips(BuildContext context) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScanningTipsSheet(),
    );
  }

  Widget _buildBody() {
    if (!_isPermissionChecked) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (_isManualEntry) {
      return _buildManualEntry();
    }

    return Stack(
      children: [
        // Full-screen camera
        MobileScanner(
          controller: _cameraController,
          onDetect: _onDetect,
        ),

        // Dark overlay with cutout
        _ScannerOverlay(),

        // Top bar — green header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primary.withValues(alpha: 0.92),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    Text(
                      'Scan Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showScanningTips(context),
                          icon: Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _cameraController.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                          icon: Icon(
                            _torchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // "Type your barcode" pill — below header, floating over camera
        if (!_isProcessing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 82.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isManualEntry = true);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(50.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_alt_outlined,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Type your barcode',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Processing indicator
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16.h),
                  Text(
                    'Looking up product...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Footer panel
        if (!_isProcessing)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                      width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/barcode.svg',
                        width: 28.sp,
                        height: 28.sp,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan bar codes, QR Codes, receipts and more',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  "we'd love to hear what you think!  ",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 12.sp,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .pushNamed(LVRoute.feedbackScreen.route),
                                  child: Text(
                                    'Give feedback',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.white54, size: 64.sp),
              SizedBox(height: 16.h),
              Text(
                'Camera permission required\nto scan barcodes',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15.sp,
                    fontFamily: 'Inter'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomElevatedButton(
                onPressed: _checkPermission,
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                text: 'Grant Permission',
              ),
              TextButton(
                onPressed: () => setState(() => _isManualEntry = true),
                child: Text('Enter Manually',
                    style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntry() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? cs.surface : const Color(0xFFF4F6F9);
    final cardColor = cs.surface;
    final inputFill =
        isDark ? cs.surfaceContainerHighest : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primary.withValues(alpha: 0.92),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isManualEntry = false),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    Text(
                      'Enter Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Barcode sample card
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.25 : 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 28.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sample barcode',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Center(
                                child: LayoutBuilder(
                                  builder: (context, constraints) =>
                                      SvgPicture.asset(
                                    'assets/images/barcodesample.svg',
                                    width: constraints.maxWidth * 0.65,
                                    fit: BoxFit.fitWidth,
                                    colorFilter: isDark
                                        ? ColorFilter.mode(
                                            cs.onSurface, BlendMode.srcIn)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Input card
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.25 : 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item barcode number',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              SizedBox(height: 12.h),
                              TextField(
                                controller: _manualController,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 17.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 9779851357358',
                                  hintStyle: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                    fontSize: 15.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                  ),
                                  filled: true,
                                  fillColor: inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                        color: AppColor.primary, width: 1.5),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 16.h),
                                  suffixIcon: Icon(Icons.dialpad_rounded,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.4),
                                      size: 20.sp),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Type the number printed below the barcode on the product label.',
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontSize: 11.sp,
                                  fontFamily: 'Inter',
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search button pinned at bottom
                Container(
                  color: bgColor,
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w,
                      MediaQuery.of(context).padding.bottom + 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: CustomElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              final code = _manualController.text.trim();
                              if (code.isNotEmpty) _handleBarcode(code);
                            },
                      isLoading: _isProcessing,
                      backgroundColor: AppColor.secondary,
                      foregroundColor: Colors.white,
                      loaderSize: 22,
                      text: 'Search',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom scanner frame overlay
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cutoutW = 280.w;
    final cutoutH = 180.h;

    return CustomPaint(
      size: Size.infinite,
      painter: _OverlayPainter(cutoutW: cutoutW, cutoutH: cutoutH),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double cutoutW;
  final double cutoutH;

  _OverlayPainter({required this.cutoutW, required this.cutoutH});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final cx = size.width / 2;
    final cy = size.height / 2 - 40;
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: cutoutW, height: cutoutH);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Corner brackets
    const bracketLen = 24.0;
    const bracketW = 3.0;
    final bracketPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = bracketW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final l = rect.left, r = rect.right, t = rect.top, b = rect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + bracketLen), Offset(l, t), bracketPaint);
    canvas.drawLine(Offset(l, t), Offset(l + bracketLen, t), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(r - bracketLen, t), Offset(r, t), bracketPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + bracketLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(l, b - bracketLen), Offset(l, b), bracketPaint);
    canvas.drawLine(Offset(l, b), Offset(l + bracketLen, b), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(r - bracketLen, b), Offset(r, b), bracketPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - bracketLen), bracketPaint);

    // Center crosshair +
    const crossLen = 14.0;
    const crossW = 1.8;
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = crossW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(cx - crossLen, cy), Offset(cx + crossLen, cy), crossPaint);
    canvas.drawLine(
        Offset(cx, cy - crossLen), Offset(cx, cy + crossLen), crossPaint);
    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Scanning tips bottom sheet ────────────────────────────────────────────────

class _ScanningTipsSheet extends StatelessWidget {
  const _ScanningTipsSheet();

  static const _tips = [
    _Tip(
      title: 'Fill the frame',
      body:
          'Get close and fill the camera view with the barcode, but not so close that it\'s blurry.',
      image: 'assets/images/Fill the frame.svg',
      imageLeft: true,
    ),
    _Tip(
      title: 'Hold Still',
      body:
          'Quick movements make the scanner lose track. Stay still on a code long enough for it to register.',
      image: 'assets/images/Hold Still.svg',
      imageLeft: false,
    ),
    _Tip(
      title: 'Lots of light',
      body:
          'Well lit areas provide better contrast for the scanner. Use the flash if you\'re in a dark area.',
      image: 'assets/images/Lots of light.svg',
      imageLeft: true,
    ),
    _Tip(
      title: 'Find the right code',
      body:
          'The scanner supports barcodes and QR codes. Use your hands to block codes you aren\'t ready to read.',
      image: 'assets/images/Find the right code.svg',
      imageLeft: false,
    ),
    _Tip(
      title: 'Can\'t find an item?',
      body:
          'If you\'re in the store, you can scan the shelf tag to find the item online.',
      image: 'assets/images/Cant FInd an iteam.svg',
      imageLeft: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Scanning tips:',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
              // Tips list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(0, 8.h, 0, 24.h),
                  itemCount: _tips.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: cs.outline.withValues(alpha: 0.2),
                  ),
                  itemBuilder: (_, i) => _TipRow(tip: _tips[i]),
                ),
              ),
              // Dismiss button — fixed at bottom with top border
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(
                    top: BorderSide(
                        color: cs.outline.withValues(alpha: 0.2), width: 1),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: CustomElevatedButton(
                    onPressed: () => context.pop(),
                    backgroundColor: AppColor.secondary,
                    foregroundColor: Colors.white,
                    text: 'Dismiss',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tip {
  final String title;
  final String body;
  final String image;
  final bool imageLeft;
  const _Tip({
    required this.title,
    required this.body,
    required this.image,
    required this.imageLeft,
  });
}

class _TipRow extends StatelessWidget {
  final _Tip tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final img = Container(
      width: 90.w,
      height: 90.w,
      margin: EdgeInsets.all(16.w),
      child: SvgPicture.asset(
        tip.image,
        fit: BoxFit.contain,
      ),
    );

    final text = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h).copyWith(
          left: tip.imageLeft ? 0 : 16.w,
          right: tip.imageLeft ? 16.w : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              tip.body,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                color: cs.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: tip.imageLeft ? [img, text] : [text, img],
    );
  }
}
