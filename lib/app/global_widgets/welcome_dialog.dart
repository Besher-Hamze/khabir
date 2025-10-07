import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/colors.dart';

class WelcomeDialog extends StatelessWidget {
  final VoidCallback? onOkPressed;

  const WelcomeDialog({Key? key, this.onOkPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                'assets/images/logo_white.png', // Update with your actual logo path
                fit: BoxFit.cover,
              ),
            ),

            // Welcome Title
            Text(
              'welcome_to_the_khabir_app'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Welcome Message
            Text(
              'we_are_happy_to_welcome_you_to_the_khabir_family'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOkPressed ?? () => Get.back(),
                child: Text(
                  'ok'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to show the dialog
  static Future<void> show({VoidCallback? onOkPressed}) {
    return Get.dialog(
      WelcomeDialog(onOkPressed: onOkPressed),
      barrierDismissible: false, // Prevent dismissing by tapping outside
      barrierColor: Colors.black54,
    );
  }
}

// Extension method for easy access
extension WelcomeDialogExtension on GetInterface {
  Future<void> showWelcomeDialog({VoidCallback? onOkPressed}) {
    return WelcomeDialog.show(onOkPressed: onOkPressed);
  }
}
