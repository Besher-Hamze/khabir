import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/order_model.dart';
import 'package:khabir/app/modules/track/track_binding.dart';
import 'package:khabir/app/modules/track/track_screen.dart';
import '../../data/repositories/orders_repository.dart';
import '../../data/repositories/providers_repository.dart';

class OrdersController extends GetxController {
  late final OrdersRepository _ordersRepository;
  late final ProvidersRepository _providersRepository;

  // Observable variables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isDeletingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('OrdersController: onInit called');
    try {
      _ordersRepository = Get.find<OrdersRepository>();
      _providersRepository = Get.find<ProvidersRepository>();
      print('OrdersController: Repository found successfully');
      loadOrders();
    } catch (e) {
      print('OrdersController: Error finding repository: $e');
      hasError.value = true;
      'failed_to_initialize'.tr.replaceAll('{error}', '$e');
    }
  }

  // Load user orders
  Future<void> loadOrders() async {
    print('OrdersController: loadOrders called');
    try {
      isLoading.value = true;
      hasError.value = false;

      print('OrdersController: Calling repository.getUserOrders()');
      final OrderResponse response = await _ordersRepository.getUserOrders();
      print(
        'OrdersController: Got response with ${response.orders.length} orders',
      );
      orders.value = response.orders;
    } catch (e) {
      print('OrdersController: Error loading orders: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
      print('OrdersController: loadOrders completed');
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  // Delete order (for rejected orders)
  Future<void> deleteOrder(OrderModel order) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await Get.dialog<bool>(
        AlertDialog(
          title: Text('delete_order'.tr),
          content: Text(
            'delete_order_confirmation_full'.tr.replaceAll(
              '{order_id}',
              '${order.id}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('delete'.tr),
            ),
          ],
        ),
      );

      if (confirmDelete != true) return;

      isDeletingOrder.value = true;

      final result = await _ordersRepository.deleteOrder(order.id);

      if (result['success']) {
        // Remove order from local list
        orders.removeWhere((o) => o.id == order.id);

        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_order'.tr.replaceAll('{error}', '$e'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isDeletingOrder.value = false;
    }
  }

  // Track order (for approved orders)
  void trackOrder(OrderModel order) {
    try {
      // Convert OrderModel to ServiceBooking for TrackingView
      final serviceBooking = ServiceBooking(
        id: order.id.toString(),
        category: order.service.title,
        type: order.service.description,
        number: order.quantity,
        duration: formatDate(order.scheduledDate),
        providerName: order.provider.name,
        providerPhone: order.provider.phone,
        providerImage: order.provider.image.isNotEmpty
            ? order.provider.image
            : 'assets/images/placeholder.png',
        price: order.totalAmount.toInt(),
      );

      // Navigate to tracking screen
      Get.to(
        () => TrackingView(booking: serviceBooking),
        binding: LocationTrackingBinding(),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_open_tracking'.tr.replaceAll('{error}', '$e'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Cancel order (for pending orders)
  Future<void> cancelOrder(OrderModel order) async {
    try {
      // Show confirmation dialog
      bool? confirmCancel = await Get.dialog<bool>(
        AlertDialog(
          title: Text('cancel_order'.tr),
          content: Text('cancel_order_confirmation'.tr + '${order.id}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('no'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('cancel_order'.tr),
            ),
          ],
        ),
      );

      if (confirmCancel != true) return;

      isLoading.value = true;

      final result = await _ordersRepository.cancelOrder(order.id);

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        // refresh orders
        await loadOrders();
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_cancel_order'.tr.replaceAll('{error}', '$e'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get status color based on order status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  // Get status text with proper formatting
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending'.tr;
      case 'accepted':
        return 'accepted'.tr;
      case 'approved':
        return 'approved'.tr;
      case 'rejected':
        return 'rejected'.tr;
      case 'in_progress':
        return 'in_progress'.tr;
      case 'completed':
        return 'completed'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      default:
        return status.toUpperCase();
    }
  }

  // Check if order can be tracked
  bool canTrackOrder(String status) {
    return [
      'accepted',
      'approved',
      'in_progress',
    ].contains(status.toLowerCase());
  }

  // Check if order can be deleted
  bool canDeleteOrder(String status) {
    return status.toLowerCase() == 'rejected' ||
        status.toLowerCase() == 'cancelled';
  }

  // Check if order can be cancelled
  bool canCancelOrder(String status) {
    return status.toLowerCase() == 'pending';
  }

  // Check if order can be rated (only completed orders)
  bool canRateOrder(String status) {
    return status.toLowerCase() == 'completed';
  }

  // Check if user has already rated this order
  Future<bool> hasRatedOrder(int orderId) async {
    try {
      return await _providersRepository.hasUserRatedProvider(orderId);
    } catch (e) {
      print('Error checking if order rated: $e');
      return false;
    }
  }

  // Get user's existing rating for an order
  Future<Map<String, dynamic>?> getExistingRating(int orderId) async {
    try {
      return await _providersRepository.getUserRating(orderId);
    } catch (e) {
      print('Error getting existing rating: $e');
      return null;
    }
  }

  // Rate a provider for a completed order
  Future<void> rateProvider(
    OrderModel order,
    double rating,
    String? comment,
  ) async {
    try {
      if (!canRateOrder(order.status)) {
        Get.snackbar(
          'cannot_rate'.tr,
          'only_completed_orders_can_be_rated'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Check if already rated
      final hasRated = await hasRatedOrder(order.id);
      if (hasRated) {
        Get.snackbar(
          'already_rated'.tr,
          'already_rated_provider_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final result = await _providersRepository.rateProvider(
        providerId: order.provider.id,
        orderId: order.id,
        rating: rating,
        comment: comment,
      );

      if (result['success']) {
        Get.snackbar(
          'rating_submitted'.tr,
          'thank_you_feedback'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.star, color: Colors.white),
        );

        // Refresh orders to get updated data
        await loadOrders();
      } else {
        Get.snackbar(
          'rating_failed'.tr,
          result['message'] ?? 'failed_to_submit_rating'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_submit_rating_error'.tr.replaceAll('{error}', '$e'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
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

  // Get order status badge widget
  Widget getStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: getStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: getStatusColor(status),
        ),
      ),
    );
  }
}

// // ServiceBooking class for TrackingView compatibility
// class ServiceBooking {
//   final String id;
//   final String category;
//   final String type;
//   final int number;
//   final String duration;
//   final String providerName;
//   final String providerPhone;
//   final String providerImage;
//   final int price;

//   ServiceBooking({
//     required this.id,
//     required this.category,
//     required this.type,
//     required this.number,
//     required this.duration,
//     required this.providerName,
//     required this.providerPhone,
//     required this.providerImage,
//     required this.price,
//   });
// }
