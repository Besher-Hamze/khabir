import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khabir/app/data/repositories/location_tracking_repository.dart';

class LocationTrackingController extends GetxController {
  final LocationTrackingRepository _locationRepository =
      LocationTrackingRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    print('LocationTrackingController: onInit called');
    _initializeLocationTracking();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  void _initializeLocationTracking() {
    try {
      _locationRepository.initializeSocket();
      _setupSocketListeners();
      isConnected.value = _locationRepository.isConnected;
    } catch (e) {
      print('Initialize location tracking error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  void _setupSocketListeners() {
    // Listen for location updates
    _locationRepository.onLocationUpdated((data) {
      try {
        final latitude = data['location']['latitude'] as double?;
        final longitude = data['location']['longitude'] as double?;
        final accuracyValue = (data['location']['accuracy'] is int)
            ? (data['location']['accuracy'] as int).toDouble()
            : (data['location']['accuracy'] as double?);
        final status = data['status'] as String?;

        if (latitude != null && longitude != null) {
          providerLocation.value = LatLng(latitude, longitude);
          locationHistory.add(LatLng(latitude, longitude));

          if (accuracyValue != null) {
            accuracy.value = accuracyValue;
          }

          if (status != null) {
            trackingStatus.value = _formatTrackingStatus(status);
          }

          print('Location updated: $latitude, $longitude');
        }
      } catch (e) {
        print('Error processing location update: $e');
      }
    });

    // Listen for tracking status changes
    _locationRepository.onTrackingStatusChanged((data) {
      try {
        final status = data['status'] as String?;
        final eta = data['estimatedArrival'] as String?;
        final distance = data['distance'] as String?;
        final duration = data['duration'] as String?;

        if (status != null) {
          trackingStatus.value = _formatTrackingStatus(status);
        }

        if (eta != null) {
          estimatedArrival.value = eta;
        }

        if (distance != null) {
          routeDistance.value = distance;
        }

        if (duration != null) {
          routeDuration.value = duration;
        }

        print('Tracking status changed: $status');
      } catch (e) {
        print('Error processing tracking status change: $e');
      }
    });

    // Listen for provider status changes
    _locationRepository.onProviderStatusChanged((data) {
      try {
        final status = data['status'] as String?;

        if (status != null) {
          providerStatus.value = _formatProviderStatus(status);
        }

        print('Provider status changed: $status');
      } catch (e) {
        print('Error processing provider status change: $e');
      }
    });

    // Listen for order status changes
    _locationRepository.onOrderStatusChanged((data) {
      try {
        final status = data['status'] as String?;
        final orderId = data['orderId'] as int?;

        if (status != null && orderId == currentOrderId) {
          // Handle order status changes
          _handleOrderStatusChange(status);
        }

        print('Order status changed: $status for order: $orderId');
      } catch (e) {
        print('Error processing order status change: $e');
      }
    });
  }

  // Start tracking for a specific order
  Future<void> startTracking(int orderId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      currentOrderId = orderId;

      // Check if socket is connected
      if (!_locationRepository.isConnected) {
        _locationRepository.initializeSocket();
        await Future.delayed(const Duration(seconds: 2)); // Wait for connection
      }

      // Get user's current location first
      await _getCurrentUserLocation();

      // Start tracking the order
      _locationRepository.trackOrder(orderId);

      // Get initial tracking data
      await _loadInitialTrackingData(orderId);

      trackingStatus.value = 'Tracking started';

      Get.snackbar(
        'Tracking Started',
        'Now tracking your service provider',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Start tracking error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation.value = LatLng(position.latitude, position.longitude);
      print('User location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Get user location error: $e');
      // Use default location if unable to get current location
      userLocation.value = const LatLng(23.5880, 58.3829); // Muscat, Oman
    }
  }

  // Load initial tracking data from API
  Future<void> _loadInitialTrackingData(int orderId) async {
    try {
      // Get current provider location
      final currentLocationResult = await _locationRepository
          .getCurrentLocation(orderId);
      if (currentLocationResult['success']) {
        final locationData = currentLocationResult['location'];
        final latitude = locationData['latitude'] as double?;
        final longitude = locationData['longitude'] as double?;

        if (latitude != null && longitude != null) {
          providerLocation.value = LatLng(latitude, longitude);
        }
      }

      // Get location history
      final historyResult = await _locationRepository.getLocationHistory(
        orderId,
      );
      if (historyResult['success']) {
        final historyData = historyResult['history'] as List?;
        if (historyData != null) {
          locationHistory.clear();
          for (var point in historyData) {
            final lat = point['latitude'] as double?;
            final lng = point['longitude'] as double?;
            if (lat != null && lng != null) {
              locationHistory.add(LatLng(lat, lng));
            }
          }
        }
      }

      // Get estimated arrival
      final arrivalResult = await _locationRepository.getEstimatedArrival(
        orderId,
      );
      if (arrivalResult['success']) {
        final arrivalData = arrivalResult['estimatedArrival'];
        estimatedArrival.value = arrivalData['eta'] ?? '';
        routeDistance.value = arrivalData['distance'] ?? '';
        routeDuration.value = arrivalData['duration'] ?? '';
      }

      // Get tracking status
      final statusResult = await _locationRepository.getTrackingStatus(orderId);
      if (statusResult['success']) {
        final statusData = statusResult['status'];
        trackingStatus.value = _formatTrackingStatus(
          statusData['status'] ?? '',
        );
        providerStatus.value = _formatProviderStatus(
          statusData['providerStatus'] ?? '',
        );
      }
    } catch (e) {
      print('Load initial tracking data error: $e');
    }
  }

  // Refresh tracking data
  Future<void> refreshTracking() async {
    if (currentOrderId != null) {
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
    isConnected.value = _locationRepository.isConnected;

    if (!isConnected.value) {
      _startReconnectTimer();
    } else {
      _stopReconnectTimer();
    }
  }

  void _startReconnectTimer() {
    _stopReconnectTimer();

    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_locationRepository.isConnected) {
        print('Attempting to reconnect to socket...');
        _initializeLocationTracking();
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
    _stopReconnectTimer();
    _locationRepository.removeAllListeners();
    _locationRepository.disconnect();

    if (currentOrderId != null) {
      _locationRepository.stopTracking(currentOrderId!);
    }
  }

  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
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
    // Expecting duration in format like "15 minutes" or "1.5 hours"
    return duration.isNotEmpty ? duration : 'Calculating...';
  }
}
