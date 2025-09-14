import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khabir/app/data/repositories/location_tracking_repository.dart';

class LocationTrackingController extends GetxController {
  final LocationTrackingRepository _locationRepository =
      Get.find<LocationTrackingRepository>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool hasError = false.obs;

  // Location data
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> providerLocation = Rx<LatLng?>(null);
  final RxList<LatLng> locationHistory = <LatLng>[].obs;

  // Tracking info
  final RxString trackingStatus = 'Connecting...'.obs;
  final RxString providerStatus = 'Unknown'.obs;
  final RxString estimatedArrival = ''.obs;
  final RxString routeDistance = ''.obs;
  final RxString routeDuration = ''.obs;
  final RxDouble accuracy = 0.0.obs;

  // Order info
  int? currentOrderId;
  Timer? _reconnectTimer;
  Timer? _connectionCheckTimer;

  @override
  void onInit() {
    super.onInit();
    print('LocationTrackingController: onInit called');
    _initializeLocationTracking();
    _startConnectionMonitoring();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  // Safe type conversion utilities
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _safeParseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  void _initializeLocationTracking() {
    try {
      print('Initializing location tracking...');
      _locationRepository.initializeSocket();
      _setupSocketListeners();

      // Update connection status after initialization
      Future.delayed(const Duration(milliseconds: 500), () {
        final connected = _locationRepository.isConnected;
        print('Connection status after initialization: $connected');
        isConnected.value = connected;
      });
    } catch (e) {
      print('Initialize location tracking error: $e');
      hasError.value = true;
      isConnected.value = false;
    }
  }

  void _setupSocketListeners() {
    print('Setting up socket listeners...');

    // Listen for location updates
    _locationRepository.onLocationUpdated((data) {
      print('CONTROLLER: onLocationUpdated callback triggered!');
      print('CONTROLLER: Received data: $data');
      print('CONTROLLER: Data Order ID: ${data['orderId']}');
      try {
        // Safe type handling for orderId
        final orderId = _safeParseInt(data['orderId']);
        print(
          'CONTROLLER: Order ID from data: $orderId, Current order: $currentOrderId',
        );

        if (orderId != null &&
            currentOrderId != null &&
            orderId != currentOrderId) {
          print(
            'CONTROLLER: Ignoring location update for different order: $orderId (current: $currentOrderId)',
          );
          return;
        }

        final locationData = data['location'];
        if (locationData == null) {
          print('CONTROLLER: No location data in update');
          return;
        }

        print('CONTROLLER: Processing location data: $locationData');

        // Safe type handling for coordinates
        final latitude = _safeParseDouble(locationData['latitude']);
        final longitude = _safeParseDouble(locationData['longitude']);
        final accuracyValue = _safeParseDouble(locationData['accuracy']);

        print(
          'CONTROLLER: Extracted - lat: $latitude, lng: $longitude, accuracy: $accuracyValue',
        );

        if (latitude != null && longitude != null) {
          final newLocation = LatLng(latitude, longitude);

          print('CONTROLLER: Setting provider location to: $newLocation');
          providerLocation.value = newLocation;

          print(
            'CONTROLLER: Current provider location after setting: ${providerLocation.value}',
          );

          // Add to history only if it's significantly different from the last point
          if (locationHistory.isEmpty ||
              _calculateDistance(locationHistory.last, newLocation) > 5.0) {
            locationHistory.add(newLocation);
            print(
              'CONTROLLER: Added to history. Total points: ${locationHistory.length}',
            );

            // Keep only last 50 points to avoid memory issues
            if (locationHistory.length > 50) {
              locationHistory.removeAt(0);
              print('CONTROLLER: Trimmed history to 50 points');
            }
          } else {
            print(
              'CONTROLLER: Location too close to last point, not adding to history',
            );
          }

          // Handle accuracy
          if (accuracyValue != null) {
            accuracy.value = accuracyValue;
            print('CONTROLLER: Set accuracy to: ${accuracy.value}');
          }

          // Mark as connected since we're receiving updates
          if (!isConnected.value) {
            print('CONTROLLER: Marking as connected due to location update');
            isConnected.value = true;
          }

          print(
            'CONTROLLER: Location updated successfully: $latitude, $longitude',
          );

          // Force trigger reactive updates
          update();
        } else {
          print(
            'CONTROLLER: Invalid location data: latitude=$latitude, longitude=$longitude',
          );
        }
      } catch (e) {
        print('CONTROLLER: Error processing location update: $e');
        print('CONTROLLER: Stack trace: ${StackTrace.current}');
      }
    });

    // Listen for tracking status changes
    _locationRepository.onTrackingStatusChanged((data) {
      print('CONTROLLER: Tracking status change callback triggered');
      print('CONTROLLER: Data: $data');

      try {
        final status = _safeParseString(data['status']);
        final eta = _safeParseString(data['estimatedArrival']);
        final distance = _safeParseString(data['distance']);
        final duration = _safeParseString(data['duration']);

        if (status != null && status.isNotEmpty) {
          trackingStatus.value = _formatTrackingStatus(status);
          print(
            'CONTROLLER: Updated tracking status to: ${trackingStatus.value}',
          );
        }

        if (eta != null && eta.isNotEmpty) {
          estimatedArrival.value = eta;
          print('CONTROLLER: Updated ETA to: $eta');
        }

        if (distance != null && distance.isNotEmpty) {
          routeDistance.value = distance;
          print('CONTROLLER: Updated distance to: $distance');
        }

        if (duration != null && duration.isNotEmpty) {
          routeDuration.value = duration;
          print('CONTROLLER: Updated duration to: $duration');
        }
      } catch (e) {
        print('CONTROLLER: Error processing tracking status change: $e');
      }
    });

    // Listen for provider status changes
    _locationRepository.onProviderStatusChanged((data) {
      print('CONTROLLER: Provider status change callback triggered');
      print('CONTROLLER: Data: $data');

      try {
        final status = _safeParseString(data['status']);
        if (status != null && status.isNotEmpty) {
          providerStatus.value = _formatProviderStatus(status);
          print(
            'CONTROLLER: Updated provider status to: ${providerStatus.value}',
          );
        }
      } catch (e) {
        print('CONTROLLER: Error processing provider status change: $e');
      }
    });

    // Listen for order status changes
    _locationRepository.onOrderStatusChanged((data) {
      print('CONTROLLER: Order status change callback triggered');
      print('CONTROLLER: Data: $data');

      try {
        final status = _safeParseString(data['status']);
        final orderId = _safeParseInt(
          data['orderId'],
        ); // Fixed: Use safe parsing instead of direct cast

        if (status != null && orderId == currentOrderId) {
          _handleOrderStatusChange(status);
          print('CONTROLLER: Handled order status change: $status');
        }
      } catch (e) {
        print('CONTROLLER: Error processing order status change: $e');
      }
    });

    // Listen for connection events
    _locationRepository.onConnectionChanged((isConnected) {
      print('CONTROLLER: Connection change callback triggered: $isConnected');
      this.isConnected.value = isConnected;

      if (!isConnected) {
        _startReconnectTimer();
      } else {
        _stopReconnectTimer();
        // Re-track current order if we have one
        if (currentOrderId != null) {
          Future.delayed(const Duration(seconds: 1), () {
            print(
              'CONTROLLER: Re-tracking order after reconnection: $currentOrderId',
            );
            _locationRepository.trackOrder(currentOrderId!);
          });
        }
      }
    });

    print('CONTROLLER: Socket listeners setup complete');
  }

  void _startConnectionMonitoring() {
    print('CONTROLLER: Starting connection monitoring...');
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentConnectionStatus = _locationRepository.isConnected;
      if (isConnected.value != currentConnectionStatus) {
        isConnected.value = currentConnectionStatus;
        print(
          'CONTROLLER: Connection status updated: $currentConnectionStatus',
        );
      }
    });
  }

  // Start tracking for a specific order
  Future<void> startTracking(int orderId) async {
    try {
      print('CONTROLLER: Starting tracking for order: $orderId');

      isLoading.value = true;
      hasError.value = false;
      currentOrderId = orderId;

      // Initialize socket if not connected
      if (!_locationRepository.isConnected) {
        print('CONTROLLER: Socket not connected, initializing...');
        _locationRepository.initializeSocket();

        // Wait for connection with timeout
        int attempts = 0;
        while (!_locationRepository.isConnected && attempts < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          attempts++;
          print('CONTROLLER: Connection attempt $attempts/10');
        }

        if (!_locationRepository.isConnected) {
          throw Exception('Failed to connect to tracking service');
        }
        print('CONTROLLER: Socket connected successfully');
      }

      // Get user's current location first
      await _getCurrentUserLocation();

      // Start tracking the order
      print('CONTROLLER: Calling trackOrder...');
      _locationRepository.trackOrder(orderId);

      // Give some time for the tracking to start
      await Future.delayed(const Duration(seconds: 1));

      // Get initial tracking data
      await _loadInitialTrackingData(orderId);

      trackingStatus.value = 'Tracking started';
      isConnected.value = true;

      print('CONTROLLER: Tracking started successfully');

      Get.snackbar(
        'Tracking Started',
        'Now tracking your service provider',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('CONTROLLER: Start tracking error: $e');
      hasError.value = true;
      isConnected.value = false;

      Get.snackbar(
        'Tracking Error',
        'Failed to start tracking: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Stop tracking
  void stopTracking() {
    if (currentOrderId != null) {
      print('CONTROLLER: Stopping tracking for order: $currentOrderId');
      _locationRepository.stopTracking(currentOrderId!);
      trackingStatus.value = 'Tracking stopped';
      currentOrderId = null;

      Get.snackbar(
        'Tracking Stopped',
        'Location tracking has been stopped',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Get current user location
  Future<void> _getCurrentUserLocation() async {
    try {
      print('CONTROLLER: Getting current user location...');

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      userLocation.value = LatLng(position.latitude, position.longitude);
      print(
        'CONTROLLER: User location obtained: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      print('CONTROLLER: Get user location error: $e');
      // Use default location if unable to get current location
      userLocation.value = const LatLng(23.5880, 58.3829); // Muscat, Oman
      print('CONTROLLER: Using default location: ${userLocation.value}');
    }
  }

  // Load initial tracking data from API
  Future<void> _loadInitialTrackingData(int orderId) async {
    try {
      print('CONTROLLER: Loading initial tracking data for order: $orderId');

      // Get current provider location
      final currentLocationResult = await _locationRepository
          .getCurrentLocation(orderId);
      if (currentLocationResult['success'] == true) {
        final locationData = currentLocationResult['location'];
        final latitude = _safeParseDouble(locationData['latitude']);
        final longitude = _safeParseDouble(locationData['longitude']);

        if (latitude != null && longitude != null) {
          providerLocation.value = LatLng(latitude, longitude);
          print(
            'CONTROLLER: Initial provider location loaded: $latitude, $longitude',
          );
        }
      }

      // Get tracking status
      final statusResult = await _locationRepository.getTrackingStatus(orderId);
      if (statusResult['success'] == true) {
        final statusData = statusResult['status'];
        final status = _safeParseString(statusData['status']) ?? '';
        final providerStatusStr =
            _safeParseString(statusData['providerStatus']) ?? '';

        trackingStatus.value = _formatTrackingStatus(status);
        providerStatus.value = _formatProviderStatus(providerStatusStr);
        print(
          'CONTROLLER: Initial tracking status loaded: ${trackingStatus.value}',
        );
      }
    } catch (e) {
      print('CONTROLLER: Load initial tracking data error: $e');
    }
  }

  // Refresh tracking data
  Future<void> refreshTracking() async {
    if (currentOrderId != null) {
      print('CONTROLLER: Refreshing tracking data...');
      await _loadInitialTrackingData(currentOrderId!);

      Get.snackbar(
        'Tracking Refreshed',
        'Location data has been updated',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Handle order status changes
  void _handleOrderStatusChange(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        stopTracking();
        Get.snackbar(
          'Service Completed',
          'Your service has been completed',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        break;
      case 'cancelled':
        stopTracking();
        Get.snackbar(
          'Service Cancelled',
          'Your service has been cancelled',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        break;
      default:
        break;
    }
  }

  // Format tracking status for display
  String _formatTrackingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'on_the_way':
        return 'On the way';
      case 'nearby':
        return 'Nearby';
      case 'almost_there':
        return 'Almost there';
      case 'arrived':
        return 'Arrived';
      case 'in_service':
        return 'Providing service';
      default:
        return status.replaceAll('_', ' ').capitalizeFirst ?? status;
    }
  }

  // Format provider status for display
  String _formatProviderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'busy':
        return 'Busy';
      case 'available':
        return 'Available';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  // Get status color
  Color getStatusColor() {
    switch (trackingStatus.value.toLowerCase()) {
      case 'on the way':
        return Colors.orange;
      case 'nearby':
        return Colors.blue;
      case 'almost there':
        return Colors.purple;
      case 'arrived':
        return Colors.green;
      case 'providing service':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  // Check connection and reconnect if needed
  void checkConnection() {
    final currentStatus = _locationRepository.isConnected;
    isConnected.value = currentStatus;
    print('CONTROLLER: Connection check - current status: $currentStatus');

    if (!currentStatus) {
      _startReconnectTimer();
    } else {
      _stopReconnectTimer();
    }
  }

  void _startReconnectTimer() {
    _stopReconnectTimer();

    print('CONTROLLER: Starting reconnect timer...');
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_locationRepository.isConnected) {
        print('CONTROLLER: Attempting to reconnect to socket...');
        try {
          _initializeLocationTracking();
        } catch (e) {
          print('CONTROLLER: Reconnection attempt failed: $e');
        }
      } else {
        timer.cancel();
        isConnected.value = true;
        if (currentOrderId != null) {
          _locationRepository.trackOrder(currentOrderId!);
        }
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cleanup() {
    print('CONTROLLER: Cleaning up...');
    _stopReconnectTimer();
    _connectionCheckTimer?.cancel();
    _locationRepository.removeAllListeners();
    _locationRepository.disconnect();

    if (currentOrderId != null) {
      _locationRepository.stopTracking(currentOrderId!);
    }
  }

  // Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Calculate distance between two points (public method)
  double calculateDistance(LatLng point1, LatLng point2) {
    return _calculateDistance(point1, point2);
  }

  // Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Format duration for display
  String formatDuration(String duration) {
    return duration.isNotEmpty ? duration : 'Calculating...';
  }

  // Debug method to check current state
  void debugCurrentState() {
    print('CONTROLLER DEBUG STATE:');
    print('  - Current Order ID: $currentOrderId');
    print('  - Is Connected: ${isConnected.value}');
    print('  - User Location: ${userLocation.value}');
    print('  - Provider Location: ${providerLocation.value}');
    print('  - Location History: ${locationHistory.length} points');
    print('  - Tracking Status: ${trackingStatus.value}');
    print('  - Repository Connected: ${_locationRepository.isConnected}');
  }
}
