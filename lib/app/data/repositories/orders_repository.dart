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
        throw Exception(
          'failed_to_load_orders'.tr.replaceAll(
            '{error}',
            '$response.statusMessage',
          ),
        );
      }
    } catch (e) {
      throw Exception('error_loading_orders'.tr.replaceAll('{error}', '$e'));
    }
  }

  // Delete order (for rejected orders)
  Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.orders}/$orderId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'order_deleted_successfully'.tr};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'failed_to_delete_order'.tr,
        };
      }
    } catch (e) {
      print('Delete order error: $e');
      return {'success': false, 'message': 'error_deleting_order'.tr};
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
          'message': 'order_cancelled_successfully'.tr,
          // 'order': OrderModel.fromJson(response.data['order']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'failed_to_cancel_order'.tr,
        };
      }
    } catch (e) {
      print('Cancel order error: $e');
      return {
        'success': false,
        'message': 'error_cancelling_order'.tr.replaceAll('{error}', '$e'),
      };
    }
  }

  // Get order details
  Future<OrderModel> getOrderById(int orderId) async {
    try {
      final response = await _apiService.get('${AppConstants.orders}/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw Exception('failed_to_load_order_details'.tr);
      }
    } catch (e) {
      throw Exception(
        'error_loading_order_details'.tr.replaceAll('{error}', '$e'),
      );
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
          'message': 'order_status_updated_successfully'.tr,
          'order': OrderModel.fromJson(response.data['order']),
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'failed_to_update_order_status'.tr,
        };
      }
    } catch (e) {
      print('Update order status error: $e');
      return {
        'success': false,
        'message': 'error_updating_order_status'.tr.replaceAll('{error}', '$e'),
      };
    }
  }
}
