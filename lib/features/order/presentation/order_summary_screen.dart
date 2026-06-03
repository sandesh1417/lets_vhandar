import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';

// ── Date range filter ─────────────────────────────────────────────────────────
enum _DR { all, today, yesterday, week, month, custom }

extension _DRX on _DR {
  String get label => const {
        _DR.all: 'All',
        _DR.today: 'Today',
        _DR.yesterday: 'Yesterday',
        _DR.week: 'This Week',
        _DR.month: 'This Month',
        _DR.custom: 'Custom',
      }[this]!;
}

class _W {
  final DateTime from;
  final DateTime to;
  const _W(this.from, this.to);
}

enum _ChartMode { daily, weekly, monthly }

// ── Status colours ─────────────────────────────────────────────────────────────
const _cDelivered = Color(0xFF10B981);
const _cPending = Color(0xFFF59E0B);
const _cProcessing = Color(0xFF6366F1);
const _cShipped = Color(0xFF0EA5E9);
const _cCancelled = Color(0xFFF43F5E);

typedef _ChartPoint = ({String label, double amount, int orders});

class OrderSummaryScreen extends StatefulWidget {
  final OrderState state;
  const OrderSummaryScreen({super.key, required this.state});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  _DR _range = _DR.all;
  DateTimeRange? _custom;

  // ── Date window ──────────────────────────────────────────────────────────────
  _W get _window {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    switch (_range) {
      case _DR.all:
        return _W(DateTime(2000), tomorrow);
      case _DR.today:
        return _W(today, tomorrow);
      case _DR.yesterday:
        return _W(today.subtract(const Duration(days: 1)), today);
      case _DR.week:
        return _W(today.subtract(Duration(days: today.weekday - 1)), tomorrow);
      case _DR.month:
        return _W(DateTime(now.year, now.month, 1), tomorrow);
      case _DR.custom:
        if (_custom != null) {
          return _W(_custom!.start, _custom!.end.add(const Duration(days: 1)));
        }
        return _W(today, tomorrow);
    }
  }

  List<OrderData> get _filtered {
    final w = _window;
    return widget.state.orders.where((o) {
      final d = o.createdAt;
      return d != null && !d.isBefore(w.from) && d.isBefore(w.to);
    }).toList()
      ..sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
  }

  double _saved(OrderData o) =>
      (o.totalDiscount?.toDouble() ?? 0) + (o.couponDiscount?.toDouble() ?? 0);

  // ── Smart chart mode ─────────────────────────────────────────────────────────
  _ChartMode get _chartMode {
    switch (_range) {
      case _DR.all:
        return _ChartMode.monthly;
      case _DR.today:
      case _DR.yesterday:
      case _DR.week:
      case _DR.month:
        return _ChartMode.daily;
      case _DR.custom:
        if (_custom == null) return _ChartMode.daily;
        final days = _custom!.end.difference(_custom!.start).inDays;
        if (days > 60) return _ChartMode.monthly;
        if (days > 14) return _ChartMode.weekly;
        return _ChartMode.daily;
    }
  }

  String get _chartModeLabel {
    switch (_chartMode) {
      case _ChartMode.daily:
        return 'Daily';
      case _ChartMode.weekly:
        return 'Weekly';
      case _ChartMode.monthly:
        return 'Monthly';
    }
  }

  // ── Chart data builders ───────────────────────────────────────────────────────
  List<_ChartPoint> get _chartPoints {
    final orders = _filtered;
    switch (_chartMode) {
      case _ChartMode.monthly:
        return _buildMonthly(orders);
      case _ChartMode.weekly:
        return _buildWeekly(orders);
      case _ChartMode.daily:
        return _buildDaily(orders);
    }
  }

  List<_ChartPoint> _buildDaily(List<OrderData> orders) {
    final map = <DateTime, ({double amount, int orders})>{};
    for (final o in orders) {
      if (o.createdAt == null) continue;
      final d = o.createdAt!;
      final day = DateTime(d.year, d.month, d.day);
      final cur = map[day];
      map[day] = (
        amount: (cur?.amount ?? 0) + (o.totalPayableAmount?.toDouble() ?? 0),
        orders: (cur?.orders ?? 0) + 1,
      );
    }
    if (map.isEmpty) return [];
    // Use actual data range — not from year 2000
    final rangeStart = map.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final w = _window;
    final rangeEnd = w.to.isAfter(DateTime.now())
        ? DateTime.now()
        : DateTime(w.to.year, w.to.month, w.to.day);
    var cur = rangeStart;
    while (!cur.isAfter(rangeEnd)) {
      map.putIfAbsent(cur, () => (amount: 0, orders: 0));
      cur = cur.add(const Duration(days: 1));
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final fmt = sorted.length > 14 ? 'M/d' : 'd';
    return sorted
        .map((e) => (
              label: DateFormat(fmt).format(e.key),
              amount: e.value.amount,
              orders: e.value.orders
            ))
        .toList();
  }

  List<_ChartPoint> _buildWeekly(List<OrderData> orders) {
    final map = <DateTime, ({double amount, int orders})>{};
    for (final o in orders) {
      if (o.createdAt == null) continue;
      final d = o.createdAt!;
      final ws = d.subtract(Duration(days: d.weekday - 1));
      final key = DateTime(ws.year, ws.month, ws.day);
      final cur = map[key];
      map[key] = (
        amount: (cur?.amount ?? 0) + (o.totalPayableAmount?.toDouble() ?? 0),
        orders: (cur?.orders ?? 0) + 1,
      );
    }
    if (map.isEmpty) return [];
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .map((e) => (
              label: DateFormat('M/d').format(e.key),
              amount: e.value.amount,
              orders: e.value.orders
            ))
        .toList();
  }

  List<_ChartPoint> _buildMonthly(List<OrderData> orders) {
    final map = <String, ({double amount, int orders, DateTime date})>{};
    for (final o in orders) {
      if (o.createdAt == null) continue;
      final d = o.createdAt!;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      final cur = map[key];
      map[key] = (
        amount: (cur?.amount ?? 0) + (o.totalPayableAmount?.toDouble() ?? 0),
        orders: (cur?.orders ?? 0) + 1,
        date: DateTime(d.year, d.month),
      );
    }
    if (map.isEmpty) return [];
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .map((e) => (
              label: DateFormat('MMM yy').format(e.value.date),
              amount: e.value.amount,
              orders: e.value.orders
            ))
        .toList();
  }

  // ── Day-of-week counts (Mon=0 … Sun=6) ───────────────────────────────────────
  List<int> get _ordersByDow {
    final counts = List.filled(7, 0);
    for (final o in _filtered) {
      if (o.createdAt == null) continue;
      counts[(o.createdAt!.weekday - 1) % 7]++;
    }
    return counts;
  }

  // ── Top products ──────────────────────────────────────────────────────────────
  List<({String name, int qty, double spent})> get _topProducts {
    final map = <String, ({int qty, double spent})>{};
    for (final o in _filtered) {
      for (final p in o.products ?? []) {
        final name = p.name?.trim() ?? '';
        if (name.isEmpty) continue;
        final cur = map[name];
        map[name] = (
          qty: ((cur?.qty ?? 0) + (p.count ?? 1).toInt()).toInt(),
          spent: (cur?.spent ?? 0) + (p.totalPrice?.toDouble() ?? 0),
        );
      }
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.qty.compareTo(a.value.qty));
    return sorted
        .take(5)
        .map((e) => (name: e.key, qty: e.value.qty, spent: e.value.spent))
        .toList();
  }

  Future<void> _pickCustom() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _custom,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _custom = picked;
        _range = _DR.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final filtered = _filtered;
    final points = _chartPoints;

    final totalSpent = filtered.fold<double>(
        0, (s, o) => s + (o.totalPayableAmount?.toDouble() ?? 0));
    final totalSaved = filtered.fold<double>(0, (s, o) => s + _saved(o));
    final totalDisc = filtered.fold<double>(
        0, (s, o) => s + (o.totalDiscount?.toDouble() ?? 0));
    final totalCoupon = filtered.fold<double>(
        0, (s, o) => s + (o.couponDiscount?.toDouble() ?? 0));
    final totalDelivery = filtered.fold<double>(
        0, (s, o) => s + (o.deliveryCharge?.toDouble() ?? 0));
    final totalHandling = filtered.fold<double>(
        0, (s, o) => s + (o.handlingCharge?.toDouble() ?? 0));
    final totalVat = filtered.fold<double>(
        0, (s, o) => s + (o.totalVatAmount?.toDouble() ?? 0));
    final subtotal = filtered.fold<double>(
        0, (s, o) => s + (o.totalAmount?.toDouble() ?? 0));
    final avgOrder = filtered.isNotEmpty ? totalSpent / filtered.length : 0.0;
    final totalItems = filtered.fold<int>(
        0,
        (s, o) =>
            s +
            (o.products?.fold<int>(0, (ps, p) => ps + (p.count ?? 1)) ?? 0));

    final delivered =
        filtered.where((o) => o.status?.toLowerCase() == 'delivered').length;
    final pending =
        filtered.where((o) => o.status?.toLowerCase() == 'pending').length;
    final processing =
        filtered.where((o) => o.status?.toLowerCase() == 'processing').length;
    final shipped = filtered
        .where((o) =>
            o.status?.toLowerCase() == 'shipped' ||
            o.status?.toLowerCase() == 'shipping')
        .length;
    final cancelled = filtered.where((o) {
      final s = o.status?.toLowerCase();
      return s == 'cancelled' || s == 'returned' || s == 'refunded';
    }).length;
    final statusTotal = filtered.length;

    final statusItems = [
      _StatusItem(
          'Delivered', delivered, _cDelivered, Icons.check_circle_rounded),
      _StatusItem('Pending', pending, _cPending, Icons.hourglass_empty_rounded),
      _StatusItem(
          'Processing', processing, _cProcessing, Icons.inventory_2_rounded),
      _StatusItem(
          'On the Way', shipped, _cShipped, Icons.local_shipping_rounded),
      _StatusItem('Cancelled', cancelled, _cCancelled, Icons.cancel_rounded),
    ].where((s) => s.count > 0 || statusTotal == 0).toList();

    final dowCounts = _ordersByDow;
    final topProducts = _topProducts;

    return Scaffold(
      backgroundColor: vc.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColor.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Order Analytics',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  fontFamily: 'Inter'),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats header card ──────────────────────────────
                Container(
                  color: AppColor.primary,
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: Row(
                      children: [
                        _HeaderStat(
                            label: 'Total Spent',
                            value: 'Rs.${totalSpent.toInt()}',
                            icon: Icons.payments_rounded),
                        _vDivider(),
                        _HeaderStat(
                            label: 'Orders',
                            value: '${filtered.length}',
                            icon: Icons.receipt_long_rounded),
                        _vDivider(),
                        _HeaderStat(
                            label: 'Avg Order',
                            value: 'Rs.${avgOrder.toInt()}',
                            icon: Icons.bar_chart_rounded),
                        _vDivider(),
                        _HeaderStat(
                            label: 'Items',
                            value: '$totalItems',
                            icon: Icons.shopping_bag_rounded),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Date filter chips ──────────────────────────────
                SizedBox(
                  height: 36.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: _DR.values.map((r) {
                      final sel = _range == r;
                      return GestureDetector(
                        onTap: () => r == _DR.custom
                            ? _pickCustom()
                            : setState(() => _range = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: sel ? AppColor.primary : vc.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: sel ? AppColor.primary : vc.divider),
                          ),
                          child: Text(
                            r.label,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : vc.onSurface),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (_range == _DR.custom && _custom != null) ...[
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '${DateFormat('MMM d').format(_custom!.start)} → ${DateFormat('MMM d, yyyy').format(_custom!.end)}',
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                // ── Summary tiles ──────────────────────────────────
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _SectionHeader(title: 'Summary', vc: vc)),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 100.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _SummaryTile(
                          label: 'Orders',
                          value: '${filtered.length}',
                          sub: 'in period',
                          color: AppColor.primary,
                          icon: Icons.receipt_long_rounded),
                      _SummaryTile(
                          label: 'Total Spent',
                          value: 'Rs.${totalSpent.toInt()}',
                          sub: 'payable',
                          color: _cCancelled,
                          icon: Icons.payments_rounded),
                      _SummaryTile(
                          label: 'Total Saved',
                          value: 'Rs.${totalSaved.toInt()}',
                          sub: 'disc + coupon',
                          color: _cDelivered,
                          icon: Icons.savings_rounded),
                      _SummaryTile(
                          label: 'Avg Order',
                          value: 'Rs.${avgOrder.toInt()}',
                          sub: 'per order',
                          color: _cShipped,
                          icon: Icons.bar_chart_rounded),
                      _SummaryTile(
                          label: 'Items',
                          value: '$totalItems',
                          sub: 'products',
                          color: const Color(0xFF0D9488),
                          icon: Icons.shopping_bag_rounded),
                    ],
                  ),
                ),

                if (totalSaved > 0) ...[
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _cDelivered.withValues(alpha: 0.08),
                          _cDelivered.withValues(alpha: 0.03)
                        ]),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: _cDelivered.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer_rounded,
                              color: _cDelivered, size: 15.sp),
                          SizedBox(width: 8.w),
                          Text('Item discounts: ',
                              style: TextStyle(
                                  fontSize: 11.sp, color: _cDelivered)),
                          Text('Rs.${totalDisc.toInt()}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _cDelivered)),
                          SizedBox(width: 16.w),
                          Icon(Icons.confirmation_number_outlined,
                              color: _cDelivered, size: 15.sp),
                          SizedBox(width: 6.w),
                          Text('Coupons: ',
                              style: TextStyle(
                                  fontSize: 11.sp, color: _cDelivered)),
                          Text('Rs.${totalCoupon.toInt()}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _cDelivered)),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                // ── Spending chart ─────────────────────────────────
                if (points.isNotEmpty) ...[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child:
                          _SectionHeader(title: 'Spending Over Time', vc: vc)),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _SpendingChart(
                      points: points,
                      mode: _chartMode,
                      periodLabel: _range.label,
                      totalSpent: totalSpent,
                      orderCount: filtered.length,
                      chartModeLabel: _chartModeLabel,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // ── Order status ───────────────────────────────────
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _SectionHeader(title: 'Order Status', vc: vc)),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _StatusChart(
                      items: statusItems, total: statusTotal, vc: vc),
                ),

                SizedBox(height: 24.h),

                // ── Spending breakdown ─────────────────────────────
                if (filtered.isNotEmpty) ...[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child:
                          _SectionHeader(title: 'Spending Breakdown', vc: vc)),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _SpendingBreakdownCard(
                      subtotal: subtotal,
                      delivery: totalDelivery,
                      handling: totalHandling,
                      vat: totalVat,
                      saved: totalSaved,
                      total: totalSpent,
                      vc: vc,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // ── Orders by day of week ──────────────────────────
                if (filtered.isNotEmpty) ...[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _SectionHeader(title: 'Orders by Day', vc: vc)),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _DayOfWeekCard(counts: dowCounts, vc: vc),
                  ),
                  SizedBox(height: 24.h),
                ],

                // ── Top products ───────────────────────────────────
                if (topProducts.isNotEmpty) ...[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _SectionHeader(title: 'Top Products', vc: vc)),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _TopProductsCard(products: topProducts, vc: vc),
                  ),
                  SizedBox(height: 24.h),
                ],

                SizedBox(height: MediaQuery.of(context).padding.bottom + 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header stat cell ──────────────────────────────────────────────────────────
Widget _vDivider() => Container(
    width: 1, height: 32, color: Colors.white.withValues(alpha: 0.25));

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _HeaderStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: Colors.white.withValues(alpha: 0.80), size: 14.sp),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white.withValues(alpha: 0.70))),
          ],
        ),
      );
}

// ── Smart Spending Chart ──────────────────────────────────────────────────────
class _SpendingChart extends StatelessWidget {
  final List<_ChartPoint> points;
  final _ChartMode mode;
  final String periodLabel;
  final double totalSpent;
  final int orderCount;
  final String chartModeLabel;

  const _SpendingChart({
    required this.points,
    required this.mode,
    required this.periodLabel,
    required this.totalSpent,
    required this.orderCount,
    required this.chartModeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    if (points.isEmpty) return const SizedBox();

    final maxY =
        points.map((p) => p.amount).fold<double>(0, (m, v) => v > m ? v : m);
    final minNonZero = points
        .map((p) => p.amount)
        .where((a) => a > 0)
        .fold<double>(double.infinity, (m, v) => v < m ? v : m);
    final activePts = points.where((p) => p.amount > 0).length;

    return Container(
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
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rs.${totalSpent.toInt()}',
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: vc.onSurface)),
                      SizedBox(height: 2.h),
                      Text(
                          '$periodLabel  •  $orderCount order${orderCount == 1 ? '' : 's'}',
                          style: TextStyle(
                              fontSize: 11.sp, color: vc.onSurfaceMuted)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(chartModeLabel,
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary)),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
              child: mode == _ChartMode.daily
                  ? _LineChart(points: points, maxY: maxY, vc: vc)
                  : _BarChart(points: points, maxY: maxY, vc: vc),
            ),
          ),
          if (maxY > 0) ...[
            Divider(color: vc.divider, height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  _ChartStat(
                      label: 'Peak',
                      value: 'Rs.${maxY.toInt()}',
                      color: AppColor.primary),
                  _chartStatDivider(vc),
                  _ChartStat(
                    label: 'Lowest',
                    value: minNonZero == double.infinity
                        ? '—'
                        : 'Rs.${minNonZero.toInt()}',
                    color: _cPending,
                  ),
                  _chartStatDivider(vc),
                  _ChartStat(
                    label: mode == _ChartMode.daily
                        ? 'Active Days'
                        : 'Active Periods',
                    value: '$activePts',
                    color: _cDelivered,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<_ChartPoint> points;
  final double maxY;
  final VhandarColors vc;
  const _LineChart(
      {required this.points, required this.maxY, required this.vc});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
        points.length, (i) => FlSpot(i.toDouble(), points[i].amount));
    final showLabels = points.length <= 31;

    return LineChart(
      LineChartData(
        minX: -0.4,
        maxX: (points.length - 1) + 0.4,
        minY: 0,
        maxY: maxY > 0 ? maxY * 1.2 : 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColor.primary,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touched) => touched.map((s) {
              final i = s.x.toInt();
              if (i < 0 || i >= points.length) return null;
              return LineTooltipItem(
                '${points[i].label}\nRs.${s.y.toInt()}  •  ${points[i].orders} order${points[i].orders == 1 ? '' : 's'}',
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY * 1.2) / 4 : 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: vc.divider, strokeWidth: 0.8),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: maxY > 0 ? (maxY * 1.2) / 4 : 25,
              getTitlesWidget: (v, _) => v == 0
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        v >= 1000
                            ? '${(v / 1000).toStringAsFixed(1)}k'
                            : v.toInt().toString(),
                        style:
                            TextStyle(fontSize: 8.sp, color: vc.onSurfaceMuted),
                      ),
                    ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showLabels,
              reservedSize: 24,
              interval:
                  points.length > 14 ? (points.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= points.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(points[i].label,
                      style:
                          TextStyle(fontSize: 8.sp, color: vc.onSurfaceMuted)),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColor.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: points.length <= 14,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColor.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColor.primary.withValues(alpha: 0.28),
                  AppColor.primary.withValues(alpha: 0.06),
                  AppColor.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<_ChartPoint> points;
  final double maxY;
  final VhandarColors vc;
  const _BarChart({required this.points, required this.maxY, required this.vc});

  @override
  Widget build(BuildContext context) {
    final barWidth = points.length > 18 ? 8.w : 14.w;

    return BarChart(
      BarChartData(
        maxY: maxY > 0 ? maxY * 1.2 : 100,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColor.primary,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, gi, rod, ri) {
              if (gi < 0 || gi >= points.length) return null;
              return BarTooltipItem(
                '${points[gi].label}\nRs.${rod.toY.toInt()}  •  ${points[gi].orders} order${points[gi].orders == 1 ? '' : 's'}',
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY * 1.2) / 4 : 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: vc.divider, strokeWidth: 0.8),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: maxY > 0 ? (maxY * 1.2) / 4 : 25,
              getTitlesWidget: (v, _) => v == 0
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        v >= 1000
                            ? '${(v / 1000).toStringAsFixed(1)}k'
                            : v.toInt().toString(),
                        style:
                            TextStyle(fontSize: 8.sp, color: vc.onSurfaceMuted),
                      ),
                    ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval:
                  points.length > 12 ? (points.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= points.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(points[i].label,
                      style:
                          TextStyle(fontSize: 8.sp, color: vc.onSurfaceMuted)),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(points.length, (i) {
          final active = points[i].amount > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: points[i].amount,
                color: active
                    ? AppColor.primary
                    : AppColor.primary.withValues(alpha: 0.12),
                width: barWidth,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

Widget _chartStatDivider(VhandarColors vc) => Container(
      width: 1,
      height: 28,
      color: vc.divider,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
    );

class _ChartStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ChartStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 9.sp, color: context.vColors.onSurfaceMuted)),
        ],
      );
}

// ── Status chart ──────────────────────────────────────────────────────────────
class _StatusItem {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatusItem(this.label, this.count, this.color, this.icon);
}

class _StatusChart extends StatelessWidget {
  final List<_StatusItem> items;
  final int total;
  final VhandarColors vc;
  const _StatusChart(
      {required this.items, required this.total, required this.vc});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || total == 0) {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: vc.divider),
        ),
        child: Center(
          child: Text('No orders in this period',
              style: TextStyle(fontSize: 13.sp, color: vc.onSurfaceMuted)),
        ),
      );
    }

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
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 100.w,
            height: 100.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30.r,
                    sections: items
                        .map((s) => PieChartSectionData(
                              value: s.count.toDouble(),
                              color: s.color,
                              radius: 26.r,
                              title: '',
                            ))
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: vc.onSurface)),
                    Text('orders',
                        style: TextStyle(
                            fontSize: 8.sp, color: vc.onSurfaceMuted)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Bar legend
          Expanded(
            child: Column(
              children: items.map((s) {
                final pct = total > 0 ? s.count / total : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Icon(s.icon, color: s.color, size: 10.sp),
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: Text(s.label,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: vc.onSurface)),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${s.count}  ${(pct * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: s.color),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5.h,
                          backgroundColor: s.color.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(s.color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

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

// ── Shared widgets ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VhandarColors vc;
  const _SectionHeader({required this.title, required this.vc});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 3.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(title,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface)),
        ],
      );
}

class _SummaryTile extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final IconData icon;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7.r)),
              child: Icon(icon, color: color, size: 13.sp),
            ),
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: vc.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 1.h),
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: vc.onSurface,
                  fontWeight: FontWeight.w600)),
          Text(sub, style: TextStyle(fontSize: 9.sp, color: vc.onSurfaceMuted)),
        ],
      ),
    );
  }
}
