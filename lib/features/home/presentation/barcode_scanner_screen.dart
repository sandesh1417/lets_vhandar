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
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final granted = status.isGranted
        ? true
        : (await Permission.camera.request()).isGranted;
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
              ),
            ),
          ),
        ),

        // "Type your barcode" pill — below header, floating over camera
        if (!_isProcessing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isManualEntry = true);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_alt_outlined,
                          color: Colors.white70, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Type your barcode',
                        style: TextStyle(
                          color: Colors.white70,
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

        // White footer panel
        if (!_isProcessing)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.zero),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/barcode.svg',
                              width: 22.sp,
                              height: 22.sp,
                              colorFilter: ColorFilter.mode(
                                  AppColor.primary, BlendMode.srcIn),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Text(
                              'Scan barcodes, QR codes & product labels',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12.sp,
                                fontFamily: 'Inter',
                              ),
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
              Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64.sp),
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
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white),
                child: const Text('Grant Permission'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header — matches scanner header
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 48.h),

                  // Icon
                  Container(
                    padding: EdgeInsets.all(22.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/barcode.svg',
                      width: 56.w,
                      height: 56.w,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'Enter Barcode Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Type the barcode number printed on the product',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // Input
                  TextField(
                    controller: _manualController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: 3,
                    ),
                    decoration: InputDecoration(
                      hintText: '0 0 0 0 0 0 0 0',
                      hintStyle: TextStyle(
                        color: Colors.white24,
                        fontSize: 20.sp,
                        letterSpacing: 3,
                        fontFamily: 'Inter',
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            BorderSide(color: AppColor.secondary, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 18.h),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Find Product button
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              final code = _manualController.text.trim();
                              if (code.isNotEmpty) _handleBarcode(code);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.secondary,
                        foregroundColor: const Color(0xFF1A1A1A),
                        disabledBackgroundColor:
                            AppColor.secondary.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColor.primary),
                            )
                          : Text(
                              'Find Product',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Or scan instead
                  TextButton.icon(
                    onPressed: () => setState(() => _isManualEntry = false),
                    icon: Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white38, size: 16.sp),
                    label: Text(
                      'Use camera scanner instead',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
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
    canvas.drawLine(Offset(cx - crossLen, cy), Offset(cx + crossLen, cy),
        crossPaint);
    canvas.drawLine(Offset(cx, cy - crossLen), Offset(cx, cy + crossLen),
        crossPaint);
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
