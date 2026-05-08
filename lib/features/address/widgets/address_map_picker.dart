import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/widgets/tff.dart';

/// Google Map with search bar and "Go to current location" button.
class AddressMapPicker extends StatelessWidget {
  final LatLng selectedLatLng;
  final TextEditingController searchController;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onMapTap;
  final VoidCallback onCurrentLocationTap;
  final void Function(String) onSearchSubmitted;

  const AddressMapPicker({
    super.key,
    required this.selectedLatLng,
    required this.searchController,
    required this.onMapCreated,
    required this.onMapTap,
    required this.onCurrentLocationTap,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- Map ---
        SizedBox(
          height: 260.h,
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

        // --- Search bar ---
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: CustomTextField(
              controller: searchController,
              hintText: 'Search location...',
              prefixIcon: Icon(Icons.search, color: AppColor.textMuted, size: 20.sp),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              onSubmitted: onSearchSubmitted,
              textInputAction: TextInputAction.search,
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
                  Icon(Icons.my_location,
                      size: 16.sp, color: AppColor.primary),
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
