part of '../order_summary_screen.dart';

// ── Spending Breakdown Card ───────────────────────────────────────────────────
class _SpendingBreakdownCard extends StatelessWidget {
  final double subtotal, delivery, handling, vat, saved, total;
  final VhandarColors vc;
  const _SpendingBreakdownCard({
    required this.subtotal,
    required this.delivery,
    required this.handling,
    required this.vat,
    required this.saved,
    required this.total,
    required this.vc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _BreakdownRow(
              label: 'Subtotal',
              value: 'Rs.${subtotal.toInt()}',
              color: vc.onSurface,
              vc: vc),
          if (delivery > 0)
            _BreakdownRow(
                label: 'Delivery Charges',
                value: '+ Rs.${delivery.toInt()}',
                color: _cPending,
                vc: vc),
          if (handling > 0)
            _BreakdownRow(
                label: 'Handling Charges',
                value: '+ Rs.${handling.toInt()}',
                color: _cPending,
                vc: vc),
          if (vat > 0)
            _BreakdownRow(
                label: 'VAT',
                value: '+ Rs.${vat.toInt()}',
                color: vc.onSurfaceMuted,
                vc: vc),
          if (saved > 0)
            _BreakdownRow(
                label: 'Discounts & Coupons',
                value: '− Rs.${saved.toInt()}',
                color: _cDelivered,
                vc: vc),
          Divider(color: vc.divider, height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: vc.onSurface)),
              Text('Rs.${total.toInt()}',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final VhandarColors vc;
  const _BreakdownRow(
      {required this.label,
      required this.value,
      required this.color,
      required this.vc});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12.sp, color: vc.onSurfaceMuted)),
            Text(value,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}

// ── Day of Week Card ──────────────────────────────────────────────────────────
class _DayOfWeekCard extends StatelessWidget {
  final List<int> counts;
  final VhandarColors vc;
  const _DayOfWeekCard({required this.counts, required this.vc});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.fold(0, (m, v) => v > m ? v : m);
    final busiestIdx = maxCount > 0 ? counts.indexOf(maxCount) : -1;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (busiestIdx >= 0) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      color: AppColor.primary, size: 13.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'You order most on ${_days[busiestIdx]}s',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final count = counts[i];
              final pct = maxCount > 0 ? count / maxCount : 0.0;
              final isMax = i == busiestIdx;
              final barColor = isMax
                  ? AppColor.primary
                  : AppColor.primary.withValues(alpha: 0.35);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (count > 0)
                    Text('$count',
                        style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: barColor)),
                  SizedBox(height: 3.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 28.w,
                    height: pct > 0 ? (pct * 72.h).clamp(6.h, 72.h) : 6.h,
                    decoration: BoxDecoration(
                      color: pct > 0 ? barColor : vc.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isMax ? AppColor.primary : vc.onSurfaceMuted,
                      fontWeight: isMax ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Top Products Card ─────────────────────────────────────────────────────────
class _TopProductsCard extends StatelessWidget {
  final List<({String name, int qty, double spent})> products;
  final VhandarColors vc;
  const _TopProductsCard({required this.products, required this.vc});

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];

  @override
  Widget build(BuildContext context) {
    final maxQty = products.isEmpty ? 1 : products.first.qty;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: List.generate(products.length, (i) {
          final p = products[i];
          final color = _colors[i % _colors.length];
          final pct = maxQty > 0 ? p.qty / maxQty : 0.0;
          final isLast = i == products.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: color)),
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Text(p.name,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: vc.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8.w),
                    Text('×${p.qty}',
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    SizedBox(width: 10.w),
                    Text('Rs.${p.spent.toInt()}',
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface)),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4.h,
                    backgroundColor: color.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
