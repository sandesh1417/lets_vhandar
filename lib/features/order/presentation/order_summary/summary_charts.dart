part of '../order_summary_screen.dart';

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
