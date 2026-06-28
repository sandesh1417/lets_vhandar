import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';
import 'package:lets_vhandar/features/my_list/providers/my_list_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class MyListsScreen extends ConsumerWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myListProvider);
    final vc = context.vColors;
    final statusBarH = MediaQuery.of(context).padding.top;

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
      backgroundColor: vc.scaffoldBg,
      body: Column(
        children: [
          // ── Green header ─────────────────────────────────────────
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.only(
              top: statusBarH + 10.h,
              left: 4.w,
              right: 8.w,
              bottom: 12.h,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Lists',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      // Dynamic subtitle — updates live
                      if (!state.isLoading)
                        Text(
                          state.lists.isEmpty
                              ? 'No lists yet'
                              : '${state.lists.length} list${state.lists.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: 'Inter',
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                    ],
                  ),
                ),
                // Always-visible "+" button in header
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCreateSheet(context, ref);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Icon(Icons.add_rounded,
                        color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? _buildShimmer()
                : AppRefreshIndicator(
                    onRefresh: () => ref.read(myListProvider.notifier).load(),
                    child: state.lists.isEmpty
                        ? LayoutBuilder(
                            builder: (_, c) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: c.maxHeight,
                                child: _buildEmpty(context, ref),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
                            itemCount: state.lists.length,
                            itemBuilder: (context, i) => _ListCard(
                              list: state.lists[i],
                              index: i,
                              onTap: () => context.push(
                                LVRoute.listDetailScreen.route,
                                extra: state.lists[i].id,
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, ref, state.lists[i]),
                              onRename: () => _showRenameSheet(
                                  context, ref, state.lists[i]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: CustomShimmer.rectangular(height: 96.h),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.list_alt_rounded,
              size: 48.sp,
              color: AppColor.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Lists Yet',
            style: TextStyle(
              fontSize: 20.sp,
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
              height: 1.6,
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showCreateSheet(context, ref);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6.w),
                  Text(
                    'Create Your First List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewListSheet(
        onCreated: (name) async {
          await ref.read(myListProvider.notifier).createList(name);
        },
      ),
    );
  }

  void _showRenameSheet(BuildContext context, WidgetRef ref, SavedList list) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewListSheet(
        initial: list.name,
        title: 'Rename List',
        buttonLabel: 'Save',
        onCreated: (name) async {
          await ref.read(myListProvider.notifier).renameList(list.id, name);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SavedList list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.vColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Delete List',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: context.vColors.onSurface,
          ),
        ),
        content: Text(
          'Delete "${list.name}"?\nThis cannot be undone.',
          style: TextStyle(
              fontSize: 13.sp,
              color: context.vColors.onSurfaceMuted,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: context.vColors.onSurfaceMuted, fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(myListProvider.notifier).deleteList(list.id);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red.shade500,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List Card
// ─────────────────────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final SavedList list;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ListCard({
    required this.list,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  static final _accentColors = [
    AppColor.primary,
    const Color(0xFF2563EB),
    const Color(0xFF7C3AED),
    const Color(0xFFD97706),
    const Color(0xFFDC2626),
    const Color(0xFF0891B2),
  ];

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final accent = _accentColors[index % _accentColors.length];
    final previews = list.products.take(4).toList();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: vc.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Coloured left accent bar
                Container(width: 4.w, color: accent),

                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 6.w, 14.h),
                    child: Row(
                      children: [
                        // Thumbnail or icon
                        _buildThumbnails(context, previews, accent),

                        SizedBox(width: 14.w),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                list.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: vc.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              // Dynamic item count
                              Row(
                                children: [
                                  Icon(Icons.list_alt_rounded,
                                      size: 12.sp, color: vc.onSurfaceMuted),
                                  SizedBox(width: 4.w),
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
                            ],
                          ),
                        ),

                        // Actions column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onRename();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Icon(Icons.edit_outlined,
                                    color: vc.onSurfaceMuted, size: 17.sp),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onDelete();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Icon(Icons.delete_outline_rounded,
                                    color: Colors.red.shade300, size: 17.sp),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(Icons.chevron_right_rounded,
                              color: vc.onSurfaceMuted, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails(
      BuildContext context, List<SavedProduct> previews, Color accent) {
    if (previews.isEmpty) {
      return Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.list_alt_rounded, color: accent, size: 26.sp),
      );
    }

    if (previews.length == 1) {
      return _thumb(context, previews[0].imageUrl, 56.w, 12.r);
    }

    final rows = [
      previews.take(2).toList(),
      previews.length > 2
          ? previews.skip(2).take(2).toList()
          : <SavedProduct>[],
    ];

    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: Column(
        children: rows
            .where((r) => r.isNotEmpty)
            .map((row) => Expanded(
                  child: Row(
                    children: row
                        .map((p) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(1.w),
                                child:
                                    _thumb(context, p.imageUrl, double.infinity, 6.r),
                              ),
                            ))
                        .toList(),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _thumb(BuildContext context, String? url, double size, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        // Dark surface behind transparent product PNGs; light grey in light mode.
        color: context.isDark
            ? context.vColors.surfaceVariant
            : const Color(0xFFF5F5F5),
        child: url != null
            ? CustomImageViewer(
                path: url, fit: BoxFit.contain, borderRadius: radius)
            : Icon(Icons.shopping_bag_outlined,
                color: Colors.grey.shade400, size: 16.sp),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create / Rename sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NewListSheet extends StatefulWidget {
  final Future<void> Function(String name) onCreated;
  final String? initial;
  final String title;
  final String buttonLabel;

  const _NewListSheet({
    required this.onCreated,
    this.initial,
    this.title = 'New List',
    this.buttonLabel = 'Create List',
  });

  @override
  State<_NewListSheet> createState() => _NewListSheetState();
}

class _NewListSheetState extends State<_NewListSheet> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    await widget.onCreated(name);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: vc.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.list_alt_rounded,
                    color: AppColor.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: vc.onSurface,
                    ),
                  ),
                  Text(
                    'Give your list a name.',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        color: vc.onSurfaceMuted),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
                fontSize: 15.sp, fontFamily: 'Inter', color: vc.onSurface),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'e.g. Weekly Groceries',
              hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: vc.onSurfaceMuted,
                  fontFamily: 'Inter'),
              filled: true,
              fillColor: vc.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColor.primary, width: 1.5),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              prefixIcon: Icon(Icons.drive_file_rename_outline_rounded,
                  color: vc.onSurfaceMuted, size: 20.sp),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 18.sp, color: vc.onSurfaceMuted),
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: CustomElevatedButton(
              onPressed: (_controller.text.trim().isEmpty || _isLoading)
                  ? null
                  : _submit,
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              isLoading: _isLoading,
              loaderSize: 22.w,
              text: widget.buttonLabel,
            ),
          ),
        ],
      ),
    );
  }
}
