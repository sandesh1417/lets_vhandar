import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';
import 'package:lets_vhandar/features/my_list/providers/my_list_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class MyListsScreen extends ConsumerWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'My Lists'),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.lists.isEmpty
              ? _buildEmpty(context)
              : ListView.builder(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                  itemCount: state.lists.length,
                  itemBuilder: (context, i) => _ListCard(
                    list: state.lists[i],
                    onTap: () => context.push(
                      LVRoute.listDetailScreen.route,
                      extra: state.lists[i].id,
                    ),
                    onDelete: () =>
                        _confirmDelete(context, ref, state.lists[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/vhandar_list.svg',
              width: 160.w,
            ),
            SizedBox(height: 20.h),
            Text(
              'No Lists Yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a list to organise\nyour favourite products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Inter',
                color: vc.onSurfaceMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'New List',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'List name (e.g. Weekly Groceries)',
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(myListProvider.notifier).createList(name);
            },
            child: Text(
              'Create',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, SavedList list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete List',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp)),
        content: Text(
          'Delete "${list.name}"? This cannot be undone.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(myListProvider.notifier).deleteList(list.id);
            },
            child: Text('Delete',
                style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final SavedList list;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ListCard({
    required this.list,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.list_alt_rounded,
                  color: AppColor.primary, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: vc.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    list.products.isEmpty
                        ? 'Empty list'
                        : '${list.products.length} item${list.products.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      color: vc.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.shade400, size: 20.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right,
                color: vc.onSurfaceMuted, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
