import 'package:get/get.dart';
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class LocationTrackingRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  IO.Socket? _socket;
  bool _isInitializing = false;

  // Callback functions
  Function(Map<String, dynamic>)? _onLocationUpdated;
  Function(Map<String, dynamic>)? _onTrackingStatusChanged;
  Function(Map<String, dynamic>)? _onProviderStatusChanged;
  Function(Map<String, dynamic>)? _onOrderStatusChanged;
  Function(bool)? _onConnectionChanged;

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
    if (_isInitializing) {
      print('REPOSITORY: Socket initialization already in progress');
      return _socket!;
    }

    try {
      _isInitializing = true;

      // Disconnect existing socket if any
      if (_socket != null) {
        print('REPOSITORY: Disconnecting existing socket');
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      print(
        'REPOSITORY: Initializing socket connection to: ${AppConstants.socketUrl}',
      );

      _socket = IO.io(
        AppConstants.socketUrl,
        IO.OptionBuilder()
            .setAuth({'token': _storageService.getToken()})
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setTimeout(5000)
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .build(),
      );

      _setupSocketEventHandlers();
      _setupDataEventHandlers();

      _isInitializing = false;
      return _socket!;
    } catch (e) {
      _isInitializing = false;
      print('REPOSITORY: Socket initialization error: $e');
      _onConnectionChanged?.call(false);
      throw Exception('Failed to initialize socket: $e');
    }
  }

  void _setupSocketEventHandlers() {
    if (_socket == null) return;

    // Connection event handlers
    _socket!.onConnect((_) {
      print('REPOSITORY: Connected to location tracking socket');
      _onConnectionChanged?.call(true);
    });

    _socket!.onDisconnect((reason) {
      print('REPOSITORY: Disconnected from location tracking socket: $reason');
      _onConnectionChanged?.call(false);
    });

    _socket!.onConnectError((error) {
      print('REPOSITORY: Socket connection error: $error');
      _onConnectionChanged?.call(false);
    });

    _socket!.onError((error) {
      print('REPOSITORY: Socket error: $error');
    });

    _socket!.onReconnect((attempt) {
      print('REPOSITORY: Socket reconnected on attempt: $attempt');
      _onConnectionChanged?.call(true);
    });

    _socket!.onReconnectError((error) {
      print('REPOSITORY: Socket reconnection error: $error');
    });

    _socket!.onReconnectFailed((_) {
      print('REPOSITORY: Socket reconnection failed');
      _onConnectionChanged?.call(false);
    });

    // Generic message handler for debugging
    _socket!.onAny((event, data) {
      print('REPOSITORY: Socket event "$event": $data');
    });
  }

  void _setupDataEventHandlers() {
    if (_socket == null) return;

    // Handle provider location updates
    _socket!.on('provider_location_updated', (data) {
      print('REPOSITORY: Received provider_location_updated: $data');
      _handleLocationUpdate(data);
    });

    // Handle order tracking started (contains initial location)
    _socket!.on('order_tracking_started', (data) {
      print('REPOSITORY: Received order_tracking_started: $data');
      _handleOrderTrackingStarted(data);
    });

    // Handle tracking status changes
    _socket!.on('tracking_status_changed', (data) {
      print('REPOSITORY: Received tracking_status_changed: $data');
      _handleTrackingStatusChanged(data);
    });

    // Handle provider status changes
    _socket!.on('provider_status_changed', (data) {
      print('REPOSITORY: Received provider_status_changed: $data');
      _handleProviderStatusChanged(data);
    });

    // Handle order status changes
    _socket!.on('order_status_changed', (data) {
      print('REPOSITORY: Received order_status_changed: $data');
      _handleOrderStatusChanged(data);
    });
  }

  void _handleLocationUpdate(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        print('REPOSITORY: Processing location update');
        if (_onLocationUpdated != null) {
          _onLocationUpdated!(data);
          print('REPOSITORY: Location update callback called successfully');
        } else {
          print('REPOSITORY: Location update callback is null');
        }
      } else {
        print('REPOSITORY: Invalid location update data format: $data');
      }
    } catch (e) {
      print('REPOSITORY: Error processing location update: $e');
    }
  }

  void _handleOrderTrackingStarted(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Extract current location from order_tracking_started event
        final currentLocation = data['currentLocation'];
        if (currentLocation != null) {
          // Convert to the same format as provider_location_updated
          final locationData = {
            'orderId': data['orderId'],
            'providerId': data['providerId'],
            'location': currentLocation,
          };

          print(
            'REPOSITORY: Converted order_tracking_started to location format',
          );
          if (_onLocationUpdated != null) {
            _onLocationUpdated!(locationData);
            print('REPOSITORY: Initial location callback called successfully');
          }
        }
      }
    } catch (e) {
      print('REPOSITORY: Error processing order tracking started: $e');
    }
  }

  void _handleTrackingStatusChanged(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (_onTrackingStatusChanged != null) {
          _onTrackingStatusChanged!(data);
          print('REPOSITORY: Tracking status callback called successfully');
        }
      } else {
        print('REPOSITORY: Invalid tracking status data format: $data');
      }
    } catch (e) {
      print('REPOSITORY: Error processing tracking status change: $e');
    }
  }

  void _handleProviderStatusChanged(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (_onProviderStatusChanged != null) {
          _onProviderStatusChanged!(data);
          print('REPOSITORY: Provider status callback called successfully');
        }
      } else {
        print('REPOSITORY: Invalid provider status data format: $data');
      }
    } catch (e) {
      print('REPOSITORY: Error processing provider status change: $e');
    }
  }

  void _handleOrderStatusChanged(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (_onOrderStatusChanged != null) {
          _onOrderStatusChanged!(data);
          print('REPOSITORY: Order status callback called successfully');
        }
      } else {
        print('REPOSITORY: Invalid order status data format: $data');
      }
    } catch (e) {
      print('REPOSITORY: Error processing order status change: $e');
    }
  }

  void startTracking(int orderId, {int updateInterval = 30}) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    final payload = {'orderId': orderId, 'updateInterval': updateInterval};

    print('REPOSITORY: Starting tracking with payload: $payload');
    _socket!.emit('start_tracking', payload);
    print('REPOSITORY: Started tracking for order: $orderId');
  }

  void trackOrder(int orderId) {
    if (_socket == null) {
      print('REPOSITORY: Cannot track order - Socket is null');
      throw Exception('Socket not initialized');
    }

    if (!_socket!.connected) {
      print('REPOSITORY: Cannot track order - Socket not connected');
      throw Exception('Socket not connected');
    }

    final payload = {'orderId': orderId};
    print('REPOSITORY: Tracking order with payload: $payload');

    _socket!.emit('track_order', payload);
    print('REPOSITORY: Started tracking order: $orderId');
  }

  void stopTracking(int orderId) {
    if (_socket == null || !_socket!.connected) {
      print('REPOSITORY: Cannot stop tracking - Socket not available');
      return;
    }

    final payload = {'orderId': orderId};
    print('REPOSITORY: Stopping tracking with payload: $payload');

    _socket!.emit('stop_tracking', payload);
    print('REPOSITORY: Stopped tracking for order: $orderId');
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

    final payload = {
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('REPOSITORY: Updating location with payload: $payload');
    _socket!.emit('update_location', payload);
    print('REPOSITORY: Updated location for order: $orderId');
  }

  // Callback registration methods
  void onLocationUpdated(Function(Map<String, dynamic>) callback) {
    print('REPOSITORY: Registering location update callback');
    _onLocationUpdated = callback;

    // Test the callback immediately
    print('REPOSITORY: Testing callback with dummy data');
    try {
      callback({'test': 'callback_working'});
      print('REPOSITORY: Callback test successful');
    } catch (e) {
      print('REPOSITORY: Callback test failed: $e');
    }
  }

  void onTrackingStatusChanged(Function(Map<String, dynamic>) callback) {
    print('REPOSITORY: Registering tracking status callback');
    _onTrackingStatusChanged = callback;
  }

  void onProviderStatusChanged(Function(Map<String, dynamic>) callback) {
    print('REPOSITORY: Registering provider status callback');
    _onProviderStatusChanged = callback;
  }

  void onOrderStatusChanged(Function(Map<String, dynamic>) callback) {
    print('REPOSITORY: Registering order status callback');
    _onOrderStatusChanged = callback;
  }

  void onConnectionChanged(Function(bool) callback) {
    print('REPOSITORY: Registering connection status callback');
    _onConnectionChanged = callback;
  }

  void removeAllListeners() {
    print('REPOSITORY: Removing all socket listeners');

    _onLocationUpdated = null;
    _onTrackingStatusChanged = null;
    _onProviderStatusChanged = null;
    _onOrderStatusChanged = null;
    _onConnectionChanged = null;

    if (_socket != null) {
      _socket!.off('provider_location_updated');
      _socket!.off('order_tracking_started');
      _socket!.off('tracking_status_changed');
      _socket!.off('provider_status_changed');
      _socket!.off('order_status_changed');
      _socket!.offAny();
    }

    print('REPOSITORY: All listeners removed');
  }

  void disconnect() {
    if (_socket != null) {
      print('REPOSITORY: Disconnecting socket');

      removeAllListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;

      _onConnectionChanged?.call(false);
      print('REPOSITORY: Socket disconnected and disposed');
    }
  }

  bool get isConnected {
    final connected = _socket?.connected ?? false;
    return connected;
  }

  // Debug method to check socket state
  void debugSocketState() {
    if (_socket == null) {
      print('REPOSITORY: Socket is null');
      return;
    }

    print('REPOSITORY: Socket Debug Info:');
    print('  - Connected: ${_socket!.connected}');
    print('  - ID: ${_socket!.id}');
    print('  - Disconnected: ${_socket!.disconnected}');
    print('  - Active: ${_socket!.active}');
  }

  // Force reconnection
  void forceReconnect() {
    print('REPOSITORY: Forcing socket reconnection');

    if (_socket != null) {
      _socket!.disconnect();
      _socket!.connect();
    } else {
      initializeSocket();
    }
  }

  // Get repository instance hash for debugging
  int getInstanceHash() {
    return hashCode;
  }

  // Check if callbacks are registered
  void debugCallbackStatus() {
    print('REPOSITORY: Callback Status:');
    print('  - Location Updated: ${_onLocationUpdated != null}');
    print('  - Tracking Status: ${_onTrackingStatusChanged != null}');
    print('  - Provider Status: ${_onProviderStatusChanged != null}');
    print('  - Order Status: ${_onOrderStatusChanged != null}');
    print('  - Connection: ${_onConnectionChanged != null}');
  }
}
