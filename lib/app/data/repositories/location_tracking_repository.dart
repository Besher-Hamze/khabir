import 'package:get/get.dart';
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class LocationTrackingRepository {
  final ApiService _apiService = Get.find<ApiService>();
  IO.Socket? _socket;
  final StorageService _storageService = Get.find<StorageService>();
  // Location tracking endpoints
  Future<Map<String, dynamic>> getTrackingHealth() async {
    try {
      final response = await _apiService.get(
        AppConstants.locationTrackingHealth,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get tracking health'};
      }
    } catch (e) {
      print('Get tracking health error: $e');
      return {'success': false, 'message': 'Error getting tracking health: $e'};
    }
  }

  Future<Map<String, dynamic>> getCurrentLocation(int orderId) async {
    try {
      final endpoint = AppConstants.locationTrackingCurrentLocation.replaceAll(
        '{orderId}',
        orderId.toString(),
      );

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        return {'success': true, 'location': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get current location'};
      }
    } catch (e) {
      print('Get current location error: $e');
      return {
        'success': false,
        'message': 'Error getting current location: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getLocationHistory(int orderId) async {
    try {
      final endpoint = AppConstants.locationTrackingHistory.replaceAll(
        '{orderId}',
        orderId.toString(),
      );

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        return {'success': true, 'history': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get location history'};
      }
    } catch (e) {
      print('Get location history error: $e');
      return {
        'success': false,
        'message': 'Error getting location history: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getTrackingStatus(int orderId) async {
    try {
      final endpoint = AppConstants.locationTrackingStatus.replaceAll(
        '{orderId}',
        orderId.toString(),
      );

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        return {'success': true, 'status': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get tracking status'};
      }
    } catch (e) {
      print('Get tracking status error: $e');
      return {'success': false, 'message': 'Error getting tracking status: $e'};
    }
  }

  // Socket connection methods
  IO.Socket initializeSocket() {
    try {
      _socket = IO.io(
        AppConstants.socketUrl,
        IO.OptionBuilder()
            .setAuth({'token': _storageService.getToken()})
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .build(),
      );

      _socket!.onConnect((_) {
        print('Connected to location tracking socket');
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from location tracking socket');
      });

      _socket!.onError((error) {
        print('Socket error: $error');
      });

      _socket!.on('tracking_status_changed', (data) {
        print('Tracking status changed: $data');
      });
      _socket!.on('order_status_changed', (data) {
        print('Order status changed: $data');
      });
      _socket!.on('provider_status_changed', (data) {
        print('Provider status changed: $data');
      });

      _socket!.on('provider_location_updated', (data) {
        print('Received location update: $data');
      });

      return _socket!;
    } catch (e) {
      print('Socket initialization error: $e');
      throw Exception('Failed to initialize socket: $e');
    }
  }

  void startTracking(int orderId, {int updateInterval = 30}) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    _socket!.emit('start_tracking', {
      'orderId': orderId,
      'updateInterval': updateInterval, // seconds
    });

    print('Started tracking for order: $orderId');
  }

  void trackOrder(int orderId) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    _socket!.emit('track_order', {'orderId': orderId});

    print('Started tracking order: $orderId');
  }

  void stopTracking(int orderId) {
    if (_socket == null || !_socket!.connected) {
      return;
    }

    _socket!.emit('stop_tracking', {'orderId': orderId});

    print('Stopped tracking for order: $orderId');
  }

  void updateLocation({
    required int orderId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    // _socket!.emit('update_location', {
    //   'orderId': orderId,
    //   'latitude': latitude,
    //   'longitude': longitude,
    //   'accuracy': accuracy,
    //   'timestamp': DateTime.now().toIso8601String(),
    // });

    print('Updated location for order: $orderId');
  }

  void onLocationUpdated(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;

    _socket!.on('provider_location_updated', (data) {
      print('Received location update: $data');
      callback(data);
    });
  }

  void onTrackingStatusChanged(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;

    _socket!.on('tracking_status_changed', (data) {
      print('Tracking status changed: $data');
      callback(data);
    });
  }

  void onProviderStatusChanged(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;

    _socket!.on('provider_status_changed', (data) {
      print('Provider status changed: $data');
      callback(data);
    });
  }

  void onOrderStatusChanged(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;

    _socket!.on('order_status_changed', (data) {
      print('Order status changed: $data');
      callback(data);
    });
  }

  void removeAllListeners() {
    if (_socket == null) return;

    _socket!.off('provider_location_updated');
    _socket!.off('tracking_status_changed');
    _socket!.off('provider_status_changed');
    _socket!.off('order_status_changed');
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      print('Socket disconnected and disposed');
    }
  }

  bool get isConnected => _socket?.connected ?? false;
}
