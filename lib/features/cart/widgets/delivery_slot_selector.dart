import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/time_slot_model.dart';
import 'package:lets_vhandar/features/home/providers/time_slot_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';

class DeliverySlotSelector extends ConsumerWidget {
  final bool isError;
  const DeliverySlotSelector({super.key, this.isError = false});

  void _openPicker(BuildContext context, WidgetRef ref, String? currentId,
      List<TimeSlot> slots) {
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SlotPickerSheet(
        slots: slots,
        currentId: currentId,
        onSelected: (slot) {
          ref.read(selectedDeliverySlotProvider.notifier).state = slot.id;
          ref.read(cartAddressErrorProvider.notifier).state = false;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedDeliverySlotProvider);
    final slotsAsync = ref.watch(timeSlotProvider);
    final vc = context.vColors;
    final hasError = isError && selectedId == null;

    final slots = slotsAsync.valueOrNull ?? [];
    final selectedSlot = slots.where((s) => s.id == selectedId).firstOrNull;
    final displayLabel = selectedSlot != null
        ? '${selectedSlot.slotName}  ${selectedSlot.displayTime}'
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: slotsAsync.isLoading
            ? null
            : () => _openPicker(context, ref, selectedId, slots),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: selectedId != null
                ? AppColor.primary.withValues(alpha: 0.07)
                : hasError
                    ? Colors.red.withValues(alpha: 0.04)
                    : vc.surfaceVariant,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasError
                  ? Colors.red.shade400
                  : selectedId != null
                      ? AppColor.primary.withValues(alpha: 0.4)
                      : vc.divider,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: hasError
                      ? Colors.red.withValues(alpha: 0.12)
                      : AppColor.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: hasError ? Colors.red.shade600 : Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Time Slot',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                            hasError ? Colors.red.shade600 : vc.onSurfaceMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    slotsAsync.isLoading
                        ? const CustomShimmer.rectangular(height: 14, width: 80)
                        : Text(
                            displayLabel ??
                                (hasError
                                    ? 'Required – tap to select'
                                    : 'Tap to choose time'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: hasError
                                  ? Colors.red.shade600
                                  : selectedId != null
                                      ? vc.onSurface
                                      : vc.onSurfaceMuted,
                            ),
                          ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22.sp,
                color: hasError ? Colors.red.shade400 : vc.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slot picker bottom sheet ──────────────────────────────────────────────────

class _SlotPickerSheet extends StatelessWidget {
  final List<TimeSlot> slots;
  final String? currentId;
  final ValueChanged<TimeSlot> onSelected;

  const _SlotPickerSheet({
    required this.slots,
    required this.currentId,
    required this.onSelected,
  });

  IconData _iconFor(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'morning':
        return Icons.wb_sunny_outlined;
      case 'afternoon':
        return Icons.light_mode_outlined;
      case 'evening':
        return Icons.wb_twilight_outlined;
      case 'night':
        return Icons.nights_stay_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 6.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.schedule_rounded,
                      color: AppColor.primary, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Delivery Time',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: vc.onSurface,
                      ),
                    ),
                    Text(
                      'Choose when to receive your order',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vc.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: vc.divider),
          SizedBox(height: 8.h),
          if (slots.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'No time slots available',
                style: TextStyle(fontSize: 14.sp, color: vc.onSurfaceMuted),
              ),
            ),
          ...slots.map((slot) {
            final isSelected = slot.id == currentId;
            return InkWell(
              onTap: () {
                AppHaptics.light();
                onSelected(slot);
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary : vc.surfaceVariant,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(slot.slotName),
                      size: 22.sp,
                      color: isSelected ? Colors.white : AppColor.primary,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.slotName ?? '',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : vc.onSurface,
                            ),
                          ),
                          if (slot.displayTime.isNotEmpty)
                            Text(
                              slot.displayTime,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : vc.onSurfaceMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded,
                            color: Colors.white, size: 14.sp),
                      )
                    else
                      Icon(Icons.radio_button_unchecked,
                          size: 18.sp, color: vc.onSurfaceMuted),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
