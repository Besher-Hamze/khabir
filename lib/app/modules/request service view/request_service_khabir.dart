import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:khabir/app/core/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/values/colors.dart';

class RequestServiceKhabirView extends StatelessWidget {
  const RequestServiceKhabirView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    final serviceName = arguments?['serviceName'] ?? 'Khabir Service';
    final serviceImage = arguments?['serviceImage'] ?? '';
    final serviceDescription = arguments?['serviceDescription'] ?? '';
    final serviceWhatsapp = arguments?['serviceWhatsapp'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                ),
                child: serviceImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          serviceImage.startsWith('http')
                              ? serviceImage
                              : getImageUrl(serviceImage),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),

              const SizedBox(height: 24),

              // Description Section
              Text(
                'description'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // Description Text
              Text(
                serviceDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _contactViaWhatsApp(serviceWhatsapp),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'contact_us'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Service Image',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _contactViaWhatsApp(String whatsappNumber) async {
    if (whatsappNumber.isNotEmpty) {
      final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
      final whatsappUrl = 'https://wa.me/$cleanNumber';

      try {
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl));
        } else {
          _showErrorDialog('WhatsApp is not installed on this device');
        }
      } catch (e) {
        _showErrorDialog('Failed to open WhatsApp: $e');
      }
    } else {
      _showErrorDialog('WhatsApp number not available for this service');
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
