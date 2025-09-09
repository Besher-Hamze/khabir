import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khabir/app/data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreedToTerms = false.obs;
  var selectedState = ''.obs;
  var profileImagePath = ''.obs;
  var otpCode = ''.obs;
  var phoneNumber = ''.obs;

  // Text controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Oman Governorates list from AppConstants
  List<Map<String, String>> get states => AppConstants.OMAN_GOVERNORATES;

  @override
  void onClose() {
    // phoneController.dispose();
    // passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggle terms agreement
  void toggleTermsAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  // Select state
  void selectState(String state) {
    selectedState.value = state;
  }

  // Pick profile image from gallery
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_pick_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pick profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_pick_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_image_source'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    pickProfileImageFromCamera();
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text('camera'.tr),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    pickProfileImage();
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 50,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text('gallery'.tr),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Login
  Future<void> login() async {
    if (loginFormKey.currentState?.validate() ?? false) return;

    isLoading.value = true;

    try {
      final result = await _authRepository.login(
        phoneController.text.trim(),
        passwordController.text,
      );
      print("result is equal to: $result");
      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'login_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Guest login
  void loginAsGuest() {
    Get.offAllNamed(AppRoutes.main);
  }

  // Sign up
  Future<void> signUp() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (!agreedToTerms.value) {
      Get.snackbar(
        'error'.tr,
        'agree_terms_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedState.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'select_state_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Step 1: Initiate registration with image upload
      final initiateResult = await _authRepository.registerInitiate(
        name: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        state: selectedState.value,
        email: emailController.text.isNotEmpty
            ? emailController.text.trim()
            : null,
        address: selectedState.value.isNotEmpty
            ? '$selectedState.value, Oman'
            : null,
        profileImagePath: profileImagePath.value.isNotEmpty
            ? profileImagePath.value
            : null,
      );

      if (initiateResult['success']) {
        phoneNumber.value = phoneController.text.trim();
        Get.snackbar(
          'success'.tr,
          initiateResult['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        startTimer();
        Get.toNamed(AppRoutes.verifyPhone);
      } else {
        Get.snackbar(
          'error'.tr,
          initiateResult['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'signup_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP for forgot password
  Future<void> sendOTP() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final result = await _authRepository.sendOTP(phoneController.text.trim());

      if (result['success']) {
        phoneNumber.value = phoneController.text.trim();
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        startTimer();
        Get.toNamed(AppRoutes.verifyPhone);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'send_otp_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP (simplified - just phone and OTP)
  Future<void> verifyOTP() async {
    if (otpCode.value.length != 6) {
      Get.snackbar(
        'error'.tr,
        'enter_valid_otp'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authRepository.verifyOTP(
        phoneNumber.value,
        otpCode.value,
      );

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Check if this is from forgot password flow
        if (Get.previousRoute == AppRoutes.forgotPassword) {
          Get.toNamed(AppRoutes.resetPassword);
        } else {
          // This is from signup flow - complete registration
          Get.offAllNamed(AppRoutes.main);
          // await _completeRegistration();
        }
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'verify_otp_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (timerSeconds.value > 0) {
      Get.snackbar(
        'info'.tr,
        'wait_before_resend'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await sendOTP();
  }

  // Reset password
  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await _authRepository.resetPassword(
        phoneNumber.value,
        otpCode.value,
        newPasswordController.text,
      );

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'reset_password_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validators
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }

    // Remove all spaces, dashes, parentheses, and other formatting
    String cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it starts with +
    if (!cleanedPhone.startsWith('+')) {
      return 'phone_must_start_with_plus'.tr;
    }

    // Remove the + for further validation
    String phoneWithoutPlus = cleanedPhone.substring(1);

    // Check if it contains only digits after +
    if (!RegExp(r'^\d+$').hasMatch(phoneWithoutPlus)) {
      return 'invalid_phone_format'.tr;
    }

    // Check length (international standards: 7-15 digits after country code)
    if (phoneWithoutPlus.length < 7 || phoneWithoutPlus.length > 15) {
      return 'invalid_phone_length'.tr;
    }

    // Optional: Check for specific Oman country code (+968)
    if (!cleanedPhone.startsWith('+968')) {
      return 'phone_must_be_omani'.tr;
    }

    // Oman phone numbers are typically 8 digits after +968
    if (phoneWithoutPlus.length != 11 || !phoneWithoutPlus.startsWith('968')) {
      return 'invalid_oman_phone'.tr;
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value.length < 6) {
      return 'password_too_short'.tr;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value != passwordController.text) {
      return 'passwords_not_match'.tr;
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value.length < 3) {
      return 'username_too_short'.tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'invalid_email'.tr;
      }
    }
    return null;
  }

  // Navigation methods
  void goToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void goToTermsAndConditions() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  void goToPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  // Timer for OTP resend
  RxInt timerSeconds = 120.obs; // 2 minutes timer
  Timer? _timer;

  void startTimer() {
    timerSeconds.value = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Format timer display
  String get formattedTimer {
    int minutes = timerSeconds.value ~/ 60;
    int seconds = timerSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Clear form data
  void clearFormData() {
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    usernameController.clear();
    emailController.clear();
    newPasswordController.clear();
    selectedState.value = '';
    profileImagePath.value = '';
    otpCode.value = '';
    phoneNumber.value = '';
    agreedToTerms.value = false;
  }
}
