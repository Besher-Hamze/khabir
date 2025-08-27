import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/order_model.dart';
import 'package:khabir/app/global_widgets/rating_dialog.dart';
import '../../core/values/colors.dart';
import '../../core/utils/helpers.dart' as Helpers;
import '../orders/orders_controller.dart';
import '../../data/models/provider_model.dart';

class MyBookingsView extends GetView<OrdersController> {
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const MyBookingsView({
    Key? key,
    this.showAppBar = false,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Obx(() {
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

    // If showAppBar is true, wrap in Scaffold with AppBar
    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title ?? 'My Bookings'),
          automaticallyImplyLeading: automaticallyImplyLeading,
          actions: actions,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: content,
      );
    }

    // Otherwise, return just the content
    return content;
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
            child: Text('try_again'.tr),
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

              // ID and Status
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

                  // Order Status Badge
                  controller.getStatusBadge(order.status),
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

          // Dynamic Action Buttons based on order status
          _buildActionButtons(order),
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

  Widget _buildActionButtons(OrderModel order) {
    List<Widget> buttons = [];

    // Show different buttons based on order status
    if (controller.canDeleteOrder(order.status)) {
      // Show delete button for rejected orders
      buttons.add(
        Expanded(
          child: _buildActionButton(
            'Delete',
            Colors.red,
            order,
            onTap: () => controller.deleteOrder(order),
            icon: Icons.delete,
          ),
        ),
      );
    } else if (controller.canTrackOrder(order.status)) {
      // Show track button for approved/accepted/in-progress orders
      buttons.add(
        Expanded(
          child: _buildActionButton(
            'Track',
            Colors.blue,
            order,
            onTap: () => controller.trackOrder(order),
            icon: Icons.location_on,
          ),
        ),
      );
    } else if (controller.canCancelOrder(order.status)) {
      // Show cancel button for pending orders
      buttons.add(
        Expanded(
          child: _buildActionButton(
            'Cancel',
            Colors.orange,
            order,
            onTap: () => controller.cancelOrder(order),
            icon: Icons.cancel,
          ),
        ),
      );
    } else if (controller.canRateOrder(order.status)) {
      // Show rate button for completed orders
      buttons.add(Expanded(child: _buildRatingButton(order)));
    }

    // Always show status info button
    if (buttons.isNotEmpty) {
      buttons.add(const SizedBox(width: 8));
    }

    buttons.add(
      Expanded(
        child: _buildActionButton(
          'Details',
          Colors.grey[600]!,
          order,
          onTap: () => _showOrderDetails(order),
          icon: Icons.info_outline,
        ),
      ),
    );

    return Row(children: buttons);
  }

  Widget _buildActionButton(
    String text,
    Color color,
    OrderModel order, {
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Obx(() {
      bool isLoading =
          (text == 'Delete' && controller.isDeletingOrder.value) ||
          (text != 'Delete' && controller.isLoading.value);

      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isLoading ? color.withOpacity(0.6) : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  void _showOrderDetails(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('order_details'.tr + ' #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', controller.getStatusText(order.status)),
              const SizedBox(height: 8),
              _buildDetailRow('Service', order.service.title),
              const SizedBox(height: 8),
              _buildDetailRow('Provider', order.provider.name),
              const SizedBox(height: 8),
              _buildDetailRow('Phone', order.provider.phone),
              const SizedBox(height: 8),
              _buildDetailRow('Quantity', order.quantity.toString()),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Total Amount',
                controller.formatCurrency(order.totalAmount),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Scheduled Date',
                controller.formatDate(order.scheduledDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Location', order.location),
              if (order.locationDetails.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Location Details', order.locationDetails),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildRatingButton(OrderModel order) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getExistingRating(order.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Already rated - show rating details
          final rating = snapshot.data!;
          final ratingValue = rating['rating']?.toDouble() ?? 0.0;
          final comment = rating['comment'] as String?;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${ratingValue.toInt()} ${ratingValue == 1 ? 'star' : 'stars'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    comment.length > 20
                        ? '${comment.substring(0, 20)}...'
                        : comment,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        } else {
          // Not rated yet - show rate button
          return _buildActionButton(
            'Rate',
            Colors.green,
            order,
            onTap: () => _showRatingDialog(order, context),
            icon: Icons.star,
          );
        }
      },
    );
  }

  void _showRatingDialog(OrderModel order, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        order: order,
        onSubmit: (order, rating, comment) {
          controller.rateProvider(order, rating, comment);
        },
      ),
    );
  }

  // Static method to create a full page version with AppBar
  static Widget createFullPage({
    Key? key,
    String? title,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
  }) {
    return MyBookingsView(
      key: key,
      showAppBar: true,
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  // Static method to create a page with search functionality
  static Widget createSearchablePage({
    Key? key,
    String? title,
    bool automaticallyImplyLeading = true,
  }) {
    return MyBookingsView(
      key: key,
      showAppBar: true,
      title: title,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
            Get.snackbar(
              'Search',
              'Search functionality coming soon!',
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filter functionality
            Get.snackbar(
              'Filter',
              'Filter functionality coming soon!',
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  // void _contactProvider(OrderModel order) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Contact ${order.provider.name}',
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 20),
  //           ListTile(
  //             leading: const Icon(Icons.phone, color: Colors.green),
  //             title: const Text('Call'),
  //             subtitle: Text(order.provider.phone),
  //             onTap: () {
  //               Get.back();
  //               // TODO: Implement phone call functionality
  //               Get.snackbar(
  //                 'Calling',
  //                 'Calling ${order.provider.name}...',
  //                 backgroundColor: Colors.green,
  //                 colorText: Colors.white,
  //               );
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.message, color: Colors.blue),
  //             title: const Text('Send Message'),
  //             subtitle: const Text('Send a message to provider'),
  //             onTap: () {
  //               Get.back();
  //               // TODO: Implement messaging functionality
  //               Get.snackbar(
  //                 'Message',
  //                 'Opening chat with ${order.provider.name}...',
  //                 backgroundColor: Colors.blue,
  //                 colorText: Colors.white,
  //               );
  //             },
  //           ),
  //           const SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
