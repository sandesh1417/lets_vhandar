import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

splitName({required String fullName}) {
  List<String> parts = fullName.split(" ");
  String firstName = parts[0];
  String lastName = parts[1];
  return [firstName, lastName];
}

/// Centralized navigation helper to handle slugs and full URLs from APIs
Future<void> navigateToSlug(BuildContext context, String? slug,
    {bool isBrand = true}) async {
  if (slug == null || slug.isEmpty) return;

  // Category URL
  if (slug.contains('vhandar.com/category/')) {
    final s = slug.split('vhandar.com/category/').last;
    if (context.mounted) context.push('/category-detail/$s');
    return;
  }

  // Brand URL
  if (slug.contains('vhandar.com/brand/')) {
    final s = slug.split('vhandar.com/brand/').last;
    if (context.mounted) context.push('/brand-detail/$s');
    return;
  }

  // Product URL — extend when product-detail route is ready
  if (slug.contains('vhandar.com/product/')) return;

  // Any other external URL → open in browser
  if (slug.startsWith('http://') || slug.startsWith('https://')) {
    final uri = Uri.parse(slug);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }

  // Plain slug — route by type
  if (context.mounted) {
    if (isBrand) {
      context.push('/brand-detail/$slug');
    } else {
      context.push('/category-detail/$slug');
    }
  }
}

class TenDigitInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only up to 10 digits
    if (newValue.text.length > 10) {
      return oldValue;
    }

    // Check if the new input contains only digits
    final RegExp regex = RegExp(r'^\d{0,10}$');
    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }

    // If it doesn't match, keep the old value
    return oldValue;
  }
}
