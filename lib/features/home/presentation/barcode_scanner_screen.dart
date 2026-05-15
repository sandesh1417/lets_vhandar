import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_appbar.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/tff.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
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
    debugPrint('Barcode Scanned: $barcode');
    ref.read(searchProvider.notifier).search(barcode);
    context.pushReplacementNamed(LVRoute.searchScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      isScrollable: true,
      appBar: CustomScreenHeader(
        title: _isManualEntry ? 'Enter Barcode' : 'Scan Barcode',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isPermissionChecked) {
      return SizedBox(
        height: 0.8.sh,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission && !_isManualEntry) {
      return SizedBox(
        height: 0.8.sh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.grey, size: 64.sp),
              SizedBox(height: 16.h),
              Text(
                'Camera permission is required\nto scan barcodes',
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Grant Permission'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isManualEntry = true;
                  });
                },
                child: Text('Enter Manually Instead',
                    style: TextStyle(color: AppColor.primary)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isManualEntry) _buildManualEntryUI() else _buildScannerUI(),
        ],
      ),
    );
  }

  Widget _buildScannerUI() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Text(
          'Align the barcode within the frame',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 40.h),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 320.w,
              height: 320.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
              ),
            ),
            // Scanner Overlay Frame
            Container(
              width: 260.w,
              height: 200.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.primary, width: 3),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 60.h),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isManualEntry = true;
            });
          },
          icon: const Icon(Icons.edit),
          label: const Text('Enter Barcode Manually'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary.withOpacity(0.1),
            foregroundColor: AppColor.primary,
            elevation: 0,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryUI() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child:
              Icon(Icons.barcode_reader, color: AppColor.primary, size: 48.sp),
        ),
        SizedBox(height: 32.h),
        CustomTextField(
          controller: _barcodeController,
          hintText: 'Enter barcode number',
          // keyboardType: TextInputType.number,
          autofocus: true,
        ),
        SizedBox(height: 32.h),
        ElevatedButton(
          onPressed: () {
            if (_barcodeController.text.isNotEmpty) {
              _performSearch(_barcodeController.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
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
        TextButton(
          onPressed: () {
            setState(() {
              _isManualEntry = false;
            });
          },
          child: Text(
            'Back to Scanner',
            style:
                TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
