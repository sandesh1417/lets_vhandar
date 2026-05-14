import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';
import 'package:lets_vhandar/widgets/tff.dart';

import '../data/location_search_service.dart';

/// Google Map with search bar and "Go to current location" button.
class AddressMapPicker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- Map ---
        SizedBox(
          height: height ?? 260.h,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 14,
            ),
            onMapCreated: onMapCreated,
            onTap: onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLatLng,
                draggable: true,
                onDragEnd: onMapTap,
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),

        Positioned(
          top: 12.h,
          left: 12.w,
          right: 12.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: CustomTextField(
              controller: searchController,
              hintText: 'Search for area, street name...',
              prefixIcon: isSearching
                  ? const UnconstrainedBox(
                      child: CustomCircularLoader(
                        size: 14,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.search, color: AppColor.textMuted, size: 20.sp),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: onClearSearch,
                      icon: Icon(Icons.close, size: 18.sp),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              onSubmitted: onSearchSubmitted,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),

        // --- Suggestions List ---
        if (suggestions.isNotEmpty)
          Positioned(
            top: 65.h,
            left: 12.w,
            right: 12.w,
            child: Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.location_on,
                        color: AppColor.textMuted, size: 18.sp),
                    title: Text(
                      suggestion.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    onTap: () => onSuggestionTap(suggestion),
                  );
                },
              ),
            ),
          ),

        // --- Current location button ---
        Positioned(
          bottom: 12.h,
          left: 12.w,
          child: GestureDetector(
            onTap: onCurrentLocationTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, size: 16.sp, color: AppColor.primary),
                  SizedBox(width: 6.w),
                  Text(
                    'Go to current location',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
