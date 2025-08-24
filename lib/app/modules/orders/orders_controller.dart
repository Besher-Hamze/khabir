import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersController extends GetxController {
  late final OrdersRepository _ordersRepository;

  // Observable variables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('OrdersController: onInit called');
    try {
      _ordersRepository = Get.find<OrdersRepository>();
      print('OrdersController: Repository found successfully');
      loadOrders();
    } catch (e) {
      print('OrdersController: Error finding repository: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to initialize: $e';
    }
  }

  // Load user orders
  Future<void> loadOrders() async {
    print('OrdersController: loadOrders called');
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('OrdersController: Calling repository.getUserOrders()');
      final OrderResponse response = await _ordersRepository.getUserOrders();
      print(
        'OrdersController: Got response with ${response.orders.length} orders',
      );
      orders.value = response.orders;
    } catch (e) {
      print('OrdersController: Error loading orders: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print('OrdersController: loadOrders completed');
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Format date
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} OMR';
  }
}
