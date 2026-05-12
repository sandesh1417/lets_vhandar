import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/address/domain/models/address_model.dart';
import 'package:vhandar/features/address/providers/address_provider.dart';
import 'package:vhandar/features/address/widgets/add_address_sheet.dart';

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
    // Load addresses when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressState = ref.read(addressProvider);
      if (!addressState.isFetched && !addressState.isLoading) {
        ref.read(addressProvider.notifier).loadAddresses(widget.userId);
      }
    });
  }

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Header row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select delivery address',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  children: [
                    // --- Add Address Button ---
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close selector first
                        await showAddAddressSheet(context,
                            userId: widget.userId);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add,
                                color: AppColor.primary, size: 22.sp),
                            SizedBox(width: 12.w),
                            Text(
                              'Add Address',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (state.addresses.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            'No saved addresses yet.',
                            style: TextStyle(
                                color: AppColor.textMuted, fontSize: 14.sp),
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        'Your saved addresses',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...state.addresses.map((addr) => _AddressTile(
                            address: addr,
                            isSelected: state.selected?.id == addr.id,
                            icon: _iconForType(addr.addressType),
                            onTap: () {
                              ref
                                  .read(addressProvider.notifier)
                                  .selectAddress(addr);
                              Navigator.pop(context);
                            },
                            onEdit: () async {
                              Navigator.pop(context);
                              await showAddAddressSheet(context,
                                  userId: widget.userId, existingAddress: addr);
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

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColor.secondary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(address.addressType ?? 'Address'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppColor.textBlack87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.description ?? '',
                    style:
                        TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.secondary,
                side: BorderSide(color: AppColor.secondary),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Edit',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
