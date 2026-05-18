import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/add_address_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(loginProvider).user;
      final addressState = ref.read(addressProvider);
      if (user?.id != null &&
          !addressState.isFetched &&
          !addressState.isLoading) {
        ref.read(addressProvider.notifier).loadAddresses(user!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final user = ref.watch(loginProvider).user;

    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFF8F9FB),
      isScrollable: false,
      appBar: const CustomScreenHeader(title: 'Saved Addresses'),
      body: Builder(
        builder: (context) {
          if (addressState.isLoading) {
            return const OrderListShimmer();
          }
          if (addressState.error != null) {
            return Center(child: Text('Error: ${addressState.error}'));
          }
          if (addressState.addresses.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              if (user?.id != null) {
                await ref
                    .read(addressProvider.notifier)
                    .loadAddresses(user!.id!);
              }
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              itemCount: addressState.addresses.length,
              itemBuilder: (context, index) {
                final address = addressState.addresses[index];
                return _AddressCard(
                  address: address,
                  onEdit: () {
                    if (user?.id == null) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddAddressSheet(
                        userId: user!.id!,
                        existingAddress: address,
                      ),
                    );
                  },
                  onDelete: () =>
                      _showDeleteConfirmation(context, ref, address),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user?.id == null) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddAddressSheet(userId: user!.id!),
          );
        },
        backgroundColor: AppColor.primary,
        elevation: 4,
        label: Text(
          'Add New Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 56.sp,
              color: AppColor.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Saved Addresses',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add an address to make checkout\nfaster and easier.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, dynamic address) {
    CustomDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconColor: Colors.red.shade400,
      iconBgColor: Colors.red.shade50,
      title: 'Delete Address',
      message: 'Are you sure you want to delete this address?',
      confirmLabel: 'Yes, Delete',
      confirmGradient: [Colors.red.shade600, Colors.red.shade400],
      onConfirm: () async {
        final user = ref.read(loginProvider).user;
        if (user?.id != null && address.id != null) {
          await ref.read(addressProvider.notifier).deleteAddress(
                userId: user!.id!,
                addressId: address.id!,
              );
        }
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final dynamic address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return const Color(0xFF1E8B5A);
      case 'work':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF7B1FA2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(address.addressType);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with tinted bg
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(_getIcon(address.addressType),
                  color: typeColor, size: 22.sp),
            ),
            SizedBox(width: 14.w),

            // Address details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name ?? 'Address',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Type chip
                      if (address.addressType != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            address.addressType!.toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    address.description ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Action buttons
            Column(
              children: [
                _ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: AppColor.primary,
                  onTap: onEdit,
                ),
                SizedBox(height: 8.h),
                _ActionIconButton(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }
}
