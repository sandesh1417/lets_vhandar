import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/home/providers/warehouse_provider.dart';

import '../data/location_search_service.dart';
import 'address_form.dart';
import 'address_location_banner.dart';
import 'address_map_picker.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

/// Opens the add/edit address bottom sheet.
Future<void> showAddAddressSheet(
  BuildContext context, {
  required String userId,
  AddressModel? existingAddress,
}) {
  return showAppSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddAddressSheet(
      userId: userId,
      existingAddress: existingAddress,
    ),
  );
}

class AddAddressSheet extends ConsumerStatefulWidget {
  final String userId;
  final AddressModel? existingAddress;

  const AddAddressSheet({
    super.key,
    required this.userId,
    this.existingAddress,
  });

  @override
  ConsumerState<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? _mapController;

  // Map state
  LatLng _selectedLatLng = const LatLng(27.7172, 85.3240);
  String _locationDescription = 'Tap on map to select location';
  bool _isGeocoding = false;
  bool _isSearching = false;
  String? _locationError;

  // Search suggestions
  final _searchService = LocationSearchService();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounceTimer;

  // Form state
  String _addressType = 'home';
  bool _isSaving = false;
  bool _isLocationConfirmed = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _landMarkCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    _populateFromExisting();
    _isLocationConfirmed = widget.existingAddress != null;
  }

  void _populateFromExisting() {
    final existing = widget.existingAddress;
    if (existing == null) return;

    _selectedLatLng = LatLng(existing.lat ?? 27.7172, existing.long ?? 85.3240);
    _locationDescription = existing.description ?? '';
    _addressType = existing.addressType ?? 'home';
    _nameCtrl.text = existing.name ?? '';
    _landMarkCtrl.text = existing.landMark ?? '';
    _localityCtrl.text = existing.locality ?? '';
    _floorCtrl.text = existing.floor ?? '';
    _phoneCtrl.text = existing.phoneNumber ?? '';
    _houseCtrl.text = existing.houseNumber ?? '';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _debounceTimer?.cancel();
    _nameCtrl.dispose();
    _landMarkCtrl.dispose();
    _localityCtrl.dispose();
    _floorCtrl.dispose();
    _phoneCtrl.dispose();
    _houseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Map callbacks
  // ---------------------------------------------------------------------------

  Future<void> _onMapTap(LatLng pos) async {
    setState(() {
      _selectedLatLng = pos;
      _isGeocoding = true;
      _locationError = null;
    });

    await _reverseGeocode(pos);
    if (!mounted) return;
    _validateDeliveryRadius(pos);
    setState(() => _isGeocoding = false);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.name,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).toSet().toList();

        setState(() => _locationDescription =
            parts.isEmpty ? _coordsString(pos) : parts.join(', '));
      } else {
        setState(() => _locationDescription = _coordsString(pos));
      }
    } catch (e) {
      log('Geocoding error: $e');
      setState(() => _locationDescription = _coordsString(pos));
    }
  }

  void _validateDeliveryRadius(LatLng pos) {
    try {
      final warehouses = ref.read(warehouseProvider).valueOrNull ?? [];
      if (warehouses.isEmpty) return;

      final isWithinRadius = warehouses.any((wh) {
        if (wh.lat == null || wh.long == null || wh.deliveryRadius == null) {
          return false;
        }
        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          wh.lat!,
          wh.long!,
        );
        return distance <= (wh.deliveryRadius!.toDouble() * 1000);
      });

      if (!isWithinRadius) {
        setState(() =>
            _locationError = 'Selected location is outside our delivery area.');
      }
    } catch (e) {
      log('Warehouse radius check error: $e');
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      // 1. Location services (GPS) must be on.
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        CustomSnackbar.error(context,
            message: 'Location is turned off. Please enable GPS.');
        await Geolocator.openLocationSettings();
        return;
      }

      // 2. Permission.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        CustomSnackbar.error(context,
            message:
                'Location permission is blocked. Enable it from Settings.');
        await Geolocator.openAppSettings();
        return;
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        CustomSnackbar.error(context,
            message: 'Location permission is needed to use your location.');
        return;
      }

      // 3. Fetch position (with a loading state + timeout).
      setState(() => _isGeocoding = true);
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      if (!mounted) return;
      final latlng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
      await _onMapTap(latlng);
    } catch (e) {
      log('Current location error: $e');
      if (!mounted) return;
      setState(() => _isGeocoding = false);
      CustomSnackbar.error(context,
          message: 'Could not get your location. Please try again.');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _suggestions = []);
        return;
      }

      setState(() => _isSearching = true);
      final suggestions = await _searchService.getSuggestions(query);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _isSearching = false;
      });
    });
  }

  Future<void> _selectSuggestion(LocationSuggestion suggestion) async {
    setState(() {
      _suggestions = [];
      _searchCtrl.text = suggestion.displayName;
      _isSearching = true;
    });

    LatLng? latLng = suggestion.latLng;
    if (latLng == null && suggestion.placeId != null) {
      latLng = await _searchService.getPlaceLatLng(suggestion.placeId!);
    }

    if (!mounted) return;
    setState(() => _isSearching = false);
    if (latLng == null) {
      setState(() => _locationError = 'Could not load this location.');
      return;
    }

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    await _onMapTap(latLng);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
      _locationError = null;
      _suggestions = [];
    });
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latlng = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
        await _onMapTap(latlng);
      } else {
        setState(() => _locationError = 'No locations found for "$query"');
      }
    } catch (e) {
      log('Search error: $e');
      setState(() => _locationError =
          'Could not find location. Please try a more specific address.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Save / Update
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (_locationDescription.isEmpty ||
        _locationDescription == 'Tap on map to select location') {
      setState(() => _locationError = 'Please select a location on the map');
      return;
    }
    if (_locationError != null) return;

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    // Collect trimmed optional values
    final name = _trimOrNull(_nameCtrl);
    final landMark = _trimOrNull(_landMarkCtrl);
    final locality = _trimOrNull(_localityCtrl);
    final floor = _trimOrNull(_floorCtrl);
    final phone = _trimOrNull(_phoneCtrl);
    final house = _trimOrNull(_houseCtrl);

    final notifier = ref.read(addressProvider.notifier);
    final bool success;

    if (_isEditing) {
      success = await notifier.updateAddress(
        userId: widget.userId,
        addressId: widget.existingAddress!.id!,
        lat: _selectedLatLng.latitude,
        long: _selectedLatLng.longitude,
        description: _locationDescription,
        addressType: _addressType,
        name: name,
        landMark: landMark,
        locality: locality,
        floor: floor,
        phoneNumber: phone,
        houseNumber: house,
      );
    } else {
      success = await notifier.addAddress(
        userId: widget.userId,
        lat: _selectedLatLng.latitude,
        long: _selectedLatLng.longitude,
        description: _locationDescription,
        addressType: _addressType,
        name: name,
        landMark: landMark,
        locality: locality,
        floor: floor,
        phoneNumber: phone,
        houseNumber: house,
      );
    }

    setState(() => _isSaving = false);
    if (success && mounted) Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String? _trimOrNull(TextEditingController ctrl) {
    final value = ctrl.text.trim();
    return value.isEmpty ? null : value;
  }

  String _coordsString(LatLng pos) =>
      '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.8,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return CustomPaint(
          painter: _DashedTopBorderPainter(
            color: context.vColors.divider,
            radius: 24.r,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.vColors.scaffoldBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // --- Drag handle ---
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: context.vColors.divider,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),

                if (!_isLocationConfirmed) ...[
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 8.w, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Delivery Location',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.vColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Search or tap on the map to pin your location',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.vColors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: context.vColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                color: context.vColors.onSurfaceMuted,
                                size: 16.sp),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                  Divider(
                      height: 14.h,
                      thickness: 1,
                      color: context.vColors.divider),
                  // Big Map Picker
                  Expanded(
                    child: AddressMapPicker(
                      height: double.infinity,
                      selectedLatLng: _selectedLatLng,
                      searchController: _searchCtrl,
                      isSearching: _isSearching,
                      suggestions: _suggestions,
                      onMapCreated: (c) => _mapController = c,
                      onMapTap: _onMapTap,
                      onCurrentLocationTap: _goToCurrentLocation,
                      onSearchSubmitted: _searchLocation,
                      onSearchChanged: _onSearchChanged,
                      onSuggestionTap: _selectSuggestion,
                      onClearSearch: () {
                        _searchCtrl.clear();
                        setState(() => _suggestions = []);
                      },
                    ),
                  ),
                  // Location Banner
                  AddressLocationBanner(
                    description: _locationDescription,
                    isGeocoding: _isGeocoding,
                    error: _locationError,
                  ),
                  // Confirm Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.w,
                        4.h,
                        16.w,
                        MediaQuery.of(context).padding.bottom + 12.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: (_locationDescription.isEmpty ||
                                _locationDescription ==
                                    'Tap on map to select location' ||
                                _locationError != null ||
                                _isGeocoding)
                            ? null
                            : () =>
                                setState(() => _isLocationConfirmed = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.secondary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF9C9C9C),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Small Location Summary Banner
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.vColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: context.vColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppColor.primary, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _locationDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.vColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        TextButton(
                          onPressed: () =>
                              setState(() => _isLocationConfirmed = false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.vColors.surface,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24.r)),
                      ),
                      child: AddressForm(
                        formKey: _formKey,
                        scrollController: scrollController,
                        addressType: _addressType,
                        onAddressTypeChanged: (type) =>
                            setState(() => _addressType = type),
                        houseCtrl: _houseCtrl,
                        floorCtrl: _floorCtrl,
                        localityCtrl: _localityCtrl,
                        landMarkCtrl: _landMarkCtrl,
                        nameCtrl: _nameCtrl,
                        phoneCtrl: _phoneCtrl,
                        isSaving: _isSaving,
                        isEditing: _isEditing,
                        onSave: _save,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),   // Container
        );   // CustomPaint
      },
    );
  }
}

class _DashedTopBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedTopBorderPainter({
    required this.color,
    required this.radius,
  });

  static const double strokeWidth = 1.5;
  static const double dashWidth = 7;
  static const double dashSpace = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Path: bottom-left → up left side → top-left arc → top → top-right arc → down right side → bottom-right
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedTopBorderPainter old) =>
      old.color != color || old.radius != radius;
}
