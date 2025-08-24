import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  var selectedRole = ''.obs;

  void selectUser() {
    selectedRole.value = 'user';
    Get.offAllNamed(AppRoutes.login);
  }

  void selectServiceProvider() async {
    selectedRole.value = 'provider';
    
    // Open Google Play Store for provider app
    final url = '${AppConstants.playStoreUrl}${AppConstants.providerAppId}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: show dialog with manual instructions
        Get.dialog(
          AlertDialog(
            title: Text('download_provider_app'.tr),
            content: Text('download_provider_app_message'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'cannot_open_store'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
