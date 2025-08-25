import 'package:get/get.dart';
import 'package:khabir/app/data/models/order_model.dart';
import '../models/provider_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class OrdersRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get user orders
  Future<OrderResponse> getUserOrders() async {
    try {
      final response = await _apiService.get(AppConstants.getUserOrders);

      if (response.statusCode == 200) {
        return OrderResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load orders: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error loading orders: $e');
    }
  }

  // Delete order (for rejected orders)
  Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.orders}/$orderId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Order deleted successfully'};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete order',
        };
      }
    } catch (e) {
      print('Delete order error: $e');
      return {'success': false, 'message': 'Error deleting order: $e'};
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.orders}/$orderId/cancel',
        data: {'status': 'cancelled'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Order cancelled successfully',
          'order': OrderModel.fromJson(response.data['order']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      print('Cancel order error: $e');
      return {'success': false, 'message': 'Error cancelling order: $e'};
    }
  }

  // Get order details
  Future<OrderModel> getOrderById(int orderId) async {
    try {
      final response = await _apiService.get('${AppConstants.orders}/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Error loading order details: $e');
    }
  }

  // Update order status (for testing purposes)
  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.orders}/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Order status updated successfully',
          'order': OrderModel.fromJson(response.data['order']),
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to update order status',
        };
      }
    } catch (e) {
      print('Update order status error: $e');
      return {'success': false, 'message': 'Error updating order status: $e'};
    }
  }
}
