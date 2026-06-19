part of '../order_summary_screen.dart';

// ── Header stat cell ──────────────────────────────────────────────────────────
Widget _vDivider() => Container(
    width: 1, height: 32, color: Colors.white.withValues(alpha: 0.25));

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _HeaderStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: Colors.white.withValues(alpha: 0.80), size: 14.sp),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white.withValues(alpha: 0.70))),
          ],
        ),
      );
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VhandarColors vc;
  const _SectionHeader({required this.title, required this.vc});

  @override
  Widget build(BuildContext context) => Row(
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
          Text(title,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface)),
        ],
      );
}

class _SummaryTile extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final IconData icon;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7.r)),
              child: Icon(icon, color: color, size: 13.sp),
            ),
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: vc.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 0.5.h),
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: vc.onSurface,
                  fontWeight: FontWeight.w600)),
          Text(sub, style: TextStyle(fontSize: 9.sp, color: vc.onSurfaceMuted)),
        ],
      ),
    );
  }
}
