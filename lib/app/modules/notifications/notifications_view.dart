import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/global_widgets/custom_appbar.dart';

import '../track/track_screen.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: DetailAppBar(
        title: 'notifications'.tr,
        notificationCount:
            0.obs, // Hide notification badge on notification screen
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            providerName: 'Mohamad Soltani',
            serviceType: 'Electricity',
            id: '66518722',
            rating: 5.0,
            category: 'Electricity',
            type: 'Switch lamps',
            number: '2',
            duration: 'Now',
            totalPrice: '10 OMR',
            imageUrl: 'assets/images/logo-04.png',
            statusButtons: [
              StatusButton(text: 'Incomplete', color: Colors.red),
              StatusButton(text: 'Complete', color: Colors.green),
              StatusButton(text: 'Track', color: Colors.blue),
              StatusButton(text: 'Acceptable', color: Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationCard(
            providerName: 'Ali Marwan',
            serviceType: 'Electricity',
            id: '66533322',
            rating: 4.0,
            category: 'Electricity',
            type: 'Switch lamps',
            number: '1',
            duration: '22/5/2025',
            totalPrice: '12 OMR',
            imageUrl: 'assets/images/logo-04.png',
            statusButtons: [
              StatusButton(text: 'Incomplete', color: Colors.red),
              StatusButton(text: 'Complete', color: Colors.green),
              StatusButton(text: 'Delete', color: Colors.black),
              StatusButton(text: 'Rejected', color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationCard(
            providerName: 'Ahmed Hassan',
            serviceType: 'Plumbing',
            id: '66512345',
            rating: 4.5,
            category: 'Plumbing',
            type: 'Pipe repair',
            number: '1',
            duration: 'Tomorrow',
            totalPrice: '25 OMR',
            imageUrl: 'assets/images/logo-04.png',
            statusButtons: [
              StatusButton(text: 'Pending', color: Colors.orange),
              StatusButton(text: 'Accept', color: Colors.green),
              StatusButton(text: 'Decline', color: Colors.red),
              StatusButton(text: 'Reschedule', color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String providerName,
    required String serviceType,
    required String id,
    required double rating,
    required String category,
    required String type,
    required String number,
    required String duration,
    required String totalPrice,
    required String imageUrl,
    required List<StatusButton> statusButtons,
  }) {
    return Container(
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
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceType,
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
                    'ID $id',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: index < rating.floor()
                              ? Colors.amber
                              : Colors.grey[300],
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
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
              _buildDetailColumn('Category', category),
              _buildDetailColumn('Type', type),
              _buildDetailColumn('Number', number),
              _buildDetailColumn('Duration', duration),
              _buildDetailColumn('Total Price', totalPrice),
            ],
          ),

          const SizedBox(height: 20),

          // Status Buttons
          Row(
            children: statusButtons
                .map(
                  (button) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildStatusButton(button.text, button.color),
                    ),
                  ),
                )
                .toList(),
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

  Widget _buildStatusButton(String text, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
        print('$text button tapped');

        // Add specific actions based on button type
        switch (text.toLowerCase()) {
          case 'track':
            final booking = ServiceBooking(
              id: '66533322',
              // Use actual ID from your data
              category: 'Electricity',
              type: 'Switch lamps',
              number: 2,
              duration: '7/5/2025',
              providerName: 'Mohamad Soltani',
              providerPhone: '+96XXXXXXXXX',
              providerImage: 'assets/images/provider.jpg',
              price: 36,
            );

            // Navigate to tracking screen
            Get.to(() => TrackingView(booking: booking));

            break;
          case 'complete':
            // Mark as complete
            Get.snackbar(
              'Completed',
              'Service marked as completed!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            break;
          case 'delete':
            // Show delete confirmation
            Get.dialog(
              AlertDialog(
                title: Text('delete_notification'.tr),
                content: Text('delete_notification_confirmation'.tr),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Deleted',
                        'Notification deleted successfully',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'delete'.tr,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
            break;
          default:
            Get.snackbar(
              'Action',
              '$text action performed',
              backgroundColor: color,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            break;
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

class StatusButton {
  final String text;
  final Color color;

  StatusButton({required this.text, required this.color});
}
