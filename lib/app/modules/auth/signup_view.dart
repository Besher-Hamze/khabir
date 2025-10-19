import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/global_widgets/custom_drop_down.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import '../../global_widgets/custom_text_field.dart';
import 'auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 100,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Image.asset(
                    'assets/images/logo_login.png',
                    color: AppColors.primary,
                    fit: BoxFit.cover,
                  ),
                ),

                // Title
                Text(
                  'create_account_title'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Full Name Field
                CustomTextField(
                  hint: 'enter_full_name'.tr,
                  controller: controller.usernameController,
                  validator: controller.validateUsername,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 16),

                // Phone Number Field
                PhoneTextField(
                  hint: 'enter_mobile_number'.tr,
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                ),

                const SizedBox(height: 16),

                // State Dropdown - Custom Grouped
                Obx(
                  () => CustomGroupedDropdown(
                    hint: 'choose_state'.tr,
                    selectedValue: controller.selectedState.value.isEmpty
                        ? null
                        : controller.selectedState.value,
                    data: OmanStatesData.states,
                    onChanged: (String value, String label) {
                      controller.selectState(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'field_required'.tr;
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.public,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Obx(
                  () => CustomTextField(
                    hint: 'enter_password'.tr,
                    controller: controller.passwordController,
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

                const SizedBox(height: 16),

                // Confirm Password Field
                Obx(
                  () => CustomTextField(
                    hint: 'confirm_password_label'.tr,
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: controller.validateConfirmPassword,
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
                  ),
                ),

                const SizedBox(height: 16),

                // Photo Upload Field
                GestureDetector(
                  onTap: controller.pickProfileImage,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.photo_camera,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => Text(
                              controller.profileImagePath.value.isNotEmpty
                                  ? 'photo_selected'.tr
                                  : 'choose_photo_to_upload'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.file_upload_outlined,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                Obx(
                  () => Row(
                    children: [
                      Checkbox(
                        value: controller.agreedToTerms.value,
                        onChanged: (value) => controller.toggleTermsAgreement(),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.goToTermsAndConditions,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: 'i_agree_to_terms'.tr),
                                TextSpan(
                                  text: 'terms_and_conditions'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                Obx(
                  () => CustomButton(
                    text: 'sign_up_button'.tr,
                    onPressed: controller.agreedToTerms.value
                        ? controller.signUp
                        : null,
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                    enabled: controller.agreedToTerms.value,
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'have_account_already'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: Text(
                        'log_in'.tr,
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
      ),
    );
  }
}
