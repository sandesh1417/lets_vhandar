import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getBadgeConfig(status, isDark);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: config.textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            _displayLabel(status),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  static String _displayLabel(String status) {
    switch (status.toLowerCase()) {
      case 'shipped':
      case 'shipping': return 'ON THE WAY';
      default: return status.toUpperCase();
    }
  }

  _BadgeConfig _getBadgeConfig(String status, bool isDark) {
    final s = status.toLowerCase();
    // Green — completed/paid
    if (s == 'delivered' || s == 'paid' || s == 'success') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.35) : const Color(0xFFE8F5E9),
        textColor: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      );
    }
    // Blue — in transit
    if (s == 'shipped' || s == 'shipping') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF0D47A1).withValues(alpha: 0.35) : const Color(0xFFE3F2FD),
        textColor: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0),
      );
    }
    // Red — cancelled/failed
    if (s == 'cancelled' || s == 'failed') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF7F0000).withValues(alpha: 0.35) : const Color(0xFFFFEBEE),
        textColor: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
      );
    }
    // Purple — returned
    if (s == 'returned') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF4A148C).withValues(alpha: 0.35) : const Color(0xFFF3E5F5),
        textColor: isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A),
      );
    }
    // Teal — refunded
    if (s == 'refunded') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF004D40).withValues(alpha: 0.35) : const Color(0xFFE0F2F1),
        textColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00695C),
      );
    }
    // Yellow — pending/processing
    if (s == 'pending' || s == 'processing') {
      return _BadgeConfig(
        backgroundColor: isDark ? const Color(0xFF4A3700).withValues(alpha: 0.5) : const Color(0xFFFFFDE7),
        textColor: isDark ? const Color(0xFFFFCC02) : const Color(0xFFF9A825),
      );
    }
    return _BadgeConfig(
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      textColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
    );
  }
}

class _BadgeConfig {
  final Color backgroundColor;
  final Color textColor;

  _BadgeConfig({required this.backgroundColor, required this.textColor});
}
