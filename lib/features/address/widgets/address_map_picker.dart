import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';

import '../data/location_search_service.dart';

// Google Maps dark style (Aubergine-inspired minimal dark theme)
const _kDarkMapStyle = r'''
[
  {"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},
  {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
  {"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},
  {"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},
  {"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},
  {"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023747"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},
  {"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},
  {"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}
]
''';

/// Google Map with search bar and "Go to current location" button.
/// Automatically applies a dark style when the app is in dark mode.
class AddressMapPicker extends StatefulWidget {
  final LatLng selectedLatLng;
  final TextEditingController searchController;
  final bool isSearching;
  final List<LocationSuggestion> suggestions;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onMapTap;
  final VoidCallback onCurrentLocationTap;
  final void Function(String) onSearchSubmitted;
  final void Function(String) onSearchChanged;
  final void Function(LocationSuggestion) onSuggestionTap;
  final VoidCallback onClearSearch;
  final double? height;

  const AddressMapPicker({
    super.key,
    required this.selectedLatLng,
    required this.searchController,
    this.isSearching = false,
    this.suggestions = const [],
    required this.onMapCreated,
    required this.onMapTap,
    required this.onCurrentLocationTap,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    required this.onSuggestionTap,
    required this.onClearSearch,
    this.height,
  });

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  String? _mapStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newStyle = isDark ? _kDarkMapStyle : null;
    if (newStyle != _mapStyle) setState(() => _mapStyle = newStyle);
  }

  void _handleMapCreated(GoogleMapController controller) {
    widget.onMapCreated(controller);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final vc = context.vColors;

    final cardColor = isDark ? vc.surfaceVariant : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Search bar (PremiumSearchBar style) ─────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: vc.divider),
            ),
            child: Row(
              children: [
                widget.isSearching
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CustomCircularLoader(
                            size: 16, strokeWidth: 2, color: AppColor.primary),
                      )
                    : Icon(Icons.search_rounded,
                        color: AppColor.primary, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    onChanged: widget.onSearchChanged,
                    onSubmitted: widget.onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search area, street or landmark...',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: widget.onClearSearch,
                    child: Icon(Icons.close_rounded,
                        color: vc.onSurfaceMuted, size: 20.sp),
                  ),
              ],
            ),
          ),
        ),

        // ── Map + floating suggestions overlay ──────────────────────────────
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(27.7172, 85.3240), // Kathmandu
                    zoom: 14,
                  ),
                  onMapCreated: _handleMapCreated,
                  style: _mapStyle,
                  onTap: widget.onMapTap,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: widget.selectedLatLng,
                      draggable: true,
                      onDragEnd: widget.onMapTap,
                      // A tap that lands on the marker is routed here by the
                      // map (not to GoogleMap.onTap), so forward it to the same
                      // handler — otherwise tapping the pin selects nothing.
                      onTap: () => widget.onMapTap(widget.selectedLatLng),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  gestureRecognizers: const <Factory<
                      OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      EagerGestureRecognizer.new,
                    ),
                  },
                ),
              ),

              // ── Suggestions dropdown overlay ─────────────────────────────
              if (widget.suggestions.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 12.w,
                  right: 12.w,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12.r),
                    color: cardColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 220.h),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: widget.suggestions.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: vc.divider),
                          itemBuilder: (context, index) {
                            final s = widget.suggestions[index];
                            return InkWell(
                              onTap: () => widget.onSuggestionTap(s),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration: BoxDecoration(
                                        color: AppColor.primary
                                            .withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.location_on_rounded,
                                          color: AppColor.primary, size: 16.sp),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        s.displayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: vc.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Current location button ───────────────────────────────────
              Positioned(
                bottom: 12.h,
                left: 12.w,
                child: GestureDetector(
                  onTap: widget.onCurrentLocationTap,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.4 : 0.1),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.my_location,
                            size: 16.sp, color: AppColor.primary),
                        SizedBox(width: 6.w),
                        Text(
                          'Go to current location',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
