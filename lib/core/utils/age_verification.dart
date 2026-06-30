import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Age-restricted (alcohol / tobacco) gating.
//
// A single source of truth for (a) detecting whether a product is age-
// restricted and (b) asking the user — at most once per app session — to
// confirm they are of legal age before such an item is added to the cart.
//
// Both the product listing cards and the product detail screen import and use
// the helpers here, so the detection rules and the dialog live in exactly one
// place.
// ---------------------------------------------------------------------------

/// Category id for the dedicated alcohol category on the backend.
const String kAlcoholCategoryId = '670e8b316c080aecbd5a2dce';

/// Keywords that mark a product as age-restricted when found (case-insensitive)
/// in the product name or keyword field. Extend this list as the catalogue
/// grows — it is intentionally the single knob for keyword-based detection.
const List<String> kRestrictedKeywords = [
  'alcohol',
  'beer',
  'wine',
  'whisky',
  'whiskey',
  'vodka',
  'rum',
  'gin',
  'tequila',
  'brandy',
  'liquor',
  'cigarette',
  'cigar',
  'tobacco',
  'beedi',
  'khaini',
];

/// True when [product] is age-restricted, i.e. EITHER it lives in the alcohol
/// category OR its name/keyword contains one of [kRestrictedKeywords].
///
/// Note: the product model carries a list of [ProductData.categoryIds] and a
/// free-text [ProductData.keyword] rather than a single `categoryId` /
/// `category.name`, so we match against those.
bool isRestrictedProduct(ProductData product) {
  // 1. Dedicated alcohol category.
  if (product.categoryIds?.contains(kAlcoholCategoryId) == true) {
    return true;
  }

  // 2. Keyword match on the product name + keyword text.
  final haystack =
      '${product.name ?? ''} ${product.keyword ?? ''}'.toLowerCase();
  for (final word in kRestrictedKeywords) {
    if (haystack.contains(word)) return true;
  }
  return false;
}

/// Session-scoped age-verification state.
///
/// The flag is reset to `false` on every cold start (see [resetForColdStart],
/// called from `main()`), set to `true` the first time the user confirms, and
/// kept in memory for the rest of the session so neither the listing cards nor
/// the detail screen re-ask. There is deliberately no timestamp-based re-ask.
class AgeVerification {
  AgeVerification._();

  static const String _prefKey = 'age_verified_session';

  /// In-memory fast path so the add-to-cart action doesn't await disk on every
  /// tap once the user has verified this session.
  static bool _verifiedInSession = false;

  /// Clear any persisted flag. Call once during app initialization (cold
  /// start) so each fresh app launch asks again at most once.
  static Future<void> resetForColdStart() async {
    _verifiedInSession = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
  }

  static Future<bool> _isVerified() async {
    if (_verifiedInSession) return true;
    final prefs = await SharedPreferences.getInstance();
    final verified = prefs.getBool(_prefKey) ?? false;
    _verifiedInSession = verified;
    return verified;
  }

  static Future<void> _markVerified() async {
    _verifiedInSession = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
}

/// Gate an add-to-cart action for a possibly-restricted product.
///
/// Returns `true` if the caller may proceed to add the item:
///   • the product isn't restricted, OR
///   • the user has already verified this session, OR
///   • the user confirms they are of legal age in the dialog shown here.
///
/// Returns `false` only when the product is restricted and the user cancels /
/// dismisses the dialog — in which case the caller must NOT add the item.
Future<bool> ensureAgeVerified(
  BuildContext context,
  ProductData product,
) async {
  if (!isRestrictedProduct(product)) return true;
  if (await AgeVerification._isVerified()) return true;
  if (!context.mounted) return false;

  // Strong buzz the moment the gate opens — this is a validation checkpoint,
  // so it should feel more deliberate than a normal add-to-cart tick.
  AppHaptics.heavy();

  final confirmed = await _showAgeVerificationDialog(context) ?? false;
  if (confirmed) await AgeVerification._markVerified();
  return confirmed;
}

// ---------------------------------------------------------------------------
// The age-gate dialog — playful, on-brand, and dismissible.
//
// Pops in with a gentle scale/fade, shows a festive gradient header with a
// softly bobbing wine-glass badge, friendly copy, and a "we'll only ask once"
// reassurance chip. Tap-outside / "Not now" returns false; confirming returns
// true.
// ---------------------------------------------------------------------------
Future<bool?> _showAgeVerificationDialog(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Age check',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => const _AgeGateDialog(),
    transitionBuilder: (_, anim, __, child) {
      final pop = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.75 + 0.25 * pop.value, // subtle overshoot "pop"
          child: child,
        ),
      );
    },
  );
}

class _AgeGateDialog extends StatefulWidget {
  const _AgeGateDialog();

  @override
  State<_AgeGateDialog> createState() => _AgeGateDialogState();
}

class _AgeGateDialogState extends State<_AgeGateDialog>
    with SingleTickerProviderStateMixin {
  // Slow, reversing loop that gives the wine-glass badge a little life.
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 360.w),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 18.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Title ────────────────────────────────
                      Text(
                        'Quick age check 🍷',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: vc.onSurface,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // ── Message ──────────────────────────────
                      Text(
                        "This item is age-restricted. Tap below to confirm "
                        "you're 18 or older — the legal drinking age in Nepal.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: vc.onSurfaceMuted,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // ── "Only once" reassurance chip ─────────
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: 12.w, vertical: 6.h),
                      //   decoration: BoxDecoration(
                      //     color: vc.surfaceVariant,
                      //     borderRadius: BorderRadius.circular(30.r),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.lock_outline,
                      //           size: 13.sp, color: vc.onSurfaceMuted),
                      //       // SizedBox(width: 6.w),
                      //       // Text(
                      //       //   "We'll only ask once",
                      //       //   style: TextStyle(
                      //       //     fontSize: 11.sp,
                      //       //     fontWeight: FontWeight.w600,
                      //       //     color: vc.onSurfaceMuted,
                      //       //   ),
                      //       // ),
                      //     ],
                      //   ),
                      // ),

                      SizedBox(height: 20.h),

                      // ── Confirm (primary) ────────────────────
                      _GateButton(
                        label: "Yes, I'm 18 or older",
                        icon: Icons.check_circle_rounded,
                        gradient: const LinearGradient(
                          colors: AppColor.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        textColor: Colors.white,
                        onTap: () => Navigator.pop(context, true),
                      ),

                      SizedBox(height: 4.h),

                      // ── Decline (secondary) ──────────────────
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Not now',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: vc.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Festive gradient banner with floating "bubbles" and a bobbing glass badge.
  Widget _buildHeader() {
    return SizedBox(
      height: 116.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Warm, drink-y gradient.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFA94A), Color(0xFFD9663B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox.expand(),
          ),
          // Decorative translucent bubbles.
          Positioned(top: -18.h, right: 26.w, child: _bubble(58)),
          Positioned(bottom: -22.h, left: -12.w, child: _bubble(78)),
          Positioned(top: 26.h, left: 34.w, child: _bubble(14)),
          Positioned(bottom: 20.h, right: 40.w, child: _bubble(10)),
          // Bobbing + tilting beer-mug badge.
          AnimatedBuilder(
            animation: _bob,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_bob.value);
              return Transform.translate(
                offset: Offset(0, -3 + 6 * t),
                child: Transform.rotate(
                  angle: (t - 0.5) * 0.16,
                  child: Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text('🍺', style: TextStyle(fontSize: 30.sp)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, {IconData? icon}) => Container(
        width: size.w,
        height: size.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.16),
        ),
        child: icon == null
            ? null
            : Icon(
                icon,
                size: size.w * 0.5,
                color: Colors.white.withValues(alpha: 0.9),
              ),
      );
}

class _GateButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final Color textColor;
  final VoidCallback onTap;

  const _GateButton({
    required this.label,
    this.icon,
    this.gradient,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: gradient != null
                ? [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 18.sp),
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
