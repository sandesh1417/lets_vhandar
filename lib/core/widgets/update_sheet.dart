import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart' as version_lib;

const _androidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.vhandar.app';
const _iosStoreUrl = 'https://apps.apple.com/app/id'; // TODO: add App Store ID

// ---------------------------------------------------------------------------
// Shared branded card
// ---------------------------------------------------------------------------

class UpdateCard extends StatelessWidget {
  const UpdateCard({
    required this.isForced,
    required this.onUpdate,
    this.onLater,
    super.key,
  });

  final bool isForced;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              isForced ? 'Update Required' : 'New Update Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              isForced
                  ? 'This version is no longer supported.\nPlease update to continue using Vhandar.'
                  : 'A new version of Vhandar is available.\nUpdate now for the latest features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurfaceMuted,
                height: 1.6,
              ),
            ),
            SizedBox(height: 24.h),

            // Update Now button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: onUpdate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Update Now'),
              ),
            ),

            // Later button (optional only)
            if (!isForced && onLater != null) ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: TextButton(
                  onPressed: onLater,
                  style: TextButton.styleFrom(
                    foregroundColor: vc.onSurfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Later'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Force update — Stack overlay (above Navigator, no dismiss)
// ---------------------------------------------------------------------------

class ForceUpdateGate extends StatelessWidget {
  const ForceUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: UpdateCard(
                  isForced: true,
                  onUpdate: () => _openStore(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final uri = Uri.parse(isIos ? _iosStoreUrl : _androidStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ---------------------------------------------------------------------------
// Optional update — lives inside Navigator, shows custom dialog
// ---------------------------------------------------------------------------

class OptionalUpdateListener extends StatefulWidget {
  const OptionalUpdateListener({required this.child, super.key});

  final Widget child;

  @override
  State<OptionalUpdateListener> createState() => _OptionalUpdateListenerState();
}

class _OptionalUpdateListenerState extends State<OptionalUpdateListener> {
  bool _shown = false;

  late final Upgrader _upgrader = Upgrader(
    durationUntilAlertAgain: const Duration(days: 2),
    debugDisplayAlways: kDebugMode, // TODO: remove before release
    storeController: kDebugMode
        ? UpgraderStoreController(
            onAndroid: () => _MockUpgraderStore(),
            oniOS: () => _MockUpgraderStore(),
          )
        : null,
  );

  @override
  void initState() {
    super.initState();
    _upgrader.initialize().then((_) {
      if (!mounted || _shown) return;
      if (_upgrader.shouldDisplayUpgrade()) {
        _shown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showDialog();
        });
      }
    });
  }

  Future<void> _showDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: UpdateCard(
            isForced: false,
            onUpdate: () async {
              Navigator.of(dialogContext).pop();
              await _openStore();
            },
            onLater: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final uri = Uri.parse(isIos ? _iosStoreUrl : _androidStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// Mock store for debug testing (no Play Store listing needed)
// ---------------------------------------------------------------------------

class _MockUpgraderStore extends UpgraderStore {
  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required version_lib.Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    return UpgraderVersionInfo(
      installedVersion: installedVersion,
      appStoreVersion: version_lib.Version(
        installedVersion.major,
        installedVersion.minor,
        installedVersion.patch + 1,
      ),
      appStoreListingURL: _androidStoreUrl,
    );
  }
}
