import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

splitName({required String fullName}) {
  List<String> parts = fullName.split(" ");
  String firstName = parts[0];
  String lastName = parts[1];
  return [firstName, lastName];
}

/// Centralized navigation helper to handle slugs and full URLs from APIs
void navigateToSlug(BuildContext context, String? slug, {bool isBrand = true}) {
  if (slug == null || slug.isEmpty) return;

  // Handle full URLs if they are passed as slugs
  if (slug.contains('vhandar.com/category/')) {
    final extractedSlug = slug.split('vhandar.com/category/').last;
    context.push('/category-detail/$extractedSlug');
    return;
  }

  if (slug.contains('vhandar.com/product/')) {
    // Handle product if needed, e.g., context.push('/product-detail/$extractedSlug');
    return;
  }

  // Normal navigation based on type
  if (isBrand) {
    context.push('/brand-detail/$slug');
  } else {
    context.push('/category-detail/$slug');
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
