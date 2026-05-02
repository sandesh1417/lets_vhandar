import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/add_address_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

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
      if (user?.id != null) {
        ref.read(addressProvider.notifier).loadAddresses(user!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final user = ref.watch(loginProvider).user;

    return CustomScaffoldWrapper(
      appBar: const CustomScreenHeader(title: 'Saved Addresses'),
      body: Builder(
        builder: (context) {
          if (addressState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (addressState.error != null) {
            return Center(child: Text('Error: ${addressState.error}'));
          }
          if (addressState.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 60.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  const Text('No addresses saved yet.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: addressState.addresses.length,
            itemBuilder: (context, index) {
              final address = addressState.addresses[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                    child: Icon(_getAddressIcon(address.addressType),
                        color: AppColor.primary),
                  ),
                  title: Text(
                    address.name ?? 'Address',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    address.description ?? '',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Implement delete logic
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user?.id == null) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddAddressSheet(userId: user!.id!),
          );
        },
        backgroundColor: AppColor.primary,
        label: const Text('Add New Address',
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getAddressIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }
}
