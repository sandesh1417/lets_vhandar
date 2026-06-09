import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _androidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.vhandar.app';
const _iosStoreUrl =
    'https://apps.apple.com/app/id'; // TODO: add App Store ID when published

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
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Update Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A new version of Vhandar is available. '
                            'Please update to continue using the app.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openStore(context),
                              child: const Text('Update Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
