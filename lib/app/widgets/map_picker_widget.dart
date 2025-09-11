import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

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
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _hasError = false;

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

      // Check if we have initial coordinates
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _selectedLocation = LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
        _selectedAddress = widget.initialAddress ?? 'selected_location'.tr;
      } else {
        // Try to get current location
        final position = await _getCurrentLocation();
        if (position != null) {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _selectedAddress = await _getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } else {
          // Use default location
          _selectedLocation = _defaultLocation;
          _selectedAddress = 'muscat_oman'.tr;
        }
      }

      // Automatically notify parent of initial location
      if (_selectedLocation != null) {
        widget.onLocationSelected(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
          _selectedAddress,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // For now, return a formatted coordinate string
    // You can integrate with a geocoding service like Google Places API later
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });

    // Get address and immediately notify parent
    _getAddressFromCoordinates(location.latitude, location.longitude).then((
      address,
    ) {
      setState(() {
        _selectedAddress = address;
      });

      // Automatically notify parent of location change
      widget.onLocationSelected(location.latitude, location.longitude, address);
    });
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
    });

    // Get address and immediately notify parent
    _getAddressFromCoordinates(
      newPosition.latitude,
      newPosition.longitude,
    ).then((address) {
      setState(() {
        _selectedAddress = address;
      });

      // Automatically notify parent of location change
      widget.onLocationSelected(
        newPosition.latitude,
        newPosition.longitude,
        address,
      );
    });
  }

  void _centerOnCurrentLocation() async {
    final position = await _getCurrentLocation();
    if (position != null && _mapController != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

      setState(() {
        _selectedLocation = latLng;
      });

      // Get address and immediately notify parent
      _getAddressFromCoordinates(position.latitude, position.longitude).then((
        address,
      ) {
        setState(() {
          _selectedAddress = address;
        });

        // Automatically notify parent of location change
        widget.onLocationSelected(
          position.latitude,
          position.longitude,
          address,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'loading_map'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'map_not_available'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'check_connection'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initializeLocation,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('retry'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedLocation == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'no_location_available'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Google Map
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15,
              ),
              onTap: _onMapTap,
              myLocationEnabled: true,
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
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    }
                  : {},
            ),

            // Current Location Button
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _centerOnCurrentLocation,
                  icon: const Icon(
                    Icons.my_location,
                    color: Colors.black87,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),

            // Instructions Overlay
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'tap_drag_pin'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
