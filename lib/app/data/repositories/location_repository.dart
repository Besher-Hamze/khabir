import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class LocationRepository {
  final ApiService _apiService = ApiService.instance;

  // Health check for location tracking
  Future<Map<String, dynamic>> checkLocationTrackingHealth() async {
    try {
      final response = await _apiService.get(
        AppConstants.locationTrackingHealth,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return {
          'success': true,
          'status': responseData['status'] ?? 'unknown',
          'message': 'تم فحص حالة التتبع بنجاح',
        };
      }

      return {'success': false, 'message': 'فشل في فحص حالة التتبع'};
    } catch (e) {
      print('Location tracking health check error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Get current location for an order
  Future<Map<String, dynamic>> getCurrentLocation(String orderId) async {
    try {
      final path = AppConstants.locationTrackingCurrentLocation.replaceAll(
        '{orderId}',
        orderId,
      );
      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['location'] != null) {
          final location = responseData['location'] as Map<String, dynamic>;
          return {
            'success': true,
            'latitude': location['latitude']?.toDouble(),
            'longitude': location['longitude']?.toDouble(),
            'timestamp': location['timestamp'],
            'message': 'تم جلب الموقع الحالي بنجاح',
          };
        }
      }

      return {'success': false, 'message': 'فشل في جلب الموقع الحالي'};
    } catch (e) {
      print('Get current location error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Get location history for an order
  Future<Map<String, dynamic>> getLocationHistory(
    String orderId, {
    int limit = 50,
  }) async {
    try {
      final path = AppConstants.locationTrackingHistory.replaceAll(
        '{orderId}',
        orderId,
      );
      final response = await _apiService.get(
        path,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['locations'] != null) {
          final locations = responseData['locations'] as List;
          return {
            'success': true,
            'locations': locations,
            'message': 'تم جلب سجل المواقع بنجاح',
          };
        }
      }

      return {'success': false, 'message': 'فشل في جلب سجل المواقع'};
    } catch (e) {
      print('Get location history error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Get estimated arrival time for an order
  // Future<Map<String, dynamic>> getEstimatedArrival(String orderId) async {
  //   try {
  //     final path = AppConstants.locationTrackingEstimatedArrival.replaceAll(
  //       '{orderId}',
  //       orderId,
  //     );
  //     final response = await _apiService.get(path);

  //     if (response.statusCode == 200) {
  //       final responseData = response.data;
  //       if (responseData['estimatedArrival'] != null) {
  //         final estimatedArrival =
  //             responseData['estimatedArrival'] as Map<String, dynamic>;
  //         return {
  //           'success': true,
  //           'estimatedTime': estimatedArrival['estimatedTime'],
  //           'distance': estimatedArrival['distance'],
  //           'message': 'تم جلب وقت الوصول المتوقع بنجاح',
  //         };
  //       }
  //     }

  //     return {'success': false, 'message': 'فشل في جلب وقت الوصول المتوقع'};
  //   } catch (e) {
  //     print('Get estimated arrival error: $e');
  //     return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
  //   }
  // }

  // Get tracking status for an order
  Future<Map<String, dynamic>> getTrackingStatus(String orderId) async {
    try {
      print('============== getTrackingStatus: $orderId');
      final path = AppConstants.locationTrackingStatus.replaceAll(
        '{orderId}',
        orderId,
      );
      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['trackingStatus'] != null) {
          final trackingStatus =
              responseData['trackingStatus'] as Map<String, dynamic>;
          return {
            'success': true,
            'status': trackingStatus['status'],
            'isActive': trackingStatus['isActive'],
            'lastUpdate': trackingStatus['lastUpdate'],
            'message': 'تم جلب حالة التتبع بنجاح',
          };
        }
      }

      return {'success': false, 'message': 'فشل في جلب حالة التتبع'};
    } catch (e) {
      print('Get tracking status error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Get user orders with location tracking
  Future<Map<String, dynamic>> getUserOrdersWithTracking(String userId) async {
    try {
      final path = AppConstants.locationTrackingUserOrders.replaceAll(
        '{userId}',
        userId,
      );
      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['orders'] != null) {
          final orders = responseData['orders'] as List;
          return {
            'success': true,
            'orders': orders,
            'message': 'تم جلب الطلبات مع التتبع بنجاح',
          };
        }
      }

      return {'success': false, 'message': 'فشل في جلب الطلبات مع التتبع'};
    } catch (e) {
      print('Get user orders with tracking error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Start tracking (for testing/documentation)
  Future<Map<String, dynamic>> startTracking(
    String orderId, {
    int updateInterval = 30,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.locationTrackingStart,
        data: {'orderId': orderId, 'updateInterval': updateInterval},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم بدء التتبع بنجاح'};
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في بدء التتبع',
        };
      }
    } catch (e) {
      print('Start tracking error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Stop tracking (for testing/documentation)
  Future<Map<String, dynamic>> stopTracking(String orderId) async {
    try {
      final response = await _apiService.post(
        AppConstants.locationTrackingStop,
        data: {'orderId': orderId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم إيقاف التتبع بنجاح'};
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إيقاف التتبع',
        };
      }
    } catch (e) {
      print('Stop tracking error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }
}
