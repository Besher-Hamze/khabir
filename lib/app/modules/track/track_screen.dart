import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:khabir/app/modules/track/track_controller.dart';

class TrackingView extends StatefulWidget {
  final ServiceBooking booking;

  const TrackingView({Key? key, required this.booking}) : super(key: key);

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView>
    with TickerProviderStateMixin {
  static const String mapboxAccessToken =
      "pk.eyJ1IjoibW9ra3MiLCJhIjoiY20zdno3MXl1MHozNzJxcXp5bmdvbTllYyJ9.Ed_O6F-c2IZJE9DoCyPZ2Q";

  final Completer<GoogleMapController> _mapController = Completer();
  final LocationTrackingController _trackingController = Get.put(
    LocationTrackingController(),
  );

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _mapUpdateTimer;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _markerController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTracking();
    _startMapUpdateTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _markerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeTracking() {
    // Start tracking for this booking
    final orderId = int.tryParse(widget.booking.id) ?? 0;
    _trackingController.startTracking(orderId);
  }

  void _startMapUpdateTimer() {
    _mapUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateMapMarkers();
      _updateRoute();
    });
  }

  @override
  void dispose() {
    _mapUpdateTimer?.cancel();
    _pulseController.dispose();
    _markerController.dispose();
    _trackingController.stopTracking();
    super.dispose();
  }

  Future<void> _updateMapMarkers() async {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    if (userLocation == null || providerLocation == null) return;

    setState(() {
      _markers.clear();

      // User location marker
      _markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: userLocation,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Provider location marker with animation
      _markers.add(
        Marker(
          markerId: const MarkerId("provider_location"),
          position: providerLocation,
          infoWindow: InfoWindow(
            title: widget.booking.providerName,
            snippet: _trackingController.trackingStatus.value,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // Add accuracy circle if available
      final accuracy = _trackingController.accuracy.value;
      if (accuracy > 0) {
        _markers.add(
          Marker(
            markerId: const MarkerId("accuracy_indicator"),
            position: providerLocation,
            infoWindow: InfoWindow(title: "Accuracy: ${accuracy.toInt()}m"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
          ),
        );
      }
    });

    // Animate to show both locations
    _animateToFitRoute();
  }

  Future<void> _updateRoute() async {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    if (userLocation == null || providerLocation == null) return;

    await _getRoute(userLocation, providerLocation);
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?alternatives=true&geometries=geojson&steps=true&access_token=$mapboxAccessToken";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          final distance = route['distance'] as double;
          final duration = route['duration'] as double;

          // Update controller with route info
          _trackingController.routeDistance.value = (distance / 1000)
              .toStringAsFixed(1);
          _trackingController.routeDuration.value = _formatDuration(
            duration.toInt(),
          );

          final routePoints = geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          setState(() {
            _polylines.clear();

            // Main route
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("main_route"),
                points: routePoints,
                color: Colors.blue,
                width: 6,
                patterns: [],
              ),
            );

            // Add route history from location tracking
            final locationHistory = _trackingController.locationHistory;
            if (locationHistory.isNotEmpty) {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId("provider_path"),
                  points: locationHistory,
                  color: Colors.green,
                  width: 4,
                  patterns: [PatternItem.dash(10), PatternItem.gap(5)],
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  Future<void> _animateToFitRoute() async {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    if (userLocation == null || providerLocation == null) return;

    final GoogleMapController controller = await _mapController.future;

    double minLat = min(userLocation.latitude, providerLocation.latitude);
    double maxLat = max(userLocation.latitude, providerLocation.latitude);
    double minLng = min(userLocation.longitude, providerLocation.longitude);
    double maxLng = max(userLocation.longitude, providerLocation.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_trackingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_trackingController.hasError.value) {
          return _buildErrorWidget();
        }

        return Stack(
          children: [
            // Map
            _buildMap(),

            // Custom AppBar
            _buildCustomAppBar(),

            // Connection status indicator
            _buildConnectionStatus(),

            // Service Details Card
            _buildServiceDetailsCard(),

            // Status Updates
            _buildStatusUpdates(),
          ],
        );
      }),
    );
  }

  Widget _buildMap() {
    final userLocation = _trackingController.userLocation.value;

    if (userLocation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('getting_your_location'.tr),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: userLocation, zoom: 14.0),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController.complete(controller);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      trafficEnabled: true,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'tracking_error'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _trackingController.errorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final orderId = int.tryParse(widget.booking.id) ?? 0;
              _trackingController.startTracking(orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Positioned(
      top: 80,
      left: 16,
      child: Obx(() {
        final isConnected = _trackingController.isConnected.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'live_tracking'.tr : 'reconnecting'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
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

                Expanded(
                  child: Text(
                    'live_tracking'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                _buildDetailColumn('category'.tr, widget.booking.category),
                _buildDetailColumn('type'.tr, widget.booking.type),
                _buildDetailColumn(
                  'number'.tr,
                  widget.booking.number.toString(),
                ),
                _buildDetailColumn('duration'.tr, widget.booking.duration),
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
                    child: widget.booking.providerImage.startsWith('http')
                        ? Image.network(
                            widget.booking.providerImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 25,
                                color: Colors.white,
                              );
                            },
                          )
                        : Image.asset(
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

                      Obx(
                        () => Text(
                          _trackingController.providerStatus.value,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _trackingController.providerStatus.value
                                        .toLowerCase() ==
                                    'online'.tr
                                ? Colors.green
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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
                      'id'.tr + ' ${widget.booking.id}',
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
                        Text(
                          'price'.tr,
                          style: const TextStyle(
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

            // Real-time Status and ETA
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                            color: _trackingController.getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _trackingController.trackingStatus.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_trackingController
                            .estimatedArrival
                            .value
                            .isNotEmpty)
                          Text(
                            'ETA: ${_trackingController.estimatedArrival.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        if (_trackingController.routeDistance.value.isNotEmpty)
                          Text(
                            '${_trackingController.routeDistance.value} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
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
      top: 120,
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
            onPressed: () => _trackingController.refreshTracking(),
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.green),
          ),

          const SizedBox(height: 12),

          // Connection Check Button
          Obx(
            () => FloatingActionButton(
              mini: true,
              onPressed: () {
                _trackingController.checkConnection();
                // _trackingController.startTracking(
                //   int.tryParse(widget.booking.id) ?? 0,
                // );
              },
              backgroundColor: _trackingController.isConnected.value
                  ? Colors.green[100]
                  : Colors.red[100],
              child: Icon(
                _trackingController.isConnected.value
                    ? Icons.wifi
                    : Icons.wifi_off,
                color: _trackingController.isConnected.value
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _animateToCurrentLocation() async {
    final userLocation = _trackingController.userLocation.value;
    if (userLocation == null) return;

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation, zoom: 16.0),
      ),
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
    // TODO: Implement actual phone call functionality
  }
}

// Service Booking Model (updated for compatibility)
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
