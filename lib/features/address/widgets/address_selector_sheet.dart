import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:go_router/go_router.dart';

/// Shows the list of saved addresses and an "Add Address" button.
/// Call via: showAddressSelectorSheet(context, userId: '...')
Future<void> showAddressSelectorSheet(
  BuildContext context, {
  required String userId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddressSelectorSheet(userId: userId),
  );
}

class AddressSelectorSheet extends ConsumerStatefulWidget {
  final String userId;
  const AddressSelectorSheet({super.key, required this.userId});

  @override
  ConsumerState<AddressSelectorSheet> createState() =>
      _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends ConsumerState<AddressSelectorSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressState = ref.read(addressProvider);
      if (!addressState.isFetched && !addressState.isLoading) {
        ref.read(addressProvider.notifier).loadAddresses(widget.userId);
      }
    });
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
    final state = ref.watch(addressProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: vc.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColor.primary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select delivery address',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: vc.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Choose where to deliver your order',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: vc.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: vc.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: vc.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: vc.divider),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  children: [
                    // Add new address button (dashed border)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          LVRoute.addAddressScreen.route,
                          extra: {'userId': widget.userId},
                        );
                      },
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: AppColor.primary.withValues(alpha: 0.6),
                          radius: 12.r,
                          dashWidth: 6,
                          gapWidth: 4,
                          strokeWidth: 1.5,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: vc.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: vc.divider),
                              ),
                              child: Icon(
                                Icons.add,
                                color: AppColor.primary,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add new address',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Save a location for faster checkout',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.primary
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                    SizedBox(height: 20.h),

                    if (state.isLoading)
                      const OrderListShimmer(itemCount: 3)
                    else if (state.addresses.isEmpty)
                      _EmptyState(vc: vc)
                    else ...[
                      Text(
                        'Your saved addresses',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...state.addresses.map((addr) => _AddressTile(
                            address: addr,
                            isSelected: state.selected?.id == addr.id,
                            svgAsset: _svgForType(addr.addressType),
                            onTap: () {
                              ref
                                  .read(addressProvider.notifier)
                                  .selectAddress(addr);
                              Navigator.pop(context);
                            },
                            onEdit: () {
                              Navigator.pop(context);
                              context.pushNamed(
                                LVRoute.addAddressScreen.route,
                                extra: {
                                  'userId': widget.userId,
                                  'existingAddress': addr,
                                },
                              );
                            },
                          )),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VhandarColors vc;
  const _EmptyState({required this.vc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/no_address.svg',
            width: 200.w,
            height: 140.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Text(
            'No saved addresses yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Add an address to get started',
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final String svgAsset;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.svgAsset,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withValues(alpha: 0.04)
              : vc.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : vc.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppColor.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(address.addressType ?? 'Address'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: vc.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.description ?? '',
                    style: TextStyle(
                        fontSize: 12.sp, color: vc.onSurfaceMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: vc.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: vc.divider),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double gapWidth;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 6,
    this.gapWidth = 4,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dashWidth != dashWidth ||
      old.gapWidth != gapWidth ||
      old.strokeWidth != strokeWidth;
}
