import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:go_router/go_router.dart';
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

  void _openAddSheet(BuildContext context, String userId,
      {AddressModel? existing}) {
    context.pushNamed(
      LVRoute.addAddressScreen.route,
      extra: {'userId': userId, 'existingAddress': existing},
    );
  }

  void _showDeleteConfirmation(BuildContext context, AddressModel address) {
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

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final user = ref.watch(loginProvider).user;
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      isScrollable: false,
      appBar: const CustomScreenHeader(title: 'Manage Addresses'),
      body: Builder(builder: (context) {
        if (addressState.isLoading) {
          return const OrderListShimmer();
        }
        if (addressState.error != null) {
          return _ErrorState(
            message: addressState.error!,
            onRetry: () {
              if (user?.id != null) {
                ref.read(addressProvider.notifier).loadAddresses(user!.id!);
              }
            },
          );
        }
        if (addressState.addresses.isEmpty) {
          return RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              if (user?.id != null) {
                await ref
                    .read(addressProvider.notifier)
                    .loadAddresses(user!.id!);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: _EmptyState(
                  onAdd: user?.id != null
                      ? () => _openAddSheet(context, user!.id!)
                      : null,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
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
                      parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  itemCount: addressState.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressState.addresses[index];
                    return _AddressCard(
                      address: address,
                      onEdit: () {
                        if (user?.id == null) return;
                        _openAddSheet(context, user!.id!,
                            existing: address);
                      },
                      onDelete: () =>
                          _showDeleteConfirmation(context, address),
                    );
                  },
                ),
              ),
            ),
            _AddAddressButton(
              onTap: user?.id != null
                  ? () => _openAddSheet(context, user!.id!)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Address Bottom Button
// ---------------------------------------------------------------------------

class _AddAddressButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddAddressButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w,
          12.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.add_location_alt_outlined,
              size: 20.sp, color: Colors.white),
          label: Text(
            'Add New Address',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Address Card
// ---------------------------------------------------------------------------

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  String get _svgAsset {
    switch (address.addressType?.toLowerCase()) {
      case 'home':
        return 'assets/icons/address_home.svg';
      case 'office':
        return 'assets/icons/address_office.svg';
      default:
        return 'assets/icons/address_other.svg';
    }
  }

  String get _typeLabel {
    final t = address.addressType?.toLowerCase();
    if (t == 'home') return 'Home';
    if (t == 'office') return 'Office';
    if (address.addressType != null && address.addressType!.isNotEmpty) {
      return address.addressType![0].toUpperCase() +
          address.addressType!.substring(1);
    }
    return 'Others';
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: vc.divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + label + actions ─────────────────────
            Row(
              children: [
                // SVG type icon in yellow box
                Container(
                  width: 44.w,
                  height: 44.w,
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: SvgPicture.asset(
                    _svgAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: vc.onSurface,
                        ),
                      ),
                      if (address.name != null && address.name!.isNotEmpty)
                        Text(
                          address.name!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: vc.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                _IconBtn(
                  icon: Icons.edit_outlined,
                  color: AppColor.primary,
                  onTap: onEdit,
                ),
                SizedBox(width: 6.w),
                _IconBtn(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red.shade400,
                  onTap: onDelete,
                ),
              ],
            ),

            // ── Address text ─────────────────────────────────────────
            if (address.description != null &&
                address.description!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Divider(height: 1, color: vc.divider),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 15.sp, color: AppColor.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      address.description!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── Detail chips ─────────────────────────────────────────
            _buildDetailChips(vc),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChips(VhandarColors vc) {
    final details = <String>[];
    if (address.houseNumber != null && address.houseNumber!.isNotEmpty) {
      details.add('House ${address.houseNumber}');
    }
    if (address.floor != null && address.floor!.isNotEmpty) {
      details.add('Floor ${address.floor}');
    }
    if (address.locality != null && address.locality!.isNotEmpty) {
      details.add(address.locality!);
    }
    if (address.landMark != null && address.landMark!.isNotEmpty) {
      details.add('Near ${address.landMark}');
    }
    if (details.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 4.h,
        children: details
            .map((d) => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: vc.scaffoldBg,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: vc.divider),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: vc.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small icon action button
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 17.sp, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;

  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/location_pin.svg',
            width: 160.w,
            height: 160.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Saved Addresses',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Save your home, work, or other\naddresses for faster checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
              height: 1.6,
            ),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_location_alt_outlined,
                  size: 20.sp, color: Colors.white),
              label: Text(
                'Add Your First Address',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 48.sp, color: vc.onSurfaceMuted),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: vc.onSurfaceMuted),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
