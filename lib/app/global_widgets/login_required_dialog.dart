// login required dialog
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/routes/app_routes.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.amber[800]),
          const SizedBox(width: 4),
          Text(
            'login_required'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Text(
        'you_must_login_to_continue'.tr,
        style: TextStyle(color: Colors.grey[800], fontSize: 15),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
          child: Text('ok'.tr),
        ),
        ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: Text(
            'login'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
