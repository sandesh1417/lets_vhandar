import 'package:flutter/widgets.dart';

/// A number that smoothly tweens whenever its [value] changes, instead of
/// popping to the new figure. Use it for prices, cart subtotals, point
/// balances — anything that updates in front of the user.
///
/// ```dart
/// AnimatedCounter(
///   value: subtotal,
///   prefix: 'Rs. ',
///   fractionDigits: 2,
///   style: KTextStyle.bold16,
/// )
/// ```
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int fractionDigits;

  /// Insert thousands separators (e.g. 1,234.50).
  final bool thousandsSeparator;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.thousandsSeparator = true,
    this.style,
    this.duration = const Duration(milliseconds: 550),
    this.curve = Curves.easeOutCubic,
  });

  String _format(double v) {
    final fixed = v.toStringAsFixed(fractionDigits);
    if (!thousandsSeparator) return '$prefix$fixed$suffix';

    final parts = fixed.split('.');
    final intPart = parts.first;
    final neg = intPart.startsWith('-');
    final digits = neg ? intPart.substring(1) : intPart;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final grouped = '${neg ? '-' : ''}$buf';
    final withDecimals = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    return '$prefix$withDecimals$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Tweening from the *current* value is handled by TweenAnimationBuilder:
      // when `value` changes it animates from the previous end to the new one.
      tween: Tween<double>(begin: value, end: value),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => Text(_format(v), style: style),
    );
  }
}
