import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';

class TrackingView extends StatefulWidget {
  final ServiceBooking booking;

  const TrackingView({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView>
    with TickerProviderStateMixin {
  static const String mapboxAccessToken =
      "pk.eyJ1IjoibW9ra3MiLCJhIjoiY20zdno3MXl1MHozNzJxcXp5bmdvbTllYyJ9.Ed_O6F-c2IZJE9DoCyPZ2Q";

  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLocation;
  LatLng? _providerLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _routeDistance;
  String? _routeDuration;
  Timer? _locationUpdateTimer;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _truckController;

  // Service provider tracking
  double _currentProgress = 0.0;
  String _serviceStatus = 'On the way';
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
    _startLocationTracking();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _truckController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _pulseController.dispose();
    _truckController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        // Simulate provider location (you'll get this from your backend)
        _providerLocation = LatLng(
            position.latitude + 0.01,
            position.longitude + 0.01
        );
      });

      await _setupMapMarkers();
      await _getRoute();
      _animateToFitRoute();
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }

  Future<void> _setupMapMarkers() async {
    if (_currentLocation == null || _providerLocation == null) return;

    // Custom marker for user location
    _markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Custom truck marker for provider (you can use custom icons here)
    _markers.add(
      Marker(
        markerId: const MarkerId("provider_location"),
        position: _providerLocation!,
        infoWindow: InfoWindow(title: widget.booking.providerName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Warning/Alert marker (like in your image)
    _markers.add(
      Marker(
        markerId: const MarkerId("alert_location"),
        position: LatLng(
          (_currentLocation!.latitude + _providerLocation!.latitude) / 2,
          (_currentLocation!.longitude + _providerLocation!.longitude) / 2,
        ),
        infoWindow: const InfoWindow(title: "Traffic Alert"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null || _providerLocation == null) return;

    final String url = "https://api.mapbox.com/directions/v5/mapbox/driving/"
        "${_currentLocation!.longitude},${_currentLocation!.latitude};"
        "${_providerLocation!.longitude},${_providerLocation!.latitude}"
        "?alternatives=true&geometries=geojson&steps=true&access_token=$mapboxAccessToken";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry']['coordinates'] as List;
        final distance = route['distance'] as double;
        final duration = route['duration'] as double;

        setState(() {
          _routeDistance = (distance / 1000).toStringAsFixed(1);
          _routeDuration = _formatDuration(duration.toInt());

          _routePoints = geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          _polylines.clear();

          // Main route (blue)
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("main_route"),
              points: _routePoints,
              color: Colors.blue,
              width: 6,
              patterns: [],
            ),
          );

          // Alternative route segments (orange, red, yellow like in image)
          _addAlternativeRouteSegments();
        });
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  void _addAlternativeRouteSegments() {
    if (_routePoints.length < 4) return;

    // Orange segment
    int orangeStart = (_routePoints.length * 0.2).round();
    int orangeEnd = (_routePoints.length * 0.4).round();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("orange_route"),
        points: _routePoints.sublist(orangeStart, orangeEnd),
        color: Colors.orange,
        width: 6,
      ),
    );

    // Red segment
    int redStart = (_routePoints.length * 0.6).round();
    int redEnd = (_routePoints.length * 0.8).round();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("red_route"),
        points: _routePoints.sublist(redStart, redEnd),
        color: Colors.red,
        width: 6,
      ),
    );

    // Yellow segment
    int yellowStart = (_routePoints.length * 0.1).round();
    int yellowEnd = (_routePoints.length * 0.3).round();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("yellow_route"),
        points: _routePoints.sublist(yellowStart, yellowEnd),
        color: Colors.yellow[700]!,
        width: 4,
      ),
    );
  }

  Future<void> _animateToFitRoute() async {
    if (_currentLocation == null || _providerLocation == null) return;

    final GoogleMapController controller = await _mapController.future;

    double minLat = min(_currentLocation!.latitude, _providerLocation!.latitude);
    double maxLat = max(_currentLocation!.latitude, _providerLocation!.latitude);
    double minLng = min(_currentLocation!.longitude, _providerLocation!.longitude);
    double maxLng = max(_currentLocation!.longitude, _providerLocation!.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateProviderLocation();
      _updateServiceStatus();
    });
  }

  void _updateProviderLocation() {
    if (_routePoints.isEmpty) return;

    setState(() {
      _currentProgress += 0.1;
      if (_currentProgress >= 1.0) {
        _currentProgress = 1.0;
        _serviceStatus = 'Arrived';
        _locationUpdateTimer?.cancel();
      }

      // Move provider along the route
      int pointIndex = (_currentProgress * (_routePoints.length - 1)).round();
      _providerLocation = _routePoints[pointIndex];

      // Update provider marker
      _markers.removeWhere((marker) => marker.markerId.value == "provider_location");
      _markers.add(
        Marker(
          markerId: const MarkerId("provider_location"),
          position: _providerLocation!,
          infoWindow: InfoWindow(title: widget.booking.providerName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
  }

  void _updateServiceStatus() {
    if (_currentProgress < 0.3) {
      _serviceStatus = 'On the way';
    } else if (_currentProgress < 0.8) {
      _serviceStatus = 'Nearby';
    } else if (_currentProgress < 1.0) {
      _serviceStatus = 'Almost there';
    } else {
      _serviceStatus = 'Arrived';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Custom AppBar
          _buildCustomAppBar(),

          // Service Details Card
          _buildServiceDetailsCard(),

          // Status Updates
          _buildStatusUpdates(),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      LucideIcons.chevronLeft,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),

                const Expanded(
                  child: Text(
                    'Tracking Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Call Provider Button
                GestureDetector(
                  onTap: () => _callProvider(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service Details Row
            Row(
              children: [
                _buildDetailColumn('Category', widget.booking.category),
                _buildDetailColumn('Type', widget.booking.type),
                _buildDetailColumn('Number', widget.booking.number.toString()),
                _buildDetailColumn('Duration', widget.booking.duration),
              ],
            ),

            const SizedBox(height: 20),

            // Provider Info Row
            Row(
              children: [
                // Provider Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.booking.providerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 25,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Provider Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.booking.providerPhone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // ID and Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ID ${widget.booking.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.booking.price} OMR',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status and ETA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _serviceStatus,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  if (_routeDuration != null)
                    Text(
                      'ETA: $_routeDuration',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdates() {
    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        children: [
          // My Location Button
          FloatingActionButton(
            mini: true,
            onPressed: _animateToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),

          const SizedBox(height: 12),

          // Refresh Button
          FloatingActionButton(
            mini: true,
            onPressed: _refreshTracking,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_serviceStatus) {
      case 'On the way':
        return Colors.orange;
      case 'Nearby':
        return Colors.blue;
      case 'Almost there':
        return Colors.purple;
      case 'Arrived':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _animateToCurrentLocation() async {
    if (_currentLocation == null) return;

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 16.0),
      ),
    );
  }

  void _refreshTracking() {
    _getCurrentLocation();
    Get.snackbar(
      'Tracking Updated',
      'Service location refreshed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _callProvider() {
    Get.snackbar(
      'Calling Provider',
      'Calling ${widget.booking.providerName}...',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}

// Service Booking Model
class ServiceBooking {
  final String id;
  final String category;
  final String type;
  final int number;
  final String duration;
  final String providerName;
  final String providerPhone;
  final String providerImage;
  final int price;

  ServiceBooking({
    required this.id,
    required this.category,
    required this.type,
    required this.number,
    required this.duration,
    required this.providerName,
    required this.providerPhone,
    required this.providerImage,
    required this.price,
  });
}
