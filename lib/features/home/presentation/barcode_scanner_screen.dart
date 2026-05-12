import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/home/providers/search_provider.dart';
import 'package:vhandar/widgets/tff.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  bool _isManualEntry = false;
  final TextEditingController _barcodeController = TextEditingController();
  bool _hasPermission = false;
  bool _isPermissionChecked = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isPermissionChecked = true;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
        _isPermissionChecked = true;
      });
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _performSearch(barcode.rawValue!);
        break;
      }
    }
  }

  void _performSearch(String barcode) {
    ref.read(searchProvider.notifier).search(barcode);
    context.pop(); // Go back to search screen which will show results
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF06412D),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFF06412D),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white, size: 64),
              SizedBox(height: 16.h),
              Text(
                'Camera permission is required\nto scan barcodes',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text('Grant Permission'),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06412D), // Dark green background
      body: Stack(
        children: [
          if (!_isManualEntry) ...[
            MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
            // Custom Scanner Overlay
            Center(
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          
          // Background overlay for manual entry or UI elements
          if (_isManualEntry)
            Container(
              color: const Color(0xFF06412D),
            ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/v.svg',
                        height: 32.h,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  if (_isManualEntry) ...[
                    // Manual Entry UI based on screenshot
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.barcode_reader, color: Colors.white, size: 48),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Enter Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Type the barcode number manually',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CustomTextField(
                      controller: _barcodeController,
                      hintText: 'e.g. 8901234567890',
                      // textColor: Colors.white,
                      // hintStyle: const TextStyle(color: Colors.white38),
                      // keyboardType: TextInputType.number,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFF9B141)),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_barcodeController.text.isNotEmpty) {
                          _performSearch(_barcodeController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A8744), // Olive green from screenshot
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Search Product',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isManualEntry = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56.h),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Back to Scanner',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ] else ...[
                    // Scanning UI
                    const Text(
                      'Scan product barcode',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isManualEntry = true;
                        });
                      },
                      icon: const Icon(Icons.keyboard),
                      label: const Text('Enter Manually'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
