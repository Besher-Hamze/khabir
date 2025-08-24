import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class BookingRepository {
  final ApiService _apiService = ApiService.instance;

  // Create a new order
  Future<Map<String, dynamic>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiService.post(
        AppConstants.orders,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['order'] != null) {
          final order = Order.fromJson(responseData['order']);
          return {
            'success': true,
            'order': order,
            'message': 'تم إنشاء الطلب بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في إنشاء الطلب',
      };
    } catch (e) {
      print('Create order error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Get user orders
  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await _apiService.get(AppConstants.orders);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['orders'] != null) {
          final orders = (responseData['orders'] as List)
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();

          return {
            'success': true,
            'orders': orders,
            'message': 'تم جلب الطلبات بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب الطلبات',
      };
    } catch (e) {
      print('Get user orders error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Get order history with pagination
  Future<Map<String, dynamic>> getOrderHistory(
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        AppConstants.orderHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['orders'] != null) {
          final orders = (responseData['orders'] as List)
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();

          return {
            'success': true,
            'orders': orders,
            'total': responseData['total'],
            'page': responseData['page'],
            'limit': responseData['limit'],
            'message': 'تم جلب سجل الطلبات بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب سجل الطلبات',
      };
    } catch (e) {
      print('Get order history error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.orders}/$orderId/cancel',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم إلغاء الطلب بنجاح',
        };
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إلغاء الطلب',
        };
      }
    } catch (e) {
      print('Cancel order error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Get order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('${AppConstants.orders}/$orderId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['order'] != null) {
          final order = Order.fromJson(responseData['order']);
          return {
            'success': true,
            'order': order,
            'message': 'تم جلب الطلب بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب الطلب',
      };
    } catch (e) {
      print('Get order by ID error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Get orders by status
  Future<Map<String, dynamic>> getOrdersByStatus(String status) async {
    try {
      final response =
          await _apiService.get('${AppConstants.orders}/status/$status');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['orders'] != null) {
          final orders = (responseData['orders'] as List)
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();

          return {
            'success': true,
            'orders': orders,
            'message': 'تم جلب الطلبات بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب الطلبات',
      };
    } catch (e) {
      print('Get orders by status error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Convert Order to Booking for backward compatibility
  List<Booking> ordersToBookings(List<Order> orders) {
    return orders.map((order) => order.toBooking()).toList();
  }
}
