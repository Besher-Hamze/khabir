import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  height: 150,
                  width: 250,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Image.asset(
                    'assets/images/logo_login.png',
                    color: AppColors.primary,
                    fit: BoxFit.cover,
                  ),
                ),

                // Title
                Text(
                  'Create An Account',
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
                  label: 'Enter your full name',
                  controller: controller.usernameController,
                  validator: controller.validateUsername,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 16),

                // Phone Number Field
                CustomTextField(
                  label: 'Enter your mobile number',
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 16),

                // State Dropdown
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedState.value.isEmpty
                      ? null
                      : controller.selectedState.value,
                  decoration: InputDecoration(
                    labelText: 'Choose your state',
                    prefixIcon: const Icon(
                      Icons.language,
                      color: AppColors.textLight,
                    ),
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textLight,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: controller.states.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      controller.selectState(value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'field_required'.tr;
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 16),

                // Password Field
                Obx(() => CustomTextField(
                  label: 'Enter your password',
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
                )),

                const SizedBox(height: 16),

                // Confirm Password Field
                Obx(() => CustomTextField(
                  label: 'Confirm your password',
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
                )),

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
                          child: Obx(() => Text(
                            controller.profileImagePath.value.isNotEmpty
                                ? 'Photo selected'
                                : 'Choose photo to upload',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          )),
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
                Obx(() => Row(
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
                        onTap: controller.toggleTermsAgreement,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'terms and conditions',
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
                )),

                const SizedBox(height: 30),

                // Sign Up Button
                Obx(() => CustomButton(
                  text: 'SIGN UP',
                  onPressed: controller.agreedToTerms.value ? controller.signUp : null,
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                  enabled: controller.agreedToTerms.value,
                )),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an account already? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: const Text(
                        'Log in',
                        style: TextStyle(
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