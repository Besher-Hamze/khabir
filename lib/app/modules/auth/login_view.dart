import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import '../../global_widgets/custom_text_field.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                height: 140,
                width: 260,
                margin: const EdgeInsets.only(bottom: 12),
                child: Image.asset(
                  'assets/images/logo_login.png',
                  color: AppColors.primary,
                  fit: BoxFit.cover,
                ),
              ),

              // Welcome Back Title
              Text(
                'welcome_back'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'login_to_continue'.tr,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Phone Number Field
              PhoneTextField(
                controller: controller.loginPhoneController,
                validator: controller.validatePhone,
                hint: 'enter_mobile_number'.tr,
              ),

              const SizedBox(height: 16),

              // Password Field
              Obx(
                () => CustomTextField(
                  hint: 'password'.tr,
                  controller: controller.loginPasswordController,
                  obscureText: !controller.isPasswordVisible.value,
                  validator: controller.validatePassword,
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: AppColors.textLight,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textLight,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.goToForgotPassword,
                  child: Text(
                    'forgot_password'.tr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Login Button
              Obx(
                () => CustomButton(
                  text: 'login'.tr,
                  onPressed: controller.login,
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 24),

              // Skip Button
              Obx(
                () => CustomButton(
                  text: 'skip'.tr,
                  onPressed: controller.loginAsVisitor,
                  isLoading: controller.isVisitorLoading.value,
                  width: double.infinity,
                  backgroundColor: AppColors.background,
                  textColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account'.tr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: controller.goToSignup,
                    child: Text(
                      'signup'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
