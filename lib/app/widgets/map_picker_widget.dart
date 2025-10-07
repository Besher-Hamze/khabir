import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

// Full Screen Map Picker
class FullScreenMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const FullScreenMapPicker({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<FullScreenMapPicker> createState() => _FullScreenMapPickerState();
}

class _FullScreenMapPickerState extends State<FullScreenMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLocatingUser = false;

  // Default location (Muscat, Oman)
  static const LatLng _defaultLocation = LatLng(23.5880, 58.3829);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _selectedLocation = LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
        _selectedAddress = widget.initialAddress ?? 'Selected Location';
      } else {
        final position = await _getCurrentLocation();
        if (position != null) {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _selectedAddress = await _getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } else {
          _selectedLocation = _defaultLocation;
          _selectedAddress = 'Muscat, Oman';
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
  }

  void _onMapTap(LatLng location) {
    setState(() => _selectedLocation = location);
    _getAddressFromCoordinates(location.latitude, location.longitude).then((
      address,
    ) {
      setState(() => _selectedAddress = address);
    });
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() => _selectedLocation = newPosition);
    _getAddressFromCoordinates(
      newPosition.latitude,
      newPosition.longitude,
    ).then((address) {
      setState(() => _selectedAddress = address);
    });
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _isLocatingUser = true);

    final position = await _getCurrentLocation();
    if (position != null && _mapController != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16),
      );

      setState(() => _selectedLocation = latLng);
      final address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() => _selectedAddress = address);
    } else {
      Get.snackbar(
        'Error',
        'Unable to get current location. Please check permissions.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    setState(() => _isLocatingUser = false);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Get.back(
        result: {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'address': _selectedAddress,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.black87),
          ),
          title: Text(
            'select_location'.tr,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_selectedLocation != null)
              TextButton(
                onPressed: _confirmLocation,
                child: Text(
                  'confirm'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'loading_map'.tr,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              )
            : _hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'map_not_available'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'please_check_your_internet_connection'.tr,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _initializeLocation,
                      icon: Icon(Icons.refresh, size: 18),
                      label: Text('retry'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation ?? _defaultLocation,
                      zoom: 15,
                    ),
                    onTap: _onMapTap,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    markers: _selectedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected_location'),
                              position: _selectedLocation!,
                              draggable: true,
                              onDragEnd: _onMarkerDragEnd,
                              infoWindow: InfoWindow(
                                title: 'selected_location'.tr,
                                snippet: _selectedAddress,
                              ),
                            ),
                          }
                        : {},
                  ),

                  // Instructions
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'tap_anywhere_on_the_map_or_drag_the_pin_to_select_location'
                                  .tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Current Location Button
                  Positioned(
                    bottom: 180,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: _isLocatingUser
                          ? null
                          : _centerOnCurrentLocation,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      child: _isLocatingUser
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location),
                    ),
                  ),

                  // Selected Location Info Panel
                  if (_selectedLocation != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'selected_location'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedAddress,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _confirmLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'confirm_location'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// Compact Map Picker Widget
class MapPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final Function(double latitude, double longitude, String address)
  onLocationSelected;

  const MapPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  String _selectedAddress = '';
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
    _selectedAddress = widget.initialAddress ?? 'tap_to_select_location'.tr;
  }

  Future<void> _openFullScreenMap() async {
    final result = await Get.to(
      () => FullScreenMapPicker(
        initialLatitude: _selectedLatitude,
        initialLongitude: _selectedLongitude,
        initialAddress: _selectedAddress,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedAddress = result['address'];
      });

      widget.onLocationSelected(
        result['latitude'],
        result['longitude'],
        result['address'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullScreenMap,
      child: Container(
        height: 120, // Made smaller
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Stack(
          children: [
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedLatitude != null
                        ? Icons.location_on
                        : Icons.add_location,
                    size: 32,
                    color: _selectedLatitude != null
                        ? Colors.red
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedLatitude != null
                        ? 'location_selected'.tr
                        : 'select_location'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedLatitude != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: _selectedLatitude != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  if (_selectedLatitude != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'tap_to_change'.tr,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),

            // Open map button
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: _openFullScreenMap,
                  icon: const Icon(
                    Icons.open_in_full,
                    color: Colors.white,
                    size: 16,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ),

            // Status indicator
            if (_selectedLatitude != null)
              Positioned(
                bottom: 6,
                left: 6,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _selectedAddress,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
