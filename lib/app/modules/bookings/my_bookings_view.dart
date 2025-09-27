import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/order_model.dart';
import 'package:khabir/app/global_widgets/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/values/colors.dart';
import '../../core/utils/helpers.dart' as Helpers;
import '../orders/orders_controller.dart';

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
          title: Text(title ?? 'my_bookings_title'.tr),
          automaticallyImplyLeading: automaticallyImplyLeading,
          actions: actions,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
            'something_went_wrong'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
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
            'no_bookings_yet'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_bookings_message'.tr,
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
                    'order_id'.tr + ' ${order.id}',
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
              _buildDetailColumn(
                'serving_number'.tr,
                order.quantity.toString(),
              ),
              _buildDetailColumn(
                'duration'.tr,
                Helpers.formatDate(order.scheduledDate),
              ),
              _buildDetailColumn(
                'total_price'.tr,
                controller.formatCurrency(order.totalAmount),
              ),
            ],
          ),

          // Services Breakdown Summary (if multiple services)
          if (order.isMultipleServices &&
              order.servicesBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildServicesSummary(order),
          ],

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
            'delete'.tr,
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
            'track'.tr,
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
            'cancel'.tr,
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
          'details'.tr,
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
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.85, // Max 85% of screen height
            maxWidth: Get.width - 32, // Full width minus padding
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'order_details'.tr,
                            style: Get.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${'order_id'.tr} #${order.id}',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildStatusCard(order),
                      const SizedBox(height: 16),

                      // Service Information Card
                      _buildInfoCard(
                        title: 'service_information'.tr,
                        icon: Icons.build,
                        children: [
                          _buildDetailRow(
                            'quantity'.tr,
                            order.quantity.toString(),
                          ),
                          _buildAmountRow(
                            'total_amount'.tr,
                            controller.formatCurrency(order.totalAmount),
                          ),
                          _buildDetailRow(
                            'scheduled_date'.tr,
                            Helpers.formatDate(order.scheduledDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Provider Information Card
                      _buildInfoCard(
                        title: 'provider_information'.tr,
                        icon: Icons.person,
                        children: [
                          _buildDetailRow('provider'.tr, order.provider.name),
                          if (order.status.toLowerCase() == 'accepted' &&
                              order.provider.phone.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailRow(
                                    'phone'.tr,
                                    order.provider.phone,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await _makePhoneCall(order.provider.phone);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.call,
                                      size: 20,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location Information Card
                      _buildInfoCard(
                        title: 'location_information'.tr,
                        icon: Icons.location_on,
                        children: [
                          if (order.locationDetails != null &&
                              order.locationDetails!.isNotEmpty)
                            _buildDetailRow(
                              'location_details'.tr,
                              order.locationDetails!,
                            ),
                        ],
                      ),

                      // Services Breakdown Card
                      if (order.servicesBreakdown.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'services_breakdown'.tr,
                          icon: Icons.list_alt,
                          children: [_buildServicesBreakdownSection(order)],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                        label: Text('close'.tr),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for the improved dialog
  Widget _buildStatusCard(OrderModel order) {
    Color statusColor = _getStatusColor(order.status);
    IconData statusIcon = _getStatusIcon(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'status'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 16,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.work_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
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

  Widget _buildServicesBreakdownSection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'services_breakdown'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...order.servicesBreakdown.map(
          (service) => _buildServiceBreakdownItem(service),
        ),
      ],
    );
  }

  Widget _buildServiceBreakdownItem(ServiceBreakdown service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.serviceTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                'quantity'.tr + ': ${service.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service.serviceDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'unit_price'.tr +
                    ': ${service.unitPrice.toStringAsFixed(2)} OMR',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'total'.tr + ': ${service.totalPrice.toStringAsFixed(2)} OMR',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (service.category != null) ...[
            const SizedBox(height: 4),
            Text(
              'category'.tr + ': ${service.category!.titleEn}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'multiple_services'.tr + ' (${order.servicesBreakdown.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.servicesBreakdown
              .take(2)
              .map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '• ${service.serviceTitle}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${service.quantity}x ${service.unitPrice.toStringAsFixed(2)} OMR',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          if (order.servicesBreakdown.length > 2) ...[
            Text(
              'and_more_services'.tr.replaceAll(
                '{count}',
                '${order.servicesBreakdown.length - 2}',
              ),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(OrderInvoice invoice) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, size: 16, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'invoice'.tr + ' #${invoice.id}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'payment_status'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: invoice.paymentStatus == 'paid'
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: invoice.paymentStatus == 'paid'
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${invoice.totalAmount.toStringAsFixed(2)} OMR',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
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
                      '${ratingValue.toInt()} ${ratingValue == 1 ? 'star'.tr : 'stars'.tr}',
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
            'rate'.tr,
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

  // Make phone call using url_launcher
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'[\s\-\(\)]'),
        '',
      );

      // Create the phone URL
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

      // Check if the device can launch the phone app
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: show error message
        Get.snackbar(
          'error'.tr,
          'cannot_make_phone_call'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      // Handle any errors
      Get.snackbar(
        'error'.tr,
        'failed_to_make_phone_call'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
