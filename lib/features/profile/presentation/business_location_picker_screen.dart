import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/data/location_search_service.dart';
import 'package:lets_vhandar/features/address/widgets/address_map_picker.dart';

class BusinessLocationResult {
  final LatLng latLng;
  final String address;

  const BusinessLocationResult({required this.latLng, required this.address});
}

/// Full-screen map picker for business location.
/// Returns [BusinessLocationResult] via Navigator.pop, or null if cancelled.
class BusinessLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLatLng;
  final String? initialAddress;

  const BusinessLocationPickerScreen({
    super.key,
    this.initialLatLng,
    this.initialAddress,
  });

  @override
  State<BusinessLocationPickerScreen> createState() =>
      _BusinessLocationPickerScreenState();
}

class _BusinessLocationPickerScreenState
    extends State<BusinessLocationPickerScreen> {
  static const _defaultLatLng = LatLng(27.7172, 85.3240); // Kathmandu

  GoogleMapController? _mapController;
  late LatLng _selectedLatLng;
  String _locationAddress = 'Tap on map to pin your business location';
  bool _isGeocoding = false;
  bool _isSearching = false;

  final _searchService = LocationSearchService();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounceTimer;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLatLng ?? _defaultLatLng;
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _locationAddress = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onMapTap(LatLng pos) async {
    setState(() {
      _selectedLatLng = pos;
      _isGeocoding = true;
      _suggestions = [];
      _searchCtrl.clear();
    });
    await _reverseGeocode(pos);
    setState(() => _isGeocoding = false);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.name,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).toSet().toList();
        setState(() => _locationAddress =
            parts.isEmpty ? _coordsString(pos) : parts.join(', '));
      } else {
        setState(() => _locationAddress = _coordsString(pos));
      }
    } catch (e) {
      log('Geocoding error: $e');
      setState(() => _locationAddress = _coordsString(pos));
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final latlng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
      await _onMapTap(latlng);
    } catch (e) {
      log('Current location error: $e');
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final results = await _searchService.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  void _onSuggestionTap(LocationSuggestion s) {
    setState(() {
      _selectedLatLng = s.latLng;
      _locationAddress = s.displayName;
      _suggestions = [];
      _searchCtrl.text = s.displayName;
    });
    _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(s.latLng, 15));
  }

  String _coordsString(LatLng pos) =>
      '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Scaffold(
      backgroundColor: vc.surface,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pick Business Location',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map takes all available space
          Expanded(
            child: AddressMapPicker(
              selectedLatLng: _selectedLatLng,
              searchController: _searchCtrl,
              isSearching: _isSearching,
              suggestions: _suggestions,
              onMapCreated: (ctrl) => _mapController = ctrl,
              onMapTap: _onMapTap,
              onCurrentLocationTap: _goToCurrentLocation,
              onSearchSubmitted: _onSearchChanged,
              onSearchChanged: _onSearchChanged,
              onSuggestionTap: _onSuggestionTap,
              onClearSearch: () {
                _searchCtrl.clear();
                setState(() => _suggestions = []);
              },
            ),
          ),

          // Bottom confirm bar
          Container(
            decoration: BoxDecoration(
              color: vc.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
                16.w, 14.h, 16.w, MediaQuery.of(context).padding.bottom + 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isGeocoding
                          ? Padding(
                              padding: EdgeInsets.all(8.w),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primary,
                              ),
                            )
                          : Icon(Icons.location_on,
                              color: AppColor.primary, size: 18.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: vc.onSurfaceMuted,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _locationAddress,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: vc.onSurface,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGeocoding
                        ? null
                        : () => Navigator.pop(
                              context,
                              BusinessLocationResult(
                                latLng: _selectedLatLng,
                                address: _locationAddress,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColor.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
