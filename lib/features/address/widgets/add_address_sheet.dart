import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';

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

  // Default center: Kathmandu
  LatLng _selectedLatLng = const LatLng(27.7172, 85.3240);
  String _locationDescription = 'Tap on map to select location';

  String _addressType = 'home';

  final _nameCtrl = TextEditingController();
  final _landMarkCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAddress;
    if (existing != null) {
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

  Future<void> _onMapTap(LatLng pos) async {
    setState(() {
      _selectedLatLng = pos;
      _isGeocoding = true;
    });
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final desc = [p.subLocality, p.locality, p.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
        setState(() => _locationDescription = desc);
      }
    } catch (_) {
      setState(() => _locationDescription =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
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

  Future<void> _save() async {
    if (_locationDescription.isEmpty ||
        _locationDescription == 'Tap on map to select location') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on map')));
      return;
    }
    setState(() => _isSaving = true);
    final success = await ref.read(addressProvider.notifier).addAddress(
          userId: widget.userId,
          lat: _selectedLatLng.latitude,
          long: _selectedLatLng.longitude,
          description: _locationDescription,
          addressType: _addressType,
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          landMark: _landMarkCtrl.text.trim().isEmpty
              ? null
              : _landMarkCtrl.text.trim(),
          locality: _localityCtrl.text.trim().isEmpty
              ? null
              : _localityCtrl.text.trim(),
          floor: _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
          phoneNumber:
              _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          houseNumber:
              _houseCtrl.text.trim().isEmpty ? null : _houseCtrl.text.trim(),
        );
    setState(() => _isSaving = false);
    if (success && mounted) Navigator.pop(context);
  }

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

              // --- Google Map section ---
              Stack(
                children: [
                  SizedBox(
                    height: 260.h,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLatLng,
                        zoom: 14,
                      ),
                      onMapCreated: (c) => _mapController = c,
                      onTap: _onMapTap,
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedLatLng,
                          draggable: true,
                          onDragEnd: _onMapTap,
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                    ),
                  ),
                  // Search bar
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
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13.sp),
                          prefixIcon: Icon(Icons.search,
                              color: AppColor.textMuted, size: 20.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onSubmitted: _searchLocation,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                  // Go to current location
                  Positioned(
                    bottom: 12.h,
                    left: 12.w,
                    child: GestureDetector(
                      onTap: _goToCurrentLocation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
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
              ),

              // Delivering to banner
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: AppColor.primary, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _isGeocoding
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              _locationDescription,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textBlack87),
                            ),
                    ),
                  ],
                ),
              ),

              // --- Form section ---
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enter complete address',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Address type chips
                      Text(
                        'Save address as *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColor.textBlack87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _TypeChip(
                            label: 'Home',
                            icon: Icons.home_rounded,
                            selected: _addressType == 'home',
                            onTap: () => setState(() => _addressType = 'home'),
                          ),
                          SizedBox(width: 8.w),
                          _TypeChip(
                            label: 'Office',
                            icon: Icons.business_rounded,
                            selected: _addressType == 'office',
                            onTap: () =>
                                setState(() => _addressType = 'office'),
                          ),
                          SizedBox(width: 8.w),
                          _TypeChip(
                            label: 'Others',
                            icon: Icons.location_on_rounded,
                            selected: _addressType == 'others',
                            onTap: () =>
                                setState(() => _addressType = 'others'),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      _FormField(
                          controller: _houseCtrl, hint: 'House / Flat no.'),
                      SizedBox(height: 10.h),
                      _FormField(
                          controller: _floorCtrl, hint: 'Floor (optional)'),
                      SizedBox(height: 10.h),
                      _FormField(
                          controller: _localityCtrl, hint: 'Area / Locality'),
                      SizedBox(height: 10.h),
                      _FormField(controller: _landMarkCtrl, hint: 'Landmark'),
                      SizedBox(height: 14.h),
                      Text(
                        'Receiver name for seamless delivery experience.',
                        style: TextStyle(
                            fontSize: 12.sp, color: AppColor.textMuted),
                      ),
                      SizedBox(height: 8.h),
                      _FormField(controller: _nameCtrl, hint: 'Receiver name'),
                      SizedBox(height: 10.h),
                      Text(
                        'Receiver phone number',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: AppColor.textBlack87),
                      ),
                      SizedBox(height: 8.h),
                      _FormField(
                        controller: _phoneCtrl,
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Save Address',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.secondary.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColor.secondary : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16.sp,
                color: selected ? AppColor.secondary : AppColor.textMuted),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColor.secondary : AppColor.textBlack87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColor.primary),
        ),
      ),
    );
  }
}
