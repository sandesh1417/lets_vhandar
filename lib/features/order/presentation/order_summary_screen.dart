import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

part 'order_summary/summary_common.dart';
part 'order_summary/summary_charts.dart';
part 'order_summary/summary_cards.dart';

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
  List<_ChartPoint> _chartPointsFor(List<OrderData> orders) {
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
  List<int> _ordersByDowFor(List<OrderData> orders) {
    final counts = List.filled(7, 0);
    for (final o in orders) {
      if (o.createdAt == null) continue;
      counts[(o.createdAt!.weekday - 1) % 7]++;
    }
    return counts;
  }

  // ── Top products ──────────────────────────────────────────────────────────────
  List<({String name, int qty, double spent})> _topProductsFor(
      List<OrderData> orders) {
    final map = <String, ({int qty, double spent})>{};
    for (final o in orders) {
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
    final points = _chartPointsFor(filtered);

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

    final dowCounts = _ordersByDowFor(filtered);
    final topProducts = _topProductsFor(filtered);

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
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
),
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
