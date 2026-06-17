import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/error_state.dart';
import 'widgets/bill_details_card.dart';
import 'widgets/order_product_item.dart';
import 'widgets/order_status_badge.dart';
import 'order_receipt_pdf.dart';

// ── Order status step definition ──────────────────────────────────────────────
class _StepDef {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StepDef(this.title, this.subtitle, this.icon);
}

const _orderSteps = [
  _StepDef('Order Placed', 'Your order has been received',
      Icons.receipt_long_rounded),
  _StepDef(
      'Processing', 'Your order is being packed', Icons.inventory_2_rounded),
  _StepDef('On the Way', 'Out for delivery', Icons.local_shipping_rounded),
  _StepDef(
      'Delivered', 'Order delivered successfully', Icons.check_circle_rounded),
];

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    ref.watch(generalSettingsProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(LVRoute.helpSupportScreen.route),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.headset_mic_outlined,
                      size: 20.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => _OrderDetailBody(
          order: order,
          onRefresh: () async => ref.invalidate(orderDetailProvider(orderId)),
        ),
        loading: () => const OrderDetailShimmer(),
        error: (_, __) => ErrorStateWidget(
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

String _monthName(int month) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return m[month - 1];
}

class _OrderDetailBody extends StatefulWidget {
  final OrderData order;
  final Future<void> Function() onRefresh;
  const _OrderDetailBody({required this.order, required this.onRefresh});

  @override
  State<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<_OrderDetailBody> {
  bool _shareLoading = false;
  bool _downloadLoading = false;

  OrderData get order => widget.order;

  String get _dateStr {
    if (order.createdAt == null) return '';
    final d = order.createdAt!;
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_monthName(d.month)} ${d.year}  •  $h:$min $ampm';
  }

  Future<void> _shareReceiptPdf() async {
    setState(() => _shareLoading = true);
    try {
      final bytes = await buildReceiptPdf(order);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Vhandar_Receipt_${order.orderId ?? 'order'}.pdf',
      );
    } catch (_) {
      if (mounted) {
        CustomSnackbar.error(context,
            message: 'Could not generate receipt PDF');
      }
    } finally {
      if (mounted) setState(() => _shareLoading = false);
    }
  }

  Future<void> _downloadReceiptPdf() async {
    setState(() => _downloadLoading = true);
    try {
      final bytes = await buildReceiptPdf(order);
      final filename = 'Vhandar_Receipt_${order.orderId ?? 'order'}.pdf';
      final file = await _savePdf(bytes, filename);

      if (!mounted) return;
      if (file == null) {
        CustomSnackbar.error(context,
            message: 'Could not download receipt PDF');
      } else {
        final toDownloads = file.path.contains('/Download');
        CustomSnackbar.success(
          context,
          message: toDownloads
              ? 'Saved to Downloads: $filename'
              : 'Receipt saved: $filename',
        );
      }
    } catch (_) {
      if (mounted) {
        CustomSnackbar.error(context,
            message: 'Could not download receipt PDF');
      }
    } finally {
      if (mounted) setState(() => _downloadLoading = false);
    }
  }

  /// Writes the PDF to the device. Tries the public Downloads folder on
  /// Android, then app-external storage, then app documents as a fallback.
  Future<File?> _savePdf(Uint8List bytes, String filename) async {
    try {
      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download');
        if (await downloads.exists()) {
          try {
            final f = File('${downloads.path}/$filename');
            await f.writeAsBytes(bytes, flush: true);
            return f;
          } catch (_) {
            // Scoped storage blocked the direct write — fall through.
          }
        }
        final ext = await getExternalStorageDirectory();
        if (ext != null) {
          final f = File('${ext.path}/$filename');
          await f.writeAsBytes(bytes, flush: true);
          return f;
        }
      }
      final docs = await getApplicationDocumentsDirectory();
      final f = File('${docs.path}/$filename');
      await f.writeAsBytes(bytes, flush: true);
      return f;
    } catch (_) {
      return null;
    }
  }

  String _svgForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 'assets/icons/address_home.svg';
      case 'office':
        return 'assets/icons/address_office.svg';
      default:
        return 'assets/icons/address_other.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return AppRefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order hero card ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: vc.divider),
              ),
              child: Column(
                children: [
                  // Green strip with order ID + date
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.orderId ?? '—'}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                _dateStr,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Share button
                        GestureDetector(
                          onTap: _shareLoading ? null : _shareReceiptPdf,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: _shareLoading
                                ? SizedBox(
                                    width: 18.sp,
                                    height: 18.sp,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.ios_share_rounded,
                                    color: Colors.white, size: 18.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status + payment row
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        _InfoChip(
                          label: 'Order',
                          child: OrderStatusBadge(
                              status: order.status ?? 'Pending'),
                        ),
                        SizedBox(width: 12.w),
                        _InfoChip(
                          label: 'Payment',
                          child: OrderStatusBadge(
                              status: order.paymentStatus ?? 'Pending'),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${order.totalPayableAmount ?? 0}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                              ),
                            ),
                            Text(
                              'Total paid',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: vc.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Order Status Stepper ────────────────────────────────────
            _OrderStatusStepper(status: order.status),

            SizedBox(height: 20.h),

            // ── Products ────────────────────────────────────────────────
            const _SectionLabel(label: 'Items Ordered'),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: vc.divider),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < (order.products?.length ?? 0); i++) ...[
                    OrderProductItem(product: order.products![i]),
                    if (i < (order.products!.length - 1))
                      Divider(height: 1, thickness: 0.5, color: vc.divider),
                  ],
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Delivery Info ────────────────────────────────────────────
            if (_hasDeliveryInfo(order)) ...[
              const _SectionLabel(label: 'Delivery Info'),
              SizedBox(height: 10.h),
              _DeliveryInfoCard(order: order),
              SizedBox(height: 20.h),
            ],

            // ── Bill ────────────────────────────────────────────────────
            const _SectionLabel(label: 'Bill Details'),
            SizedBox(height: 10.h),
            BillDetailsCard(order: order),

            SizedBox(height: 20.h),

            // ── Delivery Address ────────────────────────────────────────
            const _SectionLabel(label: 'Delivery Address'),
            SizedBox(height: 10.h),
            if (order.location != null)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: vc.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: vc.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: SvgPicture.asset(
                        _svgForType(order.location?.addressType),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.location?.name?.isNotEmpty == true
                                ? order.location!.name!
                                : _labelForType(order.location?.addressType),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: vc.onSurface,
                            ),
                          ),
                          if (order.location?.description?.isNotEmpty ==
                              true) ...[
                            SizedBox(height: 4.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 13.sp, color: AppColor.primary),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    order.location!.description!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: vc.onSurfaceMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (order.location?.phoneNumber?.isNotEmpty ==
                              true) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: 13.sp, color: AppColor.primary),
                                SizedBox(width: 4.w),
                                Text(
                                  order.location!.phoneNumber!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: vc.onSurfaceMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20.h),

            // ── Payment Method ──────────────────────────────────────────
            const _SectionLabel(label: 'Payment Method'),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: vc.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.orange.shade700, size: 22.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.paymentMethod ?? 'Cash on Delivery',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface,
                          ),
                        ),
                        Text(
                          'Payment method used',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: vc.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.paymentStatus ?? 'Pending'),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── PDF actions ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PdfButton(
                    label: 'Share Receipt',
                    icon: Icons.ios_share_rounded,
                    loading: _shareLoading,
                    onTap: _shareReceiptPdf,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _PdfButton(
                    label: 'Download PDF',
                    icon: Icons.download_rounded,
                    loading: _downloadLoading,
                    onTap: _downloadReceiptPdf,
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasDeliveryInfo(OrderData o) {
    final s = o.status?.toLowerCase();
    return (o.deliveryTime?.isNotEmpty == true) ||
        (o.deliveryTimeSlot != null) ||
        (s == 'delivered' && o.updatedAt != null);
  }

  String _labelForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'office':
        return 'Office';
      default:
        if (type != null && type.isNotEmpty) {
          return type[0].toUpperCase() + type.substring(1);
        }
        return 'Others';
    }
  }
}

// ── PDF action button ─────────────────────────────────────────────────────────

class _PdfButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final bool filled;
  final VoidCallback onTap;

  const _PdfButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: filled
              ? AppColor.primary
              : AppColor.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: AppColor.primary.withValues(alpha: filled ? 1 : 0.25)),
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 18.sp,
                  height: 18.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: filled ? Colors.white : AppColor.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 17.sp,
                      color: filled ? Colors.white : AppColor.primary),
                  SizedBox(width: 7.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : AppColor.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Order Status Stepper ──────────────────────────────────────────────────────

class _OrderStatusStepper extends StatefulWidget {
  final String? status;
  const _OrderStatusStepper({this.status});

  @override
  State<_OrderStatusStepper> createState() => _OrderStatusStepperState();
}

class _OrderStatusStepperState extends State<_OrderStatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  static int _stepIndex(String? s) {
    switch (s?.toLowerCase()) {
      case 'processing':
        return 1;
      case 'shipped':
      case 'shipping':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0; // pending
    }
  }

  bool get _isCancelled {
    final s = widget.status?.toLowerCase();
    return s == 'cancelled' || s == 'returned' || s == 'refunded';
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final activeIndex = _stepIndex(widget.status);
    final cancelled = _isCancelled;
    final activeColor = cancelled ? Colors.red.shade600 : AppColor.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: vc.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: activeColor, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                cancelled
                    ? 'Order ${widget.status ?? 'Cancelled'}'
                    : 'Order Progress',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (cancelled)
            _CancelledBanner(status: widget.status)
          else
            ...List.generate(_orderSteps.length, (i) {
              final step = _orderSteps[i];
              final isDone = i < activeIndex;
              final isActive = i == activeIndex;
              final isLast = i == _orderSteps.length - 1;
              return _StepRow(
                step: step,
                isDone: isDone,
                isActive: isActive,
                isLast: isLast,
                activeColor: activeColor,
                pulseAnimation: isActive ? _pulse : null,
              );
            }),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _StepDef step;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final Color activeColor;
  final Animation<double>? pulseAnimation;

  const _StepRow({
    required this.step,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    required this.activeColor,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final dimColor = vc.onSurface.withValues(alpha: 0.2);

    final circleColor = (isDone || isActive) ? activeColor : Colors.transparent;
    final iconColor = (isDone || isActive) ? Colors.white : dimColor;
    final borderColor = (isDone || isActive) ? activeColor : dimColor;

    Widget circle = Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Icon(
        isDone ? Icons.check_rounded : step.icon,
        color: iconColor,
        size: 18.sp,
      ),
    );

    // Pulse ring on active step
    if (isActive && pulseAnimation != null) {
      circle = AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40.w + 10 * pulseAnimation!.value,
              height: 40.w + 10 * pulseAnimation!.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor.withValues(
                    alpha: 0.15 * (1 - pulseAnimation!.value)),
              ),
            ),
            child!,
          ],
        ),
        child: circle,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + connector column
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                circle,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone ? activeColor : dimColor,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          // Text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8.h,
                bottom: isLast ? 0 : 20.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: (isDone || isActive)
                          ? vc.onSurface
                          : vc.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: (isDone || isActive)
                          ? vc.onSurfaceMuted
                          : vc.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                  if (isActive) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Current Status',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  final String? status;
  const _CancelledBanner({this.status});

  @override
  Widget build(BuildContext context) {
    final s = status?.toLowerCase();
    final (label, color, icon) = switch (s) {
      'returned' => (
          'This order has been Returned',
          Colors.purple.shade600,
          Icons.assignment_return_rounded
        ),
      'refunded' => (
          'This order has been Refunded',
          const Color(0xFF00695C),
          Icons.currency_exchange_rounded
        ),
      _ => (
          'This order has been Cancelled',
          Colors.red.shade600,
          Icons.cancel_rounded
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: context.vColors.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Info chip (label + child) ──────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoChip({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: context.vColors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: 4.h),
        child,
      ],
    );
  }
}

// ── Delivery Info Card ─────────────────────────────────────────────────────

class _DeliveryInfoCard extends StatelessWidget {
  final OrderData order;
  const _DeliveryInfoCard({required this.order});

  String _fmt(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isDelivered = order.status?.toLowerCase() == 'delivered';
    final slot = order.deliveryTimeSlot;
    final slotLabel = slot is Map
        ? ('${slot['slotName'] ?? ''} ${slot['displayTime'] ?? ''}'.trim())
        : (slot is String ? slot : null);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: vc.divider),
      ),
      child: Column(
        children: [
          // Delivered on
          if (isDelivered && order.updatedAt != null)
            _InfoRow(
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF2E7D32),
              label: 'Delivered on',
              value: _fmt(order.updatedAt!),
            ),

          // Delivery time (field)
          if (order.deliveryTime?.isNotEmpty == true) ...[
            if (isDelivered && order.updatedAt != null)
              Divider(height: 20.h, color: vc.divider),
            _InfoRow(
              icon: Icons.schedule_rounded,
              iconColor: AppColor.primary,
              label: 'Delivery time',
              value: order.deliveryTime!,
            ),
          ],

          // Time slot
          if (slotLabel != null && slotLabel.isNotEmpty) ...[
            if ((isDelivered && order.updatedAt != null) ||
                order.deliveryTime?.isNotEmpty == true)
              Divider(height: 20.h, color: vc.divider),
            _InfoRow(
              icon: Icons.access_time_rounded,
              iconColor: AppColor.primary,
              label: 'Time slot',
              value: slotLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: vc.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
