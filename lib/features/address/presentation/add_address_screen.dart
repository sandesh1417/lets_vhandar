import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/home/providers/warehouse_provider.dart';

import '../data/location_search_service.dart';
import '../widgets/address_form.dart';
import '../widgets/address_location_banner.dart';
import '../widgets/address_map_picker.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final String userId;
  final AddressModel? existingAddress;

  const AddAddressScreen({
    super.key,
    required this.userId,
    this.existingAddress,
  });

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  GoogleMapController? _mapController;

  LatLng _selectedLatLng = const LatLng(27.7172, 85.3240);
  String _locationDescription = 'Tap on map to select location';
  bool _isGeocoding = false;
  bool _isSearching = false;
  String? _locationError;

  final _searchService = LocationSearchService();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounceTimer;

  String _addressType = 'home';
  bool _isSaving = false;
  bool _isLocationConfirmed = false;
  bool _submitted = false;

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
    final e = widget.existingAddress;
    if (e == null) return;
    _selectedLatLng = LatLng(e.lat ?? 27.7172, e.long ?? 85.3240);
    _locationDescription = e.description ?? '';
    _addressType = e.addressType ?? 'home';
    _nameCtrl.text = e.name ?? '';
    _landMarkCtrl.text = e.landMark ?? '';
    _localityCtrl.text = e.locality ?? '';
    _floorCtrl.text = e.floor ?? '';
    _phoneCtrl.text = e.phoneNumber ?? '';
    _houseCtrl.text = e.houseNumber ?? '';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _nameCtrl.dispose();
    _landMarkCtrl.dispose();
    _localityCtrl.dispose();
    _floorCtrl.dispose();
    _phoneCtrl.dispose();
    _houseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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
      final isWithin = warehouses.any((wh) {
        if (wh.lat == null || wh.long == null || wh.deliveryRadius == null) {
          return false;
        }
        final d = Geolocator.distanceBetween(
            pos.latitude, pos.longitude, wh.lat!, wh.long!);
        return d <= (wh.deliveryRadius!.toDouble() * 1000);
      });
      if (!isWithin) {
        setState(() =>
            _locationError = 'Vhandar is not available at your location.');
        _showLocationNotServiceablePopup();
      }
    } catch (e) {
      log('Radius check error: $e');
    }
  }

  void _showLocationNotServiceablePopup() {
    AppHaptics.error(); // location rejected — distinct error double-pulse
    final vc = context.vColors;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, bottomPad + 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: vc.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SvgPicture.asset(
              'assets/images/delivery-locatio-icon.svg',
              width: 100.w,
              height: 100.w,
            ),
            SizedBox(height: 20.h),
            Text(
              'Vhandar is not available at your location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We will notify you when Vhandar becomes available at your location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurfaceMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: CustomElevatedButton(
                onPressed: () => context.pop(),
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                text: 'Change Location',
              ),
            ),
          ],
        ),
      ),
    );
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
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        CustomSnackbar.error(context,
            message:
                'Location permission is blocked. Enable it from Settings.');
        await Geolocator.openAppSettings();
        return;
      }
      if (perm == LocationPermission.denied) {
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
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (query.length < 2) {
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

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_locationDescription.isEmpty ||
        _locationDescription == 'Tap on map to select location') {
      setState(() => _locationError = 'Please select a location on the map');
      return;
    }
    if (_locationError != null) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppHaptics.error();
      return;
    }

    setState(() => _isSaving = true);

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
        name: _trimOrNull(_nameCtrl),
        landMark: _trimOrNull(_landMarkCtrl),
        locality: _trimOrNull(_localityCtrl),
        floor: _trimOrNull(_floorCtrl),
        phoneNumber: _trimOrNull(_phoneCtrl),
        houseNumber: _trimOrNull(_houseCtrl),
      );
    } else {
      success = await notifier.addAddress(
        userId: widget.userId,
        lat: _selectedLatLng.latitude,
        long: _selectedLatLng.longitude,
        description: _locationDescription,
        addressType: _addressType,
        name: _trimOrNull(_nameCtrl),
        landMark: _trimOrNull(_landMarkCtrl),
        locality: _trimOrNull(_localityCtrl),
        floor: _trimOrNull(_floorCtrl),
        phoneNumber: _trimOrNull(_phoneCtrl),
        houseNumber: _trimOrNull(_houseCtrl),
      );
    }

    setState(() => _isSaving = false);
    if (success && mounted) context.pop();
  }

  String? _trimOrNull(TextEditingController ctrl) {
    final v = ctrl.text.trim();
    return v.isEmpty ? null : v;
  }

  String _coordsString(LatLng pos) =>
      '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      resizeToAvoidBottomInset: true,
      isScrollable: false,
      bottomSafeArea: false,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isLocationConfirmed
              ? (_isEditing ? 'Edit Address' : 'Enter Address Details')
              : 'Select Delivery Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: _isLocationConfirmed
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(1.h),
                child: const Divider(
                    height: 1, thickness: 1, color: Colors.white24),
              ),
      ),
      body: _isLocationConfirmed ? _buildForm() : _buildMapPicker(),
    );
  }

  Widget _buildMapPicker() {
    final vc = context.vColors;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final bool noLocation = _locationDescription.isEmpty ||
        _locationDescription == 'Tap on map to select location';

    return Column(
      children: [
        // ── Map ──────────────────────────────────────────────────────────────
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

        // ── Bottom action area ────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, bottomPad + 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag pill
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: vc.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Location banner
              AddressLocationBanner(
                description: _locationDescription,
                isGeocoding: _isGeocoding,
                error: _locationError,
              ),
              SizedBox(height: 12.h),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: CustomElevatedButton(
                  // Always tappable; preconditions are surfaced on tap
                  // (banner error for no location, popup for out-of-area).
                  onPressed: () {
                    if (_isGeocoding) return;
                    if (noLocation) {
                      setState(() => _locationError =
                          'Please select a location on the map');
                      return;
                    }
                    if (_locationError != null) {
                      _showLocationNotServiceablePopup();
                      return;
                    }
                    setState(() => _isLocationConfirmed = true);
                  },
                  backgroundColor: AppColor.secondary,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_rounded,
                  iconSize: 18.sp,
                  text: 'Confirm Location',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final vc = context.vColors;
    return Column(
      children: [
        // Location summary banner
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: AppColor.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: AppColor.primary, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _locationDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => setState(() => _isLocationConfirmed = false),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: vc.scaffoldBg,
            child: AddressForm(
              formKey: _formKey,
              scrollController: _scrollController,
              addressType: _addressType,
              onAddressTypeChanged: (t) => setState(() => _addressType = t),
              houseCtrl: _houseCtrl,
              floorCtrl: _floorCtrl,
              localityCtrl: _localityCtrl,
              landMarkCtrl: _landMarkCtrl,
              nameCtrl: _nameCtrl,
              phoneCtrl: _phoneCtrl,
              isSaving: _isSaving,
              isEditing: _isEditing,
              submitted: _submitted,
              onSave: _save,
            ),
          ),
        ),
      ],
    );
  }
}
