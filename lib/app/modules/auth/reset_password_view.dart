import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import '../../global_widgets/custom_text_field.dart';
import 'auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({Key? key}) : super(key: key);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.resetPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Center(
                  child: Text(
                    'reset_password'.tr,
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
                    'reset_password_description'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Code Field
                CustomTextField(
                  label: 'verification_code'.tr,
                  hint: 'enter_6_digit_code'.tr,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (value) {
                    controller.otpCode.value = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'field_required'.tr;
                    }
                    if (value.length != 6) {
                      return 'enter_valid_otp'.tr;
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.verified_user,
                    color: AppColors.textLight,
                  ),
                  suffixIcon: Obx(
                    () => controller.timerSeconds.value > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            child: Text(
                              controller.formattedTimer,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: controller.resendOTP,
                            child: Text(
                              'resend'.tr,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // New Password Field
                Obx(
                  () => CustomTextField(
                    label: 'new_password'.tr,
                    controller: controller.newPasswordController,
                    obscureText: !controller.isPasswordVisible.value,
                    textInputAction: TextInputAction.next,
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

                const SizedBox(height: 16),

                // Confirm New Password Field
                Obx(
                  () => CustomTextField(
                    label: 'confirm_new_password'.tr,
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'field_required'.tr;
                      }
                      if (value != controller.newPasswordController.text) {
                        return 'passwords_not_match'.tr;
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppColors.textLight,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textLight,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    onFieldSubmitted: (_) {
                      if (controller.resetPasswordFormKey.currentState
                              ?.validate() ??
                          false) {
                        controller.resetPassword();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Reset Password Button
                Obx(
                  () => CustomButton(
                    text: 'reset_password'.tr,
                    onPressed: controller.resetPassword,
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(height: 16),

                // Resend OTP Button (visible when timer is 0)
                Obx(
                  () => controller.timerSeconds.value == 0
                      ? Center(
                          child: TextButton.icon(
                            onPressed: controller.resendOTP,
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            label: Text(
                              'resend_verification_code'.tr,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),

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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (text == 'عربي' && Get.locale?.languageCode != 'ar') {
          Get.updateLocale(const Locale('ar'));
        } else if (text == 'EN' && Get.locale?.languageCode != 'en') {
          Get.updateLocale(const Locale('en'));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
