import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
  Timer? _locationUpdateTimer;
  Timer? _routeUpdateTimer;
  Timer? _userInteractionTimer;

  // User interaction state
  bool _userIsInteracting = false;
  bool _hasInitializedCamera = false;
  double _currentZoom = 14.0;
  LatLng? _lastUserLocation;
  LatLng? _lastProviderLocation;

  // Card expansion state
  bool _isCardExpanded = true;
  double _dragPosition = 0.0;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _statusController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTracking();
    _startUpdateTimers();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _statusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start with card expanded
    _cardAnimationController.value = 1.0;
  }

  void _initializeTracking() {
    final orderId = int.tryParse(widget.booking.id) ?? 0;
    _trackingController.startTracking(orderId);
  }

  void _startUpdateTimers() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateMarkersIfNeeded();
    });

    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateRouteIfNeeded();
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _routeUpdateTimer?.cancel();
    _userInteractionTimer?.cancel();
    _pulseController.dispose();
    _statusController.dispose();
    _cardAnimationController.dispose();
    _trackingController.stopTracking();
    super.dispose();
  }

  void _updateMarkersIfNeeded() {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    bool shouldUpdate = false;

    if (userLocation != _lastUserLocation) {
      _lastUserLocation = userLocation;
      shouldUpdate = true;
    }

    if (providerLocation != _lastProviderLocation) {
      _lastProviderLocation = providerLocation;
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      _updateMapMarkers();
    }
  }

  void _updateRouteIfNeeded() {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    if (userLocation != null && providerLocation != null) {
      final distance = _calculateDistance(userLocation, providerLocation);
      if (distance > 50) {
        _getRoute(userLocation, providerLocation);
      }
    }
  }

  Future<void> _updateMapMarkers() async {
    final userLocation = _trackingController.userLocation.value;
    final providerLocation = _trackingController.providerLocation.value;

    if (userLocation == null || providerLocation == null) return;

    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: userLocation,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

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
    });

    _updatePolylines(userLocation, providerLocation);

    if (!_userIsInteracting && !_hasInitializedCamera) {
      _fitBothLocationsOnMap(userLocation, providerLocation);
      _hasInitializedCamera = true;
    }
  }

  void _updatePolylines(LatLng userLocation, LatLng providerLocation) {
    setState(() {
      _polylines.clear();

      final distance = _calculateDistance(userLocation, providerLocation);

      if (distance > 10) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("user_to_provider"),
            points: [userLocation, providerLocation],
            color: Colors.blue.withOpacity(0.6),
            width: 3,
            patterns: [PatternItem.dash(15), PatternItem.gap(10)],
          ),
        );
      }

      final locationHistory = _trackingController.locationHistory;
      if (locationHistory.isNotEmpty && locationHistory.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("provider_trail"),
            points: locationHistory,
            color: Colors.green.withOpacity(0.7),
            width: 4,
          ),
        );
      }
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?alternatives=false&geometries=geojson&steps=false&access_token=$mapboxAccessToken";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          final distance = route['distance'] as double;
          final duration = route['duration'] as double;

          _trackingController.routeDistance.value = (distance / 1000)
              .toStringAsFixed(1);
          _trackingController.routeDuration.value = _formatDuration(
            duration.toInt(),
          );

          final routePoints = geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          setState(() {
            _polylines.removeWhere(
              (polyline) => polyline.polylineId.value == "main_route",
            );

            _polylines.add(
              Polyline(
                polylineId: const PolylineId("main_route"),
                points: routePoints,
                color: Colors.blue,
                width: 5,
                patterns: [],
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  void _fitBothLocationsOnMap(
    LatLng userLocation,
    LatLng providerLocation,
  ) async {
    try {
      final GoogleMapController controller = await _mapController.future;
      final distance = _calculateDistance(userLocation, providerLocation);

      if (distance < 100) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: providerLocation, zoom: 16.0),
          ),
        );
        return;
      }

      double minLat = math.min(
        userLocation.latitude,
        providerLocation.latitude,
      );
      double maxLat = math.max(
        userLocation.latitude,
        providerLocation.latitude,
      );
      double minLng = math.min(
        userLocation.longitude,
        providerLocation.longitude,
      );
      double maxLng = math.max(
        userLocation.longitude,
        providerLocation.longitude,
      );

      double padding = math.max(0.002, (maxLat - minLat) * 0.3);

      final bounds = LatLngBounds(
        southwest: LatLng(minLat - padding, minLng - padding),
        northeast: LatLng(maxLat + padding, maxLng + padding),
      );

      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      debugPrint('Error fitting locations on map: $e');
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  void _onCameraMoveStarted() {
    setState(() {
      _userIsInteracting = true;
    });
    _userInteractionTimer?.cancel();
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  void _onCameraIdle() {
    _userInteractionTimer?.cancel();
    _userInteractionTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _userIsInteracting = false;
        });
      }
    });
  }

  // Card expansion methods
  void _toggleCardExpansion() {
    setState(() {
      _isCardExpanded = !_isCardExpanded;
    });

    if (_isCardExpanded) {
      _cardAnimationController.forward();
    } else {
      _cardAnimationController.reverse();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _dragPosition = 0.0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dy;
    });

    const double sensitivity = 200.0;
    double progress = (-_dragPosition / sensitivity).clamp(0.0, 1.0);

    if (!_isCardExpanded) {
      progress = 1.0 - progress;
    }

    _cardAnimationController.value = progress;
  }

  void _handlePanEnd(DragEndDetails details) {
    const double threshold = 100.0;
    double velocity = details.velocity.pixelsPerSecond.dy;

    bool shouldExpand;

    if (velocity.abs() > 500) {
      shouldExpand = velocity < 0;
    } else {
      if (_isCardExpanded) {
        shouldExpand = _dragPosition < threshold;
      } else {
        shouldExpand = _dragPosition < -threshold;
      }
    }

    setState(() {
      _isCardExpanded = shouldExpand;
      _dragPosition = 0.0;
    });

    if (_isCardExpanded) {
      _cardAnimationController.forward();
    } else {
      _cardAnimationController.reverse();
    }
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
            _buildMap(),
            _buildCustomAppBar(),
            _buildConnectionStatus(),
            _buildServiceDetailsCard(),
            _buildControlButtons(),
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
      initialCameraPosition: CameraPosition(
        target: userLocation,
        zoom: _currentZoom,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController.complete(controller);
      },
      onCameraMoveStarted: _onCameraMoveStarted,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      trafficEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _trackingController.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
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
      top: 100,
      left: 16,
      child: Obx(() {
        final isConnected = _trackingController.isConnected.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.green.withOpacity(0.9)
                : Colors.red.withOpacity(0.9),
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
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isConnected
                        ? (1.0 + _pulseController.value * 0.2)
                        : 1.0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.8),
            ],
          ),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'live_tracking'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Order #${widget.booking.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
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
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        const double collapsedHeight = 100.0;
        const double expandedHeight = 320.0;

        double currentHeight =
            collapsedHeight +
            (_cardAnimation.value * (expandedHeight - collapsedHeight));

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isCardExpanded ? null : _toggleCardExpansion,
            onPanStart: _handlePanStart,
            // onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                minHeight: collapsedHeight + 32,
                maxHeight: currentHeight + 32,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _isCardExpanded
                          ? Colors.grey[400]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Always visible: Provider summary
                            _buildProviderSummary(),

                            // Expandable content
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 16 * _fadeAnimation.value,
                                      ),
                                      if (_fadeAnimation.value > 0.1) ...[
                                        _buildServiceDetailsSection(),
                                        const SizedBox(height: 16),
                                        _buildLiveStatusSection(),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderSummary() {
    return Row(
      children: [
        // Provider Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.booking.providerImage.startsWith('http')
                ? Image.network(
                    widget.booking.providerImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 26,
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
                        size: 26,
                        color: Colors.white,
                      );
                    },
                  ),
          ),
        ),

        const SizedBox(width: 14),

        // Provider info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking.providerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Obx(
                () => Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _trackingController.getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _trackingController.trackingStatus.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: _trackingController.getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Price and expand indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.booking.price} OMR',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _cardAnimation.value * math.pi,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildDetailColumn('category'.tr, widget.booking.category),
          _buildDetailColumn('type'.tr, widget.booking.type),
          _buildDetailColumn('duration'.tr, widget.booking.duration),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusSection() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + _pulseController.value * 0.3,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _trackingController.getStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _trackingController.trackingStatus.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            if (_trackingController.estimatedArrival.value.isNotEmpty ||
                _trackingController.routeDistance.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_trackingController.estimatedArrival.value.isNotEmpty)
                    _buildInfoChip(
                      'ETA',
                      _trackingController.estimatedArrival.value,
                    ),
                  if (_trackingController.routeDistance.value.isNotEmpty)
                    _buildInfoChip(
                      'Distance',
                      '${_trackingController.routeDistance.value} km',
                    ),
                  if (_trackingController.routeDuration.value.isNotEmpty)
                    _buildInfoChip(
                      'Duration',
                      _trackingController.routeDuration.value,
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      top: 140,
      right: 16,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: _animateToCurrentLocation,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.refresh,
            onPressed: () => _trackingController.refreshTracking(),
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.crop_free,
            onPressed: () {
              final userLoc = _trackingController.userLocation.value;
              final providerLoc = _trackingController.providerLocation.value;
              if (userLoc != null && providerLoc != null) {
                setState(() {
                  _userIsInteracting = false;
                });
                _fitBothLocationsOnMap(userLoc, providerLoc);
              }
            },
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  void _animateToCurrentLocation() async {
    final userLocation = _trackingController.userLocation.value;
    if (userLocation == null) return;

    setState(() {
      _userIsInteracting = false;
    });

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation, zoom: 16.0),
      ),
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
