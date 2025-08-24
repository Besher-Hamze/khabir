import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../core/utils/helpers.dart' as Helpers;
import '../orders/orders_controller.dart';
import '../../data/models/provider_model.dart';

class MyBookingsView extends GetView<OrdersController> {
  const MyBookingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }

      if (controller.hasError.value) {
        return _buildErrorWidget();
      }

      if (controller.orders.isEmpty) {
        return _buildEmptyWidget();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildBookingCard(order);
          },
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t made any bookings yet.\nStart by requesting a service!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Row(
            children: [
              // Provider Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: order.provider.image.isNotEmpty
                      ? Image.network(
                          Helpers.getImageUrl(order.provider.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            );
                          },
                        )
                      : Icon(Icons.person, size: 30, color: Colors.grey[400]),
                ),
              ),

              const SizedBox(width: 12),

              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.provider.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.service.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // ID and Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ID ${order.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating (using a default 5.0 for now)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: index < 5 ? Colors.amber : Colors.grey[300],
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '5.0',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Details Section
          Row(
            children: [
              _buildDetailColumn('Category', order.service.title),
              _buildDetailColumn('Type', order.service.description),
              _buildDetailColumn('Number', order.quantity.toString()),
              _buildDetailColumn(
                'Duration',
                controller.formatDate(order.scheduledDate),
              ),
              _buildDetailColumn(
                'Total Price',
                controller.formatCurrency(order.totalAmount),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status Buttons
          Row(
            children: [
              Expanded(
                child: _buildStatusButton('Incomplete', Colors.red, order),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('Complete', Colors.green, order),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusButton('Track', Colors.blue, order)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('Acceptable', Colors.green, order),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String text, Color color, OrderModel order) {
    return GestureDetector(
      onTap: () {
        if (text.toLowerCase() == 'track') {
          // TODO: Implement tracking functionality
          Get.snackbar(
            'Tracking',
            'Tracking feature coming soon!',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        } else if (text.toLowerCase() == 'incomplete') {
          Get.snackbar(
            'Status Update',
            'Marking as incomplete...',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else if (text.toLowerCase() == 'complete') {
          Get.snackbar(
            'Status Update',
            'Marking as complete...',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (text.toLowerCase() == 'acceptable') {
          Get.snackbar(
            'Status Update',
            'Marking as acceptable...',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
