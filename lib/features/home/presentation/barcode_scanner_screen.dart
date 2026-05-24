import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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

        // Top bar
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hint text
        Align(
          alignment: const Alignment(0, 0.25),
          child: Text(
            'Align barcode within the frame',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.sp,
              fontFamily: 'Inter',
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

        // Bottom buttons
        if (!_isProcessing)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: GestureDetector(
                  onTap: () => setState(() => _isManualEntry = true),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_outlined,
                            color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Enter Barcode Manually',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
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
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.qr_code_2_rounded,
                        color: AppColor.secondary, size: 48.sp),
                  ),
                  SizedBox(height: 32.h),
                  TextField(
                    controller: _manualController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'Enter barcode number',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontFamily: 'Inter'),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColor.secondary),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
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
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Corner brackets
    const bracketLen = 24.0;
    const bracketW = 3.0;
    final bracketPaint = Paint()
      ..color = AppColor.secondary
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
