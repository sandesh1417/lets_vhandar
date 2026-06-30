import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
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
  final haystack = '${product.name ?? ''} ${product.keyword ?? ''}'.toLowerCase();
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

  final confirmed = await _showAgeVerificationDialog(context) ?? false;
  if (confirmed) await AgeVerification._markVerified();
  return confirmed;
}

/// The age-gate dialog. Dismissible (tap-outside / Cancel return `null` /
/// `false`); confirming returns `true`. Styled to match the app's existing
/// [CustomDialog] language — rounded card, tinted icon circle, stacked
/// primary + secondary buttons — with a warm amber accent for identity.
Future<bool?> _showAgeVerificationDialog(BuildContext context) {
  const accent = Color(0xFFE8A33D); // warm amber — caution, not alarm

  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (dialogContext) {
      final vc = dialogContext.vColors;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: accent,
                  size: 32.sp,
                ),
              ),

              SizedBox(height: 16.h),

              // ── Title ─────────────────────────────────────
              Text(
                '🍷 Before You Continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: vc.onSurface,
                ),
              ),

              SizedBox(height: 10.h),

              // ── Message ───────────────────────────────────
              Text(
                'This item is age-restricted. By continuing, you confirm '
                'you are 18 years or older — the legal drinking age in Nepal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: vc.onSurfaceMuted,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // ── Confirm (primary) ─────────────────────────
              _AgeDialogButton(
                label: "I'm 18 or older — Continue",
                gradient: const LinearGradient(
                  colors: AppColor.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                textColor: Colors.white,
                onTap: () => Navigator.pop(dialogContext, true),
              ),

              SizedBox(height: 10.h),

              // ── Cancel (secondary) ────────────────────────
              _AgeDialogButton(
                label: 'Cancel',
                backgroundColor: vc.surfaceVariant,
                textColor: vc.onSurface,
                onTap: () => Navigator.pop(dialogContext, false),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AgeDialogButton extends StatelessWidget {
  final String label;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _AgeDialogButton({
    required this.label,
    this.gradient,
    this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
