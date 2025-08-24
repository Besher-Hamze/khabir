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
}
