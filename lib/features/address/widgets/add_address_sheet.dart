import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vhandar/features/address/domain/models/address_model.dart';
import 'package:vhandar/features/address/providers/address_provider.dart';
import 'package:vhandar/features/home/providers/warehouse_provider.dart';

import 'address_form.dart';
import 'address_location_banner.dart';
import 'address_map_picker.dart';

/// Opens the add/edit address bottom sheet.
Future<void> showAddAddressSheet(
  BuildContext context, {
  required String userId,
  AddressModel? existingAddress,
}) {
  return showModalBottomSheet(
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
  GoogleMapController? _mapController;

  // Map state
  LatLng _selectedLatLng = const LatLng(27.7172, 85.3240);
  String _locationDescription = 'Tap on map to select location';
  bool _isGeocoding = false;
  String? _locationError;

  // Form state
  String _addressType = 'home';
  bool _isSaving = false;

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
  }

  void _populateFromExisting() {
    final existing = widget.existingAddress;
    if (existing == null) return;

    _selectedLatLng =
        LatLng(existing.lat ?? 27.7172, existing.long ?? 85.3240);
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
    _validateDeliveryRadius(pos);

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

        setState(() => _locationDescription = parts.isEmpty
            ? _coordsString(pos)
            : parts.join(', '));
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
    } catch (_) {}
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latlng = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 15));
        await _onMapTap(latlng);
      }
    } catch (_) {}
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // --- Drag handle ---
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // --- Map picker ---
              AddressMapPicker(
                selectedLatLng: _selectedLatLng,
                searchController: _searchCtrl,
                onMapCreated: (c) => _mapController = c,
                onMapTap: _onMapTap,
                onCurrentLocationTap: _goToCurrentLocation,
                onSearchSubmitted: _searchLocation,
              ),

              // --- Location banner ---
              AddressLocationBanner(
                description: _locationDescription,
                isGeocoding: _isGeocoding,
                error: _locationError,
              ),

              // --- Form ---
              Expanded(
                child: AddressForm(
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
            ],
          ),
        );
      },
    );
  }
}
