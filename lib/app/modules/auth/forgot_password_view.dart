import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import '../../global_widgets/custom_text_field.dart';
import 'auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                Center(
                  child: Text(
                    'forgot_password'.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Center(
                  child: Text(
                    'forgot_password_description'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Phone Number Field
                PhoneTextField(
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                ),

                const SizedBox(height: 32),

                // Send OTP Button
                Obx(
                  () => CustomButton(
                    text: 'send_otp'.tr,
                    onPressed: controller.sendOTP,
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  ),
                ),

                const Spacer(),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'remember_password'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.goToLogin,
                      child: Text(
                        'login'.tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
